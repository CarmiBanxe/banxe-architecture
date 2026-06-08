# HANDOFF — Target Frontend Repo Bootstrap

Date: 2026-06-08
Status: DRAFT (Sprint 3 Step 1; ADR-057, I-28 append-only)
IL: IL-156
Branch: il-155-handoff-target-frontend-repo
Parent: dependency-map-trading-frontend.md (IL-154); trading-ui-group-SPEC-2026-05-23.md (SPEC #4)
Related ADRs: ADR-016 (trading-ui migration), ADR-017 (Keycloak auth), ADR-019 (GraphQL→REST), ADR-021 (ExchangePort), ADR-057 (append-only immutability)

> **Scope note (immutable).** This handoff bootstraps a **NEW banking frontend**. It is **NOT** a revival of the Binance-style legacy app. The legacy projects `banxe-trade-view` / `banxe-trade-view-new` are **only a reuse source** per the IL-154 dependency map — never a base to fork or resurrect.
>
> **Canon guardrails for Step 2 (operator-gated).** No repo is created, no branch protection is changed, and no PR is opened by this document. Those are operator signals. This is a read-only diagnosis + draft only.

---

## 1. Target repo — recommendation

### Candidates inspected (read-only)

| Repo | Identity | Layout | Guardian gates | Branch protection (main) | Verdict |
|---|---|---|---|---|---|
| `CarmiBanxe/banxe-ui` | "UI prototype workspace (Developer Plane)", CANON v1.3 | pnpm+turbo monorepo: `apps/{mobile,web-next,web-vite}`, `packages/{design-tokens,ui,shared}`, storybook, mocks; languages: TS 411 KB, **Python 297 KB**, HTML 236 KB | partial (`.github/` present) | **NONE** (HTTP 404 "Branch not protected") | **REUSE as component source only, NOT as target** |
| `CarmiBanxe/banxe-repo-template` | "BANXE repo template — CANON v1.0 controlled-copy baseline" | clean: `.claude/settings.json`, `.github/workflows/{claude,factory-guard,guardian}.yml`, `.gitignore`, README | **full guardian baseline wired** | n/a (template) | **SEED for new repo** |

### Recommendation: **NEW repo `banxe-trading-frontend`, seeded from `banxe-repo-template`**

**Rationale:**

1. **Clean canonical baseline.** `banxe-repo-template` already ships the three guardian-compatible workflows (`factory-guard.yml`, `guardian.yml`, `claude.yml`) and `.claude/settings.json` — the exact gate surface Section 5 requires. A new repo inherits append-only/ADR/secrets enforcement from commit zero.
2. **banxe-ui is the wrong identity.** It is an explicitly labelled *Developer-Plane prototype workspace* carrying mixed concerns: ~297 KB of Python, HTML, storybook, mocks, and a **divergent CANON v1.3** with a single-step "factory axiom" unsuited to a product frontend. Repurposing it would entangle a production banking frontend with prototype baggage and force a larger cleanup than a greenfield start.
3. **banxe-ui has no branch protection.** Adopting it as the production target would require *establishing* protection from scratch anyway — no protection is inherited by reuse.
4. **IL-154 already mandates build-fresh.** The dependency map classifies the legacy UI as REWRITE across all 8 axes ("build-fresh with extracted logic"). A fresh repo is the consistent home for that fresh build.
5. **Architectural invariants point to fresh code.** Decimal-only money (I-01), Keycloak-handled auth (ADR-017, Axis 6 = DROP), and GraphQL→REST (ADR-019, Axis 7 = DROP GQL) all require new implementations, not ports of legacy components.

**What banxe-ui IS good for:** a secondary *reuse source* — its `packages/design-tokens` and `packages/ui` may seed the new design system. That is a later extraction task (Step 5), not a repo-identity decision.

---

## 2. Branch policy

| Policy | Setting |
|---|---|
| Default branch | `main` — **protected** |
| Direct pushes to `main` | **forbidden** — PR-only |
| Required approvals | ≥1 review; dismiss stale approvals on new commits |
| Required status checks | `factory-guard`, `guardian` (ledger/append-only + ADR + secrets), typecheck, lint, test — all must pass + branches up to date |
| Merge method | **squash-merge only** (linear history; rebase/merge-commit disabled) |
| Force-push / deletion of `main` | disabled |
| Signed/linear history | linear history required |

> Establishing this protection is a **Step 2 operator action** (operator signal). This document only specifies the target state.

---

## 3. Directory layout

Feature-Sliced Design (FSD) layered structure:

```
banxe-trading-frontend/
├── src/
│   ├── app/          # app shell, providers, routing, layout composition
│   ├── features/     # order-flow, orderbook, market-data, balances, charting
│   ├── entities/     # domain models: Order, Pair, Ticker, Balance (Decimal-only, I-01)
│   └── shared/       # ui-kit, lib (typed REST/WS clients), config, types
├── public/           # static assets
├── tests/            # unit + integration (vitest); e2e (playwright) optional
└── docs/             # ADRs, runbooks, migration notes from IL-154 reuse extraction
```

Mapping from IL-154 axes → layout:
- Axis 1 Routes → `src/app`
- Axes 3/4/5 Order flow, Balances, Market data → `src/features`
- Reuse candidates (`OrderBookStream`, `typeOfOrdersCalculators`, `TradeProxy` URL map) → `src/shared/lib` + `src/features`
- Charting (license TBD, see IL-154) → `src/features/charting` (adapter boundary)

---

## 4. Package baseline

| Concern | Choice | Note |
|---|---|---|
| Framework | **React 18 + TypeScript (strict)** | `strict: true`, no `any` (global rule) |
| Build / dev | **Vite** | matches `apps/web-vite` reuse path; fast HMR |
| Package manager | **pnpm** | aligns with banxe-ui workspace; lockfile committed |
| State | **Zustand** | IL-154 recommends MobX → Zustand migration |
| Data layer | typed **REST** client + **WebSocket** stream client | GraphQL DROP (ADR-019); ExchangePort REST (ADR-021) |
| Money | **Decimal** (`decimal.js` or equiv.) | I-01: never float for money |
| Lint / format | **ESLint + Prettier** | `no-explicit-any` error-level |
| Typecheck | `tsc --noEmit` in CI | |
| Test | **Vitest** (+ Testing Library); Playwright optional | ≥80% coverage gate (GSD Phase 4) |
| Charting | **OPEN DECISION** (IL-154) | TradingView license check vs Lightweight Charts (MIT) fallback |

---

## 5. CI hooks (guardian-compatible)

Inherited from `banxe-repo-template` `.github/workflows/`, retained as required checks:

| Workflow | Gate | Maps to |
|---|---|---|
| `guardian.yml` | ledger/append-only enforcement, ADR presence, **secrets scan** | ADR-057, I-28; "no .env/secrets" rule |
| `factory-guard.yml` | factory-canon version pin, controlled-copy integrity | CANON baseline |
| `claude.yml` | Claude Code review automation | REVIEW phase (GSD 5) |

Additional repo CI (added at bootstrap, Step 2):
- `ci.yml` — install → typecheck → lint → test (coverage ≥80%) → build; required on PR.
- **pre-commit** (`.pre-commit-config.yaml`): ruff-equiv for TS (eslint), prettier, secrets-scan (gitleaks/trufflehog), no-`any` guard, conventional-commit message check.
- Hooks path: `core.hooksPath .githooks` consistent with parent canon (Quality Hook / BUG-006).

> All gates are **append-only / non-bypassable**: no skip flags. A failing gate is fixed at root cause, never silenced (per `.claude/rules/agents.md` "quality-gate.sh is always the final enforcement layer").

---

## Step 2 (awaiting operator signal — DO NOT execute now)

1. **Operator** creates `CarmiBanxe/banxe-trading-frontend` from `banxe-repo-template` (repo creation = operator signal).
2. **Operator** applies branch protection per Section 2 (branch protection = operator signal).
3. Factory task: scaffold Section 3 layout + Section 4 baseline; wire Section 5 CI.
4. Factory task: extract IL-154 reuse candidates (OrderBookStream, calculators, TradeProxy URL map) into `src/shared`/`src/features`.
5. Charting license decision (IL-154 OPEN DECISION) → ADR.
