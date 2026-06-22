# Canon Fast-Lane Simplification — accelerating BANXE smart-refactor migration

**Status:** governance proposal (docs-only) · **Date:** 2026-06-22 · **Type:** canon amendment proposal, no code/runtime change
**Refs:** ADR-059 / ADR-059-A (shard ledger), ADR-057 (append-only), ADR-060 (branch namespace), ADR-102 (Duplication Audit), ADR-103 (server-only refactor), `docs/governance/LEDGER-MERGE-QUEUE.md`, `docs/governance/OPERATOR-ENABLE-MERGE-QUEUE.md`, MIG-TEMPLATE §3 (mode labels).
**Scope:** changes the *process weight* applied to migration actions by **risk class**. It does **not** weaken any safety guardrail, invariant (I-21..I-28), ADR-102/103, or the strict-lane domains in §5. **Additive / re-tiering only.**

> **Thesis.** The migration track is correct but *slow for the wrong reasons*. The friction is almost entirely **process ceremony applied uniformly to low-risk descriptive/additive work**, not genuine safety cost. This proposal splits migration actions into **three risk lanes** and removes the unjustified ceremony from the lowest one, while keeping the strictest lane exactly as hard as today.

---

## 1. What is actually blocking throughput (evidence from this track)

Each item below is observed in the M2.8 / MIG / canon track, not hypothetical.

| # | Friction | Evidence | Justified by real risk? |
|---|---|---|---|
| 1 | **Excessive IL/ledger churn** | every docs-only step mints a new shard + regenerates `INSTRUCTION-LEDGER.md`; dozens of micro-shards (IL-440…IL-452) for one migration phase | **No** for descriptive/additive docs — the shard adds audit noise, not safety |
| 2 | **`il_ts` collision management as constant overhead** | readiness shard re-minted **13:30→13:45→14:00** across three rebases as main churned; gate-lift bumped to 14:15; each collision = full rebase+regenerate cycle | **No** — already acknowledged as a "Sisyphus loop" in `LEDGER-MERGE-QUEUE.md`; manual arbitration is pure overhead |
| 3 | **Stale CONFLICTING / forced-nudge cases** | PR #699 and readiness branch flipped DIRTY/BEHIND repeatedly; main moved 8+ times in one window (`684e5f9→…→d819937`) | **No** — artifact of strict + concurrent ledger PRs, fixable at merge-time |
| 4 | **Docs-only PR batch-merge overhead** | each MIG note = its own PR + its own governance-merge cycle, even when 5 notes belong to one sprint | **No** — no code/runtime risk in a descriptive note |
| 5 | **Over-fragmentation into micro-steps** | a single governance step (e.g. "decision-brief") blocks the *next useful scaffold* though both are low-risk and additive | **Partially** — sequencing matters for *decisions*, not for *additive scaffolding homes* |
| 6 | **Operator-gated mode applied to low-risk additive surfaces** | descriptive roster/coverage updates, adapter shells, and additive ports wait on the same operator gate as live-state changes | **No** — a descriptive/additive surface cannot harm clients or production |
| 7 | **One-size process for high- and low-risk actions** | a docs note and a production cutover traverse the *same* weight of gates | **No** — risk is wildly different; process should be proportional |

**Conclusion.** Items 1–4, 6, 7 are **unjustified** for low-risk work and are the dominant drag on migration velocity. Item 5 is justified only where a *decision* (not a scaffold) is the dependency. None of them protect KYC/auth/ledger/cutover — those are protected by *other*, lane-3 controls that this proposal leaves untouched.

---

## 2. The three-lane model (best-decision canon)

Every migration action is classified into exactly one lane by **what it can touch**, using MIG-TEMPLATE §3 mode vocabulary.

