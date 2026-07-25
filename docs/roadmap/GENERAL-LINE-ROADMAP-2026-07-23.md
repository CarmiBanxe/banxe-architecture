# GENERAL-LINE ROADMAP — single source of truth — 2026-07-23

**ROADMAP / GENERAL-LINE / SUPERSEDES ALL PARALLEL ROADMAPS / DOCS-ONLY / NO COMMIT**
One unified roadmap consolidating ~466 parallel roadmap/sprint/plan/matrix files (arch-repo 132 + other repos 334). Unified sprint numbering **GL-00..GL-NN**. Existing roadmaps are **superseded, not deleted**.

## §1 Purpose + supersession

- This is the single **GENERAL-LINE** roadmap. All other roadmap/sprint plans are **SUPERSEDED** — see §5 register (files retained, not deleted; "see GENERAL-LINE").
- Parallel sprint schemes consolidated: `Sprint N`, `S-A*`, `S-0*`, `S-2*`, `S-1*`, `OD-R*`, `WS*`, `S-3/4/5/6/7/8/B*`, `PHASE1/PHASE2`.
- **IL-ledger (IL-*, 7748 entries) is NOT a sprint scheme** — it is append-only LEDGER history; **not renumbered**, only referenced.

## §2 Phases — COMPLETED (DONE)

| GL | phase | status |
|---|---|---|
| GL-00 | Bank org baseline: census, 17 rooms / 4 floors, room-doc conformance | DONE |
| GL-01 | Floor-2 S-A5 identity install-audits (A-IDV/A-KYC/A-KYB) | DONE |
| GL-02 | Floor-2 S-A6 ledger/EMI install-audit (D-GL/B-EMI) | DONE |
| GL-03 | Floor-2 S-A7 gateway/web install-audit (M-GATEWAY-WEB) | DONE |
| GL-04 | PHASE1 Sprint 3 — New Products overview | DONE |
| GL-05 | PHASE1 Sprint 4 — ICT/webhooks/DORA risk | DONE |
| GL-06 | PHASE1 Sprint 5 — Payments resilience | DONE |
| GL-07 | PHASE1 Sprint 6 — Agent routing / code-lift | DONE |
| GL-08 | PHASE1 Sprint 7 — AI governance / risk lanes | DONE |
| GL-09 | PHASE1 Sprint 8 — Consent / DPO / GDPR | DONE |
| GL-10 | PHASE1 Sprint 9 — Tax / ledger / audit-cell | DONE |
| GL-11 | PHASE1 Master roadmap (sprints + repair lanes) | DONE |
| GL-12 | S-GATE-REPAIR — unified gateway/auth perimeter | DONE (plan) |
| GL-13 | PHASE2 Master code-migration + verification gates | DONE (plan) |
| GL-14 | Agent registry F1–F4 + MASTER (census 86 → 129) | DONE |
| GL-15 | Coverage closure — 34 repos, mirrors flagged | DONE |
| GL-16 | Company split — BANK / ENGINE-MANUS(core) / FACTORY(9) / REPAIR-BRIGADE(6) | DONE |
| GL-17 | Banksy Engine — concept + heart-32 + F0 room + build-spec + harvest-spec | DONE (scaffold, NOT launched) |
| GL-18 | Factory→Banksy handoff wave-1 (mcp/rules/agents/skills) | DONE (untracked, reversible) |
| GL-19 | S-B0 spot-check (+3 ADR-049 masks, 129 → 132; 6-mask series complete) | DONE |

**Completed summary:** Bank org 129→132, 17 rooms/4 floors, docs conformant; Banksy heart (scaffold, not launched); Legion = external supplier (harvest-spec: adopt decision/memory/tools, exclude TOR/scrape/RL); company split done; coverage complete.

## §3 Phases — PENDING

| GL | phase | status |
|---|---|---|
| GL-20 | S-B1 — build + launch Banksy via factory | **DONE — ONLINE** (2026-07-24, HITL-L4 signed; 32 modules, port 8200 health-green) |
| GL-21 | S-B2 — wire `banxe_mcp.server` + rules/agents adaptation | **STAGED DONE**; LIVE cutover → **DONE-LIVE** at GL-post-21 (backend :8000 up 2026-07-24) |
| GL-post-21 | MCP re-cutover — 6 tools LIVE (backend :8000 up, read round-trip green) | **DONE — LIVE** (2026-07-24; write-tools `[counsel]`) |
| GL-canon-1 | Contact-chain matrix canonized (vertical/horizontal/client/technical + gates) | **DONE** (2026-07-25; descriptive, non-blocking, parallel to sprints) |
| GL-13-EXEC | Batch code distribution — high-confidence domains basement→rooms (cp-only, staged) | **DONE** (2026-07-25; 94 domains, 666 files (measured; operator-cited 737 not reproduced), 3 `[counsel-ref]` flagged; remaining: 7 pending + 6 counsel; 3 room-mapping RESOLVED 2026-07-25 → F3-aml compliance-perimeter, 24 files) |
| GL-gov-1 | Governance committees chartered (8: Board Risk/Audit/ALCO/Credit/Product-Gov/Consumer-Duty/Op-Risk/SMCR) | **DONE-docs** (2026-07-25; live operation `[pending appointments]`) |
| GL-gov-2 | Three Lines of Defence overlay + audit independence (audit-cell → Board Audit Committee, not CTO) | **DONE-docs** (2026-07-25) |
| GL-gov-3 | Open appointments CCO/SMF16 + DPO (GDPR) + Legal separation | **[counsel] / appointment pending** (cannot close by docs) |
| GL-post-20 | Prod-inference — engine wired to bank LiteLLM gateway :4000, proposes-only (I-27), NOT Legion | **WIRED** (2026-07-25; live call `[pending env key]`; write-tools `[counsel]`) |
| GL-22 | Client-mask placement — F2-payments vs F0 engine client-PM layer | PENDING `[human ratification]` |
| GL-23 | AML-passport dedup; `executor.py`; expansion-agents | PENDING `[human ratification]` |
| GL-24 | Midaz/MCP→ledger; Banksy↔Legion data-flow; gated carve-out | GATED `[counsel]` |

