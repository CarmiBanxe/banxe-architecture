# HANDOFF 2026-05-07 — Roadmap of fixes & §1.bis compliance gaps
<!-- Branch: docs/audit-r3-roadmap-fixes-2026-05-07 -->
<!-- Sister IL: IL-OBSERVE-R3-AGENT-AUDIT-2026-05-07 -->
<!-- Builds on: IL-OPS-R1-R2-FACTORY-PROJECT-EXECUTION-2026-05-07 -->

## 1. Назначение

Документ фиксирует результаты R3 audit (agent placement vs §1.bis canon)
от 2026-05-07 04:00 CEST и предлагает roadmap исправлений для 9
открытых gap'ов после R0–R2 execution.

R0–R2 закрыты в audit trail (PR #121–#126, IL-OPS-R1-R2 PR следующий).
R3 audit проведён, миграция отложена для безопасного исполнения.

## 2. R3 Audit findings — current agent topology

### 2.1 Legion (factory layer per §1.bis)

| Агент | Где работает | Статус §1.bis |
|---|---|---|
| Claude Code (mmber, PID 8160) | ~/banxe-emi-stack (factory work: AUTH/IAM Wave B) | ✅ PASS |
| LiteLLM v2 gateway | 0.0.0.0:4000, master_key=sk-banxe-llm-gateway-2026 | ✅ PASS |
| Ollama service | 127.0.0.1:11434, drop-in canonical | ✅ PASS |
| factory-coder | qwen2.5-coder:14b-banxe-factory loaded; 22/49 layers GPU | ✅ PASS |

### 2.2 evo1 (project layer per §1.bis)

| Агент | PID | Endpoint | Статус §1.bis |
|---|---|---|---|
| OpenClaw ctio (:18791) | 3286→3639 | OLLAMA_API_KEY=ollama-local (direct ollama localhost) | ❌ FAIL §1.bis p.3 |
| OpenClaw guiyon (:18794) | 3287→3849 | OLLAMA_API_KEY=ollama-local | ❌ FAIL |
| OpenClaw moa (:18789) | 3294→3831 | OLLAMA_API_KEY=ollama-local | ❌ FAIL |
| OpenClaw mycarmibot (:18793) | — | env unknown | ⚠ UNKNOWN |
| Guardian factory (:8195) | 6864 | GUARDIAN_CH_HOST=127.0.0.1 (ClickHouse only, no LLM) | ✅ PASS (no LLM use) |
| Guardian project (:8196) | 6909 | GUARDIAN_CH_HOST=127.0.0.1 (ClickHouse only) | ✅ PASS |
| compliance-api (:8194) | 3271 | EnvironmentFile=/data/banxe/banxe-emi-stack/.env (unverified) | ⚠ UNKNOWN |
| banxe-api uvicorn (app.py :8085) | 2094 | /data/banxe/.env: OLLAMA_URL=http://127.0.0.1:11434 | ❌ FAIL §1.bis p.3 |

### 2.3 evo2 (project layer / heavy)

| Агент | Endpoint | Статус §1.bis |
|---|---|---|
| llama-server qwen3-235b (:8082) | --api-key sk-rpc-q235-2026 (server, не клиент) | ✅ PASS — это backend для project-reason маршрута |

## 3. Сводка нарушений §1.bis

| Gap ID | Нарушение | Priority |
|---|---|---|
| G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY | OpenClaw × 3 + banxe-api ходят прямо в local Ollama, минуя Legion LiteLLM gateway | P1 |
| G-INFRA-EVO1-LOAD-AVG-35 | Постоянная нагрузка ~35 на evo1 без идентифицированного источника | P2 |
| G-INFRA-EVO1-PORT-4000-COLLISION | evo1:4000 занят Google IDX preview | P3 |
| G-INFRA-EVO2-VRAM-CAP-VS-UMA | UMA=2G vs heavy GPU offload потребности; нужен ADR | P1 |
| G-GUARDIAN-WEBHOOK-MISSING | GitHub App id 15368 не доставляет webhook на evo1:8195/8196; check_runs пустые | P1 |
| G-NETWORK-MAGICDNS-MISSING | Tailscale MagicDNS не работает; имена evo1/evo2 не резолвятся на ОС-уровне | P2 |
| G-INFRA-EVO-FLAPPING | evo1, evo2 уходили в Tailscale-offline во время сессии | P2 |
| G-INFRA-EVO2-DNS-BROKEN | DNS unreachable с evo2 (Tailscale health warning) | P3 |
| G-NETWORK-SSH22-NOT-ON-TAILSCALE | SSH:22 closed/refused по Tailscale IP; работает только через ssh-config alias | P3 |

## 4. Roadmap исправлений (приоритезированный)

### 4.1 P1 блокеры

#### 4.1.1 G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY
**Цель:** все project-агенты обращаются к LLM только через Legion LiteLLM 0.0.0.0:4000 (Tailscale: 100.101.218.26:4000).
**Шаги:**
1. Создать новый API-key в LiteLLM для project-agents (отдельно от master).
2. Обновить .env / Environment= в systemd-units OpenClaw ctio/guiyon/moa/mycarmibot:
   - убрать OLLAMA_API_KEY=ollama-local
   - добавить OPENAI_API_BASE=http://100.101.218.26:4000/v1
   - добавить OPENAI_API_KEY=<project-agent-key>
   - модель использовать через model_name (project-mid / project-heavy / project-reason)
3. Обновить /data/banxe/.env: убрать OLLAMA_URL, добавить LITELLM_BASE_URL.
4. systemctl restart по очереди + smoke test.
5. Verify journal: запросы летят через Legion gateway (login traces in litellm logs).
**Критерии closure:** ни один project-agent не имеет ollama:11434 в env; все запросы идут через :4000.
**Owner:** ops session, ~30 мин, low-risk если поэтапно.

#### 4.1.2 G-INFRA-EVO2-VRAM-CAP-VS-UMA
**Цель:** ADR с решением: GTT overflow vs UMA увеличение vs hybrid CPU heavy.
**Шаги:**
1. Создать docs/adr/ADR-031-evo2-uma-strategy.md.
2. Опции: A) UMA=2G + GTT overflow (текущее, qwen3:235b на CPU/RAM через llama-server); B) UMA=8G/16G/32G — потеря системной RAM; C) hybrid (mid models GPU, heavy CPU).
3. Status: Proposed; решение operator.
**Owner:** architecture session.

