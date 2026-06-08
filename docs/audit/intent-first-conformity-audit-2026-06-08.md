# Intent-First Conformity Audit — 8-Repo Fan-Out (2026-06-08)

> **Type:** Governance audit (read-only fan-out, materialized).
> **Anchor IL:** IL-152.
> **Companion:** `docs/roadmap/intent-first-migration-roadmap-2026-06-08.md`.
> **Method:** Read-only 8-repo fan-out this session. Every claim is tagged `[FACT]`
> (verified against a cited path / API), `[INFERENCE]` (reasoned from facts, not
> directly observed), or `[UNKNOWN]` (could not be verified this session).
> Scores reflect **runtime conformity to the Intent-First model** (ADR-045..049,
> 053..055), NOT merge-state of artefacts.
>
> **Verdict in one line:** the Intent-First model is **contract-complete,
> runtime-incomplete** (~45% overall). The full adoption is **hard-gated by
> ADR-049 §D6** (LLM-orchestration substrate, Terminal-A infra). `AGENT_ROUTING_ENABLED`
> stays **OFF** until S1 lands.

---

## A. Executive verdict

### A.1 Per-repo conformity scores

| # | Repo | Conformity | One-line state |
|---|------|-----------|----------------|
| 1 | `banxe-payment-core` | **80%** | `[FACT]` 3 CONTRACT ports + 3 client-facing agents + `_lineage` in `main`; gate chain coded; runtime sink + L1 missing |
| 2 | `banxe-emi-stack` | **72%** | `[FACT]` 6 CONTRACT ports + 6 client-facing agents in `main`; deep L3 compliance present; observability/producers absent |
| 3 | `banxe-architecture` | **70%** | `[FACT]` ADRs 045-049/053-055 + canon + IL governance present, but **prose-only** (not executable/enforced) |
| 4 | `banxe-business-processes` | **35%** | `[FACT]` 21 ArchiMate processes exist; `[INFERENCE]` not machine-resolvable as `process_ref` (ADR-048 unbuilt) |
| 5 | `banxe-monitoring` | **25%** | `[FACT]` monitoring stack exists; `[INFERENCE]` zero Intent-First (lineage/cost/confidence) observability wired |
| 6 | `banxe-platform` | **25%** | `[INFERENCE]` infra primitives present; no DecisionRecorder sink / ClickHouse lineage store landed |
| 7 | `banxe-ui` | **20%** | `[FACT]` two screen-first UIs; `[FACT]` no chat / intent surface; agents not client-reachable |
| 8 | `banxe-ai-infrastructure` | **15%** | `[FACT]` ADR-049 §D6 LLM-orchestration gateway **unbuilt** — the critical-path blocker |

**Overall: ~45% — "contract-complete, runtime-incomplete."**
`[INFERENCE]` The contract surface (ports, masks, ADRs, lineage primitive) is
substantially in place; the runtime that would make Intent-First *operate*
(L1 classifier/router, lineage sink, observability, governance enforcement,
LLM substrate) is largely unbuilt.

### A.2 Top-10 gaps (ranked)

1. **`[FACT]` ADR-049 §D6 LLM-orchestration substrate is unbuilt** — *critical path*.
   No LiteLLM + Postgres + GPU routing in `banxe-ai-infrastructure`. Everything
   downstream (live L2, L1 routing) is gated on this. `AGENT_ROUTING_ENABLED=false`.
2. **`[FACT]` No L1 Intent Layer** — no client-intent classifier/router exists;
   intents cannot be captured, classified, or dispatched to masks.
3. **`[INFERENCE]` Business Process Repository (BPR) is not resolvable** — ADR-048
   `intent → process_ref` resolution is unbuilt; the 21 ArchiMate processes in
   `banxe-business-processes` are documentation, not a queryable registry.
4. **`[INFERENCE]` DecisionRecorder sink + ClickHouse store missing** — ADR-046
   `AgentDecisionRecord` is produced in-agent but has nowhere durable to land
   (the injected recorder is a seam with no backing sink).
5. **`[FACT]` Governance is prose-only** — ADRs/canon/IL describe rules
   (cost bands, compliance gates, HITL thresholds) as text, not as executable,
   CI-enforced schemas/policies.
