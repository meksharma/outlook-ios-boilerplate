<!-- ============================================================
     OUTLOOK DESIGN SYSTEM — RULES FILE (V1.2)
     Production locations:
       Claude Code  → .claude/rules/outlook-design-system.md
       GitHub Copilot → .github/copilot-instructions.md
     Changes from V1.1:
       - Rule 2 now requires decision-tree-first ordering (closes 27.3 row 32)
       - Rule 5 adds explicit scope guard — cannot be used as cover
         when ODS returns an entry (closes 27.3 row 6 motivated reasoning)
       - NEW rule 12: ODS-canonical values when base Fluent rejects
         (closes 27.3 rows 6 + 33 — collapses old V1.2 candidates A and C)
     ============================================================ -->
---
paths:
  - "OutlookBoilerplate/**/*.swift"
---

# Outlook Design System

## What this file is

This is a rules file. It defines WHEN and WHY to query the Fluent MCP — not how to use it. The Fluent MCP's own SKILL.md handles workflow and lookup procedures.

## Core principle

The Outlook Design System (ODS) is an override layer on top of Fluent React v9. Fluent is the baseline. ODS only specifies where Outlook deviates — restricted variants, added intents, required tokens, decision trees. If ODS is silent on a component or property, Fluent defaults are correct.

**Two MCP edges to keep in mind:**

- `search_fluent_*` and `validate_fluent_*` reach base Fluent.
- `ask_fluent_agent(knowledge_base: "outlook")` reaches the ODS knowledge base.

These are different calls. Querying base Fluent does not reach ODS. Without `ask_fluent_agent`, only generic Fluent is returned — Outlook overrides, decision trees, and patterns like OOF banner / presence / reading-pane composition will not appear.

## Rules

### 1. Query the Fluent MCP before writing UI code — and cite the response inline

Before any decision about a Fluent component, prop, token, or icon, run the matching Fluent MCP tool and cite the response chunk in your reply.

- **Component picks** → `mcp__fluent__search_fluent_components`
- **Spacing / color / typography** → `mcp__fluent__search_fluent_tokens`
- **Icons** → `mcp__fluent__search_fluent_icons`
- **Outlook-specific guidance** (allowed variants, decision trees, ODS overrides, patterns like OOF banner / presence / reading-pane / mail card) → `mcp__fluent__ask_fluent_agent` with `knowledge_base: "outlook"`. This is the call that reaches the ODS knowledge base. Without it, only base Fluent is returned.

**Confidence in prior knowledge of Fluent is not grounds to skip the query.** If you can recall the API from training, query anyway — the MCP exists specifically to override training-data recall, which can be stale, version-mismatched, or wrong for Outlook's overrides.

Citation = the query string + the relevant response chunk, alongside or before the code. *"I checked the MCP"* without a chunk does not count.

### 2. Walk ODS decision trees BEFORE component selection

Before picking a component, query `ask_fluent_agent(knowledge_base: "outlook")` with the user's actual question. ODS may return a decision-tree or routing file (e.g., `notifications.md`) that redirects the request to a specific component or surface — you cannot pick a component until the tree returns.

The tree may redirect to:
- A different component than the user named (e.g., MessageBar → Toast)
- A different surface than the user assumed (e.g., reading pane → header banner)
- A specific variant or token treatment that base Fluent doesn't directly expose

Once the tree returns, continue with `ask_fluent_agent` for any of:
- Allowed variants, sizes, intents, or appearances for Outlook
- Outlook-specific patterns (OOF banner, presence, mail card, reading pane composition)
- ODS-custom tokens or token usage rules

The first useful response from `ask_fluent_agent` is not necessarily authoritative on routing. If the response references another file by name, query that file before treating the first as final. Confidence in the first answer is the documented failure mode (see `[[27.1 ods-rules-learnings]]` §3).

Pass the actual user question. Cite the returned guidance verbatim before any code.

### 3. Follow ODS overrides over Fluent defaults

If `ask_fluent_agent` returns an Outlook-specific override (restricted variants, added intents, required tokens, decision tree redirects), follow the override — not the base Fluent default.

The difference: a Fluent default is what ships with the base library. An Outlook override is what this product requires instead.

