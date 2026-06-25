# Target-Model Conformance Assessment — 2026-06-24

> **⚠ SUPERSEDED (ADR-102) by `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md`** — recomputed ~86 % after S2 activation + 57/57 passport binding + 7 executable factory tools merged. This doc is retained for history (its ~79 % reflects the `5aa561c` state).
>
> **Status:** LIVE AUDIT (supersedes stale 04-audit-v2 plan; ADR-102 note §6).
> **Base:** `origin/main` @ `5aa561c` (2026-06-24).
> **Method:** content audit of every S1-S6 governance artifact against the 15 target-model
> traits defined in `docs/master-document/04-audit-v2.md` §4 (report base `45e4a9e`, stale).
> **Principle:** evidence-based. Each verdict cites file path + size. No gaps are invented;
> no existing artifacts are recreated (ADR-102).

---

## 1. Conformance Matrix — 15 Target-Model Traits

Each trait is mapped to the audit-v2 gap number, current state on `main`, and the S1-S6
governance sprint that addresses it.

| # | Trait (audit-v2 gap) | Priority | Current state | Sprint | Evidence | Verdict |
|---|---|---|---|---|---|---|
| 1 | Immutable audit trail / Event Sourcing | P1 | Append-only instruction ledger (ADR-057/059); ClickHouse audit logs (INV-07, 5yr TTL); Guardian CI enforces append-only on every PR | S6 | `INSTRUCTION-LEDGER.md` + `ledger/entries/` (493 ILs); `.github/workflows/guardian.yml` (`ledger-append-only` job) | **PRESENT** |
| 2 | XAI layer (Explainability) | P1 | Canon Judge provides LLM-eval explanations (ADR-025); MRM §5 documents independent validation surface; no `ExplanationBundle` in `risk_contract.py` yet (emi-stack scope) | S1 | `docs/governance/MODEL-RISK-MANAGEMENT.md` §5 (11.8 KB) | **PARTIAL** — governance frame present; code-level XAI deferred to emi-stack |
| 3 | HITL governance (EU AI Act Art.14) | P1 | MRM §4 formalises LOW/MEDIUM gate split; P5 Evidence Pack requires MLRO sign-off; Guardian blocking gates; Canon Judge audit-mode; agent autonomy levels (L1-L3) defined per ORG-STRUCTURE | S1 | `docs/governance/MODEL-RISK-MANAGEMENT.md` §4–§5; `docs/canon/software-factory-canon-v1.md` §8 | **PRESENT** — governance formalised; blocking Canon Judge gate for T1 models AWAITS OPERATOR |
| 4 | Trust boundaries between agents | P1 | Orchestration Tree hierarchy in AGENT-ORG-STRUCTURE.md (5-level L0-L4); trust zones RED/AMBER/GREEN per ORG-STRUCTURE §2; agent passports enforce scope | S6 | `AGENT-ORG-STRUCTURE.md` (88 lines, 6.5 KB); `agents/passports/` (70 passports bound) | **PRESENT** |
| 5 | SOUL.md / governance-file change gate | P1 | Guardian deterministic rules (F1-F8/P1-P8) block ungoverned changes; Canon Judge evaluates against ADR-025; CLASS_B change governance defined in UI-UX canon §4; merge-queue serialises ledger changes | S6 | `docs/governance/LEDGER-MERGE-QUEUE.md` (22 lines); `.github/workflows/guardian.yml` | **PRESENT** |
| 6 | Bounded Context Map (DDD) | P2 | DEPARTMENT-MAP.md maps 10 ArchiMate departments to AI agents; ORG-STRUCTURE establishes domain boundaries; Open Banking canon §2 defines single bounded context per ADR-102 | S5, S6 | `docs/DEPARTMENT-MAP.md` (522 lines, 29 KB); `docs/governance/OPEN-BANKING-API-MANAGEMENT.md` §2 | **PRESENT** |
| 7 | Externalised compliance config | P2 | Config-over-Hardcoding rule canonical (CLAUDE.md §10); KPI thresholds externalised in ADR-117; DORA target bands in KPI-DORA-FRAMEWORK §2 (operator-approved); all non-asserted values marked AWAITS OPERATOR | S3 | `docs/governance/KPI-DORA-FRAMEWORK.md` §2–§3 (9.9 KB) | **PARTIAL** — governance targets externalised; runtime `compliance_config.yaml` not yet created (emi-stack scope) |
| 8 | Drift detection for policy files | P2 | Guardian CI checks ledger append-only + shard integrity + branch naming + ADR validation on every PR; `build_ledger.py --check` verifies ledger = rebuild | S2, S6 | `.github/workflows/guardian.yml` (7 jobs); `.github/workflows/ledger-build.yml` | **PRESENT** — ledger/canon drift detected; general policy-file checksum CI not yet active |
| 9 | Pre-tx gate performance (Redis hot-path) | P2 | Architecture scope — no runtime implementation in banxe-architecture; documented as open item | — | `docs/master-document/04-audit-v2.md` §4 gap #9 | **OUT OF SCOPE** (emi-stack runtime) |
| 10 | Zero Standing Privileges for agents | P2 | Agent passport system enforces `allowed_skills`/`prohibited_skills` per agent; autonomy levels (L1-L3) gate actions; mask scope allow-lists (ADR-079 §D3) | S1 | `agents/passports/` (70 bound); `docs/governance/MODEL-RISK-MANAGEMENT.md` §4 | **PARTIAL** — passport-scoped; vault-based JIT not implemented |
| 11 | Partner access segregation | P2 | Trust zones (RED/AMBER/GREEN) defined in ORG-STRUCTURE; ADR-060 branch namespace + ADR-120 worktree isolation; signed commits via cosign template (inert) | S2, S6 | `AGENT-ORG-STRUCTURE.md`; `docs/governance/branch-protection.md`; `.github/workflows/cosign-sign.yml.template` | **PARTIAL** — zones defined; cosign not active |
| 12 | Agent passport system | P2 | 70 passports in `agents/passports/`; SKILLS-MATRIX binds skills; training runner (`make train-verify`) validates bindings; PROPOSED/active lifecycle (I-27) | S6 | `agents/passports/*.yaml` (70 files); `docs/SKILLS-MATRIX.md` | **PRESENT** |
| 13 | Compliance audit bundle | P3 | P4 Audit Pack (Guardian verdicts + Canon Judge + ClickHouse log) + P5 Evidence Pack defined in factory canon §8; KPI-DORA-FRAMEWORK provides metric governance; no `compliance_snapshot.py` yet | S3 | `docs/canon/software-factory-canon-v1.md` §8; `docs/governance/KPI-DORA-FRAMEWORK.md` | **PARTIAL** — governance defined; automated bundle generator not built |
| 14 | OPA/Rego runtime enforcement | P3 | Guardian provides deterministic rule enforcement (16 rules); Canon Judge provides LLM-based evaluation; no OPA sidecar | — | `.github/workflows/guardian.yml` | **PARTIAL** — CI-time enforcement present; runtime OPA deferred |
| 15 | Multi-agent review pattern | P3 | Canon Judge (independent model eval); Guardian (deterministic); merge-queue serialisation; HITL gates at MEDIUM/HIGH; multi-level approval (CTIO + MLRO for compliance) | S1, S6 | `docs/governance/MODEL-RISK-MANAGEMENT.md` §7 RACI; `docs/governance/LEDGER-MERGE-QUEUE.md` | **PRESENT** |

