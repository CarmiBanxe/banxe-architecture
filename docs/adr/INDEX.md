# ADR Index — banxe-architecture (unified)

Generated: 2026-05-12 (regenerated 2026-05-14 per Sprint D3.2d.3-FU)
Generator: Sprint D3.2d.3 (rewrite from D2 single-catalogue scope to unified scope);
Sprint D3.2d.3-FU (ADR Status backfill — 20 UNKNOWN → Accepted)
Source: `decisions/ADR-*.md` (canonical catalogue, 37 files) + `docs/adr/ADR-*.md`
(factory ADRs post-D3.2d.1 renumber, 11 files incl. ADR-045 Intent-First,
ADR-046 Decision Lineage Schema, ADR-047 AI Cost Governance Policy,
ADR-048 S13-00 Business Process Repository — ADR-046/047/048 are the three
ADR-045 §D7 siblings, now all authored — and ADR-049 Intent Layer &
Client-Facing Agent Masks, 2026-06-07, the L1 + L1→L2 client-surface spec of ADR-045)

This index covers BOTH ADR catalogues. After Sprint D3.2d.1 collision renumber,
the two catalogues are non-colliding: `decisions/` holds ADR-001..035, ADR-036,
ADR-038, ADR-074..077 (38 files); `docs/adr/` holds ADR-039..055 (17 files;
factory / agent governance scope). Numbers ADR-021, ADR-023, ADR-031, ADR-037,
ADR-056..073, ADR-078+ are unassigned (see §"MISSING / unassigned").
Correction (2026-06-08, IL-137): the prior free-block line read "ADR-050..073
unassigned (24 free)", but ADR-050 (Crypto-Ops Subgroup Delivery Model),
ADR-051 (Coding Execution Decision) and ADR-052 (Canon Enforcement Runtime)
were authored by parallel sessions and ADR-053 is added here — so the real
free block was ADR-054..073 (20 numbers).
Update (2026-06-08, IL-141): ADR-054 (Analytics / Reporting Client-Facing Mask
C7, extends ADR-049 via ADR-053) is added here — so the real free block is now
**ADR-055..073 (19 numbers)**.
Update (2026-06-08, IL-143): ADR-055 (Statements Client-Facing Mask, extends
ADR-049 via ADR-053; third extended-catalogue entry after Cards C22 and
Analytics C7; ADR-054 §D5 deferred Statements to it) is added here — so the real
free block is now **ADR-056..073 (18 numbers)**.

Status values are parsed verbatim from each ADR's `**Status:**` line. Where no
`**Status:**` line exists at the top of the file, the row shows `UNKNOWN` and
the ADR is listed in the §"Parse failures" section at the bottom for follow-up
in a later D3.2d sprint. As of 2026-05-14 (Sprint D3.2d.3-FU) the 20 previous
parse failures have been resolved by inserting canonical `**Status:**` /
`**Date:**` / `**Source-of-determination:**` header lines after the H1 in
each of the 20 ADRs; INDEX UNKNOWN coverage was 24 (20 file-side + 4 placeholder)
and is now 4 (placeholder-only).

---

## Real ADR files in `decisions/` (canonical catalogue, 37 files)

