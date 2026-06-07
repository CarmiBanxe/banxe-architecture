# Refactor SPEC #14 — Bitrix CRM adapter + WebhookPort (closes CLASS_PORT)

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_PORT final; NEW-driven; Bitrix CRMPort adapter + new WebhookPort C21)
Scope: 3 PORT-ADAPTER projects -> BitrixCRMAdapter (CRMPort) + WebhookPort
Source: BANXE.RAR; CLASS_PORT.tsv (bitrix-support-connector, banxe-fiat-backend/bitrix, banxe-webhook)
NEW capability: C10 (CRM via Bitrix adapter) + surfaces C21 (webhook ingestion via WebhookPort)
Related: SPEC #6 CRMPort + CONTRACT; ADR-034 webhook reliability
Owner: Terminal B (smart refactor)

## Purpose

Close CLASS_PORT NEW-driven sweep. Bitrix connectors -> BitrixCRMAdapter (implements CRMPort from SPEC #6 CONTRACT). banxe-webhook -> WebhookPort, a new port for inbound provider webhooks (partner status callbacks, KYC events) with signature verification + DLQ per ADR-034. Surfaces C21 (webhook ingestion).

## Legacy inventory + decision

- crypto-api/bitrix-support-connector + banxe-fiat-backend/bitrix -> BitrixCRMAdapter (CRMPort instance); dedupe 2 -> 1; mine Bitrix field mapping.
- banxe-fiat-backend/banxe-webhook -> WebhookPort (inbound webhook router; signature verify + DLQ + dedupe per ADR-034).

## WebhookPort contract (new, high-level)

register(provider, eventTypes, handler); verifyAndRoute(provider, payload, signature) -> {routed, deduped}; DLQ on handler failure; idempotent by provider event id (per ADR-034, same pattern as KYCProviderPort.handleWebhook).

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decision (this SPEC).
- Phase B-C (Terminal B): BitrixCRMAdapter on CRMPort; WebhookPort service with signature verify + DLQ.
- Phase D (Terminal B): conformance tests (CRMPort suite for Bitrix; webhook reliability suite reusing ADR-034 pattern).
- Phase E-F (Terminal B): cut over; ARCHIVE 3 legacy projects; IL record.

## Acceptance criteria

- BitrixCRMAdapter passes CRMPort conformance (SPEC #6 CONTRACT 7-test).
- WebhookPort: signature verify + DLQ + dedupe per ADR-034; verified.
- PRIORITY-MAP amended with C21 (webhook ingestion).
- 3 legacy projects ARCHIVE; CLASS_PORT fully closed.

## References

- SPEC #6 fiat-backend-utils + (CRMPort); ADR-034 webhook reliability; NEW-PROJECT-PRIORITY-MAP (C10; to amend C21)
- CLASS_PORT.tsv (3 rows: 2 Bitrix + 1 webhook)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF Bitrix CRM + WebhookPort SPEC #14 (CLASS_PORT closed; NEW-driven C10 + C21) ===
