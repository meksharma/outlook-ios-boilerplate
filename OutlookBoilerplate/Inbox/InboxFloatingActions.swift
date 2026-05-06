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
//  DAB = Dynamic Action Bar (Outlook iOS subsystem name). The Compose / Copilot FABs are
//  managed by DAB in production; for the boilerplate we render them statically.
//

import FluentUI
import SwiftUI

struct InboxFloatingActions: View {
    var body: some View {
        HStack(spacing: 12) {
            composeButton
            copilotButton
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var composeButton: some View {
        Button(action: {}) {
            Image("ComposeIcon")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color(uiColor: GlobalTokens.brandColor(.comm80)))
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private var copilotButton: some View {
        Button(action: {}) {
            Image("CopilotIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
                )
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
                InboxFloatingActions()
            }
        }
    }
    .fluentTheme(FluentTheme.shared)
}
