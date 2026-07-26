# BANK-NEXT-GEN-CONCEPT — что такое банк нового поколения BANXE

> **STATUS: PROPOSED — концептуальный свод; ничего не активирует.**
> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> STEP9 v3, ENGREF01, 2026-07-26. Свод существующего канона + аналитик; ссылки, не дубли.
> Companions: `../roadmap/BANK-ORGANIZATION-ROADMAP.md` (§0–§5), `DIRECTOR-CONTROL-PLANE.md`,
> `../engine/BANXE-AI-ENGINE-REFERENCE.md`, `../master-document/01-master-full.md` v3.0.

## 1. Параметры (полный список — roadmap §0)

AI-native (агенты + human-double HITL) · composable open-source · event-driven (Midaz/Kafka/Temporal) ·
explainable/compliant-by-design (EU AI Act, GDPR, CASS 15, SM&CR) · confidence-gated autonomy
(0.75/0.90 + HITL) · fail-closed-over-best-decide · 3 Lines of Defence · federated/privacy-preserving ·
foundation-model-driven (PRAGMA-style) — **плюс три дифференцирующих**: INTENT-FIRST/agent-as-interface,
DATA-SOVEREIGNTY (on-prem Legion/evo, zero 3rd-party storage), COMPLIANCE-NATIVE (не bolt-on).

## 2. Intent-First: четыре слоя

| Слой | Содержание | Якоря |
|---|---|---|
| **Intent Layer** | chat/voice-first вход; ClientIntentRecord (consent-at-delegation, scope_limits, revocation); dual-track UX (AI + классика равноправно) | ADR-167, ADR-172, roadmap S-INTENT |
| **Execution Layer** | L5/L6: composite tools + оркестрация (LangGraph/DeerFlow/Strands); rule-bound interpreter поверх LLM-intent (детерминизм для FCA/IMF) | engine-reference §1–2, S13-00 BPR |
| **Governance Layer** | guardrails 3 уровней, confidence-гейты, HITL-пороги, NEVER-AUTONOMOUS LIST, BDT-гейт, Trust Zones | BANXE-SECURITY-OWASP, gates, S-BDSL |
| **Data-Intelligence Layer** | decision lineage (AgentDecisionRecord), foundation-модели (PRAGMA/nuFormer), federated learning (FATE), метрики BDSL | hitl_decisions (STEP5), ENGINE-MATH, S-LINEAGE |

## 3. Best-Decision математика (нормативные рамки — детали в roadmap S-BDSL и ENGINE-MATH)

VNM-ожидаемая полезность · MDP-формализация последовательных решений · **MAUT** U=Σ wj·uj ·
Secretary/optimal stopping (37%-правило; satisficing ЗАПРЕЩЁН в payment/compliance — только full-search) ·
**Minimax** (suboptimal ≤5%) · **Regret** (R̄ ≤0.05) · калибровка: **Brier ≤0.15, ECE ≤0.08** ·
counterfactual: IPW / causal forest · drift: PSI >0.25 → эскалация · Pareto Efficiency ≥0.95 ·
Escalation Recall ≥0.98. Принцип-арбитр: **fail-closed-over-best-decide**
(`../canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md`).

## 4. Director-centric управление

`ceo_orchestration_agent` (L1, PROPOSED/STUB GAP-078; human double CEO Moriel Carmi SMF1) ← 8 department
heads ← team leads ← workers; независимые линии (audit/risk/board-reporting) — к Board. Control plane =
engine L6; активация — только операторские гейты. Спецификация: `DIRECTOR-CONTROL-PLANE.md`;
норматив: `../../governance/CANONICAL-ORG-CHART-v2.md`.

## 5. Регуляторный слой (FCA-2026 и ЕС)

PSR 2017 agentic-payments + SCA machine-initiated · SM&CR (SMF ↔ Decision Lineage) · Safeguarding PS25/12 ·
Consumer Duty reversibility · DORA/PSD3 continuous reconciliation · **EU AI Act Art.9/14/15/17 + Annex
III/IV + Art.49 (регистрация в EU DB к Aug 2026)** · GDPR Art.22 · BaFin HITL. Каждый пункт → Fable5
banking-canon (roadmap §3, F5-REG-1…8).

## 6. Benchmark-ориентиры (ссылки на аналитики; без копирования чужих материалов)

Intent-First точка входа: Revolut AIR / Starling / bunq Finn (2026) · Federated: WeBank FATE ·
On-prem суверенность: WeLab (DeepSeek локально) / VietBank 100% self-hosted · MCP-платежи: Alipay-класс,
M-Pesa (mpesa-mcp) · Nubank 5 уроков: Evals-First, Composite Tools > raw LLM, DSPy/prompt-versioning,
multi-model, ReAct · Insight-масштаб: DBS Joy (~15k insights) · Dual-track UX: Alipay Project Treasure /
KakaoBank. (Источник: analytics #3, session ENGREF01.)

## 7. Дифференциатор BANXE

**Compliance-native + data-sovereignty + Intent-First by design** — три свойства, встроенные с рождения,
а не retrofit (контраст: retrofitted-AI инкумбентов). Плюс полная прослеживаемость: каждое агентное
решение → SMF-человек (SM&CR) → hash-chain lineage → объяснение клиенту (Art.13/14).

## 8. UX-appendix (ссылка на будущий UX-spec — отдельный артефакт, не этот документ)

Объём будущей спецификации: 10 mobile + 3 web экранов · Rich Cards (типизированный вывод агентов) ·
**Compliance-Audit-Trail экран** (EU AI Act Art.13 — клиентская прослеживаемость) · dual-track ·
латентность <300ms (LangGraph real-time) · WCAG 2.1 AA · i18n (EN/DE/FR/ES/IT).
Базис: BANXE-UI-* канон (4 дока) + analytics #2 deltas (уже на main).

---
*STEP9 v3 | ENGREF01 | PROPOSED | sandbox-labeled.*
