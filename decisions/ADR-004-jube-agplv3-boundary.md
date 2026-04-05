# ADR-004: Jube AGPLv3 — граница использования

**Статус:** ПРИНЯТО  
**Дата:** 2026-04-05  
**Автор:** Moriel Carmi (CEO)

---

## Контекст

Jube Transaction Monitoring (:5001) лицензирован под AGPLv3. Section 13 AGPL требует раскрытия исходного кода любой производной системы, взаимодействующей с Jube по сети. Даже microservice-интеграция через API может создать вирусное обязательство если BANXE начнёт предоставлять compliance-услуги третьим лицам.

## Решение

1. Jube используется ТОЛЬКО как internal tool (internal use = допустимо по AGPLv3)
2. Архитектуру и спецификации Jube изучаем как reference — паттерны SAR detection, ML scoring
3. НЕ создаём техническую зависимость — ни на уровне кода (импорт), ни API-контракта (интеграция в production pipeline)
4. Если BANXE когда-либо предоставляет compliance-as-a-service (B2B, SaaS, партнёрский доступ) — TM-движок переписывается на Apache 2.0 компонентах ДО запуска
5. Триггер для переписывания: решение CEO о B2B/SaaS compliance offering

## Граница

```
[BANXE internal] → Jube :5001 (AGPLv3 ML layer) ← ДОПУСТИМО
[BANXE as service] → external client → Jube :5001 ← ЗАПРЕЩЕНО (AGPL вирус)
```

Граница = API-контракт (HTTP :5001), не import. tx_monitor.py (deterministic rules) остаётся полностью независимым от Jube.

## Последствия

- tx_monitor.py (9 deterministic rules + Redis velocity) = независимый, заменяемый
- Jube = probabilistic ML layer, заменяемый при B2B сценарии
- Замена Jube при B2B: Apache 2.0 альтернативы (Flink, custom ONNX model)
- Документировать в DEFERRED-PROJECTS.md: "TM ML layer migration при B2B"

## Ссылки

- `INVARIANTS.md` I-15 (обновлён)
- `DEFERRED-PROJECTS.md` (при B2B decision)