6. **`[INFERENCE]` Compliance / confidence / cost producers absent** — the gate
   chain reads compliance/confidence/cost-cap signals, but no runtime producers
   emit them; defaults risk silently passing.
7. **`[FACT]` Two screen-first UIs, no chat surface** — `banxe-ui` is
   screen-navigation-first; there is no conversational / intent entry point, so
   the L1→L2 path has no client-facing front door.
8. **`[INFERENCE]` Zero Intent-First observability** — `banxe-monitoring` has no
   lineage-rate, cost-cap, confidence-band, or decision-record dashboards/alerts.
9. **`[FACT]` Agents not client-reachable** — the 9 L2 agents are
   governance-complete and unit-tested but not exposed to any client channel
   (no API opened, routing off).
10. **`[INFERENCE]` Bug-debt cluster** — concrete defects to clear before live:
    Hyperswitch adapter missing `await`; `PaymentsAgent` lacks idempotency key;
    `CostWindow` race condition; SAR→NCA submission is a stub; dual-safeguarding
    path duplication.

### A.3 Top-10 reusable assets (no-loss inventory)

1. **`[FACT]` `_lineage` primitives** — consolidated lineage helper (IL-135 DRY)
   in both code repos; ADR-046 §D5 fields ready.
2. **`[FACT]` 9 client-facing masks** — Payments, FXExchange, Wallet (payment-core)
   + KYC, Notification, CRM, Cards, Analytics, Statements (emi-stack).
3. **`[FACT]` 9 CONTRACT ports** — WalletPort, PartnerPort, ExchangePort
   (payment-core) + KYCProviderPort, NotificationProviderPort, CRMProviderPort,
   CardPort, AnalyticsPort, StatementPort (emi-stack).
4. **`[FACT]` Deep emi-stack L3 compliance** — existing domain service-agents with
   AML/KYC/CASS logic, now wired behind ports as adapters (untouched).
5. **`[FACT]` ADRs 045-049 + 053-055 + canon + IL** — the full Intent-First
   conceptual + governance corpus.
6. **`[FACT]` 21 ArchiMate processes** — `banxe-business-processes`; the raw
   material for a resolvable BPR.
7. **`[FACT]` L4 adapters** — ledger/infra adapters behind ports (Midaz etc.).
8. **`[FACT]` Monitoring stack** — `banxe-monitoring` base (extensible to
   Intent-First metrics).
9. **`[FACT]` UI components** — `banxe-ui` component library (reusable under a
   chat-first shell).
10. **`[FACT]` Factory pipeline** — the spec-build factory that produced all of
    the above; the delivery mechanism for the roadmap.

---

## B. Per-repo audit matrix

Legend: *Drift* = divergence from Intent-First target; *Tails* = loose ends to
close; *Blocker* = what gates progress; *Sprint* = where addressed (see §D).

| Repo | Current | Target (Intent-First) | Alignment | Drift | Tails | Migration | Blocker | Sprint |
|------|---------|-----------------------|-----------|-------|-------|-----------|---------|--------|
| `banxe-payment-core` | 3 ports + 3 agents + `_lineage`, gate chain coded `[FACT]` | L2 live behind L1, lineage landing in sink | 80% | No live sink; no L1 feeder | idempotency key; Hyperswitch `await`; `CostWindow` race | Additive: wire injected recorder to real sink; bugfixes in place | §D6 substrate; sink (S4) | S4, S5 |
| `banxe-emi-stack` | 6 ports + 6 agents; deep L3 compliance `[FACT]` | Compliance producers emit real signals; SAR→NCA real | 72% | Producers absent; SAR→NCA stub `[FACT]`; dual safeguarding | compliance signal producers; SAR submission; safeguarding dedup | Additive producers + wiring; transform-in-place | Compliance infra (S6) | S5, S6 |
| `banxe-architecture` | ADRs/canon/IL prose `[FACT]` | Executable governance schemas + CI gates | 70% | Prose-only `[FACT]` | schema-ize cost/compliance/HITL bands; CI enforcement | Render prose → schema; add guardian hooks | none (Central-buildable) | S2 |
| `banxe-business-processes` | 21 ArchiMate processes `[FACT]` | Machine-resolvable BPR (`intent→process_ref`) | 35% | Not resolvable `[INFERENCE]` | build registry; resolver API; process_ref IDs | Index existing processes → resolvable store | ADR-048 build | S3 |
| `banxe-monitoring` | base stack `[FACT]` | Intent-First observability (lineage/cost/confidence) | 25% | zero IF metrics `[INFERENCE]` | dashboards; alert tiers; lineage-rate monitor | Additive dashboards over sink data | sink exists (S4) | S4 |
| `banxe-platform` | infra primitives `[INFERENCE]` | DecisionRecorder sink + ClickHouse lineage store | 25% | no sink landed `[INFERENCE]` | provision ClickHouse; sink service; retention | Stand up sink; injected seam plugs in | Terminal-A infra | S4 |
| `banxe-ui` | 2 screen-first UIs, no chat `[FACT]` | Chat-first shell + decision/lineage surfaces | 20% | no chat surface `[FACT]`; agents unreachable | decision view; chat shell; reuse components | Add chat shell over existing components | L1 + agents live | S7, S8 |
| `banxe-ai-infrastructure` | §D6 gateway unbuilt `[FACT]` | LiteLLM + Postgres + GPU routing | 15% | critical-path gap `[FACT]` | build gateway; routing; model pool | New build (Terminal-A) | none (this IS the blocker) | S1 |

