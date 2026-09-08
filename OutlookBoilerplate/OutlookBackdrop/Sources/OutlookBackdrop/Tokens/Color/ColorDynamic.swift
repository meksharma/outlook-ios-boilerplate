// Hand-written token infrastructure (NOT generated). Stable across re-exports.
//
// Bridges the Outlook color tokens to iOS: a hex initializer for Layer-1
// primitives, and the 5-mode resolver that powers every Layer-2 semantic token.

import SwiftUI
import UIKit

public extension Color {
    /// Build a Color from `#RRGGBB` or `#RRGGBBAA`.
    init(odsHex hex: String) {
        let s = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((v >> 24) & 0xFF) / 255
            g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255
            a = Double(v & 0xFF) / 255
        } else {
            r = Double((v >> 16) & 0xFF) / 255
            g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

/// Resolve an Outlook semantic token across the five Figma modes via iOS traits:
///
///   Figma mode    →  iOS trait
///   ─────────────────────────────────────────────
///   Light         →  .light, normal contrast
///   Dark          →  .dark,  normal contrast, base level
///   iOS Elevated  →  .dark,  normal contrast, .elevated (sheets/popovers)
///   Light HCC     →  .light, accessibilityContrast .high
///   Dark HCC      →  .dark,  accessibilityContrast .high
///
/// Inputs may themselves be primitives or other (dynamic) semantic colors — the
/// nested UIColor resolves in the active trait collection, so L2→L2 links work.
public func odsDynamic(
    light: Color,
    dark: Color,
    iosElevated: Color,
    lightHCC: Color,
    darkHCC: Color
) -> Color {
    Color(UIColor { tc in
        let highContrast = tc.accessibilityContrast == .high
        switch tc.userInterfaceStyle {
        case .dark:
            if highContrast { return UIColor(darkHCC) }
            return UIColor(tc.userInterfaceLevel == .elevated ? iosElevated : dark)
        default:
            return UIColor(highContrast ? lightHCC : light)
        }
    })
}