| Number  | Title                                                                                              | Status                                          | Date       | Path |
|---------|----------------------------------------------------------------------------------------------------|-------------------------------------------------|------------|------|
| ADR-001 | Модель привилегий — разработчик vs оператор-дублёр                                                  | Accepted                                        | 2026-04-05 | [decisions/ADR-001-privilege-model.md](../../decisions/ADR-001-privilege-model.md) |
| ADR-002 | Telegram-бот — область применения                                                                   | Accepted                                        | 2026-04-05 | [decisions/ADR-002-telegram-bot-scope.md](../../decisions/ADR-002-telegram-bot-scope.md) |
| ADR-003 | Обучение модели — только разработчик/CTIO                                                            | Accepted                                        | 2026-04-05 | [decisions/ADR-003-training-developer-only.md](../../decisions/ADR-003-training-developer-only.md) |
| ADR-004 | Jube AGPLv3 — граница использования                                                                  | Accepted                                        | 2026-04-05 | [decisions/ADR-004-jube-agplv3-boundary.md](../../decisions/ADR-004-jube-agplv3-boundary.md) |
| ADR-005 | Marble Elastic License V2 — граница использования                                                    | Accepted                                        | 2026-04-05 | [decisions/ADR-005-marble-elastic-v2.md](../../decisions/ADR-005-marble-elastic-v2.md) |
| ADR-006 | EvidenceBundle — контракт доказательной базы                                                         | Accepted                                        | 2026-04-05 | [decisions/ADR-006-evidence-bundle.md](../../decisions/ADR-006-evidence-bundle.md) |
| ADR-007 | Scenario Registry Design — AMLTRIX Mapping Policy                                                    | Accepted                                        | —          | [decisions/ADR-007-scenario-registry-design.md](../../decisions/ADR-007-scenario-registry-design.md) |
| ADR-008 | Jurisdiction label — preemptive UK tagging                                                           | Accepted                                        | 2026-04-05 | [decisions/ADR-008-jurisdiction-label.md](../../decisions/ADR-008-jurisdiction-label.md) |
| ADR-009 | OpenSanctions + Yente — primary sanctions/PEP source                                                 | Accepted                                        | 2026-04-05 | [decisions/ADR-009-opensanctions-yente.md](../../decisions/ADR-009-opensanctions-yente.md) |
| ADR-010 | AMLTRIX taxonomy — industry-standard scenario labelling                                              | Accepted                                        | 2026-04-05 | [decisions/ADR-010-amltrix-taxonomy.md](../../decisions/ADR-010-amltrix-taxonomy.md) |
| ADR-011 | Reference Architecture vs Operational Dependency                                                     | Accepted                                        | 2026-04-05 | [decisions/ADR-011-reference-vs-dependency.md](../../decisions/ADR-011-reference-vs-dependency.md) |
| ADR-012 | Compliance API Port Migration :8090 → :8093                                                          | ACCEPTED                                        | —          | [decisions/ADR-012-compliance-api-port-8093.md](../../decisions/ADR-012-compliance-api-port-8093.md) |
| ADR-013 | Midaz CBS: PRIMARY Core Banking System                                                               | ACCEPTED                                        | —          | [decisions/ADR-013-midaz-cbs-primary.md](../../decisions/ADR-013-midaz-cbs-primary.md) |
| ADR-014 | Composable Financial Stack — EMI Core Architecture                                                   | PROPOSED                                        | —          | [decisions/ADR-014-composable-financial-stack.md](../../decisions/ADR-014-composable-financial-stack.md) |
| ADR-015 | Payment Processing Stack — Hyperswitch + Paymentology                                                | ACCEPTED                                        | 2026-04-13 | [decisions/ADR-015-payment-processing-stack.md](../../decisions/ADR-015-payment-processing-stack.md) |
| ADR-016 | AI Plane and PII/AML Routing for EMI Stack                                                           | Accepted                                        | 2026-05-03 | [decisions/ADR-016-ai-plane-pii-aml-routing.md](../../decisions/ADR-016-ai-plane-pii-aml-routing.md) |
| ADR-017 | Keycloak IAM Cutover for EMI Realm `banxe-emi`                                                       | Accepted                                        | 2026-05-03 | [decisions/ADR-017-keycloak-iam-cutover.md](../../decisions/ADR-017-keycloak-iam-cutover.md) |
| ADR-018 | Hybrid 5-layer AI Compute Architecture (canonical target)                                            | ACCEPTED (canon, locked)                        | —          | [decisions/ADR-018-hybrid-5-layer-ai-compute.md](../../decisions/ADR-018-hybrid-5-layer-ai-compute.md) |
| ADR-019 | AI Guardian Agent — two-family architecture compliance enforcement                                   | ACCEPTED (canon, locked)                        | —          | [decisions/ADR-019-ai-guardian-two-family.md](../../decisions/ADR-019-ai-guardian-two-family.md) |
| ADR-020 | Memory governance — 100% utilization of MEMORY/LEDGER/GAP/CANON/HITL                                 | ACCEPTED (canon, locked)                        | —          | [decisions/ADR-020-memory-governance.md](../../decisions/ADR-020-memory-governance.md) |
| ADR-022 | Guardian bootstrap baseline exception (one-time amendment to ADR-019 §6.1 F7)                        | ACCEPTED (one-time, scoped exception)           | —          | [decisions/ADR-022-guardian-bootstrap-baseline-exception.md](../../decisions/ADR-022-guardian-bootstrap-baseline-exception.md) |
| ADR-024 | Guardian Bash Shim: Claude Code Pre-Command Enforcement                                              | Accepted                                        | 2026-05-04 | [decisions/ADR-024-guardian-bash-shim.md](../../decisions/ADR-024-guardian-bash-shim.md) |
| ADR-025 | Agent Interaction Canon                                                                              | Accepted                                        | 2026-05-04 | [decisions/ADR-025-agent-interaction-canon.md](../../decisions/ADR-025-agent-interaction-canon.md) |
| ADR-026 | Guardian Third Family — agent.bash                                                                   | Accepted                                        | 2026-05-05 | [decisions/ADR-026-guardian-agent-bash-family.md](../../decisions/ADR-026-guardian-agent-bash-family.md) |
| ADR-027 | Audit-Trail Durability Strategy                                                                      | Accepted (2026-05-06)                           | 2026-05-06 | [decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md) |
| ADR-028 | KYC Re-verification Triggers                                                                         | Accepted (2026-05-09)                           | 2026-05-09 | [decisions/ADR-028-kyc-reverification-triggers.md](../../decisions/ADR-028-kyc-reverification-triggers.md) |
| ADR-029 | PostgreSQL Backup Strategy                                                                           | Accepted (2026-05-10)                           | 2026-05-10 | [decisions/ADR-029-postgres-backup-strategy.md](../../decisions/ADR-029-postgres-backup-strategy.md) |
| ADR-030 | Auth Surface Rate-Limit Policy                                                                       | Accepted (2026-05-12)                           | 2026-05-12 | [decisions/ADR-030-auth-rate-limit-policy.md](../../decisions/ADR-030-auth-rate-limit-policy.md) |
| ADR-032 | Secret Rotation Policy (Interim)                                                                     | Proposed (2026-05-06)                           | 2026-05-06 | [decisions/ADR-032-secret-rotation-policy.md](../../decisions/ADR-032-secret-rotation-policy.md) |
| ADR-033 | Alert Routing Strategy (Keycloak Auth Events)                                                        | Accepted (2026-05-11) — Option (a) n8n+Telegram | 2026-05-11 | [decisions/ADR-033-alert-routing-strategy.md](../../decisions/ADR-033-alert-routing-strategy.md) |
| ADR-034 | Webhook Reliability Strategy (KYC / SumSub Inbound)                                                  | Accepted (2026-05-11) — Steps 1-4 merged        | 2026-05-11 | [decisions/ADR-034-webhook-reliability-kyc.md](../../decisions/ADR-034-webhook-reliability-kyc.md) |
| ADR-035 | CI Smoke-Gate Policy                                                                                 | Accepted (2026-05-11) — 5 steps merged          | 2026-05-11 | [decisions/ADR-035-ci-smoke-gate-policy.md](../../decisions/ADR-035-ci-smoke-gate-policy.md) |
| ADR-036 | FATF Travel Rule for crypto-asset transfers                                                          | Closed (2026-05-11) — deferred S21              | 2026-05-11 | [decisions/ADR-036-travel-rule.md](../../decisions/ADR-036-travel-rule.md) |
| ADR-038 | Vault / Infisical Adoption (Placeholder)                                                             | Placeholder (2026-05-06)                        | 2026-05-06 | [decisions/ADR-038-vault-adoption-placeholder.md](../../decisions/ADR-038-vault-adoption-placeholder.md) |
| ADR-074 | Stealth Addresses, Silent Payments & ZKP Identity for Ghost Mode                                     | PROPOSED                                        | —          | [decisions/ADR-074-stealth-and-silent-payments.md](../../decisions/ADR-074-stealth-and-silent-payments.md) |
| ADR-075 | PayJoin & HD Privacy Score for Ghost Mode                                                            | PROPOSED                                        | —          | [decisions/ADR-075-payjoin-and-hd-privacy-score.md](../../decisions/ADR-075-payjoin-and-hd-privacy-score.md) |
| ADR-076 | RAILGUN Integration Decision Gate                                                                    | PENDING LEGAL REVIEW                            | —          | [decisions/ADR-076-railgun-integration-decision-gate.md](../../decisions/ADR-076-railgun-integration-decision-gate.md) |
| ADR-077 | Guardian -> GitHub webhook auth: GitHub App vs PAT | ACCEPTED | 2026-05-22 | [decisions/ADR-077-guardian-github-webhook-auth-app-vs-pat.md](../../decisions/ADR-077-guardian-github-webhook-auth-app-vs-pat.md) |

