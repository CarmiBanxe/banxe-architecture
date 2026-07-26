# Sprint 1–4 Shell Audit — Artefact Presence

AUDIT GUIDE (READ-ONLY): команды запускаются оператором вручную из корня канон-worktree; для runtime-якорей — из `~/banxe-emi-stack`. Запрещены `rm`/`mv`/`sed -i`.

## Quick presence check

```sh
# Register + структура
find docs/governance -name 'OPEN-REGULATORY-QUESTIONS-REGISTER*'
find bank-rooms -name 'README.md' | sort
find bank-rooms -name 'agents-*.yaml' | sort
ls docs/sprints/

# Sprint artefacts by title
grep -Rln 'Card Functional Scope Note\|CASP Perimeter Memo\|Travel Rule Split Note' docs/sprints/
grep -Rln 'Art.37 Applicability\|Interim Consent-Owner\|High-Risk Map\|AI-Act Compliance Timeline' docs/sprints/
grep -Rln 'Product Evidence Pack Template\|Per-Product Evidence Packs\|Permissions Map per Product' docs/sprints/
grep -Rln 'DORA-Style ICT\|Webhook / Event Lifecycle\|Register-of-Information' docs/sprints/

# Register: evidence links + proposed entries
grep -nE 'docs/sprints/sprint-' docs/governance/OPEN-REGULATORY-QUESTIONS-REGISTER-*.md
grep -nE 'proposed #9|proposed #10|Proposed future entries' docs/governance/OPEN-REGULATORY-QUESTIONS-REGISTER-*.md

# Runtime anchors (из ~/banxe-emi-stack)
ls services/card_issuing/card_agent.py services/crypto_custody/crypto_agent.py \
   services/savings/savings_agent.py services/insurance/insurance_agent.py \
   services/merchant_acquiring/merchant_agent.py services/consent_management/consent_agent.py \
   services/midaz_mcp/midaz_agent.py services/webhook_orchestrator/webhook_agent.py
```

## How to interpret
- Путь найден → REAL FILE PRESENT (можно ссылаться как evidence-кандидат в register).
- Совпадение только в планах/register → PLANNING-ONLY.
- Тишина → NOT FOUND / TO CREATE.
Статусы register'а этим аудитом не меняются; ни один спринт не объявляется complete/compliant.

