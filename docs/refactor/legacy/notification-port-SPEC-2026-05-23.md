# Refactor SPEC — NotificationPort consolidation

Date: 2026-05-23
Status: SPEC (design baseline; impl owned by Terminal B per House rule 10)
Scope: telegram-bot + neuron-push-notifications + neuron-push-notifications-chat -> NotificationPort
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1
Related: ADR-021 five-new-ports (NotificationPort = candidate 6th port); ADR-017 vendor-to-os; CLASS_KEEP.tsv
Owner: Central authors SPEC; Terminal B owns impl

## Purpose

Define NotificationPort as a candidate 6th Hexagonal Port (amendment to ADR-021) and specify how three legacy notification services consolidate into two production adapters behind that port. Without NotificationPort, downstream services (compliance alerts, customer onboarding emails, trade confirmations, MLRO escalations) lack a unified sender-agnostic interface.

## Legacy inventory (read-only audit 2026-05-23)

### 1. crypto-api/telegram-bot (NestJS production microservice)

- Path: crypto-api/telegram-bot
- Lang: TypeScript (NestJS)
- Size: 1.2 MB (most mature of the three)
- Node engine: per .nvmrc (modern)
- Tooling: eslint, husky, prettier, jest, commitlint, nest-cli
- Has .env.example (production-like config); has .changelog-graphql-diffs.sh (GraphQL coupling, ADR-019 implication)
- Git history: active (Task-9631; XRP/ETH/DOT/EOS getInfo format changes)
- Role: Telegram channel notification adapter

### 2. neuron/neuron-push-notifications (AWS Lambda, plain JS)

- Path: neuron/neuron-push-notifications
- Lang: plain JS + Babel (legacy)
- Size: 264 KB
- Runtime: AWS Lambda via serverless-webpack + serverless framework
- Components: authenticate.js, config.js, mapIds.js, message.js, presence.js, private.js
- Git history: neuronchain (BitShares fork) coupling; AWS CodeCommit origin
- Role: mobile push notifications adapter (Firebase/APNS)

### 3. neuron/neuron-push-notifications-chat (NestJS skeleton)

- Path: neuron/neuron-push-notifications-chat
- Lang: TypeScript (NestJS, same boilerplate as telegram-bot)
- Size: 592 KB (mostly package-lock.json + boilerplate)
- Source: src/ + test/ minimal; README 1 KB; tsconfig
- Git history: 3 commits only ("init project" x2 + "education task RMQ user")
- Role: chat-specific notifications skeleton (not production)

## Decision per service

### telegram-bot: TRANSFORM (production adapter)
- Extract Telegram-specific code from NestJS service to a TelegramAdapter implementing NotificationPort.
- Remove GraphQL coupling per ADR-019 (Apollo to Hasura migration); replace with NotificationPort interface call.
- Keep .env.example pattern; ship as part of NEW banxe-notifications repo.

