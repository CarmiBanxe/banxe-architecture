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

---

## Snapshot v2 — 2026-06-28 (append-only; basis: live shell P0 RUNTIME CLAIMS @ origin/main)

---

### Models & Routing

**Ollama :11434 — 10 active models:**

| Model | Notes |
|-------|-------|
| `qwen3-235b-a22b-banxe` | BANXE custom variant |
| `qwen3-235b-a22b` | Base 235B |
| `llama3.3-70b` | General reasoning |
| `qwen3.5-35b` | Mid-tier |
| `qwen3-4b` | Fast/lightweight |
| `qwen3-30b-a3b` | Compact 30B |
| `qwen3.5-latest` | Latest snapshot |
| `qwen3-coder-next` | Code specialization |
| `glm-4.7-flash` | Flash variant |
| `gpt-oss-20b` | OSS GPT-class |

**qwen3-235b master :8082** (ADR-018): Q3KS 235.1B, 101.4 GB, evo2 healthy.

**LiteLLM router :4000 — 5 canonical aliases (I-32):**

| Alias | Target |
|-------|--------|
| `factory-fast` | qwen3:4b @ Legion RTX 4070 (FA-1 ✅) |
| `factory-mid` | qwen3:30b-a3b MoE @ evo1+evo2 LB (Strix Halo iGPU) |
| `factory-heavy` | llama3.3:70b @ evo1+evo2 LB (Strix Halo iGPU) |
| `factory-coder` | qwen3-coder-next (Q4_K_M, 51B) @ evo1 |
| `project-reason` | qwen3:235b-a22b (Q3_K_S, 142 GB) @ evo2:8082 standalone (ADR-018) |

**Classifier:** qwen2.5-0.5b @ evo2 (routing classification, lightweight).

**[ФАКТ] Cross-refs:** ADR-018 (hybrid compute evo1/evo2 USB4); ADR-016 (LiteLLM single entrypoint); I-32 (all AI calls via :4000).

---

### Compliance Services & Ports

| Port | Service | Status | ADR / Note |
|------|---------|--------|-----------|
| :8094 | Verify API / auto-verify | PRESENT (evo1) | ADR-012, I-09; compliance/AML response validation; routes 8093→8094 |
| :8084 | Watchman (Moov) | PRESENT | Sanctions screening |
| :8085 | Screener | PRESENT | AML screener |
| :8086 | Yente | Phase 3 / PLANNED | OpenSanctions; Phase 3 deployment |
| :5001 | Jube | Reference-only | ADR-004 (AGPLv3 internal-only; B2B → Apache-2.0 rewrite required) |
| :5002 / :5003 / :15433 | Marble | ELv2 internal | ADR-005; fraud scoring |
| :5137 / :5200 / :5201 | Ballerine | PRESENT | KYC orchestration (self-hosted) |
| :3001 | MiroFish | PRESENT | — |
| tx_monitor | 9 deterministic rules + Redis 24h velocity | PRESENT | :6379; Apache-2.0 compatible path |

**[ФАКТ] tx_monitor** — 9 deterministic rules + Redis velocity tracker (24h window).
Independent of Jube AGPL; forms Apache-2.0 compliant TM-baseline.

---

### Orchestration Runtime

| Component | Endpoint | Status | Notes |
|-----------|----------|--------|-------|
| Guardian factory | :8195 | PRESENT (evo1) | ADR-077; App id 15368 |
| Guardian project | :8196 | PRESENT (evo1) | ADR-077; App id 15368 |
| guardian-shim | — | PRESENT | I-36: fail-closed / fail-open modes |
| Keycloak | :8180 | LIVE | v26.2.5; realm banxe; 7 roles; KeycloakAdapter active |
| n8n | :5678 | DEPLOYED (evo1) | 5 workflows: safeguarding-shortfall-alert, daily-recon-report, complaint-sla-monitor, mcp-health-monitor, k-gabriel-n8n; HITL gate (I-27) |
| Redis IL allocator | evo1 shared | PRESENT | ADR-143-A: key `banxe:il:counter` INCR; fallback local max+1 |

**Guardian shim I-36:** fail-closed = block on degradation; fail-open = pass with alert.
Degradation detection: ADR-139. Guardian factory/project = L0 fleet infrastructure.

---

### banxe-recon Service — Current Status

**[ФАКТ] Current status:** `inactive` (verified 2026-06-28).
Note: banxe-recon.service/timer was `installed/active` per FROZEN-ARCHIVE (historical S7 snapshot).
Status has drifted — current evo1 state = inactive/not-found.

**Implication:** CASS 15 daily reconciliation cron is NOT currently running via systemd.
Operator must re-enable after HITL gate (CTIO + CFO sign-off) per GAP-087 activation spec.

**Cross-refs:** FROZEN-ARCHIVE (historical), GAP-087 (LIVE activation spec), HITL gate requirement.

---

### Secrets Policy

**[ПРИНЦИП]** Этот snapshot НЕ фиксирует значения секретов (ANTHROPIC_API_KEY и пр.).
Секреты хранятся в `/etc/banxe/secrets.env` и `~/.env.*` — не в документации (I-02, security-policy.md).
