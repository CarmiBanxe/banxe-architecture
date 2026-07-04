---
il_ts: 2026-07-04T23:47:38Z
session_id: agent-factory-adr160c-fg-scope-separation
source: agent-factory
status: PROPOSED
---

# ADR-160 §F/§G scope-separation amendment (operator ruling 2026-07-05)

## What

Resolve the §F/§G governance conflict flagged in ADR-160's Renumber & Status Note, per operator ruling
**"scope-separate, no amendment to ADR-154"**: two distinct arbiter roles coexist —
- **Factory** (= Terminal A / LEFT) = shared-space **concurrency** arbiter (IL/branch/ledger/worktree) per **ADR-154** (unchanged);
- **Central** (a *separate* actor per **ADR-153**, NOT Terminal A) = **canon / write-gate** authority per this ADR.

## Edits (doc-only, ADR-160)

- §G ROLES: "GUARDIAN OF CANON | Terminal A (Central)" → **Central**; Executor = **Factory (Terminal A)** with
  the ADR-154 concurrency-arbiter role noted as a distinct scope; accountability chain Factory→**Central**→Operator.
- Added a **Scope Separation (ADR-153/154)** note — the two arbiter roles do not conflict; ADR-154 referenced, not amended.
- §F: axis renamed **Central↔Factory** (was self-referential "A↔Factory"); A→Factory→**Central→Factory**, Factory→A→**Factory→Central**; added ADR-153 alias-note callout.
- §H tri-party: **Central↔Factory↔TRADING-001** (Central = hub); all **B→A** direction labels → **B→Central**; guardian refs → Central.
- Updated the Renumber & Status Note: this item now **RESOLVED** (was deferred).

## Boundaries

Doc-only, prepare-only. No change to ADR-153/154 (referenced only). No hook/config/runtime change. Guardian
naming corrected per ADR-153 (A=Factory=LEFT; Central=separate; B=TRADING-001=RIGHT). IL minted redis-serialized
at ratification (REDIS_HOST=100.68.102.48).

## Anchors

`docs/adr/ADR-160-bilateral-orchestration-write-gate.md` · ADR-153 (topology/alias) · ADR-154 (concurrency arbiter — unchanged) · operator ruling 2026-07-05.