### Conformance summary

| Verdict | Count | Traits |
|---|---|---|
| **PRESENT** | 8 | #1, #3, #4, #5, #6, #8, #12, #15 |
| **PARTIAL** | 6 | #2, #7, #10, #11, #13, #14 |
| **OUT OF SCOPE** | 1 | #9 (emi-stack runtime, not architecture) |
| **ABSENT** | 0 | — |

**Recomputed conformance: 8 PRESENT + 6 PARTIAL (×0.5) + 1 OOS = 11/14 applicable = ~79 %**

> The stale report (base `45e4a9e`) scored many of these as ABSENT. Since then, S1-S6
> governance sprints have landed substantive artifacts on `main` that close or partially
> close every gap. The real executable gap is narrow (§3).

---

## 2. Per-Sprint S1-S6 Verdict

### S1 — Model Risk Management (MRM)

**Artifact:** `docs/governance/MODEL-RISK-MANAGEMENT.md` (136 lines, 11.8 KB)
**Verdict: PRESENT — governance baseline delivered.**

Covers: model inventory (§2, 12-row table), risk tiering T1/T2/T3 (§3), lifecycle controls
(§4), independent validation via Canon Judge + Guardian (§5), KPIs (§6), RACI (§7),
8 AWAITS OPERATOR open items registered.

