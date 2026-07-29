//
//  InboxRow.swift
//  OutlookBoilerplate
//
//  Custom mail row matching the Figma spec at:
//    📱 Mail file `Eacu5ZUQ1b7uIMush8uOvg`, node `15044:143212`
//    (📱 Message list Item / Base)
//
//  Drops FluentUI `ListItem` (Decision Log #29). ListItem's API can't express:
//    - Top-aligned avatar (always centers to the title block)
//    - Top-right timestamp with body extending below it to full width
//    - Edge-to-edge separator (default is inset)
//
//  Layout (per Figma node hierarchy):
//
//      Base — HStack items-start, gap 10, padding `top:10 r:16 b:7 l:4`
//        ├─ Left — HStack items-start, gap 4
//        │   ├─ Notification rail (8 × 40, unread dot inside)
//        │   └─ Avatar (40 × 40 circular)
//        └─ Right — VStack items-start, flex:1
//            ├─ Row 1 — sender + timestamp (top-aligned, sender takes remaining)
//            ├─ Row 2 — subject + 20pt trailing icon slot
//            └─ Row 3 — body preview, 2 lines, full width
//      Divider — edge-to-edge, suppressed when `isLastInSection`
//
//  Production cross-reference:
//    - client-cocoa/.../SnippetCellStyle.swift — fromLabelFont 17pt medium
//      matches the Figma sender style.
//

import OutlookBackdrop
import SwiftUI

struct InboxRow: View {
    let thread: InboxThread
    let onTap: () -> Void

    /// Show the bottom separator. ONLY the last thread in each section
    /// renders it — visually the separator marks the section boundary, with
    /// all interior rows showing no stroke. Other rows pass `false` (default).
    var isLastInSection: Bool = false

