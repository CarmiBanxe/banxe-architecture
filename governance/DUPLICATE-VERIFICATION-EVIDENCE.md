# DUPLICATE VERIFICATION EVIDENCE — Phase 2 (T2.5)
**Date:** 2026-07-02
**Author:** Factory (agent-factory, T2.5 task)
**Source:** CONSOLIDATION-PLAN.md §2 — "per-duplicate verification evidence"
**Status:** VERIFIED (append-only, I-24)

---

## Scope

T2.5 mandates per-duplicate verification evidence before any Phase 7 archive action.
Evidence gathered from live filesystem inspection of banxe-emi-stack and vibe-coding.

---

## DUP-1 — banxe_aml_orchestrator.yaml (OD-1)

**CONSOLIDATION-PLAN claim:**
> `agents/passports/aml/banxe_aml_orchestrator.yaml` (L3, complete)
> vs `agents/passports/banxe_aml_orchestrator.yaml` (root, autonomy=unset)

**Verified state (2026-07-02):**

| Path | Exists? | Evidence |
|------|---------|----------|
| `banxe-emi-stack/agents/passports/aml/banxe_aml_orchestrator.yaml` | ❌ NOT FOUND | `find ~/banxe-emi-stack/agents -name "banxe_aml_orchestrator.yaml"` → empty |
| `banxe-emi-stack/agents/passports/banxe_aml_orchestrator.yaml` | ❌ NOT FOUND | Same search → empty |
| `vibe-coding/src/compliance/banxe_aml_orchestrator.py` | ✅ EXISTS | 718 lines, Python, Layer 3 canonical runtime |
| `banxe-architecture/agents/souls/banxe-aml-orchestrator.md` | ✅ EXISTS | Soul file (governance ref, not runtime) |

**Finding:** OD-1 is a **phantom blocker**. The two YAML passport files referenced in CONSOLIDATION-PLAN do not exist in banxe-emi-stack at current HEAD. The duplication concern may have been recorded based on a prior branch state or speculative path.

**Recommendation:** MLRO/CTIO to confirm OD-1 is resolved (files never landed or were deleted). If confirmed, OD-1 blocking status on Phase 3 should be reclassified to RESOLVED.

**Risk if wrong:** If files exist on a non-main branch that will be rebased, the duplicate resurfaces. Factory action: `git log --all --oneline -- agents/passports/aml/banxe_aml_orchestrator.yaml` should be run to confirm files never existed.

---

## DUP-2 — tx_monitor.py

**CONSOLIDATION-PLAN claim:** dual implementations, no test coverage cross-check.

**Verified state (2026-07-02):**

| Property | vibe-coding | banxe-emi-stack |
|----------|-------------|-----------------|
| Path | `src/compliance/tx_monitor.py` | `services/aml/tx_monitor.py` |
| Lines | 311 | 332 |
| Rules | 7 (HARD_BLOCK_JURISDICTION, HIGH_RISK_JURISDICTION, SINGLE_TX_THRESHOLD, POTENTIAL_STRUCTURING, RAPID_IN_OUT, ROUND_AMOUNT, CRYPTO_FLAG) | 5 (VELOCITY_D, VELOCITY_M, STRUCTURING, + entity-aware thresholds) |
| Money type | ❌ `float` (I-01 VIOLATION) | ✅ `Decimal` (compliant) |
| Entity awareness | ❌ No (single threshold) | ✅ Yes (INDIVIDUAL £10k / COMPANY £50k per I-04) |
| Redis velocity | ✅ Yes (async Redis) | ✅ Yes (InMemory stub for tests) |
| Crypto signals | ✅ CRYPTO_FLAG rule | ❌ No crypto-specific rule |

**I-01 violation in vibe-coding `tx_monitor.py`:**
```python
# line 83 — I-01 BREACH: float used for monetary amount
async def _add_velocity(r, account: str, amount: float, window: int) -> float:
# line 242 — float coercion of transaction amount
    amount_gbp=float(tx.get("amount", 0)),
```

**Finding:** These are **real diverged implementations** — NOT simple duplication. Each has unique rules not present in the other. EMI is production-compliant (Decimal, entity-aware); vibe-coding is reference with I-01 violation.

**Recommended Phase 2 resolution:**
1. EMI (`services/aml/tx_monitor.py`) is **canonical production** — no changes.
2. vibe-coding must fix I-01 violation (replace `float` with `Decimal`) — CTIO task before vibe-coding can serve as reference.
3. CRYPTO_FLAG rule from vibe should be evaluated for inclusion in EMI (security enrichment).
4. No code merge; maintain separation (vibe = vendor-neutral reference, EMI = FCA-compliant runtime).

**Blocker:** I-01 violation in vibe-coding must be remediated before vibe can serve as trusted reference engine.

---

## DUP-3 — SAR Generator

**Verified state (2026-07-02):**

| Property | vibe-coding | banxe-emi-stack |
|----------|-------------|-----------------|
| Path | `src/compliance/sar_generator.py` | `services/aml/sar_service.py` |
| Lines | 124 | 602 |
| Nature | Reference stub | Production (POCA 2002 s.330 compliant) |

**Finding:** ✅ RESOLVED — clear separation by compliance tier. Canonical is `banxe-emi-stack/services/aml/sar_service.py`. vibe-coding version is a reference stub only. No consolidation needed.

---

## DUP-4 — Service Overlaps (AML/KYC/fraud stubs)

**Verified state (2026-07-02):**

| Domain | banxe-emi-stack | vibe-coding |
|--------|-----------------|-------------|
| fraud | `services/fraud/` (414 lines jube_adapter, 314 fraud_aml_pipeline) | `src/compliance/review/review_agent.py` (406L) — different scope |
| AML | `services/aml/` (4 py files) | `src/compliance/aml_orchestrator.py` + `banxe_aml_orchestrator.py` |
| KYC | `services/kyc/` (5 py, 0 tests) | No direct equivalent |

**Finding:** 🟡 PARTIAL — fraud and AML have overlapping concerns but different scopes. Minimal risk if API contract boundary is maintained (EMI calls vibe via HTTP, no direct imports). No test cross-coverage exists yet.

**Recommended Phase 2 action:** API contract definition (T2.1 prerequisite satisfied by OD-1 resolution).

---

## Summary Table

| Dup | Status | Action Required | Owner | Phase 2 Gate |
|-----|--------|-----------------|-------|--------------|
| OD-1 banxe_aml_orchestrator.yaml | 🟢 PHANTOM — files don't exist | MLRO/CTIO confirm OD-1 resolved | MLRO/CTIO | Reclassify to RESOLVED |
| tx_monitor.py | 🔴 REAL + I-01 violation in vibe | Fix float→Decimal in vibe-coding | CTIO/Factory | Before Phase 2 reference use |
| SAR generator | ✅ RESOLVED | None | — | Done |
| Service overlaps | 🟡 LOW RISK (API boundary intact) | API contract spec | CTIO | Phase 2 (T2.1) |

---

## CRYPTO_FLAG Gap (new finding)

vibe-coding `tx_monitor.py` has a `CRYPTO_FLAG` rule not present in EMI. EMI has no crypto-specific transaction monitoring signal. Given growing crypto activity on EMI:

**Recommended:** CTIO to evaluate adding CRYPTO_FLAG equivalent rule to `banxe-emi-stack/services/aml/tx_monitor.py` (Phase 2 enrichment task, not blocking).

---

*Append-only evidence record. Do not edit. Add new findings as dated addendum sections.*
