import Foundation
import OutlookBackdrop
import SwiftUI
import UIKit

enum WorkIQResponseState: Equatable {
    case idle
    case loading
    case answer(String)
    case failure(String)
}

struct WorkIQClient {
    private let bridgeURL = URL(string: "http://127.0.0.1:8765")!
    private let cacheURL: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return caches.appendingPathComponent("workiq-inbox.json")
    }()

    func ask(_ question: String) async throws -> String {
        var request = URLRequest(url: bridgeURL.appendingPathComponent("ask"))
        request.httpMethod = "POST"
        request.timeoutInterval = 320
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(WorkIQRequest(question: question))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WorkIQClientError.invalidResponse
        }

        let payload = try JSONDecoder().decode(WorkIQResponse.self, from: data)
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WorkIQClientError.bridge(payload.error ?? "Work IQ request failed.")
        }
        guard let answer = payload.response, !answer.isEmpty else {
            throw WorkIQClientError.invalidResponse
        }
        return answer
    }

    func cachedInbox() -> [InboxThread] {
        guard
            let data = try? Data(contentsOf: cacheURL),
            let payload = try? JSONDecoder().decode(WorkIQMailCache.self, from: data)
        else {
            return []
        }
        return payload.messages.map(\.inboxThread)
    }

    func recentInbox(forceRefresh: Bool = false) async throws -> [InboxThread] {
        var components = URLComponents(
            url: bridgeURL.appendingPathComponent("emails"),
            resolvingAgainstBaseURL: false
        )!
        if forceRefresh {
            components.queryItems = [URLQueryItem(name: "refresh", value: "true")]
        }

        var request = URLRequest(url: components.url!)
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)
        try Task.checkCancellation()
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WorkIQClientError.invalidResponse
        }

        let payload = try JSONDecoder().decode(WorkIQMailResponse.self, from: data)
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WorkIQClientError.bridge(payload.error ?? "Work IQ mail request failed.")
        }

        let messages = payload.messages ?? []
        let cache = WorkIQMailCache(savedAt: Date(), messages: messages)
        if let cacheData = try? JSONEncoder().encode(cache) {
            try? cacheData.write(to: cacheURL, options: .atomic)
        }
        return messages.map(\.inboxThread)
    }

    func messageBody(id: String) async throws -> WorkIQMessageBody {
        let encodedID = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
        var request = URLRequest(
            url: bridgeURL
                .appendingPathComponent("messages")
                .appendingPathComponent(encodedID)
                .appendingPathComponent("body")
        )
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)
        try Task.checkCancellation()
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WorkIQClientError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let payload = try? JSONDecoder().decode(WorkIQResponse.self, from: data)
            throw WorkIQClientError.bridge(payload?.error ?? "Work IQ message request failed.")
        }
        return try JSONDecoder().decode(WorkIQMessageBody.self, from: data)
    }
}

struct WorkIQMessageBody: Decodable {
    let content: String
    let contentType: String

    var isHTML: Bool {
        contentType.caseInsensitiveCompare("html") == .orderedSame
    }

    var displayText: String {
        guard
            isHTML,
            let data = content.data(using: .utf8),
            let attributed = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil
            )
        else {
            return content
        }
        return attributed.string
    }
}

private struct WorkIQRequest: Encodable {
    let question: String
}

private struct WorkIQResponse: Decodable {
    let response: String?
    let error: String?
}

private struct WorkIQMailResponse: Decodable {
    let messages: [WorkIQMailMessage]?
    let error: String?
}

private struct WorkIQMailCache: Codable {
    let savedAt: Date
    let messages: [WorkIQMailMessage]
}

private struct WorkIQMailMessage: Codable {
    let id: String
    let senderName: String
    let senderEmail: String
    let subject: String
    let preview: String
    let receivedDateTime: String
    let isRead: Bool
    let recipients: [String]
    let hasAttachments: Bool
    let isFlagged: Bool
    let importance: String
    let classification: String

    var inboxThread: InboxThread {
        let receivedDate = Self.parseDate(receivedDateTime)
        let photoURL = senderEmail.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            .flatMap { URL(string: "http://127.0.0.1:8765/photos/\($0)") }
        return InboxThread(
            id: id.isEmpty ? UUID().uuidString : id,
            section: Self.section(for: receivedDate),
            sender: senderName.isEmpty ? senderEmail : senderName,
            recipients: Self.recipientSummary(recipients),
            subject: subject.isEmpty ? "(No subject)" : subject,
            preview: preview,
            body: preview,
            timeStamp: Self.timestamp(for: receivedDate),
            isUnread: !isRead,
            isExternalSender: !senderEmail.lowercased().hasSuffix("@microsoft.com"),
            hasAttachment: hasAttachments,
            isFlagged: isFlagged,
            profilePhotoURL: photoURL
        )
    }

    private static func recipientSummary(_ recipients: [String]) -> String {
        guard let first = recipients.first else { return "To you" }
        return recipients.count == 1 ? "To \(first)" : "To \(first), +\(recipients.count - 1)"
    }

    private static func parseDate(_ value: String) -> Date? {
        let formats = [
            "yyyy-MM-dd hh:mm a",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        ]
        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return date
            }
        }
        return nil
    }

    private static func section(for date: Date?) -> InboxSection {
        guard let date else { return .thisWeek }
        if Calendar.current.isDateInToday(date) { return .today }
        if Calendar.current.isDateInYesterday(date) { return .yesterday }
        return .thisWeek
    }

    private static func timestamp(for date: Date?) -> String {
        guard let date else { return "" }
        if Calendar.current.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        return date.formatted(.dateTime.weekday(.abbreviated))
    }
}

private enum WorkIQClientError: LocalizedError {
    case bridge(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .bridge(let message):
            return message
        case .invalidResponse:
            return "The Work IQ bridge returned an invalid response."
        }
    }
}

struct WorkIQResponseView: View {
    let state: WorkIQResponseState

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case .loading:
            HStack(spacing: .odsSpacingHorizontalS) {
                ProgressView()
                Text("Checking your Microsoft 365 context...")
                    .font(.odsBody2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.odsSpacingHorizontalL)
            .background(responseBackground)
        case .answer(let answer):
            ScrollView {
                Text(answer)
                    .font(.odsBody2)
                    .foregroundStyle(Color.odsNeutralForeground1)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 180)
            .padding(.odsSpacingHorizontalL)
            .background(responseBackground)
        case .failure(let message):
            Text(message)
                .font(.odsBody2)
                .foregroundStyle(Color.odsStatusDangerForeground1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.odsSpacingHorizontalL)
                .background(responseBackground)
        }
    }

    private var responseBackground: some View {
        RoundedRectangle(cornerRadius: .odsSize120)
            .fill(Color.odsNeutralBackground3)
    }
}
