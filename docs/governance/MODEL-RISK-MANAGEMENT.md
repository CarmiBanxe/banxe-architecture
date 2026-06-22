# Model Risk Management (MRM) Framework — Banxe EMI AI Bank

**Status:** S1 baseline (2026-06-22) · **Owner role:** CRO (SMF4) · **Co-owners:** CTIO, MLRO (SMF17)
**Alignment:** SR 11-7 (Fed/OCC model-risk principles) and EBA model-risk guidance — *structure only*. Every factual cell below is grounded in an existing repo doc; anything not asserted by repo canon is explicitly marked **AWAITS OPERATOR** (no facts invented).

> **Reading rule.** This document is a *governance frame over existing canon*, not a new source of truth. Model sizes, placement, routes, gates, and KPIs live in the cited source docs (see Provenance footer). Where this frame names a control, the cited file is authoritative.

---

## 1. Purpose & Scope

Banxe operates as an FCA-regulated EMI AI bank in which LLM/agent models participate in regulated workflows (compliance, KYC, AML, fraud, reasoning) and in software delivery (coding/utility). This framework establishes how those models are inventoried, risk-tiered, validated, deployed, monitored, and retired.

**In-scope models:** all inference models served on the Project cluster (evo1/evo2) and the factory model on Legion — see §2.

**Perimeter (regulated compute).** All AI inference for regulated workloads MUST run **on-prem** on the Project cluster evo1/evo2 (128 GB each); no customer/regulated data leaves that perimeter, and **FCA DORA data-residency** is satisfied by it. Legion (Factory) handles software-delivery orchestration only — **no project/customer data on Legion**.
*Source:* `docs/DEPLOYMENT-ARCHITECTURE.md` §1.1, §1; `docs/compliance/ai-data-flow.md` §"Hard rule" (UK GDPR Art. 46; FCA PS25/12); `docs/canon/software-factory-canon-v1.md` (“No cloud LLM calls are permitted … All inference runs on the local cluster (evo1, evo2)”).

> **AWAITS OPERATOR — ADR cross-reference.** The on-prem / no-cloud rule is referenced in canon as “ADR-031”, but no `ADR-031` file resolves in the repo (the *AI Execution Policy* is `docs/adr/ADR-040-ai-execution-policy.md`; `ADR-043` frontmatter still points at the legacy `ADR-031/032/033` numbers). The **rule is in force** (asserted by the two compliance/canon docs above); only the ADR identifier needs operator reconciliation.

---

## 2. Model Inventory

Sizes and node placement are **not duplicated here** — single source of truth is `docs/canon/HW-MODEL-UPGRADE-matrix.md`. This section records only the **model → role** mapping needed for risk tiering.

| Model (id) | Primary node | Role / route (as asserted in canon) | Source |
|---|---|---|---|
| qwen3:4b | evo1 | tools / autocomplete (utility) | HW-matrix |
| qwen3.5:latest (9.7B) | evo1 | embedding / quick reasoning (utility) | HW-matrix |
| gpt-oss-derestricted:20b | evo1 | text generation (utility) | HW-matrix |
| qwen3:30b-a3b (MoE) | evo2 | `factory-mid` / `project-mid` — refactor, spec writing | HW-matrix; factory-routing-map |
| huihui_ai/glm-4.7-flash | evo2 | `fast` route; canon-judge backend | HW-matrix; factory-routing-map |
| **qwen3.5:35b** | evo2 | **`ai` route — Factory Guardian backbone; Canon Judge (qwen3.5:35b)** | software-factory-canon §3.1/§5; ADR-043 |
| **llama3.3:70b** | evo2 | **`ai-heavy` — Project Guardian backbone; heavy code-gen** | software-factory-canon §3.1; ADR-043 |
| qwen3-coder-next:q4_K_M | evo2 | `factory-coder` — code-tuned heavy work | HW-matrix; factory-routing-map |
| **qwen3:235b-a22b (Q3_K_S)** | evo2 ONLY | **`reasoning` / `project-reason` — ADR drafting, dense compliance reasoning** (canonical max) | ADR-043; HW-matrix; factory-routing-map |
| qwen3:235b-a22b-banxe | evo2 ONLY | fine-tuned variant of the above | HW-matrix |
| qwen3-banxe-v2 | evo1 | banxe-supervisor (AI-gateway on evo1) | DEPLOYMENT-ARCHITECTURE §1.1 |
| qwen2.5-coder:14b-banxe-factory | Legion | `factory-fast` — autocomplete/lint (Factory only) | DEPLOYMENT-ARCHITECTURE §1; factory-routing-map |

