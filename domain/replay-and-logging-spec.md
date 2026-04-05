# Replay & Structured Logging — Спецификация

**Добавлен:** аудит toolchain v4 (2026-04-05)
**Закрывает:** GAP-REGISTER G-01 (partial), G-20 (partial)

Два компонента для FCA supervisory visit readiness и Factor XI compliance.

---

## 1. replay_decision.py — FCA Audit Replay (G-01)

При regulatory examination (FCA supervisory visit, SOCA/NCA запрос) аудитор должен
воспроизвести точную цепочку событий, приведших к решению по конкретному клиенту.

### Спецификация

```python
# vibe-coding/src/compliance/utils/replay_decision.py
"""
FCA Audit Replay — воспроизведение compliance-решений.

Использует ClickHouse audit_trail (primary) или PostgreSQL decision_events
(когда G-01 будет реализован).

Вывод: JSON-отчёт с хронологической цепочкой событий.
Доступен через: Marble UI (кнопка "Replay") или CLI.

Usage:
    python replay_decision.py --customer-id C12345 --from 2026-01-01 --to 2026-04-05
    python replay_decision.py --transaction-id TX-789 --format json
"""
from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime


@dataclass
class DecisionChain:
    customer_id: str
    events: list[dict]   # хронологический список DecisionEvents
    summary: str          # human-readable нарратив для аудитора


def replay_by_customer(
    customer_id: str,
    from_dt: datetime,
    to_dt: datetime,
) -> DecisionChain:
    """
    Восстанавливает цепочку решений из ClickHouse audit_trail.
    Группирует: alert raised → decision → MLRO review → SAR (если был).
    """
    ...  # реализация: SELECT FROM audit_trail WHERE customer_id = ?

def replay_by_transaction(transaction_id: str) -> DecisionChain:
    """Single transaction replay — для быстрого FCA ответа."""
    ...

def export_to_pdf(chain: DecisionChain, output_path: str) -> None:
    """Экспорт в PDF для регуляторного представления."""
    ...
```

### Данные для replay

```sql
-- Источник: ClickHouse audit_trail (текущий)
SELECT
    timestamp,
    customer_id,
    transaction_id,
    decision,
    composite_score,
    policy_jurisdiction,
    policy_regulator,
    policy_framework,
    -- RiskSignals (JSON)
    toJSONString(audit_payload) AS signals
FROM banxe.audit_trail
WHERE customer_id = {customer_id}
  AND timestamp BETWEEN {from_dt} AND {to_dt}
ORDER BY timestamp ASC;
```

### Marble UI integration

Кнопка «Replay Decision» в Marble case view → вызывает `replay_decision.py` →
возвращает JSON → отображается как timeline.

---

## 2. structured_logger.py — Factor XI Compliance (G-20)

Стандартизированный JSON-логгер для всех AML-движков.
Correlation ID связывает события через transaction_id + case_id + scenario_id.

### Спецификация

```python
# vibe-coding/src/compliance/utils/structured_logger.py
"""
Structured JSON logger для AML-движков. Factor XI compliance.

Формат: одна строка JSON на событие.
Destination: stdout (→ ClickHouse pipeline) + /data/banxe/data/logs/

Usage:
    from utils.structured_logger import get_logger
    log = get_logger("sanctions_check")
    log.event("SANCTIONS_HIT", {
        "customer": "Alice",
        "rule": "SANCTIONS_CONFIRMED",
        "score": 100,
    }, tx_id=tx_id, case_id=case_id)
"""
import json
import logging
import sys
from datetime import datetime, timezone


class StructuredLogger:
    def __init__(self, module: str):
        self.module = module

    def event(
        self,
        event_type: str,
        payload: dict,
        tx_id: str | None = None,
        case_id: str | None = None,
        scenario_id: str | None = None,
        level: str = "INFO",
    ) -> None:
        record = {
            "ts":          datetime.now(timezone.utc).isoformat(),
            "level":       level,
            "module":      self.module,
            "event":       event_type,
            "tx_id":       tx_id,        # correlation: транзакция
            "case_id":     case_id,      # correlation: Marble кейс
            "scenario_id": scenario_id,  # correlation: SCN-NNN
            **payload,
        }
        print(json.dumps(record, ensure_ascii=False), flush=True)


def get_logger(module: str) -> StructuredLogger:
    return StructuredLogger(module)
```

### Использование в AML-движках

```python
# sanctions_check.py — до:
print(f"Hit: {hit}")  # неструктурированно

# после:
from utils.structured_logger import get_logger
log = get_logger("sanctions_check")
log.event("SANCTIONS_HIT", {"rule": signal.rule, "score": signal.score},
          tx_id=tx_id, scenario_id="SCN-002")
```

Correlation ID (`tx_id`, `case_id`, `scenario_id`) позволяет одним запросом в ClickHouse
найти все события по конкретной транзакции — это и replay capability, и Factor XI.

---

## 3. ExplanationBundle с counterfactual (G-02)

Для rule-based движков counterfactual генерируется детерминированно
из threshold-параметров — не требует ML.

### Спецификация

```python
@dataclass
class CounterfactualExplanation:
    """«Что изменилось бы, если бы...»"""
    decision_was: str         # "HOLD"
    decision_would_be: str    # "APPROVE"
    condition: str            # "if amount < £850"
    nearest_threshold: str    # "fps_structuring_max_amount: 1000"

@dataclass
class ExplanationBundle:
    decision: str                              # APPROVE | HOLD | REJECT | SAR
    top_factors: list[tuple[str, float, str]]  # (rule_id, contribution_pct, direction)
    narrative: str                             # "3 transfers below FPS threshold in 24h"
    confidence: float                          # 0.0-1.0
    method: str                                # "rule-based" | "shap" | "lime"
    counterfactual: CounterfactualExplanation | None
    # I-25: обязателен для decisions > £10,000

# Генерация для rule-based (до ML):
def build_rule_explanation(signals: list[RiskSignal], amount: float) -> ExplanationBundle:
    top_factors = [(s.rule, s.score / 100, "↑") for s in sorted(signals, key=lambda x: -x.score)]
    narrative = "; ".join(s.reason[:60] for s in signals[:3])
    cf = None
    if amount > 10000:
        cf = CounterfactualExplanation(
            decision_was="HOLD",
            decision_would_be="APPROVE",
            condition=f"if amount < £{10000:.0f}",
            nearest_threshold="i-04_amount_edd_threshold: 10000",
        )
    return ExplanationBundle(
        decision="HOLD", top_factors=top_factors, narrative=narrative,
        confidence=0.95, method="rule-based", counterfactual=cf,
    )
```

---

## Приоритет реализации

1. `structured_logger.py` — 1 день, закрывает Factor XI, без рисков
2. `ExplanationBundle` + counterfactual — 1–2 дня, закрывает G-02 + I-25
3. `replay_decision.py` — 2–3 дня, требует ClickHouse query, closesG-01 partial
