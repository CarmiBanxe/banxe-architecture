# TWO-TERMINAL-SYNC-MARKER (durable SSOT, append-only)
Читается через `git show origin/main:docs/canon/sync/TWO-TERMINAL-SYNC-MARKER.md`.
Live anchor (НЕ merge-gated): `~/.banxe/two-terminal-sync.json`.

## Якорь sync-точки
sync_id · ts(UTC) · central_head(origin/main sha) · factory_last_reply_id · topic · seen_by[] · status
SYNCED ⇔ seen_by содержит обе стороны И central_head == `git rev-parse origin/main`.

## Пример (~/.banxe/two-terminal-sync.json)
{ "sync_id": 42, "ts": "2026-07-28T09:15:00Z", "central_head": "2191112",
  "factory_last_reply_id": "PR#1160/8a30745", "topic": "TERMINAL-ROLE-IDENTITY",
  "seen_by": ["central","factory"], "status": "SYNCED" }

## Reconcile (каждый ход; расширение P-1 на session-state)
fetch → прочитать anchor → сравнить own.last_seen_sync_id и baseline sha с маркером/origin/main
→ при расхождении авторитетна большая пара (sync_id, ts) → переписать маркер как merged-point,
seen_by=self → действовать только при SYNCED. 2+ rebase-цикла (P-2) ⇒ STOP+escalate.

## self-stale (любой ⇒ STOP-and-reconcile)
(a) git-stale: baseline_sha != origin/main (P-1)
(b) dialogue-stale: own.last_seen_sync_id < marker.sync_id
(c) liveness-stale: now − marker.ts > N мин без ack
(d) role-stale: inbound Factory-reply зачтён как голос Central (TERMINAL-ROLE-IDENTITY-CANON)
