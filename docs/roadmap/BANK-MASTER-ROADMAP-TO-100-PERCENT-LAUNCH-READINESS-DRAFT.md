# BANK MASTER ROADMAP — TO 100% LAUNCH READINESS (DRAFT, consolidated v2)

> **Status:** **DRAFT / NOT FOR MERGE** — операторский HITL обязателен
> **Date:** 2026-07-18 (v2, консолидация концепт-корпуса) · **База:** origin/main @ c66c198 · **Ветка:** agent/factory/bank-operating-model/20260718
> **Producer:** factory terminal (sandbox) — durable input для **Central terminal**
> **Companion files:** `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md` (операционный план), `BANK-ROADMAP-CONSOLIDATION-DELTA-MEMO-2026-07-18.md` (дельта v1→v2)
> **Маркировка источников:** [FACT-REPO] = подтверждено репо · [PLAN-CONCEPT] = из концепт-файлов (планировочный вход, не репо-факт) · [INFERENCE] = вывод · [UNKNOWN] = не установлено
> **Классификация треков:** [LC] Launch-Critical · [PL] Parallel non-blocking · [PX] Post-Launch eXpansion · [OD] Operator Decision · [ED] External Dependency · [UNK] Unknown

---

# 1. Purpose and planning rule

[FACT-REPO, канон] Фабрика строит ФАБРИКУ; БАНК строит **Central terminal**. Это BANK-only план; фабричный roadmap (R0–R5) исключён. Архитектурная линия неизменна: BANXE = Intent-First / AI-agent-first EMI (ADR-045); **governed autonomy, не free-form**; Banking Engine — регулируемое сердце; Private Engine/фабричный tooling — вне регулируемых решений; HITL, Decision Lineage, cost governance, BPR, consent и audit trail — **launch-critical governance substrate, не «extras»** [INFERENCE из ADR-045..049 + концепт-корпуса].

Правила: дубликаты свёрнуты (позднейший канон побеждает); концепт-идеи не попадают в critical path без фильтра; операторские решения не схлопываются в техзадачи.

# 2. Planning assumptions

- [FACT-REPO] Внутренний impl-backlog = 0 (16/16 сервисов REAL); engine L2 достигнут; conformance 86%.
- [PLAN-CONCEPT] Концепт-корпус (`/home/mmber/MetaClaw/docs/sources/`: intent-layer-launch, intent-first-banking, agent-engine-conclusion, uxui-architecture, full_structure_report, world-experience — все 2026-07-06..10) даёт согласованную governance-модель Intent Layer (S9–S13 линия, лестница L0–L4) без противоречий между файлами.
- [FACT-REPO] Launch AML/KYC стек в основном уже в коде: Ballerine (`infra/ballerine/`), Jube (`services/fraud/jube_adapter.py`), Watchman (`services/beneficiary_management/sanctions_screener.py`), eKYC (`services/kyc/`).
- [INFERENCE] Запуск = supervised slice (§9), не полный продукт: L0/L1/L2 автономия, минимальный HII-интерфейс, FPS/SEPA, без crypto/cards/BaaS.
- [UNKNOWN] Файл «Nachalnye-shagi-ot-marketinga…» существует только в S3 (footnote 50 uxui-дока) — его контент недоступен и в план не вошёл.

# 3. Critical path summary

[INFERENCE] Хребет запуска: **S-A1 (кадры+GDPR) → S-A2 (runtime prereq) → S-A3 (HITL live) → S-A4 (Intent substrate + L0/L1) → S-A5 (compliance overlay + L2 + KYC) → S-A6 (CASS-контур) → S-A7 (rails, по ключам) → S-A12 (security) → S-A13 (go-live)**. Всё прочее — [PL]/[PX]. Самый длинный внешний lead-time — ключи ClearBank/Modulr (ED-01/02): запросить в неделю 1.

# 4. Workstreams table (WS1–WS16)

