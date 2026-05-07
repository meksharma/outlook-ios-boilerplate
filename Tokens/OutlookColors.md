# Outlook Colors — boilerplate token reference

Source-of-truth for color tokens used in this boilerplate. Designers
reach for tokens here; engineers wire them via `FluentTheme`.

This file is descriptive, not authoritative. Authority lives in
FluentUI Apple 0.35.0 (`FluentTheme+iOS.swift`) and, for Outlook-specific
deltas, in `client-cocoa/app-ios/OLMFoundations/OLMColorsKit/Fluent2Palette/AliasTokens/F2AliasTokens.swift`.

---

## How to use

Inside any SwiftUI `View`:

```swift
@Environment(\.fluentTheme) private var fluentTheme: FluentTheme

var body: some View {
    Text("hello")
        .foregroundStyle(fluentTheme.swiftUIColor(.foreground1))
        .background(fluentTheme.swiftUIColor(.background1))
}
```

The root `ContentView` already applies `.fluentTheme(FluentTheme.shared)`,
so every descendant inherits the theme automatically.

---

## Brand palette (the Outlook blue ramp)

FluentUI Apple ships Outlook's "communication" brand palette directly.
Path D′ (see `04 tech sheet.md`) uses these via the SPM-pinned 0.35.0
release — no vendoring.

| Token | Hex (light) | Hex (dark)  | Where it shows |
|---|---|---|---|
| `comm80`  | `#0F6CBD` | `#3B8CD9` | Default brand, unread dots, action icons |
| `comm100` | `#3B8CD9` | `#5DA5E8` | Brand foreground in dark mode |
| `comm150` | `#EBF3FC` | `#11243A` | Tinted backgrounds (selection, hover) |

Access:

```swift
GlobalTokens.brandSwiftUIColor(.comm80)   // raw global token (always comm80)
fluentTheme.swiftUIColor(.brandForeground1) // alias — adapts comm80 ↔ comm100 by mode
```

Prefer the alias unless you need a fixed value (e.g. always-blue
icon regardless of mode).

---

## Alias tokens used in this boilerplate

These are the FluentTheme alias tokens currently wired into the
boilerplate's surfaces. Anything below is what you should reach for
when adding new UI.

### Surfaces

| Token | Use |
|---|---|
| `background1` | Page surface — Inbox, Reading pane, Compose, Drawer |
| `background3` | Pill / capsule backgrounds — folder counts, suggestion chips, Copilot input bar |

### Foregrounds

| Token | Use |
|---|---|
| `foreground1` | Primary text, primary icons |
| `foreground2` | Secondary text — timestamps, subtitles, muted icons |
| `brandForeground1` | Unread dots, brand-tinted accents |

### Strokes

For subtle chip / capsule strokes use `foreground1.opacity(0.08)` —
0.35.0 doesn't ship `strokeAlpha1` / `strokeAlpha2` (those land in a
later FluentUI Apple release). The opacity-on-foreground pattern stays
tokenized and auto-inverts for dark mode.

### Avoid

- `Color.accentColor` — resolves to iOS system tint, not Outlook blue
- `Color(uiColor: .systemBackground)` — iOS auto-mapping doesn't match
  Outlook's surface ramp; use `.background1`
- `Color.primary` / `Color.secondary` — same reason; use `.foreground1` /
  `.foreground2`
- Hand-typed hex / RGB values — if you need a color, find or request a token

---

## Outlook ↔ FluentUI Apple divergence

`F2AliasTokens.swift`'s header comment states most aliases come from
FluentUI Apple's defaults verbatim. The deltas (relative to FluentUI
Apple 0.35.0):

### Dark-elevated background shift

Outlook's surfaces are slightly lighter than FluentUI Apple's defaults
in dark-elevated mode (the appearance iOS applies to sheets / popovers
above a dark background):

| Token | FluentUI Apple darkElevated | Outlook darkElevated | Δ |
|---|---|---|---|
| `background1` | grey4  | grey12 | +8 |
| `background2` | grey16 | grey18 | +2 |
| `background3` | grey20 | grey22 | +2 |
| `background4` | grey24 | grey26 | +2 |
| `background5` | grey28 | grey30 | +2 |
| `background6` | grey40 | grey42 | +2 |

Light, plain dark, and pressed/selected variants match. Phase 1 ships
with FluentUI Apple's values — the +2/+8 lift will surface only on
elevated dark surfaces, where the eye barely catches it. If a
prototype needs production-faithful dark-elevated, that's the Phase 2
override path.

### Outlook-only categories

These exist in `F2AliasTokens.swift` but not in FluentUI Apple's
`FluentTheme+iOS.swift`:

- **High-contrast variants** (`*HC`) — Fluent ships none; Outlook
  defines `lightHC` / `darkHC` for every brand alias
- **`backgroundTransparent`** — black @ 40% alpha; used as scrim. The
  boilerplate emits this as `Color.black.opacity(0.4)` literal until
  the override layer lands

### Phase 2 override path

If/when the mobile team needs production-faithful dark-elevated or HC
support, the override goes in `OutlookBackdrop.applyToFluentTheme()` via
`FluentTheme(colorOverrides: …)`. See the empty hook in
`OutlookBackdrop.swift`.

---

## Quick cross-reference

```
SwiftUI semantic              →  FluentTheme alias
─────────────────────────────────────────────────────
Color.accentColor             →  brandForeground1
Color(uiColor: .systemBackground)
                              →  background1
Color(uiColor: .secondarySystemBackground)
                              →  background3
.foregroundStyle(.primary)    →  foreground1
.foregroundStyle(.secondary)  →  foreground2
Color.primary.opacity(0.08)   →  foreground1.opacity(0.08)
```
