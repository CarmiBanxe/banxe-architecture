# Runtime Guardrails Policy — NeMo-Guardrails runtime layer (ADOPT #65)

- **Status:** PROPOSED (governance-doc; ADOPT #65, SP41 roadmap §4 cluster-1)
- **Date:** 2026-07-09 | **Handoff:** OD-LLM-SECURITY
- **FCR:** 0.80 (ESCALATE-IMMEDIATE) per `governance/ADOPTION-FINALIZATION-SP41.md` §1.1/§4
- **Scope:** define the **runtime** LLM input/output policy-enforcement layer (**NVIDIA NeMo
  Guardrails**) as an **ADDITIVE** control per **ADR-102**. Pointer-first — existing controls are
  referenced, not restated. **No runtime code, no Colang configs, no LiteLLM wiring, no CI gate in
  this PR** — those are explicit follow-ups (see *Follow-up*). NeMo is **referenced, not imported**
  (novelty-collection convention).

## Why a runtime layer (and why it is not a duplicate)

BANXE already governs the LLM surface at two points; NeMo occupies a **third, distinct** point:

| Layer | When | What it does | Artefact |
|-------|------|--------------|----------|
| **Prompt-canon** | **authoring-time** | how prompts/system-context are written (separation, least-context, canon) | `PROMPT-CANON-DEVELOPER.md` / `PROMPT-CANON-PROJECT.md` — **KEEP** |
| **Runtime rails (NeMo)** | **request-time** | intercepts each call: input/output/dialog rails enforce policy live | **this policy — NEW** |
| **Audit hook** | **post-hoc** | records the call for the audit trail | `patches/litellm-guardrail-audit-hook-2026-05-12.py` — **KEEP** |

Prompt-canon says *how to write*; the audit hook says *what happened*; **NeMo enforces at the moment
of the call**. Different times, different mechanisms — additive, not overlapping.

## The three rails (proposed)

1. **Input rails** — inspect the incoming prompt **before** it reaches the model: prompt-injection /
   jailbreak detection, off-topic / disallowed-intent rejection. Closes **OWASP LLM01
   (Prompt Injection)** at runtime — the complement prompt-canon cannot enforce at authoring-time.
2. **Output rails** — inspect the model response **before** it is returned: PII / sensitive-data
   filtering, policy compliance, hallucination / fact-check gating, structured-output conformance.
   Closes **OWASP LLM05 (Improper Output Handling)** at runtime (alongside #104 Guardrails.ai
   validators at the input-validation layer).
3. **Dialog rails** — constrain multi-turn flow to permitted conversational paths (Colang-defined),
   preventing agency drift across a session (supports **LLM06 Excessive Agency** governance).

## How it complements #64 (OWASP-LLM-Top10) and #104

- **#64 checklist** (`governance/owasp-llm-top10-checklist.md`) marked LLM01 / LLM05 runtime
  enforcement as *pending*; **this policy is the named runtime enforcer** for those two rows
  (updated by this PR to `runtime-enforced-by: NeMo-Guardrails (#65, proposed)`).
- **#104 Guardrails.ai** (ADOPT #104, PROPOSED — defined in *LLM-input validation layer* below) sits
  at the **LLM-input validation / structured-output** layer; NeMo sits at the **request/response
  rails** layer. They **compose** — #104 validates payload shape, NeMo enforces policy rails — and
  are **not** two substrates of the same role (no XOR conflict; cf. ADR-166 role-scoping).

## LLM-input validation layer (Guardrails.ai — ADOPT #104, PROPOSED)

> Added 2026-07-09 per SP41 roadmap §4 cluster-1 (ADOPT #104 guardrails-ai-validators,
> ESCALATE-IMMEDIATE, FCR 0.80 — the **last** of cluster-1, completing the LLM-safety perimeter;
> handoff **OD-LLM-SECURITY**). **Additive** per ADR-102 — pointer-first, no restate. **Guardrails.ai
> is referenced, not imported.**

**Guardrails.ai** provides **declarative structured-output validators** at the **LLM I/O boundary** —
a distinct layer from NeMo's conversational rails:

| Layer | Mechanism | Enforces |
|-------|-----------|----------|
| **Guardrails.ai** (#104) | declarative validators on **structured** LLM I/O — Pydantic-style schemas, value/format/range checks, PII detectors, structured re-ask on failure | payload **shape & content** conform to a schema/policy before use |
| **NeMo rails** (#65) | **conversational** input/output/dialog rails (Colang) | request/response **policy & flow** at call time |

**They compose, they do not compete (no XOR).** Guardrails.ai answers *"does this structured payload
conform?"*; NeMo answers *"is this call/flow permitted?"*. Different roles at adjacent points — the
ADR-166 role-scoping that permits distinct-role layers to coexist applies here too. Wiring both is the
defense-in-depth completion of the LLM-safety perimeter (prompt-canon authoring → Guardrails.ai schema
validation → NeMo policy rails → audit hook).

**What it closes:**
- **OWASP LLM05 (Improper Output Handling)** — schema-validated structured output; malformed/policy-
  violating responses are re-asked or rejected (complements NeMo output rails).
- **OWASP LLM02 (Sensitive Information Disclosure)** — PII/secret validators on input and output
  reject or redact sensitive fields at the boundary (complements secrets governance + redaction canon).

**Distinct from existing validators.** The repo's `schemas/validate_schemas.py`, `scripts/mrm-validate.sh`,
`.github/scripts/validate_mermaid.py`, `validators/check-compliance.sh`, and
`tests/best-decision/validator.py` are **non-LLM** (JSON-schema / MRM / mermaid / compliance-doc /
decision-record validation). Guardrails.ai validates **LLM-generated semantic payloads** — a new,
non-overlapping validator role. Those validators are **KEEP** (referenced, not touched).

**Config-over-hardcoding.** Every validator (allowed value sets, format regexes, PII match lists,
re-ask limits, on-fail action) is a **governed-config proposal** (CLAUDE.md §10) — held in the
validator's declarative config under version control when wired, not in code or this policy.

## No-authority & perimeter (unchanged)

- Rails are **read/deny only w.r.t. authority**: a rail may **block or redact** a call, never grant a
  permission or mutate code / ledger / prod / dispatch (ADR-130 / ADR-127; I-27 HITL for any block
  that affects a customer-facing decision).
- Runtime rails run **within a single perimeter** (factory OR project); no cross-perimeter rail
  sharing (ADR-117).

## Config-over-hardcoding

Every rail threshold (injection-score cutoff, PII match set, hallucination-gate confidence, allowed
dialog paths) is a **governed-config proposal** (CLAUDE.md §10) — it will live in the rail's Colang /
YAML config under version control when wired, **not** in code and **not** in this policy.

## Follow-up (NOT this PR)

1. Colang rail configs (input/output/dialog) **and** Guardrails.ai validator specs (schemas/PII/format)
   as governed-config, per perimeter.
2. LiteLLM `:4000` integration wiring (NeMo rails + Guardrails.ai validators in the request path) —
   behind a flag, staged.
3. CI gate: rail-config + validator-spec lint + a rails/validator smoke test; promote
   LLM01/LLM02/LLM05 from *manual* to *CI-enforced* in `docs/policies/OSS-SUPPLY-CHAIN-POLICY.md` §6
   once wired.
4. HITL routing for rail/validator blocks on L2+ compliance decisions (I-27).

## References

- `governance/ADOPTION-FINALIZATION-SP41.md` — ADOPT #65 (ESCALATE-IMMEDIATE, FCR 0.80), roadmap §4 cluster-1.
- `governance/owasp-llm-top10-checklist.md` — LLM01 / LLM05 rows now name this runtime enforcer.
- `PROMPT-CANON-DEVELOPER.md` / `PROMPT-CANON-PROJECT.md` — authoring-time canon (KEEP; not rewritten).
- `patches/litellm-guardrail-audit-hook-2026-05-12.py` — post-hoc audit trail (KEEP).
- `docs/agent-engine-dossier/SRC-07-constraints-guardrails.md` — constraints dossier (pointer added).
- **#104 guardrails-ai-validators** (ADOPT #104, PROPOSED) — the LLM-input validation layer defined
  above; completes cluster-1 LLM-safety perimeter. ADR-102 (additive/pointer-first), ADR-117
  (perimeter), ADR-130/127 (no authority), ADR-166 (role-scoped XOR analogy), I-27/I-24/I-28.
