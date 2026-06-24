# DevSecOps / Secure SDLC Framework — Banxe AI Bank

**Status:** GOVERNANCE BASELINE — ACTIVE (SAST/SCA/SBOM/signing wired as advisory CI; DAST/SLSA/threat-models/DORA still gap) · **Sprint:** S2 (DevSecOps/SSDLC)
**Driver:** §5.2 SSDLC target model (SAST/SCA/DAST, container signing, SLSA, threat modeling, DORA incident reporting; ISO 27001 / SOC 2 Type II / PCI DSS)
**Principle:** Operator = canon, supreme over docs. No facts are invented here. Every unasserted tool, owner, or threshold is marked **AWAITS OPERATOR**.

---

## 1. Purpose & scope

This document is the governance baseline for Secure Software Development Lifecycle (SSDLC) and DevSecOps controls across the Banxe factory and project perimeters. It:

1. Maps each SSDLC phase (Requirements → Design → Development → Test → Deploy → Production) to the security control that governs it.
2. Inventories the **existing** CI/CD enforcement (already present in `.github/workflows/`), without weakening or replacing it.
3. Registers the **gaps** against the §5.2 target model (SBOM, artifact signing, threat models) and assigns each a planned control + owner.
4. Defines the threat-modeling process (STRIDE) and the security KPIs (ADR-117, verbatim).
5. Records roles & RACI, citing existing org canon; unassigned roles are **AWAITS OPERATOR**.

**Scope boundary (perimeter canon):** Factory = Legion (software-delivery orchestration only; **no project/customer data**, ADR-117). Project services, AI models, and regulated data reside on the **Project cluster evo1/evo2** — the regulated compute perimeter that satisfies FCA DORA data-residency (`docs/DEPLOYMENT-ARCHITECTURE.md` §"Important", lines 37, 108, 296). All AI inference for regulated workloads MUST run on-prem (evo1/evo2) — hard rule, `docs/compliance/ai-data-flow.md` line 19 (UK GDPR Art. 46, FCA PS25/12). DevSecOps tooling MUST NOT route regulated data or inference off-perimeter.

**Current maturity:** PARTIAL → improving. CI exists (secrets-scan, ledger/append-only guardians, ADR validation, Mermaid/Markdown checks). As of this revision the following are **wired as active, ADVISORY (non-blocking) workflows** that run on every PR/push: **SAST** (CodeQL), **SCA** (OSV-Scanner), **SBOM** (CycloneDX via syft), and **artifact/container signing** (Cosign keyless/OIDC). Still **gap**: documented threat models, **DAST** (OWASP ZAP), **SLSA** provenance, DORA reporting workflow. This document **adds no required gate** — every new workflow is advisory; promotion to a *required* status check is operator-reserved (must prove green first) — see §3.6, §4, §9.

---

## 2. SSDLC phases → controls

| Phase | Objective | Existing control (asserted in repo) | Target-model control (§5.2) | Status |
|-------|-----------|--------------------------------------|------------------------------|--------|
| **Requirements** | Capture security/compliance requirements as governed instructions | Instruction-Ledger (ADR-056/059/060) append-only shards; IL lifecycle | Security requirements traceability; abuse cases | PARTIAL |
| **Design** | Threat-model before build; ADR-grade decisions | ADR process + ADR Validation job (`ci.yml › adr-validate`); Canon Judge (ADR-025, audit) | STRIDE threat modeling (per-service) | **GAP** — no threat models (§4, §6) |
| **Development** | Prevent secrets/insecure code entering history | Secrets Scan (`ci.yml › secrets-scan`, gitleaks); Guardian INV-05 "No secrets in commits" (factory-canon §INV-05); branch-naming gate (ADR-060) | SAST on every PR | **ACTIVE (advisory)** — CodeQL (`codeql.yml`), not yet required (§3.6) |
| **Test** | Verify code + dependencies before merge | `quality-gate.sh` (project canon); ledger rebuild check (`ledger-build.yml`) | SCA (dependency CVEs); DAST (runtime) | SCA **ACTIVE (advisory)** — OSV-Scanner (`osv-scanner.yml`); DAST (OWASP ZAP) **GAP** — AWAITS OPERATOR |
| **Deploy** | Produce + sign verifiable artifacts; provenance | Guardian deterministic gates (factory-canon §4.1); operator/MLRO sign-off gates (factory-canon §8) | SBOM (CycloneDX), artifact signing (Cosign), SLSA provenance | SBOM + signing **ACTIVE (advisory)** — `sbom.yml`, `cosign-sign.yml` (§3.6); SLSA provenance **GAP** |
| **Production** | Detect & report incidents within regulatory SLA | IncidentResponseAgent (ORG-STRUCTURE §2.7.4, L2); CEO notified ≤2h on CRITICAL (FCA SYSC 8.1) | DORA incident reporting; MTTD <24h KPI | PARTIAL — DORA reporting workflow AWAITS OPERATOR |

