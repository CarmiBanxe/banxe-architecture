# ADR-019: AI Guardian Agent — two-family architecture compliance enforcement

**Status:** ACCEPTED (canon, locked)
**Date:** 2026-05-03T19:08:02+02:00
**Author:** Moriel Carmi
**Supersedes:** none
**Related:** ADR-016 (AI plane PII/AML routing), ADR-018 (5-layer hybrid AI compute, expected to be created in Phase B), ADR-020 (Memory governance), HITL-MATRIX.yaml, PROMPT-CANON-PROJECT.md, factory-guard.yml.

## Context
У нас 5-layer hybrid AI compute (ADR-018, target). Любой AI агент (Claude Code, factory-guard CI, future agents) может случайно или системно нарушить:
- 43+ ADR (banxe-architecture/decisions + adrs + banxe-emi-stack/docs/adr).
- Constitution + amendments + canon правила.
- HITL-MATRIX (операции требующие человека-в-цикле).
- deny_paths из ADR-016 (PII/AML/secrets).
- sprint scope (out-of-scope изменения в роадмапе).
- merge marker leftovers, hardcoded secrets.
- "забывание" instruction'ов от operator (отсебятина).
- изменение ранее зафиксированных roadmap status'ов.

Текущая защита через factory-guard.yml + pre-commit (gitleaks/ruff) — это базовая механика; не закрывает architectural compliance целиком.

Operator (Mark) явно поручил: Guardian должен быть **двухсемейным** с активным использованием memory artefacts (MEMORY.md, INSTRUCTION-LEDGER.md, GAP-REGISTER.md, PROMPT-CANON-PROJECT.md, HITL-MATRIX.yaml, constitution/amendments/) — см. ADR-020.

## Decision
Ввести AI Guardian Agent как 6-й layer над 5-layer hybrid из ADR-018. Состоит из двух семейств процессов с общим core engine.

### 6.1 Семья 1 — Factory Guardian (контролирует, КАК строим)
- systemd unit: `banxe-guardian-factory.service` на evo1.
- Backbone model: qwen3.5:35b (Layer 2 LB, fallback на llama3.3:70b для critical reviews).
- Скоп: фабрика разработчика, любые AI агенты в любом репо CarmiBanxe.
- Audit log: ClickHouse table `guardian_audit_factory` (TTL 5y).

#### 8 правил Factory Guardian (ruleset v1.0)
1. Промт Claude Code соответствует канону из PROMPT-CANON-PROJECT.md.
2. Каждая инструкция от operator занесена в INSTRUCTION-LEDGER.md до выполнения; PR без ledger entry → BLOCK.
3. Изменения в роадмапе только append; rewrite/delete существующих секций требует ADR amendment + operator approval.
4. Никакой отсебятины: PR должен явно ссылаться на конкретную instruction в ledger по ID.
5. ADR изменения требуют ADR amendment в том же PR.
6. Status в роадмапе не может ухудшаться (DONE → OPEN, PASS → FAIL) без objection log в GAP-REGISTER.md.
7. Factory baseline (.claude/settings.json + canon + deny_paths) не может быть изменён без ADR.
8. Generated artefacts factory (template, workflows) — только через PR с branch prefix `factory/*`.

### 6.2 Семья 2 — Project Guardian (контролирует, ЧТО строим)
- systemd unit: `banxe-guardian-project.service` на evo1 (форк core engine с Project ruleset).
- Backbone model: llama3.3:70b (Layer 2 LB, для compliance‑критичных задач).
- Скоп: BANXE EMI (текущий проект); портативно для следующих проектов через rule swap.
- Audit log: ClickHouse table `guardian_audit_project` (TTL 5y).

#### 8 правил Project Guardian (ruleset v1.0 BANXE)
1. P0 priorities (FCA CASS 15: E-safeguard, J-engine) blocking — нельзя deprioritize без operator override.
2. Изменения в инвариантах I-XX требуют ADR amendment + HITL approval per HITL-MATRIX.yaml.
3. PII/AML deny_paths (ADR-016/021): проверка deny list на каждом diff.
4. Audit retention 5y: попытка сократить ClickHouse retention → BLOCK.
5. Money handling: запрет float, только Decimal (ADR-007).
6. Compliance hooks: AML/sanctions screening должен присутствовать в любом payment endpoint (ADR-PAY-01).
7. Sprint scope: PR должен соответствовать active sprint (banxe-cluster-v2.X-phaseN.md), либо явно помечен `cross-sprint` с reason.
8. Reverse compatibility: изменения API endpoints не могут ломать существующие contracts без ADR amendment.

### 6.3 Common core engine
- Code: Python/FastAPI service в ~/MetaClaw/guardian/.
- Inputs: GitHub webhooks (PR opened/synchronize/comment), Claude Code prompt logs (через MCP tool, опционально), operator commands.
- Memory pull (на каждый audit): см. ADR-020.
- Outputs:
  - GitHub status check `guardian/{factory|project}/<rule-id>` (PASS/FAIL).
  - PR comment с reasons + ссылками на ADR/правила/instruction ID.
  - Append-only row в ClickHouse table.
  - Auto-append в GAP-REGISTER при override.
  - Auto-append в INSTRUCTION-LEDGER если detected new instruction.

### 6.4 Override
BLOCK status снимается только operator approval через PR review с label `guardian-override-approved-{factory|project}`. Override автоматически логируется в GAP-REGISTER.md с reason field.

### 6.5 Self-monitoring
- Audit log immutable: ClickHouse append-only с TTL 5y (FCA CASS audit retention).
- Daily verify drill: cron каждые 24h проверяет Guardian heartbeat + audit log integrity.
- Backup: Guardian rule set + audit log в /mnt/d/backups/guardian/ ежедневно.

### 6.6 Reusability beyond BANXE
- Factory Guardian portable as-is — переходит в любой следующий проект.
- Project Guardian = форк с swap rule set под новый проект.

## Consequences
- + ~80% защиты от architectural drift autonomously.
- + Audit trail immutable (FCA-friendly).
- + Universal: переносится на любой next project.
- + Соответствует operator instruction "two-family Guardian".
- − Требуется sprint A.3 (impl), A.4 (systemd), A.5 (CI integration) — суммарно ~6-8 часов.
- − False positive risk: Guardian может блокировать legitimate PR, нужен tuning.

## Status
**LOCKED canonical control plane.** Все sprint planning после A.2 должен ссылаться на ADR-019. Layer 6 = двухсемейный Guardian.
