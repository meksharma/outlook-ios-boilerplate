//
//  SampleThreads.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/SnippetCell/SnippetCellModel.swift
//      (the production protocol an inbox-row backing model conforms to)
//

import Foundation

struct InboxThread: Identifiable {
    let id = UUID()

    /// Sender display name. Maps to `SnippetCellModel.from`.
    let sender: String

    /// Subject line. Maps to `SnippetCellModel.subject`.
    let subject: String

    /// Preview text (the first line or two of the message body). Maps to `SnippetCellModel.body`.
    let preview: String

    /// Pre-formatted display string for timestamp (e.g. "10:42 AM", "Yesterday", "Mon").
    /// Production uses `Date` and formats at render-time; for the boilerplate we pre-format
    /// to keep fixtures simple.
    let timeStamp: String

    /// Whether the thread is unread. Maps to the inverse of `SnippetCellModel.read`.
    let isUnread: Bool

    /// Whether the sender is external to the user's tenant. Maps to `SnippetCellModel.isExternalSender`.
    /// Drives the "External" pill in the row (will be rendered in a future cell-variant milestone).
    let isExternalSender: Bool

    /// Whether the thread has any attachment. Maps to `SnippetCellModel.hasAttachment`.
    let hasAttachment: Bool

    /// Whether the user flagged the thread. Maps to `SnippetCellModel.flagged`.
    let isFlagged: Bool
}

let sampleThreads: [InboxThread] = [
    InboxThread(
        sender: "Sarah Chen",
        subject: "Q2 design review prep",
        preview: "Hi team, ahead of our review on Friday I wanted to share the working deck and call out the open questions on the navigation refactor.",
        timeStamp: "10:42 AM",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: true,
        isFlagged: false
    ),
    InboxThread(
        sender: "Marcus Rivera",
        subject: "Project Greenlight: kickoff materials",
        preview: "I've shared the kickoff deck and the scoping doc in our shared drive. Skim before Thursday and bring questions.",
        timeStamp: "9:18 AM",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: true,
        isFlagged: false
    ),
    InboxThread(
        sender: "Microsoft Learn",
        subject: "Your weekly digest is ready",
        preview: "New AI-focused content this week, including hands-on labs for Copilot agents and tutorials on prompt design.",
        timeStamp: "8:04 AM",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Jordan Patel",
        subject: "Re: design tokens proposal",
        preview: "Saw your draft — a few thoughts on the naming for surface tokens. Worth a 15-min sync if you have time today.",
        timeStamp: "Yesterday",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Emily Watson",
        subject: "User research findings — round 2",
        preview: "Round 2 results are in. Headline: the empty-state copy testing didn't move the needle. Detailed report attached.",
        timeStamp: "Yesterday",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: true,
        isFlagged: true
    ),
    InboxThread(
        sender: "Devon Brooks",
        subject: "Sprint planning moves to Tuesday",
        preview: "Heads up — pushing sprint planning to Tuesday 10 AM so we have estimates from the platform team. New invite incoming.",
        timeStamp: "Yesterday",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "PMCon 2026",
        subject: "Session recordings now live",
        preview: "Thank you for joining us at PMCon 2026. All session recordings and slides are now available on the conference portal.",
        timeStamp: "Mon",
        isUnread: false,
        isExternalSender: true,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Microsoft IT",
        subject: "Action required: device security update",
        preview: "Please complete the device security assessment by end of week. The portal link and steps are inside.",
        timeStamp: "Mon",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Riley Foster",
        subject: "Re: prototype feedback",
        preview: "Loved the new flow. One note on the empty state — the illustration competes with the CTA. Want me to mock an alternative?",
        timeStamp: "Sun",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Olivia Martinez",
        subject: "Welcome to the team!",
        preview: "Excited to have you joining the design org next month. I've set up a few intro chats for your first week.",
        timeStamp: "Sun",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
]
