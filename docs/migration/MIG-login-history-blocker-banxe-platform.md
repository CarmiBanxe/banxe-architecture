# MIG genuine-gap #2 login-history → banxe-platform — BLOCKER / Findings Report (docs-only, no merge, NO scaffold)

> **Type:** ADR-102 preflight blocker report (symmetric to SRP blocker IL-434 / #678).
> **Decision:** **NO scaffold** — canonical login-history surface already exists (covered) AND target
> is a frontend client (target-mismatch).
> **Canon:** ADR-102 (Duplication Audit — fail-closed), ADR-103 (legacy read-only), factory-only
> (shell = read-only audit), no `--admin`/`--auto`/bypass, ADR-059-A append-only, «не галлюцинировать».
> **Baseline:** banxe-architecture origin/main `102b79f`. Sources (read-only): banxe-platform
> `80c93c8`, banxe-emi-stack `35033ac`, legacy `/srv/banxe-legacy/work/banxe-code/banxe`.

---

## 1. Scope

Read-only ADR-102 preflight трека «login-history auth-audit surface → banxe-platform»
(genuine-gap #2). Цель — установить, существует ли canonical surface / уместен ли target, ДО любого
scaffold. Результат: **BLOCKER, no scaffold** (как SRP #678). Этот трек был инициирован auto-mode и
прерван harness-outage в незавершённом состоянии (0 scaffold / 0 PR) — закрывается документально.

---

## 2. Target finding — banxe-platform = frontend-client, нет auth-audit boundary

- `git grep` по `login-history|login_event|login-audit|signin-history|auth-history` в `packages/`:
  **единственное совпадение** — `packages/shared/src/types/auth.ts:25` → `last_login?: ISODateString`
  (одно display-поле на `AuthUser`, потребляется из backend).
- **`LoginHistoryPort` / `login_history` / `LoginEvent` store/repository в banxe-platform — 0**
  (нет backend auth-audit boundary).
- `types/auth.ts` header: «Auth types — matches banxe-emi-stack auth router»; `api-client.ts` →
  `/v1/auth/login`, `/v1/auth/token/refresh` → banxe-platform **потребляет** auth backend emi-stack.
- **Вывод:** login-history (backend auth-audit event surface) в frontend-монорепо = target-mismatch;
  максимум frontend-стороны — display-поле `last_login`, уже присутствует.

---

## 3. Canonical covered — banxe-emi-stack `services/auth/login_history.py` (#208)

- `services/auth/login_history.py` + `tests/test_login_history.py` (MIG genuine-gap #2, PR #208 /
  IL-413 / SHA `4378207`).
- Содержит: `LoginOutcome` (Enum) + `LoginHistoryRecord` (**`masked_ip` — PII-masked via `mask_ip`**,
  `outcome`, caller-supplied timestamp) + `LoginHistoryPort` (ABC) + `SandboxLoginHistoryProvider`
  (DI id-generator, collision-safe, `mask_ip(ip)` before storage, fail-closed).
- Зафиксирован также в coverage-acceptance (IL-415/416) и closure-record (IL-428).
- **Это canonical login-history auth-audit surface** — уже на main emi-stack.

---

## 4. Legacy touchpoint

- `banxe_auth` / `banxe-auth` (`src/`): **0** hand-authored login-history surface; **нет даже
  generated GraphQL client** для login-history (в отличие от SRP, у которого был SRP-6 apollo
  `__generated__` контракт).
- `banxe-auth-backend`: ABSENT.
- **Вывод:** dedicated login-history boundary в legacy frontend отсутствует; это backend
  auth-audit концерн (→ покрыт emi-stack `login_history.py`). Frontend touchpoint исчерпывается
  display-полем `last_login`.

---

## 5. ADR-102 decision — BLOCKER (no scaffold), two independent reasons

| # | Причина | Доказательство |
|---|---|---|
| **R1 — Covered** | canonical login-history surface уже существует | `banxe-emi-stack/services/auth/login_history.py` (gap #2 #208/IL-413/`4378207`) |
| **R2 — Target-mismatch** | banxe-platform = frontend-клиент emi-stack auth; нет backend auth-audit boundary | `types/auth.ts` «matches emi-stack auth router»; `api-client.ts` `/v1/auth/*`; только `last_login` display-поле |

Любой из R1/R2 достаточен. Scaffold login-history в banxe-platform: (a) дублировал бы emi-stack
`login_history.py` (ADR-102 violation), и (b) разместил бы backend auth-audit в frontend (инверсия
границы). **Fail-closed → STOP, scaffold НЕ выполнен.**

---

## 6. Boundaries confirmed untouched

- **Не создано:** LoginHistoryPort/DTO в banxe-platform; backend PR; worktree banxe-platform.
- **Не затронуто:** emi-stack `login_history.py` (read-only); runtime auth / token / session / login
  flows; raw credentials. KYC/KYB/AML carve-out не тронут.
- legacy read-only (ADR-103); banxe-platform read-only; STAFF-MATRIX не тронут.

---

## 7. Net effect

- **login-history genuine-gap #2 = CLOSED на backend** (covered emi-stack `login_history.py` #208).
  Отдельный scaffold в banxe-platform не нужен и противопоказан.
- Frontend login-history представление = display-поле `last_login` (уже есть) + при миграции
  `banxe_auth` любой расширенный frontend-view материализуется как client против backend в **M2.8
  frontend track** (после operator roster-выбора), не как отдельный gap.
- **Симметрия с SRP (#678):** оба auto-mode-инициированных periphery-scaffold трека
  (SRP + login-history → platform) теперь задокументированы как BLOCKER — backend genuine-gaps
  закрыты, platform-scaffold противопоказан.

---

## 8. Open governance item

- M2.8 frontend (включая любые auth-audit frontend-views) остаётся **gated** на operator
  roster-выбор (banxe-ui / banxe-platform / split) — MIG-M2.8-PRE (IL-424/429/431/432).
- KYC/KYB/AML — независимый gate, только после I-27 HITL-L4 sign-off.

---

### Refs
banxe-emi-stack `services/auth/login_history.py` (gap #2 #208/IL-413/`4378207`); banxe-platform
`types/auth.ts` (`last_login`) + `api-client.ts`; legacy `banxe_auth`/`banxe-auth` (no login-history
boundary); MIG-SRP-blocker-banxe-platform.md (IL-434, #678 — symmetric); coverage-acceptance
(IL-415/416); closure-record (IL-428); MIG-M2.8-PRE-* (IL-424/429/431/432); ADR-102, ADR-103,
ADR-059-A; I-27, I-28.
