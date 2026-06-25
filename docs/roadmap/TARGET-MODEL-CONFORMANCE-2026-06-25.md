# Target-Model Conformance Assessment — 2026-06-25

> **Status:** LIVE AUDIT (supersedes `TARGET-MODEL-CONFORMANCE-2026-06-24.md`; ADR-102 — the 06-24 doc is NOT deleted, it keeps a supersedes note).
> **Base:** `origin/main` @ `338f6e3` (2026-06-25).
> **Method (unchanged from 06-24 for comparability):** content + executable-tool audit of every S1-S6 artifact against the 15 target-model traits (`docs/master-document/04-audit-v2.md` §4). Conformance % = (PRESENT + 0.5×PARTIAL) / applicable-traits (14; #9 is OUT OF SCOPE).
> **Principle:** evidence-based; recomputed from the **current merged state**, not the old %. No artifacts recreated, no facts invented; operator-gated gaps stay operator-gated.

---

## 1. What changed since 2026-06-24 (merged on `main`)

Seven executable factory tools + the S2 activation + full passport binding landed since the 06-24 base (`5aa561c`):

| Capability | Merged PR | Evidence (script + make target) |
|---|---|---|
| S2 DevSecOps **active** CI (CodeQL/OSV/SBOM/Cosign) | #746 | `.github/workflows/{codeql,osv-scanner,sbom,cosign-sign}.yml` (no `.template` remain) |
| Full passport skill-binding **57/57**, `train-verify` exit 0 | #765/#767/#771 | `agents/passports/*.yaml`; `make train-verify` |
| Factory status report (A–G) | #760 | `scripts/factory-report.sh` · `make report` |
| Skills-binding audit | #762 | `scripts/skills-bind-audit.sh` · `make skills-audit` |
| DORA collector (repo-derived) | #773 | `scripts/dora-collect.sh` · `make dora` |
| MRM validator + card template | #775 | `scripts/mrm-validate.sh` · `make mrm` |
| Quality gate (computable KPI-3) | #776 | `scripts/quality-gate.sh` · `make quality` |
| UI/UX pipeline validator | #777 | `scripts/uiux-pipeline.sh` · `make uiux` |
| AgentOps/LLMOps aggregator | #778 | `scripts/agentops-eval.sh` · `make agentops` |

Live tool readings @ `338f6e3`: skills **57 bound / 0 unbound**; quality-gate **🟢 (security 4/4)**; agentops **🟢 (Guardian pass)**; uiux **🟢 (5/5 stages)**; mrm **🔴 (T1 cards 0/3 — operator-gated)**; dora 7-day **🟢** (repo-derived proxy).

---

## 2. Conformance Matrix — 15 Target-Model Traits (RECOMPUTED)

| # | Trait | Prev (06-24) | **Now (06-25)** | New evidence |
|---|---|---|---|---|
| 1 | Immutable audit trail / Event Sourcing | PRESENT | **PRESENT** | `ledger/` append-only + `guardian.yml`; unchanged |
| 2 | XAI layer (Explainability) | PARTIAL | **PARTIAL** | MRM validator (`make mrm`) + agentops Canon-Judge status (`make agentops`) — governance executable; model-level `ExplanationBundle` still emi-stack |
| 3 | HITL governance (EU AI Act Art.14) | PRESENT | **PRESENT** | `make agentops` reports Canon-Judge audit-mode + Guardian gates; unchanged (blocking T1 gate AWAITS OPERATOR) |
| 4 | Trust boundaries between agents | PRESENT | **PRESENT** | `AGENT-ORG-STRUCTURE.md` + 57/57 bound passports |
| 5 | SOUL.md / governance-file change gate | PRESENT | **PRESENT** | Guardian + merge-queue ruleset (activation operator-gated) |
| 6 | Bounded Context Map (DDD) | PRESENT | **PRESENT** | `DEPARTMENT-MAP.md`; unchanged |
| 7 | Externalised compliance config | PARTIAL | **PARTIAL** | KPI/DORA targets externalised + read by `dora-collect.sh`/`quality-gate.sh`; runtime `compliance_config.yaml` still emi-stack |
| 8 | Drift detection for policy files | PRESENT | **PRESENT** | Guardian + `quality-gate.sh` ledger-check (security 4/4) |
| 9 | Pre-tx gate performance (Redis hot-path) | OUT OF SCOPE | **OUT OF SCOPE** | emi-stack runtime |
| 10 | Zero Standing Privileges for agents | PARTIAL | **PARTIAL** | passport `allowed_skills`/`prohibited_skills` now **57/57 bound** (ARP prohibited on compliance/AML); vault-based JIT still not implemented |
| 11 | Partner access segregation | PARTIAL | **PRESENT ⬆** | **`cosign-sign.yml` now ACTIVE** (#746) — the cited gap closed; + trust zones + ADR-060/120/121 isolation. (Promote-to-required = operator.) |
| 12 | Agent passport system | PRESENT | **PRESENT** | 57/57 bound; `train-verify` exit 0; `make skills-audit` unbound=0 |
| 13 | Compliance audit bundle | PARTIAL | **PRESENT ⬆** | **automated machine-readable bundles now generated** — `factory-report.sh --json` (A–G) + `quality-gate.sh --json` + `agentops-eval.sh --json` + `dora-collect.sh --json` + `mrm-validate.sh --json`. (Full P4/P5 ClickHouse persistence still emi-stack.) |
| 14 | OPA/Rego runtime enforcement | PARTIAL | **PARTIAL** | CI-time Guardian + new validators; runtime OPA sidecar still deferred |
| 15 | Multi-agent review pattern | PRESENT | **PRESENT** | Canon Judge + Guardian + merge-queue; `make agentops` aggregates |

### Conformance summary

| Verdict | Prev (06-24) | **Now (06-25)** | Traits now |
|---|---|---|---|
| **PRESENT** | 8 | **10 ⬆** | #1, #3, #4, #5, #6, #8, #11, #12, #13, #15 |
| **PARTIAL** | 6 | **4 ⬇** | #2, #7, #10, #14 |
| **OUT OF SCOPE** | 1 | 1 | #9 |
| **ABSENT** | 0 | 0 | — |

**RECOMPUTED CONFORMANCE: (10 PRESENT + 0.5×4 PARTIAL) / 14 applicable = 12/14 ≈ 86 %** (was 11/14 ≈ 79 % on 06-24; **Δ +7 pp**).

---

## 3. Per-trait deltas (PARTIAL → PRESENT)

- **#11 Partner access segregation — PARTIAL → PRESENT.** 06-24 gap was *"cosign not active"* (template). #746 promoted `cosign-sign.yml.template` → active `cosign-sign.yml` (keyless/OIDC; advisory). Combined with RED/AMBER/GREEN trust zones + ADR-060 branch namespace + ADR-120/121 worktree/destructive-action isolation, the segregation+signing surface is now executable. **Residual (operator):** mark the signing check *required* in branch protection.
- **#13 Compliance audit bundle — PARTIAL → PRESENT.** 06-24 gap was *"automated bundle generator not built"*. Five tools now emit machine-readable audit/status bundles on demand (`make report/quality/agentops/dora/mrm` with `--json`), covering factory health, KPI-3 gates, AgentOps controls, DORA proxies, and MRM coverage. **Residual (operator):** wire `--json` outputs into the P4/P5 ClickHouse evidence store (emi-stack).
- **Strengthened but still PARTIAL (honest):** #10 (passports now 57/57 bound incl. prohibited ARP — but vault-based JIT runtime absent); #2 (MRM/agentops give executable governance for XAI — but model-level explanations are emi-stack); #7 (targets externalised + consumed by tools — but runtime compliance_config.yaml is emi-stack); #14 (more CI-time enforcement — but no runtime OPA sidecar).

---

## 4. Residual gaps — ALL OPERATOR-GATED (exact action per item)

| # | Residual gap | Trait/Sprint | OPERATOR-GATED action |
|---|---|---|---|
| 1 | Per-model cards absent (MRM T1 🔴 0/3) | #2 / S1 | Author 13 model cards from `docs/governance/model-cards/TEMPLATE.md` (T1 first → `make mrm` T1 🔴→🟢) |
| 2 | evo2 Prometheus/Grafana DORA pipeline | #7,#13 / S3,S-FAC-68 | Stand up Prometheus+Grafana on evo2 for live DORA (repo proxy = `make dora` until then) |
| 3 | Merge-queue ruleset not activated | #5 / S6 | Activate `docs/governance/merge-queue-ruleset.json` on GitHub (+ mark security checks required) |
| 4 | Numeric monitoring thresholds | #2,#14 / S1 §6 | CRO sets drift/hallucination/accuracy-decay thresholds → enables Canon-Judge blocking T1 gate |
| 5 | banxe-ui CI (Storybook/design-tokens/axe-core) | #14 / S4 | Wire banxe-ui CI for the UIUX stage-3/4/5 machine checks (`make uiux` validates governance side) |
| 6 | Role appointments | multiple / S1,S3,S4,S5,S6 | Name CRO (SMF4)/MLRO (SMF17), VP Platform Eng/SRE, Head of Design/Design-System-Lead |
| 7 | Passport activation (I-27) | #10,#12 | Per-agent operator activation gate (passports remain PROPOSED/bound, not activated) |
| 8 | Runtime ZSP (vault JIT) + runtime OPA + emi-stack XAI/config | #2,#7,#10,#14 | emi-stack runtime builds (out of architecture-repo scope) |

The 7 factory tools cover the **computable** governance surface; every item above is an operator decision, an evo2/banxe-ui build, or emi-stack runtime — none is a missing governance artifact in this repo.

---

## 5. Factory tools cross-reference

| make target | Script | Conformance traits it evidences |
|---|---|---|
| `make report` | `scripts/factory-report.sh` | #1,#4,#12 (factory health, agents, ledger) |
| `make skills-audit` | `scripts/skills-bind-audit.sh` | #10,#12 (passport binding coverage) |
| `make dora` | `scripts/dora-collect.sh` | #7,#13 (DORA metrics, repo-derived) |
| `make mrm` | `scripts/mrm-validate.sh` | #2 (model-card hygiene/XAI governance) |
| `make quality` | `scripts/quality-gate.sh` | #8 (KPI-3 0 blocker/critical; security 4/4) |
| `make uiux` | `scripts/uiux-pipeline.sh` | S4 governance (UI/UX process) |
| `make agentops` | `scripts/agentops-eval.sh` | #3,#15 (Guardian/Canon-Judge/HITL/eval) |

---

## 6. ADR-102 Note

This assessment **supersedes** `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-24.md` (which itself superseded the stale `04-audit-v2.md`). The 06-24 doc is **retained** with a supersedes pointer (not deleted). No governance artifact or tool is recreated here — this is a read-only re-audit that recomputes conformance from the current merged state and cross-references the already-merged tools.

---

## 7. Provenance

- **Audit date:** 2026-06-25 · **Base commit:** `338f6e3` (origin/main).
- **New evidence (merged since 06-24):** PRs #746, #760, #762, #765, #767, #771, #773, #775, #776, #777, #778; scripts `scripts/{factory-report,skills-bind-audit,dora-collect,mrm-validate,quality-gate,uiux-pipeline,agentops-eval}.sh`; `.github/workflows/{codeql,osv-scanner,sbom,cosign-sign}.yml` (active).
- **Recomputed conformance:** **12/14 ≈ 86 %** (10 PRESENT, 4 PARTIAL, 0 ABSENT, 1 OOS) — Δ +7 pp vs 06-24.
- **Superseded:** `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-24.md`.
- **Canon:** ADR-056/059/060 (ledger); ADR-102 (anti-duplication/supersede); ADR-117 (perimeter); ADR-120/121 (isolation).
- **Invented facts:** NONE. Every residual gap is OPERATOR-GATED, evo2/banxe-ui build, or emi-stack runtime.
