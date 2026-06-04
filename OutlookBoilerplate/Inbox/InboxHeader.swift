//
//  InboxHeader.swift
//  OutlookBoilerplate
//
//  Holistic port of the Figma design context for the Inbox nav bar:
//    file `📱 Mail` (Eacu5ZUQ1b7uIMush8uOvg) node `17959:63941`.
//
//  Layout structure (matches the Figma node hierarchy):
//
//    InboxHeader
//      ├─ Nav title row              (height 48pt)
//      │   ├─ Large title HStack     (height 40pt, gap 12pt)
//      │   │   ├─ Avatar (32pt)
//      │   │   └─ "Inbox" text       (28pt bold, tracking 0.38)
//      │   └─ Right icons HStack     (gap 20pt)
//      │       ├─ Bell (24pt + 8pt badge dot)
//      │       └─ Search (24pt)
//      ├─ 8pt gap (Container padding-bottom)
//      └─ Accessory row              (height 32pt + 10pt bottom pad = 42pt)
//          ├─ Focused/Other switch   (height 32pt)
//          │   ├─ Outer Segments capsule (bg comm80)
//          │   ├─ Focused pill       (bg white fills 32pt, text comm70, 17pt semibold)
//          │   └─ Other pill         (transparent — outer comm80 shows through)
//          └─ Filter pill            (icon 20pt + "Filter" 15pt medium, gap 4pt)
//
//  Tokens (per Figma node 17959:63943 + `typography-1.1.yaml`):
//    - Nav bar background:           Color.odsControlNavBarBackground1 (#0F6CBD light / grey-3 dark), solid
//    - Foregrounds (icons + title):  white
//    - Inbox title:                  Title 1 (28pt bold, tracking 0.38)
//    - Pill text Focused/Other:      Body 1 Strong (17pt semibold, tracking -0.43)
//    - Pill text Filter:             15pt Medium, white
//    - Outer Segments capsule bg:    Color.odsControlSegmentBackground3 (`control/segment/background/3/rest`)
//    - Selected pill bg:             Color.odsControlSegmentBackground3SelectedRest (fills full 32pt outer)
//    - Selected text color:          Color.odsControlSegmentForeground1ActiveRest (`…/foreground/1/active-rest`)
//    - Unselected text color:        Color.odsControlSegmentForeground1 (`…/foreground/1/rest`)
//
//  Pending: brand-mark FluentBrandIcons gap only (auth-gated).
//

import FluentUI
import OutlookBackdrop
import SwiftUI

struct InboxHeader: View {
    let onAvatarTap: () -> Void

    /// Scroll position from the parent list. Drives the collapse animation:
    /// 0pt = fully expanded (accessory row visible); past `collapseThreshold` =
    /// fully collapsed (accessory row gone, title + avatar shrunk).
    var scrollOffset: CGFloat = 0

    @State private var selectedTab: FocusedTab = .focused

    /// Shared namespace for the white selection pill so it slides between
    /// "Focused" and "Other" via `matchedGeometryEffect`, matching the
    /// production segmented control animation.
    @Namespace private var pillNamespace

    /// Persisted across app launches via UserDefaults. Read in ContentView to
    /// apply `.preferredColorScheme(_:)` at the app root.
    @AppStorage("appColorScheme") private var appColorScheme: String = "light"

    enum FocusedTab: Hashable { case focused, other }

    // MARK: - Collapse math

    /// pt of scroll over which the accessory row fully collapses.
    private let collapseThreshold: CGFloat = 60

    /// 0 (at rest) → 1 (fully collapsed). Animates against scroll.
    private var collapseProgress: CGFloat {
        max(0, min(1, scrollOffset / collapseThreshold))
    }

    /// Avatar + title shrink to ~90% at full collapse, matching dev-build proportion.
    private var titleScale: CGFloat { 1 - 0.10 * collapseProgress }

