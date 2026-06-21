# MIG-M2.8-PRE — Namespace/Version Collision Matrix (addendum, docs-only, no merge)

> **Type:** addendum к MIG-M2.8-PRE frontend roster-audit (IL-424). **Status:** roster НЕ выбран —
> operator gate. Дополняет roster-audit точной namespace/version-фактурой.
> **Canon:** ADR-102 (Duplication Audit), factory-only (shell = read-only audit), no
> `--admin`/`--auto`/bypass, ADR-059-A append-only.
> **Baseline:** banxe-architecture origin/main `45e4a9e`; max il_ts IL-428.
> **Sources (read-only):** banxe-platform (branches: `main`, `factory/ai-onboarding`);
> banxe-ui (branches: `main`, `feat/ai-onboarding`, `refactor/claude-ai-scaffold`,
> `s8-chatshell-wiring`).

---

## 1. Scope

Дополнение к **MIG-M2.8-PRE-frontend-roster-audit.md** (IL-424): точная **package-name +
version** фактура двух конкурирующих frontend-монорепо для operator roster-решения. Canonical
target по-прежнему **НЕ выбирается фабрикой** (§7) — этот addendum только перечисляет, что именно
придётся разрешить при каждом варианте.

---

## 2. Package-name inventory (verified, workspace package.json)

| Repo | Package | Path |
|---|---|---|
| banxe-platform | `banxe-platform` (root) | `package.json` |
| banxe-platform | `@banxe/web` | `packages/web` |
| banxe-platform | `@banxe/mobile` | `packages/mobile` |
| banxe-platform | `@banxe/shared` | `packages/shared` |
| banxe-ui | `banxe-ui` (root) | `package.json` |
| banxe-ui | `@banxe/web-next` | `apps/web-next` |
| banxe-ui | `@banxe/web-vite` | `apps/web-vite` |
| banxe-ui | `@banxe/mobile` | `apps/mobile` |
| banxe-ui | `@banxe/shared` | `packages/shared` |
| banxe-ui | `@banxe/ui` | `packages/ui` |
| banxe-ui | `@banxe/design-tokens` | `packages/design-tokens` |
| banxe-ui | `@banxe/storybook` | `storybook` |
| banxe-ui | `@banxe/mocks` | `mocks` |

---

## 3. Collision matrix

### 3a. Name collisions (одинаковое имя в обоих репо — прямой merge невозможен)
| Package | banxe-platform | banxe-ui | Конфликт |
|---|---|---|---|
| **`@banxe/mobile`** | `packages/mobile` (Expo 53 / RN 0.76.5) | `apps/mobile` (Expo 53 / RN 0.76.9) | **name+role collision** |
| **`@banxe/shared`** | `packages/shared` | `packages/shared` (api/hooks/types) | **name collision, разное содержимое** |

### 3b. Role-overlap, different name (дублирующий web shell)
| Роль | banxe-platform | banxe-ui | Расхождение |
|---|---|---|---|
| web app-shell | `@banxe/web` — **Next 15.3 / React 19** | `@banxe/web-next` — **Next 16.2 / React 19.2** | major Next divergence (15→16) |

### 3c. Version divergence
| Стек | banxe-platform | banxe-ui | Δ |
|---|---|---|---|
| Next.js | 15.3 | 16.2 | major (15→16) |
| React | 19 | 19.2 | minor |
| React Native | 0.76.5 | 0.76.9 | patch (близкие) |
| Expo SDK | 53 | 53 | равны |

---

## 4. Unique-to-each

| Только в banxe-ui (design-system слой) | Только в banxe-platform |
|---|---|
| `@banxe/ui` (primitives, financial components) | app-shell зрелость: SCA/PSD2 wired |
| `@banxe/design-tokens` | infra/docker/n8n/playwright e2e |
| `@banxe/storybook` | ROADMAP «THE frontend monorepo» (Phase 2/3/4 COMPLETE) |
| `@banxe/web-vite` (chat/AI-onboarding prototype) | — |
| `@banxe/mocks` | — |

---

## 5. Implication per roster option (что разрешать в каждом варианте)

### (A) banxe-ui canonical (platform → retire/merge)
- Перенести в ui platform-уникальное: SCA/PSD2-обвязку, infra/docker/playwright.
- `@banxe/web` (platform Next 15.3) → слить в `@banxe/web-next` (Next 16.2) или retire.
- Коллизии `@banxe/mobile`/`@banxe/shared`: ui-версии становятся canonical; platform-дельта вливается.

### (B) banxe-platform canonical (ui → design-system source)
- Импортировать из ui: `@banxe/ui` + `@banxe/design-tokens` (+ `@banxe/storybook`).
- Поднять platform web до Next 16 (или сознательно остаться на 15.3).
- `@banxe/web-vite` (chat) → влить в platform-web как feature или retire.
- Коллизии: platform-версии canonical; ui остаётся только design-system (без дублирующих shells).

### (C) split по ролям (разводит коллизии разделением)
- `banxe-ui` = **library** (`@banxe/ui`, `@banxe/design-tokens`, `@banxe/storybook`) — без `@banxe/web*`/`@banxe/mobile`/`@banxe/shared`-shells.
- `banxe-platform` = **app shells** (web/mobile) + infra + SCA, потребляет `@banxe/ui` + `@banxe/design-tokens`.
- Требует: единый `@banxe/shared` (один owner), `@banxe/mobile` остаётся только в platform, унификация Next/RN.

> Во ВСЕХ вариантах обязательны: **rename/dedup `@banxe/shared` + `@banxe/mobile`**, **unify Next
> (15.3↔16.2) + RN (0.76.5↔0.76.9)**, и **branch→main promotion-решение** (§6).

---

## 6. Branch status

- **banxe-platform:** `main` + активная feature-ветка `factory/ai-onboarding`.
- **banxe-ui:** `main` + активные feature-ветки `feat/ai-onboarding`, `refactor/claude-ai-scaffold`,
  `s8-chatshell-wiring`.
- Последняя AI-onboarding / chat-работа ведётся на **feature-ветках**, не на `main` обоих репо →
  любой canonical-выбор требует **promotion-решения** (какая ветка какого репо станет основой).

---

## 7. Open governance item

- **Roster-выбор (A/B/C) = operator-решение** (M2.8 precondition). Фабрика НЕ выбирает canonical.
- **Collision-resolution стартует ПОСЛЕ выбора:** после operator-выбора A/B/C → отдельный шаг
  (ADR + ledger) фиксирует canonical target + plan по §5 (rename/dedup `@banxe/shared`+
  `@banxe/mobile`, unify Next/RN, branch→main promotion) → старт M2.8 frontend track.
- **До operator-решения** collision-resolution не начинается; canonical target в этом addendum
  **не фиксируется**.
- **Связанный gate (независимый):** KYC/KYB/AML — только после I-27 HITL-L4 sign-off.

---

### Refs
MIG-M2.8-PRE-frontend-roster-audit.md (IL-424); MIG-CLOSURE-non-gated-complete.md (IL-428);
banxe-platform (`@banxe/web`/`@banxe/mobile`/`@banxe/shared`); banxe-ui (`@banxe/web-next`/
`web-vite`/`mobile`/`shared`/`ui`/`design-tokens`/`storybook`/`mocks`); ADR-102, ADR-059-A; I-27.
