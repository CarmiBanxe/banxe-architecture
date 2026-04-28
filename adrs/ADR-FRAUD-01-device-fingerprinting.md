# ADR-FRAUD-01: Device Fingerprinting — Session Binding + Anomaly Detection

## Status
Accepted

## Context
S5 (Compliance/AML/KYC) lacked device-level fraud controls. Without device
fingerprinting, the EMI cannot detect account sharing, device cloning, or
impossible travel — all common ATO attack vectors. FCA expects EMI firms to
implement proportionate fraud prevention measures under MLR 2017 and PS22/9
Consumer Duty.

## Decision
A `FingerprintService` in `services/device_fingerprint/` orchestrates device
matching, session binding, and anomaly detection:

1. **FingerprintEngine** (existing): hash-based device ID, match against known devices.
2. **AnomalyDetector** (new): scores anomalies — NEW_DEVICE (+30), LOCATION_CHANGE (+20),
   IMPOSSIBLE_TRAVEL (+40). Risk levels: LOW/MEDIUM/HIGH/CRITICAL.
3. **FingerprintStorePort** (new): Protocol for session bindings. InMemory stub for tests.
4. **No raw PII in logs**: IP addresses SHA256-hashed, no user-agent stored in audit (I-24).
5. **HITL escalation**: HIGH/CRITICAL risk → `FingerprintHITLProposal` for FRAUD_ANALYST (I-27).
6. **Jurisdiction blocking**: devices from I-02 countries rejected immediately.

## Consequences
Positive:
- S5 coverage moves from 65% toward 75%.
- Device-level anomaly detection enables ATO prevention pipeline.
- Privacy-by-design: no PII in audit logs.

Negative:
- Browser fingerprint collection requires frontend integration (not yet wired).
- Geo-IP resolution requires external service (MaxMind/IP2Location — not yet integrated).

## References
- IL-FRAUD-01 (Sprint 45), PR: CarmiBanxe/banxe-emi-stack#28
- I-01, I-02, I-24, I-27
