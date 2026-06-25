# Model Card — qwen3.5:35b  (DRAFT — pending operator/CRO approval)

> **DRAFT.** Verifiable fields from the live ssh/ollama audit + `docs/canon/HW-MODEL-UPGRADE-matrix.md` + `MODEL-RISK-MANAGEMENT.md` §3. Operator/CRO fields = **AWAITS OPERATOR**; nothing invented. Per `docs/governance/model-cards/TEMPLATE.md`; validated by `make mrm`.

---

## 1. Identity
- **Model / alias:** `qwen3.5:35b`
- **Role in canon:** **Canon Judge primary** (independent LLM eval vs ADR-025) **+ Factory Guardian** — enforces 8 factory rules (F1-F8) deterministically (`factory_rules.py`, software-factory-canon §3.1/§4.1, lines 69/71).
- **MRM tier (inferred):** **T1 — Regulated-critical** (MRM §3; enforces project invariants + independent validation surface).
- **Binding regulatory classification:** **AWAITS OPERATOR** (MRM §3).

## 2. Provenance
- **Source / weights:** `ollama` model `qwen3.5:35b` (verified present via `ollama list` on evo1/evo2).
- **Size:** **23 GB** (HW-MODEL-UPGRADE-matrix.md).
- **Quantization:** **not asserted in repo** — HW-matrix states size only for this model. AWAITS OPERATOR to record.
- **Host / route:** **evo2 primary, evo1 fallback** (HW-matrix: `qwen3.5:35b | 23 GB | evo2 | evo1 | canon-judge primary`).
- **Backend routing divergence (ai-heavy):** N/A directly — but note `factory-routing-map.md` maps `ai-heavy` to this model while ADR-043/canon §5 map it to llama3.3:70b (see `ai-heavy.md`); reconciliation AWAITS OPERATOR.

## 3. Intended use & boundaries
- **Intended use:** **independent validation** (Canon Judge, separate from the agent under review, per SR 11-7 effective-challenge surface, MRM §5) + deterministic factory-rule enforcement (Factory Guardian).
- **Out of scope / non-goals:** Canon Judge currently runs **audit mode (log-only, no block)** — it MUST NOT be treated as a blocking gate until the operator enables one (MRM §5); must not auto-execute regulated decisions.
- **Human-in-the-loop:** T1 → operator gate (MEDIUM) + MLRO sign-off if compliance (P5).

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Canon Judge (ADR-025) + Factory Guardian deterministic rules — MRM §4/§5.
- **Eval results:** **G-CANON-01 — 13/13 PASS** (Canon Judge acceptance, Week 2; cited in HW-MODEL-UPGRADE-matrix.md). This is the existing verifiable eval evidence for this model's Canon-Judge role.
- **Known limitations:** Canon Judge is audit-only today (no blocking enforcement); drift/calibration profile not measured in repo — *AWAITS OPERATOR*.
- **Independent validation (SR 11-7):** **AWAITS OPERATOR** — whether a blocking independent-validation gate is required for T1, and the independent-validator owner, are unassigned (MRM §5).

## 5. Lifecycle controls (existing mechanisms — MRM §4)
- **Deployment gate:** **Operator gate (MEDIUM)** for a T1 model — P4 Audit Pack + P5 Evidence Pack.
- **Monitoring:** LiteLLM request logging + immutable audit logs (INV-07: 5-year TTL, ClickHouse).
- **Monitoring thresholds (drift / hallucination / accuracy-decay / calibration):** **AWAITS OPERATOR** (MRM §6).
- **Decommission:** `ollama rm` = destructive op → **per-model operator confirmation** (G-CLUSTER-03; HW-matrix §3.2).

## 6. Provenance of this card
- **Author / date:** Factory (S-MRM T1 cards) / 2026-06-26 — **DRAFT**. · **Review cycle:** annually *(proposed)*. · **Owner:** **CRO — AWAITS OPERATOR**.
- **Refs:** `docs/governance/MODEL-RISK-MANAGEMENT.md` (§3-§6); `docs/canon/HW-MODEL-UPGRADE-matrix.md` (size/placement + G-CANON-01 13/13 PASS); `docs/canon/software-factory-canon-v1.md` (Canon Judge / Factory Guardian); `scripts/mrm-validate.sh`.
