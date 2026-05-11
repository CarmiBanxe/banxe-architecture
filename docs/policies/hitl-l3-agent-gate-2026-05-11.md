# HITL L3 Agent Gate Policy
# Document ID: POLICY-HITL-001
# Created: 2026-05-11 | Authority: Sub-terminal A (Claude Code)
# Version: 1.0 | Status: ACTIVE
# Canon: SESSION-CANON-2026-05-11

---

## 1. Scope and Definitions

### 1.1 Scope

This policy governs the Human-In-The-Loop (HITL) gate applied to all AI agent decisions
at autonomy Level 3 (L3) and above within the Banxe AI Bank platform. It applies to:

- All agents defined in `agents/compliance/` and `.claude/agents/`
- All MCP tools in `banxe_mcp/server.py` that mutate financial or compliance state
- All Claude Code sub-terminal sessions operating under SESSION-CANON authority
- The LiteLLM routing layer when acting on behalf of compliance-classified requests

This policy does **not** apply to read-only operations (GET/query), in-memory test stubs,
or L0/L1 operations explicitly listed in §2.

### 1.2 Definitions

| Term | Definition |
|------|-----------|
| **HITL** | Human-In-The-Loop — a checkpoint requiring explicit human approval before an AI agent may proceed |
| **Gate** | A synchronous decision point: agent PROPOSES, human APPROVES or DENIES, agent RECORDS outcome |
| **Proposal** | A structured description of the intended action, its rationale, and expected consequences |
| **Audit record** | An append-only entry in `~/.claude/hitl-audit/` or ClickHouse `hitl_decisions` table |
| **Sub-terminal** | Claude Code instance operating under SESSION-CANON (CANON §II) |
| **OCAT** | Operator-Confirmed Action Token — the string `yes, execute` or equivalent from the operator |
| **Autonomy level** | A scalar 0–3 indicating the degree of autonomous action permitted (see §2) |

---

## 2. Autonomy Levels

### L0 — Read Only

**Permitted:** Query, inspect, list, read, verify, measure.
**Prohibited:** Any mutation of state — files, configs, DB, APIs.
**HITL gate:** Not applicable.
**Examples:** `tailscale status`, read file, `GET /api/tags`, `git status`.

### L1 — Local Reversible Write

**Permitted:** Writes to local worktree files; staging changes; running lint/tests.
**Prohibited:** Commits, pushes, remote API calls, system service restarts.
**HITL gate:** Not required. Agent acts immediately.
**Examples:** Write markdown file to worktree, run `ruff check .`, write to `/tmp/`.
**Revert path:** `git checkout -- <file>` or `git clean -fd`.

### L2 — Local Irreversible or Shared-State Write

**Permitted:** Commits to local branch; live config edits on Legion (with backup);
service restarts on Legion; `cp` from `/tmp/` to worktree.
**Prohibited:** Push to remote; PR creation; writes to evo1/evo2; secret mutation.
**HITL gate:** Operator confirmation required before execution. Gate mechanism in §3.
**Examples:** `git commit`, editing `~/litellm-config.yaml` (with backup), `systemctl --user restart litellm`.
**Evidence required:** Backup path, diff summary, affected service name.

### L3 — Remote or Compliance-Critical Write

**Permitted:** Only after explicit OCAT from operator.
**Applies to:**
- Any write to evo1 or evo2 (SSH, config, `ollama rm`, service change)
- Any schema change (Alembic migration execution)
- AML/KYC threshold changes
- SAR filing, sanctions override
- Secret rotation (Redis password, API key)
- Push to remote, PR creation or merge
- Any action on a `*prod*` environment

**HITL gate:** Mandatory, synchronous, non-bypassable. Gate mechanism in §3.
**Fallback:** On timeout or denial, agent returns to L0 and records the denial.

> **I-27 anchor:** "AI PROPOSES, human DECIDES. Never autonomous."
> L3 gates are the primary enforcement mechanism for I-27 in agent code.

---

## 3. HITL Gate Mechanism

### 3.1 Gate Lifecycle

```
+-----------------------------------------------------------------+
|                     HITL GATE LIFECYCLE                         |
|                                                                 |
|  1. DETECT          Agent classifies action as L3               |
|       |                                                         |
|  2. PROPOSE         Agent emits structured ASK block (§3.2)     |
|       |                                                         |
|  3. WAIT            Agent halts — no further action             |
|       |                                                         |
|  4. RECEIVE         Operator responds (OCAT or denial)          |
|       |                                                         |
|  5. RECORD          Gate outcome written to audit log (§3.4)    |
|       |                                                         |
|  6. BRANCH          -- APPROVED -> execute action               |
|                     +- DENIED   -> abort, document reason       |
+-----------------------------------------------------------------+
```

### 3.2 ASK Block Format

The agent MUST emit a structured ASK block before any L3 action:

