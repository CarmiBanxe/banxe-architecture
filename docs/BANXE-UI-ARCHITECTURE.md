# BANXE-UI-ARCHITECTURE.md — Implementation Architecture
**Plane:** Architecture | **Updated:** 2026-04-08

---

## Repo Placement Decision

**Prototype workspace → new dedicated repo: `banxe-ui`**

Rationale:
- Developer Plane principle: prototype tooling lives in developer-core or dedicated UI repo, NOT in banxe-emi-stack
- banxe-emi-stack is Product Plane — only reviewed, quality-gated, production-grade code
- UI prototype code requires promotion before entering Product Plane
- Plane isolation: `banxe-ui` = Developer Plane artifact (prototype + design system)
- When a component is mature + quality-gated → it moves into banxe-emi-stack (or a shared packages/ sub-dir)

```
Prototype exploration:   ~/banxe-ui/          (Developer Plane)
Production UI code:      ~/banxe-emi-stack/   (Product Plane — promoted only)
Architecture docs:       ~/banxe-architecture/ (Architecture Plane — this repo)
```

---

## Repository Structure

```
banxe-ui/
├── README.md
├── package.json                    # root monorepo manifest (npm workspaces)
├── turbo.json                      # Turborepo build config (optional, add when needed)
├── .gitignore
├── .eslintrc.json                  # shared ESLint config
├── tsconfig.base.json              # shared TypeScript config
│
├── docs/                           # UI-specific docs (supplement banxe-architecture)
│   └── COMPONENT-DECISIONS.md     # why we chose X over Y per component
│
├── packages/
│   ├── design-tokens/              # SINGLE SOURCE OF TRUTH for all design decisions
│   │   ├── package.json
│   │   ├── tokens/
│   │   │   ├── colors.json         # Style Dictionary source
│   │   │   ├── typography.json
│   │   │   ├── spacing.json
│   │   │   ├── radii.json
│   │   │   └── shadows.json
│   │   ├── build/                  # generated (gitignored)
│   │   │   ├── css/variables.css
│   │   │   ├── js/tokens.ts
│   │   │   └── rn/tokens.ts        # React Native compatible
│   │   └── style-dictionary.config.js
│   │
│   └── ui/                         # Shared component library
│       ├── package.json
│       ├── tsconfig.json
│       ├── src/
│       │   ├── index.ts            # barrel export
│       │   ├── primitives/         # unstyled base (Radix UI wrappers)
│       │   │   ├── Button/
│       │   │   ├── Input/
│       │   │   ├── Dialog/
│       │   │   └── ...
│       │   └── financial/          # BANXE-specific financial components
│       │       ├── BalanceWidget/
│       │       ├── TransactionRow/
│       │       ├── StatusChip/
│       │       ├── AmountInput/
│       │       ├── AIInsightCard/
│       │       └── ComplianceFlag/
│       └── stories/                # Storybook stories per component
│           └── *.stories.tsx
│
├── apps/
│   ├── web/                        # React web application
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── vite.config.ts
│   │   ├── index.html
│   │   ├── public/
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── App.tsx
│   │       ├── router.tsx          # React Router v6
│   │       ├── layouts/
│   │       │   ├── AppLayout.tsx   # sidebar + main content
│   │       │   └── AuthLayout.tsx  # login/onboarding shell
│   │       ├── screens/            # one dir per screen (W-01 to W-06)
│   │       │   ├── Dashboard/
│   │       │   ├── Transactions/
│   │       │   ├── Wallets/
│   │       │   ├── Send/
│   │       │   ├── AIAssistant/
│   │       │   └── Profile/
│   │       ├── api/                # API client (mock or real)
│   │       │   ├── client.ts       # axios/fetch wrapper + JWT interceptor
│   │       │   └── endpoints/      # typed API calls per domain
│   │       └── hooks/              # shared React hooks
│   │
│   └── mobile/                     # Expo React Native application
│       ├── package.json
│       ├── app.json
│       ├── tsconfig.json
│       ├── app/                    # Expo Router file-based routing
│       │   ├── _layout.tsx         # root layout + bottom tabs
│       │   ├── (tabs)/
│       │   │   ├── index.tsx       # M-01 Dashboard
│       │   │   ├── transactions.tsx # M-02
│       │   │   ├── wallet.tsx      # M-03
│       │   │   ├── send.tsx        # M-04
│       │   │   └── profile.tsx     # M-06
│       │   └── ai-assistant.tsx    # M-05 (modal/full-screen)
│       └── src/
│           ├── components/         # mobile-only components
│           └── hooks/
│
├── storybook/                      # Storybook workspace
│   ├── .storybook/
│   │   ├── main.ts
│   │   └── preview.tsx             # global decorators + token injection
│   └── package.json
│
├── mocks/                          # Mock API data (shared web + mobile)
│   ├── data/
│   │   ├── transactions.json
│   │   ├── wallets.json
│   │   └── customer.json
│   └── handlers/                   # MSW (Mock Service Worker) handlers
│       └── index.ts
│
├── tests/
│   ├── unit/                       # Component unit tests (Vitest)
│   ├── e2e/                        # Playwright E2E tests
│   ├── a11y/                       # Accessibility tests (axe-core)
│   └── visual/                     # Screenshot regression (Playwright)
│
└── scripts/
    ├── banxe-build.sh              # Main build + generation pipeline
    ├── build-tokens.sh             # Style Dictionary token build
    └── check-a11y.sh               # Accessibility check runner
```

