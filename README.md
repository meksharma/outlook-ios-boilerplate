# Outlook Card Framework

A SwiftUI design and development POC for presenting compact, stateful AI experiences inside Outlook Mobile.

**[Browse the Card Framework source](./OutlookBoilerplate/CardFramework/)** · **[Read the implementation notes](./OutlookBoilerplate/CardFramework/README.md)**

## What it demonstrates

- A Summarize card embedded in the Outlook Reading Pane
- Generation, streaming, completed, collapsed, and error states
- Inline citations, source references, suggested actions, and feedback
- A reusable card renderer separated from feature-specific state

## Try it in Xcode

```bash
git clone --branch mehak/2026_09_23_card-framework-build \
  https://github.com/meksharma/outlook-ios-boilerplate.git
cd outlook-ios-boilerplate
open OutlookBoilerplate.xcodeproj
```

Run `OutlookBoilerplate` on an iPhone simulator. Open **Designer Tools**, enable **Card Framework**, open an email, and tap **Summarize**.
