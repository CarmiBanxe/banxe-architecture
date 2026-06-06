# NotificationPort CONTRACT SPEC — executable contract (C9 notifications)

Date: 2026-06-06
Status: CONTRACT SPEC (executable; deepens SPEC #3 NotificationPort; serves NEW capability C9)
Scope: canonical NotificationPort contract — types, operations, delivery semantics, idempotency, audit, conformance
Source SPECs: notification-port-SPEC-2026-05-23.md (parent SPEC #3)
NEW capability: C9 (user notifications: Telegram, mobile push) per NEW-PROJECT-PRIORITY-MAP
Related: ADR-021 (NotificationPort candidate 6th); ADR-027 audit; consumer of every regulatory-critical port (MLRO escalations)
Owner: Terminal B (smart refactor)

## Purpose

Deepen SPEC #3 NotificationPort into an executable contract. NotificationPort is the cross-cutting delivery layer consumed by every regulatory-critical port (Wallet/Partner/Exchange/KYC) for user alerts and MLRO escalations. Delivery must be at-least-once with dedupe, multi-channel, and auditable. Terminal B implements TelegramAdapter + MobilePushAdapter against this contract. NEW-driven: C9 capability authoritative; legacy telegram-bot + neuron-push reused only to serve C9.

## Contract types

```typescript
export type NotificationChannel = "telegram" | "mobile_push" | "email" | "sms" | "in_app";
export type Severity = "info" | "warn" | "alert" | "critical";

export interface Recipient {
  userId: string;
  channelPreferences: NotificationChannel[];
}

export interface NotificationMessage {
  severity: Severity;
  subject: string;
  body: string;
  template?: string;
  data?: Record<string, unknown>;
  correlationId: string;
  dedupeKey: string; // caller-generated; same key = same logical notification
}

export interface DeliveryResult {
  channel: NotificationChannel;
  delivered: boolean;
  providerMessageId?: string;
  deduped: boolean;
  error?: string;
}
```

## Operations

```typescript
export interface NotificationPort {
  send(recipient: Recipient, message: NotificationMessage): Promise<DeliveryResult[]>;
  isChannelAvailable(channel: NotificationChannel): Promise<boolean>;
}
```

## Delivery semantics

- send: at-least-once delivery; idempotent per dedupeKey (same key within window = single delivery per channel).
- Routes to enabled adapters by recipient.channelPreferences; returns one DeliveryResult per attempted channel.
- critical severity (e.g. MLRO escalation) MUST attempt all available channels, not just preferred.
- Channel failure on one does not block others; partial delivery returns mixed DeliveryResult[].

## Idempotency rules

- dedupeKey is caller-generated; identical key within dedupe window (default 24h) -> deduped=true, single delivery per channel.
- Adapter stores (dedupeKey, channel) -> providerMessageId before/after send.
- Retry same dedupeKey -> return stored DeliveryResult; do not re-send.

## Error model

| Error class | Meaning | Caller action |
|---|---|---|
| ValidationError | empty body / no recipient channels | fix and resend |
| ChannelUnavailable | provider down (Telegram/FCM) | other channels still attempted; retry via circuit-breaker |
| RecipientOptedOut | user disabled this channel | skip channel; not an error for critical severity (override) |
| RateLimited | provider throttling | backoff; queue and retry |
| DedupeHit | dedupeKey already delivered | deduped=true; not an error |

All sends + errors carry correlationId + dedupeKey and persist to guardian_audit_events.

## Audit obligations (ADR-027)

- Every send emits one guardian_audit_events row per channel attempted.
- Fields: correlationId, dedupeKey, userId, channel, severity, delivered, providerMessageId, timestamp_utc.
- critical severity notifications (MLRO escalations from Wallet/Partner/Exchange/KYC ports) MUST be auditable for FCA Section 4.
- Retention: 5y for compliance-related notifications; 90d for routine.

## Adapter mapping

| Adapter | Source | Channel |
|---|---|---|
| TelegramAdapter | legacy telegram-bot (SPEC #3) | telegram |
| MobilePushAdapter | legacy neuron-push-notifications (SPEC #3) | mobile_push |
| EmailAdapter | build-fresh (deferred) | email |
| SmsAdapter | build-fresh (deferred) | sms |

Two adapters at launch (Telegram + mobile push); email/sms deferred to a later quarter.

## Conformance test suite (one suite, all adapters)

1. send(valid, single channel) -> delivered=true; providerMessageId present.
2. send same dedupeKey twice -> deduped=true on second; single provider call.
3. send critical severity -> attempts ALL available channels regardless of preferences.
4. send with one channel down -> that channel delivered=false; others delivered=true (partial).
5. send empty body -> ValidationError; no provider call.
6. isChannelAvailable(up) -> true; (down) -> false.
7. RecipientOptedOut on non-critical -> channel skipped; critical -> override delivers.
8. provider rate-limited -> RateLimited; queued + retried.
9. every send emits one guardian_audit_events row per channel with correlationId + dedupeKey.

## Acceptance criteria

- NotificationPort interface frozen; changes require CONTRACT revision.
- TelegramAdapter + MobilePushAdapter pass the 9-test conformance suite.
- Idempotency (dedupeKey) enforced within window.
- critical-severity all-channel delivery verified (MLRO escalation path).
- Audit: 1 row per channel per send; 5y retention for compliance notifications.

## References

- notification-port-SPEC-2026-05-23.md (parent SPEC #3)
- ADR-021 (NotificationPort candidate 6th port); ADR-027 audit trail
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C9 capability)
- sibling CONTRACTs: Wallet/Partner/Exchange/KYC (2026-06-06) — all emit MLRO escalations via NotificationPort
- SPEC #6 fiat-backend-utils (@banxe/circuit-breaker for ChannelUnavailable)
- RISK_REGISTER-2026-05-22.md (R-COMP-FCA-02 notification audit)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF NotificationPort CONTRACT SPEC (executable; C9; 5 of 6 ports now have CONTRACTs) ===