> Controls in the "Existing control" column are **not modified** by this document. Target-model controls are introduced as non-blocking scaffolds or registered gaps only.

---

## 3. Existing CI inventory (pointer — source of truth = `.github/workflows/`)

This is a read-only inventory; the workflows themselves remain the source of truth. **Nothing in S2 weakens, replaces, or adds a required gate to any job below.**

### 3.1 `ci.yml` — "CI — Architecture Docs"
| Job | Name | Tool / action | Blocking |
|-----|------|---------------|----------|
| `secrets-scan` | Secrets Scan | `gitleaks/gitleaks-action@v2` | yes |
| `mermaid-validate` | Mermaid Diagram Validation | `@mermaid-js/mermaid-cli` + `validate_mermaid.py` | yes |
| `link-check` | Markdown Link Check | internal link scan | non-blocking (by design) |
| `adr-validate` | ADR Validation | ADR sequence check over `decisions/` | yes |

### 3.2 `guardian.yml` — "guardian"
| Job | Enforces | Anchor |
|-----|----------|--------|
| `guardian-schemas` | S2 governance JSON-Schemas | IL-156 schemas / IL-164 gate (`schemas/validate_schemas.py`) |
| `guardian-factory` | Factory registry present (`agents/souls`, `agents/passports`, `.claude/agents`) | factory invariants |
| `guardian-project` | Project invariants (`README.md` present) | project invariants |
| `guardian-ledger` | Ledger-coupling gate (PR must add IL block or shard) | ADR-056 / ADR-060 |
| `ledger-append-only` | `INSTRUCTION-LEDGER.md` append-only immutability | ADR-057, I-28 |
| `guardian-ledger-shards` | Shards append-only + `build_ledger.py --check` | ADR-059 S3, I-28 |
| `guardian-branch-naming` | Branch namespace `agent/<actor>/<id>/<slug>` | ADR-060 |
| `guardian-adr117` | ADR-117 placeholder gate (`scripts/adr117-gate-check.sh`) | ADR-117 |

### 3.3 `ledger-build.yml` — "ledger-build"
Single job verifies `INSTRUCTION-LEDGER.md` is rebuildable from shards (`python ledger/build_ledger.py --check`) — ADR-059 S2.

### 3.4 `docs.yml` — "Deploy MkDocs to GitHub Pages"
`build` (`mkdocs build --strict`) + `deploy` to GitHub Pages on `docs/**` changes.

### 3.5 Canon gates beyond CI (factory canon)
`docs/canon/software-factory-canon-v1.md`: **Guardian** = deterministic enforcement of 8 factory + 8 project rules (§4.1); **Canon Judge** = LLM evaluation against ADR-025 in *audit* mode (log-only, no block, §4.1, §7). Human gates (§4.2, §8): auto (LOW), operator (MEDIUM), MLRO (HIGH); MLRO + CTIO currently interim (Moriel Carmi).

### 3.6 S2 DevSecOps scanners (NEW — ACTIVE, ADVISORY / non-blocking)

Wired on `pull_request` + `push` to `main` (+ `workflow_dispatch`). Each **runs and reports status but is NOT a required check** — promotion to *required* in branch protection is operator-reserved and only after the workflow proves green (§9). Action versions are pinned (Config-over-Hardcoding §10).

| Workflow | Control | Tool / action | Gap closed | Blocking |
|----------|---------|---------------|------------|----------|
| `codeql.yml` | SAST | `github/codeql-action@v3` (language: python) | G-S2-04 | advisory |
| `osv-scanner.yml` | SCA | `google/osv-scanner-action@v1.9.1` (recursive dep + fs) | G-S2-05 | advisory |
| `sbom.yml` | SBOM | `anchore/sbom-action@v0.17.8` → CycloneDX artifact | G-S2-01 | advisory |
| `cosign-sign.yml` | Artifact/container signing | `sigstore/cosign-installer@v3.7.0` (keyless/OIDC; real sign step operator-gated on `release` + `vars.COSIGN_SIGN_TARGET`) | G-S2-02 | advisory |

