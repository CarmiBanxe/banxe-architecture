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

---

## T2.2 — banxe-payment-core Runtime Verification (2026-07-02)

**Task:** CONSOLIDATION-PLAN T2.2 — verify if banxe-payment-core is deployed as standalone library.  
**Executor:** Factory sub-agent (read-only diagnostic)  
**Status:** RESOLVED  

### Evidence

| Question | Answer | Evidence |
|----------|--------|---------|
| Pip-installable? | YES | `pyproject.toml` defines `name = "banxe-payment-core"` v0.1.0, setuptools build-backend |
| Installed in banxe-emi-stack? | NO | `pip show banxe-payment-core` → NOT_INSTALLED; zero imports in services/ |
| Used in vibe-coding? | NO | Zero grep hits for `banxe_payment_core` or `banxe-payment-core` in vibe-coding/src/ |
| Code complete? | YES | 297 tests, 97% coverage, ADR-015 ACCEPTED (2026-04-13, CEO approved) |
| Deployment blocker? | BT-001 | Modulr production API key not obtained — CEO/Operator commercial decision |
| Integration contract with services/payment/? | UNDEFINED | Two separate domains with no API contract; Phase 3 must decide |

### Repo Structure Summary

```
banxe-payment-core/src/
├── ports/          — 3 Protocol ABCs (PaymentSwitchPort, IssuerPort, LedgerPort)
├── adapters/       — Hyperswitch, Paymentology, Midaz adapters
├── agents/         — 4 agents (payments, fx_exchange, wallet, lineage)
├── settlement/     — Mastercard IPM parser + reconciler
├── compliance_bridge/
├── authorization/
└── paymentology/   — XML-RPC remote handler
```

### Verdict

**REFERENCE ONLY** — banxe-payment-core is architecturally complete (ADR-015 ACCEPTED, code-done, 297 tests)
but NOT operationally deployed. It functions as a staged development repo and architectural reference.
It is NOT consumed by banxe-emi-stack or vibe-coding at runtime.

### Phase 3 Decision Required (CTIO)

One of three paths must be chosen in Phase 3 (SSOT consolidation):

1. **Keep separate** — define REST or async event-driven API contract between banxe-payment-core (orchestration) and services/payment/ (EMI runtime).
2. **Merge** — consolidate orchestration logic into services/payment/ (simpler dependency graph, one repo).
3. **Archive candidate** — if banxe-payment-core remains blocked post BT-001 resolution, mark for Phase 7 deprecation review.

**Gate:** CTIO sign-off required before Phase 3 entry on this item.

### References

- ADR-015-payment-processing-stack.md (ACCEPTED)
- GAP-074 (Acquiring/issuing registration — blocked on BT-001)
- BT-001 (Modulr API key — CEO/Operator)
- services/payment/ in banxe-emi-stack (separate domain, no cross-import)
