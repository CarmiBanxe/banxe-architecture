---
id: ADR-141
title: Self-healing continuous-learning loop for factory AI employees — bounded, async, HITL-gated (orchestrates ADR-135/136/137)
status: PROPOSED
date: 2026-06-27
accepted:
supersedes: []
relates:
  - "ADR-135 (held-out validation gate — the ADOPTION gate this loop routes every candidate revision through; KEEP, not redefined)"
  - "ADR-136 (agentmemory substrate — the episode/memory layer the loop reads; KEEP, not redefined)"
  - "ADR-137 + MEMOIR-PILOT-PRECOND-01..08 (versioned memory / blame / rollback + redaction/retention/replay/no-authority bounds — KEEP, composed)"
  - "ADR-126/127 (Hermes Tier-1 read-only — the observer/reflector posture)"
  - "ADR-130 (no authority expansion) / ADR-128 (HITL L1/L2/L3) / ADR-117 (factory perimeter) / ADR-059 (ledger record)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
il_anchor: IL-609
il_anchor_note: "Provisional per ADR-119 Rule 8 — NOT hardcoded; build_ledger mints max+1 over current origin/main. Frozen at rebase-before-merge."
scope: BANXE-factory-only
concept_only: true
---

# ADR-141 — Self-healing continuous-learning loop for factory AI employees

## Context

Factory AI employees run **frozen** skill/persona documents (ADR-130/131/135). When real episodes expose
a regression or gap, there is **no safe mechanism to self-restore** — the only options today are an
operator hand-edit or an ungated self-modification, which canon forbids. We need a loop that lets workers
**improve continuously from real episodes** while preserving **HITL, rollback, redaction, and
no-authority-expansion**. The required pieces already exist and MUST be **orchestrated, not duplicated**:
**ADR-135** (held-out adoption gate), **ADR-136** (memory substrate), **ADR-137 + PRECOND-01..08**
(versioned memory + bounds), **ADR-126/127** (read-only observer). This ADR is concept-only: **no
runtime, no secrets, no cron/config instantiation** — activation is a separate gated work item.

## Decision

**Adopt a bounded, ASYNCHRONOUS, scheduled, HITL-gated self-healing continuous-learning loop. Production
sessions run frozen skills and NEVER self-modify; learning happens OFFLINE; every candidate revision is
held-out-validated (ADR-135), versioned (ADR-137), and operator-adopted.** The loop:

### 1. Episode capture (sources)
Factory-agent episodes — CI signals, spec→ADR→build steps, gate pass/fail, tool I/O, incident/rollback
events, benchmark deltas — are captured via the **ADR-136 agentmemory factory fork**, **redacted at
capture** (PRECOND-01, fail-closed) before storage. No project/prod customer data; RED zone excluded
(PRECOND-06).

### 2. Redacted memory synthesis pipeline
Captured episodes are synthesised into a **redacted training signal** (patterns, failure clusters,
coverage gaps). Redaction (PRECOND-01), bounded retention/purge (PRECOND-02), and replay-scope
(PRECOND-03) bound the pipeline; the **ledger (ADR-059) stays the source of truth**, memory is convenience.

### 3. Observer / Reflector role (read-only)
A **read-only** observer (Hermes Tier-1 posture, ADR-126/127) reflects over the synthesised signal and
emits **candidate findings** (what regressed / what is missing). It proposes nothing executable and
holds no authority.

### 4. Analyst / Evolution role (proposal-only)
An analyst turns findings into **candidate revisions** — bounded edits (ADR-135 "textual learning rate")
to the allowed targets below. Candidates are **proposals**, never applied directly.

### 5. Allowed mutation targets (gated)
- agent **skills** / **prompts** (SOUL/skill docs, ADR-130/131 format);
- **runbooks** (docs/runbooks);
- **routing** rules (which agent/model handles what);
- **pre-checks** (advisory gates / lint heuristics).

### 6. Prohibited targets (hard, fail-closed)
- **Authority** of any kind (PRECOND-07 / ADR-130 — no merge/deploy/payment/dispatch right);
- **Sensitive banking write paths** — payment-core / KYC / AML / sanctions / ledger write (RED zone,
  PRECOND-06, ADR-137 L67-68);
