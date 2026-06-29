# SRC-03 — Implementation State
# BANXE AI Bank | Agent-Engine Dossier
# Source: Corpus Part 3 + A3 triple-pass audit (G1/R1/R3/G2, 2026-06-28)
# Created: 2026-06-28 | IL-agent-factory-agenteng07-src03-implementation-state

> Данный файл = текущее состояние реализации ключевых компонентов агентского движка.
> Три раздела: (1) GAP-080 Intent-First UI spine-gap, (2) payment-core ports-mapping, (3) governance/runtime divergence.
> Маркер: [ФАКТ из A3-аудита].

---

## Duplication policy (явный cross-ref вместо дублирования)

| Тема | Первичный источник | В SRC-03 |
|------|--------------------|---------|
| banxe-recon drift / inactive ports | `VERIFIED-RUNTIME-SNAPSHOT.md` §banxe-recon | Cross-ref only |
| GAP-087 activation-spec | `VERIFIED-RUNTIME-SNAPSHOT.md` §GAP-087 | Cross-ref only |
| GAP-081 AGPL risk | `SRC-07-governance-compliance.md` | Cross-ref only |
| Framework/engine table | `SRC-04-framework-selection.md` | Cross-ref only |
| Hyperswitch/Redis port inventory | `VERIFIED-RUNTIME-SNAPSHOT.md` + PR #845 | Cross-ref only |

---

## §1 — Intent-First UI Gap (GAP-080): ONE Spine-Gap, Three Angles

> [ФАКТ из A3-аудита G1=0 — NOVELTY — отсутствовало в dossier до SRC-03]

### Product / UI angle (GAP-080)

**GAP-080: C-37.3 Intent-First Banking — NOT IMPLEMENTED**

| Attribute | Value |
|-----------|-------|
| Roadmap item | C-37.3 Intent-First Banking (Hybrid Intent Interface) |
| Status | 🔴 RED OPEN |
| Owner | Product |
| Target | Q3 2026 |
| A3 audit finding | G1=0 (absent from dossier before this file) |

**Missing artefacts (consumer UI layer):**

```
banxe-frontend/
├── IntentParser          — НЕ РЕАЛИЗОВАН (парсит natural-language intent → skill-id)
├── SkillRouter           — НЕ РЕАЛИЗОВАН (маршрутизирует skill-id → агент/UI card)
└── Intent UI cards (6 variants):
    ├── TransferCard      — НЕ РЕАЛИЗОВАН
    ├── PayCard           — НЕ РЕАЛИЗОВАН
    ├── ExchangeCard      — НЕ РЕАЛИЗОВАН
    ├── SavingsCard       — НЕ РЕАЛИЗОВАН
    ├── InsightCard       — НЕ РЕАЛИЗОВАН
    └── AlertCard         — НЕ РЕАЛИЗОВАН
```

> [ФАКТ] banxe-frontend содержит ops-console (операционный UI); consumer-facing Intent Interface отсутствует полностью.
> Пользователь не может выразить намерение ("отправь 500 фунтов Марии") — система не имеет UI-слоя для приёма и маршрутизации этого intent.

### Technical / orchestration angle (target-audit PR #842 §7.2)

> Cross-ref: PR #842, section 7.2 "Orchestration Spine / Intent Dispatcher L1 to L2".
> Не дублируем техническое содержание здесь. Ключевой факт:

**[ФАКТ]** `planner.yaml` EXISTS в репо (файл есть). Intent Dispatcher НЕ ЗАДЕПЛОЕН (ADR-049 = спецификация, не production).
L1→L2 routing (classification → dispatch to specialist agent) описан в ADR-049 но не введён в эксплуатацию.
PR #842 §7.2 содержит полный технический разбор этого gap.

### Governance angle (ADR-049)

> Cross-ref: ADR-049 "Orchestration Spine — Intent Dispatcher".
> Не дублируем ADR содержание. Ключевой факт:

**[ФАКТ]** ADR-049 явно фиксирует: "client-facing masks do NOT exist — only internal passports."
Это означает: агенты имеют internal-идентичность (passport), но у пользователя нет UI-маски для взаимодействия с ними через consumer Intent Interface.

### ONE Spine-Gap — Сводная диагностика

```
GAP-080 (Product/UI)  ←——————————————→  ADR-049 (Governance)
"6 card variants absent                  "client-facing masks absent,
 from consumer UI"                        internal passports only"
        ↑                                         ↑
        └──────────── target-audit PR #842 §7.2 ──┘
                      "Orchestration Spine:
                       planner.yaml EXISTS,
                       dispatcher NOT DEPLOYED,
                       L1→L2 routing = spec, not production"
```

