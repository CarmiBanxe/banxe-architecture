---
il_ts: 2026-07-09T15:00:18Z
session_id: agent-factory-adopt104-guardrails-ai
source: CEO
status: PROPOSED
---
### ADOPT #104 — Guardrails.ai LLM-input validators → completes LLM-safety perimeter (cluster-1) (ESCALATE-IMMEDIATE, FCR 0.80) — PROPOSED

Third and LAST ADOPT sprint of SP41 roadmap §4 cluster-1 (LLM-safety perimeter). Defines Guardrails.ai
OSS declarative structured-output validators at the LLM-input/I-O boundary, composing with NeMo (#65)
conversational rails — handoff OD-LLM-SECURITY. **ADR-102 Duplication Audit:** repo-wide search found
NO prior LLM-input semantic validator; existing validators (`schemas/validate_schemas.py` JSON-schema,
`scripts/mrm-validate.sh` MRM, `.github/scripts/validate_mermaid.py` mermaid, `validators/check-
compliance.sh` compliance-doc, `tests/best-decision/validator.py` decision-record) are all NON-LLM and
DISTINCT. Verdict: `governance/runtime-guardrails-policy.md` = **EXTEND** (new "LLM-input validation
layer (Guardrails.ai)" section + follow-up/refs); `governance/owasp-llm-top10-checklist.md` = **EXTEND**
(LLM02 + LLM05 rows → input/output-validated-by Guardrails.ai #104, pointer only); existing non-LLM
validators + NeMo policy + prompt-canon = **KEEP** (referenced, NOT rewritten). Layer distinction:
Guardrails.ai = declarative validators on STRUCTURED LLM I/O (Pydantic-style schemas, value/format/PII
checks, structured re-ask) answering "does this payload conform?"; NeMo = conversational input/output/
dialog rails answering "is this call/flow permitted?" — different roles at adjacent points, they COMPOSE
(no XOR, per ADR-166 role-scoping). Closes OWASP LLM05 (improper output handling — schema-validated,
re-ask/reject) and LLM02 (sensitive-info disclosure — PII/secret validators at the boundary). Full
perimeter defense-in-depth: prompt-canon authoring → Guardrails.ai schema validation → NeMo policy rails
→ litellm audit hook. CONSTRAINT: PROPOSED/doc only — NO validator code, NO Guardrails.ai import, NO CI
wiring (all follow-up: validator specs as governed-config, :4000 wiring behind flag, CI lint+smoke, HITL
routing). Guardrails.ai referenced NOT imported. Config-over-hardcoding: all validator params (value
sets, format regexes, PII lists, re-ask limits, on-fail action) = governed-config proposals (CLAUDE.md
§10). Cluster-1 LLM-safety perimeter (#64 OWASP mapping + #65 NeMo rails + #104 Guardrails.ai validators)
COMPLETE after this merges. Refs: ADOPTION-FINALIZATION-SP41 (#104), OD-LLM-SECURITY, #64 owasp-llm-
top10-checklist, #65 nemo-guardrails runtime-guardrails-policy, ADR-102, ADR-166, ADR-117, ADR-130/127,
I-27/I-24/I-28.
