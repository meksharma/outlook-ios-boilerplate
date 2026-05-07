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
//  Known gap (documented):
//    - Production icons (paperclip, camera, format, clock, more) come from FluentIcons
//      private Microsoft Pod. SF Symbols stand in. Same approach as Inbox/Reading-pane chrome.
//

import FluentUI
import SwiftUI

/// Visual-only bottom toolbar for the compose sheet. Per Phase 1 spec, every button
/// here is a no-op — typing in the To/Subject/Body fields above it works because
/// SwiftUI TextField is free, but no toolbar action triggers anything.
struct ComposeToolbar: View {
    @Environment(\.fluentTheme) private var fluentTheme: FluentTheme

    var body: some View {
        HStack(spacing: 0) {
            toolbarIcon(systemName: "paperclip")
            toolbarIcon(systemName: "camera")
            copilotInlineIcon
            toolbarIcon(systemName: "textformat")
            toolbarIcon(systemName: "calendar.badge.clock")
            Spacer(minLength: 0)
            toolbarIcon(systemName: "ellipsis")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(fluentTheme.swiftUIColor(.background1))
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    /// Outlook brand blue. Production DAB toolbar icons (across compose, reading pane,
    /// inbox chrome) render in this color, not in `.primary`.
    private var actionTint: Color {
        Color(uiColor: GlobalTokens.brandColor(.comm80))
    }

    private func toolbarIcon(systemName: String) -> some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(actionTint)
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
