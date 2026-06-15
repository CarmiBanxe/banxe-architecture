---
id: ADR-098
title: Sandbox session recorder & replay (SBOX-3) — observability over advisory seams
status: ACCEPTED
date: 2026-06-15
accepted: 2026-06-15
supersedes: []
related:
  - "ADR-096-unified-sandbox-mode-surface.md (the sandbox surface, SBOX-1)"
  - "ADR-097-sandbox-demo-scenarios.md (the demo journeys, SBOX-2)"
  - "ADR-095-g1-g4-go-live-decision-support.md (the go-live gates this sits below)"
il_anchor: IL-243
scope: BANXE-only
concept_only: false
---

# ADR-098: Sandbox session recorder & replay (SBOX-3)

**Status:** ACCEPTED — 2026-06-15
**IL:** IL-243 (Sprint SBOX-3 — sandbox session recorder & replay)
**Extends:** ADR-096 / ADR-097 (sandbox surface + demo scenarios) and the G1L
decision-lineage logger (IL-239). No live activation.

## Context

The advisory moat (S12–S16) and SBOX-1/SBOX-2 are on main, and G1L provides a
per-request decision-lineage event. What was missing is a **session** level: a way to
tie several demo-scenario steps into one run, store/read its summary, and link the
already-emitted lineage events — so an operator, partner-success, or compliance can
replay a demo run for training or audit. SBOX-3 adds that observability layer over
the existing seams, changing none of their behaviour.

## Decision

### D1 — Sandbox session model + in-memory store

Introduce `SandboxSessionSummary` (id, started/finished timestamps, scenario, title,
description, ordered `steps`, notes) and `SandboxSessionStepRef` (scenario/step ids,
`layer`, optional `lineageEventId`). Store them in a simple in-memory, mock-safe
store — no external service, no separate log, no persistence guarantee.

### D2 — Internal session API

`POST /api/v1/sandbox/sessions` (create), `.../{id}/steps` (append),
`.../{id}/finish` (set finishedAt + notes), `GET .../sessions` (list, limit/offset),
`GET .../sessions/{id}` (full). Internal terminal endpoints under `/api/v1/sandbox/*`.

### D3 — Opt-in G1L linkage; lineage unchanged

The G1L logger is **not changed in behaviour**: it gains a `record_event` that
returns the event so the endpoint helper can link it. When — and only when — a
request carries the `X-Banxe-Sandbox-Session-Id` header, the recorded lineage event
is appended to that open session (best-effort, fail-closed; an unknown session or a
missing header is a no-op, and a session is **never** auto-created). Sessions store
only data already in the advisory payloads / lineage events — no new PII.

### D4 — No live capability; internal only

Nothing here activates live trading, providers, billing, or KYB. The endpoints are
not on the external `/v1` facade (404 there) and change no existing contract.

## Consequences

- **Positive:** operator / partner-success / compliance can replay demo sessions for
  training and keep audit traces of a run — built entirely on existing seams.
- **Neutral:** an observability layer; the DSE / preview / mm / fees / quant /
  execution endpoints behave identically with or without a session.
- **No G1–G4 live logic is touched.**

## OPERATOR DECISION REQUIRED (unchanged)

Live go-live remains an ADR-095 ratification cell + a dedicated ACCEPTED ADR. Session
persistence / retention policy (beyond the in-memory store) is a future operator
decision, consistent with the ADR-095 lineage retention cell.

## References

- banxe-trading-backend: `services/sandbox_sessions.py`, `api/sandbox_sessions.py`,
  `services/decision_lineage.py` (the additive `record_event` hook)
- ADR-096 / ADR-097 (SBOX-1/2); IL-239 (G1L lineage); ADR-095 (G1–G4 gates)
- `docs/runbooks/g1-g4-mica-aml-runbook.md` (sandbox sessions for training + audit)