- **Raw secrets** and **raw PII memory** (PRECOND-01 — never stored, never a learning input);
- the held-out/benchmark sets themselves, CI gates, or canon ADRs (no self-grading, no gate-weakening).

### 7. Held-out validation + benchmark gate (adoption)
A candidate is adopted **ONLY IF** it passes the **ADR-135 held-out validation gate** (strict
improvement on a held-out set, zero regression on boundary/safety checks) **AND** the existing benchmark
suite (e.g. `promptfoo-eval`, `adversarial-sim`) shows no regression. Otherwise **rejected
(fail-closed)** and the frozen skill is kept.

### 8. Rollback / blame / versioning
Memory and every skill/prompt/runbook revision are **versioned, blame-able, and reversible** via the
**ADR-137 Memoir** model (branch/commit/blame/rollback over content) plus a **ledger record (ADR-059)**
per revision. Any adopted revision can be **rolled back to a known-good version** (self-healing: on a
benchmark drop or incident, the loop proposes a restoring edit OR rolls back — both gated).

### 9. Scheduled cadence (async; NEVER in prod sessions)
- **Nightly (light):** capture + redacted synthesis + reflect → candidate findings (no adoption).
- **Weekly (heavy):** analyst proposals → ADR-135 held-out + benchmark gate → **operator HITL adoption**
  (ADR-128 L2/L3; IronClaw sign-off for sensitive-adjacent surfaces) → versioned.
The cadence and target/allow/deny lists are **config-as-data** (operator-owned), specified here as a
**schema contract** — no real cron/config file is created (would-be home: `deploy/cron/`, a separate
gated work item).

## Self-healing — explicit and bounded

"Self-healing" = the loop **detects a regression** (benchmark drop, gate failure, incident) and
**proposes a restoring revision OR rolls back to a known-good version** — always through §7's gate and
§9's HITL adoption. It is **continuous** (scheduled) but **asynchronous** (offline); production sessions
are never modified in-flight. There is **no ungated self-modification** anywhere.

## Duplication Audit (ADR-102)

1. **Repo-wide search** — no prior self-healing / continuous-learning-loop ADR (`grep` over `docs/adr`,
   `docs/governance` = none). This ADR **orchestrates**, it does not redefine: **ADR-135** stays the sole
   adoption gate; **ADR-136** stays the substrate; **ADR-137/PRECOND-01..08** stay the versioning/bounds;
   **ADR-126/127** the observer posture. No new gate, no new substrate, no new memory store.
2. **Source-of-truth + consumers.** Ledger (ADR-059) remains source of truth; the loop is a scheduled
   consumer that proposes → gates → versions. No existing ADR/skill/benchmark is edited.
3. **No import / no runtime.** No code, cron, config file, or secret is added; the cadence/targets are a
   schema contract only. Existing cron infra (`deploy/cron/`) is the future home, not touched here.
4. **Decision per match:** ADR-135/136/137/126/127 + PRECOND-01..08 → **KEEP + cross-link**; ADR-141 →
   **ADD** (the orchestration). No delete, no merge, no duplicate.

## Consequences

- Factory employees gain a **bounded, async, HITL-gated** path to improve and self-restore from real
  episodes — without prod self-modification, authority expansion, or RED-zone exposure.
- Every revision is held-out-validated, benchmarked, versioned, and reversible; regressions trigger a
  gated restore/rollback.
- **No runtime change.** Activating the loop (capture wiring, synthesis job, cron, config, benchmark
  integration) is a **separate gated work item** under this ADR + ADR-135 — out of scope here.

## Anchors

- ADR-135 (held-out gate), ADR-136 (substrate), ADR-137 + MEMOIR-PILOT-PRECOND-01..08 (versioning/bounds),
  ADR-126/127 (observer), ADR-130 (no authority), ADR-128 (HITL), ADR-117 (perimeter), ADR-059 (record),
  ADR-102 (Duplication Audit). Existing benchmarks: `promptfoo-eval`, `adversarial-sim` (cron). Enforcement
  = CI gates + these ADRs; this spec carries no runtime/secret/config.
