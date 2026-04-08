# UI-PLANE-OPERATING-MODEL.md — UI Work & BANXE Governance
**Plane:** Architecture | **Updated:** 2026-04-08

---

## Plane Assignment

| Asset | Plane | Repo | Rationale |
|-------|-------|------|-----------|
| UI/UX research docs | Architecture | banxe-architecture/docs/ | Architectural decisions |
| Design system spec | Architecture | banxe-architecture/docs/ | Governs both planes |
| Screen inventory | Architecture | banxe-architecture/docs/ | Authoritative screen catalog |
| Design tokens source | Developer | banxe-ui/packages/design-tokens/ | Shared tooling |
| Component library prototype | Developer | banxe-ui/packages/ui/ | Prototype, not production |
| Web app prototype | Developer | banxe-ui/apps/web/ | Prototype, not production |
| Mobile app prototype | Developer | banxe-ui/apps/mobile/ | Prototype, not production |
| Storybook | Developer | banxe-ui/storybook/ | Component documentation |
| Mock data | Developer | banxe-ui/mocks/ | Never enters Product Plane |
| Promoted web components | Product | banxe-emi-stack/ui/ | After promotion + review |
| Promoted mobile components | Product | banxe-emi-stack/mobile/ | After promotion + review |

**GUIYON / SS1:** No UI assets from BANXE are shared with Standby Plane projects. Zero cross-contamination.

---

## Developer Plane Permissions

In `banxe-ui/`:
- Free to experiment with new UI patterns
- v0.dev / bolt.new generated code may be used as **structural reference** (must be rewritten)
- Figma designs may be directly implemented
- Prototype code does NOT need quality-gate PASS before commit
- Mock data may contain FAKE_ names/IBANs (not real PII)
- No real API keys, no real banking credentials in any file

**Controls still active in Developer Plane:**
- No real customer PII in any file (even fake-looking)
- No financial logic (amounts, AML rules) — that lives in banxe-emi-stack
- IL entry required when starting a significant UI feature
- MEMORY.md updated when significant decisions are made

---

## Product Plane Controls

Code reaches Product Plane (`banxe-emi-stack/`) only via **promotion**.

**Promotion checklist (mandatory — no exceptions):**
```
□ UI quality gate PASS (TypeScript + lint + unit tests + Storybook build)
□ Accessibility: 0 critical axe violations
□ Design review: matches BANXE-UI-UX-SYSTEM.md
□ Compliance review: correct display of BLOCKED / REVIEW / pending states
□ All AI features labeled (AI badge + confidence) 
□ Decimal precision: all amount displays use correct formatting (not float)
□ No hardcoded values — all colors/spacing from design tokens
□ IL entry in INSTRUCTION-LEDGER.md with proof
□ CEO review for compliance-critical screens
□ git commit message includes IL reference
```

**Promotion is NOT automatic.** It requires explicit CEO decision and IL entry.

---

## Prototype Code Promotion Path

```
banxe-ui/packages/ui/financial/BalanceWidget/    ← Developer Plane (prototype)
         ↓  [promotion checklist PASS]
banxe-emi-stack/ui/components/BalanceWidget/     ← Product Plane (production)
```

During promotion:
- File moves (not copy) to prevent dual maintenance
- All FAKE_ mock data references removed
- Real API client injected (not mock handlers)
- Additional integration tests added

---

## Skills / Orchestration Integration

UI/app work integrates with existing BANXE skill model as follows:

| Existing Skill | UI Relevance |
|---------------|-------------|
| `implement-feature` | Extends to UI: Port (API contract) → Service (state logic) → Component (UI) |
| `create-migration` | Not directly relevant to UI |
| `deploy-gmktec` | Extended to: build banxe-ui → deploy static assets to GMKtec nginx |
| `Clean Architecture Enforcer` | Applies to: component layer isolation (primitives → financial → screens) |
| `Smart Test Generator` | Applies to: component unit tests + story tests |
| `API Contract Guardian` | Critical: web API client must match banxe-emi-stack endpoint contracts |
| `Context Memory Sync` | MEMORY.md captures UI decisions for cross-session continuity |

---

## UI Passport (Proposed — Lean)

If a dedicated UI orchestration agent is justified (when banxe-ui scales), create:

```yaml
# banxe-architecture/agents/passports/ui_orchestrator.yaml
agent_id: ui-orchestrator
name: "UI Orchestrator"
version: "1.0.0"
status: PROPOSED  # not yet active — create when banxe-ui reaches 5+ screens
model: sonnet
trust_zone: GREEN
autonomy: L2_REVIEW

description: |
  Orchestrates UI/UX development in banxe-ui Developer Plane.
  Reads BANXE-UI-UX-SYSTEM.md and BANXE-SCREEN-INVENTORY.md as working spec.
  Delegates to: backend-engineer (component code), qa-reviewer (tests), 
  devops-engineer (deploy).
  Does NOT operate in Product Plane without CEO promotion decision.

tools: [Read, Write, Edit, Bash, Glob, Grep]
allowed_skills:
  - implement-feature  # extended to UI components
  - deploy-gmktec      # extended to static asset deploy
prohibited_skills:
  - create-migration   # UI does not own schema

plane_permissions:
  developer: FULL
  product: READ_ONLY  # can read API contracts, cannot write
  standby: PROHIBITED
```

**Status: PROPOSED** — create only when banxe-ui reaches active development with 5+ screens.

---

## How This Fits BANXE's Reality Today

Current state:
- banxe-emi-stack: 520 tests, 81% coverage, quality-gate active
- banxe-architecture: 14 agent passports, governance complete
- developer-core: GSD framework + Spec-First methodology (IL-045 DONE)
- banxe-ui: **does not exist yet** (this document authorizes its creation)

Next step:
1. Create `~/banxe-ui/` as git repo (Developer Plane)
2. Execute pipeline stages 1-3 (research + tokens)
3. Scaffold minimum viable prototype per BANXE-UI-ARCHITECTURE.md
4. Iterate under Claude Code interactive workflow
5. Promote first components to Product Plane when promotion checklist passes
