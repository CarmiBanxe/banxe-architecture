# Model Card — ai-heavy  (LiteLLM alias · DRAFT — pending operator/CRO approval)

> **DRAFT.** `ai-heavy` is a **LiteLLM route alias**, not a distinct model. MRM §3 lists it as a T1 entry (`ai-heavy`/llama3.3:70b). This card documents the alias; the underlying weights' verifiable provenance is in the model card it resolves to. Operator/CRO fields = **AWAITS OPERATOR**. Per `docs/governance/model-cards/TEMPLATE.md`; validated by `make mrm`.

---

## 1. Identity
- **Model / alias:** `ai-heavy` (LiteLLM alias).
- **Role in canon:** ai-heavy / **Project Guardian backbone** (MRM §3 T1).
- **MRM tier (inferred):** **T1 — Regulated-critical** (MRM §3).
- **Binding regulatory classification:** **AWAITS OPERATOR** (MRM §3).

## 2. Provenance
- **Resolves to (backend):** **AWAITS OPERATOR — UNRECONCILED.** Documented as `llama3.3:70b` in ADR-043 / software-factory-canon §5 (see `llama3.3-70b.md`), but as `qwen3.5:35b` in `docs/runbooks/factory-routing-map.md` (see `qwen3.5-35b.md`). **Both candidate backends are really deployed** (ollama list, evo1/evo2); MRM does **not** pick a winner — operator/CTIO reconciles the routing canon.
- **Quantization / size / host:** inherit from the resolved backend card (`llama3.3-70b.md` 42 GB or `qwen3.5-35b.md` 23 GB) once the operator reconciles the alias.
- **Route discipline:** callers use the alias `ai-heavy` only — no direct model IDs in caller config (HW-matrix / LiteLLM canon).

## 3. Intended use & boundaries
- **Intended use:** regulated-critical guardian-class routing alias for the Project Guardian backbone.
- **Out of scope / non-goals:** MUST NOT autonomously make/auto-execute a regulated decision; alias must not be repointed without operator reconciliation (CLASS_B routing change).
- **Human-in-the-loop:** T1 → operator gate (MEDIUM) + MLRO sign-off if compliance (P5).

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Guardian + Canon Judge (audit-only) — MRM §4/§5; evaluated on the resolved backend.
- **Eval results:** see the resolved backend card once reconciled — *AWAITS OPERATOR*.
- **Known limitations:** alias→backend divergence is itself a model-risk item until reconciled (MRM §3 note).
- **Independent validation:** **AWAITS OPERATOR** (MRM §5).

## 5. Lifecycle controls (existing mechanisms — MRM §4)
- **Deployment gate:** Operator gate (MEDIUM) — T1.
- **Monitoring:** LiteLLM request logging + immutable audit logs (INV-07).
- **Monitoring thresholds:** **AWAITS OPERATOR** (MRM §6).
- **Decommission / repoint:** alias repoint = CLASS_B change → operator confirmation; backend `ollama rm` per-model operator confirm (G-CLUSTER-03).

## 6. Provenance of this card
- **Author / date:** Factory (S-MRM T1 cards) / 2026-06-26 — **DRAFT**. · **Review cycle:** annually *(proposed)*. · **Owner:** **CRO / CTIO — AWAITS OPERATOR** (alias-backend reconciliation owner).
- **Refs:** `docs/governance/MODEL-RISK-MANAGEMENT.md` §3 (ai-heavy/T1 + backend divergence note); `llama3.3-70b.md`, `qwen3.5-35b.md`; `docs/runbooks/factory-routing-map.md`; `docs/adr/ADR-043*`; `scripts/mrm-validate.sh`.
