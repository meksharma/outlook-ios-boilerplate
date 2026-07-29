# Outlook iOS Boilerplate

A pre-loaded Xcode project that gives Outlook iOS designers the production backdrop — real FluentUI components, real Outlook tokens — so you can vibe-code prototypes on top without re-creating Outlook from scratch.

If you're new to the repo, the only thing you need to know to get started is below.

---

## What you get out of the box

- A working iOS app that looks like Outlook
- Five working surfaces wired up: Inbox, Reading pane, Side drawer, New mail compose, Copilot sheet
- Real Outlook brand colors and typography (FluentUI Apple `0.35.0` — the same version production Outlook iOS pins via its Podfile)
- Real Outlook icon assets (Compose, Copilot, Mic) vendored from the production repo

You don't need to know Swift to use this. You prompt Claude (or Cursor, or any AI-aware editor) and it edits the files.

---

## Quick start

### 1. Clone

```bash
cd ~/Github
git clone <repo-url> Outlook-iOS-Boilerplate
cd Outlook-iOS-Boilerplate
```

### 2. Branch

You always work on your own branch. **Never push to `main`** — that's the canonical backdrop, owned by the DSAI team.

```bash
git checkout -b yourname/what-youre-prototyping
```

### 3. Open in Xcode

```bash
open OutlookBoilerplate.xcodeproj
```

Or just double-click `OutlookBoilerplate.xcodeproj` in Finder.

### 4. Run

Hit **⌘R**. The iOS Simulator opens with a working Outlook-shaped app — Inbox at home, taps work, drawer slides, Copilot sheet rises with the keyboard.

> **Simulator quirk to know:** if the soft keyboard doesn't appear when you tap a text field, the simulator has a hardware-keyboard mode that's hiding it. Fix: in the simulator menu bar, **I/O → Keyboard → uncheck "Connect Hardware Keyboard"** (or press **⌘⇧K**). On real iPhones this isn't an issue.

### Optional: connect Copilot to Work IQ

The Work IQ prototype path is off by default and currently supports the iOS Simulator only. A small local adapter connects the app to Microsoft's hosted Work IQ MCP service. Authentication tokens stay in `~/.outlook-ios-boilerplate/`, outside the repo.

```bash
cd Tools
npm install
npm start
```

The first run opens Microsoft sign-in in your browser. Keep the bridge terminal running. In the app, open **Designer Tools** and turn on **Work IQ**. The Inbox loads your recent messages and Copilot submits prompts against your Microsoft 365 context. Turning Work IQ off restores the fixture inbox and inert Copilot behavior.

The bridge maintains one connection to the hosted MCP service instead of launching `npx @microsoft/workiq` for every request. The Inbox uses Work IQ's structured mail retrieval rather than an AI-generated response. Forty messages are cached in the app and for five minutes in the bridge, so subsequent launches render the previous result immediately and refresh in the background.

Live rows include sender, recipients, read state, attachment state, follow-up flags, importance, and Focused/Other classification. Sender photos load lazily through Microsoft Graph using the same local Azure CLI session and fall back to initials when no organizational photo exists.

---

## Vibe-code a prototype

Open the project in Claude Code, Cursor, or any AI-aware editor. Then prompt naturally — Claude reads the project structure and figures out where to put the change.

Examples:

- *"Add a new thread cell variant for calendar invites with an RSVP button"*
- *"Make the Inbox rows show a small attachment icon when `hasAttachment` is true"*
- *"Replace the reading-pane action bar with a single 'Reply' button"*
- *"Add a banner at the top of the Inbox that says 'You're on a public network'"*

You don't have to point Claude at specific files — the structure (see below) is named so Claude can locate the right place from intent.

---

## Run on your iPhone

1. Plug your iPhone into your Mac, or pair wirelessly via **Window → Devices and Simulators** in Xcode.
2. In Xcode, click the run-target picker at the top (defaults to "iPhone 17 Pro" simulator) and switch to your real device.
3. Hit **⌘R**.