## §4 Unified sprint numbering (GL-00..GL-24) — mapping

One through-line replaces all parallel schemes. Old sprint id → GL (DONE/PENDING/GATED):

| old sprint id / scheme | GL | status |
|---|---|---|
| Bank census / org baseline | GL-00 | DONE |
| S-A5 (identity) | GL-01 | DONE |
| S-A6 (ledger/EMI) | GL-02 | DONE |
| S-A7 (gateway/web) | GL-03 | DONE |
| PHASE1 Sprint 3 | GL-04 | DONE |
| PHASE1 Sprint 4 | GL-05 | DONE |
| PHASE1 Sprint 5 | GL-06 | DONE |
| PHASE1 Sprint 6 | GL-07 | DONE |
| PHASE1 Sprint 7 | GL-08 | DONE |
| PHASE1 Sprint 8 | GL-09 | DONE |
| PHASE1 Sprint 9 | GL-10 | DONE |
| PHASE1-MASTER | GL-11 | DONE |
| S-GATE-REPAIR · WS8 (Payments/Rails) · OD-R07 (gateway gate) | GL-12 | DONE (plan) |
| PHASE2-MASTER · WS* (migration) | GL-13 | DONE (plan) |
| Agent registry F1–F4 / MASTER | GL-14 | DONE |
| Coverage closure | GL-15 | DONE |
| two-engines-master → company split | GL-16 | DONE |
| two-engines-master → Banksy engine · BANKSY-ENGINE-ROADMAP §0 stack | GL-17 | DONE (scaffold) |
| Banksy handoff wave-1 | GL-18 | DONE |
| S-B0 | GL-19 | DONE |
| S-B1 | GL-20 | **DONE (ONLINE, HITL-L4 signed)** |
| S-B2 | GL-21 | STAGED DONE; LIVE cutover BLOCKED `[pending banxe backend]` |
| S-A8/S-A9 (residual A-chain) · client-mask placement | GL-22 | PENDING `[ratification]` |
| OD-R* residual external gates (keys/licences) | GL-23/GL-24 | PENDING / GATED |

Notes:
- `S-0*` / `S-1*` / `S-2*` legacy sprint families roll up into their nearest GL phase by domain (identity→GL-01, ledger→GL-02, gateway→GL-03, migration→GL-13); exact per-file mapping is a `[factory]` reconciliation task, not blocking.
- `IL-*` entries keep their ledger IDs (not GL-numbered).

## §5 Superseded register

Files retained; superseded by GENERAL-LINE. (`n/p` = superseded-note append attempted where the file is in the arch repo and writable.)

| old roadmap path | status | mapped GL |
|---|---|---|
| `docs/governance/MASTER-ROADMAP.md` | SUPERSEDED | GL-00..GL-19 |
| `docs/roadmap/R2-FLOOR2-MASTER-ROADMAP-UPDATE-PLAN-2026-07-19.md` | SUPERSEDED | GL-01..GL-03, GL-12 |
| `docs/roadmap/BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` | SUPERSEDED | GL-00..GL-24 |
| `docs/roadmap/PHASE1-MASTER-ROADMAP-SPRINTS-AND-REPAIR-LANES-OVERVIEW-2026-07-20.md` | SUPERSEDED | GL-04..GL-12 |
| `docs/roadmap/PHASE2-MASTER-CODE-MIGRATION-ROADMAP-AND-VERIFICATION-GATES-2026-07-20.md` | SUPERSEDED | GL-13 |
| `docs/roadmap/BANKSY-ENGINE-ROADMAP-2026-07-23.md` | SUPERSEDED (folded) | GL-17..GL-21 |
| `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md` (+ LAUNCH-CONTROL-PANEL) | SUPERSEDED (structure ref) | GL-00 |
| `banxe-architecture: two-engines-master-analysis-...-2026-07-10.md` | SUPERSEDED (external repo, read-only) | GL-16, GL-17 |
| `FACTORY-CANON-CONSOLIDATED-MASTER` | **NOT FOUND in arch repo** `[verify path]` | GL-16 (factory) |
| arch-repo other roadmap/sprint/plan/matrix (~105 files) | SUPERSEDED (bulk) | per §4 domain roll-up |
| other-repo roadmaps (334: banxe 159, banxe-architecture 78, OpenManus 43, merged-repo 23, emi-stack 18, MetaClaw 13) | SUPERSEDED (read-only; not modified) | reference-only |

## Notes
- Old roadmaps not deleted; arch-repo masters get an append-only superseded pointer; other-repo files are read-only (register-only supersession).
- `IL-*` ledger untouched (append-only history).
- Contested mapping / placement → `[pending human ratification]`; all legal/regulatory → `[counsel]`.
- Nothing committed.

---
**This does not replace legal advice.**
