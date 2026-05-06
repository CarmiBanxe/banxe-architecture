---
paths: ["docker/**", "infra/**", "scripts/**"]
---

# Infrastructure Rules — BANXE AI BANK

## evo1 — GMKtec EVO-X2 (192.168.0.72)

Источник истины: docs/SYSTEM-STATE.md (auto-updated */5 min)
- PostgreSQL 17: :5432 — DBs: banxe_compliance, midaz_onboarding, midaz_transaction
- Redis Stack: :6379 — DB0 compliance, DB1 Midaz
- ClickHouse: :8123/:9000 — DB banxe (15 таблиц)
- Midaz Ledger: :8095→:3002 (lerianstudio/midaz-ledger:latest, 54MB)
- MongoDB 8: :5703→:27017 (replica set rs0)
- RabbitMQ 4.1.3: :3004/:3003
- Ollama: :11434 (qwen3-banxe-v2, 17.3GB)
- Marble: :5003/:5002/:15433 | Ballerine: :5137/:5200/:5201
- Jube: :5001 | n8n: :5678 | MiroFish: :3001
- **Frankfurter FX: :8181** (IL-010, 2026-04-06) | nginx: :443/:80/:8080

---

## evo2 — GMKtec EVO-X2 #2 (192.168.0.15) [G-INFRA-01]

> **Status: TBD** — node active, not yet fully registered in canonical map. Full registration tracked in G-INFRA-01.
> Anchors: ADR-018 (5-layer AI compute), ADR-032 (GLM-4.5-Air distributed), IL-AUDIT-01 A3.

- Hardware: AMD Ryzen AI MAX+ 395 / 128 GiB LPDDR5X / Radeon 8060S 40 CU gfx1151
- USB4 link to evo1: 10.0.0.2/30 ↔ evo1 10.0.0.1/30 (9.12 Gbit/s)
- Key services (as of 2026-05-05):
  - Ollama :11434 (qwen3:235b + 10 models)
  - qwen3-235b-master :8082
  - llama.cpp RPC worker :50052
  - node_exporter :9100 (observability — G-OBS-01 pending)
- GPU userspace: ROCm/amdgpu regression post kernel 6.17 — G-INFRA-02 (P1 open)

---

## SERVICE-MAP — evo1/GMKtec (192.168.0.72)

> Полная карта: `SERVICE-MAP.md`. Здесь — snapshot для быстрой навигации.

| Сервис | Порт | Лицензия | Статус |
|--------|------|----------|--------|
| Ollama (qwen3-banxe-v2) | 11434 | MIT | ✅ |
| OpenClaw moa-bot (@mycarmi_moa_bot) | 18789 | Commercial | ✅ |
| OpenClaw ctio-bot (Олег) | 18791 | Commercial | ✅ |
| FastAPI compliance API | 8093 | — | ✅ |
| Auto-Verify API | 8094 | — | ✅ |
| Midaz Ledger (CBS PRIMARY) | 8095 | Apache 2.0 | ✅ |
| Moov Watchman | 8084 | Apache 2.0 | ✅ |
| Banxe Screener | 8085 | — | ✅ |
| PII Proxy (Presidio) | 8089 | MIT | ✅ |
| **Frankfurter FX (ECB rates)** | **8181** | MIT | **✅ IL-010** |
| Jube TM | 5001 | AGPLv3 | ✅ ref |
| Marble API | 5002 | Apache 2.0 | ✅ |
| Marble UI | 5003 | Apache 2.0 | ✅ |
| MiroFish UI / API | 3001 / 5004 | — | ✅ |
| n8n workflows | 5678 | Fair-code | ✅ |
| ClickHouse | 9000 / 8123 | Apache 2.0 | ✅ |
| PostgreSQL (compliance) | 5432 | PostgreSQL | ✅ |
| PostgreSQL (Jube) | 15432 | PostgreSQL | ✅ |
| PostgreSQL (Marble) | 15433 | PostgreSQL | ✅ |
| Redis Stack | 6379 | BSD | ✅ |
| MongoDB rs0 (Midaz) | 5703→27017 | SSPL | ✅ |
| RabbitMQ (Midaz) | 3003 / 3004 | MPL 2.0 | ✅ |
| Ballerine KYC | 5137 / 5200 / 5201 | Apache 2.0 | ✅ |
| nginx | 443 / 80 / 8080 | MIT | ✅ |
| Yente (OpenSanctions) | 8086 | MIT | ⏳ Phase 3 |

