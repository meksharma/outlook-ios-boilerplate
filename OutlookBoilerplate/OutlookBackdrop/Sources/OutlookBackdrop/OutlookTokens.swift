import FluentUI
import SwiftUI

// Outlook design tokens for iOS, mirroring the canonical Foundation files in
// outlook-design-system/ods/ios/Foundations/. Three side-by-side namespaces:
//
//   - Font  — composed text styles (Title 1, Body 1 Strong, …)
//   - Color — alias tokens that route through FluentTheme.shared
//   - CGFloat — size primitives, spacing aliases, stroke widths, corner radii
//
// Naming pattern: `ods{Name}` (e.g. `.odsTitle1`, `.odsBrandBackground1`).
// Designers consume these directly in SwiftUI; behind the scenes they resolve
// to fluentui-apple 0.35.0 values.

// MARK: - Font (Layer 2 — composed text styles)
//
// Sourced from `outlook-design-system/ods/ios/Foundations/typography-1.1.yaml`
// (the canonical Variables-file extraction). Every *Strong style resolves to
// `Weight/Exceptions/500&600` which on iOS is **Semibold**. Earlier helper
// drafts ran on a misread (treating 510 as a "snap to nearest" interpolation);
// the Variables file unambiguously says Semibold for all *Strong styles on iOS.
public extension Font {
    static let odsTitle1 = Font.system(size: 28, weight: .bold)
    static let odsTitle2 = Font.system(size: 22, weight: .semibold)
    static let odsTitle3 = Font.system(size: 20, weight: .semibold)
    static let odsBody1 = Font.system(size: 17, weight: .regular)
    static let odsBody1Strong = Font.system(size: 17, weight: .semibold)
    // Headline = production Outlook iOS Mail body weight (`OLMTextStyle.headline`,
    // `client-cocoa/.../UIFont+Outlook.swift`). Sits between Font Size/300 (15) and
    // /400 (17) in the Figma Variables ramp — no Variables equivalent. Ship as a
    // production-faithful escape hatch so Mail row / Compose body / Reading sender
    // match WIP without forcing a 16↔17 drift.
    static let odsHeadline = Font.system(size: 16, weight: .regular)
    static let odsHeadlineStrong = Font.system(size: 16, weight: .semibold)
    static let odsBody2 = Font.system(size: 15, weight: .regular)
    static let odsBody2Strong = Font.system(size: 15, weight: .semibold)
    static let odsCaption1 = Font.system(size: 13, weight: .regular)
    static let odsCaption1Strong = Font.system(size: 13, weight: .semibold)
    static let odsCaption2 = Font.system(size: 12, weight: .regular)
}

// MARK: - Font / One-offs (not in the canonical type ramp)
//
// Styles sourced from production Outlook iOS code that DO NOT correspond to a
// named style in the Figma 🎨 Outlook Mobile Variables file. Each entry must
// cite its production source in the comment. Keep this list minimal — when
// production and Figma drift, Foundation typography-1.1.yaml's named styles
// are the canonical answer. One-offs exist for cases where matching the WIP
// build's runtime rendering matters more than design-spec adherence.
//
// Documented under `oneOffs:` in `typography-1.1.yaml`.
public extension Font {
    /// Mail list section header ("Yesterday" / "This Week" / "Last Week").
    /// Production source: `client-cocoa/.../ListHeaderView.swift:11`
    ///     `.outlookFont(withTextStyle: .subheadline, weight: .medium)`
    /// → `.subheadline` resolves to 15pt per `UIFont+Outlook.swift:46`.
    /// Sits between Body 2 (Regular/400) and Body 2 Strong (Semibold/600) on
    /// the Figma ramp — no exact named style equivalent.
    static let odsMailListSectionHeader = Font.system(size: 15, weight: .medium)

    /// Mail row sender name (e.g. "Sarah Chen").
    /// Figma source: `📱 Mail` node `15044:143212` Row 1 sender text — SF Pro Text
    /// Medium 17pt, tracking -0.408. Production matches (`SnippetCellStyle.swift`
    /// `fromLabelFont = .body + .medium`; OLM `.body` = 17pt per
    /// `UIFont+Outlook.swift:44`). Sits between Body 1 (Regular/400) and Body 1
    /// Strong (Semibold/600) on the Figma ramp — no exact named style.
    /// Apply with `.tracking(-0.408)` at the Text level for letter-spacing parity.
    static let odsMailListSender = Font.system(size: 17, weight: .medium)
}

// MARK: - Text — composed text-style helpers (font + tracking)
//
// Letter-spacing values per typography-1.1.yaml. Font alone can't carry
// tracking; these helpers apply font + tracking together at the Text level.
public extension Text {
    func odsTitle1() -> Text { font(.odsTitle1).tracking(0.38) }
    func odsBody1() -> Text { font(.odsBody1).tracking(-0.43) }
    func odsBody1Strong() -> Text { font(.odsBody1Strong).tracking(-0.43) }
    func odsBody2() -> Text { font(.odsBody2).tracking(-0.23) }
    func odsBody2Strong() -> Text { font(.odsBody2Strong).tracking(-0.23) }
    func odsCaption1() -> Text { font(.odsCaption1).tracking(-0.08) }
    func odsCaption1Strong() -> Text { font(.odsCaption1Strong).tracking(-0.08) }
    func odsCaption2() -> Text { font(.odsCaption2).tracking(0) }
}