    var body: some View {
        VStack(spacing: 0) {
            navTitleRow
                .frame(height: 48)

            // Container padding-bottom (Figma): collapses with accessory row.
            Color.clear.frame(height: .odsSpacingVerticalS * (1 - collapseProgress))

            accessoryRow
                .frame(height: 42 * (1 - collapseProgress), alignment: .top)
                .opacity(1 - collapseProgress)
                .clipped()
        }
        .animation(.easeOut(duration: 0.18), value: collapseProgress)
        .background(
            // Solid brand nav-bar surface (production-faithful), extended behind the
            // status bar so the blue fills the top safe area. The semantic token
            // resolves comm80 (#0F6CBD) in light and neutral background-3 in dark.
            Color.odsControlNavBarBackground1
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Nav title row (48pt)

    private var navTitleRow: some View {
        HStack(spacing: 0) {
            largeTitle
                .padding(.leading, .odsSpacingHorizontalL)

            Spacer()

            HStack(spacing: .odsSize200) {
                Button(action: presentDesignerTools) {
                    chromeIcon(.beakerSettings20Regular)
                }
                .buttonStyle(.plain)

                chromeIcon(.alert24Regular, showsBadge: true)
                chromeIcon(.search24Regular)
            }
            .padding(.trailing, .odsSpacingHorizontalL)
        }
    }

    private var largeTitle: some View {
        HStack(spacing: .odsSize120) {
            avatarMenuButton
            Text("Inbox")
                .odsTitle1()
                .foregroundStyle(.white)
        }
        .frame(height: 40)
        .scaleEffect(titleScale, anchor: .leading)
    }

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

    /// Chrome icons render at a unified 28pt × 28pt — matches production Outlook
    /// iOS nav-bar icon size. Asset catalog has 24pt bell/search + 20pt beaker
    /// variants; all scale to 28pt cleanly because they ship as vector PDFs.
    private func chromeIcon(_ icon: OutlookIcon, showsBadge: Bool = false) -> some View {
        Image(icon)
            .renderingMode(.template)
            .resizable()
            .frame(width: .odsSize280, height: .odsSize280)
            .foregroundStyle(.white)
            .overlay(alignment: .topTrailing) {
                if showsBadge {
                    Circle()
                        .fill(Color.red)
                        .frame(width: .odsSize80, height: .odsSize80)
                        .offset(x: .odsSize40, y: -2)
                }
            }
    }

    // MARK: - Accessory row (32pt content + 10pt bottom pad = 42pt)

    private var accessoryRow: some View {
        HStack {
            focusedOtherSwitch
            Spacer()
            filterPill
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.bottom, .odsSpacingVerticalMNudge)
    }

    private var focusedOtherSwitch: some View {
        HStack(spacing: 0) {
            pillButton("Focused", tab: .focused)
            pillButton("Other", tab: .other)
        }
        // Outer capsule pinned to `brandCommBlue50` (#0E4775) to match the
        // dev build empirically. The semantic chain
        // `control/segment/background/3 → brand/background/2 → commBlue70 (#115EA3)`
        // renders too light next to the nav bar's `commBlue80 (#0F6CBD)`.
        .background(Capsule().fill(ODSPrimitive.brandCommBlue50))
        .clipShape(Capsule())
        .frame(height: .odsSize320)
    }

    private func pillButton(_ title: String, tab: FocusedTab) -> some View {
        let isSelected = selectedTab == tab
        return Button(action: {
            // `.animation(_:value:)` on the parent doesn't reliably drive
            // `matchedGeometryEffect` when the curve isn't a spring — SwiftUI
            // falls back to its default matched-geometry spring (~400–500ms).
            // `withAnimation` puts the curve into the transaction so the
            // matched-geometry transition is forced to use it.
            withAnimation(.odsSegmentedControlSelection) {
                selectedTab = tab
            }
        }) {
            Text(title)
                .odsBody1Strong()
                .foregroundStyle(isSelected ? Color.odsControlSegmentForeground1ActiveRest : Color.odsControlSegmentForeground1)
                .padding(.horizontal, .odsSpacingHorizontalL)
                .frame(maxHeight: .infinity)
                .background {
                    // Only the SELECTED tab renders the white pill, but it
                    // shares geometry across both via `matchedGeometryEffect`.
                    // Result: a single white capsule slides to the active
                    // segment instead of two pills swapping in place.
                    if isSelected {
                        Capsule()
                            .fill(Color.odsControlSegmentBackground3SelectedRest)
                            .matchedGeometryEffect(id: "selectedPill", in: pillNamespace)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var filterPill: some View {
        Button(action: {}) {
            HStack(spacing: .odsSpacingHorizontalXS) {
                Image(.filter20Regular)
                    .renderingMode(.template)
                Text("Filter")
                    .odsBody2Strong()
            }
            .foregroundStyle(.white)
            .padding(.leading, .odsSpacingHorizontalS)
            .padding(.trailing, 0)
            .padding(.vertical, .odsSpacingVerticalSNudge)
        }
        .buttonStyle(.plain)
    }

}

#Preview {
    InboxHeader(onAvatarTap: {})
        .fluentTheme(FluentTheme.shared)
}

// MARK: - Native Action Sheet bridge

/// Presents a UIKit `UIAlertController(preferredStyle: .actionSheet)` from
/// SwiftUI. iOS 26 changed `.confirmationDialog` to render as a popover
/// anchored to the trigger on iPhone (Menu-style) instead of the bottom
/// action sheet our Figma calls for, so we bridge to UIKit directly.
///
/// Presents from the topmost view controller in the active window scene
/// (not from the representable's own host VC, which isn't in any visible
/// VC hierarchy — `present()` would silently fail).
struct NativeActionSheetPresenter: UIViewControllerRepresentable {
    struct Action {
        let title: String
        let style: UIAlertAction.Style
        let handler: () -> Void
    }

    @Binding var isPresented: Bool
    let title: String
    let actions: [Action]

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        guard let topVC = Self.topPresentedViewController() else { return }

        if isPresented, !(topVC is UIAlertController) {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            for action in actions {
                alert.addAction(UIAlertAction(title: action.title, style: action.style) { _ in
                    action.handler()
                    isPresented = false
                })
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                isPresented = false
            })
            // iPad / regular size class needs a source view for popover
            // adaptation; iPhone ignores this and renders as a bottom sheet.
            alert.popoverPresentationController?.sourceView = topVC.view
            alert.popoverPresentationController?.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.midY,
                width: 0, height: 0
            )
            topVC.present(alert, animated: true)
        } else if !isPresented, let alert = topVC as? UIAlertController {
            alert.dismiss(animated: true)
        }
    }

    /// Walks the active window scene to find the topmost presented VC.
    @MainActor
    private static func topPresentedViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first,
              var topVC = window.rootViewController else {
            return nil
        }
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }
}
