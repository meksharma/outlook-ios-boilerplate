#!/usr/bin/env node

const http = require("http");
const https = require("https");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawn } = require("child_process");

const host = "127.0.0.1";
const port = Number(process.env.WORKIQ_BRIDGE_PORT || 8765);
const oauthRedirectPort = Number(process.env.WORKIQ_OAUTH_REDIRECT_PORT || 12798);
const workIQMcpURL = "https://workiq.svc.cloud.microsoft/mcp";
const workIQOAuthClientId = "ba081686-5d24-4bc6-a0d6-d034ecffed87";
const maxBodyBytes = 64 * 1024;
const mailCacheTtlMs = 5 * 60 * 1000;
const messageBodyCache = new Map();
const recentMailPath =
  "/me/mailFolders/inbox/messages?$top=40" +
  "&$select=id,conversationId,subject,bodyPreview,receivedDateTime,isRead,from,toRecipients,hasAttachments,flag,importance,inferenceClassification,categories" +
  "&$orderby=receivedDateTime desc";
const threadStatsPath =
  "/me/mailFolders/inbox/messages?$top=250" +
  "&$select=conversationId,isRead";

let mailCache = null;
let mailCacheTime = 0;
let mailRequest = null;
let graphAccessToken = null;
let graphAccessTokenTime = 0;
const photoCache = new Map();
const authDirectory = path.join(os.homedir(), ".outlook-ios-boilerplate");
const authFile = path.join(authDirectory, "workiq-mcp-auth.json");

let mcpClient = null;
let mcpTransport = null;
let mcpConnection = null;
let workIQToolNames = null;

function readAuthState() {
  try {
    return JSON.parse(fs.readFileSync(authFile, "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") {
      return {};
    }
    throw new Error(`Could not read Work IQ authentication state: ${error.message}`);
  }
}

function writeAuthState(state) {
  fs.mkdirSync(authDirectory, { recursive: true, mode: 0o700 });
  const temporaryFile = `${authFile}.tmp`;
  fs.writeFileSync(temporaryFile, JSON.stringify(state, null, 2), { mode: 0o600 });
  fs.renameSync(temporaryFile, authFile);
}

function openBrowser(url) {
  let command;
  let args;
  if (process.platform === "darwin") {
    command = "open";
    args = [url];
  } else if (process.platform === "win32") {
    command = "cmd";
    args = ["/c", "start", "", url];
  } else {
    command = "xdg-open";
    args = [url];
  }

  const child = spawn(command, args, { detached: true, stdio: "ignore" });
  child.unref();
}

class WorkIQOAuthProvider {
  constructor() {
    this.authState = readAuthState();
    this.callbackPromise = null;
    this.callbackServer = null;
  }

  get redirectUrl() {
    return `http://localhost:${oauthRedirectPort}/callback`;
  }

  get clientMetadata() {
    return {
      client_name: "Outlook iOS Boilerplate Work IQ Bridge",
      redirect_uris: [this.redirectUrl],
      grant_types: ["authorization_code", "refresh_token"],
      response_types: ["code"],
      token_endpoint_auth_method: "none",
    };
  }

  clientInformation() {
    return {
      client_id: workIQOAuthClientId,
      token_endpoint_auth_method: "none",
    };
  }

  tokens() {
    return this.authState.tokens;
  }

  saveTokens(tokens) {
    this.authState.tokens = tokens;
    writeAuthState(this.authState);
  }

  saveCodeVerifier(codeVerifier) {
    this.authState.codeVerifier = codeVerifier;
    writeAuthState(this.authState);
  }

  codeVerifier() {
    if (!this.authState.codeVerifier) {
      throw new Error("Work IQ authentication is missing its PKCE verifier.");
    }
    return this.authState.codeVerifier;
  }

  async redirectToAuthorization(authorizationUrl) {
    this.callbackPromise = this.startCallbackServer();
    await new Promise((resolve, reject) => {
      this.callbackServer.once("listening", resolve);
      this.callbackServer.once("error", reject);
    });
    console.log("Opening Microsoft sign-in for the hosted Work IQ service...");
    openBrowser(authorizationUrl.toString());
  }

  waitForAuthorizationCode() {
    if (!this.callbackPromise) {
      throw new Error("Work IQ did not start an authentication callback.");
    }
    return this.callbackPromise;
  }

  invalidateCredentials(scope) {
    if (scope === "all" || scope === "tokens") {
      delete this.authState.tokens;
    }
    if (scope === "all" || scope === "verifier") {
      delete this.authState.codeVerifier;
    }
    writeAuthState(this.authState);
  }

  startCallbackServer() {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.callbackServer?.close();
        reject(new Error("Timed out waiting for Microsoft sign-in."));
      }, 5 * 60 * 1000);

      this.callbackServer = http.createServer((request, response) => {
        const callbackURL = new URL(request.url || "/", this.redirectUrl);
        const code = callbackURL.searchParams.get("code");
        const error = callbackURL.searchParams.get("error");

        if (code) {
          clearTimeout(timeout);
          response.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
          response.end("<h1>Work IQ connected</h1><p>You can close this window.</p>");
          resolve(code);
          setTimeout(() => this.callbackServer?.close(), 500);
          return;
        }

        if (error) {
          clearTimeout(timeout);
          response.writeHead(400, { "Content-Type": "text/plain; charset=utf-8" });
          response.end(`Work IQ sign-in failed: ${error}`);
          reject(new Error(`Work IQ sign-in failed: ${error}`));
          setTimeout(() => this.callbackServer?.close(), 500);
          return;
        }

        response.writeHead(404);
        response.end();
      });
      this.callbackServer.listen(oauthRedirectPort, "localhost");
    });
  }
}