    var body: some View {
        Button(action: onTap) {
            content
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                leftColumn
                rightColumn
            }
            .padding(.top, 10)         // Figma `pt-[10px]`
            .padding(.bottom, 7)       // Figma `pb-[7px]`
            .padding(.leading, 4)      // Figma `pl-[4px]`
            .padding(.trailing, .odsSpacingHorizontalL)  // Figma `pr-[16px]`

            delegatedOwnerInfo

            if isLastInSection {
                Divider()
            }
        }
        .background(rowBackground)
        .contentShape(Rectangle())
    }

    /// Production gives flagged rows priority over pinned rows when both states
    /// are present (`SnippetCell.updateBackgroundColors`).
    private var rowBackground: Color {
        if thread.isFlagged {
            return Color.odsStatusPresenceAway.opacity(0.12)
        }
        if thread.isPinned {
            return Color.odsBrandBackgroundTint2
        }
        return Color.odsNeutralBackground1
    }

    // MARK: - Left column (notification rail + avatar)

    private var leftColumn: some View {
        HStack(alignment: .top, spacing: 4) {
            notificationRail
            if let profilePhotoURL = thread.profilePhotoURL {
                AsyncImage(url: profilePhotoURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        InboxAvatar(size: 40, initials: thread.sender)
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else if let persona = thread.persona {
                Image(persona)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                InboxAvatar(size: 40, initials: thread.sender)
            }
        }
    }

    /// 8pt-wide × 40pt-tall column. Holds the unread dot vertically centered
    /// against the avatar (Figma: `w-[8px] h-[40px]`).
    private var notificationRail: some View {
        ZStack {
            if thread.isUnread {
                Circle()
                    .fill(Color.odsBrandForeground1)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 8, height: 40)
    }

    // MARK: - Right column (three content rows)

    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            row1
            row2
            row3
            SnippetCellActionView(meeting: thread.meeting, txp: thread.txp)
        }
    }

    /// Row 1 — optional External badge + sender + timestamp (top-aligned).
    /// Sender flexes to fill remaining width; timestamp shrinks.
    private var row1: some View {
        HStack(alignment: .top, spacing: 4) {
            if thread.isExternalSender {
                externalBadge
            }

            Text(thread.sender)
                .font(thread.isUnread ? .odsBody1Strong : .odsBody1)
                .tracking(-0.408)
                .foregroundStyle(Color.odsNeutralForeground1)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(thread.timeStamp)
                .font(.odsCaption1)
                .tracking(-0.078)
                .foregroundStyle(Color.odsNeutralForeground2)
                .lineLimit(1)
        }
    }

    /// "External" badge — 13pt regular text, gray-25 background (#F8F8F8),
    /// rounded 3pt, px:4 / py:1. Figma `02. Small / ⚪️ G. Disabled - Light`.
    /// TODO: promote `#F8F8F8` to a semantic token (closest available semantic
    /// background is too dark / too saturated; primitive scale doesn't have a
    /// neutral25 either). Hardcoded with hex until the design system adds one.
    private var externalBadge: some View {
        Text("External")
            .font(.odsCaption1)
            .tracking(-0.078)
            .foregroundStyle(Color.odsNeutralForeground2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0xF8 / 255.0, green: 0xF8 / 255.0, blue: 0xF8 / 255.0))
            )
    }

    /// Row 2 — subject + production triage/status icons.
    private var row2: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(thread.subject)
                .font(.odsBody2)
                .tracking(-0.24)
                .foregroundStyle(Color.odsNeutralForeground1)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            statusIcons
        }
    }

    @ViewBuilder
    private var statusIcons: some View {
        if thread.hasAttachment {
            statusIcon(.attach24Regular, color: .odsNeutralForeground2)
        }
        if thread.meeting != nil {
            statusIcon(.calendarEmpty24Regular, color: .odsBrandForeground1)
        }
        if thread.isPinned {
            statusIcon(.pin20Filled, color: .odsBrandForeground1)
        }
        if thread.isFlagged {
            statusIcon(.flag20Filled, color: .odsStatusDangerForeground2)
        }
        if thread.isImportant {
            Image(systemName: "exclamationmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.odsStatusDangerForeground2)
                .frame(width: 20, height: 20)
        }
        if thread.conversationCount > 1 {
            Text("\(thread.conversationCount)")
                .font(.odsCaption1)
                .foregroundStyle(Color.odsNeutralForeground2)
                .frame(minWidth: 20, minHeight: 24)
                .background(Color.odsNeutralBackground4, in: RoundedRectangle(cornerRadius: 4))
        }
    }

    private func statusIcon(_ icon: OutlookIcon, color: Color) -> some View {
        Image(icon)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(color)
            .frame(width: 20, height: 20)
    }

    /// Row 3 — body preview. Up to 2 lines, ellipsis. Full width — nothing
    /// trailing it. Figma `pt-px` ≈ 1pt top padding.
    private var row3: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if let category = thread.categories.first {
                Text(category)
                    .font(.odsCaption1)
                    .foregroundStyle(Color.odsStatusWarningForeground1)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.odsStatusWarningBackground1, in: RoundedRectangle(cornerRadius: 3))
            }

            Text(thread.preview)
                .font(.odsBody2)
                .tracking(-0.24)
                .foregroundStyle(Color.odsNeutralForeground2)
                .lineLimit(thread.meeting == nil && thread.txp == nil ? 2 : 1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 1)
    }

    @ViewBuilder
    private var delegatedOwnerInfo: some View {
        if thread.meeting?.kind == .delegated, let owner = thread.meeting?.delegateOwner {
            HStack(spacing: .odsSpacingHorizontalS) {
                Image(.info24Filled)
                    .renderingMode(.template)
                    .foregroundStyle(Color.odsBrandForeground1)

                Text("Received for \(owner).")
                    .font(.odsBody1)
                    .foregroundStyle(Color.odsNeutralForeground1)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .background(Color.odsNeutralBackground1)
        }
    }
}

/// Simple circular avatar with initials. Mirrors the Figma `Avatar` node visual
/// (gray fill, white centered initials) at a single 40pt size. Production uses
/// FluentUI's `Avatar` with a sender-derived background palette — Phase 1 keeps
/// the neutral gray + first-letter rendering; per-sender colorization is a
/// follow-up.
private struct InboxAvatar: View {
    let size: CGFloat
    let initials: String

    var body: some View {
        Circle()
            .fill(Color(red: 0x66 / 255.0, green: 0x66 / 255.0, blue: 0x66 / 255.0))
            .frame(width: size, height: size)
            .overlay {
                Text(firstInitial)
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundStyle(.white)
            }
    }

    private var firstInitial: String {
        initials.first.map { String($0).uppercased() } ?? "?"
    }
}

#Preview("States") {
    VStack(spacing: 0) {
        InboxRow(thread: sampleThreads[0], onTap: {})                            // unread, today
        InboxRow(thread: sampleThreads[1], onTap: {})                            // unread, today
        InboxRow(thread: sampleThreads[2], onTap: {}, isLastInSection: true)     // last in section
        InboxRow(thread: sampleThreads[6], onTap: {})                            // external sender
    }
    .background(Color.odsNeutralBackground1)
}
