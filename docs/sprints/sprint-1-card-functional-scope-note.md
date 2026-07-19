# Card Functional Scope Note — Sprint 1

Status: DRAFT / INTERNAL ONLY / NOT FOR MERGE

## Purpose
Зафиксировать фактический функциональный периметр `card_agent` как предусловие Annex III-классификации и HITL-гейтинга карточных операций. Нота структурирует вопросы для counsel; правовых выводов не содержит.

## Scope
- Агент: `card_agent` (`banxe-emi-stack/services/card_issuing/card_agent.py`).
- Функции к описанию (заполнить по коду): issuance (virtual/physical), limit changes, block/freeze, notifications, credit-like decisions (если есть — критично).
- Для каждой функции разграничить: propose-only / executable / informational.
- Decision taxonomy: Decision type · Autonomy (L1/L2/L3) · HITL gate · Annex III relevance (YES/NO/UNKNOWN).

## Register linkage
- Area **#2 (Cards/BIN)** — current light: **RED** (не меняется этим документом).
- Target for AMBER: секции Scope заполнены по коду + counsel-вопросы отправлены (с датой).

## Room linkage
- `bank-rooms/F2-payments-room/README.md` — Regulatory Status Notes (Sprint 1).

## Open questions / counsel placeholders
- SMF responsibility в BIN-sponsor модели (наш COO vs спонсор; отражение в SoR): [counsel]
- Минимальный HITL для card-issuing под scheme rules / PSR: [counsel]
- Annex III credit scoring relevance; Recital 58 fraud/AML exclusion применимость: [counsel]
> Legal classification MUST be supplied by external counsel; not to be filled by internal opinion.