async function connectWorkIQ() {
  const [{ Client }, { StreamableHTTPClientTransport }, { UnauthorizedError }] =
    await Promise.all([
      import("@modelcontextprotocol/sdk/client/index.js"),
      import("@modelcontextprotocol/sdk/client/streamableHttp.js"),
      import("@modelcontextprotocol/sdk/client/auth.js"),
    ]);

  const provider = new WorkIQOAuthProvider();
  const createClientAndTransport = () => {
    const client = new Client({
      name: "outlook-ios-boilerplate-bridge",
      version: "1.0.0",
    });
    const transport = new StreamableHTTPClientTransport(new URL(workIQMcpURL), {
      authProvider: provider,
    });
    return { client, transport };
  };

  let { client, transport } = createClientAndTransport();

  try {
    await client.connect(transport);
  } catch (error) {
    if (!(error instanceof UnauthorizedError)) {
      throw error;
    }
    const authorizationCode = await provider.waitForAuthorizationCode();
    await transport.finishAuth(authorizationCode);
    ({ client, transport } = createClientAndTransport());
    await client.connect(transport);
  }

  mcpClient = client;
  mcpTransport = transport;
  return client;
}

async function getWorkIQClient() {
  if (mcpClient) {
    return mcpClient;
  }
  if (!mcpConnection) {
    mcpConnection = connectWorkIQ().catch((error) => {
      mcpConnection = null;
      throw error;
    });
  }
  return mcpConnection;
}

async function resolveWorkIQToolName(client, logicalName) {
  if (!workIQToolNames) {
    const result = await client.listTools();
    workIQToolNames = new Map(
      result.tools.map((tool) => [tool.name, tool.name])
    );
  }

  if (workIQToolNames.has(logicalName)) {
    return logicalName;
  }
  const suffixMatch = [...workIQToolNames.keys()].find(
    (name) =>
      name.endsWith(`_${logicalName}`) ||
      name.endsWith(`-${logicalName}`) ||
      name.endsWith(`.${logicalName}`)
  );
  if (!suffixMatch) {
    throw new Error(`Hosted Work IQ does not expose the '${logicalName}' tool.`);
  }
  return suffixMatch;
}

