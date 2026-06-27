# SRC-09 — Pre-Audit Synthesis

**Статус:** INGESTED
**Загружен:** 2026-06-28
**Источник:** Внутренний синтез на основе SRC-01/02/06/07 + shell-аудита (origin/main @ 6602842)

---

## Центральный тезис

[ВЫВОД] BANXE-CORE-ENGINE логично квалифицировать как coordination layer поверх уже существующих доменных сервисов, а не как систему с нуля.

Обоснование:
- [ФАКТ] 9 ADR подтверждают intent-first / orchestration / HITL / memory / guardian / self-healing архитектуру.
- [ФАКТ] Существующий orchestration-слой (Ruflo, Aider, MetaClaw, fabric/legion, 70 passports / 20 souls / 3 swarms) не требует замены — требует координации.
- [ФАКТ] Build-specs M-GATEWAY и J-ENGINE описывают конкретные компоненты, которые движок должен координировать.

---

## Что подтверждено (только [ФАКТ])

- 9 ADR (045/060/128/136/139/141/042/123/143-A) существуют на origin/main.
- LiteLLM :4000 LISTENING (INV-AI-01 enforcing point).
- Keycloak :8180/:8181 LISTENING (IAM).
- ClickHouse :9000 LISTENING (audit trail, I-08 5yr TTL).
- 70 passports / 20 souls / 3 swarms (verified S5/S6/S7; цифра «39 passports» УСТАРЕЛА).
- banxe-recon.service = inactive (HITL-gate не пройден; оператор активирует).
- AMLSim на Legion: /home/mmber/AMLSim.

---

## Что является рабочей гипотезой ([ВЫВОД])

- BANXE-CORE-ENGINE как новый coordination layer координирует Ruflo/Aider/MetaClaw/fabric — архитектурно обоснован ADR-060, но конкретная форма реализации не зафиксирована.
- ReAct/CoT/MARL/HTN как implemented runtime — логично следует из теоретической базы (SRC-02), но степень реализации не верифицирована.
- Qdrant поверх ClickHouse как vector memory — PLANNED в корпусе; Qdrant :6333 NOT LISTENING согласно snapshot.

---

## Что требует shell-аудита перед любым roadmap/sprint ([НЕИЗВЕСТНО])

- Redis :6379 — NOT LISTENING в snapshot; роль в движке требует уточнения deployment-плана.
- n8n :5678, Temporal :7233, Qdrant :6333, MongoDB :27017 — NOT LISTENING; зависимости движка от них требуют явного deployment-плана.
- banxe-rag: точный состав, формат, размещение.
- MCTS / Bayes / confidence=1.0 hard overrides как production-код — не верифицированы.
- Математика по 4 проблемам (SRC-07) — детали ожидают SRC-03..08.
- Внешние сравнения (Manus / Revolut AIR / Nebius / H100) — не имеют прямого подтверждения в verified корпусе.

---

## Ограничения синтеза

Этот документ основан только на SRC-01/02/06/07 + runtime snapshot. SRC-03/04/05/08 — PENDING-INTAKE. После их загрузки синтез должен быть обновлён (append-only).

---

## Cross-references

- Все 9 ADR (см. SRC-INTAKE-REGISTER.md)
- docs/agent-engine-dossier/VERIFIED-RUNTIME-SNAPSHOT.md
- docs/agent-engine-dossier/SRC-INTAKE-REGISTER.md
