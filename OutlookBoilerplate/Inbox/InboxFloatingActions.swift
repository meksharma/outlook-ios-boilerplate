//
//  InboxFloatingActions.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Shared/SharedMail/DAB/ComposeButton.swift
//      (production Compose FAB; uses `.compose28Regular` icon from FluentIcons Pod)
//    - client-cocoa/app-ios/Shared/SharedIntelligence/UI/DAB/CopilotButtonContainer.swift
//      (production Copilot FAB; uses `.copilot28Color` icon from FluentBrandIcons Pod, plus a
//      Lottie animation `copilot_icon_thinking.json` for thinking state)
//
//  Vendored assets (in `Assets.xcassets/OutlookIcons/`):
//    - ComposeIcon.imageset (from client-cocoa Common.xcassets/Quick Actions/quick-action-compose.imageset)
//    - CopilotIcon.imageset (from client-cocoa Common.xcassets/M365Copilot/ChatCopilotHighResolutionIcon.imageset)
//
//  DAB = Dynamic Action Bar (Outlook iOS subsystem name).
//  ComposeFAB renders above the bottom bar as an overlay; CopilotFAB lives
//  inside `CustomBottomBar` alongside the tab pill.
//

import FluentUI
import OutlookBackdrop
import SwiftUI

/// Standalone Compose FAB. Used as an overlay above the bottom bar.
struct ComposeFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("ComposeIcon")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundStyle(ODSPrimitive.brandCommBlue80)
                .frame(width: 62, height: 62)
                .glassEffectCompat(interactive: true, tint: Color(light: .white, dark: .clear), in: Circle())
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

/// Standalone Copilot FAB. Lives inside the bottom bar alongside the tab pill.
struct CopilotFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("CopilotIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .frame(width: 62, height: 62)
                .glassEffectCompat(interactive: true, tint: Color(light: .white, dark: .clear), in: Circle())
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .systemGray6)
        VStack {
            Spacer()
            HStack {
                Spacer()
                ComposeFAB(action: {})
                CopilotFAB(action: {})
            }
            .padding()
        }
    }
    .fluentTheme(FluentTheme.shared)
}
