//
//  ReadingPaneActionBar.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailReadingPane/Messages/MessageVC.swift line 452
//      (production action bar — DAB / Dynamic Action Bar — assembled in
//      `updateActionBarConfiguration()`)
//    - client-cocoa/app-ios/Shared/SharedMail/Conversations/ConversationActions/ConversationActionsData.swift
//      lines 30-48 (icon names: arrowReplyAll24Regular, delete24Regular,
//      textBulletListSquareSparkle24Regular, moreHorizontal24Regular)
//
//  Known gap (documented):
//    - Production icons come from FluentIcons (private Microsoft Pod). FluentUI Apple's
//      bundled icon set doesn't include Reply All, Trash, etc. SF Symbols are used as
//      visually-similar approximations. Same approach as the Inbox header chrome.
//

import FluentUI
import SwiftUI

/// Visual-only bottom action bar for the reading pane. Per Phase 1 PRD, only the back
/// button (provided by the parent NavigationStack) is functional; every action button
/// here is a no-op.
struct ReadingPaneActionBar: View {
    var body: some View {
        HStack(spacing: 12) {
            actionCapsule
            copilotFAB
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var actionCapsule: some View {
        HStack(spacing: 0) {
            replyAllPill
            actionIcon(systemName: "envelope", showsBadge: true)
            actionIcon(systemName: "trash")
            copilotSummaryIcon
            actionIcon(systemName: "ellipsis")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
        )
    }

    /// Outlook brand blue. Production DAB action icons render in this color (Outlook's
    /// actionable-icon convention), not in `.primary` / system foreground.
    private var actionTint: Color {
        Color(uiColor: GlobalTokens.brandColor(.comm80))
    }

    private var replyAllPill: some View {
        Button(action: {}) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                Image(systemName: "arrowshape.turn.up.left.2")
                    .font(.system(size: 17, weight: .regular))
                Text("Reply All")
                    .font(.system(size: 15, weight: .regular))
            }
            .foregroundStyle(actionTint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func actionIcon(systemName: String, showsBadge: Bool = false) -> some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(actionTint)
                .frame(width: 36, height: 36)
                .overlay(alignment: .topTrailing) {
                    if showsBadge {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 7, height: 7)
                            .offset(x: -6, y: 6)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    /// "Copilot summary" action — production maps to `textBulletListSquareSparkle24Regular`
    /// from FluentIcons. Boilerplate uses our vendored Copilot SVG at small size with a "New"
    /// badge to match the production visual.
    private var copilotSummaryIcon: some View {
        Button(action: {}) {
            ZStack {
                Image("CopilotIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
            }
            .frame(width: 36, height: 36)
            .overlay(alignment: .topTrailing) {
                Text("New")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(Color.red))
                    .offset(x: 0, y: -4)
            }
        }
        .buttonStyle(.plain)
    }

    /// Floating Copilot FAB — same vendored asset as `InboxFloatingActions.swift`.
    /// In production this is the larger Copilot button outside the action capsule.
    private var copilotFAB: some View {
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
            ReadingPaneActionBar()
        }
    }
    .fluentTheme(FluentTheme.shared)
}