// MARK: - Color
//
// Color tokens now live in their own two-layer files, generated from the
// canonical ODS YAML:
//   - Tokens/Color/ColorPrimitives.swift  (Layer 1 — Fluent 2, ODSPrimitive.*)
//   - Tokens/Color/ColorSemantic.swift     (Layer 2 — Outlook Mobile, Color.ods*)
//   - Tokens/Color/ColorDynamic.swift      (hand-written resolver + Color(odsHex:))

// MARK: - CGFloat (Layer 1 primitives + Layer 2 aliases)
public extension CGFloat {
    // Size primitives — name = `odsSize{N*10}` → value = N
    static let odsSizeNone: CGFloat = 0
    static let odsSize20: CGFloat = 2
    static let odsSize40: CGFloat = 4
    static let odsSize60: CGFloat = 6
    static let odsSize80: CGFloat = 8
    static let odsSize100: CGFloat = 10
    static let odsSize120: CGFloat = 12
    static let odsSize160: CGFloat = 16
    static let odsSize200: CGFloat = 20
    static let odsSize240: CGFloat = 24
    static let odsSize280: CGFloat = 28
    static let odsSize320: CGFloat = 32
    static let odsSize480: CGFloat = 48

    // Spacing aliases — compose Size primitives
    static let odsSpacingHorizontalXS: CGFloat = .odsSize40
    static let odsSpacingHorizontalS: CGFloat = .odsSize80
    static let odsSpacingHorizontalL: CGFloat = .odsSize160
    static let odsSpacingVerticalS: CGFloat = .odsSize80
    static let odsSpacingVerticalSNudge: CGFloat = .odsSize60
    static let odsSpacingVerticalMNudge: CGFloat = .odsSize100

    // Stroke widths — `odsStrokeWidth{N*10}` → N/10
    static let odsStrokeWidth10: CGFloat = 1
    static let odsStrokeWidth15: CGFloat = 1.5
    static let odsStrokeWidth20: CGFloat = 2

    // Corner radii — `odsCornerRadius{N*10}` → N/10. Circular uses .infinity
    // for the SwiftUI pill idiom (Capsule shape).
    static let odsCornerRadius20: CGFloat = 2
    static let odsCornerRadius40: CGFloat = 4
    static let odsCornerRadius60: CGFloat = 6
    static let odsCornerRadius80: CGFloat = 8
    static let odsCornerRadius120: CGFloat = 12
    static let odsCornerRadiusCircular: CGFloat = .infinity
}

// MARK: - Motion (durations + cubic-bezier easings)
//
// Sourced from `outlook-design-system/ods/ios/Foundations/motion-1.0.yaml`
// (converted from the Figma Variables Motion.json export). Easing tokens are
// cubic-bezier control points (P1.x, P1.y, P2.x, P2.y) that feed straight into
// SwiftUI's `.timingCurve(_, _, _, _, duration:)`. Durations are seconds
// (Figma authors in ms; values divided by 1000 here).
public enum ODSMotion {
    public enum Easing {
        public static let linear:        (Double, Double, Double, Double) = (0.00, 0.00, 1.00, 1.00)
        public static let ease01:        (Double, Double, Double, Double) = (0.33, 0.00, 0.67, 1.00)
        public static let ease02:        (Double, Double, Double, Double) = (0.80, 0.00, 0.20, 1.00)
        public static let decelerate01:  (Double, Double, Double, Double) = (0.33, 0.00, 0.10, 1.00)
        public static let decelerate02:  (Double, Double, Double, Double) = (0.00, 0.00, 0.00, 1.00)
        public static let decelerate03:  (Double, Double, Double, Double) = (0.10, 0.90, 0.20, 1.00)
        public static let accelerate01:  (Double, Double, Double, Double) = (0.80, 0.00, 0.78, 1.00)
        public static let accelerate02:  (Double, Double, Double, Double) = (1.00, 0.00, 1.00, 1.00)
        public static let accelerate03:  (Double, Double, Double, Double) = (0.90, 0.10, 1.00, 0.20)
    }

    public enum Duration {
        public static let short01:  Double = 0.050
        public static let short02:  Double = 0.100
        public static let short03:  Double = 0.150
        public static let medium01: Double = 0.200
        public static let medium02: Double = 0.250
        public static let medium03: Double = 0.300
        public static let long01:   Double = 0.400
        public static let long02:   Double = 0.500
    }
}

public extension Animation {
    /// Compose an Outlook motion token. `easing` is a 4-tuple of cubic-bezier
    /// control points (use `ODSMotion.Easing.*`); `duration` is in seconds
    /// (use `ODSMotion.Duration.*`).
    static func odsMotion(_ easing: (Double, Double, Double, Double), duration: Double) -> Animation {
        .timingCurve(easing.0, easing.1, easing.2, easing.3, duration: duration)
    }
}

// MARK: - Motion / One-offs (not in the canonical Motion ramp)
//
// Animations sourced from production iOS Outlook code whose timing or curve
// DO NOT correspond to a named primitive in the Figma Motion ramp. Each
// entry must cite its production source. Keep minimal — primitives are the
// canonical answer when production and Figma align.
//
// Documented under `oneOffs:` in `motion-1.0.yaml`.
public extension Animation {
    /// Segmented control selection slide (Focused/Other in the Inbox header).
    /// Production source: `client-cocoa/.../SegmentedControl.swift:106` —
    /// `selectedBarAnimationDuration = 0.12` + `.curveEaseOut` (Apple's
    /// UIView ease-out, cubic-bezier ≈ (0, 0, 0.58, 1)). Neither the duration
    /// (120ms) nor the curve sit on the Fluent Motion ramp.
    static let odsSegmentedControlSelection: Animation =
        .timingCurve(0.0, 0.0, 0.58, 1.0, duration: 0.12)
}
