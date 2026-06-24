# G-RT — Real-Time Transaction Fraud Scoring Build-Spec (rule engine + ML score, HITL-governed)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** G-rt · **Priority:** P1 · **Sprint:** 11 · **Promotes:** the 0% (new fraud-scoring definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the scoring contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **SAFETY/GOVERNANCE FENCE (read §8 first).** G-rt is a **legitimate anti-fraud customer-protection
> process** (regulatory: PSR, Consumer Duty PS22/9, EU AI Act high-risk AI) — **NOT** surveillance. This is a
> **specification only**: the factory implements **no** live scoring and trains **no** ML model. All scores/reasons
> are **explainable** (EU AI Act Art.14); every HOLD/BLOCK is **human-overridable**; **HITL is mandatory** on a
> high fraud score; a STOP/REJECT path is always available. **I-27: no autonomous model/threshold updates** —
> every model or threshold change requires **CRO sign-off (HITL)**. Monitoring is L1-read; any decision/threshold
> operation is **L3-human**.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml) | AML/sanctions/PEP/KYC screening | **keep / reference** — **fraud ≠ AML**; G-rt scores **transaction fraud** and **hands AML concerns to F-aml**; screening **not** duplicated |
| `agents/passports/jube_adapter.yaml` + `agents/souls/jube-adapter-core.md` + `decisions/ADR-004-jube-agplv3-boundary.md` | Jube (AGPLv3) real-time tx scoring engine, **internal-use-only** (I-20), L3 AMBER adapter | **keep / REUSE via port** — G-rt **delegates** ML/behavioural scoring to **Jube via the existing jube_adapter port**; **does NOT reimplement** the engine, **does NOT expose Jube as a commercial API** (I-20 / ADR-004) |
| `ROADMAP-MATRIX.md` G-device row | device fingerprinting, velocity, account-takeover (ATO) | **keep / REUSE signals** — G-device is the **sibling**; G-rt **consumes** its device/velocity signals as features; device layer **not** duplicated |
| `docs/architecture/I-API-BUILD-SPEC.md` (IL-508) | API gateway — authN/authZ, routing | **keep / reference** — the scoring API is **fronted by I-api**; gateway logic **not** duplicated |
| `ROADMAP-MATRIX.md` I-security / I-infra | PII Proxy (Presidio); ClickHouse audit sink | **keep / REUSE** — G-rt routes PII via I-security and emits audit to ClickHouse (I-infra); not reimplemented |

No existing `G-RT-BUILD-SPEC` / G-block fraud-scoring artifact on main (live audit: `find docs -iname '*g-rt*'`/`*fraud*` ⇒ empty; `ls docs/architecture` ⇒ A-IDV/A-KYC/A-KYB/B-EMI/D-FEE/D-FIN/D-GL/I-API only). New file is **non-duplicative**; it **defines the scoring contract** around the existing Jube adapter + sibling signals, it does not re-implement them.

## 1. Scope — real-time transaction fraud scoring

G-rt defines the **real-time scoring** layer; all policy is **config-as-data** (CLAUDE.md §10 — no hardcoded thresholds):

1. **Rule engine (config-as-data rules)** — deterministic fraud rules (amount/velocity/geo/payee/new-payee/structuring patterns) evaluated per transaction; rules + weights live in config, governance-tunable (not code).
2. **ML model score (DELEGATED)** — behavioural/ML score obtained from the **Jube engine via `jube_adapter`** (AGPLv3, internal-use-only, I-20/ADR-004). G-rt **consumes** the score; it **does not** implement or train a model in-house.
3. **Combined decision (PASS / REVIEW / HOLD)** — rule outcome + ML score combined into a single decision via a config-driven score→action mapping; HOLD/REVIEW route to HITL.
4. **Real-time latency budget** — synchronous scoring within a configured per-transaction latency budget (config-as-data); on engine timeout/unavailable ⇒ fail-closed to REVIEW/HOLD (no silent PASS).
5. **Score → action mapping + HITL** — high score ≥ configured threshold ⇒ **HOLD + mandatory HITL** (FraudScoringAgent HITL); threshold is **config-as-data**, CRO-governed (§5, I-27).

**Out** of G-rt: AML/sanctions/PEP screening (F-aml), device fingerprinting/velocity capture (G-device — G-rt consumes its signals), the Jube engine internals, gateway/auth (I-api), in-house ML training, autonomous model/threshold updates.

## 2. Data model (FraudScore / Decision / Evidence)

