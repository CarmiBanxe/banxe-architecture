# SPRINT 3 — NEW PRODUCTS: OPERATOR MEMO

**Status: DRAFT / INTERNAL ONLY / NO LEGAL STATUS**
**Register: #4 AMBER, #2 RED — traffic lights change only via evidence-backed register update** (`../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`)

## Scope & context

Sprint 3 покрывает продуктовый кластер Savings / Insurance / Merchant / Card. Все четыре продукта — **«Pre-pilot only / permissions unresolved [counsel]»**; ни один не одобрен к запуску. Этот memo — внутренний срез готовности и список решений для Board/counsel; не правовой документ.

## Current product readiness (по коду и артефактам)

- **Merchant** — наиболее зрелый по встроенному контролю (**control maturity, not regulatory readiness**): KYB-approve и settlement требуют человеческого actor в самом коде; открыт только permissions-периметр (acquiring/scheme). Stub: `../sprints/sprint-3-per-product-evidence-packs.md` §Merchant; wiring: `../sprints/sprint-3-permissions-map-per-product.md`.
- **Card** — lifecycle-операции (freeze/PIN/activate) human-акторные; **issuance не определён** (нет BIN-спонсора и функционального scope; регуляторная зона остаётся RED, register #2). Stub: §Card; scope: `../sprints/sprint-1-card-functional-scope-note.md`.
- **Savings** — операции реализованы (Decimal-суммы, I-01), но явных in-code human-гейтов на операциях нет — гейтинг сейчас только на уровне запуска (H-017); ключевой вопрос — граница e-money vs deposit-taking. Stub: §Savings.
- **Insurance** — quote/bind/claim реализованы; human-гейты предполагаются процедурными (H-017, MLRO-раскрытия), в коде не выражены; открыт режим дистрибуции. Stub: §Insurance.

## Evidence present (внутренние артефакты)

- Product Evidence Pack Template + 4 stub-экземпляра (facts-only): `../sprints/sprint-3-product-evidence-pack-template.md`, `sprint-3-per-product-evidence-packs.md`.
- Non-legal permissions wiring (actors → human-gate references → regulator labels): `sprint-3-permissions-map-per-product.md`.
- Outcomes-инфраструктура уже в коде: ConsumerDutyAgent (dashboard, vulnerability-detection с L4-HITL, product-withdrawal под L4) и LifecycleAgent (suspend/offboard под L4, SYSC 9) — мониторинговая часть Consumer Duty технически готова к наполнению.

## Open decisions required (Board/operator)

1. **Permissions/licensing per product** — заказ counsel-мэппинга по строкам Permissions Map.
2. **Consumer Duty / target market** — утвердить шаблон пака как обязательный; назначить владельца заполнения per product (gate H-017 + pack = combined requirement).
3. **Go/no-go pilot vs full launch per product** — только после (1)+(2); для Card дополнительно: BIN-решение и Scope Note (Sprint 1).

## Risk / HITL overview

- **Enforced кодом:** Merchant KYB/settlement (actor) · Card lifecycle (actor) · Crypto-переводы ≥1000 → HITLProposal (I-27) · ConsumerDuty/Lifecycle L4-гейты.
- **Gaps:** Savings/Insurance операции без in-code гейтов (полагаются на процедурные) — рекомендация: при пилоте вынести операционные лимиты в config-as-data с явным human-гейтом. Card issuance — без гейта до Scope Note.

## For counsel

(a) Savings: e-money vs deposit-taking граница. (b) Insurance: применимый distribution-режим и партнёрская лицензия. (c) Merchant: acquiring permission / scheme membership. (d) Card: BIN-sponsor модель, SMF-ownership, Annex III-релевантность фактического scope. (e) Достаточность H-017+pack как совокупного гейта Consumer Duty.
Никакие из этих пунктов не предрешены настоящим memo.
