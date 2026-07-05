# Phase 3 SSOT Plan — Conformance Audit (2026-07-05)

**Auditor:** Factory (prepare-only, read-only verification)
**Target:** `governance/PHASE-3-SSOT-PLAN.md` (ADR-157) as on `origin/main`
**Scope:** verify the plan's claims against repository reality. `banxe-architecture`-side claims are checked
authoritatively; `banxe-emi-stack`-side operational claims are cross-repo and marked **UNVERIFIED-HERE**
(a companion emi-stack-side audit is recommended). This is an audit artefact — it does **not** edit the
append-only plan (I-24); corrections belong in `AMENDMENT-NNN` sections the operator/factory appends.

## Verdict

The plan is **substantially accurate on its evidence trail** (every referenced PR is merged; repos and
ADR-157 exist), but carries **two real discrepancies** and **four stale snapshot values**. No claim was found
to be fabricated. Summary: **confirmed 4 · stale 4 · discrepancy 2 · unverified-here 1 class.**

## A. Confirmed ✅

- **§2 Repository census** — `banxe-architecture`, `banxe-emi-stack`, `vibe-coding` all exist on the host.
- **§4 Duplicate-trap evidence** — every cited PR is **MERGED**: #998 (AML-orch, OD-1), #999 (TX-monitor, OD-4),
  #995 (SAR, OD-5), #997 (recon/audit, OD-6/7). The seven-trap "resolved / intentional-separation" verdict is
  backed by merged artefacts.
- **§6.2 archive prerequisites** — cited PRs merged: #269 (CRYPTO_FLAG→EMI), #999 (tx_monitor retire), #995,
  #998, #957 (STAFF-MATRIX rebase). Only OD-9 (operator GitHub-archive of vibe-coding) genuinely remains.
- **ADR-157** exists on main (`docs/adr/ADR-157-phase3-ssot-methodology.md`).

## B. Stale snapshot values (written pre-merge; now outdated) 🟡

| § | Claim | Reality | Note |
|---|---|---|---|
| §3.18 | IL tip **"IL-864"** | current IL max on main = **884** | 20 behind; snapshot drift |
| §3.19 | ADR range **"ADR-001..157"** | highest ADR on main = **160** | 158/159/160 landed after Phase-3 open |
| §8 crit. 1 | "This plan merged — **⏳ This PR**" | plan **is on main** — **DONE** | |
| §8 crit. 2 | "ADR-157 merged — **⏳ This PR**" | ADR-157 **on main** — **DONE** | |
| §8 crit. 6 / §7 | "#270 DEPLOYMENT-MANIFEST — **⏳ Awaiting merge**" | #270 **MERGED** — **DONE** | §7 status line also stale |

→ **AMENDMENT recommendation:** flip §8 criteria 1/2/6 to ✅ DONE, refresh §7 #270 status, and re-baseline the
IL-tip / ADR-range snapshot values (or annotate them "as of 2026-07-04 open").

## C. Discrepancies (real — need correction) ⚠

1. **STAFF-MATRIX-v3 canonical path is wrong (§5 + §3.21).** The plan names the **passport SSOT** canonical
   location as **`docs/STAFF-MATRIX-v3.md`** — that path **does not exist**; the file lives at
   **`governance/STAFF-MATRIX-v3.md`**. A SSOT registry that misroutes its *own* canonical artefact is the
   highest-severity finding here. → correct the path in both §5 and §3.21.
2. **Passport count "74" does not reconcile (§5 + §3.21).** Actual counts: **57** (`agents/passports/*.yaml`
   top-level) or **70** (`agents/passports/**/*.yaml`, incl. the `aml/` subdir). Neither equals 74; the prior
   fleet-placement work also used **70**. → restate as 70 (all-yaml basis) and define what "passport" counts
   (yaml vs the 20 `agents/souls/*.md`), since the two are conflated in §5.

## D. Needs clarification (not a hard error) 🟠

- **§3.20 GAP register — two files + unconfirmed tally.** The plan cites `docs/GAP-REGISTER.md` with
  "**92 gaps; 18 OPEN**", but a **root `GAP-REGISTER.md` also exists** (documented elsewhere as an intentional
  two-register split: root = architecture-canon gaps, `docs/` = operational). Neither the 92 nor the 18-OPEN
  figure is reproducible by simple count (the two files yield different tallies). → state which register is the
  SSOT for this number and cite its own authoritative tally.

## E. Unverified here (cross-repo — recommend companion audit) ⬜

- **§3 domains 1–17 and 22** (Identity, Payments, Ledger, AML-swarm, KYC, Safeguarding, FX, Reporting, Recon,
  Fraud, TX-mon, Audit, SAR, ARL, HITL, Intent-Layer, KB, MCP) name **`banxe-emi-stack`** services/paths and
  operational flags (✅ LIVE / 🟡 CODE-READY / 🔴 BLOCKED / 🟠 STAGED). These were **not** verified in this
  `banxe-architecture`-scoped audit. **Recommendation:** a companion emi-stack-side pass to confirm each
  `services/<x>/` path + flag (and §7's `infra/DEPLOYMENT-MANIFEST.md`, "27 services").

## Recommendation

The plan is trustworthy as a governance artefact — its resolution evidence holds. Land **one AMENDMENT-001**
that (a) fixes the two §C discrepancies (STAFF-MATRIX path → `governance/`; passport count → 70 with a defined
basis), (b) refreshes the four §B stale values, and (c) clarifies §3.20's GAP register + tally. The §E cross-repo
flags should be confirmed by an emi-stack-side audit before Phase 3 is declared COMPLETE (§8 criterion 4).

## Anchors

`governance/PHASE-3-SSOT-PLAN.md` · `docs/adr/ADR-157-phase3-ssot-methodology.md` ·
`governance/STAFF-MATRIX-v3.md` (actual path) · `GAP-REGISTER.md` + `docs/GAP-REGISTER.md` (two registers) ·
`agents/passports/` (57 top / 70 all-yaml) · PRs #995/#997/#998/#999/#957/#269/#270 (all merged). Prepare-only;
no plan edit (I-24) — findings feed an AMENDMENT.
