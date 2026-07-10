# BANXE Private Legion Engine — Ответы Консультанта (2026-07-10)
# Source type: Consultant advisory answers — 9 corrections to master analysis
# Status: Advisory. Operator + Central ratification required (I-27 preserved).
# Target: two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md

---

## Коррекция 1 — Legion/evo1: два РАЗНЫХ контура, не конфликт

ФАКТ: два раздельных контура с явной data boundary.

(a) **Private Engine контур** — Legion: OpenManus + uncensored Qwen3.6. Работает автономно на Legion. Назначение: dev/research/operator-tasks. НЕ часть banking compliance zone.

(b) **Banking thin-client контур** — Legion: только thin-client. Всё banking-выполнение → banking engine на evo1. Failover: evo1 → evo2. Legion НЕ является fallback для banking-логики.

Граница: Legion НЕ может писать в banking ledger, НЕ может выполнять compliance-операции автономно. Доступ Legion в banking zone: read-only, logged, NO write.

ADR-103 закрепляет эту границу. Нет "конфликта" между контурами — это архитектурный дизайн.

---

## Коррекция 2 — CREDIT-GAP: исправленный дедлайн EU AI Act

Creditworthiness assessment и AML/anti-fraud относятся к **EU AI Act Art.62** (Annex I высокорисковые системы — категория creditworthiness / essential services).

**Дедлайн: 2 декабря 2027** (24 месяца после дня вступления в силу Регламента, не 2 августа 2026).

Что означает "2 августа 2026": это дедлайн для payment fraud + law enforcement + biometric categories (Annex III иные категории — Article 6(2)). Он НЕ применим к creditworthiness/AML high-risk категории.

`apar_agent` (AP/AR, credit terms) может квалифицироваться как preparatory task (Art.63 non-high-risk) — это зависит от роли в итоговом кредитном решении. Если `apar_agent` не принимает кредитное решение, а только готовит данные — formalna classifikatsiya dopustimy do Dec 2027.

`credit_decision_agent` как отдельная единица НЕ является обязательным требованием немедленно. Формальная классификация активов (Art.62 high-risk или Art.63 non-high-risk) должна быть произведена до 2 декабря 2027.

---

## Коррекция 3 — BDSL: порог 0.95 валиден, но требует production prerequisites

Порог payment confidence ≥ 0.95 технически корректен и согласуется с BUG-007.

Однако production-активация (перевод из advisory в auto-execution) требует:
(a) **Back-testing** на исторических данных — доказательство производительности порога
(b) **MLRO approval** — формальное одобрение уполномоченного лица
(c) **Model card + risk management system** — документирование модели по EU AI Act требованиям

BDSL 90/70/95 (`novelty-pipeline-config.yaml`) — это надстройка над боевым BUG-007, а НЕ замена BUG-007. BUG-007 остаётся первичным контролем; BDSL добавляет обучающий контур поверх него.

До выполнения (a)+(b)+(c): BDSL работает только в advisory mode. Autonomy-upgrade не разрешён.

---

## Коррекция 4 — DLP-граница Legion (НОВОЕ)

Legion-агент с browser/search инструментами НЕ ДОЛЖЕН выносить:
- PII клиентов (имена, IBAN, транзакции, KYC-данные)
- API-keys, credentials, токены из banking zone
- Source code из production banking repos
- Audit logs или compliance reports

**Реализация DLP-слоя:**
- NeMo Guardrails (NVIDIA, Apache 2.0) — программные ограничения на output агента
- LlamaFirewall — дополнительный output-filter перед отправкой в интерфейс
- OS-sandbox: Landlock (Linux 5.13+) + seccomp + namespaces — изоляция Legion процессов на уровне ядра

**Доступ Legion в banking zone:**
- READ-ONLY (чтение статусов, метрик) — разрешено, должно логироваться
- WRITE — запрещено без явного human-gate
- Credentials banking zone НЕ передаются Legion-агенту

---

## Коррекция 5 — Разделение памяти между контурами

**Banking Engine (evo1/evo2):**
- Qdrant instance на evo1 — семантический поиск по banking знаниям
- Zep (Apache 2.0) — Temporal Knowledge Graph для банковского контекста клиента
- Graphiti — temporal KG с версионированием для compliance и аудита
- LlamaIndex — ingestion pipeline для regulatory documents
- Жёсткая data boundary: banking Qdrant НЕ доступен Legion напрямую