## Real ADR files in `docs/adr/` (factory governance, 17 files)

| Number  | Title                                                                                              | Status   | Date       | Path |
|---------|----------------------------------------------------------------------------------------------------|----------|------------|------|
| ADR-039 | Claude Code permissions reclassification                                                            | Accepted | 2026-05-05 | [./ADR-039-claude-code-permissions-reclassification.md](./ADR-039-claude-code-permissions-reclassification.md) |
| ADR-040 | AI Execution Policy — Meta-Plane vs Inference-Plane                                                  | Accepted | 2026-05-03 | [./ADR-040-ai-execution-policy.md](./ADR-040-ai-execution-policy.md) |
| ADR-041 | GLM-4.5-Air Distributed Inference (USB4 RPC)                                                         | Accepted | 2026-05-03 | [./ADR-041-glm45-air-distributed.md](./ADR-041-glm45-air-distributed.md) |
| ADR-042 | ufw Perimeter Posture per Host                                                                       | Accepted | 2026-05-03 | [./ADR-042-ufw-perimeter.md](./ADR-042-ufw-perimeter.md) |
| ADR-043 | Aider/Continue Routes — `ai` / `ai-heavy` / `reasoning`                                              | Accepted | 2026-05-03 | [./ADR-043-aider-routes.md](./ADR-043-aider-routes.md) |
| ADR-044 | AI Pool Roadmap 2026-05-11                                                                           | Accepted | —          | [./ADR-044-ai-pool-roadmap-2026-05-11.md](./ADR-044-ai-pool-roadmap-2026-05-11.md) |
| ADR-045 | Intent-First Banking Architecture for EMI BANXE AI BANK                                              | Accepted | 2026-06-07 | [./ADR-045-intent-first-banking-architecture.md](./ADR-045-intent-first-banking-architecture.md) |
| ADR-046 | Decision Lineage Schema (AgentDecisionRecord) for EMI BANXE AI BANK                                  | Accepted | 2026-06-07 | [./ADR-046-decision-lineage-schema.md](./ADR-046-decision-lineage-schema.md) |
| ADR-047 | AI Cost Governance Policy (per-agent budgets & cost caps) for EMI BANXE AI BANK                      | Accepted | 2026-06-07 | [./ADR-047-ai-cost-governance-policy.md](./ADR-047-ai-cost-governance-policy.md) |
| ADR-048 | S13-00 Business Process Repository (canonize banxe-business-processes) for EMI BANXE AI BANK         | Accepted | 2026-06-07 | [./ADR-048-business-process-repository.md](./ADR-048-business-process-repository.md) |
| ADR-049 | Intent Layer & Client-Facing Agent Masks (L1 spec & the L1→L2 client surface) for EMI BANXE AI BANK   | Accepted | 2026-06-07 | [./ADR-049-intent-layer-client-facing-agent-masks.md](./ADR-049-intent-layer-client-facing-agent-masks.md) |
| ADR-050 | Crypto-Ops Subgroup Delivery Model                                                                  | Proposed | —          | [./ADR-050-crypto-ops-subgroup-delivery-model.md](./ADR-050-crypto-ops-subgroup-delivery-model.md) |
| ADR-051 | Coding Execution Decision (Claude vs Local)                                                         | Accepted | 2026-06-07 | [./ADR-051-coding-execution-decision.md](./ADR-051-coding-execution-decision.md) |
| ADR-052 | Canon Enforcement Runtime                                                                           | Accepted | 2026-06-07 | [./ADR-052-canon-enforcement-runtime.md](./ADR-052-canon-enforcement-runtime.md) |
| ADR-053 | Client-Facing Mask Catalogue Extensibility & the Mask↔Domain-Agent Governance Boundary (extends ADR-049) | Proposed | 2026-06-08 | [./ADR-053-client-facing-mask-extensibility-and-domain-agent-boundary.md](./ADR-053-client-facing-mask-extensibility-and-domain-agent-boundary.md) |
| ADR-054 | Analytics / Reporting Client-Facing Mask (C7) — second extended-catalogue entry (extends ADR-049 via ADR-053) | Proposed | 2026-06-08 | [./ADR-054-analytics-reporting-client-facing-mask-c7.md](./ADR-054-analytics-reporting-client-facing-mask-c7.md) |
| ADR-055 | Statements Client-Facing Mask — third extended-catalogue entry (extends ADR-049 via ADR-053) | Proposed | 2026-06-08 | [./ADR-055-statements-client-facing-mask.md](./ADR-055-statements-client-facing-mask.md) |

