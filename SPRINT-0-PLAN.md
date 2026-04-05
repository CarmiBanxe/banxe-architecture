# SPRINT-0-PLAN.md — Архитектурный спринт 0

**Добавлен:** аудит v3 (2026-04-05)
**Цель:** Формализовать архитектурный фундамент до начала feature-спринтов.
**Охватывает:** G-16, G-18, G-21, G-22

Sprint 0 не требует изменений runtime-кода. Только документы, интерфейсы и hooks.
Оценка: 3–5 дней полной работы.

---

## 1. Port-интерфейсы (G-16 — Hexagonal Architecture)

Hexagonal Architecture (Ports & Adapters) изолирует бизнес-логику агентов
от инфраструктуры. Порт = контракт. Адаптер = реализация.

### 1.1 PolicyPort — читает, никогда не пишет

```python
# banxe-architecture/ports/policy_port.py  (reference spec)
from abc import ABC, abstractmethod
from typing import Any

class PolicyPort(ABC):
    """
    Read-only доступ к policy layer (SOUL.md, AGENTS.md, thresholds).
    Инвариант I-22: Level-2 агент не пишет в policy layer.
    Адаптер: SoulMdPolicyAdapter, ComplianceConfigAdapter.
    """
    @abstractmethod
    def get_forbidden_patterns(self) -> list[str]: ...

    @abstractmethod
    def get_threshold(self, name: str) -> float: ...

    @abstractmethod
    def get_jurisdiction_class(self, iso_code: str) -> str: ...
    # returns: "A" | "B" | "STANDARD"
```

### 1.2 DecisionPort — выход агента (решение + объяснение)

```python
class DecisionPort(ABC):
    """
    Единственный выход Decision Engine.
    Содержит BanxeAMLResult + ExplanationBundle (G-02).
    """
    @abstractmethod
    def emit_decision(
        self,
        result: "BanxeAMLResult",
        explanation: "ExplanationBundle",
    ) -> "DecisionEvent": ...
    # DecisionEvent → AuditPort (append-only)
```

### 1.3 AuditPort — append-only запись

```python
class AuditPort(ABC):
    """
    Append-only запись всех compliance-событий.
    Инвариант I-24: нет UPDATE/DELETE.
    Адаптеры: ClickHouseAuditAdapter, PostgresEventLogAdapter.
    """
    @abstractmethod
    def append_event(self, event: "DecisionEvent") -> str: ...
    # возвращает event_id

    # НЕТ метода update_event() — намеренно отсутствует
    # НЕТ метода delete_event() — намеренно отсутствует
```

### 1.4 EmergencyPort — канал stop button

```python
class EmergencyPort(ABC):
    """
    Канал для EU AI Act Art.14 emergency stop.
    Инвариант I-23: проверяется ДО любого решения.
    Адаптеры: RedisEmergencyAdapter (primary), FileEmergencyAdapter (fallback).
    Реализован: emergency_stop.py (d5c1007) — нужен рефакторинг под этот интерфейс.
    """
    @abstractmethod
    async def is_stopped(self) -> bool: ...

    @abstractmethod
    async def activate(self, operator_id: str, reason: str) -> None: ...

    @abstractmethod
    async def clear(self, mlro_id: str, reason: str) -> None: ...
```

### 1.5 Адаптеры (референсный список)

| Порт          | Production Adapter          | Test Adapter            |
|---------------|-----------------------------|-------------------------|
| PolicyPort    | SoulMdPolicyAdapter         | InMemoryPolicyAdapter   |
| PolicyPort    | ComplianceConfigAdapter (G-07) | —                    |
| DecisionPort  | BanxeAMLDecisionAdapter     | MockDecisionAdapter     |
| AuditPort     | ClickHouseAuditAdapter      | InMemoryAuditAdapter    |
| AuditPort     | PostgresEventLogAdapter (G-01) | —                    |
| EmergencyPort | RedisEmergencyAdapter       | InMemoryEmergencyAdapter |
| EmergencyPort | FileEmergencyAdapter        | —                       |

---

## 2. Bounded Contexts (G-18 — DDD)

5 bounded contexts для BANXE. Каждый — отдельная директория с явной публичной моделью.
Взаимодействие только через domain events, никаких прямых импортов между контекстами.

