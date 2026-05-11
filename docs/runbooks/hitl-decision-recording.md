# Runbook: HITL Decision Recording
# Document ID: RB-HITL-001
# Created: 2026-05-11 | Authority: Sub-terminal A (Claude Code)
# Version: 1.0 | Status: ACTIVE
# Canon: SESSION-CANON-2026-05-11
# Related policy: docs/policies/hitl-l3-agent-gate-2026-05-11.md

---

## Purpose

This runbook provides the operational procedure for recording HITL gate outcomes. It
defines the exact format of ASK blocks, operator response templates, audit file
structure, and retention obligations. Operators and agents MUST follow this runbook
whenever an L3 gate event occurs.

---

## 1. When This Runbook Applies

Use this runbook whenever:

- An agent emits an L3 HITL gate ASK block (see policy §3.2)
- An operator approves or denies an L3 gate request
- A gate TIMEOUT occurs (5 minutes without operator response)
- A gate audit record needs to be reviewed or exported for FCA evidence

---

## 2. ASK Block -- Agent Procedure

The agent emits the following before any L3 action. All fields are mandatory.

```
+==================================================================+
|  HITL GATE -- L3 ACTION REQUIRES APPROVAL                       |
+==================================================================+
|  Action ID:    HITL-<YYYYMMDD>-<NNN>                            |
|  Agent:        <agent-name or "sub-terminal-A">                 |
|  Timestamp:    <UTC ISO-8601, e.g. 2026-05-11T14:32:07Z>        |
|  Target:       <host:port or service name or file path>         |
|  Action:       <exact shell command or operation description>    |
|  Rationale:    <one sentence explaining why this is needed now>  |
|  Reversible:   <Yes/No -- revert command if Yes>                 |
|  Blast radius: <what breaks or degrades if this goes wrong>      |
|  Invariants:   <comma-separated I-xx codes, e.g. I-27, I-71>    |
+==================================================================+
|  APPROVE: reply "yes, execute"                                  |
|  DENY:    reply "no"                                            |
|  Timeout: 5 minutes from timestamp above                        |
+==================================================================+
```

**Numbering:** Action IDs are sequential within a session (HITL-20260511-001,
HITL-20260511-002, etc.) and must be unique within the audit file.

---

## 3. Operator Response Templates

### 3.1 Approve

The operator sends one of:

```
yes, execute
```

or approves the pending tool call in the Claude Code UI.

For multi-step actions the operator may add context:

```
yes, execute — backup confirmed at ~/litellm-config.yaml.bak-20260511
```

The verbatim response (everything after `yes, execute`) is recorded in the audit
record `ocat_received` field.

### 3.2 Deny

```
no
```

or deny the tool call in the Claude Code UI.

Optional reason (recorded verbatim):

```
no — wait for CTIO sign-off on evo2 changes
```

### 3.3 Timeout

If no response is received within 5 minutes of the ASK timestamp, the agent:
1. Records `outcome: TIMEOUT` in the audit file
2. Continues with L0 read-only work only
3. Re-emits the ASK in the session summary for human review

The operator does NOT need to take any action for a timeout -- the agent handles it.

---

## 4. Audit File Format

### 4.1 File Location and Naming

```
~/.claude/hitl-audit/
  2026-05-11.jsonl        -- one file per calendar day (UTC)
  2026-05-12.jsonl
  ...
```

Each line is a single JSON object (JSON Lines format). Files are append-only.
Never truncate, overwrite, or delete these files.

### 4.2 Record Schema

```json
{
  "gate_id": "HITL-20260511-001",
  "timestamp_utc": "2026-05-11T14:32:07Z",
  "session_id": "<claude-session-uuid or sub-terminal label>",
  "agent": "sub-terminal-A",
  "action": "cp /tmp/hitl-l3-agent-gate-2026-05-11.md /home/mmber/banxe-architecture-part7-hitl-2026-05-11/docs/policies/",
  "target": "/home/mmber/banxe-architecture-part7-hitl-2026-05-11",
  "outcome": "APPROVED",
  "operator": "mmber",
  "ocat_received": "yes, execute",
  "ocat_timestamp_utc": "2026-05-11T14:32:19Z",
  "invariants": ["I-27", "I-71"],
  "reversible": true,
  "revert_command": "git -C /path/to/worktree checkout -- docs/policies/",
  "follow_up": "commit SHA abc1234 or null",
  "notes": "optional free text"
}
```

**Required fields:** `gate_id`, `timestamp_utc`, `agent`, `action`, `target`,
`outcome`, `invariants`.

**Conditional fields:**
- `ocat_received`: required if `outcome == APPROVED`
- `ocat_timestamp_utc`: required if `outcome == APPROVED`
- `revert_command`: required if `reversible == true`

