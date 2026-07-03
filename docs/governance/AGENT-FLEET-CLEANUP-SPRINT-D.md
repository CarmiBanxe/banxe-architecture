# Agent-Fleet Cleanup — Sprint D: ADR-102 aml diff-audit + naming + ledger/redis + fork-locus (write-up only)

> **Status:** governance cleanup write-up (Sprint D of the master-plan #978). **Additive, pointer-first
> (ADR-102).** It **diagnoses** — it **deletes nothing, dedups nothing, edits no passport / name / service /
> redis config / ADR / config / perimeter / legal / ss1, and bypasses no auth.** The `banxe_aml_orchestrator`
> pair was **read read-only and diffed**; **every decision (keep/merge/delete, naming fix, redis fix, fork
> locus) is `[AWAITS-OPERATOR]`.**

## 1. ADR-102 aml-dedup — DIFF-AUDIT (result: **DIFFER → escalate, do NOT delete**)
The #972 "duplicate `agent_id: banxe_aml_orchestrator`" was diffed read-only. **The two files are NOT a
duplicate — they are two DISTINCT passports sharing one `agent_id`, in different zones and schemas.** Deleting
either would **lose content and break references** ⇒ **classification (b): they DIFFER → escalate with diff, no
deletion** (ADR-102 fail-closed; and the content is AML/FCA-critical — CLAUDE.md "never skip AML/KYC").

### 1a. Unique content of each (fact, from the read-only diff)
| | `agents/passports/aml/banxe_aml_orchestrator.yaml` (IL-068, 53 lines) | `agents/passports/banxe_aml_orchestrator.yaml` (root, 89 lines, v3.0.0) |
|---|---|---|
| **Schema** | SMF17/HITL governance passport | v3.0.0 capability / skills-orchestration passport |
| **trust_zone** | **RED** (high-risk financial crime) | **AMBER** |
| **autonomy** | `autonomy_level: L3` | `level: 1` |
| **Unique keys** | `human_double` (HEAD_OF_FINCRIME/MLRO), `fca_basis` (**SMF17**), `change_class: MAJOR`, **`hitl_gates`** (SAR_filing, AML_threshold_change, Sanctions_reversal, Sanctions_BLOCK), `allowed_actions`, `forbidden_actions`, `audit` | `name`, `version 3.0.0`, `bounded_context: CTX-01`, `capabilities`, `ports`, `allowed_callers`/`allowed_callees`, `invariants`, `governance`, `fca_references`, `aigf_risks`, `allowed_skills`/`prohibited_skills`/`preferred_skill_sequences`/`mandatory_skill_triggers` |

- **Neither is a subset of the other.** The `aml/` file carries the **regulatory HITL/SMF17/SAR gate**
  content; the root file carries the **v3.0.0 capability/skills/ports/callers** contract.
- **Conflict flagged (not resolved):** the same `agent_id` declares **two different `trust_zone`s (RED vs
  AMBER)** — a governance inconsistency the operator must resolve (which zone governs? or do they need distinct
  ids / a merge?).

### 1b. Consumers (so a dedup cannot silently break references)
**54 files reference `banxe_aml_orchestrator`** — including compliance-critical ones:
`.claude/rules/compliance.md`, `COMPLIANCE-ARCH.md`, `INVARIANTS.md`, `agents/swarms/banxe-aml-swarm.yaml`,
and many passports (`tx_monitor(_core)`, `sanctions_check`, `case_management_agent`, `crypto_aml`,
`clickhouse_writer`, `reasoning_bank_agent`, `aml_orchestrator`) + souls (`jube-adapter-core`). A blind
delete/merge would risk **54 dangling references** on an **AML RED-zone** id.

### 1c. Decision = `[AWAITS-OPERATOR]`
**This PR deletes/merges nothing.** The keep/merge/delete decision — and the RED-vs-AMBER zone reconciliation —
is a **governance call for the operator** (ADR-102 step 5: uncertainty about hidden consumers / content ⇒
fail-closed + escalate). Recommended framing for that decision (advisory, not taken here): **do not delete;
reconcile the two into a single canonical passport (or two distinct ids) preserving BOTH the SMF17/HITL gates
AND the v3.0.0 capability contract**, then update the 54 consumers in a bounded, reviewed PR.

## 2. Naming-reconciliation (flag only — CODEOWNERS-gated, not in this PR)
**GMKtec = legacy alias of `evo1`** (GLOSSARY-verified, #982). Stale references remain:
- `.claude/agents/openclo.md` — "10 Banxe agents on **GMKtec**" → should read **evo1**;
- the `openclaw-tunnel-gmktec.service` name (legacy).
**Fix is a separate CODEOWNERS-gated step** (`.claude/` requires `@mmber` review) — **flagged here, not edited.**
`[AWAITS-OPERATOR]`.

## 3. guardian-ledger / redis-counter follow-up (infra, `[AWAITS-OPERATOR]`)
Two ledger-integrity findings, both **infra / operator**, not fixable from the factory:
- **Redis anti-collision counter unreachable from Legion.** ADR-143's central counter lives on **evo1**, but
  #990 set the default `REDIS_HOST` to `127.0.0.1` (no counter there) — so `build_ledger` on Legion falls back
  to **local/degraded** mint and **races** concurrent merges. **Empirical this session:** IL **835→837→838**
  (three re-mints of the Sprint-B PR alone, drifting behind #990/#991). **Durable fix (operator/infra):** bring
  the counter up on Legion **or** set `REDIS_HOST=100.68.102.48` (evo1 tailscale). Config change — **not made
  here** (touching redis config is out of scope).
- **guardian-ledger let a de-synced sequence merge** — #966/#969 landed shards that were **un-sequenced** until
  #975's regen self-healed them (820/821). The gate should **reject** a PR whose `IL-SEQUENCE.json` is stale vs
  its shard set. **Infra follow-up (operator).**

## 4. Fork-locus flag (open, `[AWAITS-OPERATOR]`)
The **agent-harness project-fork locus** (`SELF-IMPROVEMENT-MANDATE` §4, #971; ADR-136-gated) remains
**unresolved** — project-side self-improvement and any agent-liveness-monitor project build (#988 §7) depend on
it. **Reminded as open; not created here** (no repo fabricated).

## 5. Boundaries
- **Write-up only.** No file deleted; **no dedup executed**; no passport / name / service / redis config / ADR /
  config / perimeter / legal / ss1 edited; **auth not bypassed.**
- The aml pair was **read read-only and diffed** — the diff is *reported*, not applied.
- **Every decision is `[AWAITS-OPERATOR]`:** aml keep/merge/delete + zone reconciliation, naming fix
  (CODEOWNERS), redis-counter + guardian-ledger infra fixes, fork-locus creation.

## Anchors
`docs/governance/FLEET-CONFORMANCE-AUDIT.md` (#972 — the aml-duplicate finding, now diff-audited) ·
`docs/governance/AGENT-FLEET-MASTER-PLAN.md` §7 (#982 — GMKtec≡evo1; GAP-4/naming; F-LEDGER) · #975 (ledger
self-heal 820/821) · #990 (`REDIS_HOST` default change) + #991 (concurrent merge — the drift pair) ·
`docs/governance/SELF-IMPROVEMENT-MANDATE.md` §4 (#971 — fork locus, ADR-136-gated) ·
`docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md` (the Duplication-Audit discipline this
follows — read → source-of-truth + consumers → no delete until confirmed → keep/merge/delete + risks →
fail-closed escalate) · `docs/adr/ADR-143-*` (redis single-writer allocator — the unreachable counter) ·
`docs/adr/ADR-136-*` (locus gate) · `docs/adr/ADR-117-*` (perimeter) · `.github/CODEOWNERS` (`.claude/` gate for
the naming fix) · CLAUDE.md (never skip AML/KYC — why the aml pair is fail-closed). Operator directive
2026-07-02 (Sprint D cleanup write-up; diff-audit the aml pair; delete nothing; all decisions operator-gated).
