# ADR-038 — Vault / Infisical Adoption (Placeholder)

**Status:** Placeholder (2026-05-06)
**Author:** Architecture WG
**Closes:** G-SEC-02 (canonical) — long-term replacement for ADR-032 interim rotation policy
**Linked:** ADR-032 (interim secret rotation — n8n + manual runbook), MASTER-PLAN Track F

---

## Purpose

This ADR is intentionally minimal. Full HashiCorp Vault or Infisical adoption is a separate
roadmap track to be planned when the following triggers are met:

1. **Operator team grows beyond single-engineer** — current operability constraint
   (ADR-032 §Decision Drivers #4) that favours n8n over Vault sidecar complexity no longer applies.
2. **Secret count exceeds ~15 distinct credentials** — current inventory per G-SEC-01 audit
   is 16 secrets; Vault's overhead becomes justified above ~25-30 secrets with rotation.
3. **Dynamic secrets required** — PostgreSQL/ClickHouse short-lived credentials are mandated
   by a regulatory escalation of FCA SYSC 15A beyond current requirements.

Until all three triggers are met, ADR-032 (n8n workflows + IL-SEC-01 runbook) is the
production-canon rotation policy.

---

## Number allocation note

ADR-033 is reserved for Alert Routing Strategy (Keycloak events, MASTER-PLAN Track A7).
This Vault placeholder is assigned ADR-038 to avoid collision. ADR-032 §Implementation Plan
step 5 originally referenced "ADR-033 Vault stub"; that reference should be read as ADR-038.

---

## Deferred decisions

- Vault vs Infisical selection (HA topology, MongoDB coupling, licence)
- Dynamic secrets strategy for PostgreSQL / ClickHouse
- Agent sidecar pattern for secrets injection into container workloads
- Migration plan from current operator-supplied `.env` / systemd EnvironmentFile

---

## Decision

**Deferred** — re-evaluate at end of Phase 5 or when a trigger above is met.
Owner: Architecture WG. Review checkpoint: Q4 2026.
