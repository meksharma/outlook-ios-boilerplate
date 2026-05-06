//
//  ContentView.swift
//  OutlookBoilerplate
//

import FluentUI
import SwiftUI

struct ContentView: View {
    /// Side drawer state lives here (above TabView) so the drawer overlays the
    /// bottom tab bar — matches production (`SideBarContainerVC.toggleSidebar()`
    /// presents at app-root level, not inside a tab).
    @State private var showingSideDrawer = false

    /// Copilot sheet state lives here too — for the same reason as the side
    /// drawer (overlays tab bar) AND because the custom overlay-based sheet
    /// (`CopilotSheetOverlay`) needs to be at app root to fire keyboard focus
    /// in the same RunLoop tick as the slide animation. SwiftUI's `.sheet` API
    /// can't deliver this; see CopilotSheetOverlay.swift for the production
    /// reference and rationale.
    @State private var showingCopilotSheet = false

    var body: some View {
        ZStack {
            TabView {
                InboxView(
                    showingSideDrawer: $showingSideDrawer,
                    showingCopilotSheet: $showingCopilotSheet
                )
                .tabItem {
                    Label("Mail", systemImage: "envelope.fill")
                }

                CalendarPlaceholder()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .badge(4)

                AppsPlaceholder()
                    .tabItem {
                        Label("Apps", systemImage: "square.grid.2x2.fill")
                    }
            }

            // Drawer always present so its offset can animate.
            SideDrawerView(isShowing: $showingSideDrawer)
                .zIndex(1)

            // Copilot sheet always present (same overlay pattern as drawer).
            CopilotSheetOverlay(isShowing: $showingCopilotSheet)
                .zIndex(2)
        }
        .animation(.easeOut(duration: 0.25), value: showingSideDrawer)
        .animation(.easeOut(duration: 0.25), value: showingCopilotSheet)
        .fluentTheme(FluentTheme.shared)
    }
}

private struct CalendarPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Calendar")
                .font(.title2.weight(.semibold))
            Text("Visual-only in Phase 1.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AppsPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Apps")
                .font(.title2.weight(.semibold))
            Text("Visual-only in Phase 1.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
