# Per-Product Evidence Packs — Skeleton — Sprint 3

Status: TEMPLATE / TRACKING SKELETON / NOT FOR MERGE

## Purpose
Трекинг-срез по продуктам; каждое «YES» обязано опираться на полный экземпляр пака по шаблону (ссылка обязательна).

## Scope

| Product | Type | Target market defined? | Fair value assessed? | Permissions mapped? | Evidence pack complete? |
|---|---|---|---|---|---|
| Savings v1 (`services/savings/savings_agent.py`) | savings | NO | NO | NO | NO |
| Insurance v1 (`services/insurance/insurance_agent.py`) | insurance | NO | NO | NO | NO |
| Merchant v1 (`services/merchant_acquiring/merchant_agent.py`) | merchant/payments | NO | NO | NO | NO |

## Register linkage
- Area **#4** — строки таблицы = прогресс к GREEN; статус меняет только register с evidence-ссылками.

## Room linkage
- `bank-rooms/F1-customer-ops-room/README.md`; cross-link `bank-rooms/F1-marketing-room/README.md` (промо-материалы паков → COBS4).

## Open questions
- Скоуп «Other product» строк — по roadmap-решению оператора.

## See also
- Sprint 3 набор: `sprint-3-product-evidence-pack-template.md` · `sprint-3-per-product-evidence-packs.md` · `sprint-3-permissions-map-per-product.md`
- Сводка/аудит: `sprint-1-4-status-summary.md` · `sprint-1-4-shell-audit.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`

## Приложение A (Sprint 3 deepening): stub-экземпляры (facts-only, pre-pilot)

Добавочная строка трекинга: | Card v1 (`services/card_issuing/card_agent.py`) | card | NO | NO | NO | NO |

### Savings v1 — stub
- Description: сберегательный счёт-продукт; [ФАКТ, код]: `open_account / deposit(Decimal) / withdraw(Decimal) / get_interest_summary` — I-01 соблюдён в сигнатурах.
- Features&flows (ARO): Client→SavingsAgent→account/interest ops; исполнение dormant до scope-ADR.
- Risk/threats: deposit-boundary (e-money vs deposit-taking) — главный permissions-риск [counsel].
- HITL hooks: H-017 (launch), Consumer Duty outcomes; лимиты — ledger-инварианты.
- Evidence: код выше; Permissions Map строка Savings.
- Open: лицензия/permission [counsel]; interest-механика vs EMI-режим [counsel].

### Insurance v1 — stub
- Description: [ФАКТ]: `get_quote / bind_policy / file_claim / list_products` — квоты/полисы/клеймы.
- ARO: Client→InsuranceAgent→quote/policy/claim; underwriting предполагается партнёрским (spec: distribution).
- Risk/threats: distribution-периметр; disclosure-контроли.
- HITL hooks: H-017; MLRO для regulated-док-раскрытий (COBS-класс — Marketing-room гейт для промо).
- Evidence: код; Permissions Map строка Insurance.
- Open: применимый режим дистрибуции [counsel]; partner-agreement статус.

### Merchant v1 — stub
- Description: [ФАКТ]: `onboard_merchant / approve_kyb(actor) / accept_payment / complete_3ds / create_settlement` — эквайринг-цикл с human-actor на KYB.
- ARO: Merchant→MerchantAgent→onboarding/payment/settlement; KYB-approve несёт actor-параметр (human gate в коде).
- Risk/threats: acquiring-периметр; scheme-требования; settlement-риски.
- HITL hooks: H-017; kyb-approve (actor) — CO-класс; H-016 на крупные settlements (ref).
- Evidence: код; Permissions Map строка Merchant.
- Open: acquiring permissions / scheme membership [counsel].

### Card v1 — stub
- Description: [ФАКТ]: `issue_card / activate_card / set_pin / freeze_card(reason) / unfreeze_card` — все с actor-параметром.
- ARO: Client/Ops→CardAgent→lifecycle карт; issuance dormant (register #2 RED, BIN отсутствует).
- Risk/threats: BIN-sponsor gap; ownership решений (мы vs спонсор); Annex III-вопрос — см. `sprint-1-card-functional-scope-note.md`.
- HITL hooks: freeze/unfreeze — actor-гейты в коде; issuance-гейт — до Scope Note не фиксируется.
- Evidence: код; S1 Scope Note; Permissions Map строка Card.
- Open: всё лицензионное [counsel]; связь с #2 — статус остаётся RED.
