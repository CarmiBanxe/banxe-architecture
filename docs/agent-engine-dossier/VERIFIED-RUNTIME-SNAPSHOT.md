# Verified Runtime Snapshot — BANXE-CORE-ENGINE Intake

**Snapshot basis:** origin/main @ 6602842
**Date:** 2026-06-28
**Host:** mark-legion (local)
**Method:** S5/S6/S7 shell audit (не воспроизводить без повторного аудита)

---

## Listening Services (VERIFIED)

| Port | Service | Status | Note |
|------|---------|--------|------|
| :8180 | Keycloak (HTTP) | LISTENING | IAM — ADR-IAM |
| :8181 | Keycloak (HTTPS/management) | LISTENING | IAM management |
| :4000 | LiteLLM proxy | LISTENING | INV-AI-01 PII guard |
| :9000 | ClickHouse (native) | LISTENING (local only) | Audit trail, I-08 5yr TTL |

---

## Not Listening at Snapshot Time

| Port | Service | Note |
|------|---------|------|
| :6379 | Redis (local) | NOT LISTENING — ADR-143-A uses shared-evo1 Redis |
| :5678 | n8n | NOT LISTENING — workflow automation, not yet deployed |
| :7233 | Temporal | NOT LISTENING — workflow orchestrator, not yet deployed |
| :6333 | Qdrant | NOT LISTENING — vector memory PLANNED (SRC-02), not deployed |
| :27017 | MongoDB (local) | NOT LISTENING locally |
| :8094 | Verify service | NOT LISTENING |

---

## Special Cases

| Component | Status | Detail |
|-----------|--------|--------|
| MongoDB / Midaz | HEALTHY | Midaz uses :5703 per ADR-013 (NOT :27017) |
| banxe-recon.service | INACTIVE | HITL gate (CTIO + CFO) not yet cleared; timer: not-found |
| AMLSim | PRESENT | /home/mmber/AMLSim on Legion |

---

## Swarm Status (S5/S6/S7 verified)

| Metric | Value | Note |
|--------|-------|------|
| Passports | 70 | VERIFIED — цифра «39» из ранних источников УСТАРЕЛА |
| Souls | 20 | VERIFIED |
| Swarms | 3 | VERIFIED |

---

## Usage Rules

- Все runtime-числа в docs/agent-engine-dossier/ ДОЛЖНЫ ссылаться на этот snapshot.
- Не экстраполировать snapshot за пределы даты 2026-06-28.
- При следующем shell-аудите создать новый snapshot (append-only, не перезаписывать этот).
- [НЕИЗВЕСТНО] для любого компонента, не упомянутого в таблицах выше.

---

## Stale Data Warning

Цифра «39 passports», упоминаемая в ранних частях аналитического корпуса, УСТАРЕЛА.
Verified значение: **70 passports** (S5/S6/S7).
