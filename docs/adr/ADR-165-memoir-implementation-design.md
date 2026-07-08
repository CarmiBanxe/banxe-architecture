---
id: ADR-165
title: Memoir Implementation Design — Factory Pilot HOW-layer
status: PROPOSED
date: 2026-07-08
scope: BANXE-factory-only
concept_only: true
relates:
  - "ADR-137 (memoir versioned-memory pilot — PARENT; authorises the pilot at policy level)"
  - "ADR-136 (agentmemory shared-memory substrate — boundary envelope)"
  - "ADR-135 (agent-skill evolution gate — governs EXPANSION beyond the pilot ONLY, not the pilot)"
  - "ADR-130 / ADR-127 (no authority expansion; memory describes, never authorizes)"
  - "ADR-117 (factory/project perimeter)"
  - "ADR-120 (per-session worktree isolation)"
  - "ADR-059 (ledger = memory of record / source of truth)"
  - "MEMOIR-PILOT-PRECOND-01..08 (the WHAT / acceptance contracts)"
  - "ADR-102 (pointer-first, no restatement of canon)"
---

# ADR-165: Memoir Implementation Design — Factory Pilot HOW-layer

**Status:** PROPOSED · **Date:** 2026-07-08 · **Scope:** BANXE-factory-only · **concept_only:** true

> **Document-only.** This ADR adds **no runtime, no code, no memoir instance, and no import of
> `github.com/zhangfengcdt/memoir`** (external reference only — "NOT imported", ADR-137). It defines the
> ratifiable HOW so a subsequent, separately-gated code work item is unambiguous.

## Context

ADR-137 (ACCEPTED, governance-only) authorises a **factory-only memoir pilot** under the ADR-136 boundary
envelope; the eight `MEMOIR-PILOT-PRECOND-01..08` docs define **WHAT** must hold. Neither fixes the **HOW**
(store technology, surface, redaction pattern-set, retention schema, XOR mechanism). This ADR fills that gap.

Three candidate HOW-designs were considered. **Text-3 — grounded on the real ADR-136/137 + the 8 precond
docs + the live `reasoning_bank` and `PresidioRedactor` implementations — is authoritative.** Text-2's
emi-stack / FastAPI / `reasoning_bank`-reuse design is **REJECTED** for three concrete violations:

- **C1 — factory-fork-only breach.** `reasoning_bank` lives project-side (`banxe-emi-stack/services/reasoning_bank/`);
  building memoir there violates PRECOND-05 (factory fork only, project fork disabled).
- **C2 — cross-perimeter storage.** Reusing the `reasoning_bank` store instance shares memory across the
  factory↔project perimeter — forbidden by ADR-117 / PRECOND-05 (the two forks share no store).
- **C3 — premature surface.** A FastAPI/MCP surface contradicts ADR-136/137 "no MCP/memory config surface
  today"; the pilot needs the smallest auditable surface, not a network service.

## Decision (Reconciled Architecture — the only valid HOW)

1. **Repo / path.** memoir lives at **`banxe-architecture/factory/memoir/`** — **factory-side ONLY, never
   `banxe-emi-stack`** (PRECOND-05). Consistent with the factory tooling home (`session_memory/`).

2. **Storage — git plumbing over an isolated bare memory-repo.** Memory records are content-addressed blobs
   committed into a **dedicated bare git repo on a factory-side path** (never inside a code checkout). This
   yields `branch / commit / merge / rollback / blame / checkout` **natively** — none reimplemented. **Redact →
   THEN commit:** raw sensitive data is **never** written, so no historical version can hold it (PRECOND-01
   end-to-end). `reasoning_bank` is **referenced only** — zero code/instance dependency (C2 rejected). An
   optional semantic index (FAISS/HNSW) may be **derived and regenerable** from the memory-repo, reusing the
   `reasoning_bank` *code pattern* factory-side — never its instance, never authoritative.

3. **Surface — Python library + CLI.** Explicit verbs: `store() / recall() / branch / rollback / blame /
   checkout / purge`. **No daemon, no FastAPI, no MCP** in the pilot (C3 rejected). Agents call `store()` /
   `recall()` **explicitly**; automatic session-hook capture is **OUT OF SCOPE** (Outcome C). FastAPI/MCP =
   Outcome-C reference spec only.

