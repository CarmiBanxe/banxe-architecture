# BANXE Sandbox Portal (SBOX-6) — internal demo shell

> **INTERNAL / dev-sandbox only.** A read-only UX shell over the existing
> `/api/v1/sandbox/*` surfaces. It exposes **no** live action — no `/v1/orders*`, no
> keys, no billing, no KYB. Advisory / mock-only. Not a public rollout.

## What it is

One internal entry point for operators, partner-success, and compliance to
demonstrate the sandbox to an investor, partner, or regulator — without any live
risk. It composes the SBOX-1..5 surfaces and shows a persistent banner:

> **Sandbox / Advisory-only / No live execution, billing, KYB, or keys.**

Implemented in `banxe-trading-frontend` (`src/features/sandbox-portal`,
`src/pages/sandbox-portal`); it is opt-in (`VITE_SANDBOX_PORTAL=1` or a `?sandbox`
URL) and defaults to a deterministic mock client (no network in dev/CI).

## Sections and the endpoints they read

| Section | Reads | Sprint |
|---|---|---|
| Sandbox Overview | `GET /api/v1/sandbox/status` | SBOX-1 (ADR-096) |
| Demo Scenarios | `GET /api/v1/sandbox/scenarios` (+ `/{id}`) | SBOX-2 (ADR-097) |
| Sessions & Replay | `GET /api/v1/sandbox/sessions` (+ `/{id}`) | SBOX-3 (ADR-098) |
| Partner Sandbox | `GET /api/v1/sandbox/partners` (+ `/{id}/bundle`) | SBOX-4 (ADR-099) |
| Educational Gamification | `GET` under `/api/v1/sandbox/gamification` (the `/state` read; + an opt-in demo event) | SBOX-5 (ADR-100) |

All are **internal** endpoints under `/api/v1/sandbox/*`; none is on the external
`/v1` BaaS facade (they return 404 there).

## Demo run (partner / investor / regulator) — step by step

1. **Open** the portal (`?sandbox` or `VITE_SANDBOX_PORTAL=1`). The banner makes the
   "no live execution" posture explicit.
2. **Overview** — confirm `mode: sandbox-demo`, `executionMode:
   unsigned-preview-only`, and that live / billing / KYB are all `false`.
3. **Demo Scenarios** — pick a journey (spot-swap / perp-hedge / yield-rebalance) and
   walk its steps (DSE recommendation → previews → marketplace card).
4. **Sessions & Replay** — open a session (`POST /api/v1/sandbox/sessions`) and send
   `X-Banxe-Sandbox-Session-Id` on the advisory calls to capture a replayable trace.
5. **Partner Sandbox** — show a sample partner profile + its demo bundle.
6. **Educational Gamification** — show badges + the learning streak earned by
   completing the demo (no real money / tokens).

## Boundaries

- Read-only over the sandbox API; **no** live execution, signing, submission,
  billing, KYB, or keys. A public-facing or live portal is a separate ADR +
  G-ratification (see `docs/adr/ADR-095-g1-g4-go-live-decision-support.md`,
  `docs/runbooks/g1-g4-mica-aml-runbook.md`).

**Refs:** ADR-101 (this portal), ADR-096..100 (SBOX-1..5); IL-246.
