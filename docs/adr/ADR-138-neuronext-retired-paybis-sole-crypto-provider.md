# ADR-138: NeuroNext retired — PAYBIS is the sole external crypto provider

**Status:** PROPOSED
**Date:** 2026-06-26
**Builds on:** ADR-108 (Paybis distribution model — crypto liability on Paybis), ADR-114 (Travel Rule on Paybis), ADR-036 (CryptoCompliancePort / Travel-Rule gate)
**Plane:** banxe-architecture = decision/spec only. Ships no runtime code; makes no cross-repo write. Additive (ADR-119 append-only; never renumbers a prior ADR).

> **ADR number provenance:** **renumbered from provisional ADR-126 → ADR-138** to clear a collision —
> origin/main @ `4937778` already has merged **ADR-126-hermes-tier1-cicd-watchdog-role** (central terminal),
> and ADR-127…137 are also occupied; true next-free = **max+1 = 138** (ADR-119: re-number the *unmerged*
> ADR, never a merged one). Content unchanged. (Note: the operator's pre-flight "next free = 135" was stale —
> 135/136/137 are taken on origin/main; 138 is the actual first-free.)

## Context
- **Operator decision (2026-06-26):** PAYBIS fully replaces NeuroNext as the external crypto service provider across the EMI BANXE AI BANK stack. NeuroNext is a **fully retired provider** in the target architecture.
- **Live audit (source of truth, not memory):** banxe-emi-stack origin/main `b23593c` — **zero** `neuronext` references in `services/**`/`app/**` (and zero `bitrix`). The new codebase was a clean rebuild; NeuroNext was never ported (consistent with residual-gap register IL-516, where legacy `neuron`/`crypto-processing` were classified DROP/RESCOPE). PAYBIS appears only in architecture docs (ADR-108/114), **not yet in code** — the external crypto adapter is greenfield.
- The crypto-ledger seam already exists: `services/ledger/crypto_ledger_port.py` (`CryptoLedgerPort` / `CryptoRpcPort`) with adapters under `services/ledger/legacy/*` and `services/ledger/production/*` (12 unimplemented stubs: `get_balance`/`create_wallet_address`/`create_tx`/`get_fee_estimate`/`health`). These are the integration points that MUST target PAYBIS.

## Decision
1. **PAYBIS is the single external crypto processor** for all crypto-related processes previously associated with NeuroNext — exchange, custody, processing, payouts, and treasury-side crypto flows. They route to PAYBIS via the `CryptoLedgerPort` / `CryptoCompliancePort` seams (ADR-036/114).
2. **No new code path may introduce NeuroNext as an active participant** — licensing, processing, data exchange, or orchestration. NeuroNext is not a permitted provider behind any port.
3. **No dual-provider logic** — service-level refactors treat PAYBIS as the sole external crypto processor; no NeuroNext fallback/secondary path.
4. **Deprecation / sunset:** any remaining NeuroNext-specific configuration, adapters, or feature flags are **deprecation targets** scheduled for removal under the Bitrix/NeuroNext sunset track. (Audit: none currently present in the new codebase — so this is a forward guard, not a present cleanup.)
5. **Cutover discipline:** migration plans MUST include explicit NeuroNext→PAYBIS cutover steps at the service and workflow level, with **rollback strategies that do NOT reintroduce NeuroNext as an active provider** (rollback = halt/queue/MLRO-manual, never re-route to NeuroNext).

## Rationale
- **Licensing/compliance:** NeuroNext's prior Polish licensing is no longer relied upon; routing flows via NeuroNext would introduce licensing/compliance risk under current EU/MiCA and national regimes.
- **PAYBIS = regulated CASP** (MiCA CASP per ADR-108; Travel-Rule responsibility per ADR-114) and the designated white-label provider for BANXE crypto processes. BANXE acts as distribution agent (ADR-108), keeping the crypto regulatory surface on PAYBIS.

## Consequences
- **Positive:** single, regulated crypto provider; no NeuroNext licensing exposure; aligns the (greenfield) `CryptoLedgerPort` adapter build to one target (PAYBIS), avoiding dual-provider complexity; consistent with ADR-108/114.
- **Residual / follow-up:** the PAYBIS adapter behind `CryptoLedgerPort` is **not yet built** — a separate operator-authorized banxe-emi-stack runtime task (injectable-mock + fenced live PAYBIS API, HITL where funds/PII move; ≥90% coverage via mock, live transport fenced). This ADR is the canon that gates that build to PAYBIS-only.
- Dependency on the PAYBIS data/processing contract (SP-PR3 Distribution/Outsourcing Agreement, per ADR-114).

## Out of scope (fail-closed)
No runtime code here; no cross-repo write; no PAYBIS adapter implementation (separate gated task); no KYC/KYB/AML re-implementation; no change to a prior ADR. NeuroNext is not removed from code because it is **already absent** (audit-confirmed) — this ADR forbids its reintroduction.

## Related
ADR-108 (distribution model), ADR-114 (Travel Rule / PAYBIS CASP), ADR-036 (CryptoCompliancePort / TR gate), ADR-111 (crypto-AML graph); `services/ledger/crypto_ledger_port.py`; residual-gap register IL-516; GAP-REGISTER (NeuroNext/Bitrix sunset). FATF R.16, UK MLR 2017, MiCA.

## Amendment (2026-06-28) — Bittrex (exchange) ≠ Bitrix (CMS): ELIMINATED + forward-guarded

Additive clarification (the original Context conflated two distinct retired components; this does **not**
alter any decision above):

- **Bittrex** = the retired crypto **exchange** (legacy `neuron`/`fast-exchange` lineage). **Bitrix / битрикс**
  = the unrelated CMS/CRM platform. The original "zero `bitrix`" audit line did **not** cover Bittrex.
- **Status — Bittrex = ELIMINATED.** Live audit on banxe-emi-stack origin/main `4f93870`: repo-wide
  `git grep -il 'bittrex'` = **0** (code, tests, docs, config). Bittrex was never ported (greenfield rebuild);
  consistent with this ADR's NeuroNext/PAYBIS-sole-provider canon.
- **Forward-guard added.** A prior guard gap existed: `banxe-no-bitrix-reintroduction` (regex
  `(?i)(bitrix|битрикс)`) does **not** match `bittrex`, so the exchange was unguarded. Closed by EMI **PR #262**
  (squash-merge `4f93870`): new Semgrep rule **`banxe-no-bittrex-reintroduction`** — `pattern-regex '(?i)bittrex'`,
  `languages: [generic]`, `severity: ERROR`, paths include `services/app/src/api/config`, exclude
  `tests/docs/.semgrep`. CI now fails on any future Bittrex reintroduction.
- **Unchanged:** `banxe-no-bitrix-reintroduction` and `banxe-no-neuronext-reintroduction` remain intact (not
  weakened). PAYBIS stays the sole external crypto provider (this ADR's core decision).
- **Refs:** EMI PR #262 (`4f93870`, `.semgrep/banxe-rules.yml`); `docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md` §6.
