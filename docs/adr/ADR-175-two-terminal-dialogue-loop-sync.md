# ADR-175: two-terminal dialogue-loop sync-marker & self-stale
Status: PROPOSED
Amends: SYNC-CANON (новый принцип P-6 DIALOGUE-SYNC)
Refs: ADR-163, ADR-170, ADR-153, ADR-134
Depends: TERMINAL-ROLE-IDENTITY-CANON (PROPOSED, PR #1160) — критерий self-stale (d)
Alignment: ADR-102

> Nota (numbering, ADR-119 Rule 8): изначально запрошен как ADR-174; слот занят
> `ADR-174-compliance-source-governance.md` (merged после первичной проверки) → перенумеровано
> в ADR-175 (следующий свободный, max+1). Existing ADR-174 не тронут.

Контекст: SYNC-CANON P-1..P-5 покрывает только git/ledger state; диалоговый контур двух
терминалов — незакрытый пробел. Решение: два слоя маркера (durable SSOT + live anchor),
reconcile-процедура и 4 критерия self-stale (см. docs/canon/sync/TWO-TERMINAL-SYNC-MARKER.md).
