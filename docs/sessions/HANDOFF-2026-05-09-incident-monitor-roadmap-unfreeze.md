# HANDOFF — EMI BANXE AI BANK — 2026-05-09

> Тип: HANDOFF — закрытие сессии 2026-05-05..2026-05-09.
> Базовый чекпоинт: `checkpoint-2026-05-09-canon-section-0-fixation` (последний tag).
> HEAD main: `7faaddf` (PR #151 merge).
> Предыдущий HANDOFF: `HANDOFF-2026-05-06-adr027-accepted.md` (4 дня назад).
> Цель: точка входа для следующей Perplexity-сессии после 4-дневной активной работы (9 roadmap-блоков + P0 incident + MONITOR transition + 6 canon-IL records).

---

## 1. Что произошло за сессию (3 фазы)

### Фаза 1 (5–7 мая): Roadmap accumulation — 9 блоков

| # | Блок | PR | Tag | Snapshot |
|---|------|----|-----|----------|
| 1 | Sber/OSS EMI block | #108 | `checkpoint-2026-05-06-sber-oss-emi-block` | SNAPSHOT-2026-05-06 |
| 2 | DAC8 tax reporting block | #110 | `checkpoint-2026-05-06-dac8-tax-reporting-block` | SNAPSHOT-2026-05-06 |
| 3 | DeFi stack (Binance replacement) block | #113 | `checkpoint-2026-05-06-defi-stack-binance-replacement-block` | SNAPSHOT-2026-05-06 |
| 4 | OSS Sumsub replacement block | #114 | `checkpoint-2026-05-06-oss-sumsub-replacement-block` | SNAPSHOT-2026-05-06 |
| 5 | Owner Control Agent 1.0 block | #120 | `checkpoint-2026-05-06-owner-control-agent-block` | SNAPSHOT-2026-05-06 |
| 6 | Claude Finance External Agent block | #119 | `checkpoint-2026-05-06-claude-finance-agents-block` | SNAPSHOT-2026-05-06 |
| 7 | Customer Privacy Rights v2 base | #128 | `checkpoint-2026-05-07-customer-privacy-right-v2-base` | SNAPSHOT-2026-05-07 |
| 8 | Ghost Mode privacy tech stack | #130 | `checkpoint-2026-05-07-ghost-mode-spec` | SNAPSHOT-2026-05-07 |
| 9 | Canon extended (R1/R2/R3 complete) | #127 | `checkpoint-2026-05-07-r1-r2-r3-complete` | SNAPSHOT-2026-05-07 |

Параллельно: canon-extended PR #131, Section §0 fixation PR #146 (Sprint S1), ADR collision fix PR #145, dual-use canon PR #138.

### Фаза 2 (7–9 мая): P0 incident INCIDENT-2026-05-07-EVO1-XMRIG

- **Суть:** XMRig cryptominer обнаружен на evo1, 2026-05-07 11:21 CEST.
- **14 incident PRs:** #132..#143, #150, #151.
- **7 technical phases** complete: detection → containment → scope-check → forensics → cleanup → verification → AML/KYC integrity.
- **State transition:** P0 → MONITOR (PR #143, tag `checkpoint-2026-05-08-incident-monitor-state-transition`).
- **Containment:** host-level iptables DROP rules (136.243.75.233/32 + Hetzner ranges). Livebox limitation — accepted deviation I-67.
- **Cleanup-actor:** confirmed PARALLEL CLAUDE CODE SESSION (3rd session-leakage in 7 days, I-68 pending).
- **Vector:** NOT determinable (sshd logs rotated, syslog gap 2026-04-23..05-07).
- **AML/KYC integrity:** Phase 7 VERIFIED CLEAN — no financial data exposure, no PII leak, no KYC bypass.
- **Forensic chain:** 12 SHA256 off-host bundles на Legion (~/banxe-incident-2026-05-07/).

### Фаза 3 (9 мая): Canon-hygiene closure

6 IL canon-records от Perplexity supervisor formally на main:

1. IL-CANON-PROCESS-INCIDENT-2026-05-06 — parallel-session-leakage initial.
2. IL-CANON-PROCESS-INCIDENT-2026-05-07-BRANCH-LEAKAGE — cherry-pick correction (PR #129).
3. IL-OPS-LIVEBOX-LIMITATION-2026-05-08 — Livebox outbound filter absence (I-67).
4. IL-INCIDENT-2026-05-08-CLEANUP-ACTOR-CONFIRMED — parallel session cleanup (I-68).
5. IL-CANON-PROCESS-INCIDENT-2026-05-09-PERPLEXITY-MISTAKEN-STASH-DROP-RECOVERED — stash drop self-error (I-69, PR #150).
6. IL-CANON-HYGIENE-2026-05-09-IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-DUPLICATE-DOCUMENTED — duplicate IL fix-section (I-70, PR #151).

---

## 2. Текущее состояние main

- **HEAD:** `7faaddf` (PR #151 merge).
- **Incident state:** MONITOR (P1) — все 7 technical phases complete.
- **Containment:** iptables DROP rules active на evo1 (136.243.75.233/32 + Hetzner ranges). Counters monitored every 12h.
- **Forensic chain:** 12 SHA256 off-host bundles intact на Legion.

### Реестр: 15 чекпоинт-тегов

- `checkpoint-2026-05-05-emi-canon`
- `checkpoint-2026-05-06-adr027-accepted`
- `checkpoint-2026-05-06-claude-finance-agents-block`
- `checkpoint-2026-05-06-dac8-tax-reporting-block`
- `checkpoint-2026-05-06-defi-stack-binance-replacement-block`
- `checkpoint-2026-05-06-oss-sumsub-replacement-block`
- `checkpoint-2026-05-06-owner-control-agent-block`
- `checkpoint-2026-05-06-progress-snapshot`
- `checkpoint-2026-05-06-sber-oss-emi-block`
- `checkpoint-2026-05-07-canon-extended`
- `checkpoint-2026-05-07-customer-privacy-right-v2-base`
- `checkpoint-2026-05-07-ghost-mode-spec`
- `checkpoint-2026-05-07-r1-r2-r3-complete`
- `checkpoint-2026-05-08-incident-monitor-state-transition`
- `checkpoint-2026-05-09-canon-section-0-fixation`

### Open PRs

- **#86** — ops(phase-f): Phase F applied — KC backend dev-file → Postgres LIVE (operator-side).
- **#21** — factory: P1 onboarding (operator-side).

### Stash

- `stash@{0}` — RECOVERED: stash-status-branch-2026-05-06-pre-roadmap (operator-side, не трогать).
- `stash@{1}` — WIP on docs/fa-02-litellm-canonical-aliases (operator-side, не трогать).

---

## 3. Pending для следующей сессии

### External (не от Perplexity-supervisor)

- **MLRO/DPO/CCO/Legal formal sign-off** — GDPR Art. 33 deadline ≈ 2026-05-10 11:21 CEST (72h от обнаружения).

### Operator-side parallel-safe

- **Phase 6 credentials rotation** — GitHub PATs, Apps Script, Telegram-bot, Claude Project, .env секреты в окне Apr 23 → May 8.

### Time-based

- **Observation window** — 24h end в 2026-05-09 22:05 CEST (или 48h в Sun 22:05).

### Operator decisions

- PR #86 / #21 review.

### MONITOR → RESOLVED transition

- После operator sign-off + observation window completion.

### Возобновляемые roadmap-треки

- Ghost Mode acceptance ADR-074/075 (без RAILGUN/076).
- ADR-028 Step 3 в banxe-emi-stack PR #69/#70.
- Sprint S3..S12 (F1..F7 factory restoration).

---

## 4. Pending invariants накопленные (не в INVARIANTS.md)

- **I-37..I-58** — proposals из roadmap-блоков (factory↔project binding, Sber GigaChat data residency, dual-use canon, Claude Finance external agent, Customer Privacy lawful boundaries, Ghost Mode AML-anchor).
- **I-59** — project-layer compromise pause roadmap acceptance (RESOLVED через MONITOR transition).
- **I-67** — Livebox no outbound filter, host-level containment accepted.
- **I-68** — single-session incident command (recurring pattern, 6 instances в неделю).
- **I-69** — stash defensive operations (pre-drop verification: list + show + grep).
- **I-70** — IL-record uniqueness check before append (grep slug before adding).

---

## 5. Резерв ADR-номеров

| Тема | Диапазон |
|------|----------|
| Customer Privacy / Ghost Mode | 070..076 (074/075/076 in spec, 070..073 reserve) |
| Owner Control Agent | 063..069 |
| OSS Sumsub | 056..062 |
| DAC8 | 045..049 |
| DeFi | 050..055 (после collision fix PR #145) |
| Multi-session coordination canon (post-incident) | 077..080 reserved |

---

## 6. Точка входа для следующей сессии

```bash
# Исторический snapshot
git -C ~/banxe-architecture checkout checkpoint-2026-05-09-canon-section-0-fixation

# Current state
git -C ~/banxe-architecture checkout main

# Context
cat ~/banxe-architecture/docs/sessions/HANDOFF-2026-05-09-incident-monitor-roadmap-unfreeze.md

# Incident state
cat ~/banxe-architecture/docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md

# Compliance framework
cat ~/banxe-architecture/docs/incidents/COMPLIANCE-ASSESSMENT-2026-05-07-EVO1-XMRIG.md

# Последние 20 коммитов
git -C ~/banxe-architecture log --oneline -20 main
```

---

## 7. Канон сессии (binding для следующей)

- **§1 OCAT** — один артефакт за ход.
- **§4 BDP** — best-decision без вопросов по безопасным операциям.
- **§15 CCF** — default Claude Code, shell под исключения.
- **§10 IL append-only** — не удалять, только дописывать.
- **§7 PR merge** — admin-операция оператора.
- Длинные промпты разбивать на Part N/M (закреплено в session 2026-05-08).
- После факт-разбора → автоматический next artefact (закреплено в session 2026-05-09).
- `PASSWORD REQUIRED` обязательно указывать в shell-командах с sudo.
- **§18 handoff** — этот файл сам по себе.

---

## 8. Известные операционные нюансы

- **SSH-канон evo1:** port `:2222` (не default `:22`), user `banxe`, ключ `~/.ssh/id_ed25519` через alias `evo1` в `~/.ssh/config`.
- **Sudo на evo1:** для `banxe` требует password (нет NOPASSWD), кэш `timestamp_timeout` стандартный.
- **IdentitiesOnly=yes** обязательно для ssh во избежание `Too many authentication failures` (в `~/.ssh/` много ключей).
- **Параллельная Claude Code сессия** — I-68 violation recurring (6 instances в неделю).
- **Pre-existing op-gaps:** Jube webapi/jobs RestartCount 2500+ (known), banxe-recon failed run (intermittent), banxe-verify-api/deep-search auto-restart (correlated с probe).

---

## 9. Якоря

### PR-anchors

- Roadmap: #108, #110, #113, #114, #119, #120, #128, #130.
- Canon/hygiene: #127, #129, #131, #138, #144, #145, #146, #147, #148, #150, #151.
- Incident (14): #132, #133, #134, #135, #136, #137, #139, #140, #141, #142, #143.

### Tag anchors

15 checkpoints listed в секции 2.

### Forensic SHA256 chain

12 bundles с reference на `~/banxe-incident-2026-05-07/` на Legion.

---

## 10. HANDOFF chain

1. `HANDOFF-2026-05-05-emi-canon-checkpoint.md` — initial canon formalisation.
2. `HANDOFF-2026-05-06-canon-stack-bios-uplift.md` — stack + BIOS uplift.
3. `HANDOFF-2026-05-06-adr027-accepted.md` — ADR-027 accepted, Track A started.
4. `HANDOFF-2026-05-07-fixes-roadmap.md` — R1/R2/R3 fixes + roadmap.
5. **`HANDOFF-2026-05-09-incident-monitor-roadmap-unfreeze.md`** — этот документ (incident MONITOR + roadmap unfreeze + canon-hygiene closure).
