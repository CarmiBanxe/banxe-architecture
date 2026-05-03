# ADR-022: Guardian bootstrap baseline exception (one-time amendment to ADR-019 §6.1 F7)

**Status:** ACCEPTED (one-time, scoped exception)
**Date:** 2026-05-03T23:59:49+02:00
**Author:** Moriel Carmi
**Amends:** ADR-019 §6.1 rule F7 (factory-baseline-locked).
**Related:** ADR-019 §6.4 (Override mechanism), INSTRUCTION-LEDGER entries INS-2026-05-03-A4-RUNTIME-UP and INS-2026-05-03-A5-CI-INTEGRATION.

## Context
ADR-019 §6.1 F7 говорит: "factory baseline (.claude/settings.json + factory-guard.yml) не может быть изменён без ADR reference." Это правильное правило для steady-state operation.

Однако, чтобы Guardian сам мог стать частью factory baseline, нужен initial bootstrap commit, который:
- добавляет .github/workflows/guardian.yml (новый workflow file).
- обновляет .claude/settings.json (если требуется).
- обновляет factory-guard.yml (если требуется).

Без явного исключения, Guardian заблокирует свой собственный bootstrap PR (что и произошло на CarmiBanxe/MetaClaw#2). Это кругоборот: Guardian не может deploy себя.

## Decision
**One-time exception**: PR, которые добавляют Guardian-related artefacts впервые в репо, освобождаются от F7 при следующих условиях:

1. PR содержит ADR-022 reference в title или body (например "Refs: ADR-022").
2. PR изменяет ТОЛЬКО Guardian-related artefacts: `.github/workflows/guardian.yml`, `.claude/settings.json` (canonical baseline), `.github/workflows/factory-guard.yml`. Никаких других файлов.
3. PR connected к Sprint Guardian-A.5 (CI integration) per INSTRUCTION-LEDGER.

После того как репо имеет Guardian, любые SUBSEQUENT изменения factory baseline всё равно требуют ADR reference per F7 (ADR-022 — одноразовый bootstrap, не permanent override).

## Scope (which PRs qualify)
PR на CarmiBanxe/MetaClaw factory/ai-onboarding (#2) — qualifies.
PR на 13 оставшихся репо CarmiBanxe (Phase 4 P4-Guardian-Rollout) — qualifies.
Любой другой PR — НЕ qualifies, F7 продолжает действовать.

## Implementation in Guardian rule engine
Будущий sprint (after Phase A close) обновит ~/MetaClaw/guardian/src/rules/factory_rules.py r7_factory_baseline_locked() — если в diff/PR body найдёт "Refs: ADR-022" + diff trogает ТОЛЬКО Guardian artefacts, return PASS вместо BLOCK. Пока этого update нет — operator override per ADR-019 §6.4 c label `guardian-override-approved-factory` достаточен для unblock pilot.

## Consequences
- + Guardian может быть deployed в любой репо без circular blocking.
- + Audit trail сохраняется: каждый bootstrap PR должен содержать ADR-022 ref.
- − One-time exception добавляет complexity в rule engine (когда мы implement бы proper exception logic).
- − Если operator забудет ADR-022 ref, override per ADR-019 §6.4 всё равно работает (label).

## Status
ACCEPTED. Этот amendment действует немедленно для текущего pilot rollout.