### 4.3 Writing the Record

After operator response (or timeout):

```bash
# Create audit directory if not present
mkdir -p ~/.claude/hitl-audit/

# Append record (one-liner; replace values)
echo '{"gate_id":"HITL-20260511-001","timestamp_utc":"2026-05-11T14:32:07Z",...}' \
  >> ~/.claude/hitl-audit/2026-05-11.jsonl
```

The record MUST be written **before** executing the approved action. If the write
fails, the action is not taken until the write succeeds.

---

## 5. ClickHouse Sync (Compliance-Classified Actions)

For actions involving AML, KYC, sanctions, SAR, or ledger writes, the same record
must also be inserted into ClickHouse:

```sql
INSERT INTO hitl_decisions (
  gate_id, timestamp_utc, session_id, agent, action, target,
  outcome, operator, ocat_received, invariants, follow_up
) VALUES (
  'HITL-20260511-001', '2026-05-11T14:32:07Z', ...
);
```

Table DDL (reference):

```sql
CREATE TABLE IF NOT EXISTS hitl_decisions (
  gate_id       String,
  timestamp_utc DateTime,
  session_id    String,
  agent         String,
  action        String,
  target        String,
  outcome       Enum8('APPROVED'=1, 'DENIED'=2, 'TIMEOUT'=3),
  operator      String,
  ocat_received Nullable(String),
  invariants    Array(String),
  follow_up     Nullable(String)
)
ENGINE = MergeTree
ORDER BY (timestamp_utc, gate_id)
TTL timestamp_utc + INTERVAL 5 YEAR;
```

The TTL MUST NOT be set below 5 years (I-08).

---

## 6. Reviewing and Exporting Records

### 6.1 List Today's Gates

```bash
cat ~/.claude/hitl-audit/$(date -u +%Y-%m-%d).jsonl | python3 -m json.tool --no-ensure-ascii | grep -E '"gate_id"|"outcome"|"action"'
```

### 6.2 Count by Outcome

```bash
python3 - << 'EOF'
import json, glob, collections
results = collections.Counter()
for f in sorted(glob.glob(os.path.expanduser('~/.claude/hitl-audit/*.jsonl'))):
    for line in open(f):
        results[json.loads(line).get('outcome','UNKNOWN')] += 1
print(dict(results))
EOF
```

### 6.3 Export for FCA Evidence

For regulatory requests, export all records for a given period:

```bash
python3 -c "
import json, glob, sys
start, end = sys.argv[1], sys.argv[2]  # YYYY-MM-DD
records = []
for f in glob.glob(os.path.expanduser('~/.claude/hitl-audit/*.jsonl')):
    date = f.split('/')[-1].replace('.jsonl','')
    if start <= date <= end:
        for line in open(f):
            records.append(json.loads(line))
json.dump(records, sys.stdout, indent=2, default=str)
" 2026-01-01 2026-12-31 > hitl-export-2026.json
```

---

## 7. Retention and Deletion Policy

| Requirement | Value |
|------------|-------|
| Minimum retention | 5 years from record creation date |
| Deletion authority | CFO + MLRO joint sign-off |
| Backup | Daily rsync to evo1 `~/banxe-dev/hitl-audit-backup/` |
| Tamper detection | `sha256sum ~/.claude/hitl-audit/*.jsonl` recorded weekly |
| ClickHouse TTL | `TTL timestamp_utc + INTERVAL 5 YEAR` (cannot be reduced) |

**Prohibited actions (without CFO + MLRO sign-off):**
- Deleting any `.jsonl` file in `~/.claude/hitl-audit/`
- Truncating any line from a `.jsonl` file
- Altering any `outcome`, `ocat_received`, or `gate_id` field
- Reducing the ClickHouse TTL on `hitl_decisions`

Violations of this retention policy are a breach of I-24 (append-only audit trails)
and FCA CASS 15 record-keeping requirements.

---

## 8. Quick Reference

```
L3 action detected?
  -> Emit ASK block (§2)
  -> Wait for OCAT (§3)
  -> Write audit record BEFORE executing (§4.3)
  -> Execute if APPROVED, abort if DENIED/TIMEOUT
  -> ClickHouse sync if compliance-classified (§5)
```

---

## Document History

| Version | Date | Author | Change |
|---------|------|--------|--------|
| 1.0 | 2026-05-11 | Sub-terminal A | Initial runbook (ADR-035 Step 10) |

## References

- Policy: `docs/policies/hitl-l3-agent-gate-2026-05-11.md`
- Services: `services/hitl/hitl_service.py`
- Invariants: I-24, I-27, I-71, I-72
- FCA: CASS 15, PS25/12
- EU AI Act: Article 14
