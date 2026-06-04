//
//  ComposeToolbar.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailCompose/Compose/Components/GUI/ToolBar/DAB/ComposeDABVC.swift
//      (production toolbar — DAB / Dynamic Action Bar with `ComposeToolbarItem` enum)
//    - client-cocoa/app-ios/Shared/SharedCompose/Editor/Toolbar/Shared/ComposeToolbarItem.swift
//      lines 10-26 (toolbar item enum: .attachment, .camera, .richText, .scheduleSend, .copilot, .messageOptions)
//
//  Pending: brand-mark FluentBrandIcons gap only (auth-gated) — vendored
//  `CopilotIcon` stays as the stand-in for the Copilot ribbon.
//

import FluentUI
import OutlookBackdrop
import SwiftUI

/// Visual-only bottom toolbar for the compose sheet. Per Phase 1 spec, every button
/// here is a no-op — typing in the To/Subject/Body fields above it works because
/// SwiftUI TextField is free, but no toolbar action triggers anything.
struct ComposeToolbar: View {
    var body: some View {
        HStack(spacing: 0) {
            toolbarIcon(.attach24Regular)
            toolbarIcon(.camera24Regular)
            copilotInlineIcon
            toolbarIcon(.textFont24Regular)
            toolbarIcon(.calendarClock24Regular)
            Spacer(minLength: 0)
            toolbarIcon(.moreHorizontal24Regular)
        }
        .padding(.horizontal, .odsSpacingHorizontalS)
        .padding(.vertical, .odsSpacingVerticalSNudge)
        .glassEffectCompat()
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.bottom, .odsSize120)
    }

    private func toolbarIcon(_ icon: OutlookIcon) -> some View {
        Button(action: {}) {
            Image(icon)
                .renderingMode(.template)
                .foregroundStyle(ODSPrimitive.brandCommBlue80)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }

    /// Inline Copilot affordance — production routes this through ComposeCopilotPolarisVC.
    /// Visually a small Copilot ribbon icon in the toolbar.
    private var copilotInlineIcon: some View {
        Button(action: {}) {
            Image("CopilotIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .systemGray6)
        VStack {
            Spacer()
            ComposeToolbar()
        }
    }
    .fluentTheme(FluentTheme.shared)
}
