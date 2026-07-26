# BANXE-E0-E6.md — AI Engine Adoption Phases

> **STATUS: PROPOSED / no activation.** ENGREF01, 2026-07-26.
> Naming: engine phases are **E0–E6** — deliberately distinct from the calendar phases of
> `banxe-emi-stack/docs/BANXE-master-roadmap-v3.md` (P0 sprints, PHASE 1/2). roadmap-v3 is NOT edited by this file.
> Evidence appendix: §3. Operator decisions pending: §4.

## 1. Phases

| Phase | Content | Layer focus |
|---|---|---|
| **E0 Foundation** | Formance/Blnk (via LedgerPort ONLY — see §4.3) + Temporal + Kafka + Kubernetes | L1–L2 |
| **E1 First Agent** | LangGraph TransferAgent as composite tool | L5–L6 |
| **E2 Intelligence** | Qdrant + LlamaIndex + FinGPT sentiment RAG (AnalyticsAgent) | L3–L4 |
| **E3 Memory** | Mem0 + Zep (temporal KG); PII-scoped memory | L3 |
| **E4 Fraud/AML** | HGNN fraud + NeMo Guardrails production | L4 + L0 |
| **E5 Foundation Model** | PRAGMA-style encoder / nuFormer (BANXE-trained) | L4 |
| **E6 Federated** | FATE FL cross-bank credit scoring | L4 |

Research-track, parked outside E0–E6: QGNN/VQC fraud (AUC 0.85, horizon 2027–2028).

## 2. Mapping to existing roadmaps (read-only reconciliation)

| Existing artifact | Relation |
|---|---|
| `BANXE-master-roadmap-v3.md` (emi-stack, FROZEN 2026-07-18) | Calendar P0/PHASE-1/PHASE-2 (Apr–May 2026) — historical/operational track. E0–E6 is the engine-adoption dimension layered on top; no term collision (E≠P), no edits to v3. |
| `docs/financial-analytics-research.md` | Component catalog (50+/13 blocks) — E-phases consume its picks; delta block added separately (ENGREF01). |
| FinDev priority matrix (`.claude/rules/agents.md`) | Temporal/Kafka already P1(Q2–Q3), Airflow P2 — E0 aligns with, does not reschedule, that matrix. |

## 3. Evidence appendix (case metrics — block L)

- **Temporal** (Forrester TEI): ROI positive, $14.3M preserved revenue, ~50% faster feature dev; 2M-customer case (Will Bank).
- **Nubank**: 131M customers; ReAct paradigm; DSPy 5-stage + GEPA optimizer
  *(OP-N2: earlier session version said "Japa"; precedence latest>older → GEPA; verify against Nubank primary source (QCon/ICLR 2026) at prompt-artifact materialization; record ONE value with note — this is that note)*;
  Prompt Semantic Versioning modules Tone/Tooling/Safety; **Composite Tools > raw LLM**.
- **SOFAStack**: MYBank 750M customers; circuit-breaker / bulkhead / distributed-transaction patterns.
- **FISCO BCOS**: ~5000 TPS audit trail. **Qdrant**: Rust, sub-millisecond. **DBS "Joy"**: ~15,000 AI insights.
- External eval anchors: Finance Agent Benchmark ≈57% (⇒ HITL mandatory), McKinsey agentic KYC/AML ≈80% resolution.

## 4. OPERATOR DECISIONS — status after ratification 2026-07-26

1. **Wave order (OP-F1/M4): RATIFIED — back-office-first (Option B).** Binding sequence:
   **E0 Foundation → back-office wave (safeguarding daily-recon / CASS reporting support / BI-insight
   agents) → THEN E1 TransferAgent.** TransferAgent (customer-facing) is **BLOCKED until ledger integrity
   + live daily reconciliation are green** (S-PROD-1 P0 OVERDUE; CASS 7.15 gap, D-RECON-DESIGN.md:24;
   D-gl ≈ 5%). emi-stack unfreeze operator-APPROVED as execution prerequisite (main terminal executes;
   post-unfreeze scope = back-office agents only). See ADR-171 §Ratification Update.
2. **Branch reconciliation (OP-L1): RESOLVED — form (b) change-set split.** origin/main authoritative;
   rebase + split 910-file GENERAL-LINE commit into per-context PRs + serialized merges + ledger re-mint
   (Rule 8 / ADR-119). Campaign owner: MAIN TERMINAL. **Must complete before any S-A5/S-A6/S-A7 uplift on
   main.** See ADR-171 §Ratification Update.
3. **L2 ledger slot (unchanged, reserved):** Formance/Blnk are engine-reference candidates ONLY behind
   `LedgerPort` (ADR-013 Midaz PRIMARY / Fineract FALLBACK stands; I-28: no direct CBS HTTP). No ledger
   rewiring in any E-phase without its own ADR.

### Revised wave table (post-D1 ratification)

| Order | Wave | Content | Gate |
|---|---|---|---|
| 1 | E0 Foundation | Temporal + Kafka + K8s substrate (ledger via LedgerPort) | license-audit; §11 |
| 2 | **E-BO back-office** | safeguarding daily-recon agent, CASS reporting support, BI/insight | emi-stack unfreeze (approved, main-terminal executes); S-PROD-1 closure |
| 3 | E1 TransferAgent | customer-facing money movement (propose-only + SCA + HITL) | ledger integrity + daily recon GREEN; W-05 guard ratification |
| 4+ | E2–E6 | per §1 | per-phase gates |

---
*ENGREF01 | 2026-07-26 | PROPOSED, no activation. Cross-ref: ADR-171, BANXE-ENGINE-MATH.md, BANXE-SECURITY-OWASP.md.*
