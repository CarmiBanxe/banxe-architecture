---
id: MEMOIR-PILOT-PRECOND-02
title: Memoir pilot — Precondition #2 Bounded retention + purge (config-as-data) — verifiable contract
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-137 (Memoir factory-only PILOT, ACCEPTED; this specifies its Pilot Entry Precondition #2)"
  - "MEMOIR-PILOT-PRECOND-01 (redaction-at-capture; purge correctness builds on its redaction guarantees)"
  - "ADR-136 (agentmemory substrate envelope — retention/replay boundaries)"
  - "ADR-135 (held-out validation gate — verification criteria below must pass it)"
  - "ADR-117 (factory/project perimeter — retention/purge are per fork+perimeter)"
  - "ADR-130/127 (no authority expansion; Tier-1 read-only)"
il_anchor: IL-564
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
external_ref: "github.com/zhangfengcdt/memoir — referenced by ADR-137, NOT imported"
---

# MEMOIR-PILOT-PRECOND-02 — Bounded retention + purge (config-as-data)

> **Verifiable governance CONTRACT, not an implementation and NOT a real config file.** It defines WHAT
> Precondition #2 of ADR-137 must guarantee and HOW it is proven "config, not hardcoded" + "bounded". No
> runtime, no code, no config-stub, no secret, no import of `github.com/zhangfengcdt/memoir`. Building it
> (engine + an actual operator-owned config) is the subsequent gated work item.

## 1. Scope

Applies to the **Memoir factory-only pilot** under the **ADR-137 / ADR-136 envelope** (factory fork
only; project fork disabled by default; one-substrate-per-fork). Governs how long captured memory may
live and how it is purged. It does **not** authorise a pilot.

## 2. Config-as-data principle

Retention/purge parameters are **DATA, operator-owned, never hardcoded** (Configuration-over-Hardcoding,
CLAUDE.md §10). This document specifies the **required field SCHEMA as a contract only** — it creates
**no real config file**. The eventual config (a separate gated work item) MUST provide at least:

| Field | Meaning | Constraint |
|---|---|---|
| `max_age` | maximum retention age of any entry | required; finite (e.g. ISO-8601 duration); no "infinite" |
| `max_entries` | maximum stored entries (per fork) | required; finite positive integer |
| `purge_schedule` | cadence of the purge job | required; finite interval (e.g. cron/duration) |
| `scope` | retention/purge applicability | required; **= fork + perimeter** (ADR-117); no cross-perimeter |

At least one of `max_age` / `max_entries` MUST bind (both MAY). Values live in operator-owned config,
not in code.

## 3. No indefinite accumulation (bounded) — fail-closed

A **finite upper bound by time AND/OR volume is mandatory.** If the config is **absent, unparseable,
unbounded, or schema-invalid**, the pilot is **fail-closed**: **no pilot start / no writes**
(deny-by-default). There is no default-unbounded fallback; "no valid retention config" ⇒ "no memory".

## 4. Purge correctness

- **Irreversible** — a purged entry is **not recoverable** by any Memoir surface: not via rollback,
  blame, checkout, or merge. Purge removes the content and its versioned history within scope.
- **Consistent with redaction (PRECOND-01, ADR-137 lines 79-80)** — purged content, like redacted
  content, **cannot be resurrected through rollback/blame**; the two guarantees compose (redaction at
  write + purge at retention boundary).
- **Bound-triggered** — exceeding `max_age` or `max_entries` MUST trigger purge of the oldest/over-limit
  entries; the bound is enforced, not advisory.

## 5. Scope — per fork + perimeter

Retention and purge operate **strictly per fork + perimeter (ADR-117)**: factory-fork memory is retained
and purged independently of any (default-disabled) project fork; **no cross-perimeter retention** and no
shared store. A purge in one fork never reads or writes another.

## 6. Verification criteria — "config, not hardcoded" + "bounded"

Precondition #2 is **DONE only when** all hold, as a **held-out** suite passing the **ADR-135 gate with
zero regressions**:

1. **No hardcoded values** — retention/purge parameters are read from operator-owned config; a test
   proves changing the config changes behaviour and that **no bound is baked into code**.
2. **Bounded** — exceeding `max_age` / `max_entries` triggers purge (entries beyond the bound are gone).
3. **Fail-closed on bad config** — absent / unparseable / unbounded / invalid config ⇒ **no writes / no
   pilot start** (deny-by-default); fault-injection confirms no default-unbounded path.
4. **Purge irreversibility** — post-purge, rollback/blame/checkout/merge cannot recover purged content
   (composes with PRECOND-01).
5. **Scope isolation** — retention/purge stay within fork+perimeter; no cross-perimeter effect.

## 7. Sign-off

Marking Precondition #2 = **DONE** requires **operator + IronClaw (security-review) sign-off**, recorded
in the ledger/ADR trail. Without **both**, #2 stays open and **no Memoir runtime may start** (fail-closed).

## 8. Non-goals (explicit)

Specification only. Ships **no** retention engine, **no real config file/stub**, no purge job, no Memoir
deployment. Implementation (engine + an actual operator-owned config + tests) is a **subsequent gated
work item** under ADR-137, itself subject to this contract and ADR-135.

## Anchors

- ADR-137 (Pilot Entry Preconditions; #2 = this), MEMOIR-PILOT-PRECOND-01 (redaction; sibling),
  ADR-136 (envelope), ADR-135 (held-out gate), ADR-117 (perimeter), ADR-130/127 (no authority / Tier-1),
  CLAUDE.md §10 (Configuration-over-Hardcoding). External: `github.com/zhangfengcdt/memoir` (referenced
  by ADR-137, NOT imported). Enforcement = CI gates + these ADRs; this spec carries no runtime/config/secret.
