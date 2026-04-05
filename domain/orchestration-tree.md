# Orchestration Tree — Agent Trust Hierarchy

**Добавлен:** аудит v2 (2026-04-05)
**Закрывает:** GAP-REGISTER G-04
**Связанные инварианты:** I-21, I-22
**Связанные документы:** `governance/change-classes.yaml`, `SPRINT-0-PLAN.md`

Orchestration Tree определяет иерархию агентов с явными trust boundaries.
Без этой иерархии BANXE — «unstructured agentic system», уязвимый к prompt injection
и передаче «отравленных» ответов между агентами (NCC Group).

---

## Иерархия агентов

```
Level 0 — MLRO / Human Operator  (God tier)
  │  Full authority. Only level that can approve Class B changes (SOUL.md, AGENTS.md).
  │  Tools: ALL (Marble UI, Telegram, GitHub PR approval, protect-soul.sh)
  │
  └── Level 1 — BANXE Orchestrator
        │  Policy enforcement. Reads SOUL.md and AGENTS.md.
        │  Can reject Level 2 outputs. Cannot modify policy files.
        │  Tools: read SOUL.md, read AGENTS.md, route to Level 2 agents, emit DecisionEvent
        │
        ├── Level 2a — KYC Agent
        │     Reads: customer_data, KYC documents
        │     Writes: KYCResult ONLY
        │     Tools: doc_verify, pep_check, adverse_media
        │     CANNOT: write to filesystem outside /outputs/kyc/, modify policy, push git
        │
        ├── Level 2b — Sanctions Agent
        │     Reads: watchlist (Yente :8086, Watchman :8084), transaction data
        │     Writes: ScreeningResult ONLY
        │     Tools: sanctions_check, yente_match
        │     CANNOT: write to filesystem outside /outputs/sanctions/, modify policy
        │
        ├── Level 2c — TM Agent  (Transaction Monitoring)
        │     Reads: tx_history, velocity data (Redis), scenario_registry
        │     Writes: RiskSignal ONLY
        │     Tools: tx_monitor, score_transaction
        │     CANNOT: write to filesystem outside /outputs/tm/, modify policy
        │
        └── Level 2d — Case Agent
              Reads: KYCResult, ScreeningResult, RiskSignal (от 2a/2b/2c)
              Writes: CasePayload → Marble :5002
              Tools: create_case, notify_mlro (Telegram)
              CANNOT: write to filesystem outside /outputs/cases/, modify policy
              │
              └── Level 3 — Feedback Agent  (feedback_loop.py)
                    Reads: REFUTED corpus (/data/banxe-training/corpus/)
                    Writes: proposed_patch.diff → REVIEW AGENT (никогда не применяет)
                    Tools: read REFUTED entries, generate patch proposal
                    CANNOT: write to SOUL.md, AGENTS.md, push to developer-core
                    CANNOT: push git — только предлагает изменения MLRO/L0
                    ← Governance gate I-21: auto-apply NEVER для Class B
```

---

## Правила trust boundaries

### Что НИКОГДА не происходит автоматически

| Action | Requires |
|--------|----------|
| Запись в SOUL.md / AGENTS.md | Level 0 explicit action + MLRO + CTO |
| Push в developer-core | Level 0 approval (human git push) |
| SAR submission | MLRO approval (Level 0) |
| Изменение thresholds | PR review + CI gate |
| Emergency stop clear | MLRO identity (mlro_id field) |

### Что Level 2 агент имеет право делать

| Action | Level 2a | Level 2b | Level 2c | Level 2d |
|--------|----------|----------|----------|----------|
| Читать входящие транзакции | ✅ | ✅ | ✅ | ✅ |
| Писать в свой output dir | ✅ | ✅ | ✅ | ✅ |
| Читать SOUL.md / AGENTS.md | ❌ | ❌ | ❌ | ❌ |
| Читать scenario_registry | ❌ | ❌ | ✅ | ❌ |
| Вызывать внешние API | ✅ doc_verify | ✅ sanctions | ✅ tx_monitor | ✅ Marble |
| Писать в filesystem вне /outputs/ | ❌ | ❌ | ❌ | ❌ |
| Делать git commit/push | ❌ | ❌ | ❌ | ❌ |

### Prompt injection mitigation

Все входящие данные от внешних источников (транзакции, KYC-документы, ответы
от контрагентов) проходят через Level 2 агентов — изолированных от policy layer.
Level 2 агент не может «доотравить» Level 1 или Policy layer:

```
[External data: transaction / KYC doc / counterparty response]
         ↓
[Level 2 agent: processes, outputs structured result ONLY]
         ↓
[Level 1 Orchestrator: validates result format, applies policy]
         ↓
[Policy layer: NEVER touched by Level 2]
```

Если Level 2 агент получает prompt-injected данные и выдаёт «отравленный» результат —
Level 1 Orchestrator обрабатывает его как структурированный ScreeningResult/RiskSignal,
не как инструкцию. Policy layer остаётся нетронутым.

---

## Реализация (текущее состояние vs. целевое)

| Компонент | Сейчас | Цель |
|-----------|--------|------|
| Level 0/1 | SOUL.md + AGENTS.md декларируют | EmergencyPort + DecisionPort |
| Level 2a | kyc_check.py, pep_check.py | + изолированный output dir |
| Level 2b | sanctions_check.py (ADR-009) | + SanctionsAPIAdapter (G-16) |
| Level 2c | tx_monitor.py | + изолированный output dir |
| Level 2d | Marble skill | + formal CasePayload model |
| Level 3 | feedback_loop.py (без approval gate) | + review_agent step (G-15) |
| Trust enforcement | INVARIANTS.md I-21/I-22 (декларация) | OPA/Rego rules (G-14/G-19) |

---

## Связь с другими документами

- `governance/change-classes.yaml` — CLASS_B запрещает Level 3 auto-apply на SOUL.md
- `INVARIANTS.md` I-21 — feedback_loop не патчит SOUL.md автоматически
- `INVARIANTS.md` I-22 — Level 2 не пишет в policy layer
- `SPRINT-0-PLAN.md` — EmergencyPort + PolicyPort реализуют L0/L1 boundaries
- `GAP-REGISTER.md` G-04 — статус: OPEN, Sprint 1
