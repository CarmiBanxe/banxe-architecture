# BANK ROADMAP CONSOLIDATION — DELTA MEMO (для Central)

> **Status:** DRAFT / NOT FOR MERGE · **Date:** 2026-07-18 · **База:** origin/main @ c66c198
> **Дельта:** master roadmap v1 → v2 после консолидации концепт-корпуса `/home/mmber/MetaClaw/docs/sources/` (intent-layer-launch, intent-first-banking, agent-engine-conclusion, uxui-architecture, full_structure_report, world-experience, engine-v2 — 2026-07-06..10).

## 1. Что уже покрывал прежний roadmap (v1)

[FACT-REPO] 16 workstreams, 14 спринтов S-A0..A13, 20 операторских решений, 12 внешних зависимостей, 12 неизвестных; хребет governance→runtime→HITL→intent→CASS→rails→security→launch; репо-факты (16/16 REAL, L2 движка, 86% conformance, 17 HITL-гейтов, 70 паспортов).

## 2. Что добавили новые файлы

[PLAN-CONCEPT] Конкретную governance-механику Intent Layer, которой в v1 не было: **ClientIntentRecord** (мандат делегирования со scope_limits/consent/expires), **SCA consent-at-delegation** (согласие при делегировании, не при каждом исполнении), **revocation/reversibility**, **agent-budget-policy + LiteLLM BudgetManager** (per-agent halt), **DecisionLineageWrapper + AgentDecisionRecord** (ClickHouse TTL 7yr), **BPR v1 = 10–15 YAML-правил** (агент как rule-bound interpreter), **Governed Autonomy Ladder L0–L4** с явными HITL-порогами, **compliance real-time overlay** (3 уровня: <50ms/<200ms/<2s), **monthly SMF evidence review для L4**; концепт-спринты S9–S13 (вложены в S-A4/A5/A13). Плюс: HII 3-слойная модель и состав минимального клиентского интерфейса; OSINT-карта с вердиктами IN-REPO vs CONCEPT-ONLY (Ballerine/Jube/Watchman/eKYC уже в коде [FACT-REPO]); мировой бенчмарк-контекст (Minna BaaS, bunq portal, Starling marketplace).

## 3. Что повышено до launch-critical

[INFERENCE] Governance substrate целиком: ClientIntentRecord+SCA+revocation, budget-policy+BudgetManager, LineageWrapper+AgentDecisionRecord, BPR v1, compliance overlay, лестница до L2 Supervised включительно, минимальный HII (Home+чат+confirmation cards+human-escalation), client-safe пара агентов (analytics L0/L1, payments L2). Основание: концепт-файлы единогласно маркируют это launch-critical, и это согласуется с репо-каноном I-27/ADR-046..049 — не «extras», а субстрат.

## 4. Что осталось parallel / post-launch

[INFERENCE] L3 Conditional (после запуска, поэтапно), L4 Delegated + monthly evidence review, ArchiMate full BPR import (S13-00), Crypto Hub (Paybis-gated), Cards (UNK), Savings/Marketplace/SME Hub/voice, BaaS/White Label, Developer Portal, внешний MCP, OSINT-углубление (Yente full/GDELT/OpenCorporates/Aleph/SpiderFoot/Reputell/FATE), PRAGMA/GNN/FinRL из engine-v2, finance-агенты (PL), Temporal saga (ADR-133).

## 5. Что остаётся операторским решением

22 позиции OD-R01..R22 (реестр в master v2 §6). Новые в v2: **OD-R21** — ратификация Ladder L0–L4 + ClientIntentRecord/consent-схем как ADR (концепт→канон, без этого substrate нельзя строить в regulated-зоне); **OD-R22** — утверждение launch slice и владельца product-решений. Немедленное: OD-R01 (GDPR, clock running).

## 6. Что остаётся неизвестным

13 позиций UNK-01..13 (реестр в master v2 §8). Ключевые новые/уточнённые: UNK-08 — «v7/v8/v9» как имена не идентифицированы, корпус найден под другими именами (нужно операторское подтверждение маппинга); UNK-09 — cards/BIN sponsor не найден НИ в одном источнике (в т.ч. концептах — только UI-карточка CardControlCard); UNK-13 — файл «Nachalnye-shagi-ot-marketinga…» существует только в S3 (footnote 50), контент недоступен → marketing/conversion-допущения не консолидированы.

## 7. Recommended next planning move

[INFERENCE] Один HITL-сеанс Central+оператор: (1) OD-R01 GDPR — немедленно; (2) ратифицировать roadmap v2 + sprint plan (OD-R09) и launch slice (OD-R22); (3) поручить фабрике draft-ADR по OD-R21 (Ladder+ClientIntentRecord) и OD-R19 (CTO-interface) — это разблокирует S-A4-подготовку, пока идут кадровые решения S-A1; (4) запросить ED-01/02 (ClearBank/Modulr) уже сейчас — самый длинный lead-time; (5) запросить у оператора файл «Nachalnye-shagi» из S3 (UNK-13) для закрытия product/marketing-дельты.

---
*Producer: factory sandbox terminal. Никаких push/PR/merge/tag; main worktree и MEMORY.md не тронуты.*
