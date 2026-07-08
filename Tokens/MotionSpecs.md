# Motion Design System — Outlook iOS

Source-of-truth for motion tokens used in this boilerplate and portable to other repos.
Agents read this file to determine **what animation** a component gets, its **easing curve**
(cubic-bezier), and its **duration**.

---

## How it works

1. Agent receives a request to add/animate a component (e.g. "add a SidePane").
2. Agent looks up the component in the **Component Motion Map** below.
3. Agent reads the assigned `motionToken` name.
4. Agent resolves that token in the **Motion Tokens** table to get the cubic-bezier curve and duration.
5. Agent applies the animation to the element using the platform's native API.

For SwiftUI:

```swift
.animation(
    .timingCurve(0.8, 0.0, 0.2, 1.0, duration: 0.35),
    value: triggerValue
)
```

---

## Motion Tokens

Each token defines a reusable animation primitive. Curves are expressed as
`cubic-bezier(x1, y1, x2, y2)` — the standard CSS/Core Animation format.

### Duration scale

| Token               | Value  | Use case                                  |
|---------------------|--------|-------------------------------------------|
| `duration.instant`  | 0.05s  | Micro-feedback (tap highlight)            |
| `duration.fast`     | 0.15s  | Small state changes (icon swap, toggle)   |
| `duration.normal`   | 0.25s  | Standard transitions (fade, color shift)  |
| `duration.moderate` | 0.35s  | Surface enter/exit (sheets, drawers)      |
| `duration.slow`     | 0.50s  | Large surface transitions (full-screen)   |
| `duration.gentle`   | 0.70s  | Orchestrated sequences, stagger parents   |

### Easing curves

| Token                    | Cubic-Bezier              | Character                          |
|--------------------------|---------------------------|------------------------------------|
| `easing.enter`           | `(0.0, 0.0, 0.2, 1.0)`   | Decelerate — content arriving      |
| `easing.exit`            | `(0.4, 0.0, 1.0, 1.0)`   | Accelerate — content leaving       |
| `easing.standard`        | `(0.8, 0.0, 0.2, 1.0)`   | Symmetric ease — repositions       |
| `easing.emphasized`      | `(0.05, 0.7, 0.1, 1.0)`  | Expressive spring-like — hero      |
| `easing.linear`          | `(0.0, 0.0, 1.0, 1.0)`   | Constant rate — progress bars      |
| `easing.bounce`          | `(0.34, 1.56, 0.64, 1.0)`| Overshoot — playful confirmations  |

### Composite motion tokens (easing + duration paired)

| Token                        | Easing             | Duration            | Description                         |
|------------------------------|--------------------|---------------------|-------------------------------------|
| `motion.surface.enter`       | `easing.enter`     | `duration.moderate` | Surface slides/fades in             |
| `motion.surface.exit`        | `easing.exit`      | `duration.normal`   | Surface slides/fades out            |
| `motion.content.enter`       | `easing.enter`     | `duration.normal`   | Content fades/scales in             |
| `motion.content.exit`        | `easing.exit`      | `duration.fast`     | Content fades/scales out            |
| `motion.reposition`          | `easing.standard`  | `duration.normal`   | Element moves within layout         |
| `motion.hero`                | `easing.emphasized`| `duration.slow`     | Hero transition, shared element     |
| `motion.feedback`            | `easing.standard`  | `duration.fast`     | Tap/press micro-interaction         |
| `motion.stagger.child`       | `easing.enter`     | `duration.normal`   | Staggered list item (per-item)      |
| `motion.stagger.delay`       | —                  | 0.04s               | Delay between stagger children      |

---

## Component Motion Map

Each component has an **enter** and **exit** motion assignment. Some also have
**interaction** motions for in-place state changes.

### Navigation surfaces

| Component        | State     | Motion Token              | Transform                     |
|------------------|-----------|---------------------------|-------------------------------|
| SideDrawer       | enter     | `motion.surface.enter`    | translateX(-100%) → 0        |
| SideDrawer       | exit      | `motion.surface.exit`     | translateX(0) → -100%        |
| SideDrawer.scrim | enter     | `motion.content.enter`    | opacity 0 → 0.4              |
| SideDrawer.scrim | exit      | `motion.content.exit`     | opacity 0.4 → 0              |
| ReadingPane      | enter     | `motion.surface.enter`    | translateX(100%) → 0         |
| ReadingPane      | exit      | `motion.surface.exit`     | translateX(0) → 100%         |

### Sheets & overlays

| Component        | State     | Motion Token              | Transform                     |
|------------------|-----------|---------------------------|-------------------------------|
| CopilotSheet     | enter     | `motion.surface.enter`    | translateY(100%) → 0         |
| CopilotSheet     | exit      | `motion.surface.exit`     | translateY(0) → 100%         |
| ComposeModal     | enter     | `motion.hero`             | translateY(100%) → 0         |
| ComposeModal     | exit      | `motion.surface.exit`     | translateY(0) → 100%         |
| AlertDialog      | enter     | `motion.content.enter`    | scale(0.85) + opacity 0 → 1 |
| AlertDialog      | exit      | `motion.content.exit`     | scale(1) → 0.85 + opacity 0 |