function parseMCPResult(result) {
  if (result.isError) {
    const message = (result.content ?? [])
      .filter((item) => item.type === "text")
      .map((item) => item.text)
      .join("\n");
    throw new Error(message || "Work IQ returned an error.");
  }
  if (result.structuredContent) {
    return result.structuredContent;
  }

  const text = (result.content ?? [])
    .filter((item) => item.type === "text")
    .map((item) => item.text)
    .join("\n")
    .trim();
  if (!text) {
    return null;
  }
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

async function callWorkIQTool(name, args, timeout) {
  const client = await getWorkIQClient();
  const toolName = await resolveWorkIQToolName(client, name);
  try {
    const result = await client.callTool(
      { name: toolName, arguments: args },
      undefined,
      { timeout }
    );
    return parseMCPResult(result);
  } catch (error) {
    if (!String(error.message).toLowerCase().includes("unauthorized")) {
      throw error;
    }
    await mcpTransport?.close();
    mcpClient = null;
    mcpTransport = null;
    mcpConnection = null;
    workIQToolNames = null;
    const retryClient = await getWorkIQClient();
    const retryToolName = await resolveWorkIQToolName(retryClient, name);
    const result = await retryClient.callTool(
      { name: retryToolName, arguments: args },
      undefined,
      { timeout }
    );
    return parseMCPResult(result);
  }
}

function findValue(value, keys) {
  if (value == null) {
    return null;
  }
  if (typeof value === "object" && !Array.isArray(value)) {
    for (const key of keys) {
      if (value[key] != null) {
        return value[key];
      }
    }
    for (const nested of Object.values(value)) {
      const found = findValue(nested, keys);
      if (found != null) {
        return found;
      }
    }
  }
  if (Array.isArray(value)) {
    for (const nested of value) {
      const found = findValue(nested, keys);
      if (found != null) {
        return found;
      }
    }
  }
  return null;
}

async function askWorkIQ(question) {
  const result = await callWorkIQTool("ask", { question }, 300000);
  if (typeof result === "string") {
    return result;
  }
  const answer = findValue(result, ["response", "answer", "text"]);
  if (typeof answer !== "string" || !answer.trim()) {
    throw new Error("Work IQ returned an answer the bridge could not parse.");
  }
  return answer;
}

function normalizeMail(
  message,
  meeting = null,
  conversationStats = { total: 1, unread: 0 },
  reactionSummary = { topReactions: [], reactionsCount: 0 }
) {
  const emailAddress = message.from?.emailAddress ?? {};
  const extendedProperties = Array.isArray(message.singleValueExtendedProperties)
    ? message.singleValueExtendedProperties
    : [];
  const lastVerbValue = extendedProperties.find((property) =>
    String(property.id || "").toLowerCase().includes("0x1081")
  )?.value;
  const pinnedValue = extendedProperties.find((property) =>
    String(property.id || "").toLowerCase().includes("0xfffa")
  )?.value;
  const attachments = Array.isArray(message.attachments) ? message.attachments : [];
  return {
    id: message.id ?? "",
    conversationId: message.conversationId ?? "",
    messageType: message["@odata.type"] ?? "",
    senderName: emailAddress.name ?? "",
    senderEmail: emailAddress.address ?? "",
    subject: message.subject ?? "",
    preview: message.bodyPreview ?? "",
    receivedDateTime: message.receivedDateTime ?? "",
    isRead: Boolean(message.isRead),
    recipients: (message.toRecipients ?? [])
      .map((recipient) => recipient.emailAddress?.name || recipient.emailAddress?.address)
      .filter(Boolean),
    hasAttachments: Boolean(message.hasAttachments),
    isFlagged: message.flag?.flagStatus === "flagged",
    importance: message.importance ?? "normal",
    classification: message.inferenceClassification ?? "focused",
    categories: Array.isArray(message.categories) ? message.categories : [],
    conversationCount: conversationStats.total,
    unreadCount: conversationStats.unread,
    topReactions: reactionSummary.topReactions,
    reactionsCount: reactionSummary.reactionsCount,
    lastVerb: lastVerbValue ?? null,
    isPinned: String(pinnedValue || "").toLowerCase() === "true",
    hasLinkAttachment: attachments.some((attachment) =>
      String(attachment["@odata.type"] || "").includes("referenceAttachment")
    ),
    meetingStartDateTime: meeting?.startDateTime?.dateTime ?? meeting?.start?.dateTime ?? null,
    meetingEndDateTime: meeting?.endDateTime?.dateTime ?? meeting?.end?.dateTime ?? null,
    meetingTimeZone: meeting?.startDateTime?.timeZone ?? meeting?.start?.timeZone ?? null,
    meetingLocation: meeting?.location?.displayName ?? null,
    meetingMessageType: meeting?.meetingMessageType ?? null,
    meetingIsAllDay: Boolean(meeting?.isAllDay),
    meetingShowAs: meeting?.showAs ?? null,
    meetingResponse: meeting?.responseStatus?.response ?? null,
    meetingIsCancelled: Boolean(meeting?.isCancelled),
    meetingConflictCount: meeting?.conflictCount ?? 0,
  };
}

function normalizeMessageBody(message) {
  const body = message?.body ?? {};
  return {
    content: body.content ?? "",
    contentType: String(body.contentType || "text").toLowerCase(),
  };
}

function calendarViewPath() {
  const start = new Date();
  start.setDate(start.getDate() - 30);
  const end = new Date();
  end.setDate(end.getDate() + 90);
  return (
    `/me/calendarView?startDateTime=${encodeURIComponent(start.toISOString())}` +
    `&endDateTime=${encodeURIComponent(end.toISOString())}` +
    "&$top=200" +
    "&$select=id,subject,start,end,location,organizer,isCancelled,responseRequested,isAllDay,showAs,responseStatus,type"
  );
}

async function fetchCalendarEvents() {
  let result;
  try {
    result = await callWorkIQTool(
      "fetch",
      { entityUrls: [calendarViewPath()] },
      60000
    );
  } catch (error) {
    throw new Error(`Calendar enrichment failed: ${error.message}`);
  }
  const value = findValue(result, ["value"]);
  return Array.isArray(value) ? value : [];
}

function normalizedSubject(value) {
  return String(value || "")
    .replace(/^(updated invitation|canceled|cancelled|invitation):\s*/i, "")
    .replace(/\s*\[[^\]]+\]\s*$/i, "")
    .trim()
    .toLowerCase();
}

