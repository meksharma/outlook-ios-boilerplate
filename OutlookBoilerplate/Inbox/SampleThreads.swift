//
//  SampleThreads.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/SnippetCell/SnippetCellModel.swift
//      (the production protocol an inbox-row backing model conforms to)
//

import Foundation

struct InboxThread: Identifiable, Hashable {
    let id = UUID()

    /// Sender display name. Maps to `SnippetCellModel.from`.
    let sender: String

    /// Recipients line displayed in the reading pane (e.g. "To you, +2"). Production renders
    /// this via `MessageRecipientsView` from `SnippetCellModel`'s recipients data.
    let recipients: String

    /// Subject line. Maps to `SnippetCellModel.subject`.
    let subject: String

    /// Preview text (the first line or two of the message body). Maps to `SnippetCellModel.body`
    /// truncated for the row. Production truncates the same `body` string for inbox row preview.
    let preview: String

    /// Full body content rendered in the reading pane. Production renders this via
    /// `MessageContentView` (a WKWebView for HTML); for the boilerplate we use plain text
    /// with paragraph breaks, since we have no real mail backend.
    let body: String

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
        recipients: "To you, +6",
        subject: "Q2 design review prep",
        preview: "Hi team, ahead of our review on Friday I wanted to share the working deck and call out the open questions on the navigation refactor.",
        body: """
        Hi team,

        Ahead of our review on Friday I wanted to share the working deck and call out the open questions on the navigation refactor.

        The biggest one is whether we collapse the secondary nav into a tab bar on small screens, or keep it as a sticky drawer. I've prototyped both — happy to walk through tradeoffs at the meeting.

        Action items before Friday:
          • PM: align on the priority of the personalization moments
          • Eng: confirm the animation budget for the drawer
          • Design: lock the icon set for the new section headers

        Let me know if you have questions ahead of time.

        Sarah
        """,
        timeStamp: "10:42 AM",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: true,
        isFlagged: false
    ),
    InboxThread(
        sender: "Marcus Rivera",
        recipients: "To you",
        subject: "Project Greenlight: kickoff materials",
        preview: "I've shared the kickoff deck and the scoping doc in our shared drive. Skim before Thursday and bring questions.",
        body: """
        Hey,

        I've shared the kickoff deck and the scoping doc in our shared drive. Skim before Thursday and bring questions — I'd rather burn the first 15 minutes on Q&A than read slides at people.

        We have an ambitious timeline. Three things will determine whether we hit it:
          1. Speed of feedback cycles in the first sprint
          2. Whether we get a dedicated PM by week 2
          3. Whether the platform team can carve out a small spike for us

        Let's talk Thursday.

        Marcus
        """,
        timeStamp: "9:18 AM",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: true,
        isFlagged: false
    ),
    InboxThread(
        sender: "Microsoft Learn",
        recipients: "To you",
        subject: "Your weekly digest is ready",
        preview: "New AI-focused content this week, including hands-on labs for Copilot agents and tutorials on prompt design.",
        body: """
        Hi designer,

        Your weekly digest is ready. This week's highlights:

        • Hands-on lab — Build your first Copilot agent
        • Tutorial — Designing for AI: prompt-as-interface patterns
        • Live event — AI for Designers (Thursday, 11 AM PT)

        Pick one to start. Most labs take 20–30 minutes.

        — The Microsoft Learn team
        """,
        timeStamp: "8:04 AM",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Jordan Patel",
        recipients: "To you, Sarah Chen",
        subject: "Re: design tokens proposal",
        preview: "Saw your draft — a few thoughts on the naming for surface tokens. Worth a 15-min sync if you have time today.",
        body: """
        Saw your draft — a few thoughts on the naming for surface tokens.

        I'd push back on `surface.muted`. "Muted" reads as a state (selected → muted) rather than a level (1, 2, 3). My suggestion: `surface.tertiary` keeps the alias system consistent with how foreground tokens are named.

        Also, the alias for the brand-tinted background needs more contrast vs. `surface.primary` in dark mode. Right now they look identical.

        Worth a 15-min sync if you have time today?

        Jordan
        """,
        timeStamp: "Yesterday",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Emily Watson",
        recipients: "To you, +3",
        subject: "User research findings — round 2",
        preview: "Round 2 results are in. Headline: the empty-state copy testing didn't move the needle. Detailed report attached.",
        body: """
        Hi all,

        Round 2 results are in. Headline: the empty-state copy testing didn't move the needle.

        Top-line numbers:
          • Variant A (status quo): 12% completion
          • Variant B (action-oriented): 13% (within margin of error)
          • Variant C (illustration + headline): 11%

        Real takeaway: the empty state isn't the bottleneck. Users who land on it never had clear intent to begin with. We should be looking upstream at the entry points.

        Detailed report attached. Happy to walk through it next week.

        Emily
        """,
        timeStamp: "Yesterday",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: true,
        isFlagged: true
    ),
    InboxThread(
        sender: "Devon Brooks",
        recipients: "To you, the team",
        subject: "Sprint planning moves to Tuesday",
        preview: "Heads up — pushing sprint planning to Tuesday 10 AM so we have estimates from the platform team. New invite incoming.",
        body: """
        Heads up — pushing sprint planning to Tuesday 10 AM so we have estimates from the platform team. New invite incoming.

        Same agenda as usual:
          • Carry-over from last sprint
          • New work for next sprint
          • Capacity check
          • Risks and dependencies

        See you Tuesday.

        Devon
        """,
        timeStamp: "Yesterday",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "PMCon 2026",
        recipients: "To you",
        subject: "Session recordings now live",
        preview: "Thank you for joining us at PMCon 2026. All session recordings and slides are now available on the conference portal.",
        body: """
        Thank you for joining us at PMCon 2026.

        All session recordings and slides are now available on the conference portal. The most popular sessions:
          • Building product orgs that ship — Day 1 keynote
          • Product/design partnership at scale
          • The future of AI-native PM tooling

        Sign in to the portal with the same email you registered with. Recordings remain available for 90 days.

        See you at PMCon 2027 — early-bird tickets open in October.

        — The PMCon team
        """,
        timeStamp: "Mon",
        isUnread: false,
        isExternalSender: true,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Microsoft IT",
        recipients: "To you",
        subject: "Action required: device security update",
        preview: "Please complete the device security assessment by end of week. The portal link and steps are inside.",
        body: """
        Hi,

        Please complete the device security assessment by end of week. This is an annual compliance check — should take about 5 minutes.

        Steps:
          1. Open the security portal: aka.ms/security-check
          2. Sign in with your work account
          3. Run the assessment on each managed device
          4. Resolve any flagged items, or open a ticket if you can't

        Devices that don't complete the assessment by end of next week will lose access to corporate resources.

        Thanks for staying secure.

        Microsoft IT
        """,
        timeStamp: "Mon",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Riley Foster",
        recipients: "To you",
        subject: "Re: prototype feedback",
        preview: "Loved the new flow. One note on the empty state — the illustration competes with the CTA. Want me to mock an alternative?",
        body: """
        Loved the new flow.

        One note on the empty state — the illustration competes with the CTA visually. The eye lands on the illustration first, then has to hunt for the button. Could go simpler.

        Want me to mock an alternative? Could try:
          • Smaller illustration, button up top
          • No illustration, just headline + button
          • Same layout but illustration in muted color

        Should be quick.

        Riley
        """,
        timeStamp: "Sun",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
    InboxThread(
        sender: "Olivia Martinez",
        recipients: "To you",
        subject: "Welcome to the team!",
        preview: "Excited to have you joining the design org next month. I've set up a few intro chats for your first week.",
        body: """
        Hi,

        Excited to have you joining the design org next month. I've set up a few intro chats for your first week — calendar invites are coming separately.

        Day 1: Coffee with me (orientation + Q&A)
        Day 2: Tour of the design system + meet the DS team
        Day 3: Shadow a research session
        Day 5: Lunch with the broader design org

        If any of those slots don't work, just bump them. Welcome to the team.

        Olivia
        """,
        timeStamp: "Sun",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false
    ),
]
