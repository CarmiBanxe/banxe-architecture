# Banksy Phase-2 Code Migration — Sandbox Dry-Run Training Report

**PHASE-2 EXECUTION / DRY-RUN TRAINING REPORT / SANDBOX-ONLY / NO CODE MOVE**

## Purpose

- Describes a dry-run, table-top simulation of the Phase-2 migration processes.
- Uses only sandbox artefacts — DEMO families, the S-A6 verification log, and the S-PILOT DEMO reporting-view pilot.
- Is training material for operators and architects, not an execution log.
- No real code, config, infrastructure, or data is touched.

## Artefacts used in the dry run

All references are to synthetic, sandbox content.

- **Phase-2 Master Code Migration Roadmap** (`PHASE2-MASTER-CODE-MIGRATION-ROADMAP-AND-VERIFICATION-GATES-2026-07-20.md`) — the phases A–E and the five verification gates.
- **Phase-2 Phase-A + S-A6 verification checklist** (`PHASE2-PHASE-A-AND-S-A6-VERIFICATION-EXECUTION-CHECKLIST-2026-07-20.md`) — the inventory table and S-A6 evidence/findings log, populated with DEMO families and DEMO findings.
- **S-PILOT sandbox migration sprint** (`S-PILOT-CODE-MIGRATION-SANDBOX-DEMO-REPORTING-VIEW-2026-07-20.md`) — the sandbox pilot for DEMO-FAM-REPORTING-VIEW.

## Training scenario overview

Operators and architects gather for a short workshop (a couple of hours) around the three sandbox artefacts. They work through Phase A inventory using the DEMO families, then practise S-A6 verification classifications on the DEMO evidence, and finally walk through the S-PILOT migration steps for DEMO-FAM-REPORTING-VIEW. The whole session is a paper exercise: nobody runs code, moves files, or touches any environment. The aim is fluency with the pattern — inventory, verify, gate, migrate, roll back, audit — before any of it is applied to something real.

## Phase A — inventory training flow

1. Review the inventory scope and the DEMO families across all lanes (identity, ledger, gateway, payments, other).
2. Ask participants to classify one or two DEMO families (lane, owner role, risk level) as if they were real.
3. Discuss why some families are high-risk (KYB stub, gateway edge, payout batch — identity/consent or value-bearing) versus low-risk (reporting view, analytics sidecar — read-only).
4. Emphasise the sandbox markings and the rule that DEMO rows must be deleted before real inventory begins.
5. Capture participant questions on how real families would be discovered and grouped into Family IDs.
6. Confirm the Phase A exit gate: every family in the table with a lane candidate and an owner.
7. Summarise lessons learned for future real Phase A execution.

## S-A6 verification — findings training flow

- Participants review the DEMO evidence IDs (DEMO-ARCH-LEDGER-FLOW-001, DEMO-CONF-LEDGER-CREDS-001, DEMO-CODE-MIDAZ-PATH-001, DEMO-OPS-WRITE-TRACE-001) and see how each evidence type is recorded.
- They practise filling the findings blocks for Canon 1–3 on the synthetic data.
- They compare the three worked DEMO outcomes: Canon 1 "Confirmed", Canon 2 "Confirmed-with-caveats", Canon 3 "Not proven".
- They discuss what each classification would mean in a real ledger context, and how caveats must be written down, not glossed over.
- They rehearse the core rule: "Broken or Not proven → escalate and route to a repair plan, never treat as a gate pass".
- They note that evidence IDs are stable and reused later as references in the LEDGER-EMI install-audit.

## S-PILOT sprint — migration pattern training

- Walk through the pilot family description (DEMO-FAM-REPORTING-VIEW, lane "other", risk low, read-only) and the sandbox migration plan.
- Step through the 11 hypothetical execution steps, from confirming inventory presence to logging pilot assumptions.
- Discuss how the audit-evidence gate and the rollback readiness gate apply even to a low-risk component.
- Highlight why the ledger, identity, and gateway gates are out of scope here — the pilot touches none of those lanes.
- Reflect on how the same pattern would scale to real low-risk code in a future sprint, and where extra gates would switch on for higher-risk lanes.

## Key training messages

- Migration is phased and gated, not "big bang".
- Verification and evidence come before any real code move.
- Sandbox DEMO artefacts are for training only and must be removed before real work.
- High-risk lanes (identity, ledger, gateway, payments) demand HITL and stricter gates.
- Rollback planning is mandatory even for low-risk components.
- "Not proven" and "Broken" are escalation signals, never silent passes.
- Evidence IDs must be stable so findings can be traced through to install-audits.
- Phase-1 governance remains frozen; Phase-2 execution must respect it.

## Boundaries and next steps

- This dry run changed no system, config, or data — it was entirely a table-top exercise on sandbox artefacts.
- Future sessions can repeat the training with new DEMO families if broader coverage is wanted.
- Real migration sprints will begin only after governance, verification, and training are all in place and approved — and even then, only lane by lane, gated, under HITL.
