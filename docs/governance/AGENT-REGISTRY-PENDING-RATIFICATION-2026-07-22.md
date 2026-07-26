# AGENT REGISTRY — Pending Ratification + Gated-Counsel — 2026-07-22

**GOVERNANCE / RATIFICATION QUEUE / DOCS-ONLY / READ-ONLY RUNTIME**
Companion to `AGENT-REGISTRY-MASTER-2026-07-22.md`. Lists rows that do **not** block structural completeness but remain open: 20 `[pending human ratification]` (routing/type) for `[audit]`, and 21 `[gated-counsel]` carve-outs for `[counsel]`. Nothing here is closed. Read-only over `~/banxe-emi-stack`.

## A. Pending human ratification (20) — addressee `[audit]`

| agent_id | agent | current room | proposed alternative | reason (contested) | addressee |
|---|---|---|---|---|---|
| AG-F3-012 | RiskOversightAgent | F3-risk | tooling (vs decision) | L1-Auto, no HITL, but risk-domain — decision-vs-tooling ambiguity | [audit] |
| AG-F3-016 | ProfileHistoryAgent | F3-risk | decision (vs tooling) | data-provider feeding risk decisions vs pure lookup | [audit] |
| AG-F3-021 | FxEngineAgent | F3-treasury | tooling (vs decision) | no lineage/HITL signal on FX engine | [audit] |
| AG-F3-022 | FxExchangeAgent | F3-treasury | tooling (vs decision) | no lineage/HITL signal on FX exchange | [audit] |
| AG-F3-023 | MultiCurrencyAgent | F3-treasury | decision (vs tooling) | balance handling may affect outcome | [audit] |
| AG-F3-025 | LiquidityMonitor | F3-treasury | decision (vs tooling) | monitor vs decision boundary | [audit] |
| AG-F3-027 | BalanceEngine | F3-treasury | decision (vs tooling) | compute vs decision boundary | [audit] |
| AG-F3-029 | ReportingAnalyticsAgent | F3-finbi | decision (vs tooling) | analytics read vs decision | [audit] |
| AG-F3-040 | ConsumerDutyAgent | F3-risk | (ownership) board SMF Consumer Duty champion | PS22/9; board champion = ACTION-5 (room accepted per CONFIRMED-3) | [audit] + [counsel] |
| AG-F4-005 | ObservabilityAgent | F4-devops | decision (vs tooling) | monitoring vs decision boundary | [audit] |
| AG-F4-016 | RiskScorer | F4-audit-cell | tooling (vs decision) | scoring for display vs decision-affecting | [audit] |
| AG-F4-017 | GovernanceReporter | F4-audit-cell | decision (vs tooling) | report generation vs decision | [audit] |
| AG-F1-026 | InsuranceAgent | F1-customer-ops | decision confirm / possible F3 | product decision vs tooling; room | [audit] |
| AG-F1-029 | InsurancePremiumCalculator | F1-customer-ops | F3 / Annex III relevance | life/health insurance pricing may be Annex III | [audit] + [counsel] |
| AG-F1-030 | ChurnPredictionAgent | F1-customer-ops | F3-finbi | analytics domain — possible floor move | [audit] |
| AG-F1-034 | LendingAgent | F1-customer-ops | F3-risk (credit) | credit product — floor contested | [audit] + [counsel] |
| AG-F2-045 | FatcaAgent | F2-identity | F3-aml / F3-regrep | FATCA/CRS tax-info reporting vs identity | [audit] + [counsel] |
| AG-F2-046 | ComplianceAutomationAgent | F2-identity | F3 / governance | room/type contested | [audit] |
| AG-F2-047 | ComplianceSyncAgent | F2-identity | F4 / governance | sync utility, room contested | [audit] |
| AG-F2-048 | ComplianceCalendarAgent | F2-identity | F3-regrep | compliance deadlines/reporting vs identity | [audit] |

## B. Gated-counsel carve-outs (21) — recorded not closed — addressee `[counsel]`

Placed structurally, flagged `[gated-counsel]`; licensing/regulatory characterisation is **not** decided here (aligned with the OPEN-REGULATORY-QUESTIONS register + CONSULTANT-RESPONSE brief).

**Crypto / CASP (MiCA):** AG-F2-011 CryptoApplicationService · AG-F2-012 CryptoLedgerPort · AG-F2-023 CryptoAgent · AG-F2-030 CryptoTransferEngine · AG-F2-031 TravelRuleEngine · AG-F2-032 WalletManager · AG-F2-033 CustodyReconciler — CASP ownership unresolved (register #3).

**Open-banking AISP/PISP (PSD2):** AG-F2-024 OpenBankingAgent · AG-F2-040 Psd2Agent — licence depends on AISP (read) vs PISP (initiation); `[needs-function-clarification]`.

**KYB ↔ merchant-acquiring:** AG-F2-002 KybAgent · AG-F2-025 MerchantAgent · AG-F2-026 SettlementEngine · AG-F2-027 AcquiringPaymentGateway · AG-F2-028 ChargebackHandler · AG-F2-029 MerchantOnboarding — joint perimeter unresolved (register #4).

**Midaz / MCP → ledger:** AG-F2-005 MidazMcpAgent · AG-F2-006 MidazClient · AG-F2-010 MidazAdapter — direct-write path is an external-review architecture-control question, **not asserted as fact** (register #6).

**Cards:** AG-F2-021 CardsAgent · AG-F2-022 CardIssuingAgent — register #2 CARDS RED (functional scope / BIN sponsor undefined).

**Annex III credit scoring:** AG-F3-038 CreditScoringAgent — Annex III high-risk (credit scoring of natural persons); legal determination `[counsel]`.

## Note
These 20 + 21 do not block MASTER structural completeness (86/86 census placed). They are the open items to resolve before the registry is treated as fully canonical: `[audit]` for room/type, `[counsel]` for regulatory characterisation.

---
**This does not replace legal advice.**
