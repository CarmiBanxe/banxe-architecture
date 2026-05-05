# ADR-033 — Alert Routing Strategy (Keycloak Auth Events)

**Status:** Proposed (2026-05-06)
**Author:** Architecture WG / Observability lead
**Closes:** G-OBS-01 (canonical), G-OBS-02 (canonical), V-10 (HANDOFF-2026-05-04)
**Linked:** ADR-024 (Guardian), ADR-027 (audit-trail buffer), ADR-032 (secret rotation, n8n pattern),
IL-CANON-04 (best-decision), MASTER-PLAN Track A7, FCA SYSC 15A operational resilience,
KPMG AIGF observability pillar

---

## Context

Keycloak (`banxe-emi` realm, evo1 :8180) generates 18 user event types and admin event types
covering every authentication lifecycle moment: `LOGIN`, `LOGIN_ERROR`, `LOGOUT`,
`CLIENT_LOGIN_ERROR`, `TOKEN_EXCHANGE_ERROR`, `REGISTER`, `UPDATE_PASSWORD`, `DELETE_ACCOUNT`,
and the corresponding admin events (`DELETE_USER`, `UPDATE_CLIENT`, etc.). The realm export
(`infra/keycloak-banxe-emi/realms/banxe-emi-realm.json`) shows `eventsEnabled=true` and
`adminEventsEnabled=true`, but `eventsListeners` is absent from the export — the default
`jboss-logging` listener is the only active sink. Events are written to the KC internal DB
with default 0-day expiry and reach no external system.

V-10 from HANDOFF-2026-05-04 described this as "Keycloak realm alerts not wired to PagerDuty".
PagerDuty is not deployed on evo1 or evo2. The gap is reframed (GAP-REGISTER G-OBS-01) as:
Keycloak auth events exist but are routed to no alert channel. The operational consequence is
that `LOGIN_ERROR` bursts (brute-force), `CLIENT_LOGIN_ERROR` (client_secret exposure), and
`TOKEN_EXCHANGE_ERROR` spikes are silently discarded — FCA SYSC 15A requires an operational
resilience programme that detects and responds to auth-plane incidents within defined SLAs.

n8n is live on evo1 (:5678) with a working Telegram alert pattern (`safeguarding-shortfall-alert`,
`complaint-sla-monitor`). This pattern — n8n webhook receiver → conditional routing → Telegram
`sendMessage` — is the lowest-friction extension point for KC event delivery.

---

## Decision Drivers

1. **Auth-incident coverage** — `LOGIN_ERROR` rate > threshold = brute-force in progress;
   `CLIENT_LOGIN_ERROR` = client_secret compromise; `TOKEN_EXCHANGE_ERROR` = possible token
   replay. Each warrants operator notification within 60 seconds.
2. **Ownership clarity** — CTIO is the primary on-call for auth security events; CEO and MLRO
   must be notified for admin events (user deletion, password reset by admin). Routing must
   encode these ownership rules.
3. **Audit trail completeness (I-24 + ADR-027)** — alert delivery is an operational action;
   each delivered alert must produce an append-only ClickHouse record via ADR-027 `BufferedAuditPort`.
4. **Operability constraint** — single-engineer team; new services must not add significant
   operational surface. Reuse n8n + Telegram where possible.
5. **Alert latency target** — G-OBS-02 CI smoke requires delivery within 60 seconds of event.
   This constrains options that rely on polling or batch ingestion.

---

## Considered Options

### Option (a) — n8n webhook receiver + Telegram routing (RECOMMENDED)

KC realm `eventsListeners` is set to include an HTTP webhook (KC built-in
`org.keycloak.events.EventListenerProvider` with a custom HTTP dispatcher JAR, or via KC's
`http-event-listener` extension). The webhook POSTs each event to
`http://evo1:5678/webhook/kc-events`. An n8n workflow (`kc-event-router`) inspects the
`type` field, applies severity thresholds, and sends Telegram messages to the appropriate
`chat_id`. The existing n8n Telegram pattern from `safeguarding-shortfall-alert.json` is
reused verbatim.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | Full — every KC event type routable |
| Latency | < 5s end-to-end (webhook is synchronous from KC perspective) |
| New infra | Minimal — one n8n workflow; optional lightweight KC HTTP webhook jar |
| Operability | High — n8n UI for routing logic; no new services |
| Audit trail | Via ADR-027 buffer from n8n HTTP action node |

