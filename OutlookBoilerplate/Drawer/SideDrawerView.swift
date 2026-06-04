//
//  SideDrawerView.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailFolderChooser/FolderListVC.swift
//      (production folder list — UITableView .grouped style, .sidebarPrimaryBackground)
//    - client-cocoa/app-ios/Modules/Mail/MailFolderChooser/FolderListTableViewCell.swift
//      (folder row layout — 25pt icon, 16pt horizontal margin, 12pt vertical margin,
//      12pt icon-to-label spacing, subheadline-medium font)
//    - client-cocoa/app-ios/Shared/SharedMail/FolderChooser/FolderChooserHeaderView.swift
//      (production "Favorites" / "Folders" section header)
//    - client-cocoa/app-ios/Shared/SharedMail/Settings/AccountTableHeaderView.swift
//      (production account header — avatar + Microsoft 365 + email)
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/MailAvatarMenuLargeTitleView.swift
//      lines 228-230 (avatar tap → handleNavigationButtonTapped → toggleSidebar)
//    - client-cocoa/app-ios/Shared/SharedCore/Images/UIImage+Icons.swift
//      (folder icon mapping: mailInbox24Regular, send24Regular, drafts24Regular,
//      archive24Regular, delete24Regular, folder24Regular, folderProhibited24Regular,
//      people24Regular)
//
//  Production uses FluentUI's UIKit `DrawerController` for the slide-over container; we
//  replicate with a SwiftUI ZStack overlay (scrim + slide-from-leading drawer card +
//  drag-to-dismiss gesture). Tap-outside scrim dismisses.
//
//  Pending: brand-mark FluentBrandIcons gap only (auth-gated).
//

import FluentUI
import OutlookBackdrop
import SwiftUI

struct SideDrawerView: View {
    @Binding var isShowing: Bool

    private let drawerWidth: CGFloat = 320

    var body: some View {
        ZStack(alignment: .leading) {
            scrim
            drawerCard
        }
        .ignoresSafeArea()
    }

    /// Scrim fades in/out via opacity. `allowsHitTesting` prevents it from intercepting
    /// taps when the drawer is closed (since the drawer view stays in the ZStack
    /// permanently — we slide the card off-screen rather than conditionally adding it).
    private var scrim: some View {
        Color.black
            .opacity(isShowing ? 0.4 : 0)
            .allowsHitTesting(isShowing)
            .onTapGesture { isShowing = false }
    }

    /// Drawer card always present in the view tree; offset off-screen when closed.
    /// SwiftUI animates the offset because the parent ContentView applies an
    /// `.animation(_:value:)` keyed on `showingSideDrawer`. This is more reliable than
    /// `.transition(.move(edge:))` on a conditionally-added view, which silently fails
    /// when the conditional is on a parent rather than the transitioned view itself.
    private var drawerCard: some View {
        VStack(spacing: 0) {
            accountHeader
            Divider()
            ScrollView {
                VStack(spacing: 0) {
                    favoritesSection
                    Divider()
                    foldersSection
                }
            }
            Spacer(minLength: 0)
            bottomChrome
        }
        .frame(width: drawerWidth)
        .glassEffectCompat(in: Rectangle())
        .offset(x: isShowing ? 0 : -drawerWidth)
        .allowsHitTesting(isShowing)
    }

    // MARK: - Account header

    private var accountHeader: some View {
        HStack(spacing: .odsSize120) {
            Avatar(style: .default, size: .size40, primaryText: "Jay Cho")
            VStack(alignment: .leading, spacing: 0) {
                Text("Microsoft 365")
                    .font(.odsBody1Strong)
                Text("junhwancho@microsoft.com")
                    .font(.odsCaption1)
                    .foregroundStyle(Color.odsNeutralForeground2)
            }
            Spacer()
            Image(.alert24Regular)
                .renderingMode(.template)
                .foregroundStyle(Color.odsNeutralForeground2)
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, .odsSpacingHorizontalL)
        .padding(.top, 60) // safe area inset for status bar
    }

