# ADR-110: braslina Merchant-Onboarding Service — Placement & Registration

**Status:** PROPOSED
**Date:** 2026-06-19

## Context
CarmiBanxe/braslina v1.0.0 is a production-ready merchant-onboarding automation service (FastAPI/PostgreSQL/Redis/MinIO/n8n; 14 phases, CI 80% cov, gitleaks clean per ACCESS-AND-SECRETS IL-AccessPolicy-01). It is NOT registered in banxe-architecture SYSTEM-ARCHITECTURE. Functionally it is merchant KYB (relates to GAP-013) and feeds card-acquiring merchant intake.

## Decision
- braslina = STANDALONE service in the ecosystem (separate repo), registered in SYSTEM-ARCHITECTURE as merchant-onboarding component.
- Domain: merchant onboarding lifecycle (new->under_review->approved/rejected/suspended), checklist engine, website monitor (Playwright+pixelmatch), test-purchase log, CRM workflow.
- Ports: braslina-api :8000, PostgreSQL :5432, Redis :6379, MinIO :9002/:9003, n8n :5680.
- PORT NOTE: braslina n8n=:5680 vs main banxe n8n=:5678 — distinct instances; document to avoid collision if co-hosted.
- Relation: merchant KYB partially fulfils GAP-013 scope (business onboarding); Companies House API key (BT-005) still BLOCKED for full KYB UBO verification.
- HITL: merchant approve/reject = KYB decision -> MLRO/Compliance gate (no auto-approve of high-risk merchant).

## Compliance
- Merchant onboarding supports card-acquiring intake; KYB per MLR 2017. Audit trail in braslina + ClickHouse.
- Security: conforms to ACCESS-AND-SECRETS (I-SEC-01/04, gitleaks 0).

## Consequences
- Positive: production merchant-onboarding registered; partial GAP-013 progress; reusable for acquiring.
- Residual: Companies House key (BT-005) blocked; braslina passport + SYSTEM-ARCHITECTURE diagram update (SP-BR2/4).

## Related
- GAP-013 (KYB), GAP-066 (new, braslina registration), ACCESS-AND-SECRETS policy, Ballerine (KYC/KYB flow), customer_lifecycle_agent.
