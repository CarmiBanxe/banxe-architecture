# MIG-M2.8-PRE — Frontend Roster Reconcile/Gap-Audit (docs-only, no merge)

> **Type:** migration precondition audit (docs-only). **Status:** roster НЕ выбран — operator gate.
> **Scope:** разрешить отложенный с M2.7 roster двух конкурирующих EMI frontend-монорепо
> (`banxe-platform` vs `banxe-ui`) — precondition для M2.8 frontend track.
> **Canon:** ADR-102 (Duplication Audit — этот файл и есть dedup-аудит), factory-only (shell =
> read-only audit), no `--admin`/`--auto`/bypass, ADR-059-A append-only ledger.
> **Baseline:** banxe-architecture origin/main `4d08d1d`; max il_ts IL-423 @ 2026-06-22T03:30:00Z.
> **Sources (read-only):** banxe-platform `80c93c8` (pushed 2026-06-05); banxe-ui `463fe26`
> (pushed 2026-06-09).

---

## 1. Scope

- **M2.7 deferral:** roster `banxe-platform` vs `banxe-ui` не был разрешён → зафиксирован как
  **precondition M2.8** (frontend track нельзя стартовать без canonical-таргета).
- **Два активных EMI frontend-монорепо** существуют параллельно; оба **отсутствуют в legacy**
  (это EMI-таргеты, не legacy-источники). Legacy frontend = M1.7 shells (см. §6).
- Этот аудит — **dedup/reconcile (ADR-102)**: инвентаризировать оба, выявить overlap/divergence,
  перечислить candidate-роли. **Canonical-таргет НЕ выбирается фабрикой** — operator gate (§7).

---

## 2. banxe-platform — inventory

| Аспект | Значение |
|---|---|
| HEAD / pushed | `80c93c8` / 2026-06-05 |
| Tooling | pnpm@10.33 + turbo + **docker / infra / n8n / playwright** (e2e) |
| Workspaces | `packages/*` (нет `apps/`) |
| `packages/web` | `@banxe/web` — **Next.js 15.3.0** + React 19 (App Router) |
| `packages/mobile` | `@banxe/mobile` — **Expo SDK 53** + RN 0.76.5 + React 18.3.2 |
| `packages/shared` | `@banxe/shared` |
| ROADMAP-назначение | «**banxe-platform is THE frontend monorepo for BANXE AI Bank**»; Phase 2 (Web) / 3 (Mobile) / 4 (Design System) — **COMPLETE** |
| Зрелость | **SCA полностью wired** (web modal + mobile screen, PSD2 Art.97, PSR 2017 Reg.71); maps: web-map/mobile-map/ui-map/tokens-map/api-map |

**Профиль:** зрелый **product app-shell monorepo** (web+mobile) + deploy-инфраструктура +
регуляторная (SCA) обвязка; самопровозглашён canonical.

---

## 3. banxe-ui — inventory

| Аспект | Значение |
|---|---|
| HEAD / pushed | `463fe26` / 2026-06-09 (новее platform); ветки: `feat/ai-onboarding`, `refactor/claude-ai-scaffold`, `s8-chatshell-wiring` |
| Tooling | pnpm@10.33 + turbo + **storybook** + `mocks/` |
| Workspaces | `apps/{web-vite,web-next,mobile}` + `packages/{ui,shared,design-tokens}` + `mocks` |
| `apps/web-next` | `@banxe/web-next` — **Next.js 16.2.3** + React 19.2.4 (новее, чем platform web) |
| `apps/web-vite` | `@banxe/web-vite` — Vite 5 + React 18 — **AI-onboarding / chat prototype** (S8 ChatShell: chat→`/v1/intent`→DecisionView) |
| `apps/mobile` | `@banxe/mobile` — **Expo SDK 53** + RN 0.76.9 + React 18.3.1 |
| `packages/ui` | `@banxe/ui` — **design-system** (primitives, financial components) |
| `packages/shared` | `@banxe/shared` — api, hooks, types |
| `packages/design-tokens` | `@banxe/design-tokens` |
| Назначение | README: «**Prototype and design system workspace**»; DESIGN-SYSTEM.md, PRD.md, ARCHITECTURE.md |

**Профиль:** **design-system + AI-onboarding/chat prototype** workspace; новее по фреймворкам
(Next 16, dedicated `@banxe/ui` + `@banxe/design-tokens` + storybook), экспериментальный.

---

## 4. Overlap & divergence

### Дублирование (collision-риск)
| Пакет | banxe-platform | banxe-ui | Риск |
|---|---|---|---|
| **`@banxe/mobile`** | packages/mobile (Expo 53, RN 0.76.5) | apps/mobile (Expo 53, RN 0.76.9) | **namespace-коллизия** + дублирующий mobile-shell |
| **`@banxe/shared`** | packages/shared | packages/shared (api/hooks/types) | **namespace-коллизия** — два разных `@banxe/shared` |
| **web (Next.js)** | `@banxe/web` Next 15.3 | `@banxe/web-next` Next 16.2 | дублирующий web-shell, **расходящиеся версии Next** |