> CodeQL proving runs on GitHub-hosted `ubuntu-latest`; canon target runner is on-prem self-hosted (ADR-031) and is an operator switch on promotion (this repo carries no customer/regulated data — source-only SAST is in perimeter). Dependabot (the second half of the canon SCA control) is a GitHub repo-setting toggle, operator-reserved (§9 O-2).

---

## 4. GAPS register

Each gap is registered with a planned control and owner. Owners not asserted in repo canon = **AWAITS OPERATOR**. None of these gaps is closed by S2; S2 only lands inert scaffolds + this governance baseline.

| Gap | Current state | Planned control | Tooling | Scaffold landed (S2) | Owner |
|-----|---------------|-----------------|---------|----------------------|-------|
| **G-S2-01 SBOM** | **ACTIVE (advisory)** | Generate CycloneDX SBOM per build artifact | **syft → CycloneDX** | **ACTIVATED** → `.github/workflows/sbom.yml` (advisory, §3.6) | AWAITS OPERATOR (proposed owner: Head of Security Engineering; promote-to-required) |
| **G-S2-02 Artifact / container signing** | **ACTIVE (advisory)** | Sign release artifacts + container images | **Cosign** (keyless/OIDC) | **ACTIVATED** → `.github/workflows/cosign-sign.yml` (advisory; sign step operator-gated, §3.6) | AWAITS OPERATOR (key/identity policy + sign target, §9 O-5/O-7) |
| **G-S2-03 Threat models** | none documented | STRIDE threat model per service | STRIDE template | `docs/governance/threat-models/THREAT-MODEL-TEMPLATE.md` | AWAITS OPERATOR (per-service instances) |
| **G-S2-04 SAST** | **ACTIVE (advisory)** | Static analysis on every PR | **CodeQL** (GitHub-native; on-prem self-hosted runner = canon target, ADR-031) — RECONCILED 2026-06-22 (operator-approved via chat) | **ACTIVATED** → `.github/workflows/codeql.yml` (advisory, python; §3.6) | AWAITS OPERATOR (promote-to-required; self-hosted runner switch) |
| **G-S2-05 SCA** | **ACTIVE (advisory)** | Dependency CVE scanning | **Dependabot + OSV-Scanner** (in-perimeter, no external SaaS) — RECONCILED 2026-06-22 (operator-approved via chat) | **ACTIVATED** → `.github/workflows/osv-scanner.yml` (OSV half; Dependabot = repo-setting toggle, §3.6) | AWAITS OPERATOR (Dependabot enablement; promote-to-required) |
| **G-S2-06 DAST** | none asserted | Runtime/dynamic testing | **OWASP ZAP** (open-source, on-prem) — RECONCILED 2026-06-22 (operator-approved via chat) | — | AWAITS OPERATOR |
| **G-S2-07 Supply-chain (SLSA)** | none | Build provenance attestation | SLSA — **Level 2** (signed build provenance; path to L3 later) — RECONCILED 2026-06-22 (operator-approved via chat) | — | AWAITS OPERATOR |
| **G-S2-08 DORA incident reporting** | partial (CRITICAL→CEO ≤2h, SYSC 8.1) | Major-incident reporting workflow (DORA Art. 19) | AWAITS OPERATOR | — | CTO (SMF26) interim; dedicated owner AWAITS OPERATOR |

> **Note on asserted vs. unasserted tools.** `syft`/CycloneDX (SBOM) and `cosign` (signing) are named here because §5.2 target model names them and the S2 scaffolds use them; their **activation is now operator-approved (ACTIVATE) — RECONCILED 2026-06-22 (via chat)** — while physical scaffold go-live, the SBOM owner, and the cosign key/identity policy detail remain AWAITS OPERATOR. SAST = **CodeQL**, SCA = **Dependabot + OSV-Scanner**, DAST = **OWASP ZAP**, and SLSA target = **Level 2** are now **operator-approved — RECONCILED 2026-06-22 (via chat)**; no value beyond these operator-approved selections is invented.

### S2 controls — activation status

The SBOM and signing scaffolds have been **promoted from inert `.template` to active, advisory (non-blocking) workflows** (operator-approved ACTIVATE — RECONCILED 2026-06-22); SAST + SCA workflows are newly added (advisory). None is a required gate — promotion to *required* is operator-reserved (§3.6, §9).

