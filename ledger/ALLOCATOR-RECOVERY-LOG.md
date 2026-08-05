# ALLOCATOR-RECOVERY-LOG (append-only, administrative — LEDGER-PATH-TAXONOMY 2026-08-05)

Administrative numbering-lifecycle record. NOT canon content; no IL shard required
(guardian_ledger_gate.sh ADMIN_RE). Corrections by superseding entries only.

---

## 2026-08-05 — CONTROL OUTAGE: IL-allocator DOWN 3/3

- **Declared:** 2026-08-05 (factory, SPRINT0-UNFREEZE-PATH; ruling Fable-5 + Codex
  INDEPENDENT 2026-08-05).
- **State:** Redis allocator unreachable on all 3 candidates (local 127.0.0.1:6379,
  evo1 100.68.102.48:6379, evo2). ADR-143-B relocation NOT completed.
- **Impact:** ledger mint FROZEN. Blocked: batch-1 (9 donor-import records),
  payment-core import slot record, PREPARED shard regeneration, publication-gate
  item 10. NOT blocked: #1198 after guardian-gate fix (#1200), publication-gate
  prep, owner escalations, UUID remediation.
- **Fail-closed honored:** factory REFUSED local bypass (BANXE_IL_ALLOCATOR=local
  = IL-827 duplicate class). Missed RTO = escalation + stop of dependent changes,
  NEVER a local allocator.

### Escalation calendar (T0 = declaration)
| T | Action | Owner |
|---|--------|-------|
| T0 | Control outage declared, this record | factory |
| T+1h | Technical escalation to Terminal A (Redis/platform owner) | factory → A |
| T+4h | Management/control-owner escalation; snapshot-restore decision | operator |
| T+24h | Formal continuity decision; release status; regulatory assessment | operator |

### Recovery runbook (ALL steps mandatory before return to service)
1. **Authoritative source:** restore counter ONLY from evo RDB/AOF snapshot with
   proven freshness (restoration, not replacement). No reconstructed counters.
2. **Fencing:** old node fenced — guarantee single writer before start.
3. **Watermark reconciliation:** counter value verified >= max of ALL committed
   shard IDs across canon (IL-SEQUENCE.json + in-flight PR evidence).
4. **Test mint:** one throwaway allocation verified monotonic, logged here.
5. **Journal:** restore actor, source snapshot ID/time, counter value before/after
   — appended to this log.
6. Only then: unfreeze mint queue (order: PREPARED shard regeneration → batch-1 →
   payment-core slot).
