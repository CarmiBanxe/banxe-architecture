# SanctionsScreeningAgent — Oversight Notes (Art.14-style)

Status: DRAFT / NOT FOR MERGE
Agent / code path: `banxe-emi-stack/services/sanctions_screening/sanctions_agent.py` (`SanctionsAgent`: process_screening / process_match_review / process_sar_filing / process_account_freeze; `HITLProposal` dataclass); screening-движок: Watchman (`services/beneficiary_management/sanctions_screener.py`, webhook-роутер).
Room / owner: F3/aml-room · MLRO (SMF17).

## Decision context
Санкционный скрининг entity/beneficiary. По коду [ФАКТ]: possible match → `HITLProposal(action="review_possible_match")` — manual review; confirmed match → `review_confirmed_match`, **requires_approval_from="MLRO"** (I-02); SAR-путь → MLRO; account freeze — отдельный process.
## Stop-function
Auto-BLOCK на hit — детерминированный (H-003, immediate); агент НЕ содержит пути снятия блока: reversal существует только как человеческий акт **MLRO+CEO (H-004, 2h, OFSI written consent)**.
## Override / escalation path
Все вердикты — через HITLProposal к человеку (MLRO/CO); false-positive разбор — match_review человеком; агент предлагает, никогда не решает (I-27-паттерн в коде).
## Explainability output shape
HITLProposal: action + reason-строка с именем entity и типом матча (possible/confirmed) + requires_approval_from; списочная атрибуция (какой лист дал hit) — Tier-A источники (ADR-173).
## Threshold / tuning change-control
Match-пороги (block ≥0.80 / review ≥0.60 — канон agent-authority) — изменение через **H-012-класс (CRO+CEO)**; списки — OpenSanctions/Watchman обновления как data, не code; I-27 — без авто-тюнинга.
## Logging / traceability
Каждый hit/review/decision — append-only audit (I-24); SAR-цепочка — lineage с MLRO-ответственностью (H-001 non-delegable).
## Register linkage
#8 (context) · #3 cross (crypto-переводы проходят этот же скрин).
## Related
`../../sprints/sprint-2-high-risk-map.md` (grid: AML-cluster; Recital 58 — counsel) · `../../sprints/sprint-1-travel-rule-split-note.md` · `art14-per-agent-notes-template.md`.
## Legal classification: [counsel]
## Open questions
- Формат list-attribution в проде (какие поля listing-source сохраняются) — verify при A2.
- Взаимодействие freeze-процесса с H-005 customer-block цепочкой.
