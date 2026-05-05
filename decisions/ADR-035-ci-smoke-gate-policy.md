# ADR-035 — CI Smoke-Gate Policy

**Status:** Proposed (2026-05-05)
**Author:** Architecture WG / DevOps Lead
**Closes:** G-CI-01 (no end-to-end smoke gate before merge), G-CI-02 (required-check enforcement absent), V-08 (HANDOFF-2026-05-04)
**Linked:** ADR-024 (Guardian shim — current sole required check), ADR-027 (audit-trail durability — smoke-gate failure events buffered via BufferedAuditPort), ADR-029 (PostgreSQL backup — G-OPS-02 backup-restore smoke subsumed here), ADR-LCY-01 (Customer lifecycle FSM — smoke surface), IL-CANON-04 (best-decision principle — smoke evidence prerequisite), MASTER-PLAN Track A5

---

## Context

A read-only audit of `banxe-emi-stack/.github/workflows/` conducted 2026-05-05
found seven workflow files, **all operating at unit/lint level**: `quality-gate.yml`
(Ruff + pytest + Semgrep + Biome + Vitest), `lint-python.yml`, `lint-frontend.yml`,
`alembic-check.yml`, and three Claude-automation workflows. None start any service
container; all tests run against InMemory stubs, `fakeredis`, and SQLite — no real
ClickHouse, no real Keycloak, no real reconciliation path.

The GitHub branch-protection `required_status_checks` on `main` contains only
`guardian-factory` and `guardian-project` (the Guardian shim, app_id 15368). The
`quality-gate` workflow and pytest suite are **not** required checks; a PR can merge
into `main` with failing tests if the Guardian check passes. This means regressions
in the compliance engine, reconciliation, or safeguarding paths are detected only
post-merge, at which point the production state has already changed.

No `@pytest.mark.smoke` markers exist; no smoke test module exists at
`tests/test_smoke/`. Several docker-compose files exist under `docker/` (master,
recon, psd2, pgaudit, transaction-monitor) but none are referenced in any GitHub
Actions workflow — they are local-only operational tools.

IL-CANON-04 §best-decision mandates that a production-state change requires a
"smoke signal" confirming the system boots and answers correctly after the change.
Under the current CI configuration, this evidence is structurally absent.

**V-08 (HANDOFF-2026-05-04):** Classified MEDIUM. Remediation path specifies a
smoke job covering KC token grant, ClickHouse audit append, reconciler tick,
safeguarding endpoint health, and Guardian /audit POST before `main` accepts a merge.

---

## Decision Drivers

1. **Regression detection gap** — regressions in compliance-critical paths (CASS 15
   reconciliation, AML audit trail, KYC workflow) are currently detectable only
   post-merge via manual testing or production incidents. A smoke gate moves detection
   to pre-merge.

2. **Time budget** — a smoke gate must complete within ≤7 minutes total (PR author
   wait tolerance). Bringing up the full evo1 stack (Keycloak, ClickHouse, Postgres,
   Redis, Guardian, Ballerine) takes >5 minutes on a cold runner; only mock-backed
   or TestClient-backed smoke can meet this budget as a PR required check.

3. **Ephemeral env fidelity** — mock-stack smoke (fast) vs. real-stack smoke (slow
   but high-fidelity). The two needs are distinct: PR gate needs speed; nightly
   integration needs fidelity. A hybrid strategy serves both without compromising either.

4. **Smoke surface definition** — 6 components must be exercised to satisfy IL-CANON-04
   §best-decision: auth token issuance, audit trail append, recon tick, safeguarding
   health, Guardian /audit, and KYC workflow stub. These are the compliance-critical
   paths whose regression carries regulatory risk.

5. **Required-check enforcement (G-CI-02)** — branch protection must be updated to
   add `smoke-gate-mock` as a required status check, at minimum alongside the existing
   `guardian-factory`/`guardian-project` checks. Without enforcement, smoke gate is
   advisory only and can be bypassed by admin merge.

---

## Considered Options

### Option (a) — Single monolithic GH Actions job (real stack)

One `smoke-gate.yml` job brings up the full stack via `docker compose -f docker/docker-compose.master.yml up -d`, waits for health checks, runs a `pytest tests/test_smoke/` suite against real containers, tears down.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | Maximum — real Keycloak, ClickHouse, Postgres, Redis |
| Complexity | High — multi-container health-check logic, startup sequencing |
| Time | 8–15 min (container pull + init) — exceeds 7 min PR budget |
| Dependency | All containers must be available on GH Actions runner |
| Required-check viability | Poor — too slow for PR gate; misses budget by 1–2× |
| GH Actions cost | High — long-running ubuntu-latest job per PR |

**Risk:** Cold pull of KC + CH + Postgres images alone takes 3–5 min on GH Actions
runners. Any container startup failure blocks all PRs. Startup flakiness rate for
multi-container stacks on shared runners is non-trivial.

