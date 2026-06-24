# G-DEVICE — Device Signals Build-Spec (fingerprinting, velocity checks, account-takeover detection)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** G-device · **Priority:** P1 · **Sprint:** 11 · **Promotes:** the 0% (new device-signal-source definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the signal contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **SAFETY/PRIVACY FENCE (read §8 first).** G-device is a **legitimate anti-fraud account-protection process**
> (regulatory: PSR SCA, fraud prevention, Consumer Duty) — **NOT** surveillance and **NOT** behavioural tracking
> beyond the fraud purpose. This is a **specification only**: the factory implements **no** live fingerprinting and
> collects **no** device data. Privacy-by-design: GDPR/UK-GDPR lawful basis = **legitimate interest (fraud
> prevention)**, **data minimisation** (only fraud-relevant device signals), transparency, retention limits, PII
> Proxy (Presidio). Device data is used **solely** for fraud/ATO protection — **no secondary use**. The
> device-fingerprint capability is **CTO/CEO-gated** (SecurityAgent L3); this spec documents the contract, it does
> **not** activate it.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/G-RT-BUILD-SPEC.md` (IL-510) | Real-time transaction fraud **scoring** (rule engine + ML via Jube) | **keep / REUSE boundary** — G-rt **consumes** G-device signals as feature inputs; **G-device is the SOURCE/producer**. G-device produces signals; G-rt scores. **No fraud-scoring logic here** (ADR-102) |
| `ROADMAP-MATRIX.md` I-security (SecurityAgent device-fingerprint, Keycloak IAM, PII Proxy) | identity/session security plane, CTO-gated | **keep / REUSE** — G-device **integrates** I-security (SecurityAgent fingerprint capability, IAM session context, PII Proxy); **does NOT reimplement** IAM/security |
| `docs/architecture/I-API-BUILD-SPEC.md` (IL-508) | API gateway — request context, authN/authZ | **keep / reference** — device/session signals are captured from the **I-api request context**; gateway logic **not** duplicated |
| `docs/architecture/A-KYC-BUILD-SPEC.md` / `A-IDV-BUILD-SPEC.md` (IL-500/501) | onboarding identity verification | **keep / reference** — onboarding is one-time identity proofing; **ATO is post-onboarding session protection** (distinct). Onboarding **not** duplicated |
| `docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml) | AML/sanctions/PEP screening | **keep / reference** — device fraud ≠ AML; G-device feeds G-rt, not F-aml directly; screening **not** duplicated |

No existing `G-DEVICE-BUILD-SPEC` / device-signal artifact on main (live audit: `find docs -iname '*g-device*'`/`*device-finger*` ⇒ empty; `ls docs/architecture` ⇒ A-IDV/A-KYC/A-KYB/B-EMI/D-FEE/D-FIN/D-GL/G-RT/I-API only). New file is **non-duplicative**; it **defines the signal source** consumed by G-rt, it does not re-implement scoring/security.

## 1. Scope — device-signal source (fingerprint, velocity, ATO)

G-device defines the **signal-production** layer feeding G-rt; all policy is **config-as-data** (CLAUDE.md §10 — no hardcoded thresholds):

1. **Device fingerprinting (privacy-minimised signal set)** — a stable, **minimised** device identifier derived from fraud-relevant attributes (user-agent class, platform, screen/locale coarse-grained, IP-derived geo region, TLS/connection traits). **No** intrusive/persistent tracking beyond the fraud purpose; the attribute set is config-as-data and capability-gated (§5/§8).
2. **Velocity checks (config-as-data thresholds)** — transaction/login frequency over sliding windows (per-customer, per-device, per-IP); thresholds + window sizes live in config, governance-tunable (not code).
3. **Account-takeover (ATO) detection** — session-anomaly signals: impossible-travel, device-change vs known-device baseline, new-device + high-value, session-hijack indicators, credential-stuffing velocity. Produces an **ATO alert** signal, not a decision.
4. **Signal model feeding G-rt** — normalised signals exposed as **feature inputs** to G-rt scoring (G-device produces; G-rt consumes + decides).

**Out** of G-device: fraud scoring / decisioning (G-rt), AML screening (F-aml), IAM/authentication/session issuance (I-security), gateway/request handling (I-api), any non-fraud secondary use.

