---
id: ADR-182
title: MemoHarness ↔ Banksy engine binding — dual-project adapter contract (third-zone client, deny-by-default)
status: DRAFT
date: 2026-08-08
relates:
  - "ADR-135-A (MemoHarness harness-loop amendment — A1; NOT modified here)"
  - "ADR-136-A (memory fabric read-only query gateway — A2; NOT modified here; Banksy = new client class)"
  - "ADR-166-A (layer-promotion protocol — A3; NOT modified here; promotion path reused as-is)"
  - "ADR-117 (factory/project perimeter — NOT extended; Banksy is a third zone outside both)"
  - "ADR-059 (ledger shards = memory of record — antecedent IL linkage is forward-only)"
  - "ADR-102 (Duplication Audit — see section below)"
  - "ADR-119 (IL number mint-at-merge discipline)"
  - "ADR-130 (no authority expansion — memory describes, never authorizes)"
  - "ADR-181 (blind Codex second opinion — AGREE, 2026-08-08, session 019fde66-bb74-73f3-bec1-bd8ad230cca0)"
  - "bank-rooms/F0-engine-manus-room/BANKSY-ENGINE-INTEGRATION-PLAN.md (third-zone definition)"
  - "bank-rooms/F0-engine-manus-room/runtime/BANKSY-BUILD-MANIFEST.md (Wire section — external request/response pattern)"
  - "bank-rooms/F0-engine-manus-room/BANKSY-ENGINE-STACK-REGISTRY.md (two-engines concept; Legion = external supplier)"
il_anchor: TBD
il_anchor_note: "Assigned by ledger-rebuild after merge (ADR-119 Rule 8 discipline). Antecedents: IL-1147 (A2), IL-1148 (A1), IL-1151 (A3)."
scope: dual-project — BANXE MemoHarness (A1+A2+A3) bound to Banksy engine via adapter contract; the three amendment ADRs keep their own scope fields UNCHANGED
concept_only: true
---

# ADR-182 — MemoHarness ↔ Banksy engine binding (DRAFT, concept-only)

## Context

The MemoHarness amendment plan is merged 3/3 on `main`: **A1** ADR-135-A
(harness-loop, IL-1148, #1199), **A2** ADR-136-A (read-only memory fabric,
IL-1147, #1204), **A3** ADR-166-A (layer promotion, IL-1151, #1212). All three
are scoped BANXE(-factory)-only and none mentions the Banksy engine. The
operator directive is to bind MemoHarness to Banksy as **one feature across two
projects**.

Banksy is a **third zone** (BANKSY-ENGINE-INTEGRATION-PLAN): neither factory
nor project under ADR-117. It lives in `bank-rooms/F0-engine-manus-room/runtime/`
(port 8200, `compiled_over_legion = false`), is docs-only today (0 assembled
modules), runs its own inference loop, is governed by GENERAL-LINE (GL-*) not
IL-* (F0 `.claude/rules`), and reaches Legion strictly as an external
request/response data supplier. Banksy already carries a template-level memory
buffer: `runtime/banksy/harvest/memory.py` (bounded 50-item history + a
summarization signal, adapted from the OpenManus/Legion template).

This ADR records the **binding decision only**. It is additive: zero edits to
the three merged ADRs, their frontmatter, existing ledger shards, runtime code,
rego, or the BANKSY-* manifests.

## Decision — adapter contract, not scope extension

**Banksy is bound to MemoHarness as a separate, deny-by-default THIRD-ZONE
CLIENT under an explicit adapter/perimeter contract. The scope fields of
ADR-135-A / ADR-136-A / ADR-166-A are NOT extended, edited, or reinterpreted —
this ADR is the sole, append-only carrier of the dual-project binding.**

### 1. Fabric client class (A2 binding)

Banksy receives its own `client_class` / identity in the ADR-136-A query
gateway — a **third principal class** beside factory and project:

- **Deny-by-default, total.** With no rego rule for
  `(client=banksy, store, record-class)`, Banksy reads NOTHING. Every
  allowance is a separate operator-ratified rego rule — the exact G-3 pattern
  of ADR-166-A, reused verbatim.
- **Gateway-only, read-only.** Banksy never touches Ledger / reasoning_bank /
  memoir directly. The fabric runs on BANXE infrastructure; Banksy reaches it
  as an EXTERNAL request/response client — structurally identical to the
  already-canonical "Banksy↔Legion = external request/response only, no shared
  runtime" (BUILD-MANIFEST Wire). Conceptual wire line:
  `Banksy↔memory-fabric = external request/response, deny-by-default,
  read-only`. Never Legion `:8080`, never direct store paths.
- **Fail-mode inherited from A2:** fabric DOWN ⇒ Banksy degrades to
  "no memory" — NEVER to direct store access.
- **Envelope confers zero authority** (ADR-130 / A2 invariant): a fabric
  answer never authorizes a Banksy action.

### 2. Classification of `banksy/harvest/memory.py`

`harvest/memory.py` is a **local, non-authoritative working/session memory**
of the Banksy engine — ephemeral case/context input at most. Explicitly:

- MemoHarness does **not replace** it; it is engine-level runtime buffering,
  MemoHarness is governance-level (loop / access / promotion). Different
  strata; mapping-only.
- **Banksy memory is NOT a fourth store of the A2 fabric.** A2 federates
  exactly three stores (Ledger / reasoning_bank / memoir); adding a source is
  a NEW ADR by A2's own terms and is not decided here.
- Any future convergence of `harvest/memory.py` with MemoHarness concepts is a
  factory build step under GL-* (GL-20 line), not part of this binding.

### 3. Harness-loop on the Banksy side (A1 binding)

The A1 harness-loop **pattern** (six dimensions, retrieval → reflect, bounded
edits) is reused conceptually for Banksy's learnable state (BDSL training
spec). Its gating authority does NOT transfer:

