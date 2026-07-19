# Travel Rule Split Note (ADR-114) — Sprint 1

Status: DRAFT / INTERNAL ONLY / NOT FOR MERGE

## Purpose
Развести три смешиваемые вещи: правовой минимум Travel Rule (данные), внутренние policy-надстройки (одобрения) и открытые правовые вопросы. Привязка: ADR-114 (go-live gate).

## Scope
- Legal minimum (data level): «no data, no transfer», originator/beneficiary поля per transaction; пороги self-hosted wallets — [counsel refs].
- Internal control overlay: per-transfer human approval vs risk-based gating — НАШ выбор [INTERIM]; везде явно «what law requires» vs «what bank chooses to add» (voluntary stricter standard, ratchet-осознание).
- Architecture & logging: точки сбора/верификации/логирования данных; auditability (I-24 append-only, lineage, retention).

## Register linkage
- Area **#3** — RED (не меняется). Target for AMBER: split note completed + правовые вопросы отправлены.

## Room linkage
- `bank-rooms/F3-aml-room/README.md` (primary); `bank-rooms/F2-payments-room/README.md`.

## Open questions / counsel placeholders
- Когда (если вообще) human approval per transfer юридически обязателен (юрисдикционные случаи).
- Как Travel Rule взаимодействует с AI-based decision-making, если вообще.
