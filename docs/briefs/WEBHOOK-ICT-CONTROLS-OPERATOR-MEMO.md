# WEBHOOK CONTROLS / ICT — OPERATOR MEMO

**Status: DRAFT / INTERNAL ONLY / NO LEGAL STATUS**
**Register traceability: #7 AMBER; PROPOSED #9/#10 — NOT approved. DORA compliance is NOT asserted; этот memo документирует контроли/evidence, не регуляторную достаточность. Любые смены статусов — отдельным evidence-backed операторским процессом.**

## Scope & context
Вертикальный ICT-срез: webhook-диспетчер (`services/webhook_orchestrator/`, 976 строк модуля) как первый полностью документированный control-slice; control-model: `../governance/ict/webhook-agent-control-model.md`.

## Current evidence present (verified по коду)
- Lifecycle: publish→fan-out→sign→deliver→retry→DLQ; статус-видимость (delivery status, DLQ stats).
- **Bounded retry:** 6 попыток, backoff [1,5,30,300,1800,7200]s — unbounded-петель нет.
- DLQ с выводом только явным re-drive; HMAC-SHA256 подпись + constant-time verify; idempotency_key в publish-контракте.
- Автономия L2; deletion — **L4 HITL (I-27)** по docstring.
- Inherited-gates таблица: диспетчер наследует гейты источников по 5 комнатам (payments/aml/risk/devops/security).

## What is technically documented already
Control-model закрывает прежний register-#7 gap «gates undocumented»: факты зафиксированы. Контроли документированы; **соответствие DORA-ожиданиям — [counsel]**. Явные technical gaps (в control-model §Open): delivery-timeout значение, retention/связка с I-24-трейлом, circuit-breaker отсутствует, consumer-side dedup не подтверждён.

## Operator decisions required (CTO/infra/security)
1. A2-verify четырёх technical gaps (timeout, retention-связка, dedup, alert-маршруты DLQ).
2. Решение: нужен ли выделенный circuit-breaker поверх bounded-retry для платёжных событий.
3. Решение по принятию PROPOSED #9/#10 в основной реестр (отдельный акт; этим memo не производится).

## For counsel
- Минимальные DORA-требования retention/подписи/incident-trace для webhook-трафика банка нашего масштаба.
- Является ли доставка каких-либо событий «regulated execution» (меняет классификацию infra-vs-decision).
- Достаточность inherited-gates модели против выделенного контроль-класса.
