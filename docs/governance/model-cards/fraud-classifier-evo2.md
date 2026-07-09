# Model Card — fraud-classifier (evo2)  —  model TBD, AWAITS OPERATOR  (DRAFT)

> **DRAFT — gap-tracking card.** MRM §3 (T1 — Regulated-critical) lists a **"fraud classifier on evo2"**, but **no distinct fraud model is named** in `docs/canon/HW-MODEL-UPGRADE-matrix.md` or elsewhere in repo canon. Per the no-invention rule, this card records the gap honestly — **no model id is fabricated**. It is NOT yet a resolved model-card slug; it tracks the T1 fraud-classifier role until the operator names the model.

---

## 1. Identity
- **Model / alias:** **model TBD — AWAITS OPERATOR** (no distinct fraud model asserted in repo; DEPLOYMENT-ARCHITECTURE §1.1 references a "fraud classifier on evo2" as a role only).
- **Role in canon:** T1 fraud classifier on evo2 (MRM §3; ai-data-flow §"PII/KYC/AML routing").
- **MRM tier (inferred):** **T1 — Regulated-critical** (MRM §3).
- **Binding regulatory classification:** **AWAITS OPERATOR** (MRM §3).

## 2. Provenance
- **Source / weights:** **AWAITS OPERATOR** — operator to name the deployed model backing the evo2 fraud-classifier role (or confirm it is one of the existing evo2 models). Not inferred.
- **Quantization / size / host:** **AWAITS OPERATOR** (host = evo2 per MRM §3; model id unknown).
- **Route:** via LiteLLM once the backing model is named — no direct model IDs in caller config.

## 3. Intended use & boundaries
- **Intended use:** fraud classification feeding regulated AML/fraud decisions (T1).
- **Out of scope / non-goals:** MUST NOT autonomously action a regulated fraud decision without HITL.
- **Human-in-the-loop:** T1 → operator gate (MEDIUM) + MLRO sign-off (P5).

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Guardian + Canon Judge (audit-only) — MRM §4/§5 (applies once the model is named).
- **Eval results / limitations:** **AWAITS OPERATOR** — KPI §6 implies "model accuracy >95% on fraud detection" (CRO role, JOB-DESCRIPTIONS) but no measured result for a named model exists in repo.
- **Independent validation (SR 11-7):** **AWAITS OPERATOR** (MRM §5).

## 5. Lifecycle controls (existing mechanisms — MRM §4)
- **Deployment gate:** Operator gate (MEDIUM) — T1 (once named).
- **Monitoring:** LiteLLM request logging + immutable audit logs (INV-07).
- **Monitoring thresholds:** **AWAITS OPERATOR** (MRM §6) — incl. the >95% fraud-accuracy target binding.
- **Decommission:** `ollama rm` = per-model operator confirmation (G-CLUSTER-03).

## 6. Provenance of this card
- **Author / date:** Factory (S-MRM T1 cards) / 2026-06-26 — **DRAFT (gap-tracking)**. · **Owner:** **CRO — AWAITS OPERATOR**.
- **Refs:** `docs/governance/MODEL-RISK-MANAGEMENT.md` §3 (T1 fraud classifier); `docs/DEPLOYMENT-ARCHITECTURE.md` §1.1; `docs/governance/KPI-DORA-FRAMEWORK.md`/JOB-DESCRIPTIONS (>95% fraud accuracy target); `scripts/mrm-validate.sh`; `adrs/ADR-FRAUD-03-lightgbm-gbm-baseline.md` (LightGBM GBM baseline, fraud-only — complementary interpretable baseline; ADOPT #111, PROPOSED); `adrs/ADR-FRAUD-04-heterogeneous-gnn.md` (heterogeneous GNN over the multi-entity tx graph, atop the GBM baseline; ADOPT #49, PROPOSED).
- **Action to close:** operator names the evo2 fraud model → rename/replace this card to `<model-slug>.md` with verifiable provenance.
