# ADR-020: Memory governance — 100% utilization of MEMORY/LEDGER/GAP/CANON/HITL

**Status:** ACCEPTED (canon, locked)
**Date:** 2026-05-03T19:08:02+02:00
**Author:** Moriel Carmi
**Related:** ADR-019 (Guardian two-family), constitution/amendments/, HITL-MATRIX.yaml, PROMPT-CANON-PROJECT.md.

## Context
Operator выявил что MEMORY.md, INSTRUCTION-LEDGER.md, GAP-REGISTER.md, PROMPT-CANON-PROJECT.md, HITL-MATRIX.yaml, constitution/amendments/ используются пассивно (можно прочесть, можно не прочесть). Это позволяет AI агентам "забывать" instruction'ы и делать отсебятину.

## Decision
Превратить memory artefacts в **активные обязательства** через Guardian (ADR-019).

### Memory pull contract (MANDATORY на каждый audit)
Перед каждой audit-сессией Guardian (factory или project) ОБЯЗАН прочесть и загрузить в context:
1. ~/banxe-architecture/MEMORY.md (стабильная память проекта).
2. ~/banxe-architecture/INSTRUCTION-LEDGER.md (журнал поручений operator).
3. ~/banxe-architecture/GAP-REGISTER.md (журнал отступлений).
4. ~/banxe-architecture/PROMPT-CANON-PROJECT.md (канон промтов).
5. ~/banxe-architecture/HITL-MATRIX.yaml (HITL operations).
6. ~/banxe-architecture/constitution/README.md + ~/banxe-architecture/constitution/amendments/*.md (immutable rules + поправки).
7. ~/banxe-architecture/decisions/*.md (все ADR).
8. ~/banxe-architecture/adrs/*.md.
9. ~/banxe-emi-stack/docs/adr/*.md.
10. Active sprint roadmap: ~/MetaClaw/docs/roadmap/banxe-cluster-v2.X-phaseN.md, ~/banxe-architecture/docs/ROADMAP-MATRIX.md.

### Append-only contracts
- INSTRUCTION-LEDGER.md: каждое operator поручение получает уникальный ID (формат `INS-YYYY-MM-DD-NNN`), Guardian при detect нового поручения добавляет entry. Manual edit запрещён (Guardian блокирует diff с inline change в LEDGER, разрешён только append в конец файла).
- GAP-REGISTER.md: Guardian при override автоматически добавляет entry с reason. Manual edit запрещён аналогично.
- constitution/amendments/: только monotonic add (amendment-NN.md, никогда delete/edit).

### Rewrite protection
- MEMORY.md: rewrite разрешён только operator через PR с label `memory-rewrite-approved`.
- PROMPT-CANON-PROJECT.md: rewrite требует ADR amendment.
- HITL-MATRIX.yaml: edit требует label `hitl-update-approved` + ADR amendment ссылка.

### Verify drill
- Daily cron: проверка integrity всех memory files (no missing, no truncation, line count growth-only).
- Weekly: Guardian отчитывается в audit log сколько раз каждый memory file был прочитан за неделю; если 0 — alert.

## Consequences
- + Memory artefacts становятся обязательными inputs для AI решений.
- + AI агенты (включая меня как assistant) физически не могут "забыть" instruction.
- − Каждый audit становится медленнее (~1-2s на pull всех файлов; mitigation — кэш на 60s).

## Status
**LOCKED canonical memory governance.** ADR-019 Guardian обязан соблюдать ADR-020.