Declarative, config-as-data; money values Decimal (I-01); PII minimised (§6).

### 2.1 `FraudScore`
- `score_id`, `txn_ref`, `correlation_id`, `customer_ref` (pseudonymous).
- `rule_score` (deterministic rule outcome + fired-rule ids), `ml_score` (from Jube via adapter), `combined_score`.
- `feature_inputs_ref`: handles to inputs — transaction attributes, **G-device** signals (device/velocity/ATO), historical velocity windows. No raw PII stored inline (§6).
- `scored_at`, `engine_ref` (`jube_adapter` session handle).

### 2.2 `FraudDecision`
- `decision_id`, `score_id`, `outcome` (`PASS | REVIEW | HOLD`), `action` (allow / queue-for-review / hold-pending-HITL), `reason_codes[]` (explainable; mapped from fired rules + ML reason factors — EU AI Act Art.14), `decided_by` (`auto` for PASS below threshold | `hitl` for REVIEW/HOLD), `decided_at`, `override_ref` (if human override applied).
- Every decision + state transition = immutable audit record (`guardian_audit_events` / ClickHouse, ADR-027; retention per policy).

### 2.3 `Evidence`
- `evidence_refs`: fired rules, ML reason factors (explainability), device/velocity signal refs — PII-redacted (§6); FCA/Consumer-Duty producible.

## 3. Scoring flow (rule engine + Jube ML via port; HITL on high score)

```
transaction → I-api gateway → G-rt scorer
  1. gather features: txn attrs + G-device signals + velocity windows   [G-device = producer]
  2. rule engine (config-as-data) → rule_score + fired_rule_ids
  3. ML score: jube_adapter.score(features) → ml_score                  [Jube AGPLv3, internal-use-only, I-20]
  4. combine → combined_score → score→action map (config) → PASS | REVIEW | HOLD
  5. PASS (below threshold) → allow (auto, logged, explainable reason codes)
     REVIEW / HOLD (≥ threshold) → mandatory HITL (FraudScoringAgent); human override + STOP/REJECT path
  6. if fraud pattern implies AML concern → hand off to F-aml (G-rt does not screen AML)
  7. emit FraudScore + FraudDecision → ClickHouse audit (I-infra), explainable reason codes
```

- G-rt **never** calls the Jube engine outside `jube_adapter` and **never** exposes Jube as an external/commercial API (I-20 / ADR-004 — internal use only).
- Engine timeout / `EngineUnavailable` ⇒ **fail-closed** to REVIEW/HOLD (no silent PASS); latency budget config-as-data.

## 4. EU AI Act Art.14 high-risk-AI controls

- **Explainability:** every decision carries human-readable `reason_codes` (fired rules + ML reason factors); no opaque auto-deny.
- **Human override:** every HOLD/BLOCK is human-overridable; a **STOP/REJECT path is always available** to the operator.
- **HITL on high score:** combined_score ≥ configured threshold ⇒ decision paused for human review (FraudScoringAgent HITL); no autonomous hold-to-block on borderline/high cases without human confirmation.
- **Oversight at every L2+ decision** (BUG-007 thresholds): AUTO >90% confidence / REVIEW 70–90% / BLOCK <70%, logged to ClickHouse with correlation_id.

## 5. Governance — CRO sign-off + I-27 (no autonomous model/threshold update)

- **I-27:** **no autonomous model updates.** Any ML model promotion/retrain-adoption or **threshold change requires CRO sign-off (HITL)**. The factory/runtime never self-tunes thresholds or swaps models autonomously.
- **Plane separation:** monitoring/score-read = **L1-read**; any **decision or threshold operation = L3-human**. Thresholds + rule weights + score→action map are **config-as-data** (CLAUDE.md §10), changed only via governed config update + CRO approval (audit-logged).
- **No in-house ML training here** — the model is provided by the Jube engine (internal-use); training/model lifecycle is out of scope and operator/CRO-gated.

## 6. Privacy-by-design

- **Data minimisation:** G-rt stores score/decision metadata + feature/evidence **refs** only; raw PII routed via **PII Proxy (Presidio)** per I-security; no PII in logs/audit beyond redacted reason codes.
- **Lawful basis:** legitimate interest / legal obligation (fraud prevention, PSR) + Consumer Duty (PS22/9) customer protection; documented.
- **Retention:** decision/audit records per policy (config-as-data); ClickHouse audit sink (I-infra).

## 7. Producer/consumer contracts (referenced, not duplicated)

