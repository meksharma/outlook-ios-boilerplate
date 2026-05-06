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
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            inboxContent
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: InboxThread.self) { thread in
                    ReadingPaneView(thread: thread)
                }
        }
    }

    private var inboxContent: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                InboxHeader()
                threadList
            }
            InboxFloatingActions()
                .padding(.bottom, 8)
        }
        .background(Color(uiColor: .systemBackground))
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
    InboxView()
        .fluentTheme(FluentTheme.shared)
}