```
vibe-coding/src/
├── compliance/          → ТЕКУЩЕЕ (переименовать + реструктурировать)
│
banxe-architecture/domain/
├── compliance_context/         # KYC/AML, sanctions, MLRO alerts
│   public_model: CustomerRisk, ScreeningResult, Alert
│
├── decision_engine_context/    # AI-агенты, scoring, ExplanationBundle
│   public_model: BanxeAMLResult, ExplanationBundle, DecisionEvent
│   reads_from: PolicyPort (read-only)
│   writes_to: DecisionPort → AuditPort
│
├── policy_context/             # SOUL.md, AGENTS.md, change governance
│   public_model: PolicySnapshot, ChangeRequest
│   access: READ-ONLY для всех других контекстов
│   writers: только developer/CTIO через protect-soul.sh
│
├── audit_context/              # Append-only event store, reporting
│   public_model: DecisionEvent, AuditQuery, ComplianceReport
│   invariant: I-24 (no UPDATE/DELETE)
│
└── operations_context/         # Emergency stop, health checks, monitoring
    public_model: StopState, HealthStatus, DriftAlert
    ports: EmergencyPort
```

### Правила взаимодействия между контекстами

```
compliance_context     → audit_context      (ScreeningResult events)
decision_engine_context → audit_context     (DecisionEvent)
decision_engine_context ← policy_context   (PolicyPort read-only)
operations_context     → все контексты      (EmergencyPort signal)
audit_context          ← все остальные      (append-only, нет writes назад)
```

**Запрещено:** `decision_engine_context` импортирует из `compliance_context` напрямую.
Правило: использовать только public_model (domain events), не внутренние классы.

---

## 3. Claude Code Hooks (G-21 — Vibe-coding governance)

4 обязательных hook'а. Конфигурируются в `.claude/settings.json`.
Спецификация — в `banxe-architecture/hooks/`, реализация — в `vibe-coding/.claude/`.

### hook-1: policy-guard (PreToolUse)

```bash
# .claude/hooks/policy-guard.sh
# Назначение: I-22 — Level-2 агент не пишет в policy layer
# Триггер: любой write/edit в файлы policy_context/

TARGET="$1"  # файл, который собирается изменить инструмент

if echo "$TARGET" | grep -qE "(SOUL\.md|AGENTS\.md|IDENTITY\.md|BOOTSTRAP\.md|change-classes\.yaml)"; then
  echo "BLOCKED [I-22]: Запись в policy layer требует CLASS_B approval."
  echo "  Используй: bash scripts/protect-soul.sh update <file>"
  echo "  Требует: MLRO + CTO approval (change-classes.yaml CLASS_B)"
  exit 1
fi
```

### hook-2: invariant-check (PostToolUse)

```bash
# .claude/hooks/invariant-check.sh
# Назначение: Запуск check-compliance.sh после каждого изменения compliance/ файлов
# Триггер: Edit/Write в src/compliance/** или developer/**

if echo "$1" | grep -qE "(compliance|developer-core)"; then
  bash ~/banxe-architecture/validators/check-compliance.sh ~/vibe-coding 2>&1 | tail -5
fi
```

### hook-3: bounded-context-check (PostToolUse)

```bash
# .claude/hooks/bounded-context-check.sh
# Назначение: Предотвращает прямые импорты между bounded contexts
# Триггер: Edit/Write *.py

FILE="$1"

# decision_engine не импортирует из compliance напрямую
if echo "$FILE" | grep -q "decision_engine"; then
  if grep -n "from compliance\." "$FILE" | grep -v "models\|ports"; then
    echo "WARN [G-18]: Прямой импорт из compliance_context в decision_engine."
    echo "  Используй domain events или PolicyPort."
  fi
fi
```

### hook-4: load-architecture (SessionStart)

```bash
# .claude/hooks/load-architecture.sh
# Назначение: Загружает INVARIANTS.md + GAP-REGISTER.md в контекст сессии
# Триггер: при запуске Claude Code в vibe-coding

echo "=== BANXE Architecture Context ==="
echo "Invariants: $(wc -l < ~/banxe-architecture/INVARIANTS.md) lines"
echo "Open gaps: $(grep -c 'OPEN' ~/banxe-architecture/GAP-REGISTER.md)"
echo "PRIORITY: G-03 (stop button), G-16 (ports), G-17 (event store)"
```

