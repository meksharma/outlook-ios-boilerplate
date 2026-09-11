//
//  ReadingPaneView.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailReadingPane/Messages/MessageVC.swift
//      (production reading pane, UIKit MessageVC — confirms NavigationController-pushed VC,
//      subject as nav title, sender block + body + DAB action bar layout)
//    - client-cocoa/app-ios/Modules/Mail/MailOther/Conversation/SummaryHeader/MessageSummaryHeaderView.swift
//      (production sender block — avatar + name + recipients + time + overflow; we mirror this
//      with FluentUI's Avatar + plain Text)
//    - client-cocoa/app-ios/Modules/Mail/MailReadingPane/Conversation/ConversationSubjectTitleContainer.swift
//      (production navigation title — `TwoLinesTitleView` rendering subject + attachment count)
//    - client-cocoa/app-ios/Modules/Mail/MailOther/Conversation/EmailRenderKitView/MessageContentView.swift
//      (production body rendering — WKWebView for HTML; we use plain Text since the
//      boilerplate has no real mail backend)
//

import FluentUI
import OutlookBackdrop
import SwiftUI

struct ReadingPaneView: View {
    let thread: InboxThread
    let usesWorkIQ: Bool
    let onBack: () -> Void
    let onOpenReferences: ([OutlookCardReference]) -> Void
    let onCardAction: (OutlookCardAction) -> Void
    @State private var workIQBody: WorkIQMessageBody?
    @State private var bodyError: String?
    @AppStorage("cardFrameworkEnabled") private var cardFrameworkEnabled: Bool = false
    @AppStorage("cardFrameworkTheme") private var cardFrameworkTheme: String = OutlookCardTheme.neutral.rawValue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                senderBlock
                Divider()
                if let meeting = thread.meeting {
                    MeetingScenarioCard(meeting: meeting)
                }
                if cardFrameworkEnabled {
                    SummarizeCard(
                        theme: OutlookCardTheme(rawValue: cardFrameworkTheme) ?? .neutral,
                        onOpenReferences: onOpenReferences,
                        onAction: onCardAction
                    )
                    .padding(.horizontal, .odsSize160)
                    .padding(.top, .odsSize160)
                }
                bodyContent
                if !thread.attachments.isEmpty {
                    AttachmentWellView(attachments: thread.attachments)
                }
            }
        }
        .background(Color.odsNeutralBackground1)
        .navigationTitle(thread.subject)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
        .task(id: thread.id) {
            await loadFullBody()
        }
        // ReadingPaneActionBar is rendered at the ContentView level (stacked
        // above BottomNav inside the outer `safeAreaInset`) so it sits
        // visibly above the tab pill rather than being clipped beneath it
        // by the `.ignoresSafeArea(.container, edges: .bottom)` on
        // `currentTabContent`. Visibility is driven by the
        // `readingPanePresented` binding bubbled up from InboxView.
    }

    @ViewBuilder
    private var backButton: some View {
        if cardFrameworkEnabled {
            Button(action: onBack) {
                Image(.chevronLeft28Regular)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(Color.odsNeutralForeground1)
                    .frame(width: 10.25, height: 19)
                    .frame(width: 36, height: 36)
            }
            .frame(width: 44, height: 44)
            .background(Color.odsNeutralBackground1, in: Circle())
            .shadow(
                color: Color.black.opacity(0.02),
                radius: 20,
                y: 4
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 10,
                y: 4
            )
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
        } else {
            Button(action: onBack) {
                Image(.arrowLeft24Regular)
                    .renderingMode(.template)
                    .foregroundStyle(Color.odsNeutralForeground1)
                    .frame(width: 44, height: 44)
                    .glassEffectCompat(interactive: true, in: Circle())
            }
            .buttonStyle(.plain)
            .hotspotTarget()
            .accessibilityLabel("Back")
        }
    }

    private var senderBlock: some View {
        HStack(alignment: .top, spacing: .odsSize120) {
            Avatar(
                style: .default,
                size: .size40,
                primaryText: thread.sender
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(thread.sender)
                    .font(.odsHeadlineStrong)
                    .foregroundStyle(Color.odsNeutralForeground1)

                Text(thread.recipients)
                    .font(.odsBody2)
                    .foregroundStyle(Color.odsNeutralForeground2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: .odsSize40) {
                Text(thread.timeStamp)
                    .font(.odsCaption1)
                    .foregroundStyle(Color.odsNeutralForeground2)

                HStack(spacing: .odsSize120) {
                    /// Shield icon: production uses a security label / encryption-state icon
                    /// here. Visual-only in Phase 1.
                    Image(.shield16Filled)
                        .renderingMode(.template)
                        .foregroundStyle(ODSPrimitive.brandCommBlue80)

                    Image(.moreHorizontal16Regular)
                        .renderingMode(.template)
                        .foregroundStyle(Color.odsNeutralForeground2)
                }
            }
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, .odsSpacingHorizontalL)
    }

    @ViewBuilder
    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: .odsSpacingVerticalS) {
            Text(workIQBody?.displayText ?? thread.body)
                .font(.odsHeadline)
                .foregroundStyle(Color.odsNeutralForeground1)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let bodyError {
                Text(bodyError)
                    .font(.odsCaption1)
                    .foregroundStyle(Color.odsNeutralForeground2)
            }
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, .odsSpacingHorizontalL)
    }

    @MainActor
    private func loadFullBody() async {
        guard usesWorkIQ else { return }
        do {
            workIQBody = try await WorkIQClient().messageBody(id: thread.id)
            bodyError = nil
        } catch is CancellationError {
            return
        } catch {
            bodyError = "Showing the message preview because the full body could not load."
        }
    }
}

#Preview {
    NavigationStack {
        ReadingPaneView(
            thread: sampleThreads[0],
            usesWorkIQ: false,
            onBack: {},
            onOpenReferences: { _ in },
            onCardAction: { _ in }
        )
    }
    .fluentTheme(FluentTheme.shared)
}
