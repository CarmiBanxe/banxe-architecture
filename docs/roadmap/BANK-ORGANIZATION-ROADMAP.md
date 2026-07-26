# BANK-ORGANIZATION-ROADMAP — Организация банка BANXE (35 репо)

> **STATUS: PROPOSED — каждый спринт требует отдельной операторской авторизации; ничего не активировано.**
> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> STEP9, ENGREF01, 2026-07-26. Base: origin/main 08dbb44. Companion: `../architecture/DIRECTOR-CONTROL-PLANE.md`.
> Барьеры действуют на всех спринтах: LedgerPort-only (ADR-013/I-28), `config/runtime_gate/` §72,
> MEMORY.md, пути `decisions/` заморожены (73+ входящих ссылки), ADR-102 Duplication Audit перед любым переносом.

## ПРИНЦИП УПРАВЛЕНИЯ: DIRECTOR-CENTRIC (bank engine = директор банка)

- Движок BANXE (engine-reference, ACTIVE в sandbox) = **ДИРЕКТОР БАНКА / central control plane**.
- Директор ЗНАЕТ и УПРАВЛЯЕТ: все департаменты, все отделы, всех агентов-сотрудников, всех начальников (оркестраторов).
- Все «бразды правления» сходятся к директору: единый cross-repo реестр агентов, оргструктура и оркестрация
  подчинены director control plane (L6 orchestration: LangGraph / DeerFlow / Strands).
- Директор — обязательный участник КАЖДОГО спринта: он потребитель ORG-MAP, владелец реестра агентов,
  узел эскалации HITL, точка активации.
- Иерархия управления: **Director → Department orchestrators (начальники департаментов) → Room/team leads
  (начальники отделов) → agents (сотрудники)**. Каждый уровень — с паспортом и подчинением вверх к директору.

## ИСТОЧНИК КАНОНОВ: Fable5 через фабрику

- Банковские каноны (banking canon: организационные, регуляторные, процедурные правила банка) предоставляет
  КОНСУЛЬТАНТ Fable5 ПО ЗАПРОСУ К ФАБРИКЕ.
- Механизм: на этапах, где нужен новый banking-canon (оргправила, роли, разграничение полномочий, регуляторные
  рамки), фабрика делает запрос → Fable5 (read-only advisory, confidence-scored, **<0.90 → HITL к оператору**)
  → вердикт фиксируется как canon-артефакт (PROPOSED).
- Fable5 НЕ пишет код и не активирует — только выдаёт каноны/вердикты; оператор ратифицирует.
- В каждом спринте, где создаётся оргструктура/полномочия, обязателен шаг
  **"REQUEST banking-canon from Fable5 via factory"** перед фиксацией.

## Классификация 35 репо (5 категорий + архив)

| Категория | Репо |
|---|---|
| **CORE-BANK** | banxe-architecture (штаб/HR/конституция) · banxe-emi-stack (compliance/EMI/back-office) · banxe-ui (фронт) · banxe-payment-core (платежи) · banxe-trading-backend / banxe-trading-frontend (трейдинг) |
| **PLATFORM/INFRA** | banxe-ai-infrastructure (фабрика агентов) · banxe-platform · banxe-infra · banxe-monitoring · banxe-collaboration |
| **GOVERNANCE** | factory (CANON/guardians) · banxe-business-processes (ArchiMate) · banxe-repo-template |
| **ENGINE/RESEARCH** | OpenManus-RL (153MB RL) · MetaClaw (71MB) · MiroFish/banxe-mirofish (swarm) · developer-core · OpenManus |
| **KNOWLEDGE/LEGAL** | legal-canon · legal-reference-fr · banxe-lexisnexis-distro · banxe-training-data · crypto-ops-monitor |
| **ARCHIVE (freeze, low-prio)** | banxe-archive-2026-04-18 · collaboration · legi_fr · gpt-archive-toolkit · france.code-civil · obsidian-vault · braslina · guiyon · ss1 |

## Наблюдения аудита (входные факты)

- Единый каркас: почти все репо имеют AGENTS.md + docs/canon/ (CANON-TOPOLOGY/MODULES/OVERRIDES) —
  controlled-copy из banxe-repo-template.
- Штат агентов в 3 местах: architecture (agents/passports+souls — HR-центр) / emi-stack (agents/compliance —
  живой код) / ai-infrastructure (сборка+деплой). **НЕТ единого cross-repo реестра.**
