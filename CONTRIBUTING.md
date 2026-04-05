# CONTRIBUTING — BANXE AI Bank

**Version:** 1.0 (2026-04-05)
**Closes:** G-11 — Trust Zone Governance
**Authority:** CEO Moriel Carmi + CTIO Oleg

---

## Overview

BANXE operates under a **three-zone trust model** that controls who can change
what code and under what conditions. This model prevents supply-chain attacks
and ensures FCA/DORA audit traceability.

Full specification: `governance/trust-zones.yaml`
Machine-readable invariants: `INVARIANTS.md`
Change classification: `governance/change-classes.yaml`

---

## The Three Zones

```
┌─────────────────────────────────────────────────────────────────┐
│  Zone RED  — Governance Core                                     │
│  AI-generation: FORBIDDEN   Approval: MLRO|CEO|CTIO required    │
│  Files: SOUL.md, *.rego, compliance_config.yaml, change-classes │
├─────────────────────────────────────────────────────────────────┤
│  Zone AMBER  — Compliance Decision Engine                        │
│  AI-generation: Claude Code ONLY   Review: Architect required   │
│  Files: banxe_aml_orchestrator.py, sanctions_check.py, ports/  │
├─────────────────────────────────────────────────────────────────┤
│  Zone GREEN  — Operations & Tests                                │
│  AI-generation: PERMITTED   Review: CI must pass                │
│  Files: api.py, tests/, scripts/, docs/                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Zone RED — Governance Core

### What lives here
| File / Path | Reason | Change Class |
|-------------|--------|--------------|
| `**/SOUL.md` | AI agent identity | CLASS_B |
| `**/IDENTITY.md` | Agent identity | CLASS_B |
| `**/BOOTSTRAP.md` | Agent bootstrap | CLASS_B |
| `**/openclaw.json` | Gateway config | CLASS_B |
| `**/compliance_config.yaml` | Compliance thresholds | CLASS_C |
| `**/*.rego` | OPA/Rego policies | CLASS_C |
| `**/change-classes.yaml` | Governance classification | CLASS_B |
| `**/INVARIANTS.md` | System invariants | CLASS_B |
| `governance/trust-zones.yaml` | Trust zone rules | CLASS_B |
| `decisions/ADR-*.md` | Architecture decisions | CLASS_B |
| `governance/soul_governance.py` | Governance gate engine | CLASS_C |

### Rules
1. **AI-generation is FORBIDDEN** in this zone. No LLM-generated code or content.
2. **Manual approval required** from at least one of: MLRO, CEO, CTIO.
3. **Signed commits required** (tag or GPG signature where configured).
4. **policy_guard.py hook** blocks any `Edit`/`Write` without `GOVERNANCE_BYPASS=1`.
5. CLASS_C files (*.rego, compliance_config.yaml) require **MLRO or CEO approval**.
6. All changes are logged to `governance_log.jsonl` (append-only).

### How to change a RED zone file
```bash
# 1. Set governance bypass (use only after human approval obtained)
export GOVERNANCE_BYPASS=1

# 2. For SOUL.md — use the protected update script
bash scripts/protect-soul.sh update docs/SOUL.md \
  --approver "Moriel.Carmi" --role "CEO" --reason "Quarterly review Q2-2026"

# 3. For compliance_config.yaml or *.rego — use the governance gate
python3 src/compliance/governance/soul_governance.py check \
  --target compliance_config.yaml --approver "MLRO-ID" --role "MLRO"