## MISSING / unassigned ADR numbers

| Number(s)        | Status                                                                  |
|------------------|-------------------------------------------------------------------------|
| ADR-021          | ExchangePort Network Transport — `banxe-trading-backend` + MarketDataPort (ACCEPTED 2026-06-12; `decisions/ADR-021-exchangeport-network-transport.md`; IL-190). |
| ADR-023          | UNASSIGNED — no file in either catalogue.                                |
| ADR-031          | UNASSIGNED — no file in either catalogue.                                |
| ADR-037          | UNASSIGNED — free for next factory or product ADR.                       |
| ADR-045          | Intent-First Banking Architecture for EMI BANXE AI BANK (ACCEPTED 2026-06-07; docs/adr/). |
| ADR-046          | Decision Lineage Schema (AgentDecisionRecord) (ACCEPTED 2026-06-07; docs/adr/; ADR-045 §D7.1). |
| ADR-047          | AI Cost Governance Policy (per-agent budgets & cost caps) (ACCEPTED 2026-06-07; docs/adr/; ADR-045 §D7.2). |
| ADR-048          | S13-00 Business Process Repository — canonize banxe-business-processes (ACCEPTED 2026-06-07; docs/adr/; ADR-045 §D7.3 — final §D7 sibling; §D7 backlog now CLOSED). |
| ADR-049          | Intent Layer & Client-Facing Agent Masks (ACCEPTED 2026-06-07; docs/adr/; specifies ADR-045 L1 + the L1→L2 client surface; NOT a §D7 sibling). |
| ADR-050          | Crypto-Ops Subgroup Delivery Model (PROPOSED; docs/adr/; parallel session). |
| ADR-051          | Coding Execution Decision (Claude vs Local) (ACCEPTED 2026-06-07, P0-A hybrid; docs/adr/; IL-131). |
| ADR-052          | Canon Enforcement Runtime (ACCEPTED 2026-06-07; docs/adr/; IL-131). |
| ADR-053          | Client-Facing Mask Catalogue Extensibility & the Mask↔Domain-Agent Governance Boundary (PROPOSED 2026-06-08; docs/adr/; extends ADR-049; adds Cards C22 mask; IL-137). |
| ADR-054          | Analytics / Reporting Client-Facing Mask C7 (PROPOSED 2026-06-08; docs/adr/; extends ADR-049 via ADR-053; second extended-catalogue entry after Cards; reads AUTO-with-cap, export REVIEW, PII + data-egress gate; IL-141). |
| ADR-055          | Statements Client-Facing Mask (PROPOSED 2026-06-08; docs/adr/; extends ADR-049 via ADR-053; third extended-catalogue entry after Cards C22 & Analytics C7; ADR-054 §D5 deferred Statements to it; read/generate AUTO-with-cap, external delivery REVIEW, PII + data-egress gate; statement_agent.py → StatementPort adapter, untouched; IL-143). |
| ADR-056..073     | UNASSIGNED block — 18 free numbers between docs/adr/ and Ghost-Mode set. |
| ADR-077          | Guardian -> GitHub webhook auth: GitHub App vs PAT (ACCEPTED 2026-05-22, App default).
| ADR-078+         | UNASSIGNED — next free after ADR-077 (Guardian webhook auth).                     |

