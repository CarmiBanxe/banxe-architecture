# SPRINT-0-PLAN.md — Архитектурный спринт

**Статус:** ACTIVE
**Версия:** v1 (2026-04-05)
**Цель:** Формализовать архитектурный фундамент BANXE AI Bank перед реализацией функциональных спринтов.
**Длительность:** 0-1 неделя
**Связанные gaps:** G-16, G-18, G-21, G-22

## Задача 1: Hexagonal Architecture — Port-интерфейсы (G-16)

### Что создать

4 формальных Port-интерфейса для агентной архитектуры:

| Port | Тип | Назначение | Контракт |
|------|-----|-----------|----------|
| PolicyPort | READ-ONLY | Доступ агентов к SOUL.md/AGENTS.md | get_policy(scope) -> PolicyDocument |
| DecisionPort | OUTPUT | Результат решения агента | emit_decision(AMLResult, ExplanationBundle) -> DecisionEvent |
| AuditPort | APPEND-ONLY | Запись в audit trail | append(event: DomainEvent) -> receipt_id |
| EmergencyPort | BIDIRECTIONAL | Emergency stop channel | check_stop() -> bool, activate_stop(reason) -> StopEvent |

### Почему это важно

- I-22: PolicyPort без write-метода = архитектурное ограничение
- I-24: AuditPort без update/delete = append-only по контракту
- I-23: EmergencyPort.check_stop() обязателен перед DecisionPort

### Критерии готовности

- [ ] Python ABC-интерфейсы для 4 портов в ports/
- [ ] MockAdapter для каждого порта (тесты)
- [ ] Документация: какой инвариант какой порт защищает

## Задача 2: DDD Bounded Contexts (G-18)

### 5 Bounded Contexts

Compliance: KYC/AML, sanctions, MLRO alerts
Decision Engine: AI-агенты, scoring, ExplanationBundle
Policy: SOUL.md, AGENTS.md, change governance (READ-ONLY)
Audit: Append-only event store, reporting
Operations: Emergency stop, health checks, monitoring

### Правила взаимодействия

| Из/В | Compliance | Decision | Policy | Audit | Operations |
|------|-----------|----------|--------|-------|------------|
| Compliance | - | Events | Read | Append | Check stop |
| Decision | Events | - | Read | Append | Check stop |
| Policy | - | - | - | Append | - |
| Audit | - | - | - | - | - |
| Operations | Commands | Commands | - | Append | - |

### Критерии готовности

- [ ] Директории созданы
- [ ] Каждый context имеет свой __init__.py с публичным API
- [ ] Cross-context imports запрещены (проверяется hook)

## Задача 3: Claude Code Hooks — зонирование AI-кода (G-21)

### 4 обязательных hook

1. policy-guard (PreToolUse): блокирует запись в /policy/ из agent-контекста (I-22)
2. invariant-check (PostToolUse): после изменения файла запускает check-compliance.sh
3. bounded-context-check (PostToolUse): запрещает cross-context imports
4. load-architecture (SessionStart): инжектирует INVARIANTS.md + MEMORY.md в сессию

### Зоны AI-генерации кода

| Зона | Директория | AI-генерация | Ревью |
|------|-----------|-------------|-------|
| RED | policy/ | ЗАПРЕЩЕНА | Unanimous MLRO+CTO (CLASS_B) |
| AMBER | decision_engine/, compliance/ | Через Claude Code | Архитектор + Ревьюер |
| GREEN | operations/, audit/adapters/ | Свободная vibe-coding | check-compliance.sh + hooks |

### Критерии готовности

- [ ] .claude/hooks/ директория с 4 скриптами
- [ ] .claude/settings.json с конфигурацией hooks
- [ ] Тест: попытка записи в policy/ блокируется

## Задача 4: FINOS AIGF v2.0 Risk Mapping (G-22)

| AIGF Risk | Наш GAP | Контроль | Статус |
|-----------|---------|----------|--------|
| Agent autonomy creep | G-05 | CLASS_B_SOUL_AGENTS | COVERED |
| Uncontrolled actions | G-03 | Emergency stop | PAUSED |
| Audit trail integrity | G-01, G-17 | Event Sourcing + I-24 | PARTIAL |
| Explainability gap | G-02 | ExplanationBundle + I-25 | OPEN |
| Model drift | G-08 | Policy checksum in CI | OPEN |
| Feedback loop risk | G-05 + I-21 | No-autowrite SOUL.md | COVERED |
| Agent identity | G-12 | SOUL.md partial | PARTIAL |
| Privilege escalation | G-10 | ZSP/JIT secrets | OPEN |
| Cross-agent contamination | G-04, G-18 | Trust boundaries + BC | OPEN |
| Regulatory non-compliance | G-03 | HITL Art.14 | PAUSED |

### Критерии готовности

- [ ] Маппинг-таблица добавлена в governance/
- [ ] Недостающие контроли добавлены в Sprint 1-4
- [ ] Ссылка на FINOS AIGF v2.0: github.com/finos/ai-governance-framework

## Коллаб-модель

Claude Code (архитектор): Port ABC, bounded contexts, hook-скрипты
Aider/Oleg (исполнитель): Adapters, миграция кода в bounded contexts
check-compliance.sh: финальный gate перед merge
git push: только если все checks пройдены

## Definition of Done

- [ ] 4 Port-интерфейса формализованы
- [ ] 5 bounded contexts созданы с правилами изоляции
- [ ] 4 Claude Code hooks настроены
- [ ] AIGF v2.0 risk mapping завершён
- [x] GAP-REGISTER.md обновлён до v3
- [ ] Все существующие тесты проходят
