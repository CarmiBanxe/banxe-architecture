> ⚠ TRAINING DATA — SANDBOX — NOT FOR PRODUCTION

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

To be filled by humans. The rows below marked **SANDBOX / DEMO** are synthetic examples only — fictional components in the Banksy sandbox, no connection to any real bank, EMI, customer, or endpoint. Delete them before real inventory begins; leave real rows empty until filled by an operator.

| Family ID | Component(s) | Location (repo/service) | Lane candidate (identity / ledger / gateway / other) | Owner (role) | Risk level (low/medium/high) | Notes |
|---|---|---|---|---|---|---|
| DEMO-FAM-LEDGER-TEST (SANDBOX) | demo_ledger_sidecar.py; sandbox_mcp_adapter.yaml | banksy-sandbox-repo / services/demo-ledger-sidecar | ledger | Ledger / Safeguarding Engineer | medium | Synthetic components in Banksy sandbox; no connection to real EMI. |
| DEMO-FAM-IDV-STUB (SANDBOX) | demo_idv_stub.py | banksy-sandbox-repo / services/demo-idv-stub | identity | Identity Lane Engineer | medium | Synthetic identity stub; sandbox only, no real customer data. |
| DEMO-FAM-KYB-STUB (SANDBOX) | demo_kyb_stub.py; sandbox_ubo_checker.py | banksy-sandbox-repo / services/demo-kyb-stub | identity | Identity Lane Engineer | high | Synthetic KYB/UBO stub; sandbox only, no real business data. Remove before real inventory. |
| DEMO-FAM-LEDGER-RECON (SANDBOX) | demo_recon_job.py | banksy-sandbox-repo / services/demo-ledger-recon | ledger | Ledger / Safeguarding Engineer | medium | Synthetic reconciliation job over DemoLedger; sandbox only. Remove before real inventory. |
| DEMO-FAM-GATEWAY-EDGE (SANDBOX) | demo_gateway_edge.py; sandbox_ratelimit.yaml | banksy-sandbox-repo / services/demo-gateway-edge | gateway | Gateway / Web Engineer | high | Synthetic gateway edge with sandbox rate-limit config; no real routes. Remove before real inventory. |
| DEMO-FAM-PAYMENTS-STUB (SANDBOX) | demo_payments_router.py; sandbox_card_tokenizer.py | banksy-sandbox-repo / services/demo-payments-router | payments | Payments Lane Engineer | medium | Synthetic payments router; sandbox-only flows, no live cards. Remove before real inventory. |
| DEMO-FAM-PAYOUT-BATCH (SANDBOX) | demo_payout_batch.py | banksy-sandbox-repo / services/demo-payout-batch | payments | Payments Lane Engineer | high | Synthetic batch payout worker; sandbox only, no real beneficiaries. Remove before real inventory. |
| DEMO-FAM-REPORTING-VIEW (SANDBOX) | demo_report_builder.py | banksy-sandbox-repo / services/demo-reporting-view | other | Reporting / Analytics Engineer | low | Synthetic read-only reporting view over demo data; sandbox only. Remove before real inventory. |
| DEMO-FAM-ANALYTICS-SIDECAR (SANDBOX) | demo_analytics_sidecar.py | banksy-sandbox-repo / services/demo-analytics-sidecar | other | Reporting / Analytics Engineer | low | Synthetic analytics sidecar; sandbox only, no real metrics. Remove before real inventory. |
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

Templates; do not fill with real data here. Each type below shows one **SANDBOX / DEMO** example (synthetic, sandbox artefacts only) followed by the blank template to fill for real work.

**Architecture evidence**
- Example (SANDBOX): Evidence ID `DEMO-ARCH-LEDGER-FLOW-001` — Diagram of sandbox Midaz→LedgerPort→LedgerAgent→DemoLedger flow. Source: `docs/sandbox/diagrams/demo-ledger-flow.png`.
- [ ] Evidence ID:
- [ ] Description:
- [ ] Source (diagram / config / text):

