# Model Card — llama3.3:70b  (DRAFT — pending operator/CRO approval)

> **DRAFT.** Verifiable fields are filled from the live ssh/ollama audit + `docs/canon/HW-MODEL-UPGRADE-matrix.md` + `docs/governance/MODEL-RISK-MANAGEMENT.md` §3. Operator/CRO fields are left **AWAITS OPERATOR** — no thresholds, classification, or backend are invented. Authored per `docs/governance/model-cards/TEMPLATE.md`; validated by `scripts/mrm-validate.sh` (`make mrm`).

---

## 1. Identity
- **Model / alias:** `llama3.3:70b` (LiteLLM alias `ai-heavy` — see `ai-heavy.md`)
- **Role in canon:** **Project Guardian backbone** — enforces 8 project rules (P1-P8) deterministically (`project_rules.py`, software-factory-canon §3.1/§4.1).
- **MRM tier (inferred):** **T1 — Regulated-critical** (MRM §3; inferred from role).
- **Binding regulatory classification:** **AWAITS OPERATOR** (operator/CRO + FCA/EBA; the inferred tier is not a binding classification — MRM §3).

## 2. Provenance
- **Source / weights:** `ollama` model `llama3.3:70b` (verified present via `ollama list` on evo1/evo2).
- **Size:** **42 GB** (HW-MODEL-UPGRADE-matrix.md).
- **Quantization:** **not asserted in repo** — HW-matrix states size only for this model (no Q-level row). AWAITS OPERATOR to record.
- **Host / route:** **evo2 primary, evo1 fallback** (HW-matrix: `llama3.3:70b | 42 GB | evo2 | evo1`). Accessed via LiteLLM alias `ai-heavy` — no direct model IDs in caller config.
- **Backend routing divergence (ai-heavy):** **AWAITS OPERATOR** — `ai-heavy` is documented as `llama3.3:70b` (ADR-043 / software-factory-canon §5) but as `qwen3.5:35b` in `docs/runbooks/factory-routing-map.md`; MRM does not pick a winner.

## 3. Intended use & boundaries
- **Intended use:** regulated-critical **Project Guardian** backbone — deterministic enforcement of project invariants on every PR (compliance/KYC/AML-adjacent project rules).
- **Out of scope / non-goals:** MUST NOT autonomously make or auto-execute a regulated customer decision; Guardian is deterministic rule enforcement, not an auto-approver.
- **Human-in-the-loop:** T1 → operator gate (MEDIUM) + **MLRO sign-off if compliance** (P5 Evidence Pack), per MRM §4 / software-factory-canon §8.

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Guardian (deterministic rules) + Canon Judge (ADR-025, **audit-only** today) — MRM §4/§5.
- **Eval results:** *placeholder — AWAITS OPERATOR* (no model-level benchmark asserted in repo for this model; attach when run).
- **Known limitations:** *placeholder — AWAITS OPERATOR* (hallucination/calibration profile not measured in repo).
- **Independent validation (SR 11-7 effective challenge):** **AWAITS OPERATOR** — blocking gate for T1 + independent-validator owner not assigned (MRM §5).

## 5. Lifecycle controls (existing mechanisms — MRM §4)
- **Deployment gate:** **Operator gate (MEDIUM)** for a T1 model — P4 Audit Pack + P5 Evidence Pack.
- **Monitoring:** LiteLLM request logging + immutable audit logs (INV-07: 5-year TTL, ClickHouse).
- **Monitoring thresholds (drift / hallucination / accuracy-decay / calibration):** **AWAITS OPERATOR** (MRM §6 — numeric thresholds are an operator/CRO decision).
- **Decommission:** `ollama rm` = destructive op → **per-model operator confirmation** (G-CLUSTER-03; HW-matrix §3.2).

## 6. Provenance of this card
- **Author / date:** Factory (S-MRM T1 cards) / 2026-06-26 — **DRAFT**. · **Review cycle:** annually *(proposed)*. · **Owner:** **CRO — AWAITS OPERATOR** (role-holder not named).
- **Refs:** `docs/governance/MODEL-RISK-MANAGEMENT.md` (§3 tier, §4 lifecycle, §5 validation, §6 thresholds); `docs/canon/HW-MODEL-UPGRADE-matrix.md` (size/placement); `docs/canon/software-factory-canon-v1.md` (Project Guardian); `scripts/mrm-validate.sh`.
