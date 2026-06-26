---
id: ADR-139
title: Guardian System — self-hosted PR-audit service (Factory :8195 + Project :8196) [comprehensive]
status: ACCEPTED
date: 2026-06-26
accepted: 2026-06-26
supersedes: []
related:
  - "decisions/ADR-022-guardian-bootstrap-baseline-exception.md (one-time bootstrap exception; narrower scope — ADR-022 is the narrow operational amendment; ADR-139 is the comprehensive system architecture)"
  - "docs/adr/ADR-117-factory-project-perimeter-and-fullcycle-org.md (factory/project perimeter this enforces)"
  - "docs/adr/ADR-120-session-worktree-isolation.md (worktree isolation guardian verifies via branch-naming gate)"
  - "docs/adr/ADR-121-parallel-session-destructive-action-protection.md (RULE 7 companion; guardian is audit surface)"
  - "docs/adr/ADR-056-ledger-coupling-merge-gate.md (IL coupling rule guardian-ledger enforces)"
  - "docs/adr/ADR-057-ledger-append-only-immutability.md (ledger-append-only job sources from here)"
  - "docs/adr/ADR-060-multi-actor-orchestration.md (branch namespace guardian-branch-naming enforces)"
  - ".github/workflows/guardian.yml (the workflow implementation this ADR governs)"
il_anchor: IL-600
scope: BANXE-only
concept_only: false
---

# ADR-139 — Guardian System

> **Cross-reference:** `decisions/ADR-022-guardian-bootstrap-baseline-exception.md` is the
> *narrow* one-time operational exception allowing Guardian to bootstrap without circular
> blocking (ADR-019 §6.1 F7 amendment). **ADR-139 is the comprehensive system architecture
> record** — different scope, complementary purpose. Both remain ACCEPTED and in force.

## Context

As the Banxe multi-repo factory grew beyond a single maintainer, PRs accumulated drift against
architectural canon: branches violated ADR-060 namespace, IL entries were dropped, invariant
references were missing, and required governance files were absent from newly-bootstrapped
repositories.

Automated static checks (ruff, semgrep, pytest) verify code correctness but cannot verify
*architectural intent* — whether a PR contradicts an accepted ADR, omits a mandatory IL coupling,
or introduces a pattern prohibited by the invariant registry.

The Guardian system fills this gap: a pair of self-hosted, LLM-powered PR-audit services that
evaluate every inbound PR against the living canon (ADRs, invariants, required-file checklist)
and post a structured verdict before merge.

Two distinct scopes require separate audit lenses:

- **Factory scope** — code quality, tooling, test coverage, CI/CD, factory baseline files
  (`.claude/settings.json`, `factory-guard.yml`). Reviewer: Guardian Factory (:8195).
- **Project scope** — domain correctness, compliance controls, ADR conformance, IL coupling,
  FCA/AML/KYC invariant adherence. Reviewer: Guardian Project (:8196).

Splitting the scopes prevents cross-contamination: a factory baseline change is not judged by
domain-compliance rules, and a compliance PR is not blocked by tooling-lint heuristics.

## Decision

### 1. Two Guardian services, one host (evo1)

| Service | Port | Scope | Endpoint secret |
|---------|------|-------|----------------|
| Guardian Factory | :8195 | Factory baseline, tooling, CI/CD, code-quality gates | `TS_GUARDIAN_FACTORY_URL` |
| Guardian Project | :8196 | Domain correctness, ADR compliance, invariants, IL coupling | `TS_GUARDIAN_PROJECT_URL` |

Both run on **evo1** (`192.168.0.72`) and are reachable via **Tailscale MagicDNS** only —
never exposed on the public internet.

### 2. GitHub Actions integration (guardian.yml)

Every repository that adopts Guardian MUST contain `.github/workflows/guardian.yml` with the
canonical matrix pattern:

```yaml
jobs:
  guardian:
    strategy:
      matrix:
        family: [factory, project]
    steps:
      - uses: tailscale/github-action@v3
        with:
          authkey: ${{ secrets.TS_AUTHKEY }}
      - name: Audit via Guardian (${{ matrix.family }})
        env:
          GUARDIAN_URL: ${{ steps.url.outputs.url }}
        run: |
          curl -sS -X POST "$GUARDIAN_URL" \
            -H 'Content-Type: application/json' \
            -d "$payload"
```

**Graceful degrade:** when `TS_AUTHKEY` or the family-specific URL secret is absent, the job
SUCCEEDS with a skip notice (operator-gated). The moment secrets are populated, the full audit
auto-activates. No repository must be blocked by an unconfigured Guardian.

**Payload schema** sent to each Guardian endpoint:

```json
{
  "request_id": "guardian-{family}-{run_id}",
  "subject_type": "pull_request",
  "subject_id": "{repo}#{pr_number}",
  "scope": "{factory|project}",
  "prompt": "{pr_title}\n\n{pr_body}",
  "context": {
    "branch": "{head_ref}",
    "instruction_id": "{INS-* extracted from PR body}",
    "diff": "{first 60 kB of git diff}",
    "files_changed": ["{array of changed paths}"]
  },
  "actor": "{github.actor}"
}
```

**Verdict schema** returned by each Guardian:

```json
{
  "verdict": {
    "result": "pass|fail",
    "summary": "one-line human summary",
    "reasons": ["reason 1", "reason 2"]
  }
}
```

A `result: "fail"` verdict causes `exit 1` in CI, blocking the merge.

### 3. What Guardian Factory enforces

