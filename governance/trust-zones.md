# Trust Zones — Зонирование доступа к коду и данным

**Добавлен:** аудит v2 (2026-04-05)
**Закрывает:** GAP-REGISTER G-11
**Связанные документы:** `domain/orchestration-tree.md`, `change-classes.yaml`

Три зоны доступа предотвращают supply chain угрозы через партнёрский код
в `vibe-coding/src/compliance/` (runtime adapter с доступом к compliance-решениям).

---

## Зоны

### Zone RED — только BANXE core team

**Репозиторий:** `developer-core` (полностью)
**Доступ:** Moriel Carmi (CEO), Oleg (CTIO) — никаких внешних коллаборантов

Файлы Zone RED:
```
developer-core/
├── compliance/
│   ├── compliance_validator.py      ← policy enforcement
│   ├── verification/                ← VerificationResult, ConsensusResult
│   ├── training/
│   │   ├── feedback_loop.py         ← self-modifying governance engine
│   │   ├── scenario_registry.yaml   ← AML scenario taxonomy
│   │   └── registry_loader.py       ← I-1..I-10 enforcement
│   └── scenarios/                   ← training scenarios bank

banxe-architecture/
├── INVARIANTS.md                    ← architectural invariants
├── governance/                      ← change-classes, trust-zones, rego
│   ├── change-classes.yaml
│   ├── trust-zones.md               ← этот файл
│   └── banxe.rego                   ← OPA rules
└── decisions/ADR-*.md               ← architectural decisions
```

Требования:
- Branch protection: `main` — required reviews от минимум 1 core team member
- Signed commits обязательны
- Никаких fork PR от внешних аккаунтов

---

### Zone AMBER — BANXE core team + trusted partners

**Репозиторий:** `vibe-coding` (только `src/compliance/`)
**Доступ:** core team + trusted partners с signed commits

Файлы Zone AMBER:
```
vibe-coding/src/compliance/
├── api.py                           ← FastAPI gateway, emergency_stop dependency
├── banxe_aml_orchestrator.py        ← BanxeAMLResult, policy_scope
├── sanctions_check.py               ← Yente/Watchman routing (ADR-009)
├── tx_monitor.py                    ← transaction monitoring rules
├── crypto_aml.py                    ← FINOS OpenAML integration
├── models.py                        ← AMLResult, RiskSignal, EvidenceBundle
├── emergency_stop.py                ← EU AI Act Art.14 stop mechanism
├── audit_trail.py                   ← ClickHouse logging
└── compliance_validator.py (mirror) ← копия из developer-core
```

Требования:
- Каждый PR из партнёрского аккаунта → автоматический review request к MLRO
- Automated scanning на prompt-injection patterns перед merge
- Required review от Zone RED member перед merge в main
- Линт/тест обязателен (check-compliance.sh + pytest)

**Trigger:** Любой commit в `src/compliance/` от не-core аккаунта
→ GitHub Action → уведомление MLRO в Telegram → review required

---

### Zone GREEN — все коллаборанты

**Репозиторий:** `vibe-coding` (всё кроме `src/compliance/`)
**Доступ:** все коллабораторы

Файлы Zone GREEN:
```
vibe-coding/
├── docs/                            ← документация, MEMORY.md
├── scripts/                         ← deploy, train, hitl scripts
├── agents/                          ← workspace docs (не SOUL.md/AGENTS.md)
├── src/ (кроме compliance/)         ← утилиты, не-compliance модули
└── .github/workflows/               ← CI (но изменения требуют core review)
```

Требования:
- Standard code review
- CI gate (check-compliance.sh)
- Нет специальных ограничений

---

## Маппинг зон → Orchestration Tree

| Orchestration Level | Zone | Причина |
|---------------------|------|---------|
| Level 0 (MLRO/Human) | RED | Policy authority |
| Level 1 (Orchestrator) | RED | Policy enforcement |
| Level 2a (KYC) | AMBER | Runtime, но compliance-sensitive |
| Level 2b (Sanctions) | AMBER | ADR-009, runtime adapter |
| Level 2c (TM) | AMBER | AML engine |
| Level 2d (Case) | GREEN | Marble integration, UI |
| Level 3 (Feedback) | RED | Self-modifying — только core |

---

## Реализация (текущее состояние)

| Механизм | Статус | Следующий шаг |
|----------|--------|---------------|
| developer-core branch protection | ❌ не настроен | Настроить в GitHub Settings |
| Signed commits требование | ❌ не enforced | `git config gpg.minTrustLevel ultimate` в CI |
| Auto review request для AMBER PR | ❌ не реализован | GitHub Action + CODEOWNERS |
| Prompt injection scanning | ❌ не реализован | Semgrep rule или Cisco Skill Scanner |

### CODEOWNERS для Zone AMBER

```
# .github/CODEOWNERS
# Zone AMBER — requires core team review
/vibe-coding/src/compliance/ @CarmiBanxe/core-team
/developer-core/compliance/  @CarmiBanxe/core-team

# Zone RED — requires CEO or CTIO
/banxe-architecture/         @bereg2022 @bnxolegcto
```

Добавить в Sprint 3 (G-11): `CONTRIBUTING.md` + CODEOWNERS + branch protection settings.
