# Evidence Pack (P5) Schema v1.0

Per Software Factory Canon Section 9.

## Required fields
| Field | Type | Source |
|-------|------|--------|
| pack_id | UUID | auto-generated |
| timestamp | ISO8601 | auto |
| instruction_ref | string | P1 (IL entry ID) |
| execution_log | string | P2 (Aider session log ref) |
| evaluation_verdict | PASS/WARN/BLOCK | P3 (evaluate.sh output) |
| guardian_audit_id | UUID | P4 (Guardian ClickHouse row) |
| ruflo_checkpoint_id | UUID | Ruflo checkpoint record |
| final_verdict | APPROVED/REJECTED | from Ruflo |
| signer | string | gate authority |
| branch | string | git branch name |
| commit_sha | string | git commit hash |
| pr_number | int | GitHub PR number |
| files_changed | list[string] | git diff --name-only |
| test_results | string | pytest summary |
| ruff_results | string | ruff output |

## Optional fields
| Field | Type | Notes |
|-------|------|-------|
| promptfoo_results | JSON | if --promptfoo flag used |
| canon_judge_verdict | string | audit-mode output |
| notes | string | reviewer comments |

## Format
Markdown file + companion JSON sidecar for machine parsing.
Stored in: `docs/evidence-packs/YYYY-MM-DD-<pack_id>.md`