4. **Redaction (PRECOND-01).** A **factory-side** implementation **mirroring the `PresidioRedactor` pattern**
   (Presidio-first + deterministic-regex fallback behind a `PiiRedactorPort` DI seam) — **no import of the
   project-side instance** (perimeter). Base classes from the existing redactor (`EMAIL / IBAN / CARD /
   SORT_CODE / PHONE`) are **extended** with: secrets/keys (`AKIA`, `ghp_`, `xox[baprs]-`, `sk-`, `AIza`,
   `-----BEGIN … PRIVATE KEY-----`, JWT `eyJ…`), `.env` `KEY=VALUE` for secret-like keys, and **high-entropy
   spans** (Shannon ≥ ~4.0 over ≥20 base64/hex chars). PAN Luhn-checked; IBAN mod-97-checked. **RED zone =
   DROP, not mask** (payment-core / KYC / AML / sanctions / ledger-derived). **Fail-closed:** on any
   uncertainty — unknown class, parser failure, partial/ambiguous match, engine error/timeout — `store()`
   **refuses and persists nothing** (deny-by-default; "allow" requires a positive non-sensitive classification).
   Redaction also covers **semantic-path keys** and `blame`/`checkout`/`rollback`/`merge` output.

5. **Versioning.** git-native `branch` / `blame` / `checkout`; **`rollback` = a NEW commit (revert), NEVER a
   history rewrite** — no `reset --hard` / force-delete of memory history (append-only, ADR-059 spirit).

6. **Retention (PRECOND-02) — config-as-data.** `config/memoir/retention.yaml` (operator-owned). Required
   finite fields: `max_age`, `max_entries` (per fork), `purge_schedule`, `scope` (= fork + perimeter), plus a
   `hard_cap_bytes` ceiling. **Fail-closed:** absent / unparseable / unbounded / schema-invalid config ⇒ **no
   pilot start, no writes** ("no valid retention config ⇒ no memory"). Purge = **on-write eviction + an explicit
   sweep** (systemd-timer / CI job — no hidden daemon). Example valid config:

   ```yaml
   # owner: Head of Platform (factory). Change = operator-gated PR. schema: memoir-retention/v1
   schema: memoir-retention/v1
   engine: memoir                 # XOR selector — see §7
   scope:
     fork: factory                # factory ONLY (PRECOND-05)
     perimeter: factory           # ADR-117; no cross-perimeter (PRECOND-03)
   bounds:
     max_age: P30D                # ISO-8601 duration; entries older are purged
     max_entries: 20000           # finite, per fork
     hard_cap_bytes: 268435456    # 256 MiB ceiling; above ⇒ store() refuses (fail-closed)
   purge:
     purge_schedule: "0 3 * * *"  # daily 03:00; on-write eviction also applies
     strategy: oldest_first
   ```

7. **XOR (PRECOND-04).** A fork runs **agentmemory XOR memoir, never both**, enforced three ways: (a) a single
   config `engine:` key (source of truth); (b) a **CI guard** (`scripts/check-memory-xor.sh`) failing the build
   if both engines are active/present; (c) a **runtime single-registry** that refuses a second engine
   registration. The **ledger (ADR-059) remains the source of truth**; memoir is never a competing record.

8. **Perimeter (PRECOND-05, ADR-117).** Factory fork only; project fork disabled by default; the two forks
   share no store; **no cross-perimeter** capture or **replay** (PRECOND-03 — replay is observability, not
   re-execution, scoped to the same fork + perimeter).

9. **Authority (PRECOND-07, ADR-130/127).** The memory VCS operates on **memory content only**. `branch /
   commit / merge / rollback / checkout / blame` **NEVER** acquire authority over code / ledger (ADR-059) /
   production / payment / KYC / AML / sanctions / secrets / PII / dispatch. A recalled item is **provisional and
   re-verified before use**; it confers no merge/deploy/payment/AML right.

## Acceptance Gate (CORRECTION)

