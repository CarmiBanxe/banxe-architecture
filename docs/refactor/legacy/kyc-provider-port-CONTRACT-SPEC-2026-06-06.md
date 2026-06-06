# KYCProviderPort CONTRACT SPEC — executable contract (C5 KYC/AML)

Date: 2026-06-06
Status: CONTRACT SPEC (executable; deepens SPEC #8 KYCProviderPort; serves NEW capability C5 KYC/AML)
Scope: canonical KYCProviderPort contract — types, operations, webhook reliability, idempotency, audit, conformance tests
Source SPECs: kyc-provider-port-SPEC-2026-05-26.md (parent SPEC #8)
NEW capability: C5 (KYC/AML onboarding + tiers) per ADR-028 + NEW-PROJECT-PRIORITY-MAP
Related: ADR-028 re-verification; ADR-034 webhook reliability; ADR-021; RISK_REGISTER R-REG-02 (KYC gap) + R-REG-03 (Travel Rule)
Owner: Terminal B (smart refactor)

## Purpose

Deepen SPEC #8 KYCProviderPort into an executable, compliance-critical contract. KYC gates account opening and crypto outflows, so status transitions MUST be auditable, webhook-reliable (DLQ + retry), and tamper-evident. Terminal B implements SumSubAdapter (primary) + a fallback provider adapter against this contract. NEW-driven: C5 KYC/AML capability is authoritative; legacy banxe-baas SumSub code is extracted only because it serves C5.

## Contract types

```typescript
export type KYCTier = "none" | "basic" | "intermediate" | "full";
export type KYCStatus = "not_started" | "pending" | "approved" | "rejected" | "review" | "expired";
export type ProviderLevelId = string;

export interface KYCSession {
  userId: string;
  accessToken: string;
  expiresAt: string;
  providerLevelId: ProviderLevelId;
  correlationId: string;
}

export interface KYCResult {
  userId: string;
  status: KYCStatus;
  tier: KYCTier;
  providerLevelId: ProviderLevelId;
  reviewedAt?: string;
  rejectReasons?: string[];
  raw?: Record<string, unknown>;
}

export interface WebhookOutcome {
  processed: boolean;
  userId?: string;
  newStatus?: KYCStatus;
  deduped: boolean; // true if event already seen (idempotency)
}
```

## Operations

```typescript
export interface KYCProviderPort {
  startSession(userId: string, tier: KYCTier, correlationId: string): Promise<KYCSession>;
  getStatus(userId: string): Promise<KYCResult>;
  handleWebhook(payload: unknown, signature: string): Promise<WebhookOutcome>;
  changeLevel(userId: string, newTier: KYCTier, correlationId: string): Promise<KYCResult>;
}
```

## Operation semantics

- startSession: issues provider web-SDK access token for the given tier; idempotent per (userId, tier) within token TTL.
- getStatus: read-only; safe to poll; returns last known KYCResult.
- handleWebhook: provider-initiated status update; MUST verify signature; MUST be idempotent (dedupe by provider event id).
- changeLevel: tier upgrade/downgrade; triggers re-verification per ADR-028.

## Webhook reliability (ADR-034)

- handleWebhook verifies HMAC signature BEFORE processing; invalid signature -> reject + audit, never process.
- Each provider event has a unique event id; store processed event ids; duplicate -> WebhookOutcome.deduped=true, no reprocessing.
- Processing failure (downstream error) -> push to dead-letter queue (DLQ) with retry counter.
- DLQ retry with exponential backoff; after max retries -> alert MLRO; never silently drop a KYC status change.
- Webhook endpoint idempotent: same event delivered N times -> single state change.

## Idempotency rules

- startSession idempotent per (userId, tier) within token TTL.
- handleWebhook idempotent per provider event id.
- changeLevel idempotent per (userId, newTier) until status actually transitions.

## Error model

| Error class | Meaning | Caller action |
|---|---|---|
| InvalidSignature | webhook HMAC mismatch | reject; audit; possible attack |
| UnknownUser | userId not found | reject; caller bug |
| ProviderUnavailable | SumSub API down | retry via circuit-breaker; getStatus stays last-known |
| TierDowngradeBlocked | regulatory rule forbids downgrade | escalate to MLRO |
| WebhookReplayDetected | duplicate event id | dedupe; WebhookOutcome.deduped=true |

All errors carry correlationId and persist to guardian_audit_events.

## Audit obligations (ADR-027 + R-REG-02)

- Every startSession, getStatus, handleWebhook, changeLevel emits one guardian_audit_events row.
- Fields: correlationId, userId, operation, status, tier, providerLevelId, http_status, timestamp_utc.
- Every status transition (pending->approved, etc.) is an immutable audit record for MLRO + AMLD evidence.
- KYCResult.raw stored for FCA Section 4 evidence; PII redacted per ADR-021 PII routing.
- Retention 5 years (CASS 15 / AMLD).

## Adapter mapping

| Adapter | Source | Role |
|---|---|---|
| SumSubAdapter | legacy banxe-baas SumSub (SPEC #8) | primary KYC provider |
| FallbackKYCAdapter | build-fresh (Vouched/Onfido) | regulatory risk mitigation |

Both implement identical KYCProviderPort; provider selection via config + MLRO approval.

## Conformance test suite (one suite, all adapters)

1. startSession(user, basic) -> accessToken present; expiresAt future.
2. startSession same (user, tier) within TTL -> same session (idempotent).
3. getStatus(known user) -> consistent KYCResult; no side effects.
4. getStatus(unknown) -> UnknownUser.
5. handleWebhook(valid sig) -> processed=true; status transition persisted.
6. handleWebhook(invalid sig) -> InvalidSignature; NOT processed; audited.
7. handleWebhook same event id twice -> deduped=true; single state change.
8. handleWebhook downstream failure -> DLQ entry created; retried.
9. changeLevel(upgrade) -> re-verification triggered (ADR-028).
10. changeLevel(regulatory-forbidden downgrade) -> TierDowngradeBlocked; MLRO escalation logged.
11. every operation emits exactly one guardian_audit_events row with correlationId.

## Acceptance criteria

- KYCProviderPort interface frozen; changes require CONTRACT revision.
- 2 adapters (SumSub + fallback) pass the 11-test conformance suite.
- Webhook DLQ + retry + signature verification implemented per ADR-034.
- Idempotency (session, webhook event id, level change) enforced.
- Every KYC status transition persisted; 5y retention; PII redacted.
- R-REG-02 (KYC/AML gap) marked CLOSED on cut-over.

## References

- kyc-provider-port-SPEC-2026-05-26.md (parent SPEC #8)
- ADR-028 KYC re-verification; ADR-034 webhook reliability; ADR-021 KYCProviderPort; ADR-027 audit trail
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C5 KYC/AML capability)
- sibling CONTRACTs: PartnerPort + WalletPort + ExchangePort (2026-06-06)
- SPEC #6 fiat-backend-utils (@banxe/circuit-breaker for ProviderUnavailable)
- SPEC #7 crypto-ops-subgroup (Travel Rule consumer of KYC status, R-REG-03)
- RISK_REGISTER-2026-05-22.md (R-REG-02, R-REG-03)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF KYCProviderPort CONTRACT SPEC (executable; C5 KYC/AML; all regulatory-critical ports now have CONTRACTs) ===