function matchingEvent(message, events) {
  const messageSubject = normalizedSubject(message.subject);
  return events.find((event) => {
    const eventSubject = normalizedSubject(event.subject);
    return (
      eventSubject &&
      (messageSubject === eventSubject ||
        messageSubject.startsWith(`${eventSubject} -`) ||
        eventSubject.startsWith(`${messageSubject} -`) ||
        messageSubject.startsWith(`${eventSubject}:`) ||
        eventSubject.startsWith(`${messageSubject}:`))
    );
  });
}

function eventConflictCount(target, events) {
  const targetStart = Date.parse(target.start?.dateTime);
  const targetEnd = Date.parse(target.end?.dateTime);
  if (!Number.isFinite(targetStart) || !Number.isFinite(targetEnd)) {
    return 0;
  }
  return events.filter((event) => {
    if (
      event.id === target.id ||
      event.isCancelled ||
      event.showAs === "free"
    ) {
      return false;
    }
    const start = Date.parse(event.start?.dateTime);
    const end = Date.parse(event.end?.dateTime);
    return Number.isFinite(start) && Number.isFinite(end) && start < targetEnd && end > targetStart;
  }).length;
}

function runCommand(command, args) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, { stdio: ["ignore", "pipe", "pipe"] });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) {
        resolve(stdout.trim());
      } else {
        reject(new Error(stderr.trim() || `${command} exited with code ${code}.`));
      }
    });
  });
}

async function getGraphAccessToken() {
  const tokenIsFresh = graphAccessToken && Date.now() - graphAccessTokenTime < 45 * 60 * 1000;
  if (tokenIsFresh) {
    return graphAccessToken;
  }
  graphAccessToken = await runCommand("az", [
    "account",
    "get-access-token",
    "--resource-type",
    "ms-graph",
    "--query",
    "accessToken",
    "-o",
    "tsv",
  ]);
  graphAccessTokenTime = Date.now();
  return graphAccessToken;
}

