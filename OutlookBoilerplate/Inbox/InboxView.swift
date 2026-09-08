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
import OutlookBackdrop
import SwiftUI

struct InboxView: View {
    @Binding var showingSideDrawer: Bool
    @Binding var showingCopilotSheet: Bool
    @Binding var showingComposeSheet: Bool
    /// Bubbles ReadingPaneView push/pop up to ContentView so the bottom-nav
    /// Compose FAB can hide while the user is inside a thread.
    @Binding var readingPanePresented: Bool

    @State private var navigationPath = NavigationPath()

    /// Drives `InboxHeader`'s collapse animation. Updated by the thread list's
    /// `onScrollGeometryChange`. 0 = at top, grows positively as user scrolls down.
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack(path: $navigationPath) {
            inboxContent
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: InboxThread.self) { thread in
                    ReadingPaneView(thread: thread)
                        .onAppear { readingPanePresented = true }
                        .onDisappear { readingPanePresented = false }
                }
                .sheet(isPresented: $showingComposeSheet) {
                    ComposeView()
                }
        }
    }

    private var inboxContent: some View {
        VStack(spacing: 0) {
            InboxHeader(
                onAvatarTap: { showingSideDrawer = true },
                scrollOffset: scrollOffset
            )
            threadList
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { _, newValue in
                    scrollOffset = newValue
                }
        }
        .background(Color.odsNeutralBackground1)
    }

    private var threadList: some View {
        FluentList {
            ForEach(InboxSection.allCases, id: \.self) { section in
                let threads = sampleThreads.filter { $0.section == section }
                if !threads.isEmpty {
                    // `Section { ... }` without a `header:` parameter is just a logical
                    // grouping — no sticky element. The label row below scrolls naturally
                    // with content, matching production Mail behavior.
                    Section {
                        // Production Outlook iOS doesn't label the top-most section
                        // ("Today"); threads start immediately. Subsequent sections get
                        // labels ("Yesterday", "This Week", "Last Week", …).
                        if section != .today {
                            Text(section.rawValue)
                                .font(.odsMailListSectionHeader)
                                .foregroundStyle(Color.odsNeutralForeground2)
                                .textCase(nil)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                // 16pt leading (production-faithful); 8pt top / 12pt
                                // bottom — tighter to the row above, breathing below.
                                .padding(.horizontal, .odsSpacingHorizontalL)  // 16pt
                                .padding(.top, .odsSpacingVerticalS)           // 8pt
                                .padding(.bottom, .odsSize120)                 // 12pt
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }

                        ForEach(Array(threads.enumerated()), id: \.element.id) { index, thread in
                            InboxRow(
                                thread: thread,
                                onTap: { navigationPath.append(thread) },
                                isLastInSection: index == threads.count - 1
                            )
                            // Suppress FluentList's default separator + edge insets
                            // so the custom row controls its own layout (edge-to-edge
                            // Divider, full-width body).
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
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
        showingCopilotSheet: .constant(false),
        showingComposeSheet: .constant(false),
        readingPanePresented: .constant(false)
    )
    .fluentTheme(FluentTheme.shared)
}