#### 4.1.3 G-GUARDIAN-WEBHOOK-MISSING
**Цель:** GitHub App id 15368 доставляет webhooks на evo1:8195/8196 и постит check_runs обратно.
**Шаги:**
1. Проверить App credentials (private key, webhook secret).
2. Поднять публичный HTTPS endpoint через guiyon-tunnel.service (cloudflared) для путей /guardian-factory/webhook + /guardian-project/webhook (через nginx route в openclaw site).
3. Указать webhook URL в GitHub App settings.
4. Verify: новый PR → webhook delivered → Guardian endpoint hit → check_run posted.
**Owner:** DevOps session, multi-hour.

### 4.2 P2 второй приоритет

#### 4.2.1 G-INFRA-EVO1-LOAD-AVG-35
**Шаги:**
1. ssh evo1: top -c -b -n 1 | head -25
2. iotop -ao -b -n 5 | head -25 (требует package iotop)
3. journalctl --since "1 hour ago" | grep -iE "error|warn|spike"
4. Идентифицировать источник; если это компиляция/индексация — норма; если runaway — kill/throttle.

#### 4.2.2 G-NETWORK-MAGICDNS-MISSING
**Шаги:**
1. tailscale set --accept-dns=true on каждом узле.
2. resolv.conf проверить что 100.100.100.100 (Tailscale DNS) первый.
3. Verify: getent hosts evo1 returns Tailscale IP.

