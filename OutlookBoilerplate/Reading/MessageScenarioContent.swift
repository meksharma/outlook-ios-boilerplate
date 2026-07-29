import OutlookBackdrop
import SwiftUI

struct AttachmentWellView: View {
    let attachments: [MessageAttachment]

    var body: some View {
        VStack(alignment: .leading, spacing: .odsSpacingVerticalS) {
            HStack {
                Text(attachments.count == 1 ? "Attachment" : "\(attachments.count) attachments")
                    .font(.odsBody2Strong)
                    .foregroundStyle(Color.odsNeutralForeground1)

                Spacer()

                if attachments.count > 1 {
                    Button("Save all", action: {})
                        .font(.odsBody2)
                        .foregroundStyle(Color.odsBrandForeground1)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .odsSpacingHorizontalS) {
                    ForEach(attachments) { attachment in
                        attachmentCard(attachment)
                    }
                }
            }
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.bottom, .odsSize160)
    }

    private func attachmentCard(_ attachment: MessageAttachment) -> some View {
        Button(action: {}) {
            HStack(spacing: .odsSpacingHorizontalS) {
                Image(icon(for: attachment.kind))
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.odsBrandForeground1)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(attachment.name)
                        .font(.odsBody2Strong)
                        .foregroundStyle(Color.odsNeutralForeground1)
                        .lineLimit(1)

                    Text(attachment.detail)
                        .font(.odsCaption1)
                        .foregroundStyle(Color.odsNeutralForeground2)
                        .lineLimit(1)
                }
            }
            .padding(.odsSpacingHorizontalS)
            .frame(width: 238, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .odsSize120)
                    .fill(Color.odsNeutralBackground2)
                    .overlay {
                        RoundedRectangle(cornerRadius: .odsSize120)
                            .stroke(Color.odsNeutralStroke2)
                    }
            )
        }
        .buttonStyle(.plain)
    }

    private func icon(for kind: MessageAttachment.Kind) -> OutlookIcon {
        switch kind {
        case .calendarEvent:
            return .calendarEmpty24Regular
        case .cloudLink:
            return .folder24Regular
        case .attachedMessage:
            return .mail24Regular
        case .file, .image:
            return .attach24Regular
        }
    }
}

struct MeetingScenarioCard: View {
    let meeting: MeetingScenario

    @State private var response: MeetingScenario.Response
    @State private var acceptedSharedCalendar = false
    @State private var selectedPollOptions: Set<String> = []

    init(meeting: MeetingScenario) {
        self.meeting = meeting
        _response = State(initialValue: meeting.response)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .odsSpacingVerticalS) {
            HStack(alignment: .top, spacing: .odsSpacingHorizontalS) {
                Image(.calendarEmpty24Regular)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(accentColor)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(eyebrow)
                        .font(.odsCaption1)
                        .foregroundStyle(accentColor)

                    Text(meeting.title)
                        .font(.odsHeadlineStrong)
                        .foregroundStyle(Color.odsNeutralForeground1)
                }
            }

            detailRow(meeting.dateLine)
            if let location = meeting.location {
                detailRow(location)
            }
            detailRow("Organized by \(meeting.organizer)")

            if let previousDetail = meeting.previousDetail {
                Text(previousDetail)
                    .font(.odsCaption1)
                    .strikethrough(meeting.kind == .updated || meeting.kind == .proposedTime)
                    .foregroundStyle(Color.odsNeutralForeground2)
            }

            Text(meeting.detail)
                .font(.odsBody2)
                .foregroundStyle(Color.odsNeutralForeground2)

            if meeting.kind == .delegated, let owner = meeting.delegateOwner {
                infoStrip("Received for \(owner)")
            }