| WS | Название | Класс | Статус / ключевой дефицит |
|---|---|---|---|
| WS1 | Governance & Org | [LC] | [FACT-REPO] 86%; нужны 8 решений [OD] |
| WS2 | Human Roles & HITL | [LC] | 7 SMF есть; DPO/HoC/CCO пусто [OD]; HITL-формы не live |
| WS3 | Agent Passports & Twins | [LC] частично | 38/70 ACTIVE; волны I-27 [OD] |
| WS4 | Banking Engine & Runtime | [LC] | L2 done; Qdrant deploy + L3-пакет [OD] |
| WS5 | Intent Layer & Client Intent | [LC] | + новое ядро: ClientIntentRecord, SCA/consent, revocation, BPR v1, лестница L0–L4 [PLAN-CONCEPT] |
| WS6 | Compliance / MLRO / Risk | [LC] | swarm ACTIVE; + real-time overlay 3-уровневый (<50ms/<200ms/<2s) [PLAN-CONCEPT] |
| WS7 | Safeguarding / Ledger / Recon | [LC] | REAL; нужен live-режим + FIN060 цикл |
| WS8 | Payments / Cards / FX / Rails | [LC] (rails) / [UNK] (cards) | код REAL; ключи [ED]; cards/BIN — NOT FOUND в источниках [UNK] |
| WS9 | KYC / KYB / Onboarding | [LC] | Ballerine IN-REPO; Sumsub [ED]; KYB-глубина [PX] |
| WS10 | CFO / Finance / Reg-Reporting | [LC] (FIN060) / [PL] (агенты) | генератор REAL; 6 finance-агентов PROPOSED |
| WS11 | Crypto / Blockchain | [PX] | Paybis-distributed (ADR-138); Wave B/C gated [ED]; НЕ в launch slice [INFERENCE] |
| WS12 | Product UX/UI / HII | [LC] минимум / [PX] полнота | HII 3-слойный [PLAN-CONCEPT]; ADR-167 PROPOSED; launch = Home+chat+confirmation cards |
| WS13 | API / BaaS / Dev Portal / MCP | [PX] | Developer Portal/BaaS — концепт (bunq/Starling бенчмарки); внешний MCP — [PX]+[OD] |
| WS14 | Security / Audit / Observability | [LC] | GAP-082/090 открыты [OD]; дашборды rails |
| WS15 | External Deps / Credentials / Legal | [ED] | реестр §7 |
| WS16 | Launch Readiness / Cutover | [LC] | launch slice §9, dry-run, L3-gate |

# 5. Sprint map

Детали — в `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md`. Сводка:

| Sprint | Суть | Класс | Gate |
|---|---|---|---|
| S-A0 | Planning baseline: ратификация v2, канон-гигиена ADR-046..049 | [LC] | operator |
| S-A1 | Governance & roles: GDPR (вне очереди), кадры, OD-пакет | [LC] | CEO/CTIO/MLRO/Legal |
| S-A2 | Runtime prereqs: Qdrant, cost-caps верификация, ADR-133 | [LC] | CTIO |
| S-A3 | HITL live binding: 17 форм + L2-петля | [LC] | CTIO+MLRO |
| S-A4 | Intent substrate + L0/L1: budget-policy, LineageWrapper, ClientIntentRecord+SCA+revocation, BPR v1 (10–15 правил), флаг ON (sandbox) | [LC] | CTIO |
| S-A5 | Compliance overlay + L2 supervised + KYC live: 3-уровневый overlay, Ballerine/Watchman/Jube контур, паспорта волна-1 | [LC] | MLRO |
| S-A6 | CASS closure: daily recon live, HITL-011, FIN060 dry-run | [LC] | CFO+MLRO |
| S-A7 | Rails activation: hardening, ключи, switch-on | [LC] | CTIO+COO/CFO |
| S-A8 | CFO stack: finance-агенты, RegData live | [PL] | CFO |
| S-A9 | Crypto readiness (Paybis B/C) | [PX] | MLRO+operator |
| S-A10 | HII client surface + XAI + support | [LC] минимум | CTIO+product [UNK-12] |
| S-A11 | API/BaaS/MCP exposure | [PX] | CTIO+security |
| S-A12 | Security/observability closure | [LC] | CTIO+CEO |
| S-A13 | Launch governance: dry-run, L3-gate, go-live; L3 Conditional autonomy — только после запуска slice | [LC] | CTIO+CEO+MLRO+CFO |