---

### Option (b) — Service-isolated smoke (all mocks)

Smoke tests run entirely with InMemory stubs, `fakeredis`, and `httpx.MockTransport`.
Fast (≤2 min), deterministic, no containers. Each "smoke" step calls a service
function directly via TestClient or service constructor.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | Low — only tests mock wiring, not real boot path |
| Complexity | Minimal — same pattern as existing unit tests |
| Time | ≤2 min — well within budget |
| Dependency | None |
| Required-check viability | Good — fast, reliable |
| GH Actions cost | Low |

**Risk:** Mock-only smoke does not detect boot-path regressions (import errors, lifespan
failures, middleware ordering issues, dependency injection failures at startup). A
regression in `api/main.py` lifespan or `api/deps.py` DI graph would pass this gate.
Option (b) alone does not satisfy IL-CANON-04 §best-decision for production-state changes.

---

### Option (c) — Hybrid: smoke-mock (PR gate) + smoke-full (nightly)

Two workflow files:
- `smoke-gate-mock.yml` — PR required check: TestClient + InMemory stubs + `fakeredis`;
  exercises all 6 smoke-surface components via `FastAPI.TestClient` with real app
  lifespan (catches DI/middleware regressions); target ≤3 min.
- `smoke-gate-full.yml` — nightly (`schedule: cron`) + `workflow_dispatch`: real
  Keycloak + real Postgres (SQLite substitute for ClickHouse on runner) + real Guardian;
  target ≤12 min; failure alerts via audit trail.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | High — mock gate catches DI/lifespan regressions; nightly catches real-stack regressions |
| Complexity | Moderate — two workflow files; `tests/test_smoke/` module (new) |
| Time | PR gate ≤3 min; nightly ≤12 min |
| Dependency | PR gate: none; nightly: Docker on GH Actions |
| Required-check viability | Excellent — mock gate meets budget; nightly separate |
| GH Actions cost | Moderate — nightly is infrequent |

**Risk:** Nightly smoke failure may go unnoticed without alert routing. Mitigation:
emit audit trail event on nightly smoke failure (ADR-027 buffer) + GitHub notification.

---

### Option (d) — External smoke runner on evo1/evo2

GH Actions workflow triggers a smoke run on evo1 (via `curl` or self-hosted runner)
against the real running stack. Results returned to GH Actions as check status.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | Maximum — real production-equivalent stack |
| Complexity | Very high — self-hosted runner registration, network egress, evo1 availability coupling |
| Time | Variable — depends on evo1 load; may exceed 7 min |
| Dependency | evo1 availability; GH Actions ↔ evo1 connectivity; self-hosted runner config |
| Required-check viability | Poor — evo1 downtime blocks all PR merges |
| GH Actions cost | Low (local runner) |

**Risk:** Coupling PR merge to evo1 availability means evo1 maintenance windows block
all development. Given Keycloak OOM kills already observed (ADR-029 Finding 2), this
coupling is unacceptable for a required-check gate.

---

## Trade-off Summary

| Option | Coverage | Time (PR gate) | New dependency | Required-check viability | GH Actions cost |
|--------|---------|----------------|---------------|--------------------------|----------------|
| (a) monolithic real stack | Max | 8–15 min ❌ | Docker on runner | Poor | High |
| (b) all mocks | Low | ≤2 min ✅ | None | Good | Low |
| (c) hybrid mock+nightly | High | ≤3 min ✅ | Docker on runner (nightly only) | Excellent | Moderate |
| (d) evo1 external runner | Max | Variable ❌ | Self-hosted runner + evo1 | Poor | Low |

---

## Recommendation

**Option (c) — hybrid: `smoke-gate-mock.yml` as PR required check + `smoke-gate-full.yml` nightly.**

Rationale:
- Option (a) misses the 7 min budget by 1–2×; startup flakiness on shared GH runners
  makes it unreliable as a required check.
- Option (b) alone does not satisfy IL-CANON-04 §best-decision: mock smoke does not
  detect boot-path regressions that occur in the real FastAPI lifespan and DI graph.
- Option (c) uses `FastAPI.TestClient` with the **real** app lifespan in `smoke-gate-mock.yml`
  — this catches `api/main.py` lifespan errors, `api/deps.py` DI graph failures, and
  middleware registration issues, while substituting only external services (KC, CH,
  Postgres) with stubs. The nightly full-stack run catches real-stack regressions.
- Option (d) couples PR merges to evo1 uptime — unacceptable given observed OOM kills.

---

## Smoke Surface Matrix (Required-Check Level)

