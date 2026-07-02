# Fleet Conformance Audit — measured state @ `origin/main` `e44aae7` (2026-07-02)

> **Status:** read-only audit register (non-canonical record). **Additive, pointer-first (ADR-102).**
> **This document is NOT an activation, dedup, or rollout order.** It records reconnaissance facts measured
> against a single commit; **strategic remediation is intentionally deferred to operator direction.** It edits
> no passport, activates no agent, executes no dedup, invents no repo, and asserts no runtime/deployment fact.

## §0. Scope & method
- **Pin:** all counts are measured against `origin/main` at commit **`e44aae7`** (2026-07-02). This is a
  **point-in-time snapshot**; a later fleet change does not retroactively invalidate it — re-run the sweep to
  refresh.
- **Method:** read-only `git ls-tree -r` (file inventory) and `git show <commit>:<path>` / `git grep`
  (field/status tallies) against the pinned commit. **No file was mutated, no agent invoked, no runtime
  inspected.**
- **What was NOT done:** no passport/soul/agent edit; no activation; no dedup execution; no ADR/project/
  perimeter change; no runtime/deployment probing.

## §1. Fleet inventory
| Class | Location | Count |
|---|---|---|
| Factory-side agents | `.claude/agents/*.md` | **4** (`controller`, `inspector-agent`, `openclo`, `safeguarding-agent`) |
| Project / bank passports | `agents/passports/**/*.yaml` | **70** |
| Souls | `agents/souls/*.md` | **20** |

## §2. Activation reality
Measured `status:` field across the 70 passports:

| Value | Count |
|---|---|
| `PROPOSED` | **41** |
| `active` | **10** |
| `ACTIVE` | **3** |
| — activated total — | **13** |
| no parseable top-level `status` | **16** |

- 54 passports carry a parseable top-level `status`; **16 are silent** (see risk note — state is **not
  inferred** for these; could be nested or mis-keyed).
- **Casing inconsistency finding:** `active` (10) vs `ACTIVE` (3) — the same activated state written two ways;
  a conformance gate would normalise this.
- **This is a conformance observation, NOT an activation instruction.** No agent is activated by this document.

## §3. ADR-102 duplication finding
- **Duplicate `agent_id: banxe_aml_orchestrator`** declared in **two** files (one identity, two passports):
  - `agents/passports/aml/banxe_aml_orchestrator.yaml`
  - `agents/passports/banxe_aml_orchestrator.yaml`
- `agents/passports/aml_orchestrator.yaml` carries a **distinct** id (`aml_orchestrator`) → **naming-proximity
  only, NOT an id collision.**
- **Resolution — keep / merge / delete = `[BLOCKING: operator]`.** Per ADR-102 the source-of-truth must be
  chosen and **every consumer enumerated before any action**; uncertainty about a hidden consumer is
  fail-closed and escalated. **No dedup is executed in this PR; no passport is edited or deleted here.**

## §4. Self-improvement mandate conformance
- **0 / 70** passports declare any self-improvement / lesson-capture / skill-evolution field.
- This is a **measurable gap, not a failed implementation effort.** The mandate
  (`docs/governance/SELF-IMPROVEMENT-MANDATE.md`, #971 / IL-815) is **in force for the factory fork**; its
  **project-side closure is pending the agent-harness locus.**
- **Blocker (explicit):** the project-side self-improvement mechanism requires an agent-harness project-fork
  locus, which is **`[BLOCKING: operator / ADR-136-gated]`** — the single operator decision before any
  project-side conformance work. No locus is invented here. The gap is attributable to the **pending locus**,
  not to agent non-performance.

## §5. Hermes / OpenClaw-family status
- **Hermes:** appears **only in ADR/ledger prose** (ADR-126/127/128 and the ledger). **No runtime or config
  artifact exists on `main`** → **governed, not configured.**
- **OpenClaw family:** mention counts measured on `main` — Ruflo 568, MetaClaw 342, OpenClaw 283, MiroFish 140,
  IronClaw 77 — are **documentation references, not runtime proof.** **No runtime/deployment fact is asserted;
  the counts measure prose, not deployments.**

## §6. Honesty boundary
- **Facts recorded** — the counts and findings above are measured, not inferred.
- **Strategic remediation intentionally deferred** to operator direction — activation policy, dedup resolution,
  and mandate-conformance schema are governance calls, **not** made here.
- **This document must not be read as an activation, dedup, or rollout order.** It changes no fleet state.

## Anchors
`docs/governance/SELF-IMPROVEMENT-MANDATE.md` (#971/IL-815 — the mandate whose §4 gap is measured here) ·
`docs/governance/FACTORY-PROJECT-PROJECTION-MODEL.md` (#967; Appendix A #968 / Appendix B #971 — projection &
factory-fork framing) · `docs/governance/FACTORY-LESSON-CAPTURE.md` (#951 — the factory-side self-improvement
mechanism) · `docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md` (the Duplication Audit
discipline the §3 finding defers to) · `docs/adr/ADR-136-agentmemory-shared-memory-substrate.md` (memory
read-only w.r.t. authority; the locus gate) · `docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md` ·
`docs/adr/ADR-127-hermes-factory-delegation-contract.md` · `docs/adr/ADR-128-banking-agents-hitl-matrix.md`
(Hermes governance — cited, not restated). Operator reconnaissance directive 2026-07-02 (record measured fleet
conformance conservatively; defer remediation).