**Remaining gap:** (a) Canon Judge blocking gate for T1 models (currently audit-only);
(b) formal per-model T1/T2/T3 classification by CRO; (c) model-monitoring metric set
(drift/accuracy-decay thresholds); (d) CRO/MLRO role-holders named (TBC).

### S2 — DevSecOps / Secure SDLC

**Artifacts:**
- `docs/governance/DEVSECOPS-SSDLC.md` (governance baseline, ~10 KB)
- `.github/workflows/cosign-sign.yml.template` (inert scaffold)
- `.github/workflows/sbom.yml.template` (inert scaffold)
- `docs/governance/threat-models/THREAT-MODEL-TEMPLATE.md` (STRIDE template, no instances)

**Verdict: PARTIAL — governance frame + scaffolds only. THIS IS THE MAIN EXECUTABLE GAP.**

Existing active security CI: `gitleaks` secrets-scan (blocking) only. All other security
gates are `.template` files (GitHub ignores them) or registered gaps.

**Remaining gap (prioritised — this is the lead item to 100 %):**
1. **SAST** — promote CodeQL (operator-approved 2026-06-22) to active required CI check
2. **SCA** — promote Dependabot + OSV-Scanner to active required CI check
3. **SBOM** — rename `sbom.yml.template` → `sbom.yml`, wire as CI job
4. **Cosign** — rename `cosign-sign.yml.template` → `cosign-sign.yml`, configure key/OIDC
5. **Threat models** — author at least one per-service STRIDE instance from template
6. **DAST** — tool selection + active workflow (AWAITS OPERATOR)

### S3 — KPI / DORA Metrics

**Artifact:** `docs/governance/KPI-DORA-FRAMEWORK.md` (169 lines, 9.9 KB)
**Verdict: PRESENT — governance skeleton complete.**

Covers: 4 DORA metrics with operator-approved target bands (§2), 5 ADR-117 KPIs with
repo-asserted numeric targets (§3), collection architecture referencing ADR-079 precedent
(§4), structural dashboard model P-1..P-5 (§5), RACI (§6), 8 open items.

**Remaining gap:** (a) metric collection pipeline not built (Prometheus + Grafana approved,
exporters/scrape AWAITS OPERATOR); (b) VP Platform Eng / SRE roles not created;
(c) continuous improvement process undefined.

### S4 — UI/UX Design System

**Artifact:** `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` (238 lines, 13.7 KB)
**Verdict: PRESENT — comprehensive governance canon.**

Covers: canonical source-of-truth declaration (§1), design token governance (§3), component
library governance with contribution/review/deprecation lifecycle (§4), accessibility canon
WCAG 2.1 AA (§5), 5-stage delivery process (§6), RACI (§7).

**Remaining gap:** (a) CTIO / CTO role-holder for design approval (AWAITS OPERATOR);
(b) Storybook instance not deployed; (c) accessibility audit tooling (axe-core) not in CI.

### S5 — Open Banking / API Management