| # | Smoke step | Component | Mock / real in PR gate | Regulatory link |
|---|-----------|-----------|------------------------|----------------|
| 1 | `POST /auth/login` → 200 + JWT | Auth (app lifespan + DI) | `httpx.MockTransport` for KC token exchange | OWASP ASVS 2.1 |
| 2 | Audit `AuditTrail.log()` → `True` | Audit trail (I-24) | `InMemoryAuditPort` | FCA CASS 15 §15.10 |
| 3 | `ReconciliationEngine.run_tick()` → zero discrepancy | Recon engine | `InMemoryReconAuditPort` + `InMemoryLedgerPort` | FCA CASS 7.15 |
| 4 | `GET /safeguarding/healthz` → 200 | Safeguarding API | `FastAPI.TestClient` (real handler) | FCA CASS 15 |
| 5 | `POST /audit` with Guardian-mock rules | Guardian shim | `MockGuardianFactory` (factory=open rules) | ADR-024 |
| 6 | `KYCWorkflowPort.create_workflow()` → `PENDING` | KYC port | `MockKYCWorkflowPort` | FCA MLR 2017 Reg.27 |

---

## Branch Protection Update (G-CI-02)

Current required checks on `main`:
```json
{"checks": [{"context": "guardian-factory"}, {"context": "guardian-project"}]}
```

Required state after ADR-035 implementation:
```json
{"checks": [
  {"context": "guardian-factory"},
  {"context": "guardian-project"},
  {"context": "smoke-gate-mock / Smoke gate (mock stack)"}
]}
```

`quality-gate / Pytest (coverage >= 80%)` should also be added as a required check
(currently advisory only) — tracked as G-CI-02 phase 2.

---

## Consequences

### Positive

- G-CI-01 closed: every PR against `main` must pass a smoke gate before merge;
  DI/lifespan regressions in compliance-critical paths are caught pre-merge.
- G-CI-02 closed: branch protection updated to enforce `smoke-gate-mock` as required
  status check alongside Guardian shim checks.
- IL-CANON-04 §best-decision satisfied: smoke evidence (TestClient pass) accompanies
  every production-state change.
- Nightly full smoke (G-OPS-02 backup-restore drill can be added as a step) provides
  real-stack regression detection without blocking PR velocity.
- Smoke failures emit audit trail events (ADR-027 buffer) — forensic evidence of CI
  infrastructure incidents for DORA Art.14(2) ICT continuity records.

### Negative / Risks

- `FastAPI.TestClient` with real lifespan requires all DI dependencies to resolve;
  any new mandatory external dependency (e.g., Redis in ADR-030 `FastAPILimiter.init`)
  must provide a stub/override for the smoke environment, or the gate will fail on
  unrelated infra changes.
- Nightly smoke failure alerting requires an alert channel (Slack or email); if not
  configured, failures accumulate silently. Tracked in G-OBS-01.
- Two workflow files to maintain; divergence between `smoke-gate-mock.yml` and
  `smoke-gate-full.yml` requires discipline to keep the smoke surface definitions
  in sync.

---

## Implementation Plan

1. **New test module** — `tests/test_smoke/test_smoke_mock.py`: 6 smoke steps (one
   per row in Smoke Surface Matrix), using `FastAPI.TestClient` with the real app
   lifespan, InMemory stubs for external ports, `fakeredis` for Redis, `httpx.MockTransport`
   for KC. Marked `@pytest.mark.smoke`. Target: ≤2 min runtime on GH Actions.

2. **`smoke-gate-mock.yml`** — new workflow file: triggers on `pull_request` (branches:
   [main]) and `push` (branches: [main]); single `smoke-gate-mock` job; installs
   `requirements.txt`; runs `pytest tests/test_smoke/ -m smoke -v --timeout=120`;
   no Docker needed. Job name: `smoke-gate-mock / Smoke gate (mock stack)`.

3. **Branch-protection update** — `gh api` PATCH to add `smoke-gate-mock / Smoke gate (mock stack)`
   to `required_status_checks.checks` on `main`. Operator executes via:
   ```bash
   gh api repos/CarmiBanxe/banxe-emi-stack/branches/main/protection \
     --method PUT --input protection-update.json
   ```

4. **`smoke-gate-full.yml`** — nightly workflow: `schedule: cron: '0 3 * * *'` +
   `workflow_dispatch`; brings up `docker/docker-compose.master.yml` (postgres + redis +
   clickhouse-mock); runs full smoke suite + backup-restore drill (G-OPS-02 step);
   emits audit trail event on failure (ADR-027 buffer). Job name: `smoke-gate-full /
   Smoke gate (real stack)`.

5. **Metrics + alerting** — on `smoke-gate-full` failure: emit `AuditEvent` of type
   `CI_SMOKE_FAILURE` via ADR-027 `BufferedAuditPort`; GitHub workflow failure
   notification via existing GitHub notification settings. Tracked in G-OBS-01.

---

## Decision

**Pending** — operator acceptance required after review of the Recommendation.
Implementation begins only after operator confirms chosen option and phasing.
