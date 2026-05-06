import FluentUI
import SwiftUI

/// Entry point for applying the Outlook visual backdrop to FluentUI.
///
/// Call `OutlookBackdrop.applyToFluentTheme()` once at app launch, then apply
/// `.fluentTheme(FluentTheme.shared)` at the root SwiftUI view. After that, every
/// FluentUI component below renders Outlook-themed.
public enum OutlookBackdrop {
    /// Configure `FluentTheme.shared` for the Outlook backdrop.
    ///
    /// Phase 1 is a near-no-op: FluentUI Apple's iOS defaults already map brand
    /// color tokens to the `comm*` palette (Outlook's communication blue), so a
    /// fresh FluentUI Button renders Outlook-themed without any overrides.
    /// This entrypoint exists as the hook for future overrides — neutral-color
    /// tweaks, typography preferences, or any production-specific deltas the
    /// mobile team identifies once they start using the boilerplate.
    ///
    /// See `04 tech sheet.md` in the project notes for why we don't vendor
    /// `Fluent2Palette/` from `client-cocoa` (Path D′ vs. original Path D).
    public static func applyToFluentTheme() {
        // Intentionally empty for Phase 1.
        //
        // To add overrides later:
        //
        //   FluentTheme.shared = FluentTheme(
        //       colorOverrides: [.brandBackground1: ...],
        //       typographyOverrides: [.body1: ...]
        //   )
    }
}
