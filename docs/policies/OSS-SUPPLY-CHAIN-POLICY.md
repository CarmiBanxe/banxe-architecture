# OSS Supply-Chain & License Governance Policy (SP-26/27/28)
> Date 2026-06-19 | GAP-067 | complements ACCESS-AND-SECRETS.md (IL-AccessPolicy-01)

## 1. SBOM (SP-26)
- Software Bill of Materials generated per deploy (CycloneDX/SPDX). Tracks all OSS deps + transitive.
- Only 1 prior reference -> formalize as mandatory CI artifact.

## 2. SCA — Software Composition Analysis (SP-26)
- CVE scanning in CI/CD: Dependabot (enabled) + Grype/Trivy (add). Block high/critical on merge.
- Dependency pinning + SHA; no latest tags for prod.
- gitleaks already active (17 refs) for secrets — SCA extends to dependency CVEs.

## 3. OSS License Audit (SP-28)
- Full + transitive license scan. Risk tiers by license:
- AGPL v3 (Jube, Grafana, Metabase): self-hosted ONLY, no SaaS-to-user exposure of linked code; isolate.
- SSPL (ELK, MongoDB): prefer OpenSearch (Apache) over ELK; MongoDB SSPL reviewed for managed-service clause.
- BSL (Vault): non-production-compete use OK; review at scale.
- Fair-code (n8n): self-hosted OK; review commercial redistribution.
- Apache/MIT/BSD (Midaz/Formance/Watchman/Ballerine/most): safe.
- No-license utils: BANNED until clarified.

## 4. FCA Third-Party Register (SP-27)
- Each material OSS/vendor as third-party arrangement (EBA GL/2019/02 + DORA Register of Information).
- Per entry: BCP, annual due-diligence, exit/fork strategy, SLA (managed), audit right.
- Ties DORA (GAP-059), Paybis/Tompay (third-party providers).

## 5. Governance
- Owner: CTIO (technical) + Compliance (license/regulatory). Review quarterly.
- CI gate: SBOM + SCA + license-check mandatory before prod merge.

## 6. OWASP LLM Top-10 (2025) supply-chain mapping (ADOPT #64 — PROPOSED)

> Added 2026-07-09 per SP41 roadmap §4 cluster-1 (ADOPT #64 owasp-llm-top10-supply-chain,
> ESCALATE-IMMEDIATE, FCR 0.85; handoff **OD-LLM-SECURITY**). **Additive** per **ADR-102**:
> each OWASP LLM risk is mapped **pointer-first** to an **existing** BANXE control — no control is
> restated or rewritten here. §1–§5 above are unchanged. This extends the OSS supply-chain policy to
> the LLM-specific attack surface; the verifiable checklist lives in
> `governance/owasp-llm-top10-checklist.md`.

**Intake rule (proposed):** any OSS/LLM dependency or LLM-using capability MUST pass the OWASP-LLM
Top-10 checklist at intake (LLM03 *Supply Chain* is the direct extension of §1–§3 SBOM/SCA/license).
A **GAP** on any item blocks prod promotion and routes to **OD-LLM-SECURITY** for a mitigation IL.

| # | OWASP LLM risk | Mapped BANXE control (existing) | Enforcement status |
|---|----------------|---------------------------------|--------------------|
| LLM01 | Prompt Injection | Prompt-canon (`PROMPT-CANON-DEVELOPER/PROJECT.md`) | manual; runtime **pending #65/#104** |
| LLM02 | Sensitive Info Disclosure | Secrets governance (`ACCESS-AND-SECRETS.md`, gitleaks) + output validation **pending #104** | manual |
| LLM03 | **Supply Chain** | **This policy §1–§3** (SBOM/SCA/license/third-party register) | CI gate active (§5) |
| LLM04 | Data & Model Poisoning | Provenance + pin/SHA (§2); model-tier registry (`ai-cost-policy` §1); sandboxed-eval | manual |
| LLM05 | Improper Output Handling | Output validators **pending #104**; no-authority canon (ADR-130/127) | manual; runtime **pending #104** |
| LLM06 | Excessive Agency | Agent-authority canon + HITL gate (I-27, `hitl_service.py`) | active (governance) |
| LLM07 | System Prompt Leakage | Prompt-canon separation + `litellm-guardrail-audit-hook` audit | manual |
| LLM08 | Vector & Embedding Weaknesses | Vector-store governance (ChromaDB/Qdrant) + perimeter isolation (ADR-117) | manual |
| LLM09 | Misinformation | Decision-lineage / Art.13 explainability + HITL for L2+ | active (governance) |
| LLM10 | Unbounded Consumption | `ai-cost-policy` budget/hard-cap/anomaly/hard-stop (§2/§3/§4/§6) + rate-limit (ADR-030) | active (governance) |

**Constraint (PROPOSED):** governance-doc only — **no runtime code change and no new CI wiring** in
this sprint. The CI gate for LLM01/LLM05 (runtime prompt/output enforcement) is deferred until the
runtime guardrail ADOPTs land (**#65 nemo-guardrails**, **#104 guardrails-ai**). All thresholds
referenced (budgets, rate limits, entropy) remain **governed-config proposals** (CLAUDE.md §10),
held in their existing config, not in this policy.
