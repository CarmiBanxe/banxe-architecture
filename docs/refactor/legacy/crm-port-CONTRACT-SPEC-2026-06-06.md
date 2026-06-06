# CRMPort CONTRACT SPEC — executable contract (C10 referral/CRM)

Date: 2026-06-06
Status: CONTRACT SPEC (executable; deepens SPEC #6 CRMPort; serves NEW capability C10; final port contract -> 6/6)
Scope: canonical CRMPort contract — types, operations, idempotency, audit, conformance
Source SPECs: fiat-backend-utils-SPEC-2026-05-23.md (parent SPEC #6, banxe-referrers)
NEW capability: C10 (referral / CRM) per NEW-PROJECT-PRIORITY-MAP
Related: ADR-021 CRMPort; ADR-027 audit; RISK_REGISTER R-COMP-FCA-03 (referral audit)
Owner: Terminal B (smart refactor)

## Purpose

Deepen SPEC #6 CRMPort into an executable contract. This is the final port contract, completing 6/6 executable CONTRACTs. Referral events feed compliance evidence (referral fraud / AML), so registration is idempotent and audited. Terminal B implements ReferralCRMAdapter (from banxe-referrers) against this contract. NEW-driven: C10 capability authoritative; legacy banxe-referrers reused only to serve C10.

## Contract types + operations

See SPEC #6 fiat-backend-utils for the CRMPort interface (registerReferral, resolveReferralCode, getUser, updateUserTier). This CONTRACT freezes the semantics below.

## Operation semantics

- registerReferral: idempotent per (referrer, referee) pair; a referee can only be registered once.
- resolveReferralCode: read-only; returns owning userId or null.
- getUser: read-only; returns CRMUser or null.
- updateUserTier: idempotent per (userId, tier); re-applying same tier is a no-op.

## Idempotency rules

- registerReferral keyed on (referrer, referee); duplicate -> accepted=false, reason="already_registered".
- Self-referral (referrer == referee) -> accepted=false, reason="self_referral".
- updateUserTier idempotent; same tier -> no-op success.

## Error model

| Error class | Meaning | Caller action |
|---|---|---|
| ValidationError | bad code / empty userId | fix and resubmit |
| SelfReferral | referrer == referee | reject; fraud signal |
| AlreadyRegistered | referee already has a referrer | reject; not retryable |
| UnknownReferralCode | code resolves to nobody | surface to user |

All operations carry correlationId and persist to guardian_audit_events.

## Audit obligations (ADR-027 + R-COMP-FCA-03)

- registerReferral + updateUserTier emit one guardian_audit_events row each.
- Fields: correlationId, referrer, referee, code, tier, accepted, reason, timestamp_utc.
- Referral events retained for AML fraud analysis; tier changes for FCA evidence.

## Adapter mapping

| Adapter | Source | Role |
|---|---|---|
| ReferralCRMAdapter | legacy banxe-referrers (SPEC #6) | referral + tier CRM |

## Conformance test suite

1. registerReferral(valid pair) -> accepted=true.
2. registerReferral same pair twice -> accepted=false, reason=already_registered.
3. registerReferral self -> accepted=false, reason=self_referral.
4. resolveReferralCode(known) -> owning userId; unknown -> null.
5. getUser(known) -> CRMUser; unknown -> null.
6. updateUserTier(new tier) -> applied; same tier -> no-op success.
7. every mutating op emits one guardian_audit_events row with correlationId.

## Acceptance criteria

- CRMPort interface frozen; changes require CONTRACT revision.
- ReferralCRMAdapter passes the 7-test conformance suite.
- Idempotency (referral pair, tier) enforced; self-referral + duplicate blocked.
- Audit: 1 row per mutating op; referral events retained for AML.
- 6/6 executable port CONTRACTs complete (Wallet/Partner/Exchange/KYC/Notification/CRM).

## References

- fiat-backend-utils-SPEC-2026-05-23.md (parent SPEC #6; CRMPort interface)
- ADR-021 CRMPort; ADR-027 audit trail
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C10 capability)
- sibling CONTRACTs (Wallet/Partner/Exchange/KYC/Notification, 2026-06-06)
- RISK_REGISTER-2026-05-22.md (R-COMP-FCA-03)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF CRMPort CONTRACT SPEC (executable; C10; 6/6 port CONTRACTs complete) ===