| Lane | Definition | Examples | Risk surface |
|---|---|---|---|
| **🟢 Fast lane** | docs-only, descriptive/additive, no behavior change | migration docs/MIG notes, IL/ledger updates, roster/coverage updates, low-risk scaffolds (empty target homes), descriptive/additive ports, **adapter shells** (no wiring), schema *inventory* | none on clients/runtime — purely additive or descriptive |
| **🟡 Controlled lane** | bounded-context code migration, **no live-state touch** | moving a BC's modules, dedup/merge of non-live packages, consumer re-point within a BC, internal API shape changes behind a fence | code-level only; reversible; no live data/balances/auth |
| **🔴 Strict lane** | live/regulated runtime & money | KYC/KYB/AML, auth-crypto runtime, token/session issuance, live balances / ledger mutations, production cutover/re-point | direct client-funds / regulatory / production-traffic risk |

**Classification rule (fail-safe):** if an action plausibly fits two lanes, it takes the **stricter** one. Lane assignment is stated on the artifact (e.g. `Lane: 🟢 Fast (CANON-FAST-LANE §2)`), mirroring the MIG-TEMPLATE `Mode:` one-liner.

---

## 3. Fast-lane simplifications (proposed)

For 🟢 Fast-lane work ONLY:

1. **Batch multiple docs/IL updates into one PR.** A sprint's related docs notes + their IL shards merge as a single PR instead of N micro-PRs.
2. **No separate governance-merge cycle** where there is no code/runtime risk. Fast-lane docs PRs merge on green CI through the standard queue — no extra operator checkpoint.
3. **Replace per-PR `il_ts` arbitration** with a **deterministic batch-timestamp window** OR a **merge-time sequence generator** (see §4) — authors stop hand-bumping `il_ts` to dodge collisions.
4. **Grouped sprint artifacts.** One PR per sprint for related low-risk artifacts (roster + coverage + scaffold-plan notes together), instead of a constant stream of micro-PRs.
5. **No governance stop between consecutive low-risk scaffolds.** Creating target home A and then target home B does not require an operator gate between them when both are additive (empty shells, no code-move, no wiring).

> Fast lane keeps: ADR-059-A append-only (shards never mutated), ADR-060 branch namespace, ADR-102 *when a structural delete/merge is involved* (a pure additive scaffold has nothing to dedup yet), CI green.

---

## 4. Ledger timestamping reform (mechanism)

The durable fix already exists in canon — this proposal **adopts and extends** it:

- **Adopt the merge queue** (`LEDGER-MERGE-QUEUE.md` + `OPERATOR-ENABLE-MERGE-QUEUE.md`): build concurrency 1, auto-rebase, squash. This **eliminates `il_ts` collision chasing** because the queue serializes ledger PRs at merge-time — sequential `IL-NNN` never collides. **This is the single highest-leverage change** and removes frictions #2 and #3 outright.
- **Merge-time allocation / monotonic auto-sequencer.** Authors write a shard with a **placeholder/coarse `il_ts`**; the canonical `il_ts` (or a monotonic sequence) is **assigned at merge-time** by the queue/generator, not hand-arbitrated per PR. Hand-bumping `il_ts` across rebases (the 13:30→13:45→14:00 dance) stops being a task.
- **Batch-timestamp window (interim, until the sequencer lands).** A sprint's fast-lane shards share a reserved window (e.g. one whole-minute slot per sprint) and are ordered by `(session_id, path)` tie-break — no per-shard arbitration.
- **Unchanged:** shards remain **append-only**; `INSTRUCTION-LEDGER.md` remains generated (`build_ledger.py`), never hand-edited; deletions still fail `ledger-append-only` (I-28 / ADR-057).

---

## 5. What stays STRICT (no dilution)

The 🔴 Strict lane is **unchanged** — mandatory operator approval, full ceremony, per-action gate, server-side (ADR-103), ADR-102 audit, HITL where applicable. **No batching, no auto-merge, no reduced checkpoints** for:

- **KYC / KYB / AML** (I-27 HOLD; HITL-L4 gate).
- **SRP runtime activation** (`AGENT_ROUTING_ENABLED`, Ruflo pipeline).
- **Token / session issuance changes** (auth-crypto runtime).
- **Live balances / ledger (money) mutations** (CASS 15 safeguarding, Midaz/LedgerPort live).
- **Cutover / re-point to production traffic** (production promotion).

