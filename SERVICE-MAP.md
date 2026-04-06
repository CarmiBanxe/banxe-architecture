# Service Map — Banxe GMKtec (192.168.0.72)

**Последнее обновление:** 2026-04-06 (Sprint 8: Midaz CBS deployed)  
**Платформа:** AMD Ryzen AI MAX+ 395, 128GB RAM, ROCm

---

## Активные сервисы

| Сервис | Порт | Протокол | Лицензия | Статус | Назначение |
|--------|------|----------|----------|--------|-----------|
| Ollama | 11434 | HTTP | MIT | ✅ | LLM inference (qwen3-banxe-v2) |
| OpenClaw moa-bot | 18789 | Telegram/HTTP | Commercial | ✅ | @mycarmi_moa_bot — оператор MLRO |
| OpenClaw ctio-bot | 18791 | Telegram/HTTP | Commercial | ✅ | Бот Олега (CTIO) |
| OpenClaw @mycarmibot | 18793 | Telegram/HTTP | Commercial | ✅ | Отдельный проект (не трогать) |
| FastAPI compliance | 8093 | HTTP | — | ✅ | AML/KYC/Sanctions API |
| Moov Watchman | 8084 | HTTP | Apache 2.0 | ✅ | OFAC/UN/EU/UK sanctions screening |
| Banxe Screener | 8085 | HTTP | — | ✅ | Watchman + PEP wrapper |
| Yente (OpenSanctions) | 8086 | HTTP | MIT | PLANNED Phase 3 | Primary sanctions/PEP (200K+ entities) |
| Jube TM | 5001 | HTTP | AGPLv3 | ✅ | Probabilistic transaction monitoring |
| Marble API | 5002 | HTTP | Apache 2.0 | ✅ | Case management backend |
| Marble UI | 5003 | HTTP | Apache 2.0 | ✅ | MLRO dashboard (mark@banxe.com) |
| ClickHouse | 9000/8123 | TCP/HTTP | Apache 2.0 | ✅ | FCA audit trail, TTL 5Y |
| PostgreSQL (compliance) | 5432 | TCP | PostgreSQL | ✅ | PEP (14,491), KYB entities |
| PostgreSQL (Jube) | 15432 | TCP | PostgreSQL | ✅ | Jube TM internal |
| PostgreSQL (Marble) | 15433 | TCP | PostgreSQL | ✅ | Marble cases |
| Redis | 6379 | TCP | BSD | ✅ | Velocity monitoring (24h TTL) |
| Redis (Jube) | 16379 | TCP | BSD | ✅ | Jube internal |
| PII Proxy (Presidio) | 8089 | HTTP | MIT | ✅ | GDPR PII anonymisation |
| Deep Search | 8088 | HTTP | — | ✅ | Compliance research |
| n8n | 5678 | HTTP | Fair-code | ✅ | Workflow automation (developer) |
| nginx | 443/80 | HTTPS/HTTP | MIT | ✅ | Reverse proxy, Web UI |
| Firebase emulator | 9099/4000 | HTTP | Apache 2.0 | ✅ | Marble auth (local mode) |
| Auto-Verify API | 8094 | HTTP | — | ✅ | Agent response verification |
| AutoResearchClaw | — | — | — | ✅ | R&D optimization (not prod) |
| **Midaz Ledger** | **8095** | HTTP | Apache 2.0 | **✅ Sprint 8** | CBS PRIMARY: unified ledger (onboarding + transaction) |
| **MongoDB (Midaz)** | 5703 | TCP | SSPL | **✅ Sprint 8** | Midaz metadata store (rs0 replica set) |
| **RabbitMQ (Midaz)** | 3003/3004 | HTTP/AMQP | MPL 2.0 | **✅ Sprint 8** | Midaz async transaction queue |

## Модели Ollama (актуально 2026-04-05)

| Модель | Размер | Роль | Примечание |
|--------|--------|------|-----------|
| qwen3-banxe-v2 | ~30b-a3b | ГЛАВНАЯ: supervisor/kyc/compliance/risk/crypto | thinking подавлено |
| glm-4.7-flash-abliterated | — | client-service/operations/it-devops | — |
| gpt-oss-derestricted:20b | — | analytics/finance | — |

## Пользователи GMKtec

| User | Shell | Назначение |
|------|-------|-----------|
| root | bash | Gateway runner, systemd, chattr |
| banxe | bash | Compliance stack owner |
| ctio | bash | Олег, полные права (sudo NOPASSWD) |
| mmber | bash | Основной пользователь, vibe-coding |

## OpenClaw конфиги

| Bot | User | Config path | Workspace |
|-----|------|-------------|-----------|
| @mycarmi_moa_bot | root | /root/.openclaw-moa/.openclaw/openclaw.json | /home/mmber/.openclaw/workspace-moa/ |
| ctio-bot | root | /root/.openclaw-ctio/.openclaw/openclaw.json | /home/ctio/.openclaw/workspace-ctio/ |
| @mycarmibot | root | /root/.openclaw-default/.openclaw/openclaw.json | — |

## Cron-задачи

| Расписание | Скрипт | Назначение |
|-----------|--------|-----------|
| `*/5 * * * *` | memory-autosync-watcher.sh | MEMORY.md → workspace + SOUL GUARD |
| `*/5 * * * *` | ctio-watcher.sh v2 | SYSTEM-STATE.md → GitHub |
| `*/15 * * * *` | watchdog-watcher.sh | Watchers alive check |
| `0 */6 * * *` | backup-clickhouse.sh | ClickHouse backup |
| `0 3 * * *` | backup-openclaw.sh | OpenClaw config backup |
| `0 2 * * 0` | run-adversarial-sim.sh | Adversarial simulation |
| `0 4 * * 0` | run-promptfoo-eval.sh | Promptfoo compliance eval |

## Исключения

| Проект | Порт | Статус |
|--------|------|--------|
| GUIYON | 18794 | Исключён из Banxe — отдельный проект (абсолютный запрет) |