### neuron-push-notifications: TRANSFORM (mobile adapter)
- Extract Firebase/APNS push logic from AWS Lambda into MobilePushAdapter implementing NotificationPort.
- Drop Babel + serverless-webpack; modernise to TypeScript on Node 18+.
- Remove AWS Lambda packaging; run as long-lived NestJS service alongside telegram-bot (or as worker).
- Drop neuronchain coupling (BitShares fork is DROP per SPEC #1 chain classification).

### neuron-push-notifications-chat: DROP
- 3 commits, skeleton-only, no production code worth migrating.
- Re-implement chat notifications inside banxe-notifications using the same NotificationPort + chat-specific message templates.
- Tag as ARCHIVE-RESEARCH; no code migration.

## NotificationPort contract (candidate 6th Hexagonal port)

```typescript
export type NotificationChannel = "telegram" | "mobile_push" | "email" | "sms" | "in_app";

export type NotificationSeverity = "info" | "warn" | "alert" | "critical";

export interface NotificationRecipient {
  userId: string;
  channelPreferences: NotificationChannel[];
}

export interface NotificationMessage {
  severity: NotificationSeverity;
  subject: string;
  body: string;
  template?: string;
  data?: Record<string, unknown>;
  correlationId: string;
}

export interface NotificationDeliveryResult {
  channel: NotificationChannel;
  delivered: boolean;
  providerMessageId?: string;
  error?: string;
}

export interface NotificationPort {
  send(recipient: NotificationRecipient, message: NotificationMessage): Promise<NotificationDeliveryResult[]>;
  isChannelAvailable(channel: NotificationChannel): Promise<boolean>;
}
```

Contract notes:
- All sends are async and return one result per channel attempted.
- The port routes to enabled adapters based on recipient.channelPreferences.
- Each adapter implements only its channel; the port itself never hardcodes provider logic.
- ADR amendment required to add NotificationPort as 6th port; this SPEC names it as a candidate.

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decisions per service (this SPEC).
- Phase B (Terminal B): scaffold NEW repo banxe-notifications (NestJS + TypeScript + Node 18+); copy production-relevant code from telegram-bot baseline.
- Phase C (Terminal B): implement NotificationPort interface; TelegramAdapter from telegram-bot extract; MobilePushAdapter from neuron-push-notifications extract.
- Phase D (Terminal B): contract tests: send (mocked recipient) returns delivery results per channel; integration tests against Telegram bot test instance + Firebase test project.
- Phase E (Terminal B): cut legacy telegram-bot and neuron-push-notifications callers over to NotificationPort; remove old endpoints.
- Phase F (Terminal B): tag legacy 3 services ARCHIVE; record decommission in IL.

## Risk register tie-in

- R-MIG-02 (legacy source on evo1 only): mirror all three dirs to off-evo1 backup per R4 PREP.
- R-COMP-FCA-01 (notification audit trail): every NotificationPort send must persist to guardian_audit_events (or a dedicated table) with correlationId for MLRO traceability.
- R-PRIV-02 (GDPR Art. 15-17): NotificationPort must support recipient-level redaction on SAR; ADR amendment required.
- R-SEC-NEW-02 (provider credential leak): Telegram bot token and Firebase service account key live under /etc/banxe-notifications/.env mode 600 per UNIVERSAL-CANON section 7.

## Acceptance criteria

- NotificationPort interface defined and ADR amendment proposed to add it as 6th Hexagonal port.
- TelegramAdapter + MobilePushAdapter implemented; contract tests green for both.
- All non-test callers of legacy telegram-bot and neuron-push-notifications switched to NotificationPort.
- neuron-push-notifications-chat tagged ARCHIVE; no code migrated.
- Notification audit trail persisted for every send (correlationId + delivery result).

## Open questions (route to Architecture WG + MLRO)

- Should NotificationPort become a binding 6th port via ADR-021 amendment, or live as a separate ADR?
- Should email + SMS adapters be in Phase B, or deferred to Q5-Q6?
- Does notification persistence to guardian_audit_events satisfy CASS 15 retention, or does it need its own 5y TTL table?
- Is in-app notification a separate adapter, or a frontend-only concern outside NotificationPort?

## References

- ADR-021 five-new-ports (NotificationPort = candidate 6th)
- ADR-017 vendor-to-OpenSource policy
- ADR-019 GraphQL migration (telegram-bot GraphQL coupling)
- REFACTOR_MASTER_PLAN.md
- CLASS_KEEP.tsv (3 KEEP-EXTRACT rows for notifications)
- RISK_REGISTER-2026-05-22.md (R-MIG-02, R-COMP-FCA-01, R-PRIV-02)
- UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10)
- UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-23.md (House rules 11 + 12)

=== END OF NotificationPort SPEC (snapshot 4ca0eef) ===

## NEW capability anchor (per NEW-PROJECT-PRIORITY-MAP canon)

Serves NEW capability C9 (user notifications: Telegram, mobile push) per NotificationPort (candidate 6th port). Canon: NEW drives legacy reuse — telegram-bot + neuron-push are reused only because C9 needs Telegram + mobile push channels; neuron-push-notifications-chat (skeleton) is anti-mapped (DROP, no NEW capability beyond NotificationPort). No decision change; NEW-need-first justification confirmed.