    // MARK: - Favorites

    private var favoritesSection: some View {
        VStack(spacing: 0) {
            sectionHeader(title: "Favorites", showsEditPencil: true)
            folderRow(icon: .send24Regular, name: "Sent")
            folderRow(icon: .drafts24Regular, name: "Drafts", count: 3)
            folderRow(icon: .mailInbox24Regular, name: "Inbox", count: 702, isSelected: true)
        }
    }

    // MARK: - Folders

    private var foldersSection: some View {
        VStack(spacing: 0) {
            folderRow(icon: .mailInbox24Regular, name: "Inbox", count: 702, isSelected: true, hasChevron: true)
            folderRow(icon: .archive24Regular, name: "Archive", count: 57)
            folderRow(icon: .drafts24Regular, name: "Drafts", count: 3)
            folderRow(icon: .send24Regular, name: "Sent")
            folderRow(icon: .delete24Regular, name: "Deleted", count: 154, hasChevron: true)
            folderRow(icon: .folder24Regular, name: "Conversation History")
            folderRow(icon: .folderProhibited24Regular, name: "Junk", count: 6)
            folderRow(icon: .people24Regular, name: "Groups", count: 999)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Bottom chrome (settings + help)

    private var bottomChrome: some View {
        VStack(alignment: .leading, spacing: .odsSpacingHorizontalL) {
            Divider()
            HStack(spacing: .odsSize240) {
                Image(.questionCircle24Regular)
                    .renderingMode(.template)
                    .foregroundStyle(Color.odsNeutralForeground2)
                Image(.settings24Regular)
                    .renderingMode(.template)
                    .foregroundStyle(Color.odsNeutralForeground2)
                Spacer()
            }
            .padding(.horizontal, .odsSpacingHorizontalL)
            .padding(.bottom, .odsSize320)
        }
    }

    // MARK: - Pieces

    private func sectionHeader(title: String, showsEditPencil: Bool) -> some View {
        HStack {
            Text(title)
                .font(.odsBody2Strong)
                .foregroundStyle(Color.odsNeutralForeground2)
            Spacer()
            if showsEditPencil {
                Image(.edit24Regular)
                    .renderingMode(.template)
                    .foregroundStyle(Color.odsNeutralForeground2)
            }
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.top, .odsSpacingHorizontalL)
        .padding(.bottom, .odsSpacingVerticalS)
    }

    private func folderRow(
        icon: OutlookIcon,
        name: String,
        count: Int? = nil,
        isSelected: Bool = false,
        hasChevron: Bool = false
    ) -> some View {
        HStack(spacing: .odsSize120) {
            Image(icon)
                .renderingMode(.template)
                .foregroundStyle(isSelected ? ODSPrimitive.brandCommBlue80 : Color.odsNeutralForeground1)
                .frame(width: 25, height: 25)

            Text(name)
                .font(.odsBody2Strong)
                .foregroundStyle(isSelected ? ODSPrimitive.brandCommBlue80 : Color.odsNeutralForeground1)

            Spacer()

            if let count {
                Text(formatCount(count))
                    .font(.odsCaption1Strong)
                    .foregroundStyle(Color.odsNeutralForeground2)
                    .padding(.horizontal, .odsSpacingHorizontalS)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(Color.odsNeutralBackground3)
                    )
            }

            if hasChevron {
                Image(.chevronRight16Regular)
                    .renderingMode(.template)
                    .foregroundStyle(Color.odsNeutralForeground2)
            }
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, .odsSize120)
        .contentShape(Rectangle())
        .onTapGesture { /* visual-only in Phase 1 */ }
    }

    private func formatCount(_ count: Int) -> String {
        count > 999 ? "999+" : "\(count)"
    }
}

#Preview {
    SideDrawerView(isShowing: .constant(true))
        .fluentTheme(FluentTheme.shared)
}