- Banksy's loop is gated by **Banksy's own governance**: GL-* + HITL-L4 / I-27
  (the conductor PROPOSES only). Factory write-gates (ADR-160) do not silently
  extend to the Banksy zone, and Banksy gains no standing in factory gates.
- **Transfer evidence ≠ transferable authority** (A1(c), ADR-181 consolidated
  ruling): a pattern learned in one zone never grants standing in the other;
  the receiving side runs its own held-out pass.

### 4. Promotion path (A3 binding)

Any promotion of Banksy-originated experience into decision-memory follows the
A3 pipeline unchanged, on the BANXE side:

- reviewer-signed **evidence-manifest shard through the Ledger contour**
  (ADR-059 shard-flow) — never through the A2 fabric, never directly from
  `harvest/memory.py`.
- Until G-3 (ADR-166-A) is closed by an operator-ratified rego rule, no
  dereference into factory-memoir evidence — the self-sufficient shard is the
  only cross-boundary artifact. All A3 Pre-ACCEPTED gaps (G-1..G-9) apply to
  Banksy-originated candidates identically.

### 5. Legion supplier boundary

Legion does not become part of the memory fabric by transitivity. Data from
Legion first crosses the existing Banksy↔Legion supplier interface
(provenance / redaction / compliance capture at the receiving owner), and only
a canonical store owner may then persist it. **The direct route
`Banksy → Legion → fabric/store` is forbidden.**

### 6. Compliance invariants at the Banksy perimeter

Banksy's art-layer treats financial invariants as reference-only (F0 rules) —
which is precisely why the record-class rules MUST exclude compliance/sensitive
classes from any banksy-readable set (the ADR-136 envelope already excludes
sensitive domains from capture; A2 query-time redaction adds the second pass).
For any Banksy consumption of memory:

- **I-01..I-04 are enforced deterministically BEFORE any memory input**; a
  memory answer may only ADD scrutiny/HOLD, never relax a control (G-8
  additive-scrutiny invariant applies to Banksy as to every consumer).
- **PRECOND-04 XOR preserved:** no new substrate, no mirror, no copy of any
  store inside the Banksy zone — envelope responses only.

## Invariants preserved (unchanged by this ADR)

- A2 fabric remains **read-only, total** — no write path is created for or by
  Banksy.
- ADR-117 perimeter is **not extended** — Banksy stays a third zone; the
  factory/project wall stands as-is.
- Ledger remains SoT (ADR-059); authority ranking of A2 is not reconfigured.
- No authority expansion (ADR-130): binding grants Banksy zero write/dispatch
  authority anywhere in BANXE, and grants BANXE no authority inside the Banksy
  zone beyond this contract.

## Ledger linkage (forward-only)

Antecedents: **IL-1148** (A1), **IL-1147** (A2), **IL-1151** (A3) — merged
shards, untouched. This ADR receives its own NEW shard
(`ledger/entries/fable5-adr182-memoharness-banksy-binding/`), minted by
`scripts/add-il-shard.sh` (shared Redis allocator, fail-closed), whose body
cross-references the three antecedent ILs and this ADR. No retro-edit of any
existing shard; the link is bidirectionally discoverable through this new
artifact only. On the Banksy side the corresponding record is a **GL-* entry**
(F0 GENERAL-LINE) — part of the follow-up map, not of this PR.