async function fetchProfilePhoto(email) {
  if (photoCache.has(email)) {
    return photoCache.get(email);
  }

  const requestPromise = getGraphAccessToken().then(
    (token) =>
      new Promise((resolve, reject) => {
        const graphRequest = https.get(
          `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(email)}/photo/$value`,
          { headers: { Authorization: `Bearer ${token}` } },
          (graphResponse) => {
            if (graphResponse.statusCode === 404) {
              graphResponse.resume();
              resolve(null);
              return;
            }
            if (graphResponse.statusCode !== 200) {
              graphResponse.resume();
              reject(new Error(`Profile photo request failed with ${graphResponse.statusCode}.`));
              return;
            }

            const chunks = [];
            graphResponse.on("data", (chunk) => chunks.push(chunk));
            graphResponse.on("end", () => {
              resolve({
                data: Buffer.concat(chunks),
                contentType: graphResponse.headers["content-type"] || "image/jpeg",
              });
            });
          }
        );
        graphRequest.on("error", reject);
      })
  );
  photoCache.set(email, requestPromise);
  return requestPromise;
}

async function fetchRecentMail(forceRefresh) {
  const cacheIsFresh = mailCache && Date.now() - mailCacheTime < mailCacheTtlMs;
  if (!forceRefresh && cacheIsFresh) {
    return mailCache;
  }
  if (mailRequest) {
    return mailRequest;
  }

  mailRequest = callWorkIQTool("fetch", { entityUrls: [recentMailPath] }, 60000)
    .catch((error) => {
      throw new Error(`Inbox fetch failed: ${error.message}`);
    })
    .then(async (result) => {
      const value = findValue(result, ["value"]);
      const rawMessages = Array.isArray(value) ? value : [];
      let threadMessages = rawMessages;
      try {
        const threadResult = await callWorkIQTool(
          "fetch",
          { entityUrls: [threadStatsPath] },
          60000
        );
        const threadValue = findValue(threadResult, ["value"]);
        if (Array.isArray(threadValue) && threadValue.length > 0) {
          threadMessages = threadValue;
        }
      } catch {
        // The visible 40-message window remains a safe count fallback.
      }

      const hasMeetingMessages = rawMessages.some((message) =>
        String(message["@odata.type"] || "").includes("eventMessage")
      );
      let events = [];
      if (hasMeetingMessages) {
        events = await fetchCalendarEvents();
      }

      const conversationStats = threadMessages.reduce((stats, message) => {
        const id = message.conversationId;
        if (id) {
          const current = stats.get(id) || { total: 0, unread: 0 };
          current.total += 1;
          if (!message.isRead) {
            current.unread += 1;
          }
          stats.set(id, current);
        }
        return stats;
      }, new Map());

      const messages = rawMessages.map((message) => {
        const graphType = String(message["@odata.type"] || "");
        const event = graphType.includes("eventMessage")
          ? matchingEvent(message, events)
          : null;
        if (event) {
          event.meetingMessageType = graphType.includes("Cancellation")
            ? "meetingCancelled"
            : graphType.includes("Request")
              ? "meetingRequest"
              : null;
          event.conflictCount = eventConflictCount(event, events);
        }
        return normalizeMail(
          message,
          event,
          conversationStats.get(message.conversationId) || { total: 1, unread: message.isRead ? 0 : 1 }
        );
      });
      mailCache = messages;
      mailCacheTime = Date.now();
      return messages;
    })
    .finally(() => {
      mailRequest = null;
    });
  return mailRequest;
}

async function fetchMessageBody(messageId) {
  if (messageBodyCache.has(messageId)) {
    return messageBodyCache.get(messageId);
  }

  const request = callWorkIQTool(
    "fetch",
    {
      entityUrls: [
        `/me/messages/${encodeURIComponent(messageId)}?$select=body`,
      ],
    },
    60000
  )
    .then((result) => {
      const body = findValue(result, ["body"]);
      if (body && typeof body === "object") {
        return normalizeMessageBody({ body });
      }
      const value = findValue(result, ["value"]);
      const message = Array.isArray(value) ? value[0] : value ?? result;
      const normalizedBody = normalizeMessageBody(message);
      if (!normalizedBody.content) {
        throw new Error("Work IQ returned a message without body content.");
      }
      return normalizedBody;
    })
    .catch((error) => {
      messageBodyCache.delete(messageId);
      throw error;
    });
  messageBodyCache.set(messageId, request);
  return request;
}

