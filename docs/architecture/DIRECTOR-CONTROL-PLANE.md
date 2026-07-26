# DIRECTOR-CONTROL-PLANE — спецификация «директора банка» (BANXE engine)

> **STATUS: PROPOSED — спецификация, не активация.**
> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> STEP9, ENGREF01, 2026-07-26. Companion: `../roadmap/BANK-ORGANIZATION-ROADMAP.md`,
> `../engine/BANXE-AI-ENGINE-REFERENCE.md` (7 слоёв, Agent Registry), ADR-171.

## 1. Определение

**Директор банка** = `ceo_orchestration_agent` (`agents/souls/ceo-orchestration-agent.md`: Level 1 top
orchestrator; статус **PROPOSED/STUB — GAP-078, service-кода нет**; human double = **CEO Moriel Carmi,
SMF1**; активация = HITL-L4 гейт), исполняемый на движке BANXE (engine-reference, ACTIVE в sandbox) как
central control plane. Это НЕ новый компонент — это управляющая роль поверх L6-оркестрации (LangGraph
real-time / DeerFlow long-horizon / Strands MCP-native), замыкающая на себя все «бразды правления» банком;
идентичность и подчинение — по `governance/CANONICAL-ORG-CHART-v2.md` (NORMATIVE: L0 Board → L1 CEO-агент →
L2 heads → L3 leads → L4 workers).

## 2. Что директор ВИДИТ (observability-периметр)

| Домен видимости | Источник |
|---|---|
| Полный штат агентов (все репо) | единый cross-repo Agent Registry (S2; расширение реестра из BANXE-AI-ENGINE-REFERENCE.md §2 — второго реестра НЕ существует) |
| Оргструктура: департаменты→отделы→агенты | ORG-MAP (S1) + ORG-STRUCTURE (S3); bank-rooms F0–F4 |
| Владение кодом | ORG-MAP код→владелец (S5) |
| Решения агентов (lineage) | `banxe_audit.hitl_decisions` (14+8 колонок; sandbox ClickHouse live) |
| Здоровье флота | engine-health / fleet-liveness / agent-liveness (sandbox-active, STEP4) |
| Стоимость/бюджеты | LiteLLM gateway + ADR-030 runtime_gate контур (чужой трек §72 — только читает) |
| Трассы/качество | Langfuse (ADR-168), confidence-скоры |

## 3. Чем директор УПРАВЛЯЕТ (control-периметр)

1. **Маршрутизация:** supervisor-паттерн — маршрутизирует, сам не исполняет (v2§2); выбор L6-движка по
   правилу real-time→LangGraph / long-horizon→DeerFlow.
2. **Иерархия:** назначение/подчинение department orchestrators и room/team leads; каждый паспорт
   несёт `reports_to`, цепочка замыкается на Director (S3/S4).
3. **Активация:** точка активации агентов — только через Director + операторские гейты
   (PROPOSED→sandbox-active→prod по Promotion Gates; Director сам НЕ обходит гейты).
4. **Kill-switch/override:** остановка любого агента (v4-Q) — исполняется оператором, Director
   предоставляет рычаг и контекст.
5. **Бюджеты:** per-case budget cap enforcement через ADR-030 контур (cross-ref, не владение — §72).

## 4. Интерфейс к реестру агентов

- Реестр = единственный источник штата (single registry, ADR-171 §6); Director — владелец записи.
- Контракт записи: agent, tools, LiteLLM-alias, room/department, reports_to, trust zone, maturity (L1–L5, v4-R),
  status (PROPOSED/sandbox-active/prod), passport-ссылка (PASSPORT > SOUL).
- Изменение реестра = change-set через фабрику (никаких runtime-самозаписей агентов).

## 5. Эскалация HITL

- Пороги канона (agents.md BUG-007): AUTO >0.90 / REVIEW 0.70–0.90 / BLOCK <0.70 — Director = узел,
  через который REVIEW/BLOCK доходит до дублёра (MLRO/CEO) и логируется в hitl_decisions.
- Лестница эскалации: agent → team lead → department orchestrator → Director → operator/counsel (v3-D);
  человек всегда доступен (H10/F9-4).
- Деплой-гейты: staging ≥0.75 / prod ≥0.90 + human approval (config/gates, sandbox-active).

## 6. Связь с Fable5 (canon on demand)

- Director НЕ изобретает банковские каноны. Когда оргрешению нужен banking-canon (полномочия, роли,
  регуляторные рамки) — фабрика делает REQUEST → **Fable5** (read-only advisory, confidence-scored).
- Confidence <0.90 → HITL к оператору (прецедент: D1=0.95 auto-verdict ратифицирован, D2=0.80 → HITL — модель работает).
- Вердикт Fable5 фиксируется canon-артефактом (PROPOSED); ратификация — оператор. Fable5 не пишет код,
  не активирует, не касается ledger/prod.

## 7. Границы (что директор НЕ делает)

- НЕ трогает реальный ledger иначе как через LedgerPort (ADR-013/I-28); НЕ обходит Ruflo/ARL для
  payment/compliance/kyc; НЕ переопределяет W-05 в prod; НЕ владеет runtime_gate-контуром (§72);
  НЕ активирует ничего мимо операторских Promotion Gates; PROD — только после G0–G6
  (`../engine/PROD-PROMOTION-GATE-PLAN.md`).

---
*STEP9 | ENGREF01 | PROPOSED | Director-centric управление: вся оргструктура сходится к движку, движок — к оператору.*
