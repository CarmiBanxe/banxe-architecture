# Refactor SPEC #20 — Automation platform (C27, n8n-like trigger system)

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_TAIL; NEW-driven; surfaces C27 workflow automation — largest TAIL group)
Scope: 19 control-plane + trigger-automation legacy projects -> banxe-automation-platform
Source: BANXE.RAR; CLASS_TAIL.tsv (control-plane + n8n-like targets)
NEW capability: C27 (workflow automation / trigger system) — surfaced by CLASS_TAIL NEW-driven sweep
Related: SPEC #3 NotificationPort (automation triggers notifications); compliance plane (automated AML/recon triggers)
Owner: Terminal B (smart refactor)

## Purpose

NEW-driven sweep of CLASS_TAIL surfaced C27 (workflow automation), the largest single TAIL group (19 projects). Legacy had a control-plane + n8n-like trigger system for operational automation (recon triggers, alert routing, scheduled compliance jobs). Migrate to banxe-automation-platform (either OSS n8n self-hosted or a purpose-built trigger engine). Mine trigger definitions + workflow logic; drop legacy control-plane runtime.

## Decision (NEW-driven)

- 10 control-plane + UI projects -> banxe-automation-platform (operational orchestration + admin UI).
- 9 n8n-like trigger projects -> banxe-automation triggers (or self-hosted n8n OSS).
- Keep: workflow definitions, trigger rules, scheduled-job logic (compliance recon, AML re-checks).
- Drop: legacy control-plane runtime; build-fresh on n8n or purpose-built engine.
- Integration: triggers fire via NotificationPort (alerts) + call other ports (recon, KYC re-verify per ADR-028).

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decision (this SPEC).
- Phase B-C (Terminal B): banxe-automation-platform; choose n8n OSS vs purpose-built; migrate trigger/workflow definitions.
- Phase D (Terminal B): test critical workflows (daily recon, KYC re-verify, AML alerts); audit every automated action to guardian_audit_events.
- Phase E-F (Terminal B): cut over; ARCHIVE 19 legacy; IL record.

## Risk register tie-in

- R-REG-01 (CASS 15 recon): automation drives daily reconciliation; failure = compliance gap.
- R-COMP-FCA-07 (automated-action audit): every automated workflow action audited for MLRO.
- R-OPS-AUTOMATION-01: critical compliance jobs must alert on failure (NotificationPort critical severity).

## Acceptance criteria

- banxe-automation-platform runs critical workflows (recon, KYC re-verify, AML alerts).
- Every automated action audited; failures alert MLRO via NotificationPort.
- PRIORITY-MAP amended with C27.
- 19 legacy automation projects ARCHIVE.

## References

- SPEC #3 NotificationPort; ADR-028 KYC re-verify; ADR-027 audit
- NEW-PROJECT-PRIORITY-MAP (to amend C27); CLASS_TAIL.tsv (19 automation rows)
- RISK_REGISTER R-REG-01; UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF Automation platform SPEC #20 (CLASS_TAIL; NEW-driven C27; largest TAIL group) ===