---

## C. Migration plan — no-loss principles & sequencing

### C.1 No-loss principles

1. **Transform-in-place, not rewrite.** `[INFERENCE]` Every reusable asset
   (ports, masks, `_lineage`, L3 compliance, L4 adapters) is evolved where it
   lives. No repo is rebuilt from scratch.
2. **Additive schema only.** New fields/tables/records are added; existing
   contracts are never broken or removed in a migration step.
3. **Injected-DecisionRecorder seam = sink lands with zero agent edits.**
   `[FACT]` The 9 agents already take a `DecisionRecorder` as an injected
   interface. When the real sink (S4) is provisioned, it plugs into that seam
   with **no edits to agent code** — the single most valuable design property
   for no-loss migration.
4. **Equivalence-test before any retirement.** No legacy path is retired until a
   test proves the new path is behaviourally equivalent.
5. **Ports & masks are portable.** `[INFERENCE]` The CONTRACT ports and masks are
   transport-agnostic; they move under L1/chat surfaces without rework.

### C.2 Sequencing logic — 7 ordering axes

The 8-sprint order (§D) is the topological sort over these axes:

1. **Critical-path-first** — §D6 substrate (S1) unblocks everything live.
2. **Enforceability-before-enforcement** — executable governance (S2) before
   wiring producers that must obey it.
3. **Resolvability-before-routing** — BPR resolvable (S3) before L1 routes
   intents to `process_ref`.
4. **Sink-before-observability** — lineage sink (S4) before dashboards (S4 tail)
   and before producers emit at volume (S5).
5. **Producers-before-compliance-wiring** — confidence/cost/compliance producers
   (S5) before full compliance wiring + debt cleanup (S6).
6. **Backend-before-frontend** — L1 + agents live before UI decision/chat
   surfaces (S7, S8).
7. **Debt-cleared-before-convergence** — bug-debt (S5/S6) cleared before the
   chat-first convergence (S8) exposes paths to clients.

---

## D. 8-sprint roadmap