# 4. Always update the policy drift baseline after RED zone changes
python3 src/compliance/validators/policy_drift_check.py --update
```

---

## Zone AMBER — Compliance Decision Engine

### What lives here
| File / Path | Reason | Invariants |
|-------------|--------|------------|
| `banxe_aml_orchestrator.py` | Level-1 orchestrator | I-21..I-25 |
| `aml_orchestrator.py` | Level-2 AML | I-21, I-24 |
| `sanctions_check.py` | Sanctions screening | I-21, I-24 |
| `tx_monitor.py` | Transaction monitoring | I-21, I-24 |
| `ports/*.py` | Port interfaces | I-22 (no write) |
| `adapters/*.py` | Production adapters | I-24 |
| `agents/orchestration_tree.py` | Trust boundaries | B-01..B-06 |
| `models.py` | AMLResult, ExplanationBundle | I-25 |
| `domain/context-map.yaml` | Bounded context map | CTX-01..05 |
| `agents/passports/*.yaml` | Agent passports | KPMG AIGF |

### Rules
1. **Claude Code ONLY** — no direct editing without Claude Code session.
2. **Architect review required** before merge (at least 1 reviewer).
3. Changes must pass `invariant_check.py` (I-21..I-25) — auto-checked by hook.
4. Changes must pass `bounded_context_check.py` — import boundary enforcement.
5. **No policy_write capability** for Level-2/3 agents (B-06, I-22).
6. All changes trigger `compliance-ci.yml` (5-step gate).

### AMBER development workflow
```bash
# Work via Claude Code (hooks auto-enforce invariants)
# Claude Code session → Edit/Write → policy_guard.py checks zone
# PostToolUse → invariant_check.py + bounded_context_check.py run

# Manual validation
python3 src/compliance/validators/validate_contexts.py
python3 src/compliance/validators/validate_agent_passport.py

# Tests must remain green
pytest src/compliance/ --ignore=src/compliance/test_api_integration.py
```

---

## Zone GREEN — Operations & Tests

### What lives here
| File / Path | Reason |
|-------------|--------|
| `emergency_stop.py` | Circuit-breaker operational tooling |
| `api.py` | FastAPI REST endpoints |
| `dashboard.py` | Admin dashboard |
| `event_sourcing/*.py` | CQRS read models |
| `test_*.py` | All test files |
| `scripts/*.sh` | Deployment scripts |
| `docs/*.md` | Project documentation |
| `AGENTS.md` | Agent instructions (CLASS_A) |
| `.github/workflows/*.yml` | CI/CD workflows |

### Rules
1. **AI-generation PERMITTED** — full vibe-coding allowed.
2. CI (`compliance-ci.yml`) must pass before merge.
3. No hardcoded secrets (enforced by `release.sh` secret scan).
4. Hook warnings from `bounded_context_check.py` should be resolved, not ignored.

---

## Shared Rules (all zones)

| Rule | Description | Enforcement |
|------|-------------|-------------|
| SR-01 | No secrets committed | `release.sh` pre-release scan |
| SR-02 | All changes must pass CI | GitHub Actions branch protection |
| SR-03 | Append-only audit log (I-24) | PostgreSQL REVOKE at DB level |
| SR-04 | Policy drift baseline current | `policy_drift_check.py --update` after RED changes |

---

## Branch Protection (main)

The `main` branch is protected with the following rules:
- ✅ Require status checks: `compliance-ci.yml / compliance-gate`
- ✅ Require at least 1 approving review for AMBER/RED zone changes
- ✅ Dismiss stale reviews on new commits
- ✅ Require linear history (no merge commits)

---

## Zone Escalation

If a file is detected in an unexpected zone:

| Situation | Action |
|-----------|--------|
| RED file edited without GOVERNANCE_BYPASS | `policy_guard.py` blocks (exit 2) |
| AMBER import violates BC rules | `bounded_context_check.py` warns (exit 0) |
| GREEN file has hardcoded policy value | `invariant_check.py` warns (I-21) |
| Policy file hash changed without `--update` | `policy_drift_check.py --verify` exits 1 |

---

## Quick Reference

```bash
# Check which zone a file belongs to
python3 src/compliance/validators/validate_trust_zones.py --file <path>

# Validate all trust zone assignments
python3 src/compliance/validators/validate_trust_zones.py

# Check bounded context violations
python3 src/compliance/validators/validate_contexts.py

# Full compliance check
bash banxe-architecture/validators/check-compliance.sh ~/vibe-coding

# Release (runs all checks)
bash scripts/release.sh 3.2.0
```

---

## Contacts

| Role | Person | Telegram | Scope |
|------|--------|----------|-------|
| CEO | Moriel Carmi (Mark) | @bereg2022 | All zones |
| CTIO | Oleg | @p314pm | All zones |
| MLRO | TBD | — | CLASS_C approvals |
