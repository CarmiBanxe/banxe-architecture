# ADR-FRAUD-02: Account Takeover Prevention — Velocity Checks + Session Anomaly

## Status
Accepted

## Context
Account Takeover (ATO) is one of the highest-risk fraud vectors for EMI firms.
Without velocity-based detection, brute force attacks and credential stuffing
go undetected until funds are exfiltrated. FCA PS22/9 Consumer Duty requires
firms to protect customers from foreseeable harm including fraud.

## Decision
An `ATOPreventionService` in `services/ato_prevention/` provides layered defense:

1. **VelocityChecker**: Windowed failed login detection.
   - >3 failed in 5min → STEP_UP (MFA challenge).
   - >10 failed in 15min → LOCK (account frozen).
   - >5 unique IPs in 10min → LOCK (IP rotation attack).
2. **SessionManagerPort**: Protocol for session state tracking (ACTIVE, STEP_UP_REQUIRED,
   LOCKED, BLOCKED). InMemory stub for tests.
3. **Jurisdiction blocking**: Login from I-02 countries → immediate BLOCK (I-02).
4. **HITL escalation**: LOCK/BLOCK actions → `ATOHITLProposal` for SECURITY_OFFICER (I-27).
5. **Audit trail**: Every assessment logged with hashed IP, no raw PII (I-24).

## Consequences
Positive:
- Brute force and credential stuffing detected within seconds.
- IP rotation attacks caught before account compromise.
- HITL ensures no silent account lockouts — security team always notified.

Negative:
- Real-time Redis velocity tracking not yet wired (in-memory only).
- Step-up auth (MFA) trigger exists but MFA service not yet integrated.
- Rate limiting at API gateway layer is complementary but separate.

## References
- IL-FRAUD-02 (Sprint 45), PR: CarmiBanxe/banxe-emi-stack#30
- I-01, I-02, I-24, I-27