- Factory baseline files present: `.claude/settings.json`, `.github/workflows/guardian.yml`.
- Agent registry directories present: `agents/souls/`, `agents/passports/`, `.claude/agents/`.
- No direct cloud-LLM calls from service code (INV-AI-01, ADR-021).
- Coding quality signals: test coverage thresholds, semgrep zero-findings, ruff compliance.

### 4. What Guardian Project enforces

- **ADR compliance:** PR does not introduce patterns prohibited by accepted ADRs.
- **IL coupling (ADR-056):** any PR touching tracked paths must include a new IL block in
  `INSTRUCTION-LEDGER.md` or a new shard under `ledger/entries/`.
- **Ledger append-only (ADR-057 / I-28):** no existing IL lines removed or modified.
- **Branch namespace (ADR-060):** head branch matches `agent/(central|right|factory)/<id>/<slug>`.
- **Invariant adherence (I-01..I-74, INV-AI-01):** financial invariants (Decimal-only money,
  jurisdiction block, FCA CASS 15 safeguarding controls) not violated by the diff.
- **Required governance files:** mandatory files from the per-repo checklist are present.

### 5. Invariant coverage (Project scope)

Guardian Project is the runtime enforcement surface for the following invariants (non-exhaustive):

| Invariant | Rule | Guardian action |
|-----------|------|----------------|
| I-01 | No float for money | Fail if float literal assigned to monetary field |
| I-24 | Append-only audit trail | Fail if DELETE/UPDATE on audit tables detected in diff |
| I-28 | Ledger append-only | Fail if IL lines removed |
| I-27 | HITL — AI proposes, human decides | Flag autonomous AI writes to financial state |
| INV-AI-01 | No direct cloud-LLM calls from EMI services | Fail if direct openai/anthropic SDK call found |

### 6. Rollout plan — 18/18 coverage target

Guardian is currently deployed in **7 of 18 repositories**. Remaining 11 repos are onboarded
per the following cadence:

1. Each new repo bootstrap PR includes `guardian.yml` and references `ADR-022` in the PR body
   (per `decisions/ADR-022-guardian-bootstrap-baseline-exception.md` — qualifies as a one-time
   bootstrap exception, exempting the PR from its own F7 check).
2. Tailscale secrets (`TS_AUTHKEY`, `TS_GUARDIAN_FACTORY_URL`, `TS_GUARDIAN_PROJECT_URL`) are
   added to the repo at the GitHub org or repo level by the operator.
3. After secrets are set, Guardian auto-activates for all subsequent PRs (no code change needed).
4. Completion criterion: `guardian-factory` and `guardian-project` jobs are green (or
   graceful-skip) in all 18 repositories' CI checks.

Target: **18/18 by P1 deadline (Q2-Q3 2026)**.

### 7. Scope relationship to `decisions/ADR-022`

`decisions/ADR-022-guardian-bootstrap-baseline-exception.md` is a **narrow, one-time operational
exception** that allows Guardian to bootstrap itself without circular blocking. It amends ADR-019
§6.1 F7 for qualifying bootstrap PRs only.

This document (`docs/adr/ADR-139-guardian-system.md`) is the **comprehensive architecture record**
for the Guardian system as a whole: its design, responsibilities, port assignments, payload/verdict
contracts, enforcement scope, and rollout plan. The two documents are complementary; this one takes
precedence for system-level questions.

## Consequences

**Positive**
- Every PR in covered repositories is audited against living architectural canon before merge —
  eliminates the class of "drift PRs" that passed CI but violated ADRs.
- Two-lens split (factory / project) produces relevant verdicts without false positives from
  scope mismatch.
- Graceful degrade means unconfigured repos are not blocked; activation is fully operator-gated.
- Single evo1 host makes secret rotation simple (one Tailscale node; one URL per family).

**Negative / risks**
- Single host (evo1) is a single point of failure. Mitigation: graceful-degrade prevents a downed
  evo1 from blocking merges; the gate is advisory-by-default, required-on-config.
- LLM verdict quality depends on Guardian's system prompt and model tier. False negatives (missed
  violations) are possible; Guardian supplements but does not replace human review.
- Tailscale dependency: if Tailscale is unavailable, evo1 is unreachable from GitHub Actions.
  Mitigation: same graceful-degrade path; skip does not block.
- 11 uncovered repos (currently 7/18) continue to accumulate unaudited PRs until onboarded.
  Mitigation: rollout plan in §6.

## Enforcement artefacts

- `.github/workflows/guardian.yml` — canonical job implementation (present in all covered repos).
- `TS_AUTHKEY`, `TS_GUARDIAN_FACTORY_URL`, `TS_GUARDIAN_PROJECT_URL` — operator-managed Tailscale
  secrets (never committed; never printed in logs).
- `decisions/ADR-022-guardian-bootstrap-baseline-exception.md` — bootstrap PRs reference this.
- Guardian Factory service at `evo1:8195` / Guardian Project at `evo1:8196`.

## References

- ADR-117: Factory/Project perimeter (defines what each scope owns)
- ADR-120: Per-session worktree isolation (guardian-branch-naming enforces the branch contract)
- ADR-121: Parallel-session destructive-action protection (guardian is the audit surface)
- ADR-056: Ledger coupling merge gate (guardian-ledger job implements)
- ADR-057: Ledger append-only immutability (ledger-append-only job implements)
- ADR-060: Multi-actor orchestration / branch namespace (guardian-branch-naming job implements)
- `decisions/ADR-022-guardian-bootstrap-baseline-exception.md` (one-time bootstrap exception)
- Invariant registry: `INVARIANTS.md` (I-01..I-74, INV-AI-01)