When base Fluent's TypeScript rejects an ODS-canonical value, see rule 12. **Do not invoke rule 5 as a justification for falling back when ODS has returned an entry.**

### 4. Follow decision trees over user intent

If ODS guidance redirects to a different component than the one requested, follow the redirect. A user asking for a MessageBar to prevent a destructive action should get a Dialog. The decision tree is authoritative.

When substituting, explain: what was requested, what ODS requires instead, and which rule or decision-tree step drove the decision.

### 5. Fall back to Fluent ONLY when ODS is fully silent

This rule fires only when `ask_fluent_agent(knowledge_base: "outlook")` returns NO ODS-specific entry for the component or pattern. *"ODS is silent"* means: the agent has no entry, no guidance, no decision tree, no custom token reference for the question asked.

ODS is **NOT** silent when:
- The agent returns an entry whose value base Fluent's TypeScript rejects (see rule 12)
- The agent returns guidance whose visual treatment requires custom tokens
- The agent returns a decision tree you haven't yet walked
- The agent returns a partial answer that references another file you haven't queried

If ODS is genuinely silent, use Fluent React v9 defaults. Do not invent Outlook-specific overrides. Do not guess.

**Anti-pattern (documented in `[[27.3]]` row 6):** Do not invoke rule 5 to justify a pragmatic choice when an ODS entry exists. The honest path is rule 3 (follow the override) or rule 12 (cast + custom tokens). Picking the rule that endorses the easier path is motivated reasoning under rule selection.

### 6. Do not approximate components with custom HTML

Every surface, container, and interactive element that has a Fluent or ODS equivalent must use that component. Do not simulate components with raw HTML elements. Custom HTML is only acceptable for layout primitives (wrappers, spacing, page structure) with no Fluent equivalent.

### 7. Check existing usage in this repository

Before writing a new instance of a component, check how that same component is already used in this codebase. The Fluent MCP tells you what is correct. The codebase tells you how it is implemented here — wrapper components, import paths, local conventions. Follow both.

### 8. Do not guess component APIs

Do not assume variant names, token values, or component APIs from memory. The Fluent MCP is the source of truth. A lookup takes seconds; an incorrect implementation wastes a design review cycle.

### 9. Spacing, color, and typography come from `tokens.*`

Padding, margin, gap, color, and font values reference Fluent tokens — never raw px or hex literals. If you don't know the right token, query `search_fluent_tokens` first. Existing repo px literals are not a license to add new ones.

### 10. Validate after writing

After producing a Fluent component, call `mcp__fluent__validate_fluent_component` and surface any violations before declaring the work done.

### 11. Local verification before any Fluent decision

Before writing a Fluent component, run these checks — they are local and free:

1. `grep -rn "<ComponentName" src/` — match existing usage if found.
2. Confirm the resolved package version in `package.json`.
3. Read the package's `.d.ts` to verify exports and prop shapes.

Skipping these out of confidence is a violation of rule 1.

### 12. ODS-canonical values when base Fluent rejects

When ODS specifies a value that base Fluent's TypeScript rejects (e.g., `intent="oof"` when `MessageBarIntent` has no `"oof"`), do not fall back to a Fluent-allowed value. Two-step procedure:

**Step 1 — Hold the ODS-canonical, cast if TypeScript requires.**

```tsx
<MessageBar intent={"oof" as MessageBarIntent}>
```

The cast is a code-side accommodation for a type-system limitation. It is not an admission that the value is wrong. Comment the cast with a reference to the ODS guidance that returned the value.

**Step 2 — Query `ask_fluent_agent(knowledge_base: "outlook")` for the visual treatment.**

Ask explicitly: *"What custom tokens (background, border, color) does the [component name + variant] use in Outlook?"* Apply the returned tokens via `makeStyles` overrides on the component. If no custom tokens are returned, surface that as a knowledge-base content gap rather than guessing or reverting to a Fluent fallback.

**Why this rule exists.** Premature commitment to a Fluent fallback closes the door on the visual-treatment query (see `[[27.1 ods-rules-learnings]]` §3, driver 4). Once you decide "this is just an info MessageBar with a different icon," you stop asking what the spec'd visual actually is. Hold the canonical value first; the token query becomes the natural next step.

**Rule 5 does not apply** when ODS specifies a value. The TypeScript rejection is a code-side limitation, not ODS silence.
