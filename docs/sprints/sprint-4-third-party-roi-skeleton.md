# DORA Register-of-Information & Third-Party Skeleton — Sprint 4

Status: TEMPLATE / INTERNAL SKELETON / NOT FOR MERGE

## Purpose
Внутренний RoI-подобный срез ICT third-party зависимостей payments/merchant/savings-агентов и вебхуков. Официальная отчётность — по EBA/ESA-ресурсам [refs]; здесь только внутренний skeleton.

## Scope
- Provider inventory (Provider · Service · Contract scope · Locations · Criticality): Modulr [rails, ED-02] · ClearBank [rails fallback, ED-01] · SumSub [KYC, ED-03] · Paybis [crypto distribution, SRC-06/07/08] · cloud/messaging [___].
- Concentration/dependency notes: несколько critical-сервисов на одном провайдере; SPOF + митигации [placeholders].
- Service↔provider↔incident links: payments execution → Modulr/ClearBank → provider-API-down → payment_* events → DLQ path; KYC → SumSub/Ballerine → [___].

## Register linkage
- **Proposed #10 (Third-party/RoI)** — добавление = операторский акт; GREEN-условие: инвентарь полон, критичность классифицирована, концентрация описана, SLA-ссылки приложены.

## Room linkage
- governance docs (primary); cross-links из `bank-rooms/F4-devops-room/README.md` и `bank-rooms/F2-payments-room/README.md`.

## Open questions / counsel placeholders
- Формальные RoI-дедлайны и формат [Legal]; критичность-классификация по DORA-критериям.

## See also
- Sprint 4 набор: `sprint-4-dora-ict-risk-framework.md` · `sprint-4-webhook-event-lifecycle.md` · `sprint-4-third-party-roi-skeleton.md`
- Сводка/аудит: `sprint-1-4-status-summary.md` · `sprint-1-4-shell-audit.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`
