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
        HStack(spacing: .odsSize120) {
            actionCapsule
            copilotFAB
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.bottom, .odsSize120)
    }

    private var actionCapsule: some View {
        HStack(spacing: 0) {
            toolbarIcon(.attach24Regular)
            Spacer(minLength: 0)
            toolbarIcon(.camera24Regular)
            Spacer(minLength: 0)
            toolbarIcon(.penSparkle24Regular)
            Spacer(minLength: 0)
            toolbarIcon(.textEditStyle24Regular)
            Spacer(minLength: 0)
            toolbarIcon(.calendarEmpty24Regular)
            Spacer(minLength: 0)
            toolbarIcon(.moreHorizontal24Regular)
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, .odsSpacingVerticalSNudge)
        .liquidGlassEffect()
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
    }

    private func toolbarIcon(_ icon: OutlookIcon) -> some View {
        Button(action: {}) {
            Image(icon)
                .renderingMode(.template)
                .foregroundStyle(Color.odsNeutralForeground1)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }

    /// Floating Copilot FAB — same vendored asset as `InboxFloatingActions.swift`.
    /// Sits as a sibling of the toolbar capsule (matches dev build); production
    /// routes Copilot through ComposeCopilotPolarisVC. Frame matches the DAB
    /// height (36pt icon + 6pt × 2 vertical padding = 48pt) so the two surfaces
    /// align flush along the bottom row.
    private var copilotFAB: some View {
        Button(action: {}) {
            Image("CopilotIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: .odsSize280, height: .odsSize280)
                .frame(width: 48, height: 48)
                .liquidGlassEffect()
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
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