```
+==================================================================+
|  HITL GATE -- L3 ACTION REQUIRES APPROVAL                       |
+==================================================================+
|  Action ID:    <UUID or sequential ID>                          |
|  Agent:        <agent name / sub-terminal ID>                   |
|  Timestamp:    <ISO-8601 UTC>                                   |
|  Target:       <system / host / service being acted upon>       |
|  Action:       <exact command or operation to be executed>      |
|  Rationale:    <why this action is required>                    |
|  Reversible:   <Yes/No -- and how if Yes>                       |
|  Blast radius: <what fails if this action goes wrong>           |
|  Invariants:   <which I-xx rules are engaged>                   |
+==================================================================+
|  APPROVE: reply "yes, execute" or confirm the tool call         |
|  DENY:    reply "no" or deny/reject the tool call               |
+==================================================================+
```

### 3.3 Operator Confirmation Tokens (OCAT)

An OCAT is any of the following explicit operator responses:

| Response form | Interpretation |
|--------------|---------------|
| `"yes, execute"` | APPROVED -- agent proceeds |
| `"yes"` (standalone) | APPROVED |
| Explicit tool-call approval via Claude Code UI | APPROVED |
| `"no"` | DENIED -- agent aborts |
| `"deny"` / `"reject"` | DENIED |
| Tool-call rejection via Claude Code UI | DENIED |
| No response within 5 minutes | TIMEOUT -> treated as DENIED |

**Silence is not OCAT.** An agent that proceeds without receiving an explicit OCAT is
in violation of I-27.

### 3.4 Audit Record Requirements

Every gate event (approved or denied) MUST be recorded. The record is append-only and
may NOT be modified or deleted after creation (I-24).

Minimum audit record fields:

```json
{
  "gate_id": "<uuid>",
  "timestamp_utc": "<ISO-8601>",
  "agent": "<agent-name>",
  "sub_terminal": "<session-id>",
  "action": "<description>",
  "target": "<host/service/path>",
  "outcome": "APPROVED | DENIED | TIMEOUT",
  "operator": "<operator identifier>",
  "ocat_received": "<verbatim response or null>",
  "invariants": ["I-27", "..."],
  "follow_up": "<commit SHA / ticket / null>"
}
```

Storage: `~/.claude/hitl-audit/YYYY-MM-DD.jsonl` (Legion-local, retained per §6).
For compliance-classified actions: also written to ClickHouse `hitl_decisions` table
with the same schema.

---

## 4. Concrete Examples -- L3 Gate Scenarios

### Example A: Writing to evo2 (remote node mutation)

**Trigger:** Agent needs to modify `~/.bashrc` on evo2 to persist an env var.

**Gate ASK:**
```
Action:       SSH to evo2 (100.99.208.21) and append OLLAMA_ORIGINS=* to ~/.bashrc
Target:       evo2 remote node
Reversible:   Yes -- remove appended line via SSH
Blast radius: evo2 Ollama service restart would pick up change; rollback trivial
Invariants:   I-71 (single-writer), SESSION-CANON Clause 8.1 (no evo writes without OCAT)
```

**Without OCAT:** Agent records DENIED/TIMEOUT, documents that the change did not occur,
and continues with L0/L1 work only.

---

### Example B: Executing an Alembic migration

**Trigger:** Agent runs `alembic upgrade head` on the production database.

**Gate ASK:**
```
Action:       alembic upgrade head -- apply pending migration 20260511_add_hitl_decisions_table
Target:       PostgreSQL prod (banxe-emi-stack)
Reversible:   Partial -- downgrade to previous revision with alembic downgrade -1
Blast radius: Live schema change; any running FastAPI pods re-reading schema may error
Invariants:   I-01 (Decimal), I-24 (audit trail), CLAUDE.md DB Rules (must ask)
```

**Without OCAT:** Agent halts, does NOT execute `alembic upgrade`, records DENIED,
and notes that migration is staged but not applied.

---

### Example C: Rotating the Redis password

**Trigger:** Security review requires `REDIS_PASS` to be rotated.

**Gate ASK:**
```
Action:       Generate new 48-char hex REDIS_PASS, update ~/banxe-dev/redis-evo1.env,
              update ~/litellm-config.yaml REDIS_PASS ref, restart redis container on
              evo1 and litellm.service on Legion
Target:       evo1 Redis container + Legion LiteLLM service
Reversible:   Yes -- previous .env backup retained for 24h
Blast radius: LiteLLM cache miss until restart propagates (~10s); Redis connection
              errors if rotation is partial
Invariants:   I-71, I-72, SESSION-CANON Clause 8.1 (evo1 write)
```

**Without OCAT:** Agent records DENIED, documents that old password remains active,
and creates a ticket-placeholder for main-terminal execution.

---

## 5. Mapping to Existing Controls

### 5.1 Invariant I-27

"AI PROPOSES, human DECIDES. Never autonomous."

