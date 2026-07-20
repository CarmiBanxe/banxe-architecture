# Phase-2 Shell Inventory and Audit Method — Basement to Rooms

**PHASE-2 EXECUTION / SHELL INVENTORY & AUDIT METHOD / SANDBOX-ONLY / READ-ONLY / NO CODE MOVE**

## Purpose & A-chain context

- Formalises the shell-audit canon for the Floor-2 A-chain — the discipline for moving "from basement code to rooms".
- Shell is used only for read-only inventory and audit; no writes, no moves, no edits.
- This method is Phase-2 preparation, not a production migration script.
- It connects the "basement / boxes" metaphor to concrete, read-only CLI patterns.
- Operators — not Claude — execute shell; Claude prepares commands and templates, and interprets output into artefacts.
- Everything here is sandbox / paper mode: outputs feed inventory and verification artefacts, never a code move.

## Basement & rooms — technical mapping

- **Basement** = legacy / accumulated code in banxe-emi-stack and related repos (services, sidecars, PARKED adapters) that has not yet been placed into a governed lane.
- **Rooms** = the governed lanes and perimeters described in the Phase-1/Phase-2 roadmaps: identity, ledger, gateway, payments, and other (reporting/analytics).
- The current Phase-2 artefacts — `PHASE2-MASTER-CODE-MIGRATION-ROADMAP-AND-VERIFICATION-GATES-2026-07-20.md`, `S-A6-VERIF-NO-DIRECT-MCP-LEDGER-WRITES-2026-07-20.md`, `S-PILOT-CODE-MIGRATION-SANDBOX-DEMO-REPORTING-VIEW-2026-07-20.md`, and the dry-run report — live in `docs/`, not in the basement code trees. They describe the method; the basement is what the method inspects.

## Shell-audit canon (rules)

- Shell is used only in read-only mode (`ls`, `find`, `grep`, `sed -n`, `head`, `wc`); never `rm`, `mv`, `cp`, redirects, or in-place edits.
- All shell-audit commands are prepared by the factory and executed by operators.
- Shell output is treated as evidence and as a prompt for Claude Code — never as a migration script.
- Direct shell access to production or live EMI/bank environments is out of scope; only local/sandbox trees.
- Every shell-audit snippet must be compact and informative, suitable to paste back as a Claude prompt.
- Commands must never print secrets or full configs — scope greps to structure (paths, symbol names), not credential values.
- All inventory decisions (Family IDs, lane assignment, risk level) happen AFTER shell-audit, by humans.
- HITL applies: "AI proposes, human decides" for any interpretation of shell output.
- One question → one best command; avoid sprawling pipelines that are hard to review.
- If a command would mutate anything, it is rejected and reformulated as read-only.

## Standard shell-audit checklist (command patterns)

Reusable read-only templates. Operators may adjust paths but must keep every command read-only.

**Roadmap / briefs overview**
- Description: list the roadmap and briefs artefacts and peek at their top headings.
```
ls docs/roadmap docs/briefs
for f in docs/roadmap/*.md; do echo "== $f =="; sed -n '1,28p' "$f"; done
```

**Sprint / audit presence check**
- Description: confirm which sprint and install-audit anchors exist (S-A5/S-A6, Sprint-3/4/5).
```
find docs/sprints docs/audit/spec-audits -name '*.md' | sort
grep -rl "S-A6\|LEDGER-EMI\|Sprint 5" docs/roadmap docs/audit
```

**Basement code quick scan**
- Description: locate identity/ledger/gateway touchpoints in the basement without printing secrets or full configs.
```
find banxe-emi-stack/services -maxdepth 2 -type d | sort
grep -rln "LedgerPort\|KYCProviderPort\|api_gateway" banxe-emi-stack/services
```
- Note: the second command lists file names only (`-l`), so no code or config bodies are printed. Operators keep it that way.

## How shell-audit feeds Phase-2 artefacts

- **Phase-2 inventory (Phase-A checklist):** shell-audit discovers basement components and their touchpoints; humans then group them into Family IDs and assign lane/owner/risk in the inventory table.
- **S-A6 verification:** shell-audit locates ledger-related modules and config file names before any evidence is collected, so evidence IDs point at real, verified locations rather than guesses.
- **S-PILOT and the dry-run report:** both rely on shell-audit evidence, not intuition — the pilot's target location and the training scenario reference artefacts that shell-audit has confirmed to exist.

## Boundaries (what shell-audit does NOT do)

- Does not run tests, migrations, or deploys.
- Does not change code, configs, or infrastructure.
- Does not access live EMI/bank environments.
- Does not assert legal or compliance conclusions — those remain [counsel].
- Does not bypass governance or HITL.

## Operator workflow summary

1. Operator poses a question (e.g. "Where are the basement ledger touchpoints?").
2. Factory prepares ONE best shell-audit command — read-only, clearly scoped.
3. Operator runs the command and copies the output.
4. Operator pastes that output back as a prompt to Claude Code for analysis or templating.
5. Claude responds with structured inventory / verification artefacts (Family rows, evidence IDs, findings drafts).
6. Operator reviews, signs off (HITL), and records the result.
7. Only then does the operator consider real migration planning — still gated, lane by lane, under the Phase-2 roadmap.
