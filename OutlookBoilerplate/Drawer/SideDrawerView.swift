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
//  Known gap (documented):
//    - Folder icons use SF Symbols because production icons come from FluentIcons (private
//      Microsoft Pod we don't pull). Same approach as Inbox / Reading-pane / Compose chrome.
//

import FluentUI
import SwiftUI

struct SideDrawerView: View {
    @Binding var isShowing: Bool

    @Environment(\.fluentTheme) private var fluentTheme: FluentTheme

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
        .background(fluentTheme.swiftUIColor(.background1))
        .offset(x: isShowing ? 0 : -drawerWidth)
        .allowsHitTesting(isShowing)
    }

    // MARK: - Account header

    private var accountHeader: some View {
        HStack(spacing: 12) {
            Avatar(style: .default, size: .size40, primaryText: "Jay Cho")
            VStack(alignment: .leading, spacing: 0) {
                Text("Microsoft 365")
                    .font(.system(size: 17, weight: .semibold))
                Text("junhwancho@microsoft.com")
                    .font(.system(size: 13))
                    .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            }
            Spacer()
            Image(systemName: "alarm")
                .font(.system(size: 17))
                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .padding(.top, 60) // safe area inset for status bar
    }

    // MARK: - Favorites

    private var favoritesSection: some View {
        VStack(spacing: 0) {
            sectionHeader(title: "Favorites", showsEditPencil: true)
            folderRow(icon: "paperplane", name: "Sent")
            folderRow(icon: "pencil.and.list.clipboard", name: "Drafts", count: 3)
            folderRow(icon: "tray", name: "Inbox", count: 702, isSelected: true)
        }
    }

    // MARK: - Folders

    private var foldersSection: some View {
        VStack(spacing: 0) {
            folderRow(icon: "tray", name: "Inbox", count: 702, isSelected: true, hasChevron: true)
            folderRow(icon: "archivebox", name: "Archive", count: 57)
            folderRow(icon: "pencil.and.list.clipboard", name: "Drafts", count: 3)
            folderRow(icon: "paperplane", name: "Sent")
            folderRow(icon: "trash", name: "Deleted", count: 154, hasChevron: true)
            folderRow(icon: "folder", name: "Conversation History")
            folderRow(icon: "trash.slash", name: "Junk", count: 6)
            folderRow(icon: "person.2", name: "Groups", count: 999)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Bottom chrome (settings + help)

    private var bottomChrome: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            HStack(spacing: 24) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
                Image(systemName: "gearshape")
                    .font(.system(size: 22))
                    .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Pieces

    private func sectionHeader(title: String, showsEditPencil: Bool) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            Spacer()
            if showsEditPencil {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 15))
                    .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func folderRow(
        icon: String,
        name: String,
        count: Int? = nil,
        isSelected: Bool = false,
        hasChevron: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(isSelected ? brand : fluentTheme.swiftUIColor(.foreground1))
                .frame(width: 25, height: 25)

            Text(name)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isSelected ? brand : fluentTheme.swiftUIColor(.foreground1))

            Spacer()

            if let count {
                Text(formatCount(count))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(fluentTheme.swiftUIColor(.background3))
                    )
            }

            if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { /* visual-only in Phase 1 */ }
    }

    private var brand: Color {
        Color(uiColor: GlobalTokens.brandColor(.comm80))
    }

    private func formatCount(_ count: Int) -> String {
        count > 999 ? "999+" : "\(count)"
    }
}

#Preview {
    SideDrawerView(isShowing: .constant(true))
        .fluentTheme(FluentTheme.shared)
}