First-time setup: in **Xcode → Settings → Accounts**, add your Apple ID (free is fine — you don't need the paid $99/yr Developer program just to install on your own iPhone). On your iPhone, you'll get prompted to trust the developer certificate the first time: **Settings → General → VPN & Device Management → trust**.

The build stays on your phone for ~7 days before it needs a re-build.

---

## Share with teammates

Push your branch:

```bash
git push -u origin yourname/what-youre-prototyping
```

Teammates clone the repo and `git checkout` your branch.

**Do not open a pull request to `main`.** Main is the canonical backdrop — owned and maintained by the DSAI team. Your branch lives forever as a prototype reference. If something on main is broken, ping DSAI.

---

## File structure (in case Claude needs a hint, or you want to read the code)

```
OutlookBoilerplate/
├── OutlookBoilerplateApp.swift           # App entrypoint; calls OutlookBackdrop
├── ContentView.swift                     # Root: TabView + overlays (drawer, Copilot)
│
├── Inbox/
│   ├── InboxView.swift                   # The Inbox screen
│   ├── InboxHeader.swift                 # Blue top bar (avatar, search, Focused/Other, Filter)
│   ├── InboxRow.swift                    # A single thread row
│   ├── InboxFloatingActions.swift        # Compose + Copilot floating buttons
│   └── SampleThreads.swift               # 10 fake email threads (the data)
│
├── Reading/
│   ├── ReadingPaneView.swift             # Email reading screen
│   └── ReadingPaneActionBar.swift        # Bottom action bar (Reply All, etc.)
│
├── Copilot/
│   └── CopilotSheetOverlay.swift         # Custom bottom sheet for Copilot chat
│
├── Compose/
│   ├── ComposeView.swift                 # New mail compose (full-screen modal)
│   └── ComposeToolbar.swift              # Bottom toolbar inside compose
│
├── Drawer/
│   └── SideDrawerView.swift              # Folder pane (slides in from leading edge)
│
├── OutlookBackdrop/                      # Local Swift Package
│   ├── Package.swift
│   └── Sources/OutlookBackdrop/
│       └── OutlookBackdrop.swift         # FluentUI theme registration entrypoint
│
└── Assets.xcassets/
    └── OutlookIcons/                     # Real Outlook icons vendored from production
        ├── ComposeIcon.imageset
        ├── CopilotIcon.imageset
        └── MicIcon.imageset
```

---

## What's real vs visual-only

**Real (production-faithful):**

- FluentUI Apple components (`Avatar`, `ListItem`, `FluentList`, etc.)
- Outlook brand colors (`comm10`–`comm160`) — the same palette production Outlook iOS uses
- Outlook icon assets — Compose pencil, Copilot ribbon, mic — vendored from the Outlook iOS production repo
- Tap-through navigation (Inbox → reading pane → back), sheet-rise animations, tab switching

**Visual-only (no real backend):**

- Send / Reply / Trash buttons → they look right, do nothing
- Copilot chips, "Help me write", "Ask Copilot" submit → no real LLM calls
- Side-drawer folder rows → tap does nothing
- Tab bar Calendar / Apps tabs → placeholder content
- All notifications, badges, RSVP, etc.

This is intentional — Phase 1 is the backdrop; you provide the prototype interactions on top.

---

## Common changes you might want

**Add a new fake email thread:** Edit `OutlookBoilerplate/Inbox/SampleThreads.swift` and add a new `InboxThread(...)` entry to the `sampleThreads` array.

**Change the Outlook brand color:** Don't, in a prototype branch — it's wired through FluentUI's `commXX` tokens which match production. If you really need a different brand, modify `OutlookBackdrop/Sources/OutlookBackdrop/OutlookBackdrop.swift` and call `FluentTheme.shared` overrides.

**Add a new screen:** Just create a new `.swift` file in a new folder (e.g. `OutlookBoilerplate/Settings/SettingsView.swift`). Xcode picks up new files automatically — the project uses synchronized folders.

**Hook a button up:** All the visual-only buttons take a tap closure. Tell Claude what should happen on tap and it'll wire it.

---

## Phase 2 (later): Code Connect

Phase 2 will add Figma Code Connect mappings so designers in Figma's dev mode see real Swift code, and so AI tools can pull from the real components instead of generating from scratch. Not in this version of the boilerplate — track the DSAI work for that.

---

## Issues and questions

- **Something broken on `main`** → ping the DSAI team
- **Your prototype branch broke** → fix it locally, or git-reset to a working commit
- **Not sure where to put a change** → just describe what you want to Claude; the structure is named for agent discoverability

Phase 1 is intentionally lean. The boilerplate is a starting point, not a feature-complete app.