L3 gates are the **primary runtime enforcement** of I-27 at the code level. The gate
mechanism in §3 operationalises this invariant: the agent emits a Proposal (§3.2) and
halts until an OCAT (§3.3) is received. No bypass path exists.

### 5.2 SESSION-CANON §II -- Sub-terminal Authority Boundary

SESSION-CANON Clause 8.1 defines the authority boundary for sub-terminals:

> "Sub-terminal A operates under T2 sandbox authority. Actions beyond T2 require
> explicit CTIO/operator confirmation."

L3 gate aligns directly: any action beyond T2 sandbox (evo1/evo2 writes, secret
mutation, remote push) triggers the gate before the action is taken. The OCAT
received from the operator constitutes the authority elevation from T2 to the
required level.

### 5.3 `settings.json` Deny Rules

`~/.claude/settings.json` enforces static deny rules at the tool-call level:

```json
{
  "deny": [
    "Read(/data/kyc/**)",
    "Read(/data/transactions/**)",
    "Read(/data/aml/**)"
  ]
}
```

These rules block tool calls entirely -- they are not HITL gates. They represent
**L0 read prohibitions** (the agent cannot even see the data). The HITL gate in §3
applies to *actions* (writes, commits, restarts) not blocked by static deny rules.

The two mechanisms are complementary:
- `settings.json` deny = hard block at tool layer (no proposal emitted)
- HITL L3 gate = proposal + human approval (agent proposes, operator decides)

### 5.4 OCAT (Operator-Confirmed Action Token)

OCAT is the mechanism by which an operator elevates a sub-terminal's authority for
a specific action. Each OCAT is:
- **Scoped:** applies to the single named action only
- **Single-use:** does not authorise subsequent actions of the same type
- **Recorded:** written to the audit log with the verbatim operator response

OCAT tokens are NOT stored or reused across sessions. Each session starts at T2
sandbox authority.

---

## 6. Failure Modes and Mitigations

| Failure mode | Effect | Mitigation |
|-------------|--------|-----------|
| Agent proceeds without OCAT | I-27 violation; audit trail missing | Gate is checked before every L3 tool call; no bypass path in code |
| Operator response is ambiguous | Agent cannot confirm OCAT | Ambiguous responses (e.g. "maybe") treated as DENIED; agent re-emits ASK |
| Audit write fails | Gate outcome not recorded | Agent halts the action even if approved; retries audit write; escalates to operator |
| HITL timeout (5 min) | Session stalls | Treated as DENIED; agent continues with L0 work and logs TIMEOUT |
| Gate emitted but operator distracted | Action not taken | Acceptable -- agent documents pending gate in session summary |
| Operator approves a DENIED action post-hoc | Cannot un-approve | New OCAT for new ASK required; original denial stands in audit log |

---

## 7. Compliance Hook -- FCA and EU AI Act

### 7.1 FCA CASS 15 / PS25/12

Safeguarding operations (balance reconciliation, FIN060 generation, ledger writes) that
are triggered by AI agents are classified L3. Every such operation requires a HITL gate.
The audit record (§3.4) provides evidence that human oversight occurred, satisfying the
FCA's expectation of human control over automated financial processes.

### 7.2 EU AI Act Article 14 -- Human Oversight

Article 14 requires that high-risk AI systems "allow for effective oversight by natural
persons." The HITL gate in §3 satisfies this requirement by:
- Requiring human decision at every L3+ action
- Producing an immutable audit record of each gate event
- Enforcing a timeout-as-denial policy (silence does not constitute approval)

### 7.3 MLR 2017 -- Suspicious Activity Reporting

SAR filing is a permanent L4 action (human only). The HITL gate enforces this by
classifying all SAR operations as L3+ with mandatory MLRO OCAT. No agent may file
a SAR autonomously.

### 7.4 Retention

Audit records in `~/.claude/hitl-audit/` and ClickHouse `hitl_decisions`:
- **Minimum retention:** 5 years from date of creation (I-08, FCA CASS 15)
- **Deletion:** Prohibited without CFO + MLRO sign-off (I-24)
- **ClickHouse TTL:** Must not be set below 5 years (`TTL event_time + INTERVAL 5 YEAR`)

---

## Document History

| Version | Date | Author | Change |
|---------|------|--------|--------|
| 1.0 | 2026-05-11 | Sub-terminal A | Initial policy (ADR-035 Step 10) |

## References

- `agents/compliance/swarm.yaml` -- agent roles and autonomy levels
- `services/hitl/hitl_service.py` -- HITL gate service implementation
- `.claude/rules/agent-authority.md` -- authority matrix
- `docs/runbooks/hitl-decision-recording.md` -- operational runbook for gate events
- CANON: `SESSION-CANON-2026-05-11`, Clauses 6, 8.1, 12
- Invariants: I-01, I-02, I-24, I-27, I-28, I-71..I-74
