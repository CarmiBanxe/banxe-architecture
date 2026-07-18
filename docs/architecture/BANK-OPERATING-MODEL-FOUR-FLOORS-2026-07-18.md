# ARCHITECTURE MEMO v2 — BANXE BANK: verified blueprint «четырёхэтажного здания»

> **База:** origin/main @ c66c198
> **Метод:** 4 read-only разведки (org structure, engine, roadmap/phases, governance/MLRO) + точечная перекрёстная верификация grep'ом по origin/main; файлы канона не изменялись.
> **Статус:** synthesis + verification; кандидат в канонический BANK operating model blueprint.
> **Дисциплина:** [ФАКТ] = подтверждено файлом репо · [ВЫВОД] = следует из фактов · [НЕИЗВЕСТНО] = в репо не установлено.
> **Дата:** 2026-07-18 · **Автор:** factory sub-terminal A (sandbox) · **Track:** [ARCH-OM-2026-07-18]

---

## 1. Что BANXE уже есть

[ФАКТ] Intent-First / AI-agent-first EMI: слоевая модель L1 Intent → L2 Execution → L3 Governance → L4 Data закреплена в `docs/adr/ADR-045-intent-first-banking-architecture.md` (ACCEPTED, concept-only снят амендментом IL-693/PR #860).

[ФАКТ, верифицировано] Все 16 marker-сервисов emi-stack — REAL, внутренний impl-backlog исчерпан: `docs/architecture/EMI-IMPL-STATE-REFRESH-2026-06-26.md`, секция «FINAL re-baseline (16/16 REAL) — impl-backlog exhausted». Остаточные NotImplementedError — только внешние провайдеры (Twilio/Sumsub/Modulr/Sardine/FOS) и PAYBIS-parked legacy-crypto адаптеры.

[ФАКТ, верифицировано] Target-model conformance = **86%** по формуле (10 PRESENT + 0.5×4 PARTIAL)/14 applicable; путь к 100% — только операторские решения, новых governance-артефактов строить не нужно: `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md` §2.

[ВЫВОД] Структурно BANXE — «банк, построенный вчерне»: несущие конструкции, инженерия и регуляторный каркас готовы; дефицит — не код, а **активация** (флаги, ключи, назначения, sign-off'ы).

## 2. Верифицированное четырёхэтажное здание

[ФАКТ, верифицировано] Канонический план здания уже существует: `governance/MASTER-ORG-CODE-RUNTIME-DOSSIER.md` §2 «FOUR-FLOOR ARCHITECTURE MAP», и его нумерация — **сверху вниз от клиента**, не снизу от ядра:

| Этаж (канон репо) | Содержимое | Состояние (по §2 досье + engine-досье) |
|---|---|---|
| **FLOOR 1: CLIENT / INTENT-FIRST** | клиентский вход, intent-слой, agent masks (ADR-049) | [ФАКТ] **тончайший этаж**: «intent-first missing 6 variants»; Intent Dispatcher — код merged (infra#27), но `INTENT_LAYER_ENABLED=false` (GAP-091) |
| **FLOOR 2: ORCHESTRATION / EXECUTIVE / DEPT-HEAD AGENTS** | LangGraph planner (DEPLOYED), A2A bus Redis Streams (ADR-150, merged), LiteLLM :4000, MCP registry ADR-147 (34 tools), n8n, агенты-двойники глав департаментов | [ФАКТ] «agent stubs not activated, gated on HITL-L4»; Qdrant :6333 — код merged, evo1-деплой pending |
| **FLOOR 3: BANKING DOMAIN / RAILS / AML / FINANCE** | Midaz ledger, safeguarding-engine (REAL, recon v2 DONE), payment rails C-fps/sepa/swift, FX, AML-движки (Jube/Marble/Watchman/Yente), ClickHouse audit 5yr | [ФАКТ] **сильнейший этаж**: «payment/ledger/recon operational» |
| **FLOOR 4: GOVERNANCE / HITL / AUDIT / SMCR** | 17 HITL-гейтов, Guardian, Decision Lineage ADR-046, XAI ADR-169, append-only IL/ACTION-LEDGER (I-24), SMF-роли | [ФАКТ] «governance artefacts mature» |

[ВЫВОД] Гипотеза оператора и канон репо описывают **одно здание с обратной нумерацией**: операторский «этаж 1 (execution)» = repo FLOOR 3; «этаж 2 (orchestration)» = repo FLOOR 2; «этаж 3 (risk/compliance)» = repo FLOOR 4 + AML-движки FLOOR 3; «этаж 4 (люди)» = SMCR-люди FLOOR 4 + их агентские двойники FLOOR 2. **В гипотезе оператора отсутствовал целый этаж — клиентский вход (repo FLOOR 1)**, и именно он по досье самый тонкий. Далее нумерация репо используется как каноническая.

[ВЫВОД] Операционная логика здания: клиент входит на FLOOR 1 → намерение диспетчеризуется на FLOOR 2 (planner → агенты → A2A → LiteLLM) → деньги двигаются на FLOOR 3 → каждый значимый шаг поднимается лифтом HITL на FLOOR 4 к людям и падает в append-only аудит. Сегодня «работают» этажи 3–4; этажи 1–2 построены, но обесточены флагами и I-27-гейтом активации.

## 3. Орг-схема людей

[ФАКТ, верифицировано] `governance/CANONICAL-ORG-CHART-v2.md`: 8 департаментов, 3 линии защиты, независимые регуляторные линии структурно отделены.

```
Board / Audit Committee
 ├─ Internal Audit (SMF5, Grant Thornton, outsourced) — 3-я линия, read-only
 ├─ MLRO / Financial Crime (SMF17, Sarah Mitchell) — «reports to Board, direct, independent;
 │    NOT inside Compliance; NOT under CFO/COO» [ФАКТ, дословно из org-chart]
 └─ CEO (SMF1, Moriel Carmi)
     ├─ CFO (SMF2, David Goldstein) — CFO Office
     ├─ CRO (SMF4, Elena Vasilenko) — Risk & Compliance (2-я линия)
     │    └─ Head of Compliance — monitoring/advisory, НЕ SAR-authority [имя: НЕИЗВЕСТНО]
     ├─ COO (SMF24, James Hargreaves) — Operations (1-я линия)
     ├─ CTO (SMF26, Oleg) — Tech/Data/AI (1-я линия)
     ├─ CCO — Front Office [имя: НЕИЗВЕСТНО]
     └─ HR/Legal (Laura Bennett) + DPO [НЕ НАЗНАЧЕН — открытая позиция, ФАКТ из STAFF-MATRIX-v3/ORG-STRUCTURE]
```

[ФАКТ] Полный человеческий штат ниже SMF-уровня в репо отсутствует (вероятно operator vault) — [НЕИЗВЕСТНО].

## 4. Орг-схема агентов

[ФАКТ, верифицировано] `governance/STAFF-MATRIX-v3.md`: filesystem-scan 2026-07-02 = **70 YAML-паспортов** (подтверждено: `git ls-tree agents/passports/` = 70), v2→v3 дельта +26.

Состав [ФАКТ]: 12 двойников глав департаментов (`ceo_orchestration_agent`, `cfo_orchestration_agent`, `cto_platform_agent`, `risk_oversight_agent`…), 7 AML-субагентов (все ACTIVE, RED zone, под `banxe_aml_orchestrator` = MLRO-only по канону org-chart §4), 6 finance-агентов (все PROPOSED), 13 платформенных (mix), 32 PROPOSED в ожидании I-27 HITL-L4 активации; ~21 soul-файл в `agents/souls/`.

Автономия [ФАКТ, ADR-128]: **L1 auto** — read-only/мониторинг (`internal_audit_agent`); **L2 review** — агент предлагает, человек решает (все двойники департаментов); **L3 human-only** — SAR, PEP, санкции, prod deploy (GPG-подписанное действие человека).

**Рассинхроны people↔agents** [ФАКТ, STAFF-MATRIX-v3 §5]: OD-1 — дубль `banxe_aml_orchestrator` (root и `aml/`); OD-5 — `privacy_compliance_agent` PROPOSED в v3 vs ACTIVE в v2, при этом человеческий двойник (DPO) вообще не назначен; Board Reporting Agent — «passport TODO». [ВЫВОД] Паттерн гэпов: у сильных этажей (3) агенты ACTIVE, у слабых мест (privacy, board reporting, finance) — и человек не назначен, и агент не активирован.

## 5. Роли CEO / CTO / MLRO

**CEO (SMF1)** [ФАКТ]: вершина исполнительной вертикали; 6 HITL-гейтов (004, 007, 008, 012, 015, 017); председатель ALCO/Risk Committee (`docs/ORG-STRUCTURE.md`).

**MLRO (SMF17)** [ФАКТ]: структурно независим, прямое подчинение Board; SAR неделегируем (POCA 2002 s.330, HITL-001); 7 гейтов; собственный агентский аппарат (7 AML-субагентов). Compliance Monitoring — отдельная функция без SAR-полномочий.

**CTO (SMF26)** [ФАКТ]: гейты HITL-013 (production deploy), HITL-014 (AI model update, с CRO), HITL-015 (security, с CEO); периметр фабрики и project-кластера — ADR-117; инфраструктурные GAP-082/090/092 адресованы CTIO. [ВЫВОД] Это и делает CTO практическим интерфейсом банк↔фабрика: любой продукт фабрики входит в банк только через CTO-гейты. [НЕИЗВЕСТНО] Явная формулировка «CTO = bank↔factory interface» в репо не зафиксирована — кандидат на короткий ADR.

## 6. Граница двух движков

[ФАКТ, верифицировано] `docs/architecture/two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md` §AUDIT-2026-07-10: **Private Engine (llama-server :8080 + OpenManus :8000) NOT LISTENING → BLUEPRINT / NOT-DEPLOYED**; на Legion живы только Ollama :11434 + LiteLLM :4000. Private circuit — «NOT part of banking compliance zone», мандат: dev/research/operator.

[ФАКТ] **Banking Engine** (evo1, LangGraph + swarm) — регулируемое сердце: adoption gate «5/5 GAP epics code-merged» (`docs/agent-engine-dossier/SPRINT-PLAN.md`), residual: B1 Qdrant evo1-deploy pending, B8/B9 blocked на ADR-133.

Почему граница жёсткая [ВЫВОД из фактов]: (а) финансовые действия требуют полного L3-стека — HITL-MATRIX, Decision Lineage ADR-046, XAI ADR-169, append-only I-24 — всё это встроено только в Banking Engine circuit; (б) ADR-040 запрещает cloud/нерегулируемым контурам deny-paths (compliance/*, kyc/raw/*, secrets/*); (в) I-27: AI PROPOSES, human DECIDES — Private Engine автономен по конструкции и потому несовместим с regulated-зоной.

Разрешённые интерфейсы [ФАКТ/ВЫВОД]: общий LiteLLM :4000 как единственная точка инференса (I-32/I-33, обход закрыт Sprint-B B6); продукты фабрики → в банк только через CTO-гейты HITL-013/014; append-only ledger'ы как общая учётная плоскость. Прямых вызовов Private Engine → банковские сервисы быть не должно; защищающие инварианты: I-27, I-24, ADR-040 deny-paths, ADR-160 write-gate, ADR-154 arbitration.

## 7. Проекция 8 фаз на здание

| Фаза | Этаж (канон) | Состояние | Тип блокера |
|---|---|---|---|
| 1 Safeguarding | F3 (+F4 надзор) | [ФАКТ] REAL, recon v2 DONE; IL-472 OVERDUE (дедлайн 2026-05-07 прошёл) | регуляторный (CASS 15); операционно — активен |
| 2 Payment Rails | F3 | [ФАКТ] Spec-Locked → In Progress | **внешние credentials** (ClearBank/Modulr) + HITL-016 |
| 3 Agent Engine | F1–F2 (сердце) | [ФАКТ] L2 достигнут; L3 pending | **governance sign-off** (CTIO+CEO, FCA-boundary) + **техфлаг** (GAP-091, Qdrant) + [НЕИЗВЕСТНО] формальный гейт фазы |
| 4 Trading | F3 (Terminal B) | [ФАКТ] Phase-1 executable; S6.6/7 DROPPED (ADR-094) | **операторские решения** (5 ODR) + **legal** (MiCA) |
| 5 Legacy | F3 | [ФАКТ] CLOSED; остатки PARKED-by-canon | operator+MLRO для destructive |
| 6 Factory | вне здания | [ФАКТ] R0 DONE, R1–R5 идут | 100%-adoption traffic-light |
| 7 Paybis | F3 (+F4 Travel Rule) | [ФАКТ] Wave A DONE; B/C гейтованы | **внешняя спека** (SRC-06/07) + **governance** (ADR-114, MLRO) |
| 8 Governance | F4 | [ФАКТ] 86% | **8 операторских решений** |

[ВЫВОД] Фундамент = фазы 1, 5, 8 (готовы/почти). Центр тяжести = фаза 3: только движок объединяет этажи 1–2 с работающими 3–4. Фаза 6 идёт параллельно и банк не блокирует.

## 8. Блокеры активации и неизвестные

**Операторские решения** [ФАКТ]: OD-1..OD-5 (STAFF-MATRIX-v3 §5); 8 conformance-решений (TARGET-MODEL §4: пороги MRM, merge-queue, назначения CRO/MLRO-заместителей/VP Eng/Head of Design, активация паспортов, evo2 Prometheus, banxe-ui CI); назначение DPO; ODR-1..5 трейдинга.

**Технические флаги** [ФАКТ]: `INTENT_LAYER_ENABLED=false` (GAP-091); Qdrant evo1-деплой (B1); `AGENT_ROUTING_ENABLED=false` (GAP-COMPUTE-02).

**Governance sign-off** [ФАКТ]: L3-пакет движка (CTIO+CEO+FCA-boundary review+живые HITL-формы+ключи); ADR-133 для B8/B9 (Temporal saga).

**Срочное** [ФАКТ]: GAP-085 GDPR Art.33 (URGENT, clock running с 2026-06-27).

**[НЕИЗВЕСТНО]**: формальные гейты фаз 3/4 (operator HITL); процедуры Board sign-off (NOT FOUND, ближайшее — HITL-017); имена Head of Compliance/CCO; человеческий штат ниже SMF; place-in-building для Private Engine после деплоя.

## 9. Рекомендуемая последовательность строительства

[ВЫВОД] Принцип: изнутри наружу, sandbox прежде rails, люди прежде агентов, всё через существующие гейты. ADR-156 (sandbox-mode, гейты S-1..S-8 auto-satisfied) делает шаги 2–4 выполнимыми до продакшн-sign-off'ов.

1. **Кадры и реестр (F4, только оператор):** назначить DPO, именовать Head of Compliance/CCO; закрыть OD-1 (дубль AML-оркестратора, MLRO/CTIO) и OD-5. Нулевой код.
2. **Сердце в sandbox (F2):** Qdrant evo1-деплой (B1) → `INTENT_LAYER_ENABLED=true` в sandbox → smoke intent→dispatcher→planner→A2A→audit. Всё уже merged, это активация.
3. **Живой лифт HITL (F4):** гейты HITL-001..017 из YAML → работающие Guardian-формы; проверить L2-петлю «агент предложил — человек решил» на двойниках департаментов.
4. **Агентское заселение (F2):** поэтапная I-27-активация 32 PROPOSED-паспортов — сперва L1 read-only, затем L2-двойники; приоритет по тонким местам (board reporting, finance, privacy).
5. **Внешние двери (F3, после 2–4):** credentials-wiring Modulr/ClearBank, Sumsub/Sardine/Twilio; Paybis Wave B/C по мере SRC-06/07 + ADR-114 (MLRO). До этого — только sandbox-рельсы.
6. **Замыкание фазы 8:** 8 операторских решений → conformance 86%→100%; L3-gate движка (CTIO+CEO+FCA-boundary) — как финальный переключатель «здание → действующий банк».
7. **Параллельно, без блокировки:** фабрика (фаза 6) идёт к adoption-gate; Private Engine остаётся вне регулируемой зоны до отдельного операторского решения о его месте.
