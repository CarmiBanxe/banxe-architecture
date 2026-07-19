# DORA-Style ICT Risk & Incident Framework — Sprint 4

Status: TEMPLATE / NOT FOR MERGE

## Purpose
Лёгкий ICT risk & incident framework в духе DORA (ICT-риск, инциденты, resilience; точные статьи — [Legal refs]); RACI и инцидент-пути для критичных сервисов. Соответствие DORA НЕ утверждается.

## Scope
- Critical services: payments execution (`PaymentRouterAgent`) · core ledger (`LedgerAgent`) · KYC/AML · safeguarding recon · webhook dispatch (`webhook_agent`) · [entity scope, proportionality — заполнить].
- Governance/RACI: Board (oversight) · CTO SMF26 (owner; Tier-2 → CEO по H-015 ≤2h) · CISO/Security lead · DevOps lead (H-013) · Product owners · Incident manager (`IncidentResponseAgent`+human). Утверждение RACI — через governance (ADR-кандидат).
- Controls library (taxonomy only): access (IAM/Keycloak) · change (H-013) · backup&recovery (ED-07) · monitoring (Prometheus/observability) — Objective/Owner/Frequency/KPI по каждому.
- Incident classification: payment outage · data breach (связь GAP-085/Art.33 72h) · webhook failure · ledger integrity — severity minor/major + notification targets/timelines [PLACEHOLDERS; регуляторные — counsel].
- Resilience testing: vulnerability assessments · scenario exercises · TLPT (применимость — counsel).

## Register linkage
- Area **#7 (webhook/DORA)** + **proposed #9 (ICT risk framework)** — добавление #9 = операторский акт; см. Proposed-секцию register'а.

## Room linkage
- `bank-rooms/F4-devops-room/README.md`, `bank-rooms/F4-security-room/README.md`, `bank-rooms/F2-payments-room/README.md`.

## Open questions / counsel placeholders
- Точные DORA-статьи/применимость и notification-timelines; TLPT-обязательность для нашего масштаба.

## See also
- Sprint 4 набор: `sprint-4-dora-ict-risk-framework.md` · `sprint-4-webhook-event-lifecycle.md` · `sprint-4-third-party-roi-skeleton.md`
- Сводка/аудит: `sprint-1-4-status-summary.md` · `sprint-1-4-shell-audit.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`
