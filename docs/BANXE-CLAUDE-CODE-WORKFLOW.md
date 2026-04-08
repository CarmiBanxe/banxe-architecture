# BANXE-CLAUDE-CODE-WORKFLOW.md — Claude Code Interactive Workflow
**Plane:** Architecture | **Updated:** 2026-04-08

---

## Starting a New UI Feature

Every UI feature starts with spec, not code.

```
Step 1: Identify the screen in BANXE-SCREEN-INVENTORY.md
Step 2: Note required components, states, data
Step 3: Check if any required component already exists in packages/ui/
Step 4: Read existing token definitions (packages/design-tokens/tokens/)
Step 5: Write the component spec as a comment block or .spec.md before coding
Step 6: Implement: tokens → component → story → test → screen
```

**Slash command:** `/gsd-quick "Implement BalanceWidget component"`

---

## Resuming Context Between Sessions

Claude Code does not retain session state. Context must be file-based.

**At session start, always read:**
```bash
# Claude Code should read these at the start of every UI session:
cat ~/banxe-ui/README.md                          # workspace overview
cat ~/developer/.planning/STATE.md                # current sprint state
cat ~/banxe-architecture/docs/BANXE-SCREEN-INVENTORY.md  # target screens
cat ~/banxe-architecture/docs/BANXE-UI-UX-SYSTEM.md      # design system
```

**Memory hook approach:**
Use `~/developer/.planning/STATE.md` to record what was last worked on.
Update STATE.md after each completed task before ending session.

---

## Spec-Before-Code Rule (mandatory)

Before writing a component:

```markdown
# Component Spec: BalanceWidget
Purpose: Display user's balance with available/pending breakdown
Variants: loaded | loading | error | privacy-mode
Props:
  - currency: string (ISO 4217)
  - total: Decimal
  - available: Decimal
  - pending: Decimal
  - privacyMode: boolean
Token usage:
  - text-3xl bold monospace for amount
  - --color-text-secondary for labels
  - --color-warning for pending
States:
  - loading: show AmountSkeleton
  - error: show "Balance unavailable" + retry
  - privacy-mode: replace amount with "••••"
Accessibility:
  - aria-label: "{available} available, {pending} pending in {currency}"
  - privacy toggle: aria-pressed
```

Write this spec as a comment in the component file, or in a `*.spec.md` file.
Do not skip this — it prevents hallucinated APIs and inconsistent state handling.

---

## Component-Aware Development

Claude Code reads existing components before writing new ones.

**Mandatory context reads for any UI work:**
```bash
# Before writing a new component:
cat packages/ui/src/index.ts          # what already exists
cat packages/design-tokens/build/js/tokens.ts  # available tokens
ls packages/ui/src/financial/         # existing financial components
```

**Avoid hallucination rule:**
If a Tailwind class or token doesn't exist in the token file → do not invent it.
Only use tokens defined in `packages/design-tokens/tokens/*.json`.

---

## Storybook / Component Context

Every new component needs a Storybook story before it is considered "done".

**Story template:**
```tsx
// BalanceWidget.stories.tsx
import type { Meta, StoryObj } from '@storybook/react'
import { BalanceWidget } from './BalanceWidget'

const meta: Meta<typeof BalanceWidget> = {
  title: 'Financial/BalanceWidget',
  component: BalanceWidget,
  parameters: { layout: 'centered' },
}
export default meta
type Story = StoryObj<typeof BalanceWidget>

export const Loaded: Story = {
  args: { currency: 'GBP', total: '1300.00', available: '1250.00', pending: '50.00' }
}
export const Loading: Story = { args: { loading: true } }
export const PrivacyMode: Story = { args: { ...Loaded.args, privacyMode: true } }
export const Error: Story = { args: { error: true } }
```

Run Storybook during development: `npm run storybook`
Build check: `npm run build-storybook` (catches render errors before commit)

---

## Design Token Usage

**Rule:** Never hardcode colors, sizes, or spacing in component files.
Always import from generated tokens or use Tailwind classes mapped to tokens.

**Web (Tailwind):**
```tsx
// WRONG:
<div style={{ color: '#E8EDF5', padding: '24px' }}>

// CORRECT:
<div className="text-primary p-6">
// where text-primary maps to --color-text-primary via tailwind.config.ts
```

**React Native:**
```tsx
import { tokens } from '@banxe/design-tokens/rn'
// CORRECT:
<Text style={{ color: tokens.color.textPrimary, fontSize: tokens.text['2xl'] }}>
```

---

## Avoiding Hallucinated Components

Common failure modes to prevent:

| Failure | Prevention |
|---------|-----------|
| Using non-existent shadcn/ui component | Run `ls packages/ui/src/primitives/` first |
| Using undefined Tailwind class | Check tailwind.config.ts extensions |
| Wrong token name | Read tokens.ts before using |
| Inventing API response shape | Read mocks/data/*.json first |
| Wrong import path | Check packages/ui/src/index.ts barrel |

**Claude Code instruction:** Always read relevant existing files before writing new code.

---

## When to Use Sub-Agents / Agent Teams

| Task | Solo Claude Code | Sub-agent |
|------|-----------------|-----------|
| Single component | ✅ solo | |
| Token + component + story + test | ✅ solo (sequential) | |
| Full screen (5+ components) | | ✅ parallel agents |
| Web + mobile parallel implementation | | ✅ parallel agents |
| Research + implement in one session | | ✅ research agent first |

**Parallel is safe when:** Components have no shared state and no shared file writes.
**Must be sequential when:** Token build → component → story (each step depends on previous).

---

## Task Sequencing Rules

**Mandatory sequential order:**
```
1. Token build (packages/design-tokens)
2. Primitive component (packages/ui/primitives/)
3. Financial component (packages/ui/financial/) — depends on primitives + tokens
4. Story (packages/ui/stories/) — depends on component existing
5. Unit test — depends on component existing
6. Screen (apps/web/screens/) — depends on components existing
7. E2E test — depends on screen existing
8. Accessibility check — depends on screen existing
```

**Safe to parallelize:**
- Multiple unrelated components at the same layer
- Web screen + mobile screen for same feature (once components exist)
- Multiple Storybook stories for same component

---

## When Human Review is Required

| Situation | Action |
|-----------|--------|
| Compliance-sensitive UI (BLOCKED state, AML flag display) | CEO review before commit |
| Any screen that involves financial amounts | Review amount formatting with Decimal |
| AI Assistant UI framing changes | CEO review (trust/confidence display) |
| Accessibility violations found | Fix before commit — not "fix later" |
| Visual regression detected (Playwright screenshots differ) | Human approval to accept/reject |
| Promotion of prototype code to Product Plane | Full IL review + quality gate |

---

## Recommended Slash Commands for UI Work

```
/gsd-quick "implement BalanceWidget with loading + privacy states"
/gsd-quick "add Storybook story for TransactionRow — all states"
/gsd-quick "add axe accessibility test for Dashboard screen"
/gsd-health  ← check token build + Storybook + lint + tests
```

---

## Recommended Hooks for UI Work

```bash
# .claude/hooks/pre-tool/check-token-exists.sh
# Before any Edit to a component file — verify token names used are defined
# Purpose: prevent hardcoded values sneaking in

# .claude/hooks/post-edit/run-storybook-check.sh  
# After editing a component — run: npm run build-storybook --filter=ui
# Purpose: catch render errors immediately
```

These hooks are **optional** in prototype phase, **mandatory** before Product Plane promotion.