**Cron на GMKtec:**
- `*/5` — memory-autosync + SOUL GUARD | ctio-watcher → SYSTEM-STATE.md
- `*/15` — watchdog-watcher.sh
- `0 */6` — backup-clickhouse.sh
- `0 2 * * 0` — adversarial-sim | `0 4 * * 0` — promptfoo-eval

---

## OPEN-SOURCE АБС СТЕК

### Deployed (✅ на GMKtec)
| Компонент | Решение | Порт |
|-----------|---------|------|
| CBS PRIMARY | Midaz (Lerian Studio) | :8095 |
| KYC/KYB | Ballerine | :5137/:5200/:5201 |
| KYC Rules | Marble (Checkmarble) | :5002/:5003 |
| AML/ML | Jube (AGPLv3) | :5001 |
| Sanctions | Moov Watchman + Yente | :8084/:8086 |
| Workflows | n8n | :5678 |
| AI/LLM | Ollama qwen3-banxe-v2 | :11434 |
| Audit Trail | ClickHouse (5yr TTL) | :9000 |
| PII Proxy | Presidio | :8089 |
| Agents | OpenClaw @mycarmi_moa_bot | :18789 |

### Planned / Phase 1 (P0 — до 7 May 2026)
| Компонент | Решение | IL |
|-----------|---------|-----|
| Safeguarding recon | Blnk Finance + bankstatementparser | IL-009 FA-01/02 |
| Data transforms | dbt Core + dbt-clickhouse | IL-009 FA-03 |
| DB audit | pgAudit (PostgreSQL extension) | IL-009 FA-04 |
| FCA reporting | JasperReports / WeasyPrint | IL-009 FA-05 |
| FX rates | Frankfurter (self-hosted ECB) | ✅ IL-010 :8181 |
| Bank statement API | adorsys PSD2 gateway | IL-009 FA-07 |

### Planned / Phase 1 (P1 — Q2-Q3 2026)
| Компонент | Решение | IL |
|-----------|---------|-----|
| Payment Rails | ClearBank / Modulr BaaS | S4 |
| IDV | Sumsub + Companies House API | S5 |
| Event streaming | Apache Kafka + Flink | FA-15 |
| BI dashboards | Metabase / Apache Superset | FA-08 |
| IAM | Keycloak | FA-14 |
| Distributed tracing | Jaeger v2 | FA-13 |
| Saga/workflow | Temporal | FA-11 |

### CBS FALLBACK / Deferred
| Компонент | Решение | Trigger |
|-----------|---------|---------|
| CBS FALLBACK | Apache Fineract | Loan products needed |
| Programmable ledger | Formance Ledger | FX/marketplace flows |
| High-perf ledger | TigerBeetle | >10k TPS |
| Data lineage | OpenMetadata | Q4 2026 |
| AI finance | FinGPT / OpenBB | Q4 2026 |

---

## Keycloak canonical IAM (FA-4)

> Added 2026-05-06 per FA-4 of IL-FACTORY-AUDIT-01.

### Authority

| Component | Canonical location | Notes |
|---|---|---|
| Keycloak realm `banxe-emi` | **Legion** `100.101.218.26:8180` | Production. Quarkus 26.2.5. Postgres backend in docker bridge 172.23.0.3. Per ADR-017 + G-IAM-08 cutover 2026-05-04. |
| Keycloak admin URL | `http://100.101.218.26:8180/realms/banxe-emi` | Use Tailscale hostname or LAN as appropriate. |
| evo1 :8180 | **NOT used** (legacy, deprecated) | Pre-cutover deployment exists in `/data/banxe/banxe-emi-stack/infra/keycloak-banxe-emi/`. systemd `keycloak.service` in restart-loop (G-OPS-05); decommission deferred. Do NOT route new EMI services here. |

### Service config canon

All EMI services (`banxe-compliance-api`, `banxe-dashboard`, `deep-search`, `drive_watcher`, future) MUST set:

```
KEYCLOAK_URL=http://100.101.218.26:8180
KEYCLOAK_REALM=banxe-emi
IAM_ADAPTER=keycloak
```

The legacy form `KEYCLOAK_URL=http://localhost:8180` (interpreted differently on Legion vs evo1) is deprecated. Only use explicit Legion address for clarity.

### Anchors

- ADR-017 (Keycloak IAM Cutover) — Accepted 2026-05-03
- G-IAM-08 — DONE 2026-05-04 (cutover via STRATEGY-B host migration)
- G-IAM-10 — DONE 2026-05-06 (session-timeout hardening Phase G)
- IL-FA-04-CLOSE — this entry
- G-OPS-05 (evo1 keycloak zombie) — open follow-up
- G-FACTORY-04 (Legion 2x Java) — open follow-up
- docs/canon/operator-canon-2026-05.md
