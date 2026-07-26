# Webhook Agent — Control Model (ICT vertical slice)

Status: DRAFT / CONTROL DOCUMENTATION ONLY / NOT FOR MERGE — **DORA compliance is NOT asserted**; это описание фактических контролей по коду.

## Context
`WebhookAgent` (`banxe-emi-stack/services/webhook_orchestrator/webhook_agent.py`, 163 строки; модули: event_publisher, subscription_manager, delivery_engine, signature_engine, dead_letter_queue, models — 976 строк суммарно) — диспетчер исходящих событий банка. Автономия по коду [ФАКТ, docstring]: **L2 (subscribe/publish/deliver/retry); L4 HITL для deletion (I-27)**. Экземпляр-инстанция шаблона `docs/sprints/sprint-4-webhook-event-lifecycle.md` (шаблон не изменяется).

## Event lifecycle (trigger → dispatch → ack/fail)
1. **Publish:** `publish_event(event_type, payload, idempotency_key)` → событие с `event_id` + `idempotency_key`.
2. **Fan-out:** `SubscriptionManager` подбирает подписки; для каждой — `DeliveryAttempt`.
3. **Sign:** `SignatureEngine.sign(payload, secret, timestamp)` — HMAC-SHA256 [ФАКТ].
4. **Deliver:** `DeliveryEngine.deliver(attempt)` → success (attempted_at UTC) | fail.
5. **Retry:** `schedule_retry` по **RETRY_SCHEDULE = [1, 5, 30, 300, 1800, 7200] сек, MAX_ATTEMPTS = 6** [ФАКТ delivery_engine.py:27-29].
6. **DLQ:** после 6-й неудачи → `DeadLetterQueue.enqueue`; вывод из DLQ — только явный `retry_dlq_item` → новый PENDING attempt.
7. **Status:** `get_delivery_status(event_id)` / `list_events` / `get_dlq_stats` — операционная видимость.

Event-типы по коду [ФАКТ models.py]: PAYMENT_CREATED/COMPLETED/FAILED · CUSTOMER_CREATED · KYC_COMPLETED/FAILED · CARD_ISSUED/FROZEN/TRANSACTION · LOAN_APPLIED/APPROVED/DECLINED/DISBURSED · INSURANCE_POLICY_BOUND/CLAIM_FILED (+далее по enum).

## Control points
- **Input validation:** типизированные модели (EventType enum, DeliveryAttempt) — вне enum событие не публикуется.
- **Idempotency / dedup:** `idempotency_key` — параметр publish-контракта; хранится в событии [покрытие консьюмер-side dedup — Open question].
- **Bounded retry:** MAX_ATTEMPTS=6, экспоненциальный backoff 1s→2h — **нет unbounded-петель** [ФАКТ].
- **DLQ path:** выделенный `DeadLetterQueue` (enqueue/list/retry/stats); re-drive только явным действием.
- **Timeouts / circuit-breakers:** delivery-таймаут per attempt [значение — verify при A2]; circuit-breaker как отдельный механизм в коде не обнаружен — Open question.
- **Integrity:** HMAC-SHA256 подпись + `verify` через `hmac.compare_digest` (constant-time) [ФАКТ].

## Inherited gates (какие комнатные ограничения наследуются)
- **F2/payments-room:** PAYMENT_*-события несут суммы → DecimalStr (I-01); события ≥£50k-операций — следствия H-016-гейта источника (диспетчер не создаёт решений, доставляет исходы).
- **F3/aml-room:** KYC_*-события — исходы I-27-carve-out контура; не содержат raw-PII (R-SEC).
- **F3/risk-room:** LOAN_*-события — исходы credit-контура (reject всегда human-reviewed до события).
- **F4/devops-room:** retry/DLQ-метрики — в мониторинг-контур; изменения RETRY_SCHEDULE = change-control CTO.
- **F4/security-room:** HMAC-секреты подписок — I-security периметр (никогда в логи); deletion-операции — L4 HITL.
Принцип: **диспетчер наследует гейты источников** — самостоятельных регуляторных решений не принимает (инфраструктурная классификация; правовая — [counsel]).

## Logging / traceability
Delivery-attempts персистятся (delivery_store) с attempted_at (UTC) и статусами; DLQ-статистика — запрашиваемая; события несут event_id+idempotency_key для сквозной трассы. [Gap → Open questions: retention-период и связка с ClickHouse/I-24 audit-trail — verify при A2.]

## Register / room linkage
- **#7 (webhook/DORA, AMBER)** — этот документ = evidence-кандидат (control-model существует), НЕ решение и НЕ смена света.
- **PROPOSED #9/#10** — вход для будущего ICT-framework/RoI наполнения; их утверждение — операторский акт.
- Rooms: `bank-rooms/F4-devops-room/` · `bank-rooms/F4-security-room/` (ссылки добавлены).

## Open questions (DORA/ICT counsel only)
- Требуемый retention/подпись webhook-трафика для банка нашего масштаба.
- Является ли доставка каких-либо событий «regulated execution» (меняет классификацию инфра-vs-decision).
- Достаточность consumer-side dedup при поставщик-side idempotency_key.
- Нужен ли выделенный circuit-breaker поверх bounded-retry для платёжных событий.