- Canon: 3 корня в architecture рассинхронены (STEP8: CANON.md 20 строк, CORE.md 37 строк);
  + controlled-copies по репо — синхронность не проверена.

---

## СПРИНТЫ (каждый = отдельная будущая программа, PROPOSED)

### S0 — Инвентаризация (паспорт 35 репо)
- **Цель:** зафиксировать паспорт всех 35 репо (готов), классификацию CORE/PLATFORM/GOV/ENGINE/KNOWLEDGE/ARCHIVE.
- **Входы:** repo-аудит (готов), классификация выше.
- **Выходы:** REPO-PASSPORT-REGISTER.md (35 строк: репо, категория, объём, статус, владелец-департамент-кандидат).
- **Director:** утверждает классификацию; реестр репо становится частью control plane.
- **Fable5:** не требуется (техническая инвентаризация).
- **Риски:** незамеченные приватные/локальные репо → сверка с `config/fleet/server-inventory.yaml`.
- **Зависимости:** нет. **DoD:** 35/35 репо в реестре, категория у каждого, Director-утверждение зафиксировано.

### S1 — Технологическая карта (cross-repo ORG-MAP)
- **Цель:** карта репо→департамент→этаж; свести bank-rooms/F0–F4 + SERVICE-MAP + archimate + banxe-business-processes.
- **Входы:** S0-реестр; bank-rooms (17 комнат на main после D2); SERVICE-MAP.md; archimate/banxe-model.xml.
- **Выходы:** ORG-MAP.md (+ диаграмма); маппинг каждого CORE/PLATFORM-репо на департамент/этаж.
- **Director = владелец ORG-MAP** (карта живёт в control plane, обновляется только через него).
- **Fable5: REQUEST banking-canon** — канон разбиения банка на департаменты/этажи (соответствие
  реальной банковской оргмодели: front/middle/back-office, 3LoD).
- **Риски:** двойная принадлежность репо; расхождение bank-rooms ↔ ArchiMate. **Зависимости:** S0.
- **DoD:** каждый не-ARCHIVE репо имеет ровно один департамент; Fable5-canon ратифицирован оператором.

### S2 — Перепись штата (единый cross-repo реестр агентов)
- **Цель:** собрать все souls/passports/swarms из architecture + emi-stack + ai-infrastructure → единый реестр,
  подчинённый Director; выявить пробелы.
- **Входы:** agents/passports+souls (architecture), agents/compliance (emi-stack), деплой-манифесты (ai-infrastructure).
- **Выходы:** AGENT-CENSUS.md + machine-readable реестр (расширение Agent Registry из BANXE-AI-ENGINE-REFERENCE.md —
  единый, вторых реестров не создавать); список пробелов: агент-без-инструкции / инструкция-без-агента /
  дубли architecture↔emi-stack↔ai-infrastructure (изв. прецедент: aml_orchestrator 3-паспорта — HELD, operator/MLRO).
- **Director:** владелец реестра; каждый найденный агент приписывается узлу иерархии.
- **Fable5:** не обязателен (перепись — факт); спорные дубли → HITL оператору.
- **Риски:** stub-паспорта со status:active (читать тело, не поле); фантомные агенты. **Зависимости:** S1.
- **DoD:** 100% найденных агентов в реестре; каждый пробел классифицирован; дубли — списком на операторское решение.

### S3 — Оргструктура (иерархия управления)
- **Цель:** формализовать Director → department orchestrators → room/team leads → agents; посчитать
  департаменты/отделы фактом из S2.
- **Входы:** S1 ORG-MAP, S2 реестр.
- **Выходы:** ORG-STRUCTURE.md (+ обновление AGENT-ORG-STRUCTURE.md корня — additive); паспорта оркестраторов
  департаментов (PROPOSED, no activation).
- **Director:** вершина иерархии; все orchestrators подчинены ему (reports_to цепочка замыкается на Director).
- **Fable5: REQUEST banking-canon** — канон иерархии полномочий и разграничения ролей
  (кто может что решать; совместимость с HITL-порогами и Trust Zones ADR-030).
- **Риски:** конфликт с существующими Trust Zone/HITL канонами → additive, не переопределять. **Зависимости:** S2.
- **DoD:** каждый агент из S2 имеет путь подчинения к Director; Fable5-canon ратифицирован.

### S4 — Должностные инструкции (паспорта/souls)
- **Цель:** дописать недостающие passports/souls по agents/_template/SOUL.md; в каждый паспорт — поле
  **reports_to** (цепочка вверх к Director).
