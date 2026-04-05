# Bounded Contexts — BANXE Domain Map

**Добавлен:** аудит toolchain v4 (2026-04-05)
**Закрывает:** GAP-REGISTER G-06, G-18 (частично)
**Принцип:** DDD Bounded Contexts + Anti-Corruption Layers

---

## 5 Bounded Contexts

```
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│  KYC / Onboarding   │  │   Sanctions & PEP   │  │  Tx Monitoring      │
│  Context            │  │   Context           │  │  Context            │
│                     │  │                     │  │                     │
│  CustomerProfile    │  │  ScreeningResult    │  │  RiskSignal         │
│  KYCState           │  │  WatchlistHit       │  │  ScenarioFire       │
│  VerificationDoc    │  │  MatchConfidence    │  │  AlertPayload       │
│                     │  │  PEPRecord          │  │  VelocitySnapshot   │
│  Source:            │  │                     │  │                     │
│  developer-core/    │  │  Source:            │  │  Source:            │
│  compliance/        │  │  sanctions_check.py │  │  tx_monitor.py      │
│  verification/      │  │  pep_check.py       │  │  scenario_registry  │
└─────────┬───────────┘  └──────────┬──────────┘  └──────────┬──────────┘
          │                         │                         │
          └─────────────────────────┴─────────────────────────┘
                       ↓ CustomerProfile (shared kernel)
          ┌─────────────────────────────────────────────────────────────┐
          │               Case Management Context                        │
          │   Alert → Case → L1Review → L2Review → MLRODecision → SAR  │
          │                                                              │
          │   Public model: CasePayload, SARDraft, AuditRecord          │
          │   Source: Marble API (:5002), case_orchestrator              │
          └─────────────────────────────────────────────────────────────┘
```

---

## context.yaml — спецификация bounded context (по аналогии с scenario_registry)

Каждый bounded context будет иметь `context.yaml` в своей директории.
Подход: аналогичен `scenario_registry.yaml` — машинно-верифицируемый контракт.

```yaml
# developer-core/compliance/contexts/sanctions_context.yaml
context_id: "CTX-002"
name: "Sanctions & PEP Screening"
version: "1.0"

public_api:
  - ScreeningResult
  - WatchlistHit

allowed_dependencies:
  - "models.SanctionsSubject"    # shared kernel input
  - "models.RiskSignal"          # shared kernel output
  - "compliance_validator._HARD_BLOCK_JURISDICTIONS"  # read-only reference

forbidden_dependencies:
  - "kyc/"                       # no direct KYC imports
  - "tx_monitor"                 # no TM imports
  - "case_orchestrator"          # no case management imports

shared_kernel_fields:
  - "CustomerProfile.jurisdiction"
  - "CustomerProfile.entity_type"

anti_corruption_adapters:
  - "adapters/sanctions_adapter.py"  # n8n → Python translation layer
```

---

## Anti-Corruption Layers (n8n → Python)

Между n8n workflows и Python AML-движками нет формализованных translation layers.

### Конкретный план

Создать `vibe-coding/src/compliance/adapters/`:

```python
# adapters/kyc_adapter.py — KYC Context ACL
class KYCAdapter:
    """Translates n8n 'KYC Onboarding' webhook payload → KYCContext model."""
    def from_n8n_webhook(self, payload: dict) -> KYCInput:
        return KYCInput(
            customer_id=payload["customerId"],
            name=payload["fullName"],
            jurisdiction=payload.get("countryCode", "GB"),
        )

# adapters/tm_adapter.py — TM Context ACL
class TxMonitorAdapter:
    """Translates n8n 'AML Transaction Monitor' webhook → TransactionInput."""
    def from_n8n_webhook(self, payload: dict) -> TransactionInput:
        return TransactionInput(
            amount_gbp=float(payload["amount"]),
            tx_type=payload.get("type", "wire"),
            ...
        )
```

---

## Copilot ADR Enforcement (.github/copilot-instructions.md)

GitHub Copilot автоматический ADR review на каждом PR:

```markdown
# .github/copilot-instructions.md

## Role: Senior Compliance Architect for BANXE AI Bank

When reviewing any PR that touches `src/compliance/` or `developer-core/compliance/`:

1. Cross-reference against ADR-007..ADR-011 in banxe-architecture/decisions/
2. Check invariants I-1..I-26 in banxe-architecture/INVARIANTS.md
3. Verify bounded context isolation (no cross-context imports per bounded-contexts.md)
4. Flag any change to CLASS_B files (SOUL.md, AGENTS.md) without ADR reference
5. Confirm scenario_registry.yaml changes pass I-1..I-10 invariants

Reject if:
- New engine.id not in closed enum (I-8)
- sanctions_check.py imports from kyc/ directory
- BanxeAMLResult for amount > £10,000 missing ExplanationBundle (I-25)
```

Near-zero setup cost, автоматически на каждом PR.

---

## Enforcement via check-compliance.sh extension

Добавить в `banxe-architecture/validators/check-compliance.sh`:

```bash
# Import boundary check (bounded contexts)
echo "Checking bounded context import boundaries..."
if grep -rn "from kyc" vibe-coding/src/compliance/sanctions_check.py 2>/dev/null; then
  echo "FAIL: sanctions_check.py imports from KYC context"
  exit 1
fi
if grep -rn "from sanctions" vibe-coding/src/compliance/tx_monitor.py 2>/dev/null; then
  echo "FAIL: tx_monitor.py imports from Sanctions context"
  exit 1
fi
echo "OK: bounded context isolation verified"
```

---

## Текущее состояние vs. Цель

| Что | Сейчас | Цель |
|-----|--------|------|
| bounded-contexts.md | ✅ этот файл | + context.yaml в коде |
| Anti-Corruption Layers | ❌ нет adapters/ | adapters/ в Sprint 2 |
| Import boundary check | ❌ нет | check-compliance.sh extension |
| Copilot ADR review | ❌ нет | .github/copilot-instructions.md |
| context.yaml loader | ❌ нет | аналог registry_loader.py |
