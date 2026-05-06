//
//  ContentView.swift
//  OutlookBoilerplate
//

import FluentUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            InboxView()
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
