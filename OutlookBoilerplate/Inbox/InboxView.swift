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
    @Binding var showingSearch: Bool
    /// Bubbles ReadingPaneView push/pop up to ContentView so the bottom-nav
    /// Compose FAB can hide while the user is inside a thread.
    @Binding var readingPanePresented: Bool

    @State private var navigationPath = NavigationPath()

    /// Drives `InboxHeader`'s collapse animation. Updated by the thread list's
    /// `onScrollGeometryChange`. 0 = at top, grows positively as user scrolls down.
    @State private var scrollOffset: CGFloat = 0
    @State private var liveThreads: [InboxThread] = []
    @State private var isLoadingWorkIQ = false
    @State private var workIQError: String?
    @State private var inboxRefreshTask: Task<Void, Never>?
    @AppStorage("workIQEnabled") private var workIQEnabled: Bool = false
    @AppStorage("hotspotHintsEnabled") private var hotspotHintsEnabled: Bool = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            inboxContent
                .hotspotRegistrationEnabled(navigationPath.isEmpty)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: InboxThread.self) { thread in
                    ReadingPaneView(
                        thread: thread,
                        usesWorkIQ: workIQEnabled,
                        onBack: {
                            if !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        }
                    )
                        .onAppear { readingPanePresented = true }
                        .onDisappear { readingPanePresented = false }
                }
                .sheet(isPresented: $showingComposeSheet) {
                    ComposeView()
                        .hotspotHintsSurface(isEnabled: hotspotHintsEnabled)
                }
        }
    }

    private var inboxContent: some View {
        VStack(spacing: 0) {
            InboxHeader(
                onAvatarTap: { showingSideDrawer = true },
                onSearchTap: { showingSearch = true },
                scrollOffset: scrollOffset
            )
            workIQStatus
            threadList
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { _, newValue in
                    scrollOffset = newValue
                }
        }
        .background(Color.odsNeutralBackground1)
        .task(id: workIQEnabled) {
            inboxRefreshTask?.cancel()
            inboxRefreshTask = Task {
                await refreshWorkIQInbox()
            }
            await inboxRefreshTask?.value
        }
    }

    @ViewBuilder
    private var workIQStatus: some View {
        if workIQEnabled && isLoadingWorkIQ {
            HStack(spacing: .odsSpacingHorizontalS) {
                ProgressView()
                Text("Loading your Work IQ inbox...")
                    .font(.odsBody2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .odsSpacingHorizontalL)
            .padding(.vertical, .odsSpacingVerticalS)
            .background(Color.odsNeutralBackground2)
        } else if workIQEnabled, let workIQError {
            Text(workIQError)
                .font(.odsBody2)
                .foregroundStyle(Color.odsStatusDangerForeground1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .odsSpacingHorizontalL)
                .padding(.vertical, .odsSpacingVerticalS)
                .background(Color.odsStatusDangerBackground1)
        }
    }

    private var threadList: some View {
        FluentList {
            ForEach(InboxSection.allCases, id: \.self) { section in
                let threads = displayedThreads.filter { $0.section == section }
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

    private var displayedThreads: [InboxThread] {
        workIQEnabled ? liveThreads : sampleThreads
    }

    @MainActor
    private func refreshWorkIQInbox() async {
        guard workIQEnabled else {
            inboxRefreshTask?.cancel()
            liveThreads = []
            workIQError = nil
            isLoadingWorkIQ = false
            return
        }

        let client = WorkIQClient()
        let cachedThreads = client.cachedInbox()
        if !cachedThreads.isEmpty {
            liveThreads = cachedThreads
        }
        isLoadingWorkIQ = cachedThreads.isEmpty
        workIQError = nil
        do {
            let refreshedThreads = try await client.recentInbox()
            try Task.checkCancellation()
            liveThreads = refreshedThreads
        } catch is CancellationError {
            return
        } catch {
            if cachedThreads.isEmpty {
                liveThreads = []
            }
            workIQError = "Work IQ inbox unavailable. Start `node Tools/workiq_bridge.js`, then toggle Work IQ off and on.\n\(error.localizedDescription)"
        }
        isLoadingWorkIQ = false
    }
}

#Preview {
    InboxView(
        showingSideDrawer: .constant(false),
        showingCopilotSheet: .constant(false),
        showingComposeSheet: .constant(false),
        showingSearch: .constant(false),
        readingPanePresented: .constant(false)
    )
    .fluentTheme(FluentTheme.shared)
}