Note: the brief listed the ADR-045..073 block as "28 free numbers"; the
inclusive range 45..73 actually contains 29 numbers. Flagged here for the
canon record; non-blocking.

## Parse failures (Status = UNKNOWN)

As of 2026-05-14 (Sprint D3.2d.3-FU): **0 parse failures**. All 20 previously
UNKNOWN ADRs were resolved by inserting canonical `**Status:**` /
`**Date:**` / `**Source-of-determination:**` header lines after the H1.
All 20 resolved to Status = Accepted with no body content rewrites.

Backfill summary (Sprint D3.2d.3-FU, 2026-05-14):

`decisions/` (15 files — all Accepted):
- ADR-001 privilege-model — Accepted 2026-04-05 (Russian `**Статус:** ACCEPTED`)
- ADR-002 telegram-bot-scope — Accepted 2026-04-05 (Russian `**Статус:** ACCEPTED`)
- ADR-003 training-developer-only — Accepted 2026-04-05 (Russian `**Статус:** ACCEPTED`)
- ADR-004 jube-agplv3-boundary — Accepted 2026-04-05 (Russian `**Статус:** ПРИНЯТО`)
- ADR-005 marble-elastic-v2 — Accepted 2026-04-05 (Russian `**Статус:** ПРИНЯТО`)
- ADR-006 evidence-bundle — Accepted 2026-04-05 (Russian `**Статус:** ПРИНЯТО`)
- ADR-008 jurisdiction-label — Accepted 2026-04-05 (Russian `**Статус:** ПРИНЯТО`)
- ADR-009 opensanctions-yente — Accepted 2026-04-05 (Russian `**Статус:** ПРИНЯТО (Phase 3)`)
- ADR-010 amltrix-taxonomy — Accepted 2026-04-05 (Russian `**Статус:** ПРИНЯТО`)
- ADR-011 reference-vs-dependency — Accepted 2026-04-05 (Russian `**Статус:** ПРИНЯТО`)
- ADR-016 ai-plane-pii-aml-routing — Accepted 2026-05-03 (list-form `- **Status:** Accepted`)
- ADR-017 keycloak-iam-cutover — Accepted 2026-05-03 (list-form `- **Status:** Accepted`; S12.1 / S13.8 verify)
- ADR-024 guardian-bash-shim — Accepted 2026-05-04 (table-form `| **Status** | Accepted |`)
- ADR-025 agent-interaction-canon — Accepted 2026-05-04 (list-form `- **Status:** ACCEPTED`)
- ADR-026 guardian-agent-bash-family — Accepted 2026-05-05 (list-form `- **Status:** ACCEPTED`)