Pilot acceptance = the **ADR-137 8-precondition test matrix**, **NOT ADR-135**. ADR-135's held-out validation
gate governs **only expansion beyond the factory pilot** (PRECOND-08: a separate ADR **+** operator approval
**+** IronClaw security PASS — deny-by-default, no path via config/flags/precedent).

Required tests (Python-lib calls, **not** HTTP):

| # | Test | Asserts (precond) |
|---|------|-------------------|
| T01 | redaction-leak: PAN / IBAN / AKIA / `ghp_` / JWT / `.env` / email → none in stored content | PRECOND-01 |
| T02 | redaction fail-closed: redactor error / timeout ⇒ `store()` refuses, persists nothing | PRECOND-01 |
| T03 | redaction uncertainty: unknown high-entropy span ⇒ dropped (deny-by-default) | PRECOND-01 |
| T04 | RED-zone drop-not-mask: payment/KYC/AML/ledger-derived content ⇒ dropped entirely | PRECOND-01/06 |
| T05 | semantic-path redaction: sensitive value cannot leak via a path key | PRECOND-01 |
| T06 | history-no-raw: `blame`/`checkout`/`rollback` of any entry returns redacted content only | PRECOND-01 |
| T07 | retention-bound: store `> max_entries` ⇒ `count ≤ max_entries`; aged `> max_age` ⇒ purged | PRECOND-02 |
| T08 | hard-cap: size `> hard_cap_bytes` ⇒ `store()` refuses | PRECOND-02 |
| T09 | retention fail-closed: absent/unbounded/invalid config ⇒ no pilot start, no writes | PRECOND-02 |
| T10 | replay-scope: replay is data-return only, same fork+perimeter; cross-fork/perimeter forbidden | PRECOND-03 |
| T11 | replay-no-exec: recalled/replayed entry is never executed/`eval`'d; no code path runs it | PRECOND-03/07 |
| T12 | XOR: both engines ⇒ CI guard fails / runtime raises; exactly one ⇒ passes | PRECOND-04 |
| T13 | factory-only: project fork disabled by default; no cross-perimeter store/replay | PRECOND-05 |
| T14 | no-authority: `store/branch/merge/rollback` leave code-repo `git status` + ledger hashes byte-identical; path-jail (all writes under memory-repo); no `ledger`/`build_ledger` import; no network; no subprocess into the code repo | PRECOND-07 |
| T15 | append-only: `rollback` creates a new commit; memory history is never rewritten/force-deleted | PRECOND-07, ADR-059 |

## Non-goals / `session_memory` clarification

`session_memory/` (merged separately) is a **read-only session-start pack builder** over `MEMORY.md` +
`docs/handoff/HANDOFF-*.md` + the transfer package. It **never writes source docs**, is **not a memory
substrate**, is **NOT part of the agentmemory-XOR-memoir constraint**, and **complements** memoir. Stating this
explicitly to prevent mis-reading it as a third substrate.

## Consequences

- **+** The HOW is ratifiable; a post-merge code work item becomes unambiguous and directly testable against
  T01–T15.
- **+** Perimeter, redaction, retention, XOR, and no-authority are pinned before any code exists.
- **−** Requires a subsequent, separately-gated **code** work item (still document-only here).
- **−** git-subprocess dependency for the store (accepted; native semantics outweigh a hand-rolled DAG).

## Alternatives Considered

- **Text-2 — emi-stack / FastAPI / `reasoning_bank`-reuse:** **REJECTED** — C1 (factory-fork-only breach), C2
  (cross-perimeter storage), C3 (premature surface).
- **Build-from-scratch DB commit-DAG (SQLite):** rejected for the pilot — git plumbing is native for
  `branch/blame/merge/rollback`; a DB DAG reimplements them. Reconsider only if Outcome C needs queryable
  structured version graphs.
- **Import `github.com/zhangfengcdt/memoir`:** **forbidden** — external reference, NOT imported (ADR-137).

## Pointer

Parent: **ADR-137** (+ ADR-136 envelope). This ADR fills the **HOW**; the eight `MEMOIR-PILOT-PRECOND-01..08`
docs remain the **WHAT / acceptance** contracts (ADR-102 pointer-first — referenced, not restated).
