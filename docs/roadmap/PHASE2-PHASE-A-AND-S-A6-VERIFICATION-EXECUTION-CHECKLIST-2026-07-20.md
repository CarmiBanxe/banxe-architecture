# Phase-2 Execution Checklist — Phase A Inventory and S-A6 Verification

**PHASE-2 EXECUTION / PHASE-A INVENTORY + S-A6 VERIFICATION / CHECKLIST / NO CODE MOVE**

## Purpose

- A practical checklist for operators to start Phase-2 safely, within the frozen Phase-1 governance boundaries.
- Covers Phase A (inventory and code-lift mapping) and the initial working use of the S-A6 verification sprint.
- Does not authorize any code move, refactor, or deploy — inventory and evidence only.
- Audit-first and HITL-only: humans classify and sign off; the checklist just structures the work.
- Evidence and findings recorded here feed the LEDGER-EMI install-audit and the Phase-2 gates later.

## Phase A — Inventory and Code-Lift Mapping

### A1. Inventory scope

Operators list, read-only:

- Basement services (accumulated but ungoverned).
- Sidecar processes.
- Draft / experimental code.
- MCP / agent integration scripts.
- Any code touching identity, ledger, gateway, or payments.

### A2. Inventory table template

To be filled by humans; rows left empty.

| Family ID | Component(s) | Location (repo/service) | Lane candidate (identity / ledger / gateway / other) | Owner (role) | Risk level (low/medium/high) | Notes |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |

### A3. Inventory steps

1. Discover components — enumerate services, scripts, and drafts in scope (read-only).
2. Group into families — cluster related components under one Family ID.
3. Assign lane candidate — identity / ledger / gateway / other, per the governed lanes.
4. Assign owner — a role (not a name) accountable for the family.
5. Estimate risk level — low / medium / high, using the Sprint-7 lane stance (value-bearing or identity/consent = high).

**Exit gate for Phase A:** every family present in the table with a lane candidate and an owner assigned.

## S-A6 Verification — Working Evidence Log

Uses the canon from the S-A6 verification sprint (no second ledger; no direct MCP→ledger writes; all writes via LedgerPort + LedgerAgent under HITL). This section is the fillable log.

### B1. Evidence log structure

Templates; do not fill with real data here.

**Architecture evidence**
- [ ] Evidence ID:
- [ ] Description:
- [ ] Source (diagram / config / text):

**Configuration evidence**
- [ ] Evidence ID:
- [ ] Description:
- [ ] Source (file / path / redacted snippet):

**Code-path evidence**
- [ ] Evidence ID:
- [ ] Description:
- [ ] Module / method reference:

**Operational evidence**
- [ ] Evidence ID:
- [ ] Description:
- [ ] Log sample / HITL record reference:

### B2. Findings template per canon statement

One block per canon statement; filled by humans.

**Canon 1**
- Canon statement: No second ledger — only one authoritative GL/ledger instance for financial records.
- Classification: Confirmed / Confirmed-with-caveats / Not proven / Broken
- Evidence refs:
- Impact level: low / medium / high
- Self-repair permitted: yes (config-hardening, adding checks) / no — design change required (project brain)
- Notes:

**Canon 2**
- Canon statement: No direct MCP→ledger writes — Midaz/MCP components cannot write directly to the ledger datastore.
- Classification: Confirmed / Confirmed-with-caveats / Not proven / Broken
- Evidence refs:
- Impact level: low / medium / high
- Self-repair permitted: yes (config-hardening, adding checks) / no — design change required (project brain)
- Notes:

**Canon 3**
- Canon statement: All writes via LedgerPort + LedgerAgent under HITL, with append-only and decision-trace constraints.
- Classification: Confirmed / Confirmed-with-caveats / Not proven / Broken
- Evidence refs:
- Impact level: low / medium / high
- Self-repair permitted: yes (config-hardening, adding checks) / no — design change required (project brain)
- Notes:

### B3. Execution notes

- Operators read configs and code only — never change them under this checklist.
- Any suspected "Broken" finding is escalated, not quietly fixed.
- Evidence IDs are stable and reused as references in the LEDGER-EMI install-audit later.

## Boundaries and safety

- No code move, refactor, or deploy under this checklist.
- No governance changes; the Phase-1 roadmap stays frozen.
- HITL mandatory for every classification.
- Any remediation goes into a separate repair plan (S-GATE-REPAIR / S-A6), not here.
