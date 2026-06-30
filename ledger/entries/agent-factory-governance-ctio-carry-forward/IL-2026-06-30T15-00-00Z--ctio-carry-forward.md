---
il_ts: 2026-06-30T15:00:00Z
session_id: agent-factory-governance-ctio-carry-forward
source: CEO
status: DONE
---
### CTIO Carry-Forward — operator-owned privileged/irreversible/external operations registry (line 3 of 7)
- **Decision:** Authored `docs/governance/CTIO-CARRY-FORWARD.md` — registry of operation classes whose owner is strictly the Operator: privileged/sudo; deletions; external key/address binding (e.g. ODR-1 DeFi keys); webhook config; GitHub App operations; permission/access changes; financial/client-fund; any other irreversible/privileged action. Each class `owner: Operator`. Binding rule: terminals NEVER execute autonomously — they prepare the exact command, the operator executes; no working-around a missing privilege. Eliminates the recurring "didn't work without sudo" / needs-operator-hands situations seen across the session. **PREPARE-ONLY**, Draft PR.
- **Anti-dup (ADR-102) — pointer-first, no restatement:** references existing canon — ADR-135 (HITL gate); approval-rules.md §"Требует подтверждения CEO" (deletions/perms/financial); safety-rules.md (destructive verify-step + forbidden list); parallel-session-isolation Rule 7 + ADR-121 (foreign/destructive); HITL-MATRIX.yaml + agents.md HITL BUG-007; CLAUDE.md §1/§11 (governance/production-mutation gates); AGENTS.md §Central Terminal (read-only diagnostics; production via factory; single-writer). Complements TERMINAL-OWNERSHIP (zones, line 1) + ADR-154 (arbitration, line 2).
- **[НЕИЗВЕСТНО] (not invented):** enforce-as-CI-gate vs advisory registry = operator decision; exhaustive external-key/webhook/GitHub-App endpoint list = filled as encountered.
- **Scope/flow:** authored per #900 — doc + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL (build_ledger mints). ONE doc + this shard; 0 off-scope.
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 749) → IL-750 via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-06-30T15:00:00Z` > main max `2026-06-30T14:00:00Z`. Fresh worktree off origin/main `830f3d5` (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — registry doc + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Line 3 of 7; sequential-to-completion.**
- **Refs:** `docs/governance/CTIO-CARRY-FORWARD.md`; ADR-135/121; approval-rules.md; safety-rules.md; parallel-session-isolation; HITL-MATRIX.yaml; agents.md; CLAUDE.md §1/§11; AGENTS.md; TERMINAL-OWNERSHIP.md; ADR-154; ADR-102/119/143/144. Operator directive 2026-06-30.
