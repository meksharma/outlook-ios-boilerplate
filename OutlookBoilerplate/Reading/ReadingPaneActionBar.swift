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
        actionCapsule
            .padding(.horizontal, .odsSpacingHorizontalL)
            .padding(.bottom, .odsSize120)
    }

    private var actionCapsule: some View {
        HStack(spacing: 0) {
            replyPill
            Spacer(minLength: 0)
            actionIcon(.mail24Regular, showsBadge: true)
            actionIcon(.delete24Regular)
            copilotSummaryIcon
            actionIcon(.moreHorizontal24Regular)
        }
        .padding(.horizontal, .odsSpacingHorizontalS)
        .padding(.vertical, .odsSpacingVerticalSNudge)
        .frame(maxWidth: .infinity)
        .liquidGlassEffect()
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
            .foregroundStyle(Color.odsNeutralForeground1)
            .padding(.horizontal, .odsSize120)
            .padding(.vertical, .odsSpacingVerticalS)
        }
        .buttonStyle(.plain)
    }

    private func actionIcon(_ icon: OutlookIcon, showsBadge: Bool = false) -> some View {
        Button(action: {}) {
            Image(icon)
                .renderingMode(.template)
                .foregroundStyle(Color.odsNeutralForeground1)
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

    /// "Summarize" action — production source:
    /// `client-cocoa/.../ConversationActionsData.swift` lines 30-48
    /// → `textBulletListSquareSparkle24Regular`.
    private var copilotSummaryIcon: some View {
        Button(action: {}) {
            Image(.textBulletListSquareSparkle24Regular)
                .renderingMode(.template)
                .foregroundStyle(Color.odsNeutralForeground1)
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
            ReadingPaneActionBar()
        }
    }
    .fluentTheme(FluentTheme.shared)
}
