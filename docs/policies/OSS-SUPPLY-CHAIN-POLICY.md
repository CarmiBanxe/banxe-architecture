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