- **Fronted by I-api** (`I-API-BUILD-SPEC` IL-508): the scoring API is exposed/authed/rate-limited by the gateway; G-rt does not implement gateway logic.
- **Consumes G-device signals** (sibling, ROADMAP G-device): device fingerprint, velocity, ATO indicators as feature inputs. G-device produces; G-rt consumes. Device layer **not** reimplemented.
- **Delegates ML scoring to Jube** via `jube_adapter` (AGPLv3, internal-use-only, ADR-004/I-20): G-rt consumes the score; engine **not** reimplemented, **not** externally exposed.
- **Hands AML concerns to F-aml** (`aml-patterns-SPEC`): fraud ≠ AML; on AML-relevant patterns G-rt produces a referral; F-aml owns sanctions/PEP/SAR. Screening **not** duplicated.
- **Emits audit to ClickHouse** (I-infra): scores/decisions/reason codes; observability not reimplemented.

## 8. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_rule_engine_config_as_data` (rules + weights from config; no hardcoded thresholds — CLAUDE.md §10).
- [ ] `test_ml_score_delegated_via_jube_adapter` (score obtained through `jube_adapter`; **no in-house model / no Jube external exposure**; I-20/ADR-004 boundary test).
- [ ] `test_combined_decision_pass_review_hold` (score→action mapping config-driven).
- [ ] `test_latency_budget_and_fail_closed` (within budget; engine timeout/unavailable ⇒ REVIEW/HOLD, never silent PASS).
- [ ] `test_hitl_on_high_score` (combined_score ≥ threshold ⇒ HITL; no autonomous block of high-score case; FraudScoringAgent).
- [ ] `test_explainable_reason_codes` (every decision carries reason codes; EU AI Act Art.14).
- [ ] `test_human_override_and_stop_path` (HOLD/BLOCK overridable; STOP/REJECT always available).
- [ ] `test_threshold_and_model_change_requires_cro` (I-27 — no autonomous threshold/model update; CRO HITL gate).
- [ ] `test_aml_concern_handed_to_faml` (referral emitted; G-rt does not screen AML).
- [ ] `test_consumes_g_device_signals` (device/velocity signals as inputs; G-rt does not capture them).
- [ ] `test_privacy_pii_via_proxy` (PII routed via PII Proxy; redacted audit).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; adapter/AML/device boundaries respected; audit rows per ADR-027.

## 9. Perimeter

- **In:** real-time transaction fraud **scoring** — rule engine (config-as-data), ML score via Jube adapter, combined PASS/REVIEW/HOLD decision, HITL on high score, explainability + override + stop path, CRO/I-27 governance, the consumer/producer contracts to I-api/G-device/F-aml/I-infra.
- **Out (fail-closed, §10):** AML screening (F-aml), device/velocity capture (G-device), Jube engine internals, gateway/auth (I-api), in-house ML training, autonomous model/threshold updates.
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§11).

## 10. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no live scoring / no ML training** (spec only, §8 fence); **no AML/sanctions/PEP/SAR screening** (F-aml owns it); **no device fingerprinting / velocity capture** (G-device sibling owns it; G-rt consumes signals); **no Jube engine reimplementation and no external/commercial exposure of Jube** (internal-use-only, I-20/ADR-004); **no gateway/auth** (I-api); **no autonomous model or threshold update** (I-27 — CRO HITL only); no opaque auto-deny (explainability mandatory); no silent PASS on engine failure (fail-closed to REVIEW/HOLD).

## 11. Operator gates NOT crossed

- **Cross-repo runtime** — implementing G-rt in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Model/threshold activation** = CRO sign-off (HITL) + operator-authorized action — not done here (I-27).
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 12. References

`docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml screening — AML referral consumer);
`agents/passports/jube_adapter.yaml`, `agents/souls/jube-adapter-core.md`, `decisions/ADR-004-jube-agplv3-boundary.md` (Jube engine delegation, AGPLv3 internal-use, I-20);
`docs/architecture/I-API-BUILD-SPEC.md` (IL-508 — gateway fronting the scoring API);
`ROADMAP-MATRIX.md` (G-device sibling, I-security, I-infra rows);
ADR-027 (audit trail), ADR-102/103/115/116/117/119; I-01/I-20/I-24/I-27/I-28; BUG-007 (HITL thresholds); EU AI Act Art.14; PSR / Consumer Duty PS22/9; CLAUDE.md §9/§10/§11; I-security (PII Proxy / Presidio); I-infra (ClickHouse).