| Sprint | Objective | Repos | Durable artefacts | Acceptance | Deps | Tails closed |
|--------|-----------|-------|-------------------|------------|------|--------------|
| **S1** | ADR-049 §D6 LLM-orchestration gateway | `ai-infrastructure`, `platform` | LiteLLM+Postgres deploy, GPU routing config, gateway runbook | Gateway routes a test inference; health green | — | §D6 critical-path gap (#1) |
| **S2** | Executable governance schemas | `architecture` | cost/compliance/HITL band schemas + CI guardian hooks | CI fails on a defaults-PASS / missing-record case | — | prose-only governance (#5) |
| **S3** | Resolvable Business Process Repository | `business-processes` | process registry, `process_ref` IDs, resolver API (ADR-048) | `intent→process_ref` resolves for ≥1 capability | S2 | BPR not resolvable (#3) |
| **S4** | Lineage sink + observability | `platform`, `monitoring` | ClickHouse store, DecisionRecorder sink, lineage/cost dashboards | A real `AgentDecisionRecord` lands in sink; lineage-rate>0 | S1 | sink+ClickHouse (#4); zero observability (#8) |
| **S5** | L1 classifier/router + producers + bugfixes | `payment-core`, `emi-stack` | L1 intent classifier/router, confidence/cost/compliance producers, bugfix commits | Intent classified→routed; producers emit; bugs fixed w/ tests | S1,S3,S4 | no L1 (#2); producers absent (#6); bug-debt (#10) |
| **S6** | Compliance wiring + debt cleanup | `emi-stack`, `platform` | SAR→NCA real submission, safeguarding dedup, compliance signal wiring | SAR submits to NCA (test env); single safeguarding path | S2,S5 | SAR stub, dual safeguarding (#10); compliance producers (#6) |
| **S7** | UI decision view + chat shell | `ui` | decision/lineage view, chat shell scaffold (reusing components) | Client sees a decision record; chat shell renders | S4,S5 | screen-first only (#7 partial); agents unreachable (#9 partial) |
| **S8** | Chat-first convergence | `ui`, `payment-core`, `emi-stack` | chat-first front door wired to L1→L2; capability exposure | A client intent flows chat→L1→L2→port→lineage end-to-end | S5,S6,S7 | screen-first (#7); agents not client-reachable (#9) |

---

## E. Canon recommendations

### E.1 Factory tracking
`[INFERENCE]` Track each sprint as its own IL anchor (**IL-15x per sprint**),
produced through the factory, with the per-sprint 3-verifiable-facts checkpoint
(below) as the CLOSE proof.

### E.2 Five watchdog / guardian hooks (CI-enforced)

1. **no-mask-without-AgentDecisionRecord-schema-test** — a new mask cannot merge
   without a test proving it emits a schema-valid `AgentDecisionRecord`.
2. **fail-CI-if-compliance-defaults-PASS** — CI fails if any compliance gate can
   return PASS purely from a default (no real producer signal).
3. **alert-if-lineage-rate-zero** — production alert if the lineage sink ingest
   rate drops to zero (silent producer failure).
4. **cost-cap-breach-alert-tier** — tiered alert when an agent approaches/breaches
   its ADR-047 cost cap.
5. **process_ref-resolvability-check-in-spec-build** — spec-build refuses a spec
   whose declared `process_ref` does not resolve against the BPR.

### E.3 Per-sprint 3-verifiable-facts checkpoint
Each sprint CLOSE must record exactly **3 independently verifiable facts**
(e.g. a health endpoint 200, a CI run that fails on a seeded violation, a record
visible in the sink). Prose-only "DONE" is not acceptance.

---

## Appendix — merge-state hardening (2026-06-08)

> The session-original audit carried merge-state as `[UNKNOWN]`. This is now
> **confirmed and upgraded to `[FACT]`**.

`[FACT]` Verified via the GitHub contents API on 2026-06-08: **all 9 CONTRACT
ports + 9 client-facing agents + `_lineage.py` are present in `main`** of both
`banxe-payment-core` and `banxe-emi-stack`.

- `banxe-payment-core/main`: WalletPort, PartnerPort, ExchangePort; Payments,
  FXExchange, Wallet agents; `_lineage.py`. `[FACT]`
- `banxe-emi-stack/main`: KYCProviderPort, NotificationProviderPort,
  CRMProviderPort, CardPort, AnalyticsPort, StatementPort; KYC, Notification,
  CRM, Cards, Analytics, Statements agents; `_lineage.py`. `[FACT]`

**The conformity scores in §A are unchanged** — they measure *runtime
incompleteness*, not merge-state. Artefacts being in `main` does not make the
Intent-First model operate; the §A gaps (substrate, L1, sink, producers,
observability, client surface) remain the determinants of the ~45% overall score.

### Open governance item (do NOT fix in this audit task)
`[FACT]` **ADR-049 status hygiene** — frontmatter says `ACCEPTED` while the body
text still reads `PROPOSED`. This is a status-consistency defect to resolve as a
**separate** governance-fix task (not part of this audit/roadmap materialization).
