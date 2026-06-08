# BANXE Governance Schemas

Executable **JSON-Schema (Draft 2020-12)** contracts that make BANXE governance
**machine-validatable** instead of prose-only. They mirror the draft/style of the
pre-existing `agent_passport.schema.json` and `scenario_registry.schema.json` in this
directory.

> **Why these exist (audit gap #5):** governance for the agent fleet was prose-only —
> ADR-046/047/048 described the lineage/cost/process artefacts but nothing could
> *validate* a real record against them. These three schemas close that gap: the
> artefacts the 9 client-facing agents emit can now be checked against a schema, not
> just a paragraph.

## Schema → ADR → what it validates

| Schema | ADR | Validates | Who/what produces it |
|---|---|---|---|
| [`agent_decision_record.schema.json`](agent_decision_record.schema.json) | **ADR-046** Decision Lineage Schema | The `AgentDecisionRecord` emitted per consequential L2 decision — `_lineage.py` is the runtime field source of truth | **All 9 client-facing agents** across `banxe-payment-core` + `banxe-emi-stack` (e.g. `mlro_agent`, `aml_check_agent`, `sanctions_check_agent`, …). One consequential decision → one record. |
| [`cost_cap.schema.json`](cost_cap.schema.json) | **ADR-047** AI Cost Governance Policy | The `CostCap` config: hard per-request and per-window caps in **both** token and money dimensions, plus the per-agent budget map | Cost-governance config-as-data (CLAUDE.md §10); the agent passport is the budget unit (ADR-047 D1). Enforced at the LiteLLM gateway (ADR-043) + L3 plane. |
| [`process_ref.schema.json`](process_ref.schema.json) | **ADR-048** S13-00 Business Process Repository | The resolvable `{process_id, version}` handle an L1 intent resolves to before L2 executes | The format **S3 / `banxe-business-processes`** (canonized `CarmiBanxe/banxe-business-processes`, ArchiMate 3.2) must produce. Carried by ADR-046 lineage + ADR-047 cost as the shared key. |

The `agent_decision_record` schema validates the lineage records of **all nine
client-facing agents** in both `banxe-payment-core` and `banxe-emi-stack`.

## SPEC-vs-RUNTIME honesty note (`immutable_storage_ref`, `input_tokens`, `output_tokens`)

ADR-046 **prose** (D2) marks `immutable_storage_ref` as **required / NOT NULL**. The
**code/runtime** (`_lineage.py` via the DecisionRecorder) currently emits it — together
with the §D5-additive `input_tokens` / `output_tokens` — as **nullable, default `null`**,
because the DecisionRecorder **ClickHouse immutable sink is not yet live** (audit gap #4).

These schemas deliberately reflect **runtime reality** (nullable) rather than the ADR
target, with a documented upgrade path in each field's `description`:

> **When the immutable/cost-metering sink lands (ADR-046 §D6 / Terminal-A), these three
> fields become REQUIRED and non-null and the schema MUST be tightened to match.**

This is tracked as an **open item** in `INSTRUCTION-LEDGER.md` (IL-156). Validating
against the ADR's stated target today would reject every real record the agents
currently emit — so the schema follows the runtime and names the gap, rather than
silently diverging from either.

## R-SEC

No field of any record/config validated here may carry secret material (API keys,
tokens, credentials, LiteLLM gateway keys) or raw PII. `reasoning_summary` is a
PII-minimized, regulator-legible rationale (ADR-016), **not** raw chain-of-thought and
**not** a dump of client personal data. Each schema's top-level `description` restates
this.

## Validation proof

`banxe-architecture` is a docs/governance repo with **no pytest harness**, so the proof
is the self-contained script [`validate_schemas.py`](validate_schemas.py) plus the
samples in [`examples/`](examples/). It:

1. checks each file is a valid Draft 2020-12 schema (`check_schema`);
2. validates each `examples/*.json` sample against its schema — the
   `agent_decision_record` sample is built to **`_lineage.py` defaults** (§D5 fields
   `null`, `confidence_score` in the AUTO band, `human_reviewed_by: null`);
3. proves the ADR-046 confidence/HITL `if/then` rule **both** rejects a sub-0.90
   decision with `human_reviewed_by: null` **and** accepts the same decision once a
   reviewer is present.

```console
$ python3 schemas/validate_schemas.py
PASS  agent_decision_record.schema.json        <- agent_decision_record.example.json
PASS  cost_cap.schema.json                     <- cost_cap.example.json
PASS  process_ref.schema.json                  <- process_ref.example.json
PASS  agent_decision_record if/then     <- confidence<0.9 requires human_reviewed_by
PASS  agent_decision_record if/then     <- confidence<0.9 + reviewer accepted

All governance-schema proofs passed.
```

**Limitation:** the proof runs on demand (and in any environment with `jsonschema`
installed); it is **not yet wired into `.github/workflows/ci.yml`** because this change
set is scoped to `schemas/*` + the IL entry only. Adding a `schema-validate` CI job is a
follow-up (noted as an open item in IL-156).
