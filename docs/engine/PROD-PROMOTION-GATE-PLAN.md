# ⚠ PROD PROMOTION GATE — checklist (must ALL pass before BANXE_PROD_READY=true)
# Status: PROPOSED. Activation = separate operator authorization (NOT this pass).

## G0 — Data cutover (жёсткое условие)
- [ ] PURGE всех TRAINING-данных из всех sandbox-хранилищ (ClickHouse banxe_audit, Redis, любые mock-стораджи)
- [ ] Ни одной строки data_class='TRAINING' в prod-путях (enforced на write)
- [ ] Re-seed реальными данными под отдельным operator-gated change-set

## G1 — Infra prod
- [ ] Prod ClickHouse поднят (не sandbox docker); применить sql/create-banxe-audit-hitl-decisions-2026-05-12.sql (уже CH≥24.x-safe после STEP6) + alter-...engine-ref
- [ ] DESCRIBE: 14+8 колонок; ENGINE ReplacingMergeTree(ts)/PARTITION toYYYYMM/ORDER BY(decision_id,ts)/TTL 7Y
- [ ] Backup/DR по ADR-027 (5Y TTL), restore-drill пройден

## G2 — Ledger integrity + recon (разблокирует TransferAgent, D1)
- [ ] Ledger integrity зелёный (LedgerPort, реальный леджер)
- [ ] Daily reconciliation зелёный; CASS 7.15 доказуемо (закрыть D-RECON gap, D-gl≈5%)
- [ ] S-PROD-1 Safeguarding (P0) — не OVERDUE

## G3 — Agent/gates activation (prod)
- [ ] confidence-thresholds: active_environment=production (staging 0.75 / prod 0.90 + HITL)
- [ ] CI-workflow активен для prod-веток (не только sandbox/**)
- [ ] W-05 prod-политика ратифицирована (AI cannot initiate payments — снять только после явного решения)
- [ ] Excessive-Agency gate 0.90 в prod

## G4 — Compliance/security
- [ ] EU AI Act audit-lineage пишется в prod hitl_decisions
- [ ] OWASP LLM Top-10 митигации активны (NeMo Guardrails, VaultGemma DP, MCP sandbox, self-host LLM)
- [ ] AG2 license-verify (OP-N1): microsoft/autogen excluded, AG2 отдельно; AutoGen из prod исключён
- [ ] SBOM + Dependabot зелёные

## G5 — Channels (own perimeters)
- [ ] messenger channels (OP-J1): data-residency/identity gate пройден → real endpoints
- [ ] crypto channel (OP-J3): отдельный FCA-периметр → real (не testnet)

## G6 — Sign-off
- [ ] Operator PROD authorization (письменно)
- [ ] BANXE_PROD_READY=true flip (единственная точка включения)