> **Критический риск:** оба монорепо публикуют `@banxe/shared` и `@banxe/mobile` под
> одинаковыми именами — прямой merge/co-install невозможен без разведения namespace/ролей.

### Расхождение ролей (комплементарность)
| Зона | Только в platform | Только в ui |
|---|---|---|
| Infra/deploy | docker / infra / n8n / playwright e2e | — |
| Регуляторика | SCA wired (PSD2/PSR) | — |
| Design-system | (tokens внутри) | **dedicated `@banxe/ui` + `@banxe/design-tokens` + storybook** |
| AI/chat | — | **`web-vite` chat prototype** (ChatShell → /v1/intent) |
| Framework recency | Next 15.3 | **Next 16.2** |

---

## 5. Candidate roster-решения (БЕЗ выбора — operator gate)

- **(A) banxe-ui canonical** → `banxe-platform` retire/merge.
  - + новее (Next 16), готовый design-system, AI-onboarding/chat.
  - − теряется (если не мигрировать) зрелость platform: infra/deploy, SCA-wiring, ROADMAP-полнота.
- **(B) banxe-platform canonical** → `banxe-ui` сводится к design-system-источнику.
  - `@banxe/ui` + `@banxe/design-tokens` (+ storybook) питают platform; `web-vite` chat —
    либо вливается в platform, либо retire.
  - + сохраняет зрелый product-shell + infra + SCA; − нужно поднять platform до Next 16 и
    интегрировать chat/onboarding.
- **(C) split по ролям** (разрешает namespace-коллизию разведением):
  - `banxe-ui` = **design-system / components** (`@banxe/ui`, `@banxe/design-tokens`, storybook) —
    library-роль.
  - `banxe-platform` = **app shells** (web/mobile) + infra + SCA — потребляет `@banxe/ui` +
    `@banxe/design-tokens`.
  - `web-vite` (chat/onboarding) → либо feature platform-web, либо отдельный app в canonical.
  - + чёткое разделение, устраняет дубли `@banxe/shared`/`@banxe/mobile`; − требует
    рефактора зависимостей и единого `@banxe/shared`.

---

## 6. M1.7 legacy shells → mapping по вариантам

Legacy frontend shells (M1.7): `banxe-dashboard`, `banxe-admin-panel(-new)`, `tompayment-web`,
`banxe-manual-payments`, `banxe_auth`, `trade-view(-new)`, `*-mobile`.

| Legacy shell | Вариант A (ui canonical) | Вариант B (platform canonical) | Вариант C (split) |
|---|---|---|---|
| banxe-dashboard / trade-view | ui `apps/web-next` | platform `packages/web` | platform web (на `@banxe/ui`) |
| banxe-admin-panel(-new) | ui `apps/web-next` (admin route) | platform `packages/web` (admin) | platform web |
| tompayment-web / manual-payments | ui web-next | platform web | platform web |
| banxe_auth | ui shared + web-next | platform web (+ SCA уже есть) | platform web (SCA) |
| `*-mobile` | ui `apps/mobile` | platform `packages/mobile` | platform mobile (на `@banxe/ui`) |
| design-system / components | ui `packages/ui` (родной) | импорт из ui-as-source | **ui `packages/ui` (canonical lib)** |

> Mapping — иллюстративный (какие shells куда лягут); НЕ commitment до roster-выбора.

---

## 7. Open governance item

- **Roster-выбор (A/B/C) = operator-решение** (M2.8 precondition). Фабрика НЕ выбирает canonical
  frontend target.
- **Что разблокирует M2.8 после фиксации:** после operator-выбора A/B/C → отдельный шаг
  фиксирует canonical frontend target (ADR + ledger) → стартует M2.8 frontend track (миграция
  M1.7 shells в canonical по §6; разведение namespace-коллизий `@banxe/shared`/`@banxe/mobile`;
  унификация Next-версии).
- **До operator-решения** новых frontend-substep-ов нет; canonical target в этом аудите **не
  фиксируется**.
- **Связанный gate (независимый):** KYC/KYB/AML — только после I-27 HITL-L4 sign-off.

---

### Refs
banxe-platform `80c93c8` (ROADMAP.md, packages/{web@next15.3, mobile@expo53, shared});
banxe-ui `463fe26` (apps/{web-next@next16.2, web-vite, mobile@expo53} + packages/{ui, shared,
design-tokens}, storybook); M2.7 deferral; MIG-M2.8 (M2-cycle acceptance); MIG-M2.4-OB-delta-
completion (IL-423); ADR-102, ADR-059-A; I-27.