            if meeting.kind == .poll {
                pollOptions
            } else {
                actions
            }
        }
        .padding(.odsSpacingHorizontalL)
        .background(
            RoundedRectangle(cornerRadius: .odsSize160)
                .fill(cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: .odsSize160)
                        .stroke(accentColor.opacity(0.35))
                }
        )
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.top, .odsSize160)
    }

    private var eyebrow: String {
        switch meeting.kind {
        case .invitation: "Invitation"
        case .updated: "Event updated"
        case .cancelled: "Cancelled"
        case .proposedTime: "New time proposed"
        case .conflict: "Schedule conflict"
        case .recurring: "Recurring event"
        case .delegated: "Delegated invitation"
        case .poll: "Scheduling poll"
        case .sharedCalendar: "Shared calendar"
        }
    }

    private var accentColor: Color {
        switch meeting.kind {
        case .cancelled:
            return .odsStatusDangerForeground1
        case .conflict:
            return .odsStatusWarningForeground1
        default:
            return .odsBrandForeground1
        }
    }

    private var cardBackground: Color {
        switch meeting.kind {
        case .cancelled:
            return .odsStatusDangerBackground1
        case .conflict:
            return .odsStatusWarningBackground1
        default:
            return .odsBrandBackgroundTint2
        }
    }

    private func detailRow(_ value: String) -> some View {
        Text(value)
            .font(.odsBody2)
            .foregroundStyle(Color.odsNeutralForeground1)
    }

    private func infoStrip(_ value: String) -> some View {
        Text(value)
            .font(.odsBody2Strong)
            .foregroundStyle(Color.odsBrandForeground1)
            .padding(.odsSpacingHorizontalS)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.odsNeutralBackground1.opacity(0.8), in: RoundedRectangle(cornerRadius: .odsSize80))
    }

    @ViewBuilder
    private var actions: some View {
        switch meeting.kind {
        case .cancelled:
            scenarioButton("Remove from calendar", role: .destructive) {}
        case .proposedTime:
            HStack {
                scenarioButton("Accept new time") { response = .accepted }
                scenarioButton("Decline", role: .destructive) { response = .declined }
            }
        case .sharedCalendar:
            scenarioButton(acceptedSharedCalendar ? "Calendar added" : "Accept calendar") {
                acceptedSharedCalendar = true
            }
            .disabled(acceptedSharedCalendar)
        case .invitation, .updated, .conflict, .recurring, .delegated:
            if response == .none {
                HStack {
                    scenarioButton("Accept") { response = .accepted }
                    scenarioButton("Tentative") { response = .tentative }
                    scenarioButton("Decline", role: .destructive) { response = .declined }
                }
            } else {
                HStack {
                    Text(responseLabel)
                        .font(.odsBody2Strong)
                        .foregroundStyle(Color.odsStatusSuccessForeground1)
                    Spacer()
                    scenarioButton("Edit response") { response = .none }
                }
            }
        case .poll:
            EmptyView()
        }
    }

    private var pollOptions: some View {
        VStack(spacing: .odsSize40) {
            ForEach(meeting.pollOptions, id: \.self) { option in
                Button {
                    if selectedPollOptions.contains(option) {
                        selectedPollOptions.remove(option)
                    } else {
                        selectedPollOptions.insert(option)
                    }
                } label: {
                    HStack {
                        Text(option)
                            .font(.odsBody2)
                        Spacer()
                        if selectedPollOptions.contains(option) {
                            Text("Selected")
                                .font(.odsCaption1)
                                .foregroundStyle(Color.odsBrandForeground1)
                        }
                    }
                    .foregroundStyle(Color.odsNeutralForeground1)
                    .padding(.odsSpacingHorizontalS)
                    .background(Color.odsNeutralBackground1.opacity(0.8), in: RoundedRectangle(cornerRadius: .odsSize80))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func scenarioButton(
        _ title: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(title, role: role, action: action)
            .font(.odsBody2Strong)
            .buttonStyle(.bordered)
            .tint(role == .destructive ? Color.odsStatusDangerForeground1 : Color.odsBrandForeground1)
    }

    private var responseLabel: String {
        switch response {
        case .none: ""
        case .accepted: "Accepted"
        case .tentative: "Tentative"
        case .declined: "Declined"
        }
    }
}
