# CANON — Single Audit Script
# Status: BINDING (operator-ratified 2026-07-11)
# Additive to: CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md
# I-24: audit output is append-only evidence. SESSION-STATE.md is updated from audit results.

## Problem This Solves

Ad-hoc audits are reconstructed from memory each session. Different sessions run different
subsets of checks, produce different output formats, and rely on screen output that gets
truncated or discarded. Audits conducted this way cannot be cross-referenced reliably and
create "audit theatre" — the appearance of verification without reproducible evidence.

Two concrete failure modes observed:
- A section is checked with `| head -5` and a critical line appears at line 6.
- A long governance doc is searched with grep instead of read, and methodology context is missed.

## Rule

**All read-only system audits MUST run through one canonical script:**

```
tools/audit/full-audit.sh
```

### Mandatory invariants

| # | Invariant | Rationale |
|---|-----------|-----------|
| 1 | ONE script, fixed checklist | No per-session reconstruction; reproducible across all terminals |
| 2 | Full output written to file | `/tmp/full-audit-<UTC>.txt` — never truncated |
| 3 | No `\| head` on fact-bearing sections in the saved file | A critical datum on line 6 must not be silently discarded |
| 4 | Screen summary is allowed to be compact | Summary trims; the file does not |
| 5 | Long governance docs read fully when methodology matters | grep-fragments miss context; full read is mandatory for docs over 30 lines |
| 6 | Script is READ-ONLY | No writes, no restarts, no installs, no git mutations |
| 7 | One section failure MUST NOT abort the script | Every section uses `|| echo UNREACHABLE` / `|| true` |
| 8 | Output file path printed at end | Operator can open the file if the summary is insufficient |

### What counts as "a read-only audit"

- Hardware state (CPU, RAM, GPU, disk)
- Port / service liveness checks
- LiteLLM / Ollama model lists
- Git repo state (branch, SHA, ahead/behind, dirty files, open PRs)
- Worktree list
- Systemd service states
- SESSION-STATE.md TRACK BOARD read-out

### What does NOT go through full-audit.sh

- Application-layer functional tests (those go through pytest / Vitest)
- Security scans (Semgrep, ruff — those have their own gates in quality-gate.sh)
- Database migrations or schema checks
- Any write operation

## Usage

```bash
bash tools/audit/full-audit.sh
# Full output → /tmp/full-audit-<UTC>.txt
# Summary → stdout (compact)
# At end: "FULL OUTPUT: /tmp/full-audit-<UTC>.txt"
```

Operator opens the file for any section that needs deeper inspection. Do NOT re-run
the audit to see a different section — the file already contains everything.

## Maintenance

When a new check is needed permanently, add it to `full-audit.sh` as a labeled section.
Do NOT run it ad-hoc first and "add it later". The canon is: it goes in the script or it
does not count as an audited fact.

When a check becomes irrelevant (a service is decommissioned), mark the section
`# INACTIVE — <reason>` and leave it in place. Never silently remove checks —
a missing section is indistinguishable from "not checked" in historical output files.

## Relationship to Other Canons

| Canon | Relationship |
|-------|-------------|
| CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md | Audit results from full-audit.sh ARE the authoritative source that overwrites operator memory or prior session state in SESSION-STATE.md |
| CANON-LEDGER-EVENT-AFTER-BLOCK.md | After running full-audit.sh and updating SESSION-STATE.md, append one ledger event to `ledger/entries/<track>/<date>.log` |
| CANON-PARALLEL-ORCHESTRATION.md | full-audit.sh may be triggered at session start for any track that needs current system state |

## Output File Convention

```
/tmp/full-audit-20260711T120000Z.txt
```

Files in `/tmp` are ephemeral. If the audit result must survive a reboot, the operator
copies the relevant sections to `docs/governance/SESSION-STATE.md` or a findings file.
The script itself never copies — that is an operator action (I-71).

## References

- Script: `tools/audit/full-audit.sh`
- Session memory: `docs/governance/SESSION-STATE.md`
- Memory-first canon: `docs/governance/CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md`
- Ledger canon: `docs/governance/CANON-LEDGER-EVENT-AFTER-BLOCK.md`
- I-71 single-writer: operator executes, copies results; factory proposes
- I-24: audit evidence is append-only; output files are never edited after creation