### Content elements

| Component          | State       | Motion Token              | Transform                    |
|--------------------|-------------|---------------------------|------------------------------|
| InboxRow           | appear      | `motion.stagger.child`    | translateY(8) + opacity 0→1  |
| InboxRow           | stagger     | `motion.stagger.delay`    | +0.04s per index             |
| FloatingButton     | enter       | `motion.content.enter`    | scale(0) → 1                 |
| FloatingButton     | exit        | `motion.content.exit`     | scale(1) → 0                 |
| FloatingButton     | tap         | `motion.feedback`         | scale(1) → 0.92 → 1         |
| TabBar.indicator   | reposition  | `motion.reposition`       | translateX to target         |
| Avatar             | tap         | `motion.feedback`         | scale(1) → 0.9 → 1          |

### Toolbar & bars

| Component          | State     | Motion Token              | Transform                    |
|--------------------|-----------|---------------------------|------------------------------|
| InboxHeader        | scroll     | `motion.reposition`       | translateY(0) → -height      |
| ActionBar          | enter      | `motion.content.enter`    | translateY(48) + opacity 0→1 |
| ActionBar          | exit       | `motion.content.exit`     | translateY(0→48) + opacity 0 |

---

## Stagger pattern

When multiple children animate in sequence:

```
delay(index) = motion.stagger.delay × index
```

Example — 5 inbox rows:
- Row 0: delay 0.00s
- Row 1: delay 0.04s
- Row 2: delay 0.08s
- Row 3: delay 0.12s
- Row 4: delay 0.16s

Each row uses `motion.stagger.child` (easing.enter, duration.normal = 0.25s).

---

## SwiftUI integration helpers

### Reading a motion token

```swift
// Resolved from motion-tokens.json or hardcoded from this spec:
enum MotionToken {
    static let surfaceEnter = Animation.timingCurve(0.0, 0.0, 0.2, 1.0, duration: 0.35)
    static let surfaceExit  = Animation.timingCurve(0.4, 0.0, 1.0, 1.0, duration: 0.25)
    static let contentEnter = Animation.timingCurve(0.0, 0.0, 0.2, 1.0, duration: 0.25)
    static let contentExit  = Animation.timingCurve(0.4, 0.0, 1.0, 1.0, duration: 0.15)
    static let reposition   = Animation.timingCurve(0.8, 0.0, 0.2, 1.0, duration: 0.25)
    static let hero         = Animation.timingCurve(0.05, 0.7, 0.1, 1.0, duration: 0.50)
    static let feedback     = Animation.timingCurve(0.8, 0.0, 0.2, 1.0, duration: 0.15)
}
```

### Applying to a component

```swift
// SideDrawer example — matches Component Motion Map
.offset(x: isShowing ? 0 : -drawerWidth)
.animation(MotionToken.surfaceEnter, value: isShowing)
```

### Stagger helper

```swift
ForEach(Array(threads.enumerated()), id: \.element.id) { index, thread in
    InboxRow(thread: thread)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(
            MotionToken.contentEnter.delay(Double(index) * 0.04),
            value: appeared
        )
}
```

---

## Reduce Motion accessibility

When the user enables **Reduce Motion** (`UIAccessibility.isReduceMotionEnabled`
or `@Environment(\.accessibilityReduceMotion)`), all motion tokens collapse to:

| Original              | Reduced-motion fallback          |
|-----------------------|----------------------------------|
| Any translate/scale   | Cross-fade only (opacity 0 → 1)  |
| Any duration > 0.15s  | Capped at 0.15s                  |
| Stagger delay         | 0s (all appear simultaneously)   |

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

.animation(
    reduceMotion ? .easeOut(duration: 0.15) : MotionToken.surfaceEnter,
    value: isShowing
)
```

---

## Adding motion to a new component

1. **Pick a role** — Is it a surface, content, or micro-interaction?
2. **Assign tokens** — Use the composite token that matches (see table above).
3. **Define transform** — What CSS-like transform does it use? (translate, scale, opacity)
4. **Document** — Add a row to the Component Motion Map in this file.
5. **Implement** — Use the SwiftUI helpers or resolve from `motion-tokens.json`.

---

## Cross-repo portability

This motion system is designed to be dropped into any repo:

1. Copy `Tokens/MotionSpecs.md` + `Tokens/motion-tokens.json` into the target repo's tokens folder.
2. Agents read the spec to determine animations for any component they build.
3. Platform-specific helpers (SwiftUI, CSS, Compose) translate the cubic-bezier values.

The token names and values are **platform-agnostic** — only the "integration helpers"
section changes per platform.
