# Model Card — TEMPLATE

> Copy to `docs/governance/model-cards/<model-slug>.md` (slug = model id with `:`/`/`/space → `-`,
> e.g. `qwen3.5:35b` → `qwen3.5-35b`). One card per model/role enumerated in
> `docs/governance/MODEL-RISK-MANAGEMENT.md` §3. Validated by `scripts/mrm-validate.sh` (`make mrm`).
> **This is the TEMPLATE only — no per-model cards are fabricated.** Operator/CRO fills the
> AWAITS-OPERATOR fields; the factory does not invent thresholds, classification, or backend choice.

---

## 1. Identity
- **Model / alias:** `<e.g. ai-heavy | llama3.3:70b>`
- **Role in canon:** `<e.g. Project Guardian backbone>`
- **MRM tier (inferred):** `<T1 | T2 | T3>` — per MRM §3.
- **Binding regulatory classification:** **AWAITS OPERATOR** (operator/CRO — MRM §3; the inferred tier is not a binding FCA/EBA classification).

## 2. Provenance
- **Source / weights:** `<e.g. ollama pull <name>; HW-matrix placement>`
- **Quantization:** `<e.g. Q3_K_S | q4_K_M>`
- **Host / route:** `<host per HW-matrix; LiteLLM alias — no direct model IDs in caller config>`
- **Backend routing divergence (ai-heavy):** **AWAITS OPERATOR** (MRM — backend choice not asserted).

## 3. Intended use & boundaries
- **Intended use:** `<what regulated/utility task this model serves>`
- **Out of scope / non-goals:** `<decisions this model must NOT make autonomously>`
- **Human-in-the-loop:** `<HITL/MLRO gate per role; e.g. T1 → MLRO sign-off if compliance (P5 pack)>`

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Guardian (deterministic rules) + Canon Judge (ADR-025, **audit-only** today) — MRM §4/§5.
- **Eval results:** `<placeholder — attach eval/benchmark when run; e.g. fraud accuracy>` 
- **Known limitations:** `<placeholder — hallucination/calibration notes>`
- **Independent validation (SR 11-7 effective challenge):** **AWAITS OPERATOR** — blocking gate for T1 + independent validator ownership not assigned (MRM §5).

## 5. Lifecycle controls (map to existing mechanisms — MRM §4)
- **Deployment gate:** `<Auto-promote LOW | Operator gate MEDIUM>` — P4 Audit Pack + P5 Evidence Pack.
- **Monitoring:** LiteLLM request logging + immutable audit logs (INV-07, 5-year TTL, ClickHouse).
- **Monitoring thresholds (drift / hallucination / accuracy-decay / calibration):** **AWAITS OPERATOR** (MRM §6 — numeric thresholds are an operator/CRO decision; not inferred here).
- **Decommission:** `ollama rm` = destructive op → per-model operator confirmation (G-CLUSTER-03).

## 6. Provenance of this card
- **Author / date:** `<who / when>` · **Review cycle:** `<e.g. annually>` · **Owner:** `<CRO / role>`
- **Refs:** `docs/governance/MODEL-RISK-MANAGEMENT.md` (§3 tier, §4 lifecycle, §5 validation, §6 thresholds); `scripts/mrm-validate.sh`.
