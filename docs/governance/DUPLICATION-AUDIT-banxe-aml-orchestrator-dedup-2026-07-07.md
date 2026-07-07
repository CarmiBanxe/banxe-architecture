# Duplication Audit — banxe_aml_orchestrator passport dedup (ADR-102)

**Date:** 2026-07-07 · **Authority:** explicit operator ruling (corrected) · **Status:** PROPOSED (prepare-only; no activation)

## Operator ruling (corrected)
The initial ruling ("one agent, canonical RED·L2") was corrected after full grounding of all three passports revealed
**two distinct agents**, not one. Corrected ruling: **TWO agents confirmed; dedupe ONLY `banxe_aml_orchestrator`'s two
passports.**

## Two-agent shape (preserved — NOT merged)
- **`aml_orchestrator`** — Level-2 **sub-orchestrator** (risk scoring across Layer-3 adapters watchman/jube/yente);
  `allowed_callers: [banxe_aml_orchestrator]`. Passport `agents/passports/aml_orchestrator.yaml` (L2/AMBER) is a
  **separate agent — UNTOUCHED** by this dedup.
- **`banxe_aml_orchestrator`** — Level-1 **top orchestrator**; `allowed_callees` include `aml_orchestrator`.
- **Pipeline edge `banxe_aml_orchestrator -> aml_orchestrator` is preserved** (canonical still lists `aml_orchestrator`
  in `allowed_callees`).

## The real duplication (resolved here)
`banxe_aml_orchestrator` had **two passports** describing the same `agent_id` in different formats and with conflicting
attributes:

| passport | format | level | trust_zone | change_class |
|---|---|---|---|---|
| `banxe_aml_orchestrator.yaml` (root) | dev (ports/skills/callees) | 1 | AMBER | CLASS_B |
| `aml/banxe_aml_orchestrator.yaml` | governance (SMF17/HITL) | — | RED | MAJOR |

## Decision
- **Canonical = `agents/passports/aml/banxe_aml_orchestrator.yaml`** (governance format), set to **RED · L1-top · autonomy L3**.
- **Merged in from root** (fields root uniquely carried — no capability dropped): `name`, `version`, `level`,
  `bounded_context`, `capabilities`, `ports` (PolicyPort/EmergencyPort/AuditPort/DecisionPort), `allowed_callers` (`[]`),
  `allowed_callees` (`aml_orchestrator`, `sanctions_check`, `tx_monitor`, `crypto_aml`), `invariants` (I-21..I-25),
  `fca_references`, `aigf_risks`, and the full skill matrix.
- **Kept from governance passport:** `autonomy_level: L3`, `human_double` (HEAD_OF_FINCRIME + MLRO), `fca_basis` (SMF17),
  `hitl_gates` (SAR/threshold/sanctions), `allowed_actions`, `forbidden_actions` (submit_SAR, PEP, threshold, HITL-matrix),
  `audit` (ClickHouse, PII_PROXY_REQUIRED).
- **Conflicts resolved to the SAFER value:** `trust_zone` RED (> AMBER); `change_class` MAJOR (> CLASS_B); `level` 1 (top).
- **Root passport superseded (NOT hard-deleted):** `agents/passports/banxe_aml_orchestrator.yaml` gets a
  `status: SUPERSEDED` + `superseded_by:` header, retained append-only (I-24). Hard-removal is a separate operator decision.

## Guarantees
- **No capability lost** (union of both, conflicts safer-wins).
- **`aml_orchestrator` (L2 sub) untouched;** the AML pipeline (top->sub) intact.
- **Prepare-only:** identity resolved; the agent is **not activated** (activation = I-27 operator + MLRO, never the factory).
