# Icon Inbox

This folder **is** the asset catalog for Fluent system icons used in the
Boilerplate. Drop a new icon imageset in here and it's immediately accessible
in code via `Image("name")` or the typed `OutlookIcon` enum — no moving, no
promotion step.

Separate from `Assets.xcassets/OutlookIcons/`, which holds Outlook brand marks
(ComposeIcon, CopilotIcon, MicIcon).

## Where icons come from

Boilerplate vendors Fluent System Icons individually instead of pulling the full
`fluentui-system-icons` SPM package — the package's 10,000+ icon asset catalog
takes ~15 minutes to compile on first build / Clean, unworkable for a clone-
and-go boilerplate. The full upstream catalog lives at:

    https://github.com/microsoft/fluentui-system-icons/tree/1.1.316/ios/FluentIcons/Assets/IconAssets.xcassets

Find the `.imageset` directory for the icon you want, download it, drop it
here. That's it.

## Naming convention (keep upstream names verbatim)

    ic_fluent_{name}_{size}_{variant}.imageset

Examples: `ic_fluent_bell_24_regular.imageset`, `ic_fluent_send_24_filled.imageset`.

- Sizes: 10, 12, 16, 20, 24, 28, 32, 48 (pt)
- Variants: `regular`, `filled`

## Use in code (two patterns)

**Untyped** — works immediately after dropping:

    Image("ic_fluent_bell_24_regular")

**Typed** — compile-time safety + autocomplete. Requires one extra step:

1. Add a case to `OutlookBackdrop/Sources/OutlookBackdrop/OutlookIcon.swift`:

       case bell24Regular = "ic_fluent_bell_24_regular"

2. Use:

       Image(.bell24Regular)
           .renderingMode(.template)
           .foregroundStyle(.primary)

Both compile. The typed pattern is the one all existing surfaces use.

## Brand marks (Copilot ribbon, Outlook bug, M365 logos)

Those come from `FluentBrandIcons` — Microsoft-internal Azure DevOps,
auth-gated. They cannot be vendored from a public source. Use plain text
("Copilot", "Outlook") as a stand-in unless you have an explicit business
reason to chase the brand mark through internal channels.
