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
import SwiftUI

struct ReadingPaneView: View {
    let thread: InboxThread

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    senderBlock
                    Divider()
                    bodyContent
                    Spacer(minLength: 96)
                }
            }

            ReadingPaneActionBar()
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle(thread.subject)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var senderBlock: some View {
        HStack(alignment: .top, spacing: 12) {
            Avatar(
                style: .default,
                size: .size40,
                primaryText: thread.sender
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(thread.sender)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(thread.recipients)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(thread.timeStamp)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    /// Shield icon: production uses a security label / encryption-state icon
                    /// here. Visual-only in Phase 1.
                    Image(systemName: "shield.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(uiColor: GlobalTokens.brandColor(.comm80)))

                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private var bodyContent: some View {
        Text(thread.body)
            .font(.system(size: 16))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
    }
}

#Preview {
    NavigationStack {
        ReadingPaneView(thread: sampleThreads[0])
    }
    .fluentTheme(FluentTheme.shared)
}