## 2. Data model (DeviceSignal / VelocityWindow / ATOAlert)

Declarative, config-as-data; PII minimised (§6); only fraud-relevant attributes.

### 2.1 `DeviceSignal`
- `signal_id`, `session_ref`, `customer_ref` (pseudonymous), `correlation_id`.
- `device_fingerprint` (minimised, hashed/derived — **not** raw device identifiers persisted), `known_device` (boolean vs baseline), `geo_region` (coarse), `connection_traits` (fraud-relevant only).
- `captured_at`; capture source = **I-api request context** (§3).

### 2.2 `VelocityWindow`
- `window_id`, `scope` (customer | device | ip), `metric` (txn_count | login_count | amount_sum), `window_size` (config-as-data), `count`/`sum`, `threshold_ref` (config), `breached` (boolean).

### 2.3 `ATOAlert`
- `alert_id`, `customer_ref`, `session_ref`, `anomaly_type` (impossible_travel | device_change | new_device_high_value | session_hijack | credential_stuffing), `severity` (config-mapped), `evidence_refs` (PII-redacted), `raised_at`.
- ATO alert is a **signal** routed to G-rt (and/or step-up auth via I-security) — G-device does **not** block or decide.

## 3. Signal capture + output flow (source → G-rt)

```
client request → I-api gateway (request context)
  1. G-device captures minimised device signals from request context  [I-api = context source]
  2. update velocity windows (config-as-data thresholds)             → VelocityWindow{breached?}
  3. evaluate ATO anomalies (impossible-travel, device-change, …)    → ATOAlert (if any)
  4. normalise → DeviceSignal + velocity + ATO signals
  5. expose as feature inputs → G-rt scoring                         [G-device = producer, G-rt = consumer]
     (high-severity ATO MAY also trigger step-up auth via I-security — gated)
  6. emit signals/alerts → ClickHouse audit (I-infra), PII-redacted
```

- G-device **produces signals only**; it **never** scores fraud, decides PASS/HOLD, or blocks (G-rt owns decisioning). It **never** issues/validates auth tokens (I-security owns IAM).
- Capability is **CTO/CEO-gated** (SecurityAgent L3): activation of fingerprinting is an operator-authorized action; this spec defines the contract, not the activation (§5/§11).

## 4. Privacy-by-design (GDPR / UK-GDPR — fraud-only)

- **Lawful basis:** **legitimate interest = fraud prevention** (PSR SCA / Consumer Duty customer protection); documented; balancing test required at activation.
- **Data minimisation:** only **fraud-relevant** device signals; fingerprint is **derived/hashed**, not a raw persistent tracker; no full device graph, no cross-context profiling.
- **No secondary use:** device data used **solely** for fraud/ATO protection — never marketing, analytics, or behavioural tracking beyond fraud purpose.
- **Transparency + retention:** disclosed in privacy notice; retention limits config-as-data; PII routed via **PII Proxy (Presidio)** per I-security; no PII in logs/audit beyond redacted evidence.

## 5. Governance — capability gating

- **CTO/CEO-gated activation** (SecurityAgent L3): turning on device fingerprinting / ATO capture is an operator-authorized, governance-recorded action — **not** activated by this spec.
- **Config-as-data:** velocity thresholds, window sizes, fingerprint attribute set, ATO severity mapping all in config (CLAUDE.md §10), governance-tunable; no hardcoded thresholds.
- **No autonomous escalation:** G-device raises signals/alerts only; any decision (block, step-up) is owned by G-rt (scoring) or I-security (auth) under their own HITL/governance.

## 6. Producer/consumer contracts (referenced, not duplicated)

- **Produces signals → G-rt** (`G-RT-BUILD-SPEC` IL-510): `DeviceSignal` / `VelocityWindow` / `ATOAlert` as feature inputs to scoring. G-device **produces**; G-rt **consumes + decides**. Scoring **not** reimplemented.
- **Captures from I-api request context** (`I-API-BUILD-SPEC` IL-508): device/session attributes sourced from the gateway request; gateway logic **not** duplicated.
- **Integrates I-security**: SecurityAgent fingerprint capability + IAM session/known-device baseline + PII Proxy; high-severity ATO MAY trigger step-up auth via I-security. IAM/security **not** reimplemented.
- **Emits audit to ClickHouse** (I-infra): signals/alerts, PII-redacted; observability not reimplemented.