# 6. Operator decisions (consolidated register)

| ID | Тема | Блокирует | Источник |
|---|---|---|---|
| OD-R01 | GDPR Art.33 (GAP-085) — **немедленно** | юр.риск | [FACT-REPO] STAFF-MATRIX §6 |
| OD-R02 | Назначить DPO | WS2 | [FACT-REPO] |
| OD-R03 | Именовать Head of Compliance, CCO | WS2 | [FACT-REPO] |
| OD-R04 | OD-1: дубль `banxe_aml_orchestrator` | WS3/6 | [FACT-REPO] |
| OD-R05 | OD-5: статус `privacy_compliance_agent` | WS3 | [FACT-REPO] |
| OD-R06 | Пакет 8 conformance-решений | WS1 | [FACT-REPO] TARGET-MODEL §4 |
| OD-R07 | OD-2: PSD2 router A/B/C | WS8 | [FACT-REPO] |
| OD-R08 | OD-3: USB4 peer | WS14 | [FACT-REPO] |
| OD-R09 | Ратификация roadmap v2 + имя BANK-memo | всё | этот файл |
| OD-R10 | Qdrant evo1 деплой-окно | WS4 | [FACT-REPO] B1 |
| OD-R11 | `INTENT_LAYER_ENABLED=true` (sandbox) | WS5 | [FACT-REPO] GAP-091 |
| OD-R12 | ADR-133 (Temporal B8/B9) — не critical [INFERENCE] | WS4 | [FACT-REPO] |
| OD-R13 | Активация HITL-форм | WS2/6 | [FACT-REPO] |
| OD-R14 | Волны активации 32 паспортов (I-27) | WS3 | [FACT-REPO] |
| OD-R15 | L3-gate движка (CTIO+FCA-boundary+CEO) | WS16 | [FACT-REPO] ENGINE-ROADMAP §3 |
| OD-R16 | Контракты/ключи ClearBank+Modulr | WS8 | [FACT-REPO] |
| OD-R17 | ADR-114 Paybis go-live + MiCA stance | WS11 | [FACT-REPO] |
| OD-R18 | BaaS/API внешняя модель | WS13 | [UNKNOWN]-скоуп |
| OD-R19 | ADR «CTO = bank↔factory interface» | WS1 | [INFERENCE] |
| OD-R20 | FCA-коммуникация: CASS 15 после дедлайна | WS7 | [FACT-REPO] IL-472 |
| OD-R21 | Ратифицировать Governed Autonomy Ladder L0–L4 + ClientIntentRecord/consent-at-delegation как ADR (концепт→канон) | WS5, S-A4 | [PLAN-CONCEPT] intent-layer-launch |
| OD-R22 | Утвердить launch slice (§9) и владельца product-решений | WS12/16 | [INFERENCE] |

# 7. External dependencies