#### 4.2.3 G-INFRA-EVO-FLAPPING
**Шаги:**
1. ssh evo1/evo2: systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
2. systemd-inhibit --mode=block --who=ops --why="prevent NucBox suspend during agent runtime" sleep infinity (как unit или oneshot).
3. Проверить power management в BIOS (если есть auto-suspend).

### 4.3 P3 косметика

| Gap | Action |
|---|---|
| G-INFRA-EVO1-PORT-4000-COLLISION | Найти что запустило Google IDX, либо смириться. |
| G-INFRA-EVO2-DNS-BROKEN | resolv.conf fix через systemd-resolved. |
| G-NETWORK-SSH22-NOT-ON-TAILSCALE | Tailscale ACL update (или оставить ssh-config alias). |

## 5. Порядок выполнения (suggested)

```
G-INFRA-EVO1-LOAD-AVG-35 (P2 быстрая диагностика — может объяснить flapping)
↓
G-NETWORK-MAGICDNS-MISSING (P2 техническая база для остальных fix)
↓
G-INFRA-EVO-FLAPPING (P2 предотвратить будущие incidents)
↓
G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY (P1 main canon fix)
↓
G-INFRA-EVO2-VRAM-CAP-VS-UMA (P1 architectural ADR)
↓
G-GUARDIAN-WEBHOOK-MISSING (P1 process unblock — бесконечно полезно)
↓
P3 cleanup
```

## 6. Code-quality stack audit (live evidence 2026-05-07 11:00 CEST)

### Что работает (canon-evidence)

- Spec-First Auditor v2: 12 BLOCK'ов territory/existence/content;
  source ~/developer/spec-first/audit/spec_first_auditor.py;
  live PASS на текущем working tree.
- gitleaks v8.30.1 (pre-commit + GitHub Action):
  /home/mmber/bin/gitleaks; configured via .pre-commit-config.yaml.
- .claude/settings.json permissions: 144 allow / 1 ask / 39 deny.
- Personal layer ~/.claude/settings.json: deny-list active.
- Subagents: controller, inspector-agent (adversarial verifier =
  de-facto code-guardian), openclo-moa, safeguarding-agent.
- LiteLLM v2 gateway: 20 model routes per §1.bis (factory-fast,
  factory-mid, factory-heavy, factory-coder, project-mid,
  project-reason, ...); live smoke test factory-fast PASS
  (Pong! 5 tokens, 200 OK).
- factory-coder qwen2.5-coder:14b-banxe-factory loaded, 49%/51% CPU/GPU.
- CLAUDE.md (root + .claude/) and .claude/rules/ (7 binding docs).

### Новые gap'ы (added to GAP-REGISTER)

- G-CI-WORKFLOWS-FAILING (P2): ci.yml fails 0s + docs.yml fails 17s on every push.
- G-SECURITY-HISTORICAL-LEAKS (P1): gitleaks reports 8 leaks in 469-commit history.
- G-FACTORY-GITIGNORE-INCOMPLETE (P3): .gitignore missing .claude/settings.local.json, CLAUDE.local.md.

### Что НЕ требуется (false-positive ranges)

- §1.ter Claude Code config layers: фактически уже реализован через
  существующие .claude/settings.json + CLAUDE.md + .claude/agents/ +
  .claude/rules/. Введение §1.ter избыточно. Оставить как-есть.
- code-guardian как новый subagent: inspector-agent выполняет эту
  роль. Дополнительный subagent не нужен.

## 7. Anchors

- Canon: docs/canon/factory-project-stack-2026-05.md §1, §1.bis
- Sister IL chain: IL-CANON-FACTORY-PROJECT-LAYERS-2026-05-07,
  IL-OPS-R1-R2-FACTORY-PROJECT-EXECUTION-2026-05-07,
  IL-OBSERVE-R3-AGENT-AUDIT-2026-05-07 (this PR)
- Live-shell evidence: this session's R3 audit timestamps 2026-05-07 04:00 CEST