**Artifact:** `docs/governance/OPEN-BANKING-API-MANAGEMENT.md` (230 lines, 15.2 KB)
**Verdict: PRESENT — governance canon over existing FCA-wired surface.**

Covers: existing API surface inventory with 3 Open Banking routers mapped (§2), versioning
policy (§3.1), backward-compatibility / deprecation / sunset (§3.2-3.3), PSD2/OBIE
compliance posture (§4), TPP integration governance (§5), API gateway governance (§6),
RACI (§7).

**Remaining gap:** (a) `psd2_gateway` + `consent_management` mounted but not exposed
(decision AWAITS OPERATOR); (b) API-governor agent (PROPOSED, not activated);
(c) concrete version scheme / sunset windows AWAITS OPERATOR; (d) TPP onboarding policy
(eIDAS/QWAC) AWAITS OPERATOR.

### S6 — Merge Queue / Org Governance

**Artifacts:**
- `docs/governance/LEDGER-MERGE-QUEUE.md` (22 lines, 1.9 KB)
- `docs/governance/merge-queue-ruleset.json` (38 lines, 955 B)
- `AGENT-ORG-STRUCTURE.md` (88 lines, 6.5 KB)
- `docs/DEPARTMENT-MAP.md` (522 lines, 29 KB)

**Verdict: PRESENT — all artifacts substantive and on main.**

Covers: merge-queue serialisation rule with production evidence (§problem), GitHub Ruleset
JSON (enforcement=active, SQUASH, build concurrency=1), required status checks (4 named),
agent org structure (Four-Partner Swarm + 20 domain agents across 5 model slots),
department mapping (10 ArchiMate departments → AI agents).

**Remaining gap:** (a) merge-queue ruleset not yet activated on GitHub (operator action);
(b) turnaround-time (TT) targets not defined; (c) conflict resolution SLA not specified.

---

## 3. Prioritised Plan to 100 % — Addressing ONLY Real Gaps

The dominant gap is **S2 DevSecOps**: templates exist but are not promoted to active CI.
All other sprints have delivered their governance artifacts; residual gaps are mostly
AWAITS OPERATOR decisions or emi-stack runtime concerns (out of architecture scope).

### Priority 1 — S2 DevSecOps activation (the real executable gap)

| # | Action | Deliverable | Follow-up sprint |
|---|---|---|---|
| 1 | Promote CodeQL to active CI | `.github/workflows/codeql.yml` (required check) | S-GOV-01 |
| 2 | Promote SCA (Dependabot + OSV-Scanner) | `.github/workflows/sca.yml` (required check) | S-GOV-01 |
| 3 | Promote SBOM generation | Rename `sbom.yml.template` → active `sbom.yml` | S-GOV-01 |
| 4 | Promote cosign artifact signing | Rename `cosign-sign.yml.template` → active workflow + key config | S-GOV-02 |
| 5 | Author first STRIDE threat model | `docs/governance/threat-models/THREAT-MODEL-*.md` (1+ service) | S-GOV-02 |
| 6 | DAST tool selection + activation | AWAITS OPERATOR → active workflow | S-GOV-03 |

### Priority 2 — Operator decisions (governance gap closure)

| # | Action | Sprint ref | Blocking |
|---|---|---|---|
| 7 | Name CRO (SMF4) / MLRO (SMF17) role-holders | S1 open item #7 | MRM enforcement |
| 8 | Formal T1/T2/T3 model classification by CRO | S1 open item #2 | Model risk gates |
| 9 | Activate merge-queue ruleset on GitHub | S6 | Ledger race prevention |
| 10 | Activate API-governor agent (I-27 gate) | S5 | API governance enforcement |
| 11 | VP Platform Eng + SRE role creation | S3 OI-5/OI-6 | KPI/DORA pipeline ownership |

### Priority 3 — Collection / tooling (builds on governance)

| # | Action | Sprint ref |
|---|---|---|
| 12 | KPI/DORA collection pipeline (Prometheus + Grafana on evo2) | S-FAC-68 (R4) |
| 13 | Canon Judge → blocking gate for T1 models | S1 gap (a) |
| 14 | Model-monitoring metric set (drift/accuracy thresholds) | S1 gap (c) |