| ID | Зависимость | WS/Sprint |
|---|---|---|
| ED-01 | ClearBank keys+договор | WS8/S-A7 |
| ED-02 | Modulr keys+договор | WS8/S-A7 |
| ED-03 | Sumsub credentials | WS9/S-A5 |
| ED-04 | Sardine credentials | WS6/S-A5 |
| ED-05 | Twilio/SendGrid | WS9/S-A5 |
| ED-06 | FOS portal access | WS14/S-A10 |
| ED-07 | Offsite storage credentials | WS14/S-A12 |
| ED-08 | Paybis SRC-06 | WS11/S-A9 |
| ED-09 | Paybis SRC-07 + SRC-08 | WS11/S-A9 |
| ED-10 | FCA: RegData live + CASS 15 статус | WS7,10/S-A6,A8 |
| ED-11 | Grant Thornton engagement | WS1/S-A13 |
| ED-12 | Legal: GDPR, MiCA | WS15/S-A1,A9 |
| ED-13 | BIN sponsor / card scheme partner — только если cards войдут в scope [UNK] | WS8/[PX] |
| ED-14 | LexisNexis minimal contract — anchor для EDD high/critical (OSINT-S4) [PLAN-CONCEPT] | WS6/[PL], OSINT-S4 |

# 8. Unknowns register [UNKNOWN]

| ID | Вопрос | Закрытие |
|---|---|---|
| UNK-01 | Формальный гейт фазы 3 | оператор (кандидат: L3-gate) |
| UNK-02 | Формальный гейт фазы 4 | оператор; вне bank-path |
| UNK-03 | Board sign-off процедура | governance-док или решение CEO |
| UNK-04 | Имена HoC/CCO; штат ниже SMF | оператор |
| UNK-05 | Место Private Engine после деплоя | отдельный ADR |
| UNK-06 | BaaS/dev-portal модель | Central/OD-R18 |
| UNK-07 | Перечень «6 missing intent-variants» | аудит intent-layer-masks в S-A4 |
| UNK-08 | «v7/v8/v9» как именованные версии концепции — не идентифицированы; корпус найден в `/home/mmber/MetaClaw/docs/sources/` под другими именами | операторское подтверждение маппинга |
| UNK-09 | Cards/BIN sponsor — NOT FOUND во всех источниках (только CardControlCard UI-концепт) | Central: in/out of launch scope |
| UNK-10 | Последствия пропуска CASS 15 дедлайна для FCA-статуса | оператор/юрист |
| UNK-11 | Cost-governance runtime (LiteLLM BudgetManager конфиг задеплоен?) | верификация S-A2 |
| UNK-12 | Владелец product-решений | оператор (OD-R22) |
| UNK-13 | Контент «Nachalnye-shagi…» (только в S3, footnote 50 uxui-дока) — marketing/onboarding-конверсия не консолидированы | оператор: предоставить файл |

# 9. Launch slice definition

[INFERENCE, предложение к ратификации OD-R22] **Минимальный supervised launch slice:**

**Входит [LC]:** Intent Layer L0 Advisory + L1 Alert + L2 Supervised (всегда HITL-подтверждение); governance substrate полностью (ClientIntentRecord+SCA+revocation, budget-policy+BudgetManager, DecisionLineageWrapper+AgentDecisionRecord ClickHouse TTL 7yr, BPR v1 = 10–15 правил, compliance overlay L1/L2/L3-чеки); минимальный HII: Home Screen (balance+Quick Actions+AI Insight Card) + чат со structured confirmation cards (TransferCard, KYCProgressCard) + human-escalation кнопка; платежи FPS/SEPA (по ключам); KYC Ballerine + sanctions Watchman + fraud Jube; CASS-контур live; первые client-safe агенты: analytics-agent (L0/L1) + payments-agent (L2).

**НЕ входит:** [PX] crypto (Paybis-distributed, gated), cards (UNK-09), savings (концепт не детализирован), marketplace, BaaS/White Label, внешний API-portal/MCP, voice-режим, L3/L4 автономия, TradingView Pro, SME Business Hub.

# 10. Post-launch expansion lanes