**Risk:** n8n downtime = alert delivery gap. Mitigated by `restart: unless-stopped` policy.
KC `httpEventListener` jar availability must be confirmed for the installed KC version.

---

### Option (b) — KC SPI custom Java Event Listener → Slack webhook

Write a KC SPI `EventListenerProvider` Java class that fires a Slack webhook directly. Deploy
as a JAR into KC `providers/` directory and register in `standalone.xml` / realm export.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | Full |
| Latency | < 2s (in-process, synchronous) |
| New infra | New Java artifact; Slack workspace required (not in stack) |
| Operability | Low — Java build pipeline, JAR deployment, Slack org dependency |
| Audit trail | None (Slack is ephemeral) unless secondary logging added |

**Risk:** Slack is not in the current stack; adds an external SaaS dependency. Custom JAR
requires rebuild on KC version upgrades. No Telegram coverage for on-call who uses Telegram.

---

### Option (c) — Prometheus Keycloak Exporter + Alertmanager + PagerDuty

Deploy `prometheus-keycloak-exporter` to scrape KC metrics, Alertmanager to define threshold
rules, and PagerDuty for escalation. PagerDuty integration deferred from V-10.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | Metric-based (rates/counts, not individual events) |
| Latency | Scrape interval typically 15-30s; alert eval adds 15-60s; total > 60s target |
| New infra | Three new services: exporter + Alertmanager + PagerDuty account |
| Operability | Low — complex rule config; PagerDuty account/billing required |
| Audit trail | Via Alertmanager receiver, not per-event |

**Risk:** Exceeds operability constraint (single-engineer team). Latency > G-OBS-02 target of
60s under typical scrape + alert eval cycle. Deferred to P1 when 24/7 escalation is required.

---

### Option (d) — ClickHouse-side polling on audit trail

A cron or FastAPI background task polls `safeguarding_audit` ClickHouse table for
`LOGIN_ERROR` rate > threshold in a 1-minute window, then fires a Telegram alert.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | Partial — only events already in ClickHouse (requires ADR-027 buffer live) |
| Latency | 60-120s polling interval; misses sub-minute bursts |
| New infra | None — reuses existing stack |
| Operability | Medium — polling logic in FastAPI lifespan or cron |
| Audit trail | N/A (reads audit trail, does not write to it separately) |

**Risk:** Depends on ADR-027 being implemented first. Does not provide real-time event
routing for individual events (only rate-based aggregates). LOGIN_ERROR storm in < 60s
window is invisible.

---

## Trade-off Summary

| Option | Coverage | Latency | New infra | Operability |
|--------|----------|---------|-----------|-------------|
| (a) n8n + Telegram | Full | < 5s | Minimal | High |
| (b) KC SPI + Slack | Full | < 2s | New Java + Slack | Low |
| (c) Prometheus + PagerDuty | Metric-level | > 60s | 3 new services | Low |
| (d) ClickHouse polling | Rate-based only | 60-120s | None | Medium |

---

## Recommendation

**Option (a) — n8n webhook receiver + Telegram routing**, formalised as the interim
production standard. PagerDuty integration (option c) explicitly deferred to P1 when
24/7 escalation and dedicated on-call rotation are required.

Rationale:
- n8n + Telegram is the established pattern in the stack (safeguarding, complaint-SLA).
- Option (b) adds a Java SaaS dependency not present in the stack; Slack is not the
  operator's current on-call channel.
- Option (c) exceeds the G-OBS-02 latency target (60s) and operability constraint.
- Option (d) is dependent on ADR-027 implementation and provides only rate-based coverage.

**KC event → routing matrix:**

