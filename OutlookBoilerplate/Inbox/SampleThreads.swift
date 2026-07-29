//
//  SampleThreads.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/SnippetCell/SnippetCellModel.swift
//      (the production protocol an inbox-row backing model conforms to)
//

import Foundation
import OutlookBackdrop

enum InboxSection: String, CaseIterable, Hashable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
}

struct InboxThread: Identifiable, Hashable {
    let id: String

    /// Which date-grouping section the thread sits in. Mirrors production's
    /// `MessageListSectionHeaderInfo.title` derivation from message date.
    let section: InboxSection

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

    /// Whether the user pinned the thread. Maps to `SnippetCellModel.pinned`.
    /// Defaults to false so live Work IQ messages do not need synthetic state.
    var isPinned: Bool = false
    var profilePhotoURL: URL? = nil
    var attachments: [MessageAttachment] = []
    var meeting: MeetingScenario? = nil
    var txp: TxpScenario? = nil
    var isImportant: Bool = false
    var categories: [String] = []
    var conversationCount: Int = 1

    /// Optional persona avatar. When set, the row renders the persona's photo;
    /// when nil (e.g. organizational senders like "Microsoft Learn"), the row
    /// falls back to a neutral initials avatar.
    var persona: Persona? = nil

    init(
        id: String = UUID().uuidString,
        section: InboxSection,
        sender: String,
        recipients: String,
        subject: String,
        preview: String,
        body: String,
        timeStamp: String,
        isUnread: Bool,
        isExternalSender: Bool,
        hasAttachment: Bool,
        isFlagged: Bool,
        isPinned: Bool = false,
        profilePhotoURL: URL? = nil,
        attachments: [MessageAttachment] = [],
        meeting: MeetingScenario? = nil,
        txp: TxpScenario? = nil,
        isImportant: Bool = false,
        categories: [String] = [],
        conversationCount: Int = 1,
        persona: Persona? = nil
    ) {
        self.id = id
        self.section = section
        self.sender = sender
        self.recipients = recipients
        self.subject = subject
        self.preview = preview
        self.body = body
        self.timeStamp = timeStamp
        self.isUnread = isUnread
        self.isExternalSender = isExternalSender
        self.hasAttachment = hasAttachment || !attachments.isEmpty
        self.isFlagged = isFlagged
        self.isPinned = isPinned
        self.profilePhotoURL = profilePhotoURL
        self.attachments = attachments
        self.meeting = meeting
        self.txp = txp
        self.isImportant = isImportant
        self.categories = categories
        self.conversationCount = conversationCount
        self.persona = persona
    }
}

