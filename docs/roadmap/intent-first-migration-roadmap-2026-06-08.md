# Intent-First Migration Roadmap (2026-06-08)

> **Type:** Governance roadmap (derived from the conformity audit).
> **Anchor IL:** IL-152.
> **Source:** `docs/audit/intent-first-conformity-audit-2026-06-08.md` (Sections C + D + E).
> **Verdict:** audit **READY**; full Intent-First adoption **NOT READY** —
> hard-gated by ADR-049 §D6 (LLM-orchestration substrate, Terminal-A infra).
> **`AGENT_ROUTING_ENABLED` stays OFF until S1 is done.**

This roadmap takes the 8-repo audit from "contract-complete, runtime-incomplete"
(~45%) to an operating, chat-first Intent-First bank without losing any existing
asset. It is the executable companion to the audit's Sections C (no-loss
migration), D (8-sprint plan), and E (per-sprint checkpoints).

---

## 1. No-loss migration principles

1. **Transform-in-place, not rewrite** — evolve every reusable asset where it
   lives; rebuild no repo from scratch.
2. **Additive schema only** — add fields/tables/records; never break or remove an
   existing contract in a migration step.
3. **Injected-DecisionRecorder seam = sink lands with zero agent edits** — the 9
   agents already accept a `DecisionRecorder` interface; the real sink (S4) plugs
   in with no agent-code changes. This is the keystone no-loss property.
4. **Equivalence-test before any retirement** — no legacy path retires until a
   test proves the new path is behaviourally equivalent.
5. **Ports & masks are portable** — CONTRACT ports and masks are
   transport-agnostic and move under L1/chat surfaces without rework.

---

## 2. Sequencing logic — 7 ordering axes

The sprint order is the topological sort over:

1. Critical-path-first (S1 substrate unblocks all live operation).
2. Enforceability-before-enforcement (S2 executable governance precedes wired producers).
3. Resolvability-before-routing (S3 BPR resolvable precedes L1 `intent→process_ref`).
4. Sink-before-observability (S4 sink precedes dashboards and at-volume producers).
5. Producers-before-compliance-wiring (S5 producers precede S6 compliance wiring).
6. Backend-before-frontend (L1 + agents live precede S7/S8 UI surfaces).
7. Debt-cleared-before-convergence (bug-debt cleared before S8 exposes paths to clients).

---

## 3. 8-sprint roadmap

| Sprint | Objective | Repos | Durable artefacts | Acceptance | Deps | Tails closed |
|--------|-----------|-------|-------------------|------------|------|--------------|
| **S1** | ADR-049 §D6 LLM-orchestration gateway | `ai-infrastructure`, `platform` | LiteLLM+Postgres deploy, GPU routing config, gateway runbook | Gateway routes a test inference; health green | — | §D6 critical-path gap |
| **S2** | Executable governance schemas | `architecture` | cost/compliance/HITL band schemas + CI guardian hooks | CI fails on a defaults-PASS / missing-record case | — | prose-only governance |
| **S3** | Resolvable Business Process Repository | `business-processes` | process registry, `process_ref` IDs, resolver API (ADR-048) | `intent→process_ref` resolves for ≥1 capability | S2 | BPR not resolvable |
| **S4** | Lineage sink + observability | `platform`, `monitoring` | ClickHouse store, DecisionRecorder sink, lineage/cost dashboards | Real `AgentDecisionRecord` lands in sink; lineage-rate>0 | S1 | sink+ClickHouse; zero observability |
| **S5** | L1 classifier/router + producers + bugfixes | `payment-core`, `emi-stack` | L1 intent classifier/router, confidence/cost/compliance producers, bugfix commits | Intent classified→routed; producers emit; bugs fixed w/ tests | S1,S3,S4 | no L1; producers absent; bug-debt |
| **S6** | Compliance wiring + debt cleanup | `emi-stack`, `platform` | SAR→NCA real submission, safeguarding dedup, compliance signal wiring | SAR submits to NCA (test env); single safeguarding path | S2,S5 | SAR stub, dual safeguarding |
| **S7** | UI decision view + chat shell | `ui` | decision/lineage view, chat shell scaffold (reusing components) | Client sees a decision record; chat shell renders | S4,S5 | screen-first only; agents unreachable (partial) |
| **S8** | Chat-first convergence | `ui`, `payment-core`, `emi-stack` | chat-first front door wired to L1→L2; capability exposure | A client intent flows chat→L1→L2→port→lineage end-to-end | S5,S6,S7 | screen-first; agents not client-reachable |

