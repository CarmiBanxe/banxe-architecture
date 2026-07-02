# Model Card — factory-fast (alias)  (DRAFT — pending operator/CRO approval)

> **DRAFT — pending operator/CRO approval.** Verifiable fields from the live ssh/ollama audit + `docs/canon/HW-MODEL-UPGRADE-matrix.md` + `docs/runbooks/factory-routing-map.md` + `MODEL-RISK-MANAGEMENT.md` §3. Operator/CRO fields left **AWAITS OPERATOR** — no model id, quant, threshold, classification, or backend invented. Per `docs/governance/model-cards/TEMPLATE.md`; validated by `make mrm`.


---


## 1. Identity
- **Model / alias:** `factory-fast (alias)`
- **Role in canon:** LiteLLM alias — autocomplete / lint / single-line edits.
- **MRM tier (inferred):** **T3 — Utility / coding (software-delivery & utility; NO regulated decision authority)** (MRM §3; inferred from role).
- **Binding regulatory classification:** **AWAITS OPERATOR** (operator/CRO; the inferred tier is not a binding FCA/EBA classification — MRM §3).

## 2. Provenance
- **Alias resolution:** **alias → `qwen2.5-coder:7b-instruct-q4_K_M`** — factory-fast → qwen2.5-coder:7b-instruct-q4_K_M, Legion :11434 (factory-routing-map, amendment 2026-07-03). *Prior target `qwen2.5-coder:14b-banxe-factory` (9 GB) was measured to not fit Legion's 8 GB VRAM — see COMPUTE-ROUTING-TAXONOMY §5.7-D. Weights remain on disk (historical / rollback) but no alias points at them.*
- **Source / weights:** the backing ollama model `qwen2.5-coder:7b-instruct-q4_K_M` (verified present via `ollama list`). Callers use the alias only — no direct model IDs in caller config.
- **Size:** not asserted (HW-matrix has no size row for the legion factory model) (HW-MODEL-UPGRADE-matrix.md).
- **Quantization:** not asserted in repo.
- **Host / route:** Legion :11434 (HW-matrix / factory-routing-map).
- **Backend routing divergence:** N/A unless reconciled by operator (see MRM §3 ai-heavy note for the one known divergence).

## 3. Intended use & boundaries
- **Intended use:** autocomplete, lint fixes, single-line edits, light ARP — utility, no regulated authority.
- **Out of scope / non-goals:** utility/coding only — NO regulated decision authority; MUST NOT score/decide compliance/KYC/AML/fraud.
- **Human-in-the-loop:** standard PR review (quality-gate.sh + Guardian); not a regulated-decision path.

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Guardian (deterministic rules) + Canon Judge (ADR-025, **audit-only** today) — MRM §4/§5.
- **Eval results:** placeholder — AWAITS OPERATOR.
- **Known limitations:** *placeholder — AWAITS OPERATOR* (drift/calibration not measured in repo).
- **Independent validation (SR 11-7):** **AWAITS OPERATOR** (MRM §5) — applies primarily to T1; recorded for completeness.

## 5. Lifecycle controls (existing mechanisms — MRM §4)
- **Deployment gate:** Auto-promote (LOW) for routine utility work — P4 Audit Pack + P5 Evidence Pack where applicable.
- **Monitoring:** LiteLLM request logging + immutable audit logs (INV-07: 5-year TTL, ClickHouse).
- **Monitoring thresholds (drift / hallucination / accuracy-decay / calibration):** **AWAITS OPERATOR** (MRM §6).
- **Decommission:** `ollama rm` = destructive op → **per-model operator confirmation** (G-CLUSTER-03; HW-matrix §3.2).

## 6. Provenance of this card
- **Author / date:** Factory (S-MRM T2/T3 cards) / 2026-06-26 — **DRAFT**. · **Review cycle:** annually *(proposed)*. · **Owner:** **CRO — AWAITS OPERATOR**.
- **Refs:** `docs/governance/MODEL-RISK-MANAGEMENT.md` (§3-§6); `docs/canon/HW-MODEL-UPGRADE-matrix.md` (size/placement/quant); `docs/runbooks/factory-routing-map.md` (alias→model); `scripts/mrm-validate.sh`.
