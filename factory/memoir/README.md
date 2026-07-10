# factory/memoir — versioned agent memory (factory-pilot MVP, gated)

Implements **ADR-165** (HOW) under the **ADR-137 / ADR-136** envelope and the eight
`MEMOIR-PILOT-PRECOND-01..08` contracts. **Own implementation of the concept** — no
import of `github.com/zhangfengcdt/memoir`, no `agentmemory` instance dependency, no
emi-stack/project code. **PROPOSED / gated:** this package is code + tests; it does
**not** activate production capture.

> Memory VCS operates on **content only**. It confers **no authority** (PRECOND-07):
> branch/commit/merge/rollback/checkout/blame never touch code, ledger, prod, or dispatch.

## Design (per ADR-165 §1–9)
- **Storage** — git plumbing over an **isolated bare memory-repo** (`hash-object` →
  `write-tree` → `commit-tree` → `update-ref`, temp index, no working tree). **Redact →
  THEN commit:** raw values are never written, so history/blame/checkout/rollback can only
  return redacted content.
- **Redaction (fail-closed, PRECOND-01)** — `RegexEntropyRedactor` (mirrors the emi-stack
  `PresidioRedactor` *pattern* via a `PiiRedactorPort` seam; no cross-perimeter import).
  Masks EMAIL / IBAN(mod-97) / CARD(Luhn) / SORT_CODE / PHONE / secret-prefixes / JWT /
  `.env` values / high-entropy spans. **RED-zone → DROP** (whole record). Any uncertainty
  (unknown class / parser failure / engine error/timeout / gray-band entropy) ⇒ `store()`
  **refuses, persists nothing** (deny-by-default).
- **Retention (PRECOND-02)** — `config/memoir/retention.yaml` (`memoir-retention/v1`).
  Fail-closed: absent/unparseable/unbounded/invalid ⇒ no start, no writes. On-write
  eviction + explicit `purge` sweep bound the **live recallable set** (append-only history
  preserved per ADR-059; PII-safe because redaction runs at write).
- **XOR (PRECOND-04)** — config `engine:` key + `scripts/check-memory-xor.sh` (CI) +
  runtime single-registry (refuses a 2nd engine). Ledger (ADR-059) stays source of truth.
- **Perimeter (PRECOND-05)** — factory fork only; project fork disabled by default; the
  memory-repo may not live inside a code checkout (`assert_isolated`).
- **Versioning** — git-native; **rollback = a new commit (revert)**, never a history rewrite.

## CLI (no daemon / FastAPI / MCP — Outcome-C only)
```bash
python -m factory.memoir.cli --repo <bare.git> store <key> <content>
python -m factory.memoir.cli --repo <bare.git> recall <entry> [--ref REF]
python -m factory.memoir.cli --repo <bare.git> checkout <entry> <ref>
python -m factory.memoir.cli --repo <bare.git> blame <entry>
python -m factory.memoir.cli --repo <bare.git> branch <name> [--from SRC]
python -m factory.memoir.cli --repo <bare.git> rollback <entry> <to_ref>
python -m factory.memoir.cli --repo <bare.git> purge
bash scripts/check-memory-xor.sh .          # XOR CI guard
python -m pytest factory/memoir/tests -q    # T01–T15
```

## Acceptance = ADR-137 8-precondition matrix (T01–T15), NOT ADR-135
`tests/`: T01 redaction-leak · T02 redaction fail-closed · T03 uncertainty-drop · T04
RED-zone drop-not-mask · T05 semantic-path · T06 history-no-raw · T07 retention-bound ·
T08 hard-cap · T09 config fail-closed · T10 replay-scope · T11 replay-no-exec · T12 XOR ·
T13 factory-only · T14 no-authority-mutation · T15 append-only. **ADR-135's held-out gate
governs only expansion beyond the pilot (PRECOND-08: separate ADR + operator + IronClaw).**

## Status
PROPOSED / gated. No production capture, no session-hook, no cross-perimeter replay.
Activation is a separate operator-gated step.