## Out of scope (this DRAFT)

- Any implementation: rego rules, client identity plumbing, config, code,
  tests.
- Banksy-side MEMORY-INTEGRATION-MAP and BANKSY-* manifest updates (Wire line,
  STACK-REGISTRY substrate row) — follow-up after ratification.
- Fixing the `status: DRAFT` frontmatter of the merged A1/A2/A3 — a separate
  operator-gated follow-up, deliberately NOT bundled here.
- Any change to ADR-137 pilot preconditions, A2 store set, or A3 gap table.
- Any claim that the integration is operational — it is not; Banksy has 0
  assembled modules.

## Duplication Audit (ADR-102, 5 steps)

1. **Matches found:** ADR-135-A / ADR-136-A / ADR-166-A (the feature being
   bound); ADR-117 (perimeter); ADR-127 (cross-perimeter delegation
   precedent); BANKSY-ENGINE-INTEGRATION-PLAN / BUILD-MANIFEST /
   STACK-REGISTRY (third-zone + wire patterns); `banksy/harvest/memory.py`
   (existing memory contour); F0 `.claude/rules/*` (GL-* governance).
2. **Source-of-truth:** each mechanism keeps its existing SoT — A1/A2/A3 for
   MemoHarness, BANKSY-* docs for the zone, F0 rules for GL governance. This
   ADR adds ONLY the missing decision (the binding); it restates none of them
   (pointer-first).
3. **No delete/merge:** nothing is deleted or merged; `harvest/memory.py`
   keeps its role (classified, not replaced); no consumer is re-pointed.
4. **Decision per match:** all matches → **keep**; binding expressed as a new
   ADR. Risks: (i) scope-drift by reinterpretation of A1/A2/A3 — mitigated by
   the explicit "scope fields UNCHANGED" clause; (ii) perimeter bypass via
   Legion transitivity — mitigated by §5 prohibition; (iii) silent 4th-store
   creep — mitigated by §2 prohibition.
5. **Fail-closed:** any ambiguity about a hidden consumer of Banksy memory or
   fabric access halts activation (see blockers) and escalates to the
   operator.

## Activation blockers (fail-closed until closed)

| # | Blocker | Default until closed |
|---|---|---|
| B-1 | Stable Banksy identity (`client_class`, rego subject) undefined | All fabric queries from Banksy DENY |
| B-2 | No operator-ratified rego rule for any `(banksy, store, record-class)` | DENY (deny-by-default carries the load) |
| B-3 | Owner + retention for Banksy case capture undefined | No Banksy experience capture at all |
| B-4 | `harvest/memory.py` persistence semantics unaudited (process-local vs persisted) | Treated as process-local ephemeral; no promotion source |
| B-5 | Reviewer-signed evidence-manifest format for Banksy promotion unspecified | No Banksy-originated promotion |
| B-6 | A3 G-3 rego rule not ratified | Shard-only transit; no factory-memoir dereference |
| B-7 | Legion supplier data provenance/redaction boundary unspecified | No Legion-sourced content enters any store |
| B-8 | Adversarial probes (I-01..I-04 + additive-scrutiny) absent for the Banksy client class | Fabric access for Banksy stays DENY |

## Second opinion (ADR-181)

Blind parallel consultation, Codex CLI (`gpt-5.6-sol`, read-only sandbox,
session `019fde66-bb74-73f3-bec1-bc...a0`, 2026-08-08): **AGREE** —
independent verdict selected the same option (single additive integration
ADR + one new IL shard; Banksy as separate deny-by-default client, not a
scope extension, not a fourth store). Deltas adopted: adapter-contract
framing; leaner two-file first PR (Banksy-side map deferred); explicit
prohibitions on the 4th store and the Legion→fabric route; `status: DRAFT`
observation logged as a follow-up. INDEPENDENT (OpenAI engine).

## Rollback

Delete `docs/adr/ADR-182-memoharness-banksy-binding.md` + append a rollback
shard to the ledger (append-only; no history rewrite). ADR-135-A / ADR-136-A /
ADR-166-A and all BANKSY-* documents remain untouched and fully in force;
Banksy reverts to having no MemoHarness binding.