- **Входы:** S2 список пробелов, S3 иерархия, agents/_template/SOUL.md.
- **Выходы:** новые/дополненные паспорта (все PROPOSED/no-activation; PASSPORT > SOUL прецедентность сохраняется).
- **Director:** валидирует полноту штата (ни одного сотрудника без инструкции).
- **Fable5: REQUEST banking-canon** — канон шаблона должностной инструкции (обязательные поля банковской
  должностной: полномочия, лимиты, эскалация, reports_to).
- **Риски:** массовое редактирование паспортов задевает governance-гейты → по-департаментно, отдельными PR.
- **Зависимости:** S3. **DoD:** 0 агентов без паспорта; 100% паспортов с reports_to; шаблон-canon ратифицирован.

### S5 — Разнос кода из подвала
- **Цель:** бесхозный код → в свой репо/room/agent; зафиксировать владение в ORG-MAP; освободить «коробки».
- **Входы:** S1 ORG-MAP, S2 реестр, Phase-2 basement→rooms наработки (docs/roadmap/PHASE2-*).
- **Выходы:** перенос-PRы (каждый с ADR-102 Duplication Audit); обновлённый ORG-MAP (код→владелец).
- **Director:** реестр владения кодом — каждый модуль имеет агента/room-владельца.
- **Fable5:** не обязателен; спорное владение → HITL.
- **Риски:** скрытые консьюмеры (ADR-102 fail-closed); emi-stack scope (только back-office до новых гейтов).
- **Зависимости:** S1–S3. **DoD:** 0 бесхозных модулей в CORE/PLATFORM-репо; каждый перенос с Duplication Audit.

### S6 — Уборка документации
- **Цель:** R1 (canon-консолидация, operator-review 20+37 diff-строк) + R2 (слияние ADR-индексов) +
  R3 (перенос 11 корневых кандидатов) в architecture; STEP8-аудит повторить для каждого CORE/PLATFORM-репо;
  cross-repo doc-index; сверка controlled-copy canon по всем репо.
- **Входы:** DOCUMENTATION-AUDIT-2026-07-26.md (R1–R3), DOCUMENTATION-MASTER-INDEX.md, banxe-repo-template.
- **Выходы:** консолидированный canon; единый ADR-индекс; чистый корень; CROSS-REPO-DOC-INDEX.md; отчёт синхронности controlled-copies.
- **Director:** потребитель — control plane ссылается только на канонические пути.
- **Fable5:** не обязателен (техуборка); canon-консолидация контента — operator review.
- **Риски:** 73 ссылки на decisions/ (заморожено); ссылки при переносах (по одному файлу за change-set).
- **Зависимости:** независим (можно параллельно S2+). **DoD:** R1–R3 закрыты; controlled-copies синхронны или расхождения ратифицированы.

### S7 — Валидация (полнота штата и управления)
- **Цель:** доказать: каждый агент = {место + инструкция + код + reports_to→Director}; ноль бесхозных коробок;
  ноль сотрудников без кабинета; cross-repo canon синхронен; **Director control plane видит 100% штата**.
- **Входы:** выходы S1–S6.
- **Выходы:** VALIDATION-REPORT.md с метриками (штат/покрытие/пробелы=0); go/no-go к PROD-gate G-серии.
- **Director:** субъект валидации — прогон видимости 100% через control plane.
- **Fable5:** финальный advisory-вердикт полноты оргмодели (confidence-scored; <0.90 → HITL).
- **Риски:** остаточные HELD-решения (aml_orchestrator и т.п.) — фиксируются как явные исключения, не блокируют.
- **Зависимости:** S1–S6. **DoD:** все метрики зелёные или исключения ратифицированы оператором.

### Фаза Z — ARCHIVE-репо
- Только опись + заморозка (9 репо), без разноса; включение любого архивного репо в работу = отдельное операторское решение.

---

## Сводка объёма

8 спринтов (S0–S7) + фаза Z · 35 репо (26 рабочих + 9 архивных) · 3 обязательных Fable5-canon-запроса
(S1 департаменты, S3 полномочия, S4 шаблон инструкции) + 1 финальный advisory (S7) · Director-роль явно
прописана во всех 8 спринтах. Всё PROPOSED; авторизация — по-спринтно.

---
*STEP9 | ENGREF01 | PROPOSED | sandbox-labeled | Director-centric + Fable5-canon-on-demand.*
