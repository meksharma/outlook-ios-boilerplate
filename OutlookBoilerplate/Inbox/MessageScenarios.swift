import Foundation

struct MessageAttachment: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case file
        case image
        case cloudLink
        case attachedMessage
        case calendarEvent
    }

    let id: String
    let name: String
    let detail: String
    let kind: Kind

    init(id: String = UUID().uuidString, name: String, detail: String, kind: Kind = .file) {
        self.id = id
        self.name = name
        self.detail = detail
        self.kind = kind
    }
}

struct MeetingScenario: Hashable {
    enum Kind: Hashable {
        case invitation
        case updated
        case cancelled
        case proposedTime
        case conflict
        case recurring
        case delegated
        case poll
        case sharedCalendar
    }

    enum Response: String, CaseIterable, Hashable {
        case none
        case accepted
        case tentative
        case declined
    }

    let kind: Kind
    let title: String
    let dateLine: String
    let location: String?
    let organizer: String
    let detail: String
    var response: Response = .none
    var previousDetail: String? = nil
    var delegateOwner: String? = nil
    var pollOptions: [String] = []

    var rowLabel: String {
        switch kind {
        case .invitation: "RSVP requested"
        case .updated: "Event updated"
        case .cancelled: "Meeting cancelled"
        case .proposedTime: "New time proposed"
        case .conflict: "Conflicts with another event"
        case .recurring: "Recurring meeting"
        case .delegated: delegateOwner.map { "Received for \($0)" } ?? "Delegated invitation"
        case .poll: "\(pollOptions.count) poll times available"
        case .sharedCalendar: "Shared calendar invitation"
        }
    }

}

struct TxpScenario: Hashable {
    enum Kind: Hashable {
        case eventReservation
        case rentalCarReservation
        case foodReservation
        case lodgingReservation
        case parcelDelivery
        case flightReservation
        case invoice
    }

    let kind: Kind
    let title: String
    let detail: String?
    let actionTitle: String
}
