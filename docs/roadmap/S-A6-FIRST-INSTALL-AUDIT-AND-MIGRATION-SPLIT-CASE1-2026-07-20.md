> ⚠ TRAINING DATA — SANDBOX — NOT FOR PRODUCTION

# S-A6 First Install-Audit and Migration Split — Case 1 (Ledger / EMI)

**PHASE-2 EXECUTION / S-A6 LEDGER/EMI INSTALL-AUDIT CASE1 / SANDBOX-FIRST / NO CODE MOVE**

## 1) Purpose & scope

- S-A6 Case1 is the first real install-audit for the ledger/EMI lane, using the existing S-A6 canon.
- It deliberately separates "audit" (S-A6) from "code migration" (later S-GATE-REPAIR / S-A7 and beyond).
- It consumes shell-audit outputs and the Phase-2 artefacts: the master roadmap, the Phase-A + S-A6 checklist, the S-A6 verification log, the S-PILOT sprint, and the dry-run training report.
- It defines what operators must prove before any ledger-related code is allowed to move "from basement to rooms".
- It stays in sandbox-first / paper mode: no deploy, no refactor, no direct DB writes — read-only audit only.

## 2) Canon recap (for S-A6)

The three canon statements under audit; Case1 is about EVIDENCE and FINDINGS, not remediation.

- **No second ledger** — only one authoritative GL/ledger instance for financial records. (Case1: gather evidence and classify, do not consolidate.)
- **No direct MCP→ledger writes** — Midaz/MCP components cannot write directly to the ledger datastore. (Case1: prove or disprove via evidence, do not re-wire.)
- **All writes via LedgerPort + LedgerAgent under HITL** — with append-only and decision-trace constraints. (Case1: sample and classify, do not add gates.)

## 3) Pre-sprint prerequisites (already done)

- Phase-1 governance roadmap frozen (Sprints 3–9 + S-GATE-REPAIR + A-chain).
- S-A5 identity install-audits complete (A-IDV / A-KYC / A-KYB).
- Phase-2 Master Code Migration Roadmap and its five verification gates documented.
- Phase-2 Phase-A + S-A6 checklist populated with DEMO families and DEMO findings (training material).
- S-PILOT sandbox pilot and the dry-run training report executed as training only — no code moves.

## 4) Shell-audit preparation for Case1 (read-only)

Before any S-A6 evidence is collected, shell-audit scopes the ground. Patterns and constraints only — operators run the commands, factory prepares them.

- **Identify basement ledger/EMI trees:** determine which repos/dirs count as basement ledger/EMI code (e.g. `banxe-emi-stack/services/ledger`, EMI-core modules, ledger-adjacent sidecars).
- **Per tree, 1–2 read-only patterns** to locate:
  - ledger store modules (where the authoritative ledger lives);
  - MCP / agent integration points (candidates for a direct-write risk);
  - LedgerPort / LedgerAgent adapters (the sanctioned path);
  - any direct DB write path (the thing Canon 2 forbids).
- **File-names only:** every grep uses `-l` (names, not bodies); no config dumps, no secrets, no credential values printed.
- **One question → one command:** each pattern answers a single question and is small enough to review by eye.
- Actual commands are not written here — this sprint fixes the method; the operator composes and runs the scoped read-only commands.

## 5) Sprint steps (Case1 install-audit)

Method only; execution is human + shell + the existing logs.

1. Confirm the S-A6 scope and the three canon statements.
2. Run shell-audit over the basement ledger/EMI trees (operators, read-only).
3. Build a Phase-2 inventory excerpt for ledger/EMI families (Family IDs, lane, owner, risk) using the Phase-A template.
4. Map discovered components to the S-A6 evidence log (architecture / config / code-path / ops evidence IDs).
5. Populate initial findings for Canon 1–3 (each: Confirmed / Confirmed-with-caveats / Not proven / Broken).
6. Classify the impact level of each finding (low / medium / high) in the ledger lane.
7. Decide, per finding, whether self-repair is permitted or a design change is required (routing to S-GATE-REPAIR / S-A7).
8. Record HITL decisions (who signed off, when, on which evidence IDs).
9. Update the S-A6 verification sprint artefact with references to this Case1 audit.
10. Prepare a short install-audit summary for LEDGER-EMI (for the future install-audit pack).
11. Cross-check that no evidence item leaked secrets or full configs; redact if needed.
12. Confirm every "Broken" / "Not proven" finding has a backlog entry, not a quick fix.

## 6) Split between audit and migration (critical)

- This S-A6 Case1 sprint ONLY audits and classifies; it does not move any code.
- Every "Broken" / "Not proven" finding becomes an entry in the S-GATE-REPAIR / S-A7 backlog — never a quick fix inside this sprint.
- Future migration sprints will:
  - pick low-risk families first (e.g. reporting / analytics);
  - reuse the S-PILOT pattern (plan → gates → rollback → post-audit);
  - stay gated, lane by lane.
- Ledger/EMI code moves require, together:
  - S-A6 findings satisfactory;
  - repair-backlog items addressed;
  - explicit HITL approvals.

## 7) Outputs / artefacts of S-A6 Case1

Documents only — no code, no DB changes.

- Updated S-A6 verification log (real evidence IDs, real findings).
- Phase-2 inventory update (ledger/EMI families discovered from the basement).
- Case1 install-audit summary (short memo).
- Updated backlog entries for S-GATE-REPAIR / S-A7 (the Broken / Not proven items).
- Explicit confirmation that no code or DB change was made.

## 8) Boundaries and safety

- No direct ledger DB access beyond read-only audit, and only where permitted.
- No code move, refactor, or deploy in this sprint.
- No production environment changes.
- No legal/compliance assertions — all such matters remain [counsel].
- HITL mandatory for every classification and every backlog entry.
