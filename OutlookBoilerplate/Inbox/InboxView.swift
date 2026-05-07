//
//  InboxView.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/
//      (production Inbox composes a header + table view + DAB-managed floating actions)
//    - client-cocoa/app-ios/Modules/Mail/MailReadingPane/Messages/MessageVC.swift line 76
//      (production navigation: reading pane is pushed onto a UINavigationController. We
//      mirror with SwiftUI NavigationStack + path-based push.)
//

import FluentUI
import SwiftUI

struct InboxView: View {
    @Binding var showingSideDrawer: Bool
    @Binding var showingCopilotSheet: Bool

    @State private var navigationPath = NavigationPath()
    @State private var showingComposeSheet = false

    @Environment(\.fluentTheme) private var fluentTheme: FluentTheme

    var body: some View {
        NavigationStack(path: $navigationPath) {
            inboxContent
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: InboxThread.self) { thread in
                    ReadingPaneView(thread: thread)
                }
                .fullScreenCover(isPresented: $showingComposeSheet) {
                    ComposeView()
                }
        }
    }

    private var inboxContent: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                InboxHeader(onAvatarTap: { showingSideDrawer = true })
                threadList
            }
            InboxFloatingActions(
                onComposeTap: { showingComposeSheet = true },
                onCopilotTap: { showingCopilotSheet = true }
            )
            .padding(.bottom, 8)
        }
        .background(fluentTheme.swiftUIColor(.background1))
    }

    private var threadList: some View {
        FluentList {
            FluentListSection {
                ForEach(sampleThreads) { thread in
                    InboxRow(thread: thread) {
                        navigationPath.append(thread)
                    }
                }
            }
        }
        .fluentListStyle(.plain)
    }
}

#Preview {
    InboxView(
        showingSideDrawer: .constant(false),
        showingCopilotSheet: .constant(false)
    )
    .fluentTheme(FluentTheme.shared)
}
