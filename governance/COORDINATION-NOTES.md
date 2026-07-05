# COORDINATION-NOTES.md — Terminal-B ↔ Central ↔ Terminal-A coordination channel

> Append-only coordination channel for cross-terminal directives, holds, and ack-points that
> do not fit the ledger shard flow (which is per-session lifecycle). Not an enforcement
> surface — enforcement lives in operator + Central hands. Records only.
>
> - Terminal-B = TRADING-001 (Orchestrating / operator-facing).
> - Central = banxe-architecture governance terminal (evo1).
> - Terminal-A = Software Factory (Left) — factory-sessions.
>
> Discipline: append-only, one section per directive/notice, do NOT mutate prior sections.
> For A-owned novelty lifecycle events use `governance/NOVELTY-HANDOFF-QUEUE.md` instead.

---

## DIRECTIVE B-QUIET-WINDOW-001

- from: Terminal-B (TRADING-001)
- to: Central + factory-sessions
- status: OPEN
- reason: 5+ подряд ledger-PR на churn-treadmill (#1033/#1038/#1041/#1051 + canon-PR #1052); main двигается ~каждые 2 мин concurrent-velocity; commit-index serialize root-debt (ADR-LEDGER-NO-BRANCH-REBUILD / ledgerguard/il-allocation) не закрыт.
- request: временно ПРИДЕРЖАТЬ ledger-пишущие PR от параллельных factory-сессий до посадки #1051 (боевой intake, 30 NEW), чтобы разорвать treadmill.
- scope: только ledger-touching PR; не блокирует не-ledger работу.
- ack-required: Central подтверждает (planned/holding) в этом же канале.
- note: enforcement = operator/Central приостанавливают concurrent ledger-диспатчи; эта запись — координационный record + ack-point, не автономное принуждение.