**Вывод:** GAP-080 + PR #842 §7.2 + ADR-049 = один и тот же незакрытый gap, описанный с трёх сторон (product, technical, governance). Устранение требует: (1) реализации IntentParser + SkillRouter + 6 карточек в banxe-frontend; (2) деплоя Intent Dispatcher (ADR-049 → production); (3) привязки UI → dispatcher → agentы (плоскость passport + mask).

---

## §2 — Payment-Core Ports-Mapping

> [ФАКТ из A3-аудита R3 — NOVELTY — не было в dossier до SRC-03]
> Cross-ref ports inventory: `VERIFIED-RUNTIME-SNAPSHOT.md` + PR #845 (addendum A-003). Здесь — архитектурный mapping + статус.

### Hexagonal port → adapter mapping (banxe-payment-core)

| Port (Protocol) | Adapter (Production) | Network endpoint | Notes |
|-----------------|----------------------|-----------------|-------|
| `PaymentSwitchPort` | `HyperswitchAdapter` | :8096 / :8097 / :8098 | Payment switch (routing, acquirer) |
| `IssuerPort` | `PaymentologyAdapter` | Commercial (no fixed local port) | Card issuing (BIN management) |
| `LedgerPort` | `MidazAdapter` | :8095 | GL ledger (CBS primary) |

> [ФАКТ] ADR-013 (Hyperswitch as payment switch), ADR-014 (Midaz as ledger), ADR-015 (hexagonal DI pattern for payment-core).

### Quality metrics

| Metric | Value |
|--------|-------|
| Tests | 297 |
| Coverage | 97% |
| Architecture | Hexagonal DI (ADR-015) |
| Status | Code-DONE |

### Go-live status

**Code-DONE. Go-live BLOCKED.**

| Blocker | Type | Detail |
|---------|------|--------|
| BT-001 | External key | Modulr production API key not obtained (operator/CEO task) |
| GAP-074 | Open gap | payment-core go-live dependencies not resolved (see GAP-REGISTER) |

> [ФАКТ] banxe-payment-core реализован полностью как code artefact. Деплой в production заблокирован BT-001 (Modulr key) — внешний блокер, не технический debt.

---

## §3 — Governance vs Runtime Divergence

> [ФАКТ из A3-аудита G2 + R1] — PARTIAL CONFLICT, явная маркировка обязательна.

### ⚠️ PARTIAL CONFLICT: GAP-087

| Claim | Source | Value |
|-------|--------|-------|
| Governance claim | GAP-REGISTER: GAP-087 | "LIVE / timer enabled 2026-06-27" |
| Runtime fact | `VERIFIED-RUNTIME-SNAPSHOT.md` §banxe-recon | banxe-recon.service = **inactive / drifted** (FROZEN-ARCHIVE) |

**Dossier stance:** Runtime-fact (inactive) является авторитетным до прохождения HITL-гейта.

**Почему конфликт правомерен (не ошибка):**
GAP-REGISTER отражает governance-намерение (spec: "активировать таймер"). VERIFIED-RUNTIME-SNAPSHOT отражает фактическое состояние evo1 на момент снапшота. Расхождение = нормальное состояние для activated-but-not-yet-running системы. Конфликт закроется, когда HITL-гейт (CTIO + CFO) подпишет активацию.

**Детали:** → `VERIFIED-RUNTIME-SNAPSHOT.md` §banxe-recon + §GAP-087 (первичный источник, не дублируем здесь).

**HITL-гейт до разрешения конфликта:** CTIO + CFO sign-off required before banxe-recon.service activation.

---

## §4 — Cross-references

| Reference | Relevance |
|-----------|-----------|
| GAP-REGISTER: GAP-080 | Intent-First Banking, RED OPEN, Q3 2026 — продуктовая сторона spine-gap |
| GAP-REGISTER: GAP-074 | payment-core go-live (BT-001 Modulr key path) |
| GAP-REGISTER: GAP-087 | Recon activation spec (governance claim; PARTIAL CONFLICT с runtime) |
| target-audit PR #842 §7.2 | Orchestration Spine / Intent Dispatcher L1→L2 (технич. сторона spine-gap) |
| ADR-049 | Client-facing masks absent (governance сторона spine-gap) |
| ADR-015 | Hexagonal DI pattern — payment-core architecture |
| ADR-013 | Hyperswitch as payment switch |
| ADR-014 | Midaz as ledger CBS |
| `VERIFIED-RUNTIME-SNAPSHOT.md` | Ports inventory, banxe-recon inactive, GAP-087 detail (первичный источник) |
| `SRC-07-governance-compliance.md` | GAP-081 AGPL risk (не дублируется в SRC-03) |
| `SRC-04-framework-selection.md` | Framework/engine recommendation table (не дублируется) |
| PR #845 | VERIFIED-RUNTIME-SNAPSHOT addendum A-003 (Hyperswitch/Redis ports — не дублируется) |
