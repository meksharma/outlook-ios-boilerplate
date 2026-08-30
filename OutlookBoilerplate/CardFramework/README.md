# iOS Card Framework Prototype

This directory contains an opt-in SwiftUI prototype for presenting compact,
stateful AI experiences inside Outlook surfaces. The initial example is a
Summarize card in the Reading Pane.

The implementation is intentionally isolated from the default boilerplate
experience. The **Card Framework** setting is off by default, so a normal app
launch continues to use the baseline Reading Pane.

## Review the Prototype

1. Open `OutlookBoilerplate.xcodeproj`.
2. Run the `OutlookBoilerplate` scheme on an iPhone simulator.
3. Open Designer Tools from the Inbox header.
4. Turn on **Card Framework**.
5. Open an email.
6. Tap **Summarize** to start the generation sequence.

Turn **Card Framework** off to restore the baseline Reading Pane and its
original back button.

## Design References

- [OM Card Framework](https://www.figma.com/design/OzBXIkV9IFlAPJR9MLrlNr/OM-Card-Framework?node-id=3527-78090)
- [Reading Pane Summarize prototype](https://www.figma.com/design/aWoYlsFRdsIHN57U2CGpNg/POR---Reading-Pane-VCI--Summarize-v2-)

## Architecture

| File | Responsibility |
| --- | --- |
| [`OutlookCardModels.swift`](./OutlookCardModels.swift) | State, content, action, citation, reference, and sheet models |
| [`OutlookCardView.swift`](./OutlookCardView.swift) | Reusable, state-driven card renderer |
| [`SummarizeCard.swift`](./SummarizeCard.swift) | Summarize-specific content and prototype state transitions |
| [`AnimatedGIFView.swift`](./AnimatedGIFView.swift) | GIF decoding, playback, sizing, and white-background removal |
| [`InlineCitationText.swift`](./InlineCitationText.swift) | TextKit-based inline citation attachment and tap handling |
| [`OutlookReferencesSheet.swift`](./OutlookReferencesSheet.swift) | Compact and expanded source presentation |
| [`OutlookActionChatSheet.swift`](./OutlookActionChatSheet.swift) | Suggested-action chat sheet shell |
| [`LoaderDemoView.swift`](./LoaderDemoView.swift) | Standalone public-safe animation demo |

`OutlookCardView` owns presentation. Its parent owns state and supplies
callbacks. This keeps the reusable view independent of navigation, networking,
and feature-specific business logic.

## Supported States

`OutlookCardState` defines the complete prototype state family:

| State | Purpose |
| --- | --- |
| `preGeneration` | Compact command that starts generation |
| `preGenerationAlternate` | Prompt and command treatment |
| `latencyWithoutText` | Animated latency indicator before content is available |
| `latencyWithTextStreaming` | Loading header while text begins to arrive |
| `streamingExpanded` | Expanded progressive output |
| `streamingCollapsed` | Collapsed progressive output |
| `outputExpanded` | Completed output, suggested actions, and footer controls |
| `outputCollapsed` | Completed header and truncated preview |
| `error` | Failure state with retry and feedback affordances |
| `actionOnly` | Card containing suggested actions without summary output |

The example sequence in `SummarizeCard` uses local delays and mock text to
demonstrate latency and progressive streaming. These timers are not a
production data contract.

## Content Model

`OutlookCardContent` provides the copy and collections required by the renderer:

- Prompt and command title
- Output and generation titles
- Error and feedback copy
- Completed summary items
- Progressive streaming stages
- Suggested actions
- Action-only items
- References

Each `OutlookCardSummaryItem` can include an `OutlookCardCitation`. A citation
contains one or more `OutlookCardReference` values, which currently support
mail and chat source types.

To create another card experience:

1. Define a new `OutlookCardContent` value.
2. Own an `OutlookCardState` in a feature-specific wrapper.
3. Pass the state, content, and callbacks to `OutlookCardView`.
4. Replace prototype timers with real feature state.

## Interactions

### Generation and expansion

- The pre-generation command invokes `onGenerate`.
- Generating and completed headers invoke `onToggleExpansion` when applicable.
- The error action invokes `onRetry`.

### Suggested user actions

Every suggested action invokes:

```swift
onAction: (OutlookCardAction) -> Void
```

The current Reading Pane forwards this callback to `ContentView`, which presents
`OutlookActionChatSheet`. The selected action is retained in the sheet model as
handoff context. The prototype sheet intentionally renders only its header and
composer footer; its conversation body is blank.

### Citations and sources

- Inline citation attachments open the references associated with that item.
- The **Sources** footer action opens the complete reference collection.
- The compact sheet height accommodates up to two source rows.
- The sheet can expand to the large detent for the complete list.

TextKit is used for inline citations so the citation can remain at the end of
the final text line when space permits.

## Feature Gate

The prototype is controlled by:

```swift
@AppStorage("cardFrameworkEnabled")
```

The default value is `false`.

The setting is exposed in `DesignerToolsSheet`. `ReadingPaneView` reads the same
value and conditionally adds the card. While disabled, the Reading Pane uses
the baseline back button and does not display the Card Framework.

The models and callbacks may still be compiled while the setting is off, but
they do not change the visible Reading Pane experience.

## Animation

The latency animation is stored in the asset catalog as
`card_latency_animation`.

`AnimatedGIFView`:

- Decodes the GIF with ImageIO.
- Preserves per-frame timing.
- Removes near-white background pixels during decoding.
- Renders the animation at 12 x 12 points inside a 20 x 20 layout box.
- Works against light and dark card backgrounds.

The prototype decodes all GIF frames into memory. Before production use,
engineering should evaluate a native animation, APNG, or another optimized
asset pipeline.

## Light and Dark Appearance

The card uses Outlook semantic colors so its surfaces and foregrounds resolve
for the current appearance. The collapsed-state fade is also generated from
the semantic card background rather than a light-only raster.

The dark loading-card treatment maps to the intended dark brand background,
with light foreground content.

## Accessibility

The prototype includes:

- Accessible labels for card controls, citations, source rows, and sheet actions
- Combined accessibility elements for related visual content
- Escape actions for dismissing References and action sheets
- Decorative images hidden from accessibility where appropriate
- A 44-point interaction target for primary icon controls

Production review should additionally validate Dynamic Type at accessibility
sizes, VoiceOver navigation order, localization expansion, reduced motion, and
contrast in all supported themes.

## Standalone Loader Demo

The public-safe loader demo is separate from the Card Framework presentation.
Launch it with:

```bash
xcrun simctl launch \
  <simulator-udid> \
  com.microsoft.outlookboilerplate.OutlookBoilerplate \
  --loader-demo
```

The demo contains a generic skeleton, the animation, a neutral **Loading**
label, and a one-tap light/dark switcher. It intentionally excludes the card
surface and product content.

## Validation

The prototype is validated with the `OutlookBoilerplate` scheme:

```bash
xcodebuild \
  -project OutlookBoilerplate.xcodeproj \
  -scheme OutlookBoilerplate \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=<simulator-udid>' \
  -disableAutomaticPackageResolution \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Visual validation has been performed in an iPhone simulator for the primary
card states, citations, References, and light/dark loader treatments. The
suggested-action sheet compiles in the full scheme and its callback and
presentation wiring have been reviewed; complete interaction testing remains
part of productionization.

## Productionization Checklist

Before shipping this framework in a production target:

- Replace mock content and delays with feature-owned data and state.
- Connect suggested actions and composer controls to the production chat flow.
- Connect reference rows to their real mail or chat destinations.
- Add localization for all user-facing strings.
- Add unit tests for state transitions and content mapping.
- Add UI tests or snapshots for primary states and both appearances.
- Validate Dynamic Type, VoiceOver, reduced motion, and contrast.
- Evaluate animation memory usage and select the production asset format.
- Add telemetry, privacy review, error reporting, and cancellation behavior.
- Confirm final APIs and ownership with the consuming engineering team.

## Prototype Scope

This implementation demonstrates design intent and provides reusable SwiftUI
structure. It is engineer-ready reference code, not a claim that production
integration is complete. Product architecture, real data, reliability,
performance, privacy, analytics, and release validation remain engineering
responsibilities.