- `.github/workflows/sbom.yml` — **ACTIVE (advisory)** — syft → CycloneDX SBOM artifact (was `sbom.yml.template`).
- `.github/workflows/cosign-sign.yml` — **ACTIVE (advisory)** — cosign keyless/OIDC signing; real sign step operator-gated on `release` + `vars.COSIGN_SIGN_TARGET` (key/identity policy AWAITS OPERATOR, §9 O-5/O-7) (was `cosign-sign.yml.template`).
- `.github/workflows/codeql.yml` — **ACTIVE (advisory)** — CodeQL SAST (python).
- `.github/workflows/osv-scanner.yml` — **ACTIVE (advisory)** — OSV-Scanner SCA (recursive dep + fs).
- `docs/governance/threat-models/THREAT-MODEL-TEMPLATE.md` — STRIDE template, still inert (per-service instances AWAITS OPERATOR).

---

## 5. Tooling stack (target)

| Control | Tool | Status |
|---------|------|--------|
| SBOM | **syft** → **CycloneDX** format | **ACTIVE (advisory)** — `sbom.yml` (§3.6); promote-to-required + owner AWAITS OPERATOR |
| Artifact / container signing | **Cosign** (keyless / OIDC) | **ACTIVE (advisory)** — `cosign-sign.yml` (§3.6); sign target + key/identity policy AWAITS OPERATOR (§9 O-5/O-7) |
| SAST | **CodeQL** (GitHub-native, on-prem self-hosted runner) | **ACTIVE (advisory)** — `codeql.yml` (§3.6); self-hosted-runner switch + promote-to-required AWAITS OPERATOR (ADR-031 on-prem) |
| SCA | **Dependabot + OSV-Scanner** (in-perimeter, no external SaaS) | **ACTIVE (advisory)** — `osv-scanner.yml` (OSV half, §3.6); Dependabot toggle AWAITS OPERATOR |
| DAST | **OWASP ZAP** (open-source, on-prem) | RECONCILED 2026-06-22 (operator-approved via chat); workflow AWAITS OPERATOR |
| Supply-chain provenance | **SLSA Level 2** (signed build provenance; path to L3 later) | RECONCILED 2026-06-22 (operator-approved via chat) |
| Threat modeling | **STRIDE** (template landed S2) | template landed; per-service instances AWAITS OPERATOR |
| Secrets scanning | **gitleaks** (already in `ci.yml`) | ACTIVE (existing) |

> Configuration-over-Hardcoding (CLAUDE.md §10): once activated, all tool versions, thresholds, and SLSA target level live in config files (workflow inputs / repo config), never hardcoded in this document.

---

## 6. Threat modeling process (STRIDE)

1. **Trigger.** A threat model is authored/updated in the **Design** phase for any new service, or any change to a trust boundary, data flow, or authentication path (per §2 Design row).
2. **Method.** STRIDE — Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege — applied to each element of the service's data-flow diagram.
3. **Template.** Use `docs/governance/threat-models/THREAT-MODEL-TEMPLATE.md`. One instance per service under `docs/governance/threat-models/<service>.md`.
4. **Perimeter assumptions (canon).** Models MUST reflect: regulated data stays on evo1/evo2 (on-prem inference hard rule, `ai-data-flow.md` line 19); no customer data on the factory (Legion); secrets only in `/data/banxe/.env` on evo1 (`DEPLOYMENT-ARCHITECTURE.md` line 296).
5. **Review.** Threat models for payment/compliance/kyc services are reviewed under the compliance chain (Ruflo mandatory middleware; `.claude/rules/agents.md`). Per-service authorship and sign-off owner = **AWAITS OPERATOR**.

---

## 7. Security KPIs (ADR-117, verbatim)

Recorded verbatim from `docs/governance/CANON-RECONCILIATION-ADR117.md`. Enforcement is a follow-up factory work item (not added as a blocking gate by S2):

1. **coverage ≥85%**
2. **tech-debt <5%**
3. **0 blocker/critical on merge**
4. **security-hotspot ≥95%**
5. **MTTD <24h**

---

## 8. Roles & RACI