> **AWAITS OPERATOR — route/backend divergence.** `ai-heavy` is documented as `llama3.3:70b` (ADR-043, software-factory-canon §5) but as `qwen3.5:35b` in `docs/runbooks/factory-routing-map.md`. MRM does not pick a winner — operator/CTIO to reconcile the routing canon. The MRM tier (below) is assigned to the **role**, so it holds regardless of the final backend.

---

## 3. Risk Tiering

Tiers are **inferred from the role each model already plays** in repo canon. Regulatory-criticality calls that depend on operator policy are marked AWAITS OPERATOR rather than asserted.

| Tier | Definition (inferred) | Models / roles | Basis |
|---|---|---|---|
| **T1 — Regulated-critical** | Output can affect a regulated decision (compliance/KYC/AML/fraud) or enforces project invariants | Project Guardian backbone (`ai-heavy`/llama3.3:70b); Canon Judge & Factory Guardian (qwen3.5:35b); any model on the `/compliance//kyc//aml/` evo1 route; fraud classifier on evo2 | software-factory-canon §3.1; ai-data-flow §"PII/KYC/AML routing"; DEPLOYMENT-ARCHITECTURE §1.1 (evo2 “fraud classifier”) |
| **T2 — Reasoning / advisory** | Long-form planning, ADR drafting, dense compliance reasoning (human-reviewed, not auto-executing) | `reasoning`/`project-reason` (qwen3:235b-a22b); `factory-mid`/`factory-heavy` | ADR-043; factory-routing-map |
| **T3 — Utility / coding** | Software-delivery and utility; no regulated decision authority | factory-fast (14b), qwen3-coder-next, qwen3:4b, qwen3.5:latest, gpt-oss:20b | factory-routing-map; HW-matrix |

> **AWAITS OPERATOR — formal regulatory-criticality classification.** The mapping above is *inferred* from current roles. A binding T1/T2/T3 classification per model (and the threshold that makes a model "regulated-critical" under FCA/EBA) is an operator/CRO decision and is not asserted by any repo doc today.

---

## 4. Lifecycle Controls

Mapped to mechanisms that **already exist** in canon; no new tooling is asserted.

| Phase | Control (existing mechanism) | Source |
|---|---|---|
| **Development** | Models pulled/placed per HW-matrix; on-prem only; route aliases via LiteLLM (no direct model IDs in caller config) | HW-matrix; ADR-043 §Verification |
| **Validation** | **Guardian** — 16 deterministic rules (8 factory F1–F8 + 8 project P1–P8). **Canon Judge** — LLM evaluation against ADR-025, **audit mode = log only, no block** | software-factory-canon §3.1, §6, §"Canon Judge" |
| **Deployment gates** | **Auto-promote (LOW)**: all Guardian PASS + tests PASS + no compliance-sensitive files + Canon Judge PASS/WARN. **Operator gate (MEDIUM)**: any Guardian WARN, destructive ops, or P0 deprioritisation. Promotion artefacts: **P4 Audit Pack** (Guardian verdicts + Canon Judge + ClickHouse log) and **P5 Evidence Pack** (PR link + operator sign-off + **MLRO sign-off if compliance** + rollback plan) | software-factory-canon §8.1–8.2, §"P4/P5" |
| **Monitoring** | LiteLLM request logging; immutable audit logs (INV-07: 5-year TTL, ClickHouse) | software-factory-canon INV-07; ai-data-flow §"logging" |
| **Decommission** | Model removal (`ollama rm`) is a destructive op requiring **per-model operator confirmation** (deferred to G-CLUSTER-03); not blanket-admin | HW-matrix §"Execution"/§3.2 |

---

## 5. Independent Validation & Challenge

- Today's independent-evaluation surface is **Canon Judge** (separate model qwen3.5:35b, separate from the agent under review), evaluating against ADR-025. It currently runs in **audit mode (log only, no block)**. *Source:* software-factory-canon §3.1, §6.
- Guardian provides deterministic, model-independent rule enforcement (factory_rules.py / project_rules.py). *Source:* software-factory-canon §3.1.

> **AWAITS OPERATOR — independent validation gaps.** (a) Canon Judge is *audit-only* — whether a **blocking** independent-validation gate is required for T1 models is an operator/CRO decision. (b) **Independent validator ownership** (a human/role independent of model development, per SR 11-7 effective challenge) is not assigned in any repo doc. (c) Periodic revalidation cadence is undefined.

