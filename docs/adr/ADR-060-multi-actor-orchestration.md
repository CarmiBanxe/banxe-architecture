# ADR-060: Multi-actor orchestration — namespaced branches, merge queue, event-sourced shards

- Status: Accepted
- Date: 2026-06-09
- Supersedes: none
- Related: ADR-056 (ledger-coupling), ADR-057 (ledger append-only), ADR-059 (per-session shards)

## Context

Multiple independent actors write to the same repositories, branches and ledger:

- central terminal — operates through the factory (orchestrated);
- right terminal — operates autonomously ("as it pleases", not orchestrated);
- factory — itself mutates as a result of its work.

With several writers over shared mutable state and no single arbiter of ordering, conflicts arise around branches, naming and repositories (merge races, stale-green PRs, name collisions, lost updates). ADR-059 already removed the worst case for the ledger by making INSTRUCTION-LEDGER.md a generated read-only projection and routing new entries to append-only per-session shards. This ADR lifts that same principle (single-writer + append-only + generated projection + serialized merge) from the ledger up to the whole branch/repo orchestration layer.

## Decision

Adopt a minimal orchestration stack on top of the existing guardian gates:

### 1. Merge Queue — single arbiter of merge order

GitHub native Merge Queue is the ONLY mechanism that serializes merges into `main`. PRs are re-tested against the actual tip of `main` one at a time, eliminating the "green PR went stale before merge" race. All gating workflows therefore subscribe to the `merge_group` event so they run inside the queue.

### 2. Namespaced branches — uniqueness by construction

Canonical branch namespace: `agent/<actor>/<id>/<slug>`

- `actor` in {`central` | `right` | `factory`} — one namespace per writer;
- `id` = ULID / UUIDv7 / session id (monotonic, collision-free by construction);
- `slug` = kebab-case task descriptor.

Enforced by the `guardian-branch-naming` gate. Allow-listed automation prefixes: `dependabot/`, `renovate/`, `revert/`. The autonomous "right" terminal is isolated to its own namespace; its freedom cannot collide with others and is serialized only through the merge queue.

### 3. Single-writer per resource — concurrency groups

Any CI job that touches the ledger projection / monolith runs under a `concurrency` group with `cancel-in-progress: false`, serializing writes per resource. Runtime leases (Redis/etcd/Consul) cover non-CI writers when introduced.

### 4. Event sourcing + generated projection

The source of truth is the ordered append-only log of per-session shards under `ledger/entries/` (ADR-059). `INSTRUCTION-LEDGER.md` is a deterministic projection, never hand-edited. Every actor only APPENDS events to its own namespace, so write conflicts on shared files cannot occur. The factory, since it mutates during operation, writes its own state changes as events in the `factory/` namespace (outbox pattern) rather than editing shared artifacts directly.

### 5. Optimistic concurrency — stale-base detection

Gates carry `base.sha` / `head.sha`. A stale base (PR base != current `main`) is reported as a WARNING; actual serialization and rebase are delegated to the Merge Queue (no duplicate hard-fail mechanism).

### 6. Long multi-step factory processes — Temporal / saga (deferred)

Durable, deterministic ordering with compensations for long-running factory workflows is delegated to a Temporal-based saga orchestrator. This is a runtime concern: the decision is recorded here; deployment is tracked as a follow-up in `banxe-ai-infrastructure` and is OUT OF SCOPE for this architecture repo.

## Gates

- `guardian-branch-naming` (this ADR) — branch namespace convention.
- `guardian-ledger` (ADR-056), `ledger-append-only` (ADR-057), `guardian-ledger-shards` (ADR-059 S3) — unchanged, run in merge queue via `merge_group`.
- `ledger-build` — now single-writer guarded via `concurrency`.

## Consequences

- (+) Branch/name/merge conflicts removed by construction, not by convention.
- (+) Autonomous actors are contained without requiring their cooperation.
- (+) Consistent with ADR-056/057/059 invariants (I-28 append-only).
- (-) Merge Queue must be enabled in repo Settings (branch protection) — operational step.
- (-) Temporal deployment remains a separate infrastructure task.
