# Webhook / Event Lifecycle Template — Sprint 4

Status: TEMPLATE / NOT FOR MERGE

## Purpose
Стандартный жизненный цикл платёжных/мерчант-событий: статусы, ошибки, bounded retry/backoff, наблюдаемость. Закрывает control-model требование register #7 («inherited-control assumptions must be explicit and auditable»).

## Scope
- Event model (Event · Payload min fields · Source · Consumers): payment_initiated/settled/failed/reversed (amount = DecimalStr, I-01) · merchant_settlement_* (dormant) · savings_event_* (dormant).
- Error/retry (Failure · Strategy · Escalation): network [bounded max N, backoff] · provider error · schema mismatch [no retry → DLQ]. **Bounded retry обязателен**; связка с инцидент-классификацией Framework.
- Observability: latency/error rate/drop rate/DLQ depth; retention [expert to validate]; append-only trail I-24.
- Customer-facing: маппинг статусов на UI/email/support; vulnerable customers при outage (связь с Evidence Pack §5).

## Register linkage
- Area **#7** — RED/AMBER-логика не меняется этим шаблоном; шаблон = evidence-кандидат.

## Room linkage
- `bank-rooms/F2-payments-room/README.md`, `bank-rooms/F4-devops-room/README.md`.

## Open questions / counsel placeholders
- Относятся ли конкретные webhook-исходы к «regulated execution»; минимальные retention/подпись требования.

## See also
- Sprint 4 набор: `sprint-4-dora-ict-risk-framework.md` · `sprint-4-webhook-event-lifecycle.md` · `sprint-4-third-party-roi-skeleton.md`
- Сводка/аудит: `sprint-1-4-status-summary.md` · `sprint-1-4-shell-audit.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`

## See also
- Control-model instance: `../governance/ict/webhook-agent-control-model.md` (фактические параметры по коду: 6 attempts, backoff 1s→2h, DLQ, HMAC-SHA256)