---

## 4. Per-sprint 3-verifiable-facts checkpoints

Each sprint CLOSE must record exactly **3 independently verifiable facts**.
Prose-only "DONE" is not acceptance.

| Sprint | The 3 verifiable facts (CLOSE proof) |
|--------|--------------------------------------|
| **S1** | (a) gateway health endpoint 200; (b) a test inference routed to a GPU model returns; (c) Postgres-backed routing config persisted. |
| **S2** | (a) a schema file validates a sample band record; (b) CI fails on a seeded compliance-defaults-PASS; (c) CI fails on a mask without an AgentDecisionRecord schema-test. |
| **S3** | (a) resolver returns a `process_ref` for ≥1 capability; (b) an unknown intent resolves to "no match" (not a default); (c) spec-build rejects an unresolvable `process_ref`. |
| **S4** | (a) a real `AgentDecisionRecord` is visible in ClickHouse; (b) lineage-rate metric > 0 on a dashboard; (c) a cost-cap dashboard renders a non-zero series. |
| **S5** | (a) a sample intent is classified+routed; (b) a producer emits a real confidence/cost/compliance signal into a record; (c) each bugfix has a failing-then-passing test. |
| **S6** | (a) a SAR submits to the NCA test endpoint; (b) only one safeguarding path executes (dedup proven); (c) a compliance gate PASS is backed by a real producer signal (not default). |
| **S7** | (a) a client view renders a real decision record; (b) chat shell renders and accepts input; (c) a reused UI component is mounted under the chat shell. |
| **S8** | (a) an end-to-end intent flows chat→L1→L2→port→lineage; (b) the resulting record is queryable in the sink; (c) ≥1 capability is exposed chat-first to a test client. |

---

## 5. Zone ownership

| Sprint | Primary owner | Rationale |
|--------|---------------|-----------|
| **S1** | **Terminal-A infra** | LLM-orchestration substrate (LiteLLM + Postgres + GPU) is infra. |
| **S2** | **Central via factory** | Governance schemas + CI hooks in `banxe-architecture`. |
| **S3** | **Central via factory** | BPR registry/resolver derives from existing ArchiMate processes. |
| **S4** (sink + ClickHouse) | **Terminal-A infra** | ClickHouse store + sink service are platform infra; dashboards follow. |
| **S5** (producers, bugfixes) | **Central via factory** | L1 classifier, producers, bugfixes are project code. |
| **S6** (compliance infra) | **Terminal-A infra** (with Central wiring) | SAR→NCA + safeguarding infra is heavy infra; Central wires the producers. |
| **S7** | **Central via factory** | UI decision view + chat shell in `banxe-ui`. |
| **S8** | **Central via factory** | Chat-first convergence wiring across code repos. |

> **Note:** S1, S4 (sink+ClickHouse), and S6 (compliance infra) are heavily
> **Terminal-A** infra. S2, S3, S5 (producers, bugfixes), S7, and S8 are
> **Central-via-factory** buildable. Per the no-wait canon, Central proceeds on
> its buildable sprints in parallel and never blocks on Terminal-A.

---

## 6. Hard gate

**`AGENT_ROUTING_ENABLED` remains OFF until S1 is done.** No CONTRACT port is
opened to clients before the §D6 substrate is live and S1's 3 facts are recorded.
Full Intent-First adoption is **NOT READY** until then; the audit itself is READY.
