# SESSION HANDOFF — factual state & open tasks (2026-06-27)

**Purpose:** single canonical resume point for a NEW Perplexity/factory session.
**Bases at handoff:** EMI `CarmiBanxe/banxe-emi-stack` origin/main = **`3f418d1`** (#261); ARCH `CarmiBanxe/banxe-architecture` origin/main = **`45c5a5c`** (#835).
**Discipline:** additive docs-only; all SHAs below verified on their mains (read-only audit). No code/secrets/RAR here.

---

## A. FACTUAL STATE (with SHAs)

### A.1 Landed refactor/landing track — EMI origin/main @ `3f418d1`
| PR | Merge SHA | What |
|---|---|---|
| #245 | `7c12da5` | E9 NeuroNext/Bitrix forward-guard (semgrep banxe-rules) |
| #246 | `2d36720` | PAYBIS Wave A/B + sandbox + DI-gate (processing surface) |
| #247 | `f2ca72c` | strict shim assertion restore — `importlib.reload` class-identity root-cause |
| #248 | `39742b7` | E10 auth-orphan delete (legacy SCA + TOTP adapters + tests) |
| #257 | `36418d9` | ruff-debt unblock — pre-existing I001 (`test_safeguarding_adapters.py`) |
| #255 | `78207c0` | `consumer_duty/models_v2 → models` rename (rename-debt) |
| #259 | `fe27f4d` | pin ruff `0.15.20` across CI (`ruff-action@v3`) + pre-commit |
| #261 | `3f418d1` | de-dup `to_minor_units` → `services/shared/money.py` (ADR-102) |

### A.2 ARCH governance landed @ `45c5a5c`
| PR | Merge SHA | What | IL |
|---|---|---|---|
| #815 | `b6161f6` | PAYBIS dossier | IL-568..595 |
| #816 | `fffe689` | EMI impl-state re-baseline | IL-596..599 |
| #826 | `1073913` | legacy rationalization dossier pass-1 | IL-610 |
| #831 | `1fb99c6` | dossier: `models_v2` stream DONE | IL-614 |
| #834 | `2df37af` | dossier: payment-cluster correction | IL-618 |

### A.3 Legacy migration state
- **107** EMI services; **~20** legacy/v2 modules classed `LIVE_KEEP` / `LIVE_MIGRATE_NEXT` / `PARKED_REVIEW` — see `docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md` (incl. corrections; cited, not duplicated here).
- **Residual genuine-gap = 0** — `docs/migration/MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md`.
- BANXE.RAR domain migration **COVERED**; **4 SERVER-AUDIT-REQUIRED**: `neuron`, `internal_dev`, `ilink`, `Trading-core`.

### A.4 Crypto-trading track
- **ADR-083 ACCEPTED** — Composable DeFi Stack (self-custodial) replaces the Binance-dealer model.
- Repos: `banxe-trading-frontend` (mock-feed) + `banxe-trading-backend` (exists). `ExchangePort` contract + Python impl in `banxe-payment-core`; rate provider `crypto-ops-monitor`.
- **LAST-MILE NOT DONE:** dYdX v4 `MarketDataPort` (§D2 orderbook WS) + `ExchangePort` REST/WS BFF + `QuotePort` (LI.FI).
- Legacy sources inventoried (`neuron-bitshares-ui`, `fast-exchange`, `banxe-transactions/.../crypto`) on evo1 `/home/banxe/banxe-rar-extracted/`.

---

## B. OPEN TASKS (with gates)

### B.1 Rationalization streams (each its own verify-first scoped PR; ADR-102 dup-audit + full-suite green)
- `reconciliation_engine_v2 → v1` merge-pair (4 consumers: safeguarding_recon, matrix_scanner, camt053_parser, recon_agent). ⚠ **CORRECTED 2026-06-28: direction is v1→v2 (v2 is the canonical live REST engine; v1 = legacy-cron), pair PARKED** — see the recon Correction note in `docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md`.
- `fin060_generator_v2 → v1` merge-pair (2 consumers: matrix_scanner, reporting_agent). ⚠ **CORRECTED 2026-06-28: NOT a v2→v1 merge — three complementary contours (v2 = governance/HITL-CFO API `/v1/fin060/*`; v1 = required PDF+RegData submission engine `/v1/reporting/fin060/*`; `src/safeguarding` = separate return-data domain), pair PARKED** — see the fin060 Correction note in `docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md`.
- `legacy_otp_adapter → production/{twilio,sendgrid}_otp_adapter` (provider parity).
- `legacy_sepa_adapter → production/modulr_sepa_stub` (Modulr live-wiring).

### B.2 Crypto-trading options (operator picks)
- **(A)** correct residual-register Trading-core `DROP → ACCEPTED-partial` — *docs-only*.
- **(B)** server-audit on evo1 of `neuron` / `fast-exchange` / `banxe-transactions` crypto — *read-only under factory*.
- **(C)** last-mile implementation in `banxe-trading-backend` — *code*; gates: ADR-083 §7 revenue legal-review + investment-firm reclassification risk; **dYdX AGPL-3.0** license.

### B.3 Operator gates (not migration)
- M2.8 frontend roster (`banxe-ui` / `banxe-platform` / split).
- KYC/KYB/AML **I-27 HITL-L4 MLRO** sign-off.

### B.4 PARKED — do NOT remove
- `bifrost_adapter` — Wave-D scaffold (MIG-M2.5-BIF / ADR-025 §15-16). *(Note: its `to_minor_units` now imported from `services/shared/money.py` after #261; file stays.)*
- `role_guard` — security invariant + coupled chain `role_guard → jwt_strategy → jwks_models`.
- `legacy_binancekyc` / `legacy_bkyc` — I-27 KYC perimeter.
- `crypto_legacy` router + `ledger/legacy/legacy_crypto_*` — **gated on PAYBIS Wave C** (SRC-06 + ADR-114).

### B.5 Net-new (NOT BANXE.RAR ports)
SDK (Python + JS), sandbox mock-rails, BI-presentation.

---

## C. CANON / PROTOCOL for the resuming session
- Work **ONLY through the factory** (Claude Code); **single-writer §71**; shell = **read-only audit only**. **Best-decision after audit, never from memory.**
- **ADR-102 dup-audit mandatory** before any transfer/dedup (prior transfer attempts exist).
- Code-quality is a **factory function**: ruff `0.15.20` pinned · semgrep `banxe-rules` · pytest cov ≥80 · vitest · smoke · gitleaks · biome.
- **BANXE.RAR** is unpacked **ONLY server-side on evo1 under the factory**; only de-secreted, sandbox-mode code reaches the repos. Never unpack into a repo.
- Reference canon (do NOT duplicate/modify): `.canon/CANON.md` + `.canon/rules/*`; ADR-083 (DeFi stack), ADR-021 (ExchangePort), ADR-102/103/119, ADR-114/138 (PAYBIS), §71 single-writer.

---

## Appendix — recurring REFACTOR-STATUS operator prompt (verbatim, for reuse)

```
FACTORY TASK — RIGHT TERMINAL (B) REFACTOR-STATUS REPORT (read-only audit, recurring).
Repo: CarmiBanxe/banxe-emi-stack (code) + CarmiBanxe/banxe-architecture (governance/dossiers).
CANON: work ONLY through the factory (Claude Code), never directly. Single-writer §71 — the factory
orchestrates so the central and right terminals never conflict. Shell is for READ-ONLY audit only.
Decisions = "BEST DECISION", never from memory — always after a shell audit. This task PRODUCES A
REPORT ONLY: it does NOT modify code, does NOT delete, does NOT merge, does NOT unpack secrets into any repo.

MANDATE (context — do not re-explain, just honor):
- The right terminal is responsible for SMART REFACTOR of legacy BANXE.RAR → migrate EMI-relevant
  microservices into the EMI BANXE AI BANK codebase by the BEST-DECISION principle.
- BANXE.RAR contains SECRETS → it is unpacked/refactored ONLY on factory-orchestrated servers
  (evo1/evo2), NEVER on Legion, NEVER into a git repo. Only de-secreted, sandbox-mode code reaches the repos.
- DUPLICATION CHECK IS MANDATORY (ADR-102) — prior transfer attempts exist; every candidate must be
  dup-audited before any transfer.
- CODE QUALITY of transferred code is the FACTORY's function (ruff 0.15.20 pinned, semgrep banxe-rules,
  pytest cov≥80, vitest, smoke, gitleaks) — report gate status, do not weaken.

DO (read-only audit; produce the structured report):
1. Fetch fresh origin/main of both repos. Record HEAD SHAs.
2. Read the canonical progress sources (cite, do not invent): docs/migration/MIG-INDEX-final-state-register.md;
   docs/migration/MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md; docs/migration/banxe_legacy_risk_register.md;
   docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md;
   docs/refactor/legacy/BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md (+ PHASE-B if present).
3. Count EMI services and remaining legacy/v2 modules (services/*/legacy/*.py + *_v2.py). Compare to baseline (107 services, 24 legacy/v2).
4. For the legacy/v2 set, report each module's class (DONE/LIVE_KEEP/LIVE_MIGRATE_NEXT/PARKED_REVIEW) + live-consumer count
   (module + symbol level). Re-confirm dup-audit posture (ADR-102): 0 live AND 0 transitive = removable candidate; else PARKED.
5. Report required-CI-gate health on origin/main (ruff pinned 0.15.20, semgrep banxe-rules, pytest cov, vitest, gitleaks) — green/red.
6. Report gated blockers (PAYBIS Wave C for crypto_legacy/ledger-legacy; I-27 KYC perimeter for binancekyc/bkyc; security-invariant for role_guard).
7. Secrets posture: confirm NO secrets in repo (gitleaks status). RAR unpack server-side under factory, never reported into the repo.

REPORT FORMAT (Russian prose + tables): A. Заголовок (дата, EMI/ARCH HEAD SHA). B. Прогресс миграции
(сервисов vs target; legacy/v2 vs baseline 24; что закрыто + merge SHA). C. Таблица legacy/v2 (модуль | live |
класс | dup-audit вердикт). D. Открытые потоки (LIVE_MIGRATE_NEXT: цель/seam/blocker). E. Заблокированные
(gated, причина разблокировки). F. CI-гейты (зелёный/красный). G. Секреты (0 в репо; RAR server-side).
H. Рекомендация «лучшего решения» (следующий smallest-safe поток ИЛИ «нет безопасных»).

STOP: report-only. If implicitly asked to transfer/delete/merge — DO NOT; flag the recommended next stream for
explicit operator approval. Never unpack RAR into a repo. Never weaken a gate. Never force-push.
```

### Refs
EMI `3f418d1`; ARCH `45c5a5c`; `docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md`; `docs/migration/MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md`; ADR-083 / ADR-021 / ADR-102 / ADR-114 / ADR-138; `.canon/CANON.md`; §71.
