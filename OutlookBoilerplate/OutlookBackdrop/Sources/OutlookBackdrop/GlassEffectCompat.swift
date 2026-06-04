//
//  GlassEffectCompat.swift
//  OutlookBackdrop
//
//  Ported from production Outlook iOS:
//    client-cocoa/app-ios/Pods/CopilotUIKit/ios/OneCopilotMobile/Sources/CopilotUIKit/Utils/GlassEffectCompatibility.swift
//
//  Mirrors the production iOS 26 path verbatim. The iOS<26 fallback in production
//  uses .applyShadow(shadowInfo:), a SwiftUI extension defined privately inside
//  CopilotUIKit (not in fluentui-apple 0.35.0). Because OutlookBackdrop's platform
//  constraint is iOS 26+, that fallback would be dead code — it is dropped here
//  rather than reimplemented.
//
//  Production gates Liquid Glass with LiquidGlassFlags.enableiOS26LiquidGlassMode;
//  Boilerplate ships glass-on for all designers — no feature flag wrapper.
//
//  Signature alignment with fluentui-apple HEAD (Decision Log #22):
//    fluentui-apple HEAD ships `View.fluentGlassEffect(interactive:tint:in:)` at
//    Sources/FluentUI_common/Core/Extensions/View+Modifiers.swift:25. Our
//    `glassEffectCompat` matches that signature parameter-for-parameter (same
//    names, defaults, generic constraint), so a future SPM bump past 0.35.0
//    becomes a `glassEffectCompat` → `fluentGlassEffect` rename across callers,
//    not a refactor. Pinned dep stays 0.35.0 to match production Outlook iOS.
//

import FluentUI
import SwiftUI

public extension View {
    /// Applies a glass effect circle when enabled, otherwise renders plain.
    @ViewBuilder func glassEffectCircleIfEnabled(_ enabled: Bool) -> some View {
        if enabled {
            self.glassEffect(.regular.interactive(true).tint(Color(light: .white, dark: .clear)), in: .circle)
        } else {
            self
        }
    }

    /// Applies the iOS 26 `.glassEffect` modifier with production's standard configuration.
    /// Matches `glassEffectCompat(interactive:tint:in:)` in production Outlook iOS.
    func glassEffectCompat<T>(
        interactive: Bool = false,
        tint: Color? = nil,
        in shape: T = Capsule()
    ) -> some View where T: Shape {
        self.glassEffect(.regular.interactive(interactive).tint(tint), in: shape)
    }
}

/// A compatibility container which wraps `GlassEffectContainer`.
/// Production keeps this as a portability shim; on iOS 26+ it forwards directly.
public struct GlassEffectContainerCompat<Content>: View where Content: View {
    @ViewBuilder public let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        GlassEffectContainer {
            content()
        }
    }
}

// MARK: - UIKit-backed Liquid Glass (path C)
//
// Wraps iOS 26's `UIVisualEffectView` + `UIGlassEffect(style:)`. This is the
// path production Outlook iOS uses for non-Copilot surfaces — see e.g.
//   client-cocoa/.../TintedBackgroundView.swift:139–142
//   Pods/MicrosoftFluentUI/.../BottomCommandingController.swift:535
//
// SwiftUI's `.glassEffect(.regular...)` modifier (used by `glassEffectCompat`)
// renders the same underlying iOS 26 material but adds a SwiftUI wrapper
// layer that can read subtly differently from the UIKit path. Prefer
// `liquidGlassEffect` when matching system chrome (tab bars, etc.).

/// Pure UIKit Liquid Glass material. Applies the iOS 26 capsule corner
/// configuration; same behavior as production's `TintedBackgroundView`.
public struct LiquidGlassBackground: UIViewRepresentable {
    public let interactive: Bool

    public init(interactive: Bool = false) {
        self.interactive = interactive
    }

    public func makeUIView(context: Context) -> UIVisualEffectView {
        let effect = UIGlassEffect(style: .regular)
        effect.isInteractive = interactive
        let view = UIVisualEffectView(effect: effect)
        view.cornerConfiguration = .capsule()
        return view
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

public extension View {
    /// Apply iOS 26 Liquid Glass via `UIVisualEffectView` + `UIGlassEffect`
    /// (UIKit path, matches production). `interactive` enables the press-
    /// response highlight. Corner is always `.capsule()` — for non-capsule
    /// shapes, keep `glassEffectCompat`.
    func liquidGlassEffect(interactive: Bool = false) -> some View {
        background(LiquidGlassBackground(interactive: interactive))
    }
}