let sampleThreads: [InboxThread] = [
    InboxThread(
        section: .today,
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
        isFlagged: false,
        attachments: [
            MessageAttachment(name: "Q2 Design Review.pdf", detail: "PDF · 4.8 MB"),
            MessageAttachment(name: "Navigation concepts.png", detail: "PNG · 2.1 MB", kind: .image),
            MessageAttachment(name: "Review deck.pptx", detail: "PPTX · 12.4 MB"),
        ],
        persona: .sarahPerez
    ),
    InboxThread(
        section: .today,
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
        isFlagged: false,
        attachments: [
            MessageAttachment(name: "Project Greenlight", detail: "Shared Excel workbook", kind: .cloudLink),
            MessageAttachment(name: "Kickoff scope.docx", detail: "DOCX · 680 KB"),
        ],
        persona: .mauricioAugust
    ),
    InboxThread(
        section: .today,
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
        section: .yesterday,
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
        isFlagged: false,
        persona: .aadiKapoor
    ),
    InboxThread(
        section: .yesterday,
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
        isFlagged: true,
        attachments: [
            MessageAttachment(name: "Round 2 research findings.pdf", detail: "PDF · 7.2 MB"),
        ],
        persona: .erikaFuller
    ),
    InboxThread(
        section: .yesterday,
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
        isFlagged: false,
        meeting: MeetingScenario(
            kind: .updated,
            title: "Sprint planning",
            dateLine: "Tuesday, July 29 · 10:00–11:00 AM",
            location: "Teams meeting",
            organizer: "Devon Brooks",
            detail: "The meeting moved from Monday to Tuesday.",
            response: .accepted,
            previousDetail: "Previously Monday, July 28 · 10:00 AM"
        ),
        persona: .andreLawson
    ),
    InboxThread(
        section: .thisWeek,
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
        section: .thisWeek,
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
        section: .thisWeek,
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
        isFlagged: false,
        isPinned: true,
        persona: .robinCounts
    ),
    InboxThread(
        section: .thisWeek,
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
        isFlagged: false,
        meeting: MeetingScenario(
            kind: .invitation,
            title: "Welcome coffee",
            dateLine: "Monday, August 3 · 9:30–10:00 AM",
            location: "Building 92 Café",
            organizer: "Olivia Martinez",
            detail: "A quick orientation and Q&A before the rest of your first-day meetings."
        ),
        persona: .monaKane
    ),
    InboxThread(
        section: .today,
        sender: "Priya Shah",
        recipients: "To you, +4",
        subject: "Cancelled: Research review",
        preview: "This meeting has been cancelled. Remove it from your calendar if it still appears.",
        body: "The research review is cancelled while we recruit a replacement participant panel.",
        timeStamp: "7:42 AM",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: true,
        isPinned: true,
        meeting: MeetingScenario(
            kind: .cancelled,
            title: "Research review",
            dateLine: "Wednesday, July 30 · 2:00–3:00 PM",
            location: "Studio C",
            organizer: "Priya Shah",
            detail: "Cancelled by the organizer."
        )
    ),
    InboxThread(
        section: .yesterday,
        sender: "Alex Morgan",
        recipients: "To you",
        subject: "New time proposed: Launch review",
        preview: "Alex proposed Thursday at 3:30 PM for the launch review.",
        body: "The original slot conflicts with the engineering readiness review. Please review the proposed time.",
        timeStamp: "Yesterday",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false,
        meeting: MeetingScenario(
            kind: .proposedTime,
            title: "Launch review",
            dateLine: "Proposed: Thursday, July 31 · 3:30–4:30 PM",
            location: "Teams meeting",
            organizer: "Alex Morgan",
            detail: "Review the proposed time before responding.",
            previousDetail: "Original: Thursday, July 31 · 1:00–2:00 PM"
        )
    ),
    InboxThread(
        section: .yesterday,
        sender: "Maya Thompson",
        recipients: "To you, Design Leadership",
        subject: "Portfolio review",
        preview: "You have another event during this meeting.",
        body: "We will review the Q3 portfolio, staffing risks, and the projects that need leadership decisions.",
        timeStamp: "Yesterday",
        isUnread: true,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false,
        meeting: MeetingScenario(
            kind: .conflict,
            title: "Portfolio review",
            dateLine: "Friday, August 1 · 11:00 AM–12:00 PM",
            location: "Conference room 4/2210",
            organizer: "Maya Thompson",
            detail: "Conflicts with Product Council."
        )
    ),
    InboxThread(
        section: .thisWeek,
        sender: "Leadership Operations",
        recipients: "To you",
        subject: "Weekly leadership staff",
        preview: "This recurring series has been added to your calendar.",
        body: "Weekly leadership staff covers business health, people topics, and cross-team decisions.",
        timeStamp: "Sat",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false,
        isPinned: true,
        meeting: MeetingScenario(
            kind: .recurring,
            title: "Leadership staff",
            dateLine: "Every Monday · 9:00–10:00 AM",
            location: "Teams meeting",
            organizer: "Leadership Operations",
            detail: "Occurs weekly until December 14.",
            response: .accepted
        )
    ),
    InboxThread(
        section: .thisWeek,
        sender: "Recruiting",
        recipients: "To you",
        subject: "Interview loop for Sam Lee",
        preview: "You received this invitation for Jordan Patel.",
        body: "Please cover the product thinking interview and send feedback before the debrief.",
        timeStamp: "Fri",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: true,
        isFlagged: false,
        attachments: [
            MessageAttachment(name: "Sam Lee resume.pdf", detail: "PDF · 340 KB"),
        ],
        meeting: MeetingScenario(
            kind: .delegated,
            title: "Interview loop: Sam Lee",
            dateLine: "Tuesday, August 4 · 1:00–2:00 PM",
            location: "Teams meeting",
            organizer: "Recruiting",
            detail: "Product thinking interview.",
            delegateOwner: "Jordan Patel"
        )
    ),
    InboxThread(
        section: .thisWeek,
        sender: "Nina Kapoor",
        recipients: "To you, Offsite planning",
        subject: "Choose a time for the team offsite",
        preview: "Three poll times are available.",
        body: "Vote for every time you can attend. We will close the poll on Friday.",
        timeStamp: "Thu",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false,
        meeting: MeetingScenario(
            kind: .poll,
            title: "Team offsite planning",
            dateLine: "September 2026",
            location: "Redmond campus",
            organizer: "Nina Kapoor",
            detail: "Select all times that work.",
            pollOptions: [
                "Sep 9 · 9:00 AM–1:00 PM",
                "Sep 10 · 12:00–4:00 PM",
                "Sep 11 · 9:00 AM–1:00 PM",
            ]
        )
    ),
    InboxThread(
        section: .thisWeek,
        sender: "Contoso Design",
        recipients: "To you",
        subject: "Invitation to share the Design Events calendar",
        preview: "Contoso Design invited you to view a shared calendar.",
        body: "Accept this invitation to add the Design Events calendar to Outlook.",
        timeStamp: "Wed",
        isUnread: false,
        isExternalSender: true,
        hasAttachment: false,
        isFlagged: false,
        meeting: MeetingScenario(
            kind: .sharedCalendar,
            title: "Design Events",
            dateLine: "Shared calendar",
            location: nil,
            organizer: "Contoso Design",
            detail: "View design reviews, critiques, and community events."
        )
    ),
    InboxThread(
        section: .thisWeek,
        sender: "Alaska Airlines",
        recipients: "To you",
        subject: "Your Seattle flight reservation",
        preview: "Your reservation is confirmed. View the latest itinerary and flight details.",
        body: "Flight 1468 from SEA to SFO is confirmed.",
        timeStamp: "Tue",
        isUnread: false,
        isExternalSender: true,
        hasAttachment: false,
        isFlagged: false,
        txp: TxpScenario(
            kind: .flightReservation,
            title: "Flight Reservation",
            detail: nil,
            actionTitle: "View"
        )
    ),
    InboxThread(
        section: .thisWeek,
        sender: "Delta",
        recipients: "To you",
        subject: "Flight itinerary updated",
        preview: "Your departure time is Saturday, December 3 at 3:00 PM.",
        body: "Your updated itinerary is ready to view.",
        timeStamp: "Tue",
        isUnread: false,
        isExternalSender: true,
        hasAttachment: false,
        isFlagged: false,
        txp: TxpScenario(
            kind: .flightReservation,
            title: "Sat, 3 Dec. at 3:00pm",
            detail: nil,
            actionTitle: "View"
        )
    ),
    InboxThread(
        section: .thisWeek,
        sender: "Microsoft Store",
        recipients: "To you",
        subject: "Your order has shipped",
        preview: "The parcel is on its way. View the order details.",
        body: "Your order has left the fulfillment center.",
        timeStamp: "Tue",
        isUnread: false,
        isExternalSender: false,
        hasAttachment: false,
        isFlagged: false,
        txp: TxpScenario(
            kind: .parcelDelivery,
            title: "Parcel Delivery",
            detail: nil,
            actionTitle: "View"
        )
    ),
    InboxThread(
        section: .thisWeek,
        sender: "UPS",
        recipients: "To you",
        subject: "Delivery expected Thursday",
        preview: "Your parcel is expected on Thursday, October 27.",
        body: "Track the parcel for the latest delivery status.",
        timeStamp: "Tue",
        isUnread: false,
        isExternalSender: true,
        hasAttachment: false,
        isFlagged: false,
        txp: TxpScenario(
            kind: .parcelDelivery,
            title: "Expected: Thu, 27 Oct.",
            detail: nil,
            actionTitle: "Track"
        )
    ),
]