Cited from `docs/JOB-DESCRIPTIONS.md` and `docs/ORG-STRUCTURE.md`. **No role appointment is invented.** A dedicated **CISO / Head of Security Engineering** human SMF holder is **NOT asserted** in current org canon — security ownership today sits with the **CTO (SMF26, Oleg @p314pm)** whose scope is "AI platform, infra, integrations, security/IAM" (ORG-STRUCTURE §2.7.4, lines 264–266). The label "CISO" appears in the repo only as the owner column of `WalletSecurityAgent` (#30, PROPOSED, L1; JOB-DESCRIPTIONS line 588) — not as an appointed human role.

| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|----------|
| SSDLC framework (this doc) | Factory (S2) | CTO (SMF26) | MLRO (SMF17) | CEO (SMF1) |
| SBOM / signing activation | AWAITS OPERATOR | CTO (SMF26) interim → dedicated **Head of Security Engineering AWAITS OPERATOR** | — | CEO |
| SAST / SCA / DAST tool selection | AWAITS OPERATOR | AWAITS OPERATOR | CTO (SMF26) | CEO |
| Threat models (per service) | AWAITS OPERATOR | CTO (SMF26) interim | Ruflo (compliance chain) | — |
| Security incident (CRITICAL) | IncidentResponseAgent (L2) | CTO + CEO | MLRO (if AML/CASS) | CEO ≤2h (FCA SYSC 8.1) |
| DORA incident reporting | AWAITS OPERATOR | CTO (SMF26) interim | MLRO | CEO |
| KPI enforcement (ADR-117) | AWAITS OPERATOR (follow-up factory item) | CTO (SMF26) | — | CEO |

> A dedicated **CISO** and/or **Head of Security Engineering** appointment is a governance decision for the operator (Developer Block v5.1 §30.N+1.8 / human-in-the-loop). Until appointed, security accountability is the CTO (SMF26) per existing org canon.

---

## 9. Open-items register (AWAITS OPERATOR)

| # | Item | Decision needed |
|---|------|-----------------|
| O-1 | SAST tool | Select tool + activation policy |
| O-2 | SCA tool | Select tool + CVE severity gating |
| O-3 | DAST tool | Select tool + target environments |
| O-4 | SLSA target level | Choose SLSA level (1–4) |
| O-5 | Cosign identity policy | Keyless/OIDC identity + verification policy |
| O-6 | SBOM activation | Promote `sbom.yml.template` → active workflow |
| O-7 | Cosign activation | Promote `cosign-sign.yml.template` → active workflow |
| O-8 | Threat-model instances | Author per-service STRIDE models + assign owners |
| O-9 | CISO / Head of Security Engineering | Appoint dedicated security owner (SMF mapping) |
| O-10 | DORA incident reporting workflow | Define major-incident reporting process (DORA Art. 19) |
| O-11 | KPI enforcement | Implement ADR-117 KPI gates (coverage/tech-debt/hotspot/MTTD) |
| O-12 | Compliance frameworks | Confirm ISO 27001 / SOC 2 Type II / PCI DSS control-mapping scope |

---

## 10. Provenance

- **Authored by:** Factory (S2 DevSecOps/SSDLC), branch `agent/factory/devsecops/s2-ssdlc-framework`.
- **Ledger:** IL shard `ledger/entries/agent-factory-devsecops-s2-ssdlc-framework/IL-2026-06-22T07-15-00Z--c692fa.md` (il_ts `2026-06-22T07:15:00Z`, append-only ADR-059-A).
- **Grounding sources (cited, not duplicated):** `.github/workflows/{ci,guardian,ledger-build,docs}.yml`; `docs/canon/software-factory-canon-v1.md` (Guardian/Canon Judge gates §4, §8); `docs/DEPLOYMENT-ARCHITECTURE.md` (perimeter §"Important", secrets line 296); `docs/compliance/ai-data-flow.md` (on-prem inference hard rule line 19); `docs/governance/CANON-RECONCILIATION-ADR117.md` (5 KPIs verbatim); `docs/JOB-DESCRIPTIONS.md` / `docs/ORG-STRUCTURE.md` (security ownership — CTO SMF26; CISO appointment AWAITS OPERATOR).
- **Canon:** Operator supreme over docs; no facts invented; unknowns = AWAITS OPERATOR. Existing guardians untouched.
- **Revision (S2 activation, branch `agent/factory/factory/s2-devsecops-activate`):** SBOM (`sbom.yml`) + signing (`cosign-sign.yml`) promoted from inert `.template` to active; SAST (`codeql.yml`, CodeQL) + SCA (`osv-scanner.yml`, OSV-Scanner) newly added. All four run on PR/push as **ADVISORY (non-blocking)** workflows — **NO required gate added**; promotion to *required* status checks is operator-reserved and only after each proves green (§3.6, §9). Tools/levels match the RECONCILED 2026-06-22 operator selections verbatim (no tool invented). DO NOT MERGE pending operator review.
