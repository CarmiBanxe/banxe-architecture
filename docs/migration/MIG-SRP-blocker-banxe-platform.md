# MIG genuine-gap #3 SRP → banxe-platform — BLOCKER / Findings Report (docs-only, no merge, NO scaffold)

> **Type:** ADR-102 preflight blocker report. **Decision:** **NO scaffold** — canonical SRP surface
> already exists (covered) AND target is a frontend client (target-mismatch).
> **Canon:** ADR-102 (Duplication Audit — fail-closed), ADR-103 (legacy read-only), factory-only
> (shell = read-only audit), no `--admin`/`--auto`/bypass, ADR-059-A append-only, «не
> галлюцинировать».
> **Baseline:** banxe-architecture origin/main `db12ab9`. Sources (read-only): banxe-platform
> `80c93c8`, banxe-emi-stack `35033ac`, legacy `/srv/banxe-legacy/work/banxe-code/banxe`.

---

## 1. Mandate

Запрошен scaffold MIG genuine-gap #3 «SRP auth surface → banxe-platform» (SrpPort + challenge/proof
DTO, crypto-boundary only). Обязательный read-only ADR-102 preflight выполнен ДО любого scaffold.
Fail-closed: при наличии canonical surface или неподтверждённом target — scaffold НЕ делать.

---

## 2. Preflight findings (read-only, verified)

### 2a. TARGET banxe-platform — NO SRP, это frontend-client
- `git grep` по `srp|secure-remote-password|verifier|salt|handshake` в `packages/` → **0 реальных
  SRP-токенов** (ранние совпадения `challenge`/`proof` = substring-шум от **PSD2 SCA**, не SRP).
- `packages/shared/src/types/auth.ts` header: **«Auth types — matches banxe-emi-stack auth router»**.
  Модель: `LoginRequest{email,pin}` (6-digit PIN, не password) + `TokenResponse` + PSD2 `SCAChallenge`.
- `packages/shared/src/api-client.ts`: вызовы `POST /v1/auth/login`, `POST /v1/auth/token/refresh`
  → banxe-platform **потребляет** auth backend emi-stack, не реализует auth-crypto.
- **Вывод:** banxe-platform = frontend-клиент. SRP (verifier/salt/proof handshake) — **server-side
  auth-crypto boundary**; размещение его в frontend-монорепо = инверсия security-границы.

### 2b. Canonical SRP surface УЖЕ существует в banxe-emi-stack (covered)
- `services/auth/srp.py` + `tests/test_srp.py` (MIG genuine-gap #3, PR #209 / `1e39ad1`).
- Содержит: `SrpStage` (REGISTRATION→CHALLENGE→PROOF→VERIFIED/REJECTED) + `STAGE_TRANSITIONS` +
  `SrpHandshakeDescriptor` (salt_ref/verifier_ref/challenge_ref = **placeholder-only, NO real
  crypto**) + `SandboxSrpProvider`. Advisory/sandbox, semantic port для legacy `srp.service.ts`,
  fail-closed, no secret persistence, no live auth, no KYC, no ledger.
- **Это и есть canonical SRP boundary surface** — уже на main emi-stack.

### 2c. Legacy SRP provenance
- `banxe_auth` (React frontend shell): SRP-6 как **auto-generated GraphQL client** (`SrpVerifyInput`,
  `SrpInfo`, «SRP-6 data/salt» в `shared/api/apollo/__generated__/index.ts`) + locale-строки
  (`AUTH-038/039`). Это **сгенерированный API-контракт**, потребляющий backend SRP-6 сервис — не
  hand-authored scaffold-able boundary.
- `banxe-auth` (dash, NestJS backend): **bcrypt** (`generatePassword(password, salt)`) — обычный
  password-hash, **не** SRP-протокол.
- `banxe-auth-backend`: ABSENT. `banxe-fiat-backend`: 0 SRP-токенов.
- **Вывод:** legacy SRP-протокол = backend-сервис (`srp.service.ts` → покрыт emi-stack `srp.py`);
  frontend-touchpoint (`banxe_auth`) уже существует как **generated** GraphQL contract.

---

## 3. ADR-102 decision — BLOCKER (no scaffold), two independent reasons

| # | Причина | Доказательство |
|---|---|---|
| **R1 — Covered** | canonical SRP boundary surface уже существует | `banxe-emi-stack/services/auth/srp.py` (gap #3 #209/`1e39ad1`) |
| **R2 — Target-mismatch** | banxe-platform = frontend-клиент emi-stack auth; SRP — server-side crypto boundary | `types/auth.ts` «matches emi-stack auth router»; `api-client.ts` `/v1/auth/*`; 0 SRP-токенов |

Любой из R1/R2 по-отдельности достаточен для blocker. Scaffold SRP в banxe-platform: (a) дублировал
бы emi-stack `srp.py` (ADR-102 violation), и (b) разместил бы auth-crypto verifier/proof в frontend
(security-boundary инверсия). **Fail-closed → STOP, scaffold НЕ выполнен.**

---

## 4. Boundaries confirmed untouched

- **Не создано:** SrpPort/DTO/crypto в banxe-platform; backend PR; worktree banxe-platform.
- **Не затронуто:** runtime auth / token issuance / session mutation / login orchestration / raw
  credentials. KYC/KYB/AML carve-out не тронут. emi-stack `srp.py` не модифицирован (read-only).
- legacy read-only (ADR-103); banxe-platform read-only; STAFF-MATRIX не тронут.

---

## 5. Recommendation

- **SRP считать DONE** (covered emi-stack `srp.py`, gap #3 #209). Отдельный scaffold в banxe-platform
  не нужен и противопоказан.
- Если для frontend нужен SRP-touchpoint при миграции `banxe_auth` → это **generated GraphQL client**
  против backend SRP-сервиса, генерируется в M2.8 frontend track (после operator roster-выбора), а
  не hand-scaffold отдельным gap.
- Genuine-gap #3 (SRP) **закрыт** на стороне backend; в roster M2.8 SRP войдёт только как
  client-contract `banxe_auth` (не новый boundary).

---

## 6. Open governance item

- M2.8 frontend (включая `banxe_auth` SRP client-contract) остаётся **gated** на operator
  roster-выбор (banxe-ui / banxe-platform / split) — см. MIG-M2.8-PRE (IL-424/429/431/432).
- KYC/KYB/AML — независимый gate, только после I-27 HITL-L4 sign-off.

---

### Refs
banxe-emi-stack `services/auth/srp.py` (gap #3 #209/`1e39ad1`); banxe-platform `types/auth.ts` +
`api-client.ts`; legacy `banxe_auth` apollo `__generated__` SRP-6 contract, `banxe-auth` bcrypt;
MIG-M2.8-PRE-* (IL-424/429/431/432); MIG genuine-gap #2 login-history (analogous target analysis);
ADR-102, ADR-103, ADR-059-A; I-27, I-28.