| Event type | Severity | Telegram chat | On-call owner | Additional action |
|-----------|---------|--------------|--------------|-----------------|
| `LOGIN_ERROR` rate > 10/min | HIGH | CTIO chat | CTIO | ADR-027 audit event |
| `LOGIN_ERROR` rate > 50/min | CRITICAL | CTIO + CEO | CTIO + CEO | ADR-027 + account freeze proposal |
| `CLIENT_LOGIN_ERROR` (any) | CRITICAL | CTIO + CEO | CTIO/CEO | ADR-027 + secret rotation trigger |
| `TOKEN_EXCHANGE_ERROR` (any) | HIGH | CTIO | CTIO | ADR-027 audit event |
| `UPDATE_PASSWORD` (admin) | MEDIUM | CEO | CEO | ADR-027 audit event |
| `DELETE_USER` (admin) | CRITICAL | CEO + MLRO | CEO + MLRO | ADR-027 + I-27 HITL freeze |
| `REGISTER_ERROR` rate > 20/min | HIGH | CTIO | CTIO | ADR-027 audit event |
| `LOGOUT` bulk (> 100/min) | MEDIUM | CTIO | CTIO | Rate monitoring |

**n8n workflow structure (`kc-event-router`):**
```
Webhook trigger (POST /webhook/kc-events)
  → Switch node on event.type
      → Rate-threshold node (for ERROR types)
          → HTTP POST to BufferedAuditPort /audit (ALERT_DELIVERED)
          → Telegram sendMessage (CTIO chat_id / CEO chat_id)
```

**KC realm configuration change required:**
- Set `eventsListeners: ["jboss-logging", "http-event"]` in realm export
- Set `eventsExpiration: 7776000` (90 days in seconds) — minimum per FCA SYSC 15A
- Enable `eventsEnabled: true` and `adminEventsEnabled: true` (already true per audit)

---

## Consequences

### Positive

- `LOGIN_ERROR` bursts and `CLIENT_LOGIN_ERROR` events reach CTIO/CEO within < 5 seconds.
- Each alert delivery produces an `ALERT_DELIVERED` record in ClickHouse via ADR-027 buffer.
- KC event retention increased from 0 days to 90 days — FCA SYSC 15A audit evidence.
- Existing n8n Telegram pattern is reused; no new services deployed.

### Negative / Risks

- n8n is a SPOF for alert delivery; n8n OOM during a brute-force attack = alerts lost.
  Mitigated by `restart: unless-stopped` and manual KC log monitoring as fallback.
- KC `httpEventListener` availability must be verified for the installed KC version.
  If not native, a minimal HTTP dispatcher JAR must be compiled and deployed.
- PagerDuty / phone-call escalation is not provided in this option; deferred to P1.
- Rate-threshold logic in n8n (Switch + counter nodes) is stateless across n8n restarts.
  Consider Redis counter if precision is required.

---

## Implementation Plan

1. **KC realm update** — set `eventsListeners: ["jboss-logging", "http-event"]` and
   `eventsExpiration: 7776000` in `infra/keycloak-banxe-emi/realms/banxe-emi-realm.json`.
   Verify `http-event` listener JAR is available in the KC container image; document version.

2. **n8n workflow** — create `n8n/workflows/kc-event-router.json`: webhook trigger at
   `/webhook/kc-events`, Switch node on `type`, rate-threshold via Counter node (Redis-backed),
   HTTP POST to `http://localhost:8093/audit` (`ALERT_DELIVERED` event), Telegram sendMessage
   to appropriate chat_id from environment variables.

3. **ADR-027 BufferedAuditPort** — add event type `ALERT_DELIVERED` with fields `alert_type`,
   `event_source`, `delivered_to`, `delivery_latency_ms`.

4. **CI smoke test (G-OBS-02)** — `tests/test_smoke/test_kc_alert_smoke.py`:
   POST synthetic `LOGIN_ERROR` event via KC Admin API
   (`POST /admin/realms/banxe-emi/events`), poll n8n execution log via n8n API for
   completed execution, assert completion within 60 seconds. Mark `@pytest.mark.smoke`.

5. **PagerDuty stub** — open `decisions/ADR-034-pagerduty-escalation.md` as Status: Deferred
   with trigger: "activate when on-call rota requires 24/7 phone escalation (P1 scope)".

---

## Decision

**Pending** — operator acceptance required.
Implementation begins only after operator confirms Option (a) and realm configuration change.