const server = http.createServer((request, response) => {
  if (request.method === "GET" && request.url === "/health") {
    response.writeHead(200, { "Content-Type": "application/json" });
    response.end(
      JSON.stringify({
        status: "ok",
        upstream: "hosted-workiq-mcp",
        connected: Boolean(mcpClient),
      })
    );
    return;
  }

  if (request.method === "GET" && request.url.startsWith("/emails")) {
    const forceRefresh = request.url.includes("refresh=true");
    fetchRecentMail(forceRefresh)
      .then((messages) => {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            messages,
            cachedAt: new Date(mailCacheTime).toISOString(),
          })
        );
      })
      .catch((error) => {
        response.writeHead(502, { "Content-Type": "application/json" });
        response.end(JSON.stringify({ error: error.message }));
      });
    return;
  }

  if (request.method === "GET" && request.url.startsWith("/messages/")) {
    const requestURL = new URL(request.url, `http://${host}:${port}`);
    const suffix = "/body";
    if (!requestURL.pathname.endsWith(suffix)) {
      response.writeHead(404, { "Content-Type": "application/json" });
      response.end(JSON.stringify({ error: "Not found." }));
      return;
    }
    const encodedID = requestURL.pathname.slice(
      "/messages/".length,
      -suffix.length
    );
    const messageId = decodeURIComponent(encodedID);
    if (!messageId) {
      response.writeHead(400, { "Content-Type": "application/json" });
      response.end(JSON.stringify({ error: "A message ID is required." }));
      return;
    }

    fetchMessageBody(messageId)
      .then((body) => {
        response.writeHead(200, {
          "Content-Type": "application/json",
          "Cache-Control": "private, max-age=300",
        });
        response.end(JSON.stringify(body));
      })
      .catch((error) => {
        response.writeHead(502, { "Content-Type": "application/json" });
        response.end(JSON.stringify({ error: error.message }));
      });
    return;
  }

  if (request.method === "GET" && request.url.startsWith("/photos/")) {
    const email = decodeURIComponent(request.url.slice("/photos/".length)).trim().toLowerCase();
    if (!email) {
      response.writeHead(400);
      response.end();
      return;
    }

    fetchProfilePhoto(email)
      .then((photo) => {
        if (!photo) {
          response.writeHead(404);
          response.end();
          return;
        }
        response.writeHead(200, {
          "Content-Type": photo.contentType,
          "Cache-Control": "public, max-age=86400",
        });
        response.end(photo.data);
      })
      .catch((error) => {
        photoCache.delete(email);
        response.writeHead(502, { "Content-Type": "application/json" });
        response.end(JSON.stringify({ error: error.message }));
      });
    return;
  }

  if (request.method !== "POST" || request.url !== "/ask") {
    response.writeHead(404, { "Content-Type": "application/json" });
    response.end(JSON.stringify({ error: "Not found." }));
    return;
  }

  let body = "";
  request.on("data", (chunk) => {
    body += chunk;
    if (Buffer.byteLength(body) > maxBodyBytes) {
      request.destroy();
    }
  });
  request.on("end", async () => {
    try {
      const payload = JSON.parse(body);
      const question = String(payload.question || "").trim();
      if (!question) {
        response.writeHead(400, { "Content-Type": "application/json" });
        response.end(JSON.stringify({ error: "A question is required." }));
        return;
      }

      const answer = await askWorkIQ(question);
      response.writeHead(200, { "Content-Type": "application/json" });
      response.end(JSON.stringify({ response: answer }));
    } catch (error) {
      response.writeHead(502, { "Content-Type": "application/json" });
      response.end(JSON.stringify({ error: error.message }));
    }
  });
});

server.listen(port, host, () => {
  console.log(`Work IQ bridge listening at http://${host}:${port}`);
  console.log(`Upstream: ${workIQMcpURL}`);
});