### Конфигурация в .claude/settings.json

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/policy-guard.sh $TOOL_INPUT_PATH"}]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {"type": "command", "command": "bash .claude/hooks/invariant-check.sh $TOOL_INPUT_PATH"},
          {"type": "command", "command": "bash .claude/hooks/bounded-context-check.sh $TOOL_INPUT_PATH"}
        ]
      }
    ]
  }
}
```

---

## 4. FINOS AIGF v2.0 Risk Mapping (G-22)

| AIGF v2.0 Risk Category       | BANXE GAP | Контроль (current)                           | Target Control             |
|-------------------------------|-----------|----------------------------------------------|----------------------------|
| Agent autonomy creep          | G-05      | change-classes.yaml CLASS_B ✅               | CI enforcement (Sprint 3)  |
| Uncontrolled agent actions    | G-03      | emergency_stop.py (PAUSED)                   | EmergencyPort + Marble UI  |
| Audit trail integrity         | G-01      | ClickHouse append-only (partial)             | PostgresEventLogAdapter    |
| Explainability gap            | G-02      | I-25 декларирован                            | ExplanationBundle runtime  |
| Model drift / feedback loops  | G-05      | I-21 в INVARIANTS.md ✅                      | review_agent step (G-15)   |
| Trust boundary violation      | G-04      | Orchestration Tree (документ)                | Hexagonal ports (G-16)     |
| Policy drift                  | G-08      | —                                            | Checksum CI (Sprint 3)     |
| Insufficient oversight        | G-03      | HITL partial                                 | Full EU AI Act Art.14 map  |
| Confidentiality breach        | G-10      | .env secrets (partial)                       | Vault JIT (Sprint 4)       |
| Unsafe agent chaining         | G-16/G-18 | —                                            | Bounded contexts + ports   |

---

## 5. Порядок выполнения Sprint 0

```
День 1:  Port-интерфейсы (spec в banxe-architecture/ports/) + bounded-contexts.md
День 2:  Реализовать hook-1 (policy-guard) + hook-4 (load-architecture)
         Протестировать: попробовать edit SOUL.md → должен быть BLOCKED
День 3:  hook-2 (invariant-check) + hook-3 (bounded-context-check)
         FINOS AIGF mapping в GAP-REGISTER
День 4:  Рефакторинг emergency_stop.py → EmergencyPort interface
         Документ bounded-contexts.md с диаграммой контекстов
День 5:  Review + commit + push всего Sprint 0
```

---

## 5. Multi-Agent Review Pattern для feedback_loop.py (G-15)

**Проблема:** Один агент предлагает патч — сам себя и «проверяет».
Самопроверка агента хуже независимого review (Matthew Rocklin, arXiv).

### Расширенный flow feedback_loop.py

```
Шаг 1: patch_proposer  (текущий feedback_loop.py --report)
         ↓ REFUTED corpus analysis
         → proposed_patch.diff

Шаг 2: review_agent  (НОВЫЙ — отдельный LLM контекст, temperature=0)
         Получает: proposed_patch.diff + SOUL.md + INVARIANTS.md + change-classes.yaml
         Проверяет:
           □ Не нарушает ли патч red lines SOUL.md?
           □ Не создаёт ли регуляторный риск (jurisdiction, threshold, forbidden pattern)?
           □ Соответствует ли change class (AMBER/RED)?
           □ Если Class B (SOUL.md/AGENTS.md) → немедленный REJECT, не APPROVE
         Выдаёт: review_report.md с вердиктом [APPROVE | REJECT | ESCALATE]

Шаг 3: human gate
         Только при вердикте APPROVE:
           → показывается diff MLRO в Telegram / Marble UI
           → MLRO явно подтверждает (кнопка или Telegram reply)
         При REJECT → патч отбрасывается, записывается в rejection_log.jsonl
         При ESCALATE → уведомление MLRO + CTO, ожидание unanimous approval

Шаг 4: apply  (только после явного human approval)
         Class A: MLRO approval → apply
         Class B: MLRO + CTO unanimous → apply через protect-soul.sh
```

### Реализация review_agent

```python
# feedback_loop.py — новый метод (Sprint 3)
def run_review_agent(proposed_patch: str) -> ReviewReport:
    """
    Запускает independent review agent в изолированном контексте.
    Использует температуру 0 для детерминированности.
    """
    context = load_review_context()  # SOUL.md + INVARIANTS + change-classes
    prompt = build_review_prompt(proposed_patch, context)
    # Отдельный LLM вызов — не тот же контекст, что patch_proposer
    response = llm.complete(prompt, temperature=0.0)
    return parse_review_report(response)
    # Returns: ReviewReport(verdict="APPROVE"|"REJECT"|"ESCALATE", reasons=[...])
```

---

## Связь с существующими документами

| Документ                                  | Связь с Sprint 0                                      |
|-------------------------------------------|-------------------------------------------------------|
| `INVARIANTS.md` I-21..I-25                | hook-1 enforces I-22; hook-2 enforces I-21; I-23 → EmergencyPort |
| `governance/change-classes.yaml`          | hook-1 реализует CLASS_B enforcement технически        |
| `decisions/ADR-009-opensanctions-yente.md`| sanctions_check → SanctionsAPIAdapter (PolicyPort)    |
| `GAP-REGISTER.md` G-03                    | emergency_stop.py → EmergencyPort refactor             |
| `GAP-REGISTER.md` G-07                    | compliance_config.yaml → ComplianceConfigAdapter      |