`docs/adr/` (5 files — all Accepted):
- ADR-039 claude-code-permissions-reclassification — Accepted 2026-05-05 (table-form + Status history table)
- ADR-040 ai-execution-policy — Accepted 2026-05-03 (YAML frontmatter `status: ACCEPTED` + `## Status` section)
- ADR-041 glm45-air-distributed — Accepted 2026-05-03 (YAML frontmatter `status: ACCEPTED` + `## Status` section)
- ADR-042 ufw-perimeter — Accepted 2026-05-03 (YAML frontmatter `status: ACCEPTED` + `## Status` section)
- ADR-043 aider-routes — Accepted 2026-05-03 (YAML frontmatter `status: ACCEPTED` + `## Status` section)

Methodology: per-file content analysis (decision drivers + Closes refs + body
mentions), NO invention; ambiguous → UNKNOWN with TODO. Status determination
methodology anchor: IL-OPS-D3-2D-3-FU-ADR-STATUS-BACKFILL-2026-05-14.

## Cross-references

Anchor citations from `docs/project/compliance/README.md`,
`docs/project/security/README.md`, and other Layer-2 product-docs READMEs
MUST reference the canonical catalogue:

- `decisions/` for ADR-001..036, ADR-038, ADR-074..077.
- `docs/adr/` for ADR-039..044.

