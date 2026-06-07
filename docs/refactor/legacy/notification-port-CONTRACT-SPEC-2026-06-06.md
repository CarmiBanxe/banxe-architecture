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

```python
from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum
from typing import Any


class NotificationChannel(StrEnum):
    TELEGRAM = "telegram"
    MOBILE_PUSH = "mobile_push"
    EMAIL = "email"
    SMS = "sms"
    IN_APP = "in_app"


class Severity(StrEnum):
    INFO = "info"
    WARN = "warn"
    ALERT = "alert"
    CRITICAL = "critical"


@dataclass(frozen=True)
class Recipient:
    user_id: str
    channel_preferences: list[NotificationChannel]


@dataclass(frozen=True)
class NotificationMessage:
    severity: Severity
    subject: str
    body: str
    correlation_id: str
    dedupe_key: str  # caller-generated; same key = same logical notification
    template: str | None = None
    data: dict[str, Any] | None = None


@dataclass(frozen=True)
class DeliveryResult:
    channel: NotificationChannel
    delivered: bool
    deduped: bool
    provider_message_id: str | None = None
    error: str | None = None
```

## Operations

```python
import abc
from abc import abstractmethod


class NotificationProviderPort(abc.ABC):
    @abstractmethod
    async def send(
        self,
        recipient: Recipient,
        message: NotificationMessage,
    ) -> list[DeliveryResult]:
        ...

    @abstractmethod
    async def is_channel_available(self, channel: NotificationChannel) -> bool:
        ...
```

Python target naming: the emi-stack contract surface is named `NotificationProviderPort` in
`services/notifications/notification_provider_port.py`. This avoids a class-name collision with the
existing application-facing `NotificationPort` (services/notifications/notification_port.py) and
mirrors the KYC precedent (KYCProviderPort / kyc_provider_port.py is separate from the workflow
KYCWorkflowPort). The provider-facing delivery boundary and the application dispatch boundary are
distinct bounded contexts and MUST NOT be merged.

## Delivery semantics

- send: at-least-once delivery; idempotent per dedupe_key (same key within window = single delivery per channel).
- Routes to enabled adapters by recipient.channel_preferences; returns one DeliveryResult per attempted channel.
- critical severity (e.g. MLRO escalation) MUST attempt all available channels, not just preferred.
- Channel failure on one does not block others; partial delivery returns mixed list[DeliveryResult].

## Idempotency rules

- dedupe_key is caller-generated; identical key within dedupe window (default 24h) -> deduped=True, single delivery per channel.
- Adapter stores (dedupe_key, channel) -> provider_message_id before/after send.
- Retry same dedupe_key -> return stored DeliveryResult; do not re-send.

## Error model

| Error class | Meaning | Caller action |
|---|---|---|
| ValidationError | empty body / no recipient channels | fix and resend |
| ChannelUnavailable | provider down (Telegram/FCM) | other channels still attempted; retry via circuit-breaker |
| RecipientOptedOut | user disabled this channel | skip channel; not an error for critical severity (override) |
| RateLimited | provider throttling | backoff; queue and retry |
| DedupeHit | dedupe_key already delivered | deduped=True; not an error |

All sends + errors carry correlation_id + dedupe_key and persist to guardian_audit_events.

## Audit obligations (ADR-027)

- Every send emits one guardian_audit_events row per channel attempted.
- Fields: correlation_id, dedupe_key, user_id, channel, severity, delivered, provider_message_id, timestamp_utc.
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

1. send(valid, single channel) -> delivered=True; provider_message_id present.
2. send same dedupe_key twice -> deduped=True on second; single provider call.
3. send critical severity -> attempts ALL available channels regardless of preferences.
4. send with one channel down -> that channel delivered=False; others delivered=True (partial).
5. send empty body -> ValidationError; no provider call.
6. is_channel_available(up) -> True; (down) -> False.
7. RecipientOptedOut on non-critical -> channel skipped; critical -> override delivers.
8. provider rate-limited -> RateLimited; queued + retried.
9. every send emits one guardian_audit_events row per channel with correlation_id + dedupe_key.

## Acceptance criteria

- NotificationProviderPort interface frozen; changes require CONTRACT revision.
- TelegramAdapter + MobilePushAdapter pass the 9-test conformance suite.
- Idempotency (dedupe_key) enforced within window.
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
