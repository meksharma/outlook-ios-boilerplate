//
//  ContentView.swift
//  OutlookBoilerplate
//

import FluentUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Outlook iOS Boilerplate")
                .font(.title2)
                .fontWeight(.semibold)

            Text("M1 verification — the button below should render in Outlook brand blue.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {}) {
                Text("Outlook-themed Button")
            }
            .buttonStyle(FluentButtonStyle(style: .accent))
        }
        .padding()
        .fluentTheme(FluentTheme.shared)
    }
}

#Preview {
    ContentView()
}