---

## Component Strategy

### Ownership Model
All components are **owned locally** (no npm black-box components).
Foundation: `shadcn/ui` components are **copied into repo** via CLI — you own the code.

```
Layer 1: Radix UI primitives (headless, accessible — npm dependency, stable)
Layer 2: shadcn/ui copied components (Tailwind-styled, in packages/ui/primitives/)
Layer 3: BANXE financial components (custom, in packages/ui/financial/)
Layer 4: Screen-level compositions (in apps/web/screens/ + apps/mobile/)
```

### Design Token Strategy
- **Single source of truth:** `packages/design-tokens/tokens/*.json`
- **Build tool:** Style Dictionary
- **Outputs:**
  - `build/css/variables.css` → imported in web app global CSS
  - `build/js/tokens.ts` → imported in components for JS usage
  - `build/rn/tokens.ts` → imported in React Native components

Token sync guarantee: mobile and web always use the same token values.
If token changes → rebuild → both apps updated simultaneously.

### Mobile/Web Synchronization
```
Shared:
  packages/design-tokens → both apps
  packages/ui (financial components) → web direct, mobile via RN-adapted versions
  mocks/data/*.json → both apps (MSW web, direct import mobile)
  
Not shared:
  Layout components (sidebar vs bottom tabs)
  Navigation primitives (React Router vs Expo Router)
  Platform-specific interactions (hover vs touch)
```

### Reuse Decision Rule
> If a component contains financial logic (amounts, status, AI framing) → `packages/ui/financial/`
> If a component is pure UI primitive (button, input, modal) → `packages/ui/primitives/`
> If a component is screen-specific composition → `apps/*/screens/`

---

## Mock Data Strategy

- `mocks/data/`: static JSON fixture files. Realistic but not real PII.
- `mocks/handlers/`: MSW request handlers — intercept API calls in web prototype.
- Mobile: direct import of JSON fixtures during prototype phase.
- Graduation: replace mock handlers with real API calls via `apps/*/api/client.ts`.

Data format mirrors actual banxe-emi-stack API response shapes.
Use `FAKE_` prefix for all names: `FAKE_John Smith`, `FAKE_IBAN`.

---

## Testing Strategy

| Type | Tool | Where | When |
|------|------|-------|------|
| Component unit | Vitest + Testing Library | tests/unit/ | Every component in packages/ui |
| Screen integration | Vitest + MSW | tests/unit/ | Key screen flows |
| E2E | Playwright | tests/e2e/ | Core user journeys (W-01 to W-06) |
| Accessibility | axe-playwright | tests/a11y/ | All screens, mandatory |
| Visual regression | Playwright screenshots | tests/visual/ | Core components |
| Storybook | Storybook test-runner | storybook/ | All stories must render |

---

## Storybook Strategy

- Every component in `packages/ui/` MUST have a `.stories.tsx` file.
- Stories cover: default state, all variants, all relevant states (loading/error/empty).
- Storybook is the **component contract** — if a component renders in Storybook, it works.
- Design tokens injected via global preview decorator.
- Chromatic (cloud visual regression): acceptable for non-sensitive UI screenshots.

---

## Quality Gate for UI

```bash
# UI quality gate (analogous to banxe-emi-stack quality-gate.sh)

Step 1: Token build (must succeed before anything else)
  cd packages/design-tokens && npm run build

Step 2: TypeScript check
  npx tsc --noEmit (all workspaces)

Step 3: Lint
  npx eslint src/ --max-warnings 0

Step 4: Unit tests
  npx vitest run

Step 5: Storybook build (catches component render errors)
  npm run build-storybook

Step 6: Accessibility check
  bash scripts/check-a11y.sh

Step 7: E2E (optional in prototype phase, mandatory before promotion)
  npx playwright test

Exit 0 = PASS → eligible for stakeholder review or promotion consideration
Exit 1 = FAIL → do not promote to Product Plane
```

---

## Artifact Review Strategy

Before any prototype artifact is promoted to Product Plane:
1. UI quality gate must PASS
2. Accessibility audit must show 0 critical violations (axe-core)
3. Design review: does it match BANXE-UI-UX-SYSTEM.md?
4. Compliance review: does it correctly display all sensitive states (BLOCKED, REVIEW, EDD)?
5. IL entry in INSTRUCTION-LEDGER.md with proof
6. Claude Code review (not automated — actual code read)
