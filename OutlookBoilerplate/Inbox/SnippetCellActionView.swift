import OutlookBackdrop
import SwiftUI

/// SwiftUI port of production's `SharedMeetings.ActionView`, configured by
/// `SnippetCellActionViewModel`. Geometry follows Figma RSVP Bar node 4432:25931.
struct SnippetCellActionView: View {
    let meeting: MeetingScenario?
    let txp: TxpScenario?

    var body: some View {
        if let content {
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    statusIcon(content)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(content.title)
                            .font(.odsCaption1)
                            .tracking(-0.08)
                            .lineLimit(1)

                        if let subtitle = content.subtitle {
                            Text(subtitle)
                                .font(.odsCaption2)
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(Color.odsNeutralForeground2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(content.actionTitle)
                    .font(.odsCaption1Strong)
                    .tracking(-0.08)
                    .foregroundStyle(Color.odsBrandForeground1)
                    .lineLimit(1)
                    .padding(.horizontal, .odsSpacingHorizontalL)
                    .frame(height: 30)
                    .background(Color.odsControlSegmentBackground2, in: Capsule())
            }
            .padding(6)
            .frame(height: 44)
            .background(Color.odsNeutralBackground4, in: Capsule())
            .padding(.top, 4)
        }
    }

    private func statusIcon(_ content: Content) -> some View {
        Image(content.icon)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
            .frame(width: 20, height: 20)
            .frame(width: 32, height: 32)
            .background(content.iconBackground, in: Circle())
            .overlay(alignment: .bottomTrailing) {
                if let badge = content.badge {
                    Text(badge.symbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 14, height: 14)
                        .background(badge.color, in: Circle())
                        .overlay {
                            Circle().stroke(.white, lineWidth: 1)
                        }
                        .offset(x: 2, y: 2)
                }
            }
    }

    private var calendarRed: Color {
        // Figma RSVP Bar calendar-red token: #CF2B36.
        Color(red: 0xCF / 255, green: 0x2B / 255, blue: 0x36 / 255)
    }

    private var calendarBlue: Color {
        Color(red: 0x00 / 255, green: 0x78 / 255, blue: 0xD4 / 255)
    }

    private var content: Content? {
        if let meeting {
            return meetingContent(meeting)
        }
        if let txp {
            return txpContent(txp)
        }
        return nil
    }

    private func meetingContent(_ meeting: MeetingScenario) -> Content {
        let responseAction = meeting.response == .none ? "RSVP" : "Edit RSVP"

        switch meeting.kind {
        case .invitation:
            return Content(
                title: meeting.dateLine,
                subtitle: nil,
                actionTitle: responseAction,
                icon: .calendarEmpty24Regular,
                iconBackground: calendarBlue,
                badge: responseBadge(meeting.response)
            )
        case .conflict:
            return Content(
                title: meeting.dateLine,
                subtitle: meeting.detail,
                actionTitle: responseAction,
                icon: .calendarEmpty24Regular,
                iconBackground: calendarBlue,
                badge: .conflict
            )
        case .updated:
            return Content(
                title: "Event Updated",
                subtitle: meeting.title,
                actionTitle: responseAction,
                icon: .calendarEmpty24Regular,
                iconBackground: calendarRed,
                badge: .updated
            )
        case .cancelled:
            return Content(
                title: "Event Cancelled",
                subtitle: meeting.title,
                actionTitle: "Remove",
                icon: .calendarEmpty24Regular,
                iconBackground: calendarRed,
                badge: .cancelled
            )
        case .proposedTime:
            return Content(
                title: "New Time Proposed",
                subtitle: meeting.dateLine,
                actionTitle: "Review",
                icon: .calendarEmpty24Regular,
                iconBackground: calendarBlue,
                badge: .proposed
            )
        case .recurring:
            return Content(
                title: meeting.dateLine,
                subtitle: meeting.detail,
                actionTitle: responseAction,
                icon: .calendarEmpty24Regular,
                iconBackground: calendarBlue,
                badge: responseBadge(meeting.response)
            )
        case .delegated:
            return Content(
                title: meeting.dateLine,
                subtitle: nil,
                actionTitle: responseAction,
                icon: .calendarEmpty24Regular,
                iconBackground: calendarBlue,
                badge: responseBadge(meeting.response)
            )
        case .poll:
            return Content(
                title: "\(meeting.pollOptions.count) poll times available",
                subtitle: meeting.title,
                actionTitle: "View",
                icon: .calendarEmpty24Regular,
                iconBackground: calendarBlue,
                badge: nil
            )
        case .sharedCalendar:
            return Content(
                title: "Shared Calendar",
                subtitle: meeting.title,
                actionTitle: "Accept",
                icon: .calendarEmpty24Regular,
                iconBackground: calendarBlue,
                badge: nil
            )
        }
    }

    private func txpContent(_ txp: TxpScenario) -> Content {
        Content(
            title: txp.title,
            subtitle: txp.detail,
            actionTitle: txp.actionTitle,
            icon: txpIcon(txp.kind),
            iconBackground: calendarRed,
            badge: nil
        )
    }

    private func txpIcon(_ kind: TxpScenario.Kind) -> OutlookIcon {
        switch kind {
        case .flightReservation:
            return .airplane24Filled
        case .parcelDelivery:
            return .vehicleTruckCube24Filled
        case .eventReservation:
            return .calendarEmpty24Regular
        case .rentalCarReservation, .foodReservation, .lodgingReservation, .invoice:
            return .appFolder24Filled
        }
    }

    private func responseBadge(_ response: MeetingScenario.Response) -> Badge? {
        switch response {
        case .none:
            return nil
        case .accepted:
            return .accepted
        case .tentative:
            return .tentative
        case .declined:
            return .declined
        }
    }

    private struct Content {
        let title: String
        let subtitle: String?
        let actionTitle: String
        let icon: OutlookIcon
        let iconBackground: Color
        let badge: Badge?
    }

    private struct Badge {
        let symbol: String
        let color: Color

        static let conflict = Badge(symbol: "!", color: .gray)
        static let cancelled = Badge(symbol: "×", color: .odsStatusDangerForeground2)
        static let updated = Badge(symbol: "×", color: .odsStatusDangerForeground2)
        static let proposed = Badge(symbol: "↗", color: .odsBrandForeground1)
        static let accepted = Badge(symbol: "✓", color: .odsStatusSuccessForeground2)
        static let tentative = Badge(symbol: "?", color: .odsStatusWarningForeground2)
        static let declined = Badge(symbol: "×", color: .odsStatusDangerForeground2)
    }
}