Any action touching the above is Strict by definition, regardless of how "small" it looks. The fail-safe classification rule (§2) routes ambiguous cases here.

---

## 6. Controlled-lane adjustments (proposed)

For 🟡 Controlled lane — **keep the safety spine, trim the ceremony**:

- **Keep:** worktree/branch isolation (Rule 1, parallel-session isolation), full CI, ADR-102 Duplication Audit on any delete/merge, ADR-103 server-side execution.
- **Simplify:** one IL shard **per bounded-context migration** (not per file/sub-step); reduce operator checkpoints to **two** — (1) approve the BC migration plan, (2) approve promotion to main — instead of a gate at every intermediate scaffold.
- **Batching:** related Controlled-lane PRs for one BC may share a sprint grouping *if* none touch live-state; each still carries its own Duplication Audit section.

---

## 7. Concrete operator commands / policy changes

| # | Policy change | Mechanism | Removes friction |
|---|---|---|---|
| P1 | **Merge docs+IL governance PRs in sprint batches**, not per micro-step | one PR per sprint for fast-lane artifacts | #1, #4, #5 |
| P2 | **Move ledger timestamping to merge-time allocation / monotonic auto-sequencer** | enable merge queue (operator runbook already written); add a merge-time `il_ts`/sequence assignment step to `build_ledger.py` workflow | #2, #3 |
| P3 | **Allow one-PR-per-sprint for related low-risk artifacts** | fast-lane batching rule (§3.4) | #1, #4 |
| P4 | **Remove the separate governance stop between consecutive low-risk scaffolds** | fast-lane rule §3.5 — additive scaffolds chain without inter-step operator gate | #5, #6 |
| P5 | **Keep mandatory operator approval ONLY for strict-lane domains** (§5) | lane classification + fail-safe rule (§2) | #6, #7 |
| P6 | **Enable the GitHub merge queue on `main`** (operator-privileged) | `docs/governance/OPERATOR-ENABLE-MERGE-QUEUE.md` Path A/B/C — operator runs under own creds | #2, #3 |

> P2/P6 are operator-privileged (repo-admin / workflow change). The factory prepares materials; the operator executes. P1/P3/P4/P5 are process rules the factory can adopt immediately on operator acceptance of this canon.

---

## 8. Effective operating model from now on

Once this canon is accepted:

1. **Sprint-based execution.** Work is grouped into sprints; each sprint emits one batched fast-lane PR (docs + IL) plus any Controlled/Strict PRs that genuinely need isolation.
2. **One best-next-action artifact.** Per the Best-Single-Artifact canon — exactly one next action emitted, lane-tagged.
3. **Batch low-risk work.** Fast-lane docs/scaffold/roster/coverage updates accumulate into the sprint PR rather than dripping out as micro-PRs.
4. **Fewer governance interrupts.** Operator gates fire only at Strict-lane actions and at the two Controlled-lane checkpoints — not between additive scaffolds.
5. **Direct progress to 100% migration.** The factory advances bounded-context migration sprint-by-sprint, with ceremony proportional to risk, reaching full migration of the relevant microservices faster and without artificial blocks.

---

## 9. Why this is safe (guardrails preserved)

- **No invariant weakened:** I-21..I-28 intact; append-only ledger intact; ADR-102/103 intact for any structural/delete/merge or server-side work.
- **No strict-lane dilution:** §5 domains keep full ceremony and mandatory operator approval.
- **Throughput gain comes from removing *ceremony*, not *controls*:** batching, merge-time sequencing, and lane-proportional gating cut wall-clock and operator-interrupt cost on work that has **no** client/runtime/regulatory risk.
- **Fail-safe by construction:** ambiguous actions route to the stricter lane; a misclassification errs toward *more* control, never less.

---

*Docs-only proposal. No code, no runtime change, no merge of any migration branch, no KYC touch. Adopts the existing merge-queue canon (LEDGER-MERGE-QUEUE / OPERATOR-ENABLE-MERGE-QUEUE) and adds a risk-tiered lane model. Operator acceptance activates the process rules; operator-privileged items (merge queue, sequencer) are executed by the operator under their own change-control.*