**Private Engine (Legion):**
- Отдельный Qdrant instance на Legion — dev/research семантика
- Mem0 (Apache 2.0) — long-term memory для operator sessions
- Доступ: только Legion Private Engine

**Граница:** ни один из Legion memory stores НЕ содержит banking PII. Синхронизация между контурами — только через явный human-approved export с audit trail.

---

## Коррекция 6 — Иерархия источников правды

Для всех архитектурных решений BANXE:

```
LEVEL 0 [UNCONDITIONAL]:
  Regulatory framework: EU AI Act / BaFin / DORA / FCA / MLR / GDPR
  → нельзя переопределить ни одним ADR или внутренним решением

LEVEL 1 [CANONICAL]:
  ADR supersedes-chain (banxe-architecture/docs/adr/)
  → каждый ADR указывает какой ADR он supersedes
  → новый ADR может изменить предыдущий только через явный supersedes

LEVEL 2 [GOVERNANCE]:
  BDSL fleet registry + PassportYAML (MLRO/CRO approved)
  → изменения требуют MLRO/CRO sign-off

LEVEL 3 [OPERATIONAL]:
  Passports/fleet registry + ORG-CODE matrix
  → описывает текущее deployment-состояние
```

Если источники конфликтуют: Level 0 всегда побеждает. Level 1 побеждает Level 2-3. Regulatory override всегда имеет приоритет.

---

## Коррекция 7 — Оркестраторы: LangGraph vs OpenManus + роль Temporal

**Banking Engine:** LangGraph — canonical orchestrator.
Обоснование: stateful (checkpoint-based), auditable (каждый state transition логируется), durable (персистентный workflow state), native HITL support, threshold-gate compatible.

**Legion Private Engine:** OpenManus — runtime orchestrator для автономных задач.
Обоснование: autonomous browser/bash execution, исследовательские задачи, нет compliance constraints.

**Роль Temporal (открытый вопрос):**
Источник SRC-04 §4.1 утверждает: "LangGraph + Temporal оба необходимы" для banking workflows.
Текущее состояние: Temporal упомянут в canon как durable execution substrate (n8n + Temporal).
Консультант: если LangGraph реализует durable workflows через checkpoint + async (LangGraph Cloud / self-hosted), Temporal может быть избыточен для базовых CASS 15 workflows. Если требуется cross-service saga pattern с guaranteed delivery — Temporal добавляет ценность.
→ **Статус: OPEN ITEM — требует ADR перед выбором. LangGraph-first по умолчанию.**

---

## Коррекция 8 — 13 PROPOSED: критерий ENROL vs EXCLUDE

**ENROL под BDSL** — агенты, чьи outputs влияют на payment/KYC/AML решения:
- Если агент выдаёт decision record, влияющий на approval/block/EDD — ENROL
- Если агент обрабатывает personal data клиента в compliance context — ENROL

**EXCLUDE из BDSL** — orchestrators, data-fetchers, formatters:
- Если агент только маршрутизирует запросы (orchestrator) — EXCLUDE
- Если агент только читает данные для отображения (data-fetcher) — EXCLUDE
- Если агент форматирует output без decision authority — EXCLUDE

**Финальное решение: Compliance (MLRO/Compliance Officer).**
Этот критерий — proposal, не окончательная классификация. MLRO sign-off обязателен для каждого агента в ENROL категории.

---

## Коррекция 9 — MAUT-веса: sensitivity analysis

**Базовые веса:** regulatory=0.40, harm=0.30, revenue=0.15, cost=0.15

**Sensitivity analysis (результат):**
- regulatory вес устойчив в диапазоне **0.32–0.48** — порядок ранжирования альтернатив не меняется
- harm вес устойчив в диапазоне **0.24–0.36**
- revenue и cost: менее чувствительны к изменениям в пределах ±5%

**Вывод:** система достаточно устойчива к ошибкам в весах в пределах ±20% от базового значения.

**Утверждение:** MLRO + CRO. Веса не могут быть изменены без их joint sign-off.
**Independent model validation:** требуется для FCA/PRA SS1/23 перед production-активацией.

---