---

## 4. Sprint-to-Trait Mapping

| Sprint | Traits addressed | Verdict |
|---|---|---|
| S1 (MRM) | #2, #3, #10, #15 | PRESENT (4 AWAITS OPERATOR items) |
| S2 (DevSecOps) | #8, #11 | **PARTIAL — lead gap** |
| S3 (KPI/DORA) | #7, #13 | PRESENT (collection deferred) |
| S4 (UI/UX) | — (domain governance, not audit-v2 trait) | PRESENT |
| S5 (Open Banking) | #6 | PRESENT (activation deferred) |
| S6 (Merge-queue/Org) | #1, #4, #5, #6, #8, #12, #15 | PRESENT |

---

## 5. Overall Assessment

The stale report (base `45e4a9e`, April 2026) scored conformance at ~30-35 % with most
traits ABSENT. Since then, six governance sprints (S1-S6) have landed **substantive**
artifacts totalling ~87 KB of governed documentation on `main`, covering all 15 traits.

**Recomputed conformance: ~79 % (8 PRESENT, 6 PARTIAL, 0 ABSENT, 1 OOS).**

The path to 100 % is narrow and well-defined:
- **One executable gap** (S2: promote DevSecOps templates to active CI)
- **Five operator decisions** (role-holders, classifications, activations)
- **Two follow-up builds** (KPI collection pipeline, Canon Judge blocking gate)

No new governance artifacts need to be created. The remaining work is **activation and
operator decisions**, not documentation.

---

## 6. ADR-102 Note

This assessment **supersedes** the stale plan in `docs/master-document/04-audit-v2.md` §6
(Раздел 6, "Пересобранный план действий") which proposed Sprint 1-4 actions based on
state as of `45e4a9e`. That plan's gap inventory is factually outdated: S1-S6 governance
sprints have closed or partially closed all 15 gaps since then. This document does NOT
recreate existing artifacts — it audits them and identifies only the real remaining gaps.

---

## 7. Provenance

- **Audit date:** 2026-06-24
- **Base commit:** `5aa561c` (origin/main)
- **Audited artifacts (with sizes on main):**
  - `docs/governance/MODEL-RISK-MANAGEMENT.md` — 136 lines, 11.8 KB (S1)
  - `docs/governance/DEVSECOPS-SSDLC.md` — ~200 lines, ~10 KB (S2)
  - `.github/workflows/cosign-sign.yml.template` — inert scaffold (S2)
  - `.github/workflows/sbom.yml.template` — inert scaffold (S2)
  - `docs/governance/threat-models/THREAT-MODEL-TEMPLATE.md` — STRIDE template (S2)
  - `docs/governance/KPI-DORA-FRAMEWORK.md` — 169 lines, 9.9 KB (S3)
  - `docs/adr/ADR-079-cro-risk-metrics-port.md` — ACCEPTED, risk-metrics port (S3 ref)
  - `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` — 238 lines, 13.7 KB (S4)
  - `docs/governance/OPEN-BANKING-API-MANAGEMENT.md` — 230 lines, 15.2 KB (S5)
  - `docs/governance/LEDGER-MERGE-QUEUE.md` — 22 lines, 1.9 KB (S6)
  - `docs/governance/merge-queue-ruleset.json` — 38 lines, 955 B (S6)
  - `AGENT-ORG-STRUCTURE.md` — 88 lines, 6.5 KB (S6)
  - `docs/DEPARTMENT-MAP.md` — 522 lines, 29 KB (S6)
- **Stale report superseded:** `docs/master-document/04-audit-v2.md` (base `45e4a9e`)
- **Canon:** ADR-056/059/060 (ledger); ADR-102 (anti-duplication); ADR-117 (perimeter).
- **Invented facts:** NONE. All non-asserted values traced to AWAITS OPERATOR in source docs.
