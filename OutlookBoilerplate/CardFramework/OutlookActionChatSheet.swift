import OutlookBackdrop
import SwiftUI

struct OutlookActionChatSheet: View {
    let model: OutlookActionChatSheetModel
    let onDismiss: () -> Void

    @State private var promptText = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            Spacer(minLength: 0)
            composer
        }
        .background(Color.odsNeutralBackground1)
        .accessibilityLabel("Copilot chat for \(model.action.title)")
        .accessibilityAction(.escape, onDismiss)
    }

    private var header: some View {
        HStack(spacing: .odsSize120) {
            accountControl
            Spacer(minLength: 0)
            completionStatus
            moreButton
        }
        .padding(.horizontal, .odsSize160)
        .padding(.vertical, .odsSize120)
    }

    private var accountControl: some View {
        HStack(spacing: .odsSize120) {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.odsNeutralForeground2)
                    .frame(width: 36, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open chat navigation")

            Text("M")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.odsNeutralForegroundStaticLight)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(ODSPrimitive.sharedDarkOrangePrimary)
                )
                .accessibilityLabel("Mehak")
        }
        .padding(.horizontal, .odsSize80)
        .background(Color.odsNeutralBackground2)
        .clipShape(Capsule())
    }

    private var completionStatus: some View {
        HStack(spacing: .odsSize80) {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.odsNeutralForegroundStaticLight)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.green))

            Text("1 Done")
                .odsBody1Strong()
                .foregroundStyle(Color.odsNeutralForeground1)
        }
        .padding(.horizontal, .odsSize120)
        .frame(height: 52)
        .background(Color.odsNeutralBackground2)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
    }

    private var moreButton: some View {
        Button(action: {}) {
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.odsNeutralForeground2)
                .frame(width: 52, height: 52)
                .background(Color.odsNeutralBackground2)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("More options")
    }

    private var composer: some View {
        HStack(spacing: .odsSize80) {
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 25, weight: .light))
                    .foregroundStyle(Color.odsNeutralForeground2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add")

            TextField("Ask Copilot", text: $promptText)
                .font(.odsBody1)
                .foregroundStyle(Color.odsNeutralForeground1)
                .submitLabel(.send)

            Button(action: {}) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.odsNeutralForegroundStaticLight)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.odsBrandBackground1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop")
        }
        .padding(.leading, .odsSize80)
        .padding(.trailing, .odsSize80)
        .padding(.vertical, .odsSize80)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.odsNeutralBackground1)
                .stroke(Color.odsNeutralStroke2, lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 16,
            y: 4
        )
        .padding(.horizontal, .odsSize160)
        .padding(.bottom, .odsSize120)
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            OutlookActionChatSheet(
                model: OutlookActionChatSheetModel(
                    action: OutlookCardAction(
                        id: "preview",
                        title: "Show more details"
                    )
                ),
                onDismiss: {}
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(34)
        }
}
