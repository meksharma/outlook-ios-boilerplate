//
//  ContentView.swift
//  OutlookBoilerplate
//
//  Bottom-nav implementation mirrors the canonical Figma node `1648:21501`
//  in "ios26 — Mail and chrome updates". Layout values are Figma-verbatim:
//    • Tab pill: 58pt tall, 29pt radius, rgba(255,255,255,0.8) background,
//      4pt internal padding, 4pt gap between tab cells, equal-flex
//      distribution
//    • Each cell: 24pt icon container, 10pt label (SF Pro Bold/Medium-510),
//      6/7/8/8 padding (top/bottom/horizontal)
//    • Selected highlight: #EDEDED light-gray Capsule, fills the cell
//    • Selected colors: #0088FF brand blue (icon + label)
//    • Unselected colors: #242424 dark gray
//    • Copilot button: 58×58 circle (28pt icon + 15pt padding), same
//      rgba(255,255,255,0.8) material; sits trailing in the Nav HStack
//    • Compose button: 58×58 circle, identical material, brand-blue icon;
//      Figma uses absolute positioning `left: 319, top: -52` — we mirror
//      with a ZStack overlay + `.offset(y: -52)` so it floats 10pt above
//      the pill top (Figma math: pill top is at Nav.top + 16, Compose
//      bottom is at Nav.top + 6 → 10pt gap)
//    • Outer Nav: 16/32/16/16 padding (top/bottom/horizontal), two-layer
//      drop shadow
//

import FluentUI
import OutlookBackdrop
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showingSideDrawer = false
    @State private var showingCopilotSheet = false
    @State private var showingComposeSheet = false
    @State private var showingSearch = false
    @State private var selectedTab: Tab = .mail
    /// True while a ReadingPaneView is pushed onto the InboxView navigation
    /// stack. Hides the Compose FAB so the reading-pane DAB owns the bottom
    /// chrome (matches dev build).
    @State private var readingPanePresented = false
    @AppStorage("appColorScheme") private var appColorScheme: String = "light"
    /// Production vs Beta build variant (set in the Designer Tools sheet).
    /// Drives which Copilot chat sheet renders.
    @AppStorage("appVariant") private var appVariant: String = "production"

    // MARK: - Bug reporting

    /// Drives the shared bug-report form. Triggered by shake gesture or the
    /// Designer Tools "Report a Bug" row (via `.requestBugReport`). Uses an
    /// item-based sheet so the form only presents once its context + screenshot
    /// exist — avoids the blank-sheet race an optional `isPresented` sheet hits.
    @State private var bugReportRequest: BugReportRequest?

    enum Tab: Int, Hashable { case mail = 0, calendar, apps }

    var body: some View {
        ZStack {
            currentTabContent
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    // Bottom chrome (DAB + tab pill + Copilot + Compose) hides
                    // while the Copilot chat sheet is up — the sheet owns the
                    // bottom of the screen.
                    if !showingCopilotSheet {
                        VStack(spacing: 0) {
                            // Reading-pane DAB stacks above BottomNav, both in
                            // the same safe area inset. Drives the matched
                            // dev-build layering: DAB above tab pill.
                            if readingPanePresented {
                                ReadingPaneActionBar()
                            }
                            BottomNav(
                                selectedTab: $selectedTab,
                                showCompose: selectedTab == .mail && !readingPanePresented,
                                showCalendarAdd: selectedTab == .calendar,
                                onComposeTap: { showingComposeSheet = true },
                                onCalendarAddTap: {},
                                onCopilotTap: { showingCopilotSheet = true }
                            )
                            // Reading-pane DAB owns the 12pt gap above. When no
                            // DAB is shown, the BottomNav needs its own 16pt
                            // breathing room from the content above.
                            .padding(.top, readingPanePresented ? 0 : 16)
                        }
                    }
                }
                // Apply to the safeAreaInset chain so the BottomNav can
                // extend past the home-indicator safe area. Applying this
                // inside BottomNav didn't work — safeAreaInset positions
                // its content within the parent's safe area regardless of
                // ignoreSafeArea on the inset's own content.
                .ignoresSafeArea(.container, edges: .bottom)

            SideDrawerView(isShowing: $showingSideDrawer)
                .zIndex(1)

            if appVariant == "beta" {
                CopilotSheetOverlayBeta(isShowing: $showingCopilotSheet)
                    .zIndex(2)
            } else {
                CopilotSheetOverlay(isShowing: $showingCopilotSheet)
                    .zIndex(2)
            }
        }
        .animation(MotionComponent.sideDrawer.enterAnimation, value: showingSideDrawer)
        .animation(MotionComponent.copilotSheet.enterAnimation, value: showingCopilotSheet)
        .fluentTheme(FluentTheme.shared)
        .environment(\.colorScheme, appColorScheme == "dark" ? .dark : .light)
        .onShake { triggerBugReport() }
        .onReceive(NotificationCenter.default.publisher(for: .requestBugReport)) { _ in
            triggerBugReport()
        }
        .sheet(item: $bugReportRequest) { request in
            BugReportForm(context: request.context, screenshot: request.screenshot)
        }
        .fullScreenCover(isPresented: $showingSearch) {
            SearchScreen(onDismiss: { showingSearch = false })
        }
    }

    /// Captures the current screen + context, then presents the report form.
    /// Screenshot must be grabbed BEFORE the sheet animates up.
    private func triggerBugReport() {
        guard bugReportRequest == nil else { return }
        bugReportRequest = BugReportRequest(
            context: BugReportContext.capture(screen: currentScreenName),
            screenshot: ScreenshotCapture.captureKeyWindow()
        )
    }

    /// Human-readable name of the surface currently in front, for the report.
    private var currentScreenName: String {
        if showingComposeSheet { return "Compose" }
        if showingSearch { return "Search" }
        if showingCopilotSheet { return appVariant == "beta" ? "Copilot (Beta)" : "Copilot" }
        if showingSideDrawer { return "Side drawer" }
        switch selectedTab {
        case .mail: return readingPanePresented ? "Reading pane" : "Inbox"
        case .calendar: return "Calendar"
        case .apps: return "Apps"
        }
    }

    @ViewBuilder
    private var currentTabContent: some View {
        switch selectedTab {
        case .mail:
            InboxView(
                showingSideDrawer: $showingSideDrawer,
                showingCopilotSheet: $showingCopilotSheet,
                showingComposeSheet: $showingComposeSheet,
                showingSearch: $showingSearch,
                readingPanePresented: $readingPanePresented
            )
        case .calendar:
            CalendarScreen(onSearchTap: { showingSearch = true })
        case .apps:
            AppsPlaceholder()
        }
    }
}

