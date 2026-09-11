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
    let onSearchTap: () -> Void

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

    /// Drives the Designer Tools bottom sheet. Re-introduced after we moved
    /// off the imperative `UIAlertController(.actionSheet)` path — iOS 26
    /// system action sheets render as a centered popover, not the multi-row
    /// glass-pill panel we want (see `DesignerToolsSheet` for the Figma-style
    /// implementation matching iOS Focus-modes visual language).
    @State private var showingBeakerSheet: Bool = false

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
                Button(action: { showingBeakerSheet = true }) {
                    chromeIcon(.beakerSettings20Regular)
                }
                .buttonStyle(.plain)
                .hotspotTarget()
                .sheet(isPresented: $showingBeakerSheet) {
                    DesignerToolsSheet(appColorScheme: $appColorScheme)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        // Default sheet background — letting the system
                        // render its native glass material so the pill's
                        // glass effect has non-uniform content to refract.
                }

                chromeIcon(.alert24Regular, showsBadge: true)
                Button(action: onSearchTap) {
                    chromeIcon(.search24Regular)
                }
                .buttonStyle(.plain)
                .hotspotTarget()
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
        // Outer capsule is mode-adaptive. Light is empirically pinned to
        // `brandCommBlue50` (#0E4775) — the semantic chain
        // `control/segment/background/3 → brand/background/2 → commBlue70 (#115EA3)`
        // renders too light next to the nav bar's `commBlue80 (#0F6CBD)`.
        // Dark resolves to `odsNeutralBackground2` (neutralGrey12 #1F1F1F); the
        // static primitive can't adapt, so it stayed blue in dark before this.
        .background(Capsule().fill(
            odsDynamic(
                light: ODSPrimitive.brandCommBlue50,
                dark: Color.odsNeutralBackground2,
                iosElevated: Color.odsNeutralBackground2,
                lightHCC: ODSPrimitive.brandCommBlue50,
                darkHCC: Color.odsNeutralBackground2
            )
        ))
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
        .hotspotTarget()
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
        .hotspotTarget()
    }

}

#Preview {
    InboxHeader(onAvatarTap: {}, onSearchTap: {})
        .fluentTheme(FluentTheme.shared)
}

// MARK: - Designer Tools Sheet

/// Bottom sheet panel of designer-debug controls. Visual language follows
/// iOS Focus-modes selector (Image #22 reference): full-width glass
/// capsules, leading icon + title + description, subtle blue tint on the
/// active row. Replaces what was an action sheet — iOS 26 system action
/// sheets are centered popovers, not the multi-row panel we need.
struct DesignerToolsSheet: View {
    @Binding var appColorScheme: String

    @Environment(\.dismiss) private var dismiss

    /// Production vs Beta build variant. Persisted + auto-synced. No consumer
    /// yet — the per-variant tab content tree is still to be wired.
    @AppStorage("appVariant") private var appVariant: String = "production"

    /// Routes Copilot prompts through the local Work IQ bridge when enabled.
    /// Off by default so the boilerplate retains its clone-and-run behavior.
    @AppStorage("workIQEnabled") private var workIQEnabled: Bool = false

    /// Flashes every interactive hit region after a tap misses all targets.
    @AppStorage("hotspotHintsEnabled") private var hotspotHintsEnabled: Bool = false

    /// Enables the opt-in Card Framework prototype in the Reading Pane.
    @AppStorage("cardFrameworkEnabled") private var cardFrameworkEnabled: Bool = false

    /// Selects the visual treatment for cards shown in the Reading Pane.
    @AppStorage("cardFrameworkTheme") private var cardFrameworkTheme: String = OutlookCardTheme.neutral.rawValue

    private var isDarkMode: Bool { appColorScheme == "dark" }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Environment switches use native segmented controls: binary,
                // mutually-exclusive, *named* choices read clearest side-by-side.
                // System control auto-adapts to the sheet's forced light/dark.
                segmentedSection(title: "App Variant", selection: $appVariant) {
                    Text("Production").tag("production")
                    Text("Beta").tag("beta")
                }

