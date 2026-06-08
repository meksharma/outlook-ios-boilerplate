# Outlook iOS Boilerplate — Agent Instructions

This repository is the **iOS endpoint** of the Outlook Design System.

## Endpoint guard

Read ODS specs **only** from `ods-kb/ods/iOS/`. Never read `ods-kb/ods/windowsWeb/` or any other platform directory — that produces wrong-platform components ("context poisoning").

## Design system rules

The iOS rules and shared guardrails load directly from the ODS-KB submodule:

@ods-kb/ods-iOS.md
@ods-kb/guardrails.md

iOS rules are an early stub (see `ods-iOS.md`). **Reference, never copy** — propose changes upstream in `x3-design/outlook-design-system`, not here.

## Submodule setup

If `ods-kb/` is empty or missing: `git submodule update --init`.
To pull the latest specs: `git submodule update --remote ods-kb`.

## Branch naming

All branches follow `gitHubAlias/YYYY_MM_DD_branchTitle`.