**Configuration evidence**
- Example (SANDBOX): Evidence ID `DEMO-CONF-LEDGER-CREDS-001` — Redacted sandbox config showing only LedgerPort/LedgerAgent hold write credentials to `ledger.demo.local`; MCP adapter is read-only. Source: `docs/sandbox/config/demo-ledger-acl.redacted.yaml`.
- [ ] Evidence ID:
- [ ] Description:
- [ ] Source (file / path / redacted snippet):

**Code-path evidence**
- Example (SANDBOX): Evidence ID `DEMO-CODE-MIDAZ-PATH-001` — `sandbox_mcp_adapter` calls `LedgerPort.post_journal_entry()`, never the DemoLedger store directly. Module ref: `services/demo-ledger-sidecar/sandbox_mcp_adapter.py`.
- [ ] Evidence ID:
- [ ] Description:
- [ ] Module / method reference:

**Operational evidence**
- Example (SANDBOX): Evidence ID `DEMO-OPS-WRITE-TRACE-001` — Sandbox log sample for one demo write event traced back through LedgerAgent with a demo HITL approval record. Source: `docs/sandbox/logs/demo-ledger-write-trace.log`.
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

**Canon 1 (SANDBOX DEMO)** — synthetic example only; not a real finding.
- Canon statement: No second ledger in Banksy sandbox — only DemoLedger as authoritative store.
- Classification: Confirmed
- Evidence refs: DEMO-ARCH-LEDGER-FLOW-001
- Impact level: low
- Self-repair permitted: yes (keep sandbox single-ledger); no impact on real bank
- Notes: sandbox-only; real multi-ledger questions reserved for future design.

**Canon 2**
- Canon statement: No direct MCP→ledger writes — Midaz/MCP components cannot write directly to the ledger datastore.
- Classification: Confirmed / Confirmed-with-caveats / Not proven / Broken
- Evidence refs:
- Impact level: low / medium / high
- Self-repair permitted: yes (config-hardening, adding checks) / no — design change required (project brain)
- Notes:

**Canon 2 (SANDBOX DEMO)** — synthetic example only; not a real finding.
- Canon statement: No direct MCP→ledger writes in Banksy sandbox.
- Classification: Confirmed-with-caveats
- Evidence refs: DEMO-ARCH-LEDGER-FLOW-001; DEMO-CONF-LEDGER-CREDS-001; DEMO-CODE-MIDAZ-PATH-001
- Impact level: medium
- Self-repair permitted: yes (tighten sandbox config); no impact on real bank
- Notes: sandbox-only verification; real EMI/ledger to be treated separately under future install-audits.

**Canon 3**
- Canon statement: All writes via LedgerPort + LedgerAgent under HITL, with append-only and decision-trace constraints.
- Classification: Confirmed / Confirmed-with-caveats / Not proven / Broken
- Evidence refs:
- Impact level: low / medium / high
- Self-repair permitted: yes (config-hardening, adding checks) / no — design change required (project brain)
- Notes:

**Canon 3 (SANDBOX DEMO)** — synthetic example only; not a real finding.
- Canon statement: All writes via LedgerPort + LedgerAgent under HITL in Banksy sandbox.
- Classification: Not proven
- Evidence refs: DEMO-OPS-WRITE-TRACE-001
- Impact level: medium
- Self-repair permitted: yes (add missing sandbox traces); no impact on real bank
- Notes: sandbox gap; shows how "Not proven" should be handled — escalate and collect more evidence before any real migration, never assume pass.

### B3. Execution notes

- Operators read configs and code only — never change them under this checklist.
- Any suspected "Broken" finding is escalated, not quietly fixed.
- Evidence IDs are stable and reused as references in the LEDGER-EMI install-audit later.

## Boundaries and safety

- No code move, refactor, or deploy under this checklist.
- No governance changes; the Phase-1 roadmap stays frozen.
- HITL mandatory for every classification.
- Any remediation goes into a separate repair plan (S-GATE-REPAIR / S-A6), not here.
