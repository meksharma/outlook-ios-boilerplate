//
//  InboxHeader.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/MailAvatarMenuLargeTitleView.swift
//      (production header — confirms 74pt height, custom UIView pattern, avatar-as-menu-trigger,
//      bar buttons array on trailing). Production also bypasses FluentUI's NavigationBar in favor
//      of a custom layout, so a custom SwiftUI implementation here matches production's pattern.
//    - fluentui-apple/Sources/FluentUI_common/Core/Theme/Tokens/GlobalTokens.swift lines 19–34
//      (brand color tokens — `.comm80` is Outlook's communication blue)
//
//  Known gap (documented):
//    - Bell, search, hamburger, and filter chrome icons currently use SF Symbols rather than
//      FluentIcons assets. Production uses FluentIcons via the FluentIcons Pod (private
//      Microsoft repo); FluentUI Apple's bundled icon set doesn't include these. Will revisit
//      with a future asset-vendoring pass.
//

import FluentUI
import SwiftUI

struct InboxHeader: View {
    let onAvatarTap: () -> Void
    @State private var selectedTab: FocusedTab = .focused

    enum FocusedTab: Hashable { case focused, other }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            tabsAndFilter
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            // Brand background extends into the top safe area so the status-bar text sits on
            // the brand color, but header *content* respects the safe area and doesn't slide
            // under the dynamic island.
            brandBackground.ignoresSafeArea(edges: .top)
        )
    }

    private var topBar: some View {
        HStack(spacing: 16) {
            avatarMenuButton
            Text("Inbox")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
            Spacer()
            chromeIcon(systemName: "bell", showsBadge: true)
            chromeIcon(systemName: "magnifyingglass")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var tabsAndFilter: some View {
        HStack {
            HStack(spacing: 0) {
                tabButton("Focused", tab: .focused)
                tabButton("Other", tab: .other)
            }
            .background(Capsule().fill(Color.white.opacity(0.18)))
            .clipShape(Capsule())

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 14, weight: .semibold))
                Text("Filter")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
    }

    private func tabButton(_ title: String, tab: FocusedTab) -> some View {
        let isSelected = selectedTab == tab
        return Button(action: { selectedTab = tab }) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? brandTextOnWhite : .white)
                .frame(minWidth: 80)
                .padding(.vertical, 8)
                .background(Capsule().fill(isSelected ? Color.white : Color.clear))
        }
        .buttonStyle(.plain)
    }

    /// Avatar in the leading position is the side-drawer trigger in production
    /// (see `MailAvatarMenuLargeTitleView.swift:228` — `handleNavigationButtonTapped`).
    private var avatarMenuButton: some View {
        Button(action: onAvatarTap) {
            Avatar(
                style: .default,
                size: .size32,
                primaryText: "Jay Cho"
            )
        }
        .buttonStyle(.plain)
    }

    private func chromeIcon(systemName: String, showsBadge: Bool = false) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(.white)
            .overlay(alignment: .topTrailing) {
                if showsBadge {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -2)
                }
            }
    }

    /// Outlook brand blue. Sourced from FluentUI Apple's `GlobalTokens.brandColor(.comm80)`.
    /// Same value production Outlook iOS uses (`client-cocoa` pins `MicrosoftFluentUI '0.35.0'`).
    private var brandBackground: Color {
        Color(uiColor: GlobalTokens.brandColor(.comm80))
    }

    /// Brand color rendered as a SwiftUI `Color` for foreground use on white pill backgrounds.
    private var brandTextOnWhite: Color {
        Color(uiColor: GlobalTokens.brandColor(.comm80))
    }
}

#Preview {
    InboxHeader(onAvatarTap: {})
        .fluentTheme(FluentTheme.shared)
}
