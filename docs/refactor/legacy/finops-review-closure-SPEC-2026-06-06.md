# Refactor SPEC #19 — FinOps automation (C26) + CLASS_REVIEW closure

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_REVIEW final; NEW-driven; surfaces C26 FinOps; closes CLASS_REVIEW)
Scope: 3 FinOps projects -> banxe-finops; + NEW-driven verdict for all 69 CLASS_REVIEW
Source: BANXE.RAR; CLASS_REVIEW.tsv
NEW capability: C26 (FinOps / financial-operations automation)
Related: ADR-027 audit; SPEC #5 EMI Banking (cost/reconciliation feed)
Owner: Terminal B (smart refactor)

## Purpose

Close CLASS_REVIEW NEW-driven sweep. The only remaining capability-serving group is FinOps automation (3 projects -> banxe-finops, C26: cost reconciliation, settlement automation, financial reporting). All other CLASS_REVIEW projects are either covered by existing SPECs or anti-mapped.

## C26 FinOps decision

- 3 FinOps-automation legacy projects -> banxe-finops service.
- Mine settlement-automation + cost-reconciliation logic; feed midaz-ledger + ACPR reporting (R-REG-04).

## CLASS_REVIEW NEW-driven verdict (69 total)

- 12 shared-libs -> SPEC #18 (banxe-shared-libs).
- 3 FinOps -> SPEC #19 (banxe-finops, C26).
- ~14 crypto-ops/payment-core MERGE -> already covered by SPECs #7/#9/#17.
- 19 DROP-LEGACY-INFRA -> anti-map (NPM/Gateway/Discovery -> GitHub Packages/nginx/K8s; old orchestration -> systemd; build-fresh infra).
- 9 DROP-VABS-DEPRECATED -> anti-map (VABS deprecated; SPEC #10 covers the migration target).
- 3 DROP-DEV-ONLY -> anti-map (dev/test tools, not production).
- ~9 misc (message broker libs -> standardise RabbitMQ; reports/dashboards -> banxe-emi-stack; doc-import -> compliance_automation; ACL frontend -> banxe-ui) -> build-fresh/infra, no Transform SPEC.

Net: of 69 REVIEW projects, 15 capability-serving (12 shared-libs + 3 FinOps) get SPECs; ~14 already covered; ~40 anti-map/infra/build-fresh. CLASS_REVIEW 69/69 swept.

## Refactor strategy + acceptance

- Phase A (done): FinOps decision + REVIEW closure verdict (this SPEC).
- Phase B-F (Terminal B): banxe-finops service; settlement/cost-recon logic; feed ACPR reporting; ARCHIVE 3 FinOps + anti-mapped legacy.
- Acceptance: C26 added to PRIORITY-MAP; banxe-finops feeds R-REG-04 reporting; CLASS_REVIEW 69/69 closed.

## References

- ADR-027 audit; SPEC #5; NEW-PROJECT-PRIORITY-MAP (to amend C26)
- CLASS_REVIEW.tsv (69 rows); RISK_REGISTER R-REG-04
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF FinOps + REVIEW closure SPEC #19 (CLASS_REVIEW 69/69 swept; NEW-driven C26) ===