- **Lane 1 — Autonomy scale [PX]:** L2→L3 Conditional (по правилам BPR) → L4 Delegated; monthly SMF evidence review (Grafana drift dashboards) как обязательное условие L4 [PLAN-CONCEPT].
- **Lane 2 — Product surfaces [PX]:** Crypto Hub (после ADR-114), Cards (после UNK-09/ED-13), Savings, Analytics deep, SME Business Hub, voice (Whisper/Piper).
- **Lane 3 — Commercial [PX]:** BaaS/White Label (Minna-модель), Developer Portal (bunq-паттерн), Marketplace (Starling-паттерн), внешний MCP; маркетинговый тезис «единственный AI-банк с Decision Lineage» [PLAN-CONCEPT].
- **Lane 4 — OSINT deepening [PL/PX]:** Yente-адаптер (частично есть), GDELT adverse-media, OpenCorporates/Companies House/FinCEN BOI (KYB), OCCRP Aleph, SpiderFoot/Maltego CE, Reputell, FATE federated learning (замена World-Check/LexisNexis) — минимально достаточный launch-стек уже IN-REPO [FACT-REPO].
- **Lane 5 — Engine advanced [PX, PLAN-CONCEPT]:** Temporal saga (B8/B9, ADR-133), PRAGMA/GNN/FinRL-идеи из engine-v2 — строго после запуска, через канон-гейты.

# 11. Epic extensions addendum (rev. 3, additive)

[INFERENCE] Эпик-надстройка P0/P1/P2 добавлена в sprint plan (`BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md` §Epic addendum): P0 «Governed Intent Layer v1» (G1–G4 → S-A2/A3/A4; новые **ADR-172** ClientIntentRecord, **ADR-173** Autonomy Ladder L0–L4 — оба PROPOSED/DRAFT; lineage/cost — конкретизации существующих ADR-046/047 без новых номеров, ADR-102 reuse) и «Delegation Center v1» (S-A10.1, revocation = [LC]); P1 — SME Co-Pilot v1, Compliance Co-Pilot v1, Rich Cards Core v1 [PL]; P2 — Partner API, MCP Server v1, Business Co-Pilot v2 [PX]. OD-R21 теперь частично материализован draft-ADR'ами 171/172 — ратификация остаётся операторской.

[PLAN-CONCEPT, аддитивно] OSINT-трек приоритизирован в два эпика: **P0 «Compliance Source Governance & Regulator Anchor» [LC]** (OSINT-P0-1 LexisNexis contract definition [ED-14]; P0-2 yente baseline deploy; P0-3 multi-list sanctions/PEP baseline на Watchman; P0-4 AML Policy update + **ADR-174** source governance: иерархия источников/risk weighting/evidence usage — new, PROPOSED) и **P1 «Compliance Intelligence Stack v2 (OSINT Core)» [PL]** (P1-1 Corporate Registers OpenCorporates/CH/BOI; P1-2 Adverse Media&Courts GDELT/Aleph/CourtListener; P1-3..6 OSINT-backed Readiness Score / KYC-KYB Gap Finder / Transaction Risk Overlay / Audit Pack Builder с source traceability) — data layer для Compliance Co-Pilot v1. P2-расширение ограничено исчерпывающим перечнем: entity resolution/graph, internal dashboards, case triage, policy copilot. Alias-маппинг прежних ID (OSINT-S*/CompCoPilot-S*) — в sprint plan. Уточняет Lane 4 §10. Компоненты источника вне clearnet-периметра — explicitly out of scope до отдельного решения MLRO/Board.

---
*DRAFT / NOT FOR MERGE. v2 supersedes v1-структуру этого же файла (delta: см. BANK-ROADMAP-CONSOLIDATION-DELTA-MEMO-2026-07-18.md); rev.3 — аддитивная секция §11.*


---
> **SUPERSEDED (2026-07-23):** consolidated into the single **GENERAL-LINE** roadmap → `../roadmap/GENERAL-LINE-ROADMAP-2026-07-23.md` (see its §4 mapping / §5 register). This file is retained for history; the GENERAL-LINE is the source of truth. IL-ledger unaffected.