                // `GlassEffectContainer` is iOS 26's intended host for views
                // using `.glassEffect`. It coordinates the glass rendering pass,
                // morphing/blending neighboring glass shapes and giving each
                // one the backdrop sample it needs to actually refract.
                GlassEffectContainerCompat {
                    VStack(spacing: 12) {
                        ControlPill(
                            icon: isDarkMode ? "moon.fill" : "sun.max.fill",
                            title: "Dark Mode",
                            description: isDarkMode ? "On" : "Off",
                            isActive: isDarkMode
                        ) {
                            appColorScheme = isDarkMode ? "light" : "dark"
                        }

                        ControlPill(
                            icon: "sparkles",
                            title: "Work IQ",
                            description: workIQEnabled ? "Live inbox + Copilot context" : "Off",
                            isActive: workIQEnabled
                        ) {
                            workIQEnabled.toggle()
                        }

                        ControlPill(
                            icon: "rectangle.stack.fill",
                            title: "Card Framework",
                            description: cardFrameworkEnabled ? "On" : "Off",
                            isActive: cardFrameworkEnabled
                        ) {
                            cardFrameworkEnabled.toggle()
                        }

                        if cardFrameworkEnabled {
                            segmentedSection(title: "Card Theme", selection: $cardFrameworkTheme) {
                                Text("Blue").tag(OutlookCardTheme.brand.rawValue)
                                Text("Neutral").tag(OutlookCardTheme.neutral.rawValue)
                            }
                            .padding(.horizontal, 8)
                        }

                        ControlPill(
                            icon: "rectangle.dashed",
                            title: "Hotspot Hints",
                            description: hotspotHintsEnabled ? "On" : "Off",
                            isActive: hotspotHintsEnabled
                        ) {
                            hotspotHintsEnabled.toggle()
                        }

                        // Opens the shared bug-report form. Dismiss this sheet
                        // first, then post the request after the dismiss
                        // animation so the screenshot captures the underlying
                        // screen — not this panel.
                        ControlPill(
                            icon: "ladybug.fill",
                            title: "Report a Bug",
                            description: "Screenshot + details"
                        ) {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                NotificationCenter.default.post(name: .requestBugReport, object: nil)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
    }

    /// Labeled native segmented control — a caption above a `.segmented` Picker.
    @ViewBuilder
    private func segmentedSection(
        title: String,
        selection: Binding<String>,
        @ViewBuilder _ segments: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            Picker(title, selection: selection, content: segments)
                .pickerStyle(.segmented)
        }
    }
}

/// Single glass-capsule control row matching iOS Focus-modes pill aesthetic.
/// Leading SF Symbol, title, optional description, active-state blue tint.
///
/// The glass treatment is applied via `glassEffectCompat(tint:in:)` — the
/// tint parameter drives both the inactive (subtle white) and active
/// (saturated blue) appearance directly on the glass layer. Stacking a
/// `Capsule().fill(...)` underneath would compete with the glass and the
/// sheet's `.thickMaterial` background, washing the effect out.
struct ControlPill: View {
    let icon: String
    let title: String
    var description: String? = nil
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    if let description {
                        Text(description)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .glassEffectCompat(
                interactive: true,
                // Active state uses the muted `Color.blue.opacity(0.5)` we
                // had earlier — survives the glass pass with a softer,
                // more Control-Center-like blue than `Color.accentColor`
                // at full opacity. Inactive uses an adaptive primary tint
                // (dark on light, light on dark) so the pill stays visible
                // in either app color scheme.
                tint: isActive ? Color.blue.opacity(0.5) : Color.primary.opacity(0.1),
                in: Capsule()
            )
            // Make the whole pill tappable, not just the icon + text. Without
            // this, `.buttonStyle(.plain)` only hit-tests the opaque label
            // content, so taps in the empty trailing area (and the padding)
            // fall through. The shape matches the glass Capsule.
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
