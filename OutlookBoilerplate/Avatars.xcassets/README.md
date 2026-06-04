# Avatars

CELA-approved persona avatars vendored from the `🎨 Fluent avatars` Figma
file:

    https://www.figma.com/design/KGP1cSTKB0NsKZeLhkdlJBXv

Use these wherever the Boilerplate needs a realistic-looking sender or contact
avatar (mail rows, reading pane, drawer account header, etc.).

## Why a separate catalog (not `Assets.xcassets/OutlookIcons/`)

Same separation logic as `Icon Inbox.xcassets/`: brand marks vs people vs
system icons each get their own catalog so designers can drop in new images
without searching through unrelated buckets.

- `Assets.xcassets/OutlookIcons/` → Outlook brand marks (Compose, Copilot, Mic)
- `Icon Inbox.xcassets/` → Fluent system icons
- `Avatars.xcassets/` (this folder) → CELA-approved persona portraits

## Adding a persona

1. Drop the imageset directory into this folder. Name kebab-case from the
   persona's full name (e.g. `sarah-perez.imageset`).
2. Add a case to `OutlookBackdrop/Sources/OutlookBackdrop/Persona.swift`:

       case sarahPerez = "sarah-perez"
       // …in displayName switch:
       case .sarahPerez: return "Sarah Perez"

3. Use:

       Image(.sarahPerez)
           .resizable()
           .clipShape(Circle())
           .frame(width: 40, height: 40)

## Why "CELA-approved" matters

These names and portraits are pre-cleared by Microsoft Corporate, External,
and Legal Affairs for use in product mocks. Don't substitute random
stock-photo names — only use the personas Microsoft Design has vetted (the
list lives in the Fluent avatars Figma file).
