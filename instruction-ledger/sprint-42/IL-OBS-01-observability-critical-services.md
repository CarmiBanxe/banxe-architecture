# IL-OBS-01: Observability for Critical Services (complaints, fatca_crs, customer_lifecycle)

- Sprint: 42
- Status: PROPOSED
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#6
- Created: 2026-04-27

## Context
Three services delivered in Sprint 41 — `services/complaints/` (IL-FOS-01),
`services/fatca_crs/` (IL-HMR-01), `services/customer_lifecycle/` (IL-LCY-01) —
have no structured logging, metrics, or distributed tracing. Operational visibility
is zero for these paths. FCA Consumer Duty (PS22/9) requires evidenceable complaint
handling timelines. FATCA/CRS submissions must be auditable end-to-end.

## Goal
Add structured observability to the three Sprint 41 services using OpenTelemetry:
1. Structured logs (JSON, no PII, correlation_id on every line)
2. Prometheus metrics (request count, error rate, duration histograms)
3. OpenTelemetry traces (span per key operation, propagated via X-Request-ID)

## Scope
- `services/complaints/` — FOS escalation timeline, complaint state transitions
- `services/fatca_crs/` — FATCA/CRS report generation and submission events
- `services/customer_lifecycle/` — FSM state transitions with actor and timestamp
- `services/shared/telemetry.py` — shared OTel setup (if not exists)
- `tests/unit/test_observability.py` — assert log output contains required fields
- No changes to `.claude/*`, `CLAUDE.md`, `agents/*`

## Acceptance criteria
- [ ] Every service operation emits a structured log line with: `correlation_id`, `service`, `operation`, `status`, `duration_ms`
- [ ] No PII (name, IBAN, NI number, email) appears in any log line (I-24 adjacent)
- [ ] Prometheus endpoint `/metrics` exposes: `banxe_complaints_total`, `banxe_fatca_submissions_total`, `banxe_lifecycle_transitions_total`
- [ ] OTel traces include span for each FSM transition and each report submission
- [ ] `test_complaint_log_no_pii` — log output contains correlation_id, no raw customer data
- [ ] `test_fatca_submission_metric_increments` — counter increments on submission
- [ ] Ruff clean, mypy clean, no new Semgrep findings

## Implementation notes
- OTel SDK: `opentelemetry-sdk`, `opentelemetry-exporter-otlp-proto-grpc`
- Prometheus: `prometheus-client` (already in requirements if used elsewhere)
- Log format: `structlog` with JSON renderer; `masked_iban` helper for IBAN in debug logs
- Correlation ID: propagated from `X-Request-ID` header via FastAPI middleware
- Telemetry must not affect test performance: use `NoOpTracer` in unit tests

## Risks and mitigations
- Risk: OTel exporter config missing in dev → Mitigation: no-op exporter default, OTLP only when `OTEL_EXPORTER_OTLP_ENDPOINT` set
- Risk: structured logs break existing test assertions → Mitigation: update tests to use `structlog.testing.capture_logs()`
- Risk: metric cardinality explosion → Mitigation: use label-bounded label sets (state, service, outcome only)

## Related
- I-24 (audit trail, append-only)
- I-27 (HITL logging)
- IL-FOS-01, IL-HMR-01, IL-LCY-01 (Sprint 41 services)
- `services/complaints/`, `services/fatca_crs/`, `services/customer_lifecycle/`
- FCA PS22/9 (Consumer Duty — evidenceable complaint handling)
