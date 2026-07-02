# Agent-Fleet Master Plan — unified cycle (findings → intent → sprint → implementation) @ `origin/main` `1d7a18a` (2026-07-02)

> **Status:** governance master plan (consolidation, non-canonical planning record). **Additive, pointer-first
> (ADR-102). COMPLEMENTS `AGENT-FLEET-ROADMAP.md` (#975) — does NOT duplicate it** (it references #975's
> findings-register + 4 sprints and folds in the cross-repo + runtime evidence gathered afterward).
> **It activates no agent, installs no framework, edits no passport / ADR / config / perimeter / project
> code, invents no verified project-repo numbers, bypasses no auth, and excludes legal / ss1 / GUYON by
> construction (I-18/I-20).**

## 1. Scope, method & guards
- **Pin:** consolidated at `origin/main` **`1d7a18a`** (2026-07-02); a point-in-time synthesis.
- **Consolidates:** the roadmap (#975/IL-819) + the cross-repo discovery (parts 1-2) + the runtime probe
  (parts 3-4). Facts are those **verified** in that series; nothing re-derived loosely.
- **Guards (binding):** (a) **I-18/I-20** — `legal-*` / `ss1` / GUYON **excluded**, never read or consolidated;
  (b) **ADR-117 perimeter** — project repos (banxe-emi-stack, banxe-ui, …) are **not read**; their agent-file
  counts are **UNVERIFIED path-substring hits (L-10)**, *not* fleet size; (c) **no auth bypass** — auth-gated
  gateways were not enumerated; (d) **factory authors governance only** — every install/activate/run is
  operator/infra, marked below.

## 2. Consolidated findings (verified this series)
| ID | Finding | Verified how | Prior record |
|---|---|---|---|
| **F-CROSS** | Cross-repo: distinct Banxe repos only (mirrors `~/banxe/`, `wt/temp-clone` dropped); **legal/ss1 excluded (I-18/I-20)**. Project-repo agent counts (banxe-emi-stack et al.) are **UNVERIFIED path-substring (L-10)** — not fleet size; project repos **beyond ADR-117 perimeter, not read**. | parts 1-2 | new |
| **F-ARCH** | banxe-architecture **verified**: 70 bank-passports + 20 souls + 3 swarms + 4 factory agents **+ 10 canon-role passports** (`docs/canon/passports/`: operator, ctio, planner, reviewer, canon-judge, executor, guardian-factory, guardian-project, mlro, schema). | anchored `git ls-tree origin/main` | **NEW completeness finding** (like swarms in #973) |
| **F-RUN-L** | **Runtime (Legion):** 0 agent daemons; LLM infra live (litellm :4000, ollama :11434 — **models, not agents**); tunnel → evo1. The **13 `active` passports are NOT process-backed** — empirical proof of GAP-1. | part 3 (ps/ss/systemctl) | sharpens #975 GAP-1 |
| **F-RUN-E** | **Runtime (evo1 == former GMKtec, verified GLOSSARY):** openclo-moa gateway ("10 Banxe agents") behind an **auth-gated** tunnel (:8080/:4000 → 401); on-demand execution **neither confirmed nor denied** (auth not bypassed). **evo1 IS in the inventory — no missing-host gap** (my initial "GMKtec omitted" hypothesis was **refuted by verification**). | part 4 + GLOSSARY | new (method-lesson) |
| **F-LIVE** | **GAP-2 reinforced empirically:** with no liveness contract, `active` / on-demand-idle / dead are **indistinguishable** → the operator's **"7/24" requirement is not measurable today.** | parts 3-4 | strengthens #974 |
| **F-NAME** | **Naming hygiene:** stale "GMKtec" in `openclaw-tunnel-gmktec.service` + `.claude/agents/openclo.md` — canonical host is **evo1**. Minor; CODEOWNERS-gated. | part 4 | new |
| **F-LEDGER** | **Ledger self-heal (#975):** two sibling shards (820/821) were on main un-sequenced; regen healed them append-only. Possible **guardian-ledger gap** (let a de-synced sequence merge) — infra follow-up. | #975 | new |

> **Method lesson (this series):** F-RUN-E is a live case of **verify-before-asserting** (L-02/L-10) — an
> apparent "missing host" dissolved once GMKtec was verified ≡ evo1. Recorded so the discipline is reused.

## 3. Unified cycle — finding → intent → sprint → implementation
> Sprints A/B/C/D are **#975's** (referenced, not redefined). This table adds the *implementation* column with
> an explicit **executor** (factory-authorable vs operator/infra beyond perimeter). **Nothing is executed here.**

| Finding | Fix-intent | Sprint (#975) | Factory-authorable (here) | Executor beyond perimeter |
|---|---|---|---|---|
| **F-LIVE / GAP-2** (no 7/24 liveness) | define an **agent-scoped liveness contract** so "running" is measurable | **C** | governance spec + build-prompt (schema: run/idle/uptime per agent), ref ADR-126 future-item | **operator/infra:** runtime watcher (project-side); ADR for the contract (operator-gated) |
| **GAP-1 / F-RUN-L** (declared ≠ running) | activate declared agents; make status process-backed | **A** | normalization spec (status/casing) as build-prompt | **operator:** per-agent PROPOSED→ACTIVE via ADR-135 gate; actual run |
| **F-ARCH** (10 canon-role passports unacknowledged) | acknowledge the `docs/canon/passports/` class in the inventory | **A** | inventory-acknowledgment note (this plan; roadmap erratum if wanted) — **not reclassified without operator** | — |
| **GAP-6** (casing / 2 indented / 16 no-status) | normalize status hygiene | **A** | normalization spec/build-prompt | **project:** passport edits |
| **GAP-3 / F-CROSS** (frameworks not installed) | resolve the adopt track — **no new adopt doc** | **B** | advance/defer **ADR-148** via ADR-135; per-framework build-prompt | **operator/infra:** binary **install** of OpenClaw/Hermes/Aider/MetaClaw/MiroFish (dual-use, #949) |
| **GAP-4** (aml dup) | resolve after ADR-102 diff-audit | **D** | the ADR-102 Duplication-Audit write-up (enumerate consumers) | **operator:** source-of-truth + keep/merge/delete |
| **GAP-5** (no fork locus) | stand up agent-harness project-fork locus | **D** | — | **operator (ADR-136-gated):** create locus; then projection #967 |
| **F-NAME** (stale GMKtec) | reconcile to evo1 | **D** | the doc note; `openclo.md` alias line (CODEOWNERS) | operator merge (CODEOWNERS) |
| **F-LEDGER** (guardian-ledger gap) | ensure sequence-desync can't merge | **D** | file the infra follow-up finding | **operator/infra:** guardian gate fix |

## 4. Empirically-driven priority (final order = operator)
**C → A → B → D.** Rationale (evidence, not preference): **C first** because F-LIVE proves 7/24-liveness is
**absent and blocks measuring whether agents "work"** — the operator's own principle; then **A** (activate what
exists + acknowledge canon-role passports), then **B** (framework adoption/install), then **D** (dedup after
diff-audit + fork locus + naming + guardian-ledger). This **re-orders #975's proposal (A→C→B→D) → C→A→B→D** on
the runtime evidence; the operator sets the final order.

## 5. Executor split — who does what (nothing done here)
- **Factory-authorable (prepare-only, this repo, on task):** every governance **spec / build-prompt / ADR-148
  advance / ADR-102 dedup write-up / normalization spec / liveness-contract schema / naming note**. The factory
  **prepares**; it does not run.
- **AWAITS-OPERATOR / infra (beyond ADR-117 perimeter):** **framework install** (OpenClaw/Hermes/Aider/
  MetaClaw/MiroFish), **agent activation** (ADR-135 per-agent), **7/24 runtime**, **dedup source-of-truth**,
  **fork-locus creation** (ADR-136), **guardian-ledger gate fix**, **evo1 auth-gated agent probing**. Each is an
  operator/infra hand — **explicitly not the factory's**.

## 6. Honesty boundary
- **No agent activated · no framework installed · no passport/ADR/config/perimeter/project-code touched · no
  auth bypassed · no verified project-repo number invented · legal/ss1/GUYON excluded (I-18/I-20).**
- **#975 is complemented, not duplicated** — its findings-register + 4 sprints are *referenced*; this plan adds
  the cross-repo + runtime evidence and the implementation/executor cycle.
- Facts are consolidated and verified; **all remediation is deferred** to the owners/gates named in §3/§5.

## Anchors
`docs/governance/AGENT-FLEET-ROADMAP.md` (#975/IL-819 — the roadmap this **complements, not duplicates**) ·
`docs/governance/FLEET-CONFORMANCE-AUDIT.md` (#972) + erratum (#973) · `docs/governance/AGENT-LIVENESS-GAP.md`
(#974) · #966 (node heartbeat) · #969 (gap087) · `docs/governance/SERVER-CONTROL-ORCHESTRATION.md` +
`config/fleet/*` (#959 fleet-control — closed-world inventory; **evo1≡GMKtec** per GLOSSARY) ·
`docs/governance/GLOSSARY.md` (GMKtec = former name of evo1 — refutes the missing-host hypothesis) ·
`docs/adr/ADR-148-*` (adopt track — **referenced, not duplicated**) · `docs/adr/ADR-126-*`/`ADR-127-*` (Hermes
role) · `docs/adr/ADR-117-*` (perimeter) · `docs/adr/ADR-135-*` (adoption gate) · `docs/adr/ADR-136-*` (locus
gate) · `docs/adr/ADR-150-*` (a2a) · `docs/adr/ADR-154-*` (shared-space) · `docs/governance/SELF-IMPROVEMENT-MANDATE.md`
(#971) · `docs/governance/FACTORY-PROJECT-PROJECTION-MODEL.md` (#967) · `docs/governance/FACTORY-LESSON-CAPTURE.md`
(L-02 repo-root/verify, L-10 measurement rule) · ADR-102 (Duplication Audit — restates none). Operator directive
2026-07-02 (unify all agent-audit + cross-repo + runtime findings into one cycle; activate/install nothing; do
not duplicate #975; exclude legal/ss1 by I-18/I-20; no auth bypass).