Specific anchors worth re-citing correctly:

- **ADR-027 (audit-trail durability)** lives in `decisions/` at
  [decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md).
  The previously-colliding `docs/adr/ADR-027` (claude-code permissions)
  was renumbered to **ADR-039** in Sprint D3.2d.1 and now lives at
  [./ADR-039-claude-code-permissions-reclassification.md](./ADR-039-claude-code-permissions-reclassification.md).
- **ADR-030 (Auth Surface Rate-Limit Policy)** Status: Accepted
  (2026-05-12) per file body in
  [decisions/ADR-030-auth-rate-limit-policy.md](../../decisions/ADR-030-auth-rate-limit-policy.md).
  Implementation evidence: banxe-architecture PR #172 (c9de9fc).
- **ADR-036 (FATF Travel Rule)** Status: Closed (2026-05-11) per
  [decisions/ADR-036-travel-rule.md](../../decisions/ADR-036-travel-rule.md);
  implementation deferred to Sprint S21 (Crypto Block).
- **ADR-042 (ufw Perimeter Posture per Host)** is the new home of the
  former docs/adr/ADR-033 (ufw perimeter) after the D3.2d.1 renumber;
  `decisions/ADR-033-alert-routing-strategy.md` retains the alert-routing
  scope.

## Generator script (reproducibility)

The two tables and the parse-failures list above are reproducible by the
following shell snippet, run from the repo root:

```bash
#!/usr/bin/env bash
set -euo pipefail
parse_one() {
  local f="$1"
  local num title status date_acc
  num=$(basename "$f" | sed -E 's/^ADR-([0-9]+).*/\1/')
  title=$(grep -m1 '^# ' "$f" | sed -E 's/^# +ADR-[0-9]+ *(—|–|:|-) *//; s/^# +//')
  status=$(grep -m1 '^\*\*Status:\*\*' "$f" | sed -E 's/^\*\*Status:\*\* *//' || true)
  date_acc=$(grep -m1 '^\*\*Date Accepted:\*\*' "$f" \
             | sed -E 's/^\*\*Date Accepted:\*\* *//' || true)
  if [ -z "${date_acc:-}" ]; then
    date_acc=$(grep -m1 '^\*\*Date:\*\*' "$f" \
               | sed -E 's/^\*\*Date:\*\* *//' || true)
  fi
  [ -z "${status:-}" ] && status="UNKNOWN"
  printf '%s|%s|%s|%s|%s\n' "$num" "$title" "$status" "${date_acc:-}" "$f"
}
echo '# decisions/'
for f in $(ls -1 decisions/ADR-*.md | sort -t- -k2 -n); do parse_one "$f"; done
echo '# docs/adr/'
for f in $(ls -1 docs/adr/ADR-*.md | sort -t- -k2 -n); do parse_one "$f"; done
```

The generator is informational only; this `INDEX.md` is hand-curated to
preserve human-readable status normalisation and cross-reference notes.
Re-running the generator may show drift from this index when ADR files
gain new `**Status:**` lines; reconcile in the next D3.2d sub-sprint.

Generator-script run timestamp (latest reconciliation): 2026-05-14 00:30 CEST
(Sprint D3.2d.3-FU — ADR Status backfill for 20 UNKNOWN ADRs;
INDEX UNKNOWN coverage 24 → 4 placeholder-only).
