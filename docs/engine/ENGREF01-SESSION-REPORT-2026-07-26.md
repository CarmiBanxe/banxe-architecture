# ⚠ SANDBOX / TRAINING — NOT FOR PRODUCTION
# ENGREF01 — Session Report (2026-07-26)  [BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false]

## Что сделано (STEP 1–6)
- STEP 1 Unfreeze emi-stack (scope=back-office; ADR-171 §Unfreeze)
- STEP 2 Engine-reference: 11 PROPOSED-артефактов + Fable5 verdicts + D1/D2 ратификация — PR #1134 [IL-1083]
- STEP 3 D2-кампания: дрейф bank-operating-model (c02f8d8, ~1013 файлов) разбит на 8 change-sets и влит сериализованно — PR #1135–#1142 [IL-1084…1091]
  · CS1 ledger-recon · CS2 safeguarding · CS3 payments+identity · CS4 floor-3(aml/regrep/finbi/treasury/risk) · CS5 floor-1(UI/customer) · CS6 engine(F0/F4/tools) · CS7 floor-4(devops/security/audit-cell) · CS8 docs+CLAUDE.md+governance
- STEP 4 Sandbox-активация: PROPOSED→ACTIVE(sandbox), W-05 sandbox-lift, PROD-CUTOVER contract — PR #1143 [IL-1092]
- STEP 5 Sandbox ClickHouse (docker, 127.0.0.1-only, свой том), схема hitl_decisions 14+8 колонок применена+верифицирована — PR #1144 [IL-1093]
- STEP 6 Фикс канонического CREATE-DDL под CH≥24.x (TTL toDateTime(ts)), OPEN POINT RESOLVED — PR #1145 [IL-1094]

## Итог
12 PR (#1134–#1145) · IL 1083–1094 непрерывно (evo1 allocator, 0 хардкодов) · 5/5 required PASS на каждом · pre-commit PASS.
Sandbox-контур операционен на TRAINING-данных: engine-reference ACTIVE(sandbox), 8 агентов, confidence-гейты, sandbox CI (sandbox/** ветки), мониторинг, TransferAgent/Rich Cards(W-05 sandbox-lift)/messenger test-bots/crypto testnet, decision-lineage в banxe_audit.hitl_decisions.

## Решения
- D1 = back-office-first (Fable5 conf 0.95): E0 Foundation → back-office(safeguarding/recon/BI) → E1 TransferAgent (blocked до зелёных ledger integrity + daily recon).
- D2 = form(b) change-set split (operator).
- Dedup: audit-схема = DELTA ALTER (не вторая таблица); единый Agent Registry; UI-канон merge; roadmap E0–E6 (не править roadmap-v3).

## Барьеры целы (вся линия)
LedgerPort-only (реальный ledger не тронут); runtime_gate §72; MEMORY.md; PR #1133; чужие stash/тома/контейнеры; live/prod ClickHouse — не тронуты.

## Осталось gated (стратегические)
PROD Promotion Gate; E1 TransferAgent в prod; W-05 в prod; real messenger/crypto (OP-J1/J3); AG2 license-verify (OP-N1); FATE/E5–E6.
