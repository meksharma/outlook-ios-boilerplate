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
//  Pending: brand-mark FluentBrandIcons gap only (auth-gated) — vendored
//  `CopilotIcon` stays as the stand-in for the Copilot ribbon.
//

import FluentUI
import OutlookBackdrop
import SwiftUI

/// Visual-only bottom action bar for the reading pane. Per Phase 1 PRD, only the back
/// button (provided by the parent NavigationStack) is functional; every action button
/// here is a no-op.
struct ReadingPaneActionBar: View {
    var body: some View {
        HStack(spacing: .odsSize120) {
            actionCapsule
            copilotFAB
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.bottom, .odsSpacingVerticalS)
    }

    private var actionCapsule: some View {
        HStack(spacing: 0) {
            replyPill
            actionIcon(.mail24Regular, showsBadge: true)
            actionIcon(.delete24Regular)
            copilotSummaryIcon
            actionIcon(.moreHorizontal24Regular)
        }
        .padding(.horizontal, .odsSpacingHorizontalS)
        .padding(.vertical, .odsSpacingVerticalSNudge)
        .glassEffectCompat()
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)
    }

    /// Default action is "Reply" (single arrow) to match production WIP. Chevron
    /// hint indicates the user can swap to Reply All / Reply via dropdown.
    private var replyPill: some View {
        Button(action: {}) {
            HStack(spacing: .odsSpacingHorizontalXS) {
                Image(.chevronDown16Regular)
                    .renderingMode(.template)
                Image(.arrowReply24Regular)
                    .renderingMode(.template)
                Text("Reply")
                    .font(.odsBody2)
            }
            .foregroundStyle(ODSPrimitive.brandCommBlue80)
            .padding(.horizontal, .odsSize120)
            .padding(.vertical, .odsSpacingVerticalS)
        }
        .buttonStyle(.plain)
    }

    private func actionIcon(_ icon: OutlookIcon, showsBadge: Bool = false) -> some View {
        Button(action: {}) {
            Image(icon)
                .renderingMode(.template)
                .foregroundStyle(ODSPrimitive.brandCommBlue80)
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
                    .padding(.horizontal, .odsSpacingHorizontalXS)
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
                .frame(width: .odsSize320, height: .odsSize320)
                .frame(width: 56, height: 56)
                .glassEffectCompat(in: RoundedRectangle(cornerRadius: 14))
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
            ReadingPaneActionBar()
        }
    }
    .fluentTheme(FluentTheme.shared)
}