// MARK: - Bottom Nav

struct BottomNav: View {
    @Binding var selectedTab: ContentView.Tab
    let showCompose: Bool
    let showCalendarAdd: Bool
    let onComposeTap: () -> Void
    let onCalendarAddTap: () -> Void
    let onCopilotTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main row: tab pill (fills width) + Copilot circle (trailing)
            HStack(spacing: 8) {
                TabPill(selectedTab: $selectedTab)
                CopilotPillFAB(action: onCopilotTap)
            }
            .padding(.horizontal, 16)
            // Top padding is applied from ContentView level so the reading-pane
            // DAB (when shown) can control the gap between itself and this bar.
            .padding(.bottom, 32)
            .shadow(color: .black.opacity(0.06), radius: 40, x: 0, y: 4)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 4)

            // Compose floats above the right side of the pill (Mail tab only).
            // Offset math: ZStack top sits at the HStack's visible top edge
            // (no internal top padding anymore). Compose is 58pt tall; we want
            // its bottom edge 10pt above the tab-pill's top edge, so offset =
            // -(10 + 58) = -68.
            if showCompose {
                ComposePillFAB(action: onComposeTap)
                    .padding(.trailing, 16)
                    .offset(y: -68)
                    .transition(
                        .scale(scale: 0, anchor: .bottom)
                        .combined(with: .opacity)
                    )
            } else if showCalendarAdd {
                CalendarAddPillFAB(action: onCalendarAddTap)
                    .padding(.trailing, 16)
                    .offset(y: -68)
                    .transition(
                        .scale(scale: 0, anchor: .bottom)
                        .combined(with: .opacity)
                    )
            }
        }
        .animation(
            MotionComponent.composePillFAB.enterAnimation,
            value: showCompose || showCalendarAdd
        )
    }
}

// MARK: - Tab Pill

struct TabPill: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 4) {
            TabCell(
                label: "Mail",
                iconRegular: .mail24Regular,
                iconFilled: .mail24Filled,
                selected: selectedTab == .mail,
                onTap: { selectedTab = .mail }
            )
            TabCell(
                label: "Calendar",
                iconRegular: .calendarDate24Regular,
                iconFilled: .calendarDate24Filled,
                selected: selectedTab == .calendar,
                onTap: { selectedTab = .calendar }
            )
            TabCell(
                label: "Apps",
                iconRegular: .appFolder24Regular,
                iconFilled: .appFolder24Filled,
                selected: selectedTab == .apps,
                onTap: { selectedTab = .apps }
            )
        }
        .padding(4)
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .liquidGlassEffect()
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(
            MotionComponent.tabPill.enterAnimation,
            value: appeared
        )
        .onAppear { appeared = true }
    }
}

struct TabCell: View {
    let label: String
    let iconRegular: OutlookIcon
    let iconFilled: OutlookIcon
    let selected: Bool
    let onTap: () -> Void

    // Figma tokens (canonical from node 1648:21502)
    private static let brandBlue = Color(red: 0, green: 136 / 255, blue: 1)            // #0088FF
    private static let darkGray = Color(red: 36 / 255, green: 36 / 255, blue: 36 / 255) // #242424
    private static let selectedFill = Color(red: 237 / 255, green: 237 / 255, blue: 237 / 255) // #EDEDED

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if selected {
                    Capsule().fill(Self.selectedFill)
                        .transition(.scale(scale: 0).combined(with: .opacity))
                }
                VStack(spacing: 1) {
                    Image(selected ? iconFilled : iconRegular)
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(selected ? Self.brandBlue : Self.darkGray)
                    Text(label)
                        .font(.system(size: 10, weight: selected ? .bold : .medium))
                        .foregroundStyle(selected ? Self.brandBlue : Self.darkGray)
                }
                .padding(.top, 6)
                .padding(.bottom, 7)
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(
                MotionComponent.tabCell.enterAnimation,
                value: selected
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Floating Action Buttons

struct CopilotPillFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("CopilotIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .padding(15)
                .liquidGlassEffect(interactive: true)
        }
        .buttonStyle(.plain)
    }
}

struct ComposePillFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("ComposeIcon")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundStyle(Color.odsNeutralForeground1)
                .padding(15)
                .liquidGlassEffect(interactive: true)
        }
        .buttonStyle(.plain)
    }
}

struct CalendarAddPillFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(.calendarAdd24Regular)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundStyle(Color.odsNeutralForeground1)
                .padding(15)
                .liquidGlassEffect(interactive: true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New event")
    }
}

// MARK: - Placeholders

private struct AppsPlaceholder: View {
    @Environment(\.fluentTheme) private var fluentTheme: FluentTheme

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 48))
                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            Text("Apps")
                .font(.title2.weight(.semibold))
            Text("In progress")
                .font(.callout)
                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
