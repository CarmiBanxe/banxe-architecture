# OWASP LLM Top-10 (2025) — BANXE Intake Checklist

- **Status:** PROPOSED (governance-doc; ADOPT #64, SP41 roadmap §4 cluster-1)
- **Date:** 2026-07-09 | **Handoff:** OD-LLM-SECURITY
- **FCR:** 0.85 (ESCALATE-IMMEDIATE) per `governance/ADOPTION-FINALIZATION-SP41.md` §1.1/§4
- **Scope:** verifiable intake checklist for any OSS/LLM dependency or LLM-using capability.
  **Additive** per **ADR-102** — maps each OWASP risk to an **existing** BANXE control (pointer-first,
  no control restated). Nothing here wires runtime code or a CI gate; that is a follow-up once the
  runtime guardrail ADOPTs land (**#65 NeMo-Guardrails**, **#104 Guardrails.ai**).

## How to use (proposed)

At OSS/LLM dependency intake (and at any new LLM-using capability), the reviewer records **PASS /
GAP / N-A** for each of LLM01–LLM10 below, citing the BANXE control that covers it. A **GAP** on any
item blocks promotion to prod and routes to **OD-LLM-SECURITY** for a mitigation IL. Enforcement is
manual/governance now; the CI wiring is deferred (see the mapping's *Enforcement status* column in
`docs/policies/OSS-SUPPLY-CHAIN-POLICY.md` §6).

> **Config-over-hardcoding (CLAUDE.md §10):** any threshold implied below (e.g. budget caps, entropy
> limits, rate limits) is a **governed-config proposal** and lives in the referenced config, not here.

## Checklist — LLM01…LLM10 → BANXE control

| # | OWASP LLM risk (2025) | BANXE control (existing, pointer-first) | Reviewer verdict |
|---|-----------------------|-----------------------------------------|------------------|
| **LLM01** | Prompt Injection | Prompt-canon (`PROMPT-CANON-DEVELOPER.md` / `PROMPT-CANON-PROJECT.md`) authoring-time; **runtime-enforced-by: NeMo-Guardrails input rails (#65, proposed — `governance/runtime-guardrails-policy.md`)**; output-val #104 pending | ☐ PASS ☐ GAP ☐ N-A |
| **LLM02** | Sensitive Information Disclosure | LLM-input/output validation **pending #104 Guardrails.ai**; secrets governance (`ACCESS-AND-SECRETS.md`, gitleaks); redaction canon | ☐ PASS ☐ GAP ☐ N-A |
| **LLM03** | Supply Chain | `docs/policies/OSS-SUPPLY-CHAIN-POLICY.md` (SBOM/SCA/license/third-party register) — the primary control; this checklist is its LLM-facing extension | ☐ PASS ☐ GAP ☐ N-A |
| **LLM04** | Data & Model Poisoning | OSS provenance + pinning/SHA (OSS-SUPPLY-CHAIN §2); model-tier registry (`ai-cost-policy` §1); sandboxed-eval for high-risk sources | ☐ PASS ☐ GAP ☐ N-A |
| **LLM05** | Improper Output Handling | **runtime-enforced-by: NeMo-Guardrails output rails (#65, proposed — `governance/runtime-guardrails-policy.md`)**; input-validators #104 pending; structured-output contracts; no-authority canon (ADR-130/127) | ☐ PASS ☐ GAP ☐ N-A |
| **LLM06** | Excessive Agency | Agent authority canon (`.claude/rules/agent-authority.md`); HITL gate (I-27; `services/hitl/hitl_service.py`); no autonomous prod mutation | ☐ PASS ☐ GAP ☐ N-A |
| **LLM07** | System Prompt Leakage | Prompt-canon separation of system/context; `litellm-guardrail-audit-hook` audit trail; least-context passing | ☐ PASS ☐ GAP ☐ N-A |
| **LLM08** | Vector & Embedding Weaknesses | Vector-store governance (ChromaDB in-use / Qdrant PLANNED); perimeter isolation (ADR-117 — no cross-perimeter store) | ☐ PASS ☐ GAP ☐ N-A |
| **LLM09** | Misinformation | Decision-lineage / explainability (`governance/decision-lineage/README.md`, EU AI Act Art.13); HITL review for L2+ (HITL confidence tiers) | ☐ PASS ☐ GAP ☐ N-A |
| **LLM10** | Unbounded Consumption | `governance/ai-cost-policy/` — per-agent budget table (§2), monthly hard-cap (§3), per-call anomaly + hard-stop (§4/§6); rate-limit policy (ADR-030) | ☐ PASS ☐ GAP ☐ N-A |

## References

- `governance/ADOPTION-FINALIZATION-SP41.md` — ADOPT #64 (ESCALATE-IMMEDIATE, FCR 0.85), roadmap §4 cluster-1.
- `docs/policies/OSS-SUPPLY-CHAIN-POLICY.md` §6 — the OWASP-LLM supply-chain mapping this checklist verifies.
- `governance/ai-cost-policy/README.md` §7 — the OWASP-LLM checklist gate at dependency intake.
- Runtime complements: **#65 nemo-guardrails-runtime-safety** (PROPOSED — `governance/runtime-guardrails-policy.md`, LLM01/LLM05 rails); **#104 guardrails-ai-validators** (pending ADOPT).
- ADR-102 (additive / pointer-first), ADR-117 (perimeter), ADR-130/127 (no authority), I-27/I-24/I-28.