## 7. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_device_fingerprint_minimised` (fingerprint derived/hashed from config-defined fraud-relevant attrs only; no raw persistent identifier; minimisation boundary test).
- [ ] `test_velocity_thresholds_config_as_data` (windows + thresholds from config; no hardcode — CLAUDE.md §10).
- [ ] `test_ato_anomaly_detection` (impossible-travel / device-change / new-device-high-value / credential-stuffing → ATOAlert).
- [ ] `test_signals_feed_g_rt_only_as_features` (G-device produces signals; **does not score/decide/block**; G-rt consumes; boundary test).
- [ ] `test_capture_from_i_api_context` (signals sourced from gateway request context; G-device does not reimplement gateway).
- [ ] `test_no_iam_reimplementation` (no token issuance/validation; integrates I-security; step-up delegated).
- [ ] `test_privacy_fraud_only_no_secondary_use` (device data fraud-purpose only; PII via Proxy; redacted audit; retention config).
- [ ] `test_capability_gated` (fingerprinting activation requires CTO/CEO gate; spec defines contract, does not auto-activate).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; G-rt/I-security/I-api boundaries respected; audit rows per ADR-027.

## 8. SAFETY/PRIVACY FENCE (anti-fraud, fraud-only — fail-closed)

- G-device (and this build-spec) defines a **legitimate anti-fraud account-protection process only** — **not** surveillance, **not** behavioural tracking beyond the fraud purpose.
- **Specification only:** the factory implements **no** live fingerprinting and collects **no** device data.
- Privacy-by-design is mandatory (§4): legitimate-interest (fraud prevention) lawful basis, data minimisation (fraud-relevant signals only), transparency, retention limits, **no secondary use**, PII Proxy (Presidio).
- Capability is **CTO/CEO-gated** (SecurityAgent L3) — documented here, **not** activated.
- **Fail-closed:** if any requirement would extend device data to non-fraud/secondary use, persistent cross-context tracking, or surveillance → **STOP + operator brief**; do not implement.

## 9. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no live fingerprinting / no device-data collection** (spec only, §8 fence); **no fraud scoring / decisioning / blocking** (G-rt owns it; G-device only produces signals); **no AML/sanctions/PEP screening** (F-aml owns it); **no IAM / authentication / token issuance / session management** (I-security owns it; step-up delegated); **no gateway/request handling** (I-api); **no surveillance, no behavioural tracking beyond fraud, no secondary use, no persistent cross-context profiling**; no autonomous activation of the fingerprint capability (CTO/CEO-gated).

## 10. Perimeter

- **In:** device-signal **source** — minimised fingerprinting, velocity checks (config-as-data), ATO/session-anomaly detection, the signal model + producer contract to G-rt, integration hooks to I-security/I-api/I-infra.
- **Out (fail-closed, §9):** fraud scoring/decisioning (G-rt), AML (F-aml), IAM/security (I-security), gateway (I-api), any non-fraud secondary use.
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§11).

## 11. Operator gates NOT crossed

- **Cross-repo runtime** — implementing G-device in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Fingerprint-capability activation** = **CTO/CEO gate** (SecurityAgent L3) + operator-authorized action — not done here.
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 12. References

`docs/architecture/G-RT-BUILD-SPEC.md` (IL-510 — fraud-scoring consumer of G-device signals);
`docs/architecture/I-API-BUILD-SPEC.md` (IL-508 — request-context capture source);
`docs/architecture/A-KYC-BUILD-SPEC.md` / `A-IDV-BUILD-SPEC.md` (IL-500/501 — onboarding vs post-onboarding ATO distinction);
`docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml — distinct from device fraud);
`ROADMAP-MATRIX.md` (G-rt sibling, I-security, I-infra rows);
ADR-027 (audit trail), ADR-102/103/115/116/117/119; I-01/I-24/I-28; BUG-007 (HITL thresholds, via G-rt/I-security); PSR SCA / Consumer Duty; CLAUDE.md §9/§10/§11; I-security (SecurityAgent, PII Proxy / Presidio, Keycloak IAM); I-infra (ClickHouse).
