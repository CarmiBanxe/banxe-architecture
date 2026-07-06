# BEST-DECISION-RETROFIT-PLAN

> Prepare-only schedule. It plans the retrofit of the new **`## Decision Method`** SOUL section (added to
> `agents/souls/_TEMPLATE.md` in this PR) into the **58 existing SOULs**, none of which currently carry it. This
> doc **schedules** the work; it edits **no** existing SOUL. Retrofit is a separate serial effort — **one PR per
> batch**, each grounded per-passport, prepare-only, no activation (FACTORY-CANON §1.11).

## Scope

- **Existing SOULs:** 58 (`ls agents/souls/*.md | grep -v _TEMPLATE | wc -l`).
- **With `## Decision Method`:** 0 → **58 to retrofit**.
- **Source-of-truth for the section** (pointer-first, ADR-102 — reference, do not restate): theory
  `docs/sources/best-decision-concept-2026-07-06-v2.md`; principle/gate `docs/adr/ADR-162-best-decision-principle.md`;
  boundary `docs/canon/BEST-DECISION-BOUNDARY.md`; synthesis `docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md`.

## Retrofit discipline (per batch PR)

1. One PR per batch; edit ONLY the listed SOULs' bodies (add `## Decision Method` after `## HITL Gate`, per the template).
2. Ground each SOUL's method in its passport's ACTUAL criteria/invariants — do NOT normalise; runtime L2+ on
   payment/compliance/KYC/AML states **fail-closed precedence** explicitly.
3. NO passport diff; NO `_TEMPLATE.md` diff (already done here); paired IL shard; signed; `--force-with-lease`.
4. Verify each retrofitted SOUL still parses all mandatory sections (template + Decision Method).

## Batches (one PR each) — 58 SOULs

**R1 — Finance / accounting (11)** *(pre-existing; low client-fund risk — good first batch)*: `apar-agent`,
`beancount-export-agent`, `budget-agent`, `cash-position-agent`, `consolidation-agent`, `finance-bi-agent`,
`forecast-agent`, `fx-exposure-agent`, `gl-close-agent`, `ifrs-agent`, `tax-compliance-agent`.

**R2 — AML / sanctions / compliance-screening (10)**: `banxe-aml-orchestrator`, `sanctions-check-core`,
`tx-monitor-core`, `watchman-adapter-core`, `yente-adapter-agent`, `jube-adapter-core`, `mlro-report-agent`,
`fca-data-extraction-agent`, `adverse-media-governor`, `regulatory-returns-governor`. *(HIGH sensitivity — screen/monitor discipline; fail-closed emphasis.)*

**R3 — Payments CTX-04 (4)**: `channel-c-sepa-orchestrator`, `channel-c-swift-orchestrator`, `payment-router-agent`,
`coo-operations-agent`. *(HIGHEST client-fund sensitivity — payment-core fail-closed; retrofit last / with most care.)*

**R4 — Reporting CTX-10 (4)**: `board-reporting-agent`, `cfo-orchestration-agent`, `reporting-agent`,
`wind-down-planning-agent`.

**R5 — Customer CTX-06 + agreement/legal/HR CTX-07 (11)**: `alerting-agent`, `customer-lifecycle-agent`,
`fatca-crs-reporting-governor`, `front-office-agent`, `crm-dsar-governor`, `support-sla-governor`,
`user-preferences-agent`, `document-management-agent`, `agreement-agent`, `legal-corporate-agent`, `hr-agent`.

**R6 — Tech / platform / data CTX-03 & CTX-09 (14)**: `midaz-mcp-agent`, `reasoning-bank-agent`, `ml-pipeline-agent`,
`webhook-orchestrator-agent`, `webhooks-agent`, `clickhouse-writer`, `cto-platform-agent`, `experiment-copilot-agent`,
`sandbox-rails-governor`, `sdk-release-governor`, `multi-tenancy-agent`, `m-gateway-api-governor`, `design-pipeline-agent`,
`data-lake-elt-agent`. *(Low client-fund risk.)*

**R7 — Governance / safeguarding / dev-tooling (4)**: `gap-tracker-agent`, `spec-first-auditor`,
`safeguarding-recon-governor`, `bi-dashboard-governor`. *(Monitor/audit; low risk.)*

*Batch totals: R1(11) + R2(10) + R3(4) + R4(4) + R5(11) + R6(14) + R7(4) = **58** ✓ (each SOUL in exactly one batch).*

> The batch buckets above are a **scheduling convenience** (by domain / client-fund risk, low-risk first). The
> authoritative enumeration is `ls agents/souls/*.md | grep -v _TEMPLATE` (58); a SOUL appears in exactly one
> retrofit PR. Suggested order: **R1 → R6 → R7 → R5 → R4 → R2 → R3** (ascending client-fund sensitivity).

## Governance note — reconciled in this PR (no silent divergence, SYNC-CANON)

Adding `## Decision Method` to the template exercises the "separately gated" clause reserved by the best-decision
canon, and is now **reconciled in this same PR** so `main` stays internally consistent:

1. **ADR-131 amended (append-only, I-24):** `docs/adr/ADR-131-souls-format-standard.md` gains an "Amendment 2026-07-07"
   block recording `## Decision Method` as a mandatory section (canonical count 11 → 12). This is the SOUL-format
   source-of-truth; the amendment makes the standard match the template.
2. **Synthesis clarified:** `docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md` frontmatter gets a dated note that
   the template now carries the section (the doc itself still only *references* the method).
3. **BEST-DECISION-BOUNDARY — no edit (verified, not a contradiction):** the on-main BOUNDARY §4 is *adoption
   outcomes* and §5 is *HITL-merge / I-27 / CODEOWNERS / intake / config* — **neither contains a "no dedicated
   decision-method section" claim**. That wording existed only in a **closed, never-merged draft (#1068)**, so there
   is nothing to reverse there; editing it would fabricate a fix for absent text (ADR-102 — don't touch what needs no change).

Result: **zero contradiction on `main`** after this PR — template (12 sections) ↔ ADR-131 (amended) ↔ FACTORY-CANON §1.11 ↔ synthesis note all agree.

## Anchors
- `agents/souls/_TEMPLATE.md` (`## Decision Method` section, added this PR) · `docs/factory/FACTORY-CANON.md` §1.11
- `docs/sources/best-decision-concept-2026-07-06-v2.md` · `docs/adr/ADR-162-best-decision-principle.md`
- `docs/canon/BEST-DECISION-BOUNDARY.md` · `docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md`
- **ADR-131** (SOUL format standard — needs amendment for the new section) · ADR-102 (pointer-first)
