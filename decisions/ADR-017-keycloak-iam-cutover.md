# ADR-017: Keycloak IAM Cutover for EMI Realm `banxe-emi`

**Status:** Accepted
**Date:** 2026-05-03
**Source-of-determination:** body line `- **Status:** Accepted` (hyphen-prefixed list-form header — not matched by INDEX generator regex `^\*\*Status:\*\*`); confirmed Accepted per S12.1 evidence (INSTRUCTION-LEDGER line 7938) and S13.8 Legion :8180 collision-verify (PR #282)

- **Status:** Accepted
- **Date:** 2026-05-03
- **Deciders:** Architecture WG (Banxe), IAM lead
- **Scope:** banxe-emi-stack, banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher, all future EMI services
- **Supersedes:** local IAM (Legion) — to be retired post-cutover; rollback path retained
- **Related:**
  - banxe-architecture decisions/ADR-016 (AI plane and PII/AML routing)
  - banxe-emi-stack docs/adr/ADR-015-auth-ports.md (Auth Ports — Keycloak)
  - banxe-emi-stack docs/Keycloak-next-session-roadmap.md (IAM cutover plan v0.1, paper)
  - banxe-architecture docs/ROADMAP-MATRIX.md → P3.4 (PR #22)

## Context

EMI стек выходит на FCA CASS 15 (deadline 2026-05-07). Текущий IAM-стек:
- Часть EMI-сервисов исторически использует direct user/password в env (`.env*`), что несовместимо с FCA / GDPR (Art. 32) и с инвариантом I-33 (deny-paths, ADR-016).
- Локальный IAM на Legion (WSL2 `--user` units) служил времянкой; не подходит для service-to-service auth и audit log.
- Развёрнут Keycloak (см. ADR-015 в banxe-emi-stack) с realm-кандидатом `banxe-emi`.

Без единого decision record cutover будет проводиться раз-разу, без аудит-следа.

## Decision

1. **Единый IAM-plane.** Keycloak realm `banxe-emi` на хосте evo1 (порт :8180) — единственный санкционированный issuer токенов для EMI-сервисов. Прямые пары user/password в env запрещены.

2. **Service-to-service auth.** Каждый EMI-сервис получает client_id + client_secret в Keycloak realm `banxe-emi`. Токены — короткоживущие (≤ 15 минут), refresh — стандартный OIDC.

3. **OIDC discovery.** Канонический discovery URL:
   `http://evo1:8180/realms/banxe-emi/.well-known/openid-configuration`
   Все EMI-сервисы получают конфиг через discovery; hardcoded endpoints запрещены.

4. **Mappers и audit.** Realm-mappers фиксируют `service_id`, `environment`, `compliance_scope`. Все события логина / token-issue пишутся в Keycloak audit log; ретеншен — не менее 12 месяцев (FCA CASS 15).

5. **Rotation policy.** client_secrets ротируются раз в 90 дней или по инциденту. Master key — operator-supplied env, никогда не коммитится.

6. **Backout.** До подтверждённого PASS на evo1 — Legion local IAM (`--user` units) включаемый для каждого сервиса по runbook `banxe-emi-stack/docs/Keycloak-next-session-roadmap.md §IAM cutover plan v0.1`. После PASS Legion local IAM удерживается ещё 7 дней, затем декомиссионируется.

7. **Энфорсмент.**
   - pre-commit hook в каждом EMI-репо: запрет direct credentials в `.env*`, `*.yaml`, `*.json`.
   - code review checklist: «Auth via Keycloak realm `banxe-emi` only».
   - Нарушение = **P0 security incident** (FCA CASS 15 + GDPR Art. 32).

## Consequences

**Положительные**
- Единая точка аудита auth-трафика для FCA / compliance.
- Возможность ротации client_secrets без рефакторинга сервисов.
- Закрытие зазора с инвариантом I-33 (deny-paths) — credentials больше не лежат в `.env*`.

**Отрицательные / риски**
- Точка отказа: Keycloak на evo1. Митигация — health-checks, документированный rollback на Legion local IAM, мониторинг через banxe-dashboard.
- Срок: 4 дня до FCA CASS 15. Если PASS не достигнут к 2026-05-07 — переключение в P0 incident-режим, см. P3.4 risk в ROADMAP-MATRIX.

## Compliance mapping

- FCA CASS 15 (deadline 2026-05-07): требование контроля доступа к клиентским данным — закрывается п.1–4.
- FCA MLR 2017: audit trail для auth-событий — закрывается п.4 (Keycloak audit log).
- GDPR Art. 32: security of processing — закрывается п.5 (rotation) и п.7 (enforcement).

## Enforcement artefacts

- pre-commit hook: запрет direct credentials в env-файлах EMI-репо.
- Review checklist: «Auth via Keycloak realm `banxe-emi` only».
- Keycloak audit log + retention 12 месяцев.
- INVARIANTS.md: I-34 (no direct credentials in EMI services), I-35 (Keycloak realm `banxe-emi` as single issuer) — будут добавлены отдельным PR.

## Rollout

- T+0 (этот ADR Accepted): фиксация в banxe-architecture/decisions/.
- T+1: deploy realm `banxe-emi` на evo1 :8180; OIDC discovery reachable.
- T+2: provision client_id/secret для banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher.
- T+3: pre-commit hook + review checklist в каждом EMI-репо.
- T+4 (≤ 2026-05-07): подтверждённый PASS — все EMI-сервисы аутентифицируются через realm `banxe-emi`.
- T+11: декомиссия Legion local IAM (`--user` units), запись в GAP-REGISTER.

---

## Implementation Note — 2026-05-04 (Strategy-A re-engaged)

**Context**: P3.4 Keycloak deployment unblocked on second attempt via STRATEGY-A.

### Strategies considered and rejected

| Strategy | Description | Rejection reason |
|----------|-------------|-----------------|
| STRATEGY-B | KC on Legion (WSL2), served via Tailscale IP 100.101.218.26 | Legion WSL2 IP (172.22.56.223) not LAN-reachable from evo1; Tailscale IP also unreachable from evo1 host |
| STRATEGY-C | Host-installed KC binary on evo1 | No root access; KC binary not installed on evo1 |

### STRATEGY-A (selected)

- **Postgres**: dedicated `keycloak-pg` sidecar (postgres:16-alpine, volume `keycloak_pg_data`) — no dependency on `banxe-marble-postgres`.
- **Keycloak**: `docker compose` on evo1, port 8180. `kc.sh build` baked into Dockerfile at image build time (`--optimized` at runtime). Avoids Quarkus SIGKILL race under evo1 runtime load.
- **Resources**: KC mem_limit=4g / memswap=8g; Postgres mem_limit=1g / memswap=2g.
- **Realm**: imported via `--import-realm` flag from `./realms/banxe-emi-realm.json`.
- **Secrets**: all via `~/.banxe/keycloak.env` (chmod 600, I-34 compliant).
- **Artefacts**: `infra/keycloak-banxe-emi/Dockerfile` + `docker-compose.yml` + RUNBOOK.md §Strategy-A Activation Plan — banxe-emi-stack PR #54.

### Quarkus SIGKILL status

- Session-1 (2026-05-04 01:00 CEST): SIGKILL reproduced (evo1 load 35+).
- Session-2 (2026-05-04 ~14:00 CEST): build EXIT=0 in 9.8s (22GB RAM available, same load).
- **Assessment**: load-dependent, not systematic. Baking `kc.sh build` into Dockerfile at image build time (on a machine with headroom) eliminates the runtime race.

### Status

WAITING_FOR_GATE-A — awaiting operator signal `go GATE-A` to execute on evo1.
G-IAM-01..07 artefacts ready. G-IAM-08 (end-to-end smoke) unblocked after GATE-A.