---

## 6. KPIs / Thresholds

**Reused verbatim from ADR-117 (via `docs/governance/CANON-RECONCILIATION-ADR117.md`):**
coverage ≥ 85% · tech-debt < 5% · 0 blocker/critical on merge · security-hotspot ≥ 95% · MTTD < 24h.

**Model-specific metrics already implied by repo canon (CRO role, `docs/JOB-DESCRIPTIONS.md`):**
- Model accuracy **> 95%** on fraud detection.
- HITL override quality **< 5%** error rate on CRO decisions.

> **AWAITS OPERATOR — model-monitoring metric set.** Drift, hallucination/accuracy-decay, calibration, and per-tier performance thresholds for T1 reasoning/compliance models are **not** defined in repo canon and must be set by the operator/CRO. Do not infer numeric thresholds.

---

## 7. Roles & RACI

Roles below already exist in `docs/JOB-DESCRIPTIONS.md`; **holders are TBC** in that doc (marked AWAITS OPERATOR here).

| Activity | Responsible | Accountable | Consulted | Informed | Source |
|---|---|---|---|---|---|
| AI model risk assessment **before production deployment** | CRO (SMF4) | CRO | CTIO | MLRO | JOB-DESCRIPTIONS §1.3 (CRO duties) |
| AI model **update approval** | CTIO (with CRO) | CTIO | CRO | — | JOB-DESCRIPTIONS §"CTIO" ("AI model update approval (with CRO)") |
| Production **deployment approval** | CTIO | CTIO | CRO | Operator | JOB-DESCRIPTIONS §"CTIO" |
| Compliance sign-off on compliance-touching model changes (P5) | MLRO (SMF17) | MLRO | CRO | CEO | software-factory-canon §"P5"; JOB-DESCRIPTIONS §1.2 |

> **AWAITS OPERATOR.** (a) CRO (SMF4) and MLRO (SMF17) **holders are "TBC"** in JOB-DESCRIPTIONS — to be named by the operator. (b) **Doubled-dev composition** (the AI developer headcount/mix) remains AWAITS OPERATOR, consistent with the ADR-117 canon-reconciliation **Q6** open item — not asserted by any repo doc.

---

## 8. Open Items Register (AWAITS OPERATOR)

1. **ADR-031 identifier** — reconcile the canon references ("ADR-031") to the actual on-prem/AI-execution ADR file(s) (§1).
2. **Binding model risk classification** — formal per-model T1/T2/T3 and the FCA/EBA criticality threshold (§3).
3. **Route/backend divergence** — `ai-heavy` backend (llama3.3:70b vs qwen3.5:35b) (§2).
4. **Blocking independent-validation gate** for T1 models (Canon Judge is audit-only today) (§5).
5. **Independent validator ownership** + revalidation cadence (§5).
6. **Model-monitoring metric set & thresholds** (drift/accuracy-decay/calibration) (§6).
7. **CRO (SMF4) / MLRO (SMF17) holders** — currently TBC (§7).
8. **Doubled-dev composition** — consistent with ADR-117 Q6 (§7).

---

## 9. Provenance footer (source docs cited)

- `docs/canon/HW-MODEL-UPGRADE-matrix.md` — model inventory, sizes, evo1/evo2 placement (source of truth for sizes).
- `docs/adr/ADR-043-aider-routes.md` — `ai` / `ai-heavy` / `reasoning` route aliases; on-prem no-cloud-degradation rule.
- `docs/runbooks/factory-routing-map.md` — canonical LiteLLM :4000 alias→model→backend map.
- `docs/canon/software-factory-canon-v1.md` — Guardian (16 rules), Canon Judge (ADR-025, audit mode), promotion gates P4/P5, INV-07.
- `docs/DEPLOYMENT-ARCHITECTURE.md` — evo1/evo2 perimeter (128 GB each, node-per-service mode B), FCA DORA data-residency.
- `docs/compliance/ai-data-flow.md` — on-prem hard rule (UK GDPR Art. 46, FCA PS25/12), PII/KYC/AML routing, inference logging.
- `docs/governance/CANON-RECONCILIATION-ADR117.md` — the 5 reused KPIs; Q6 doubled-dev open item.
- `docs/JOB-DESCRIPTIONS.md` — CRO (SMF4) / CTIO / MLRO (SMF17) duties and model-related KPIs.

*No metrics, owners, dates, or thresholds beyond those asserted in the above sources are introduced. Unknowns are marked AWAITS OPERATOR.*
