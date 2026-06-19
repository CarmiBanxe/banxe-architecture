# ADR-112: Voice AI Support Channel (compliance-gated)

**Status:** PROPOSED
**Date:** 2026-06-19

## Context
Chat/text support exists (Chatwoot=4, GAP-039 ticketing IN PROGRESS). Voice/telephony AI channel ABSENT (LiveKit/Pipecat/Whisper/telephony minimal, audio-retention=0). Presidio (14 refs) already available for PII redaction -> reuse for transcripts.

## Decision
- Add voice AI support channel as EXTENSION on existing Chatwoot/ticketing (GAP-039), reuse Presidio for audio-PII.
- Infra: LiveKit/Pipecat realtime + SIP telephony gateway; ASR Faster-Whisper; TTS XTTS/Kokoro (self-hosted, data sovereignty).
- Integration: voice -> Chatwoot ticketing; transcript -> ClickHouse audit (append-only, TTL); complaint/DISP flow (GAP-038).

## Compliance (HEAVY — voice adds material burden vs text)
- Call recording + retention policy (FCA SYSC/DISP); consent-to-record at call start.
- Audio PII -> Presidio on transcripts (UK GDPR); no raw audio to 3rd-party.
- MLRO/Compliance HITL on flagged calls; Consumer Duty PS22/9 support-outcome monitoring.
- Voice agent advisory/support only; no autonomous financial execution via voice without HITL + biometric (per intent-first ADR-049 masks).

## Consequences
- Positive: voice channel parity with Revolut/bunq Finn; reuses Presidio + Chatwoot + ClickHouse.
- Negative/residual: recording/retention compliance overhead; ASR/TTS self-host ops; jurisdiction consent rules.

## Related
- GAP-038/039 (CRM/support), GAP-069 (new), ADR-049 (client-facing masks), Presidio (PII), Chatwoot. Intent-First ADR-045.
