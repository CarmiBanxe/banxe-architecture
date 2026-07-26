# BANXE-SECURITY-OWASP.md — OWASP LLM Top-10 → BANXE Mitigations

> **STATUS: ACTIVE in SANDBOX (TRAINING data) per operator Promotion Gate 2026-07-26 — prod activation remains gated.**
> Source: engine reference rebuilt v2 (block F) + analytics #1 (OWASP Agents ASI06–ASI10), session 2026-07-26 (ENGREF01).
> Context justifying runtime gates: State-of-AI-Agents 2026 — **81% of teams are past planning, only 14.4% have full security**.
> Companion: `config/gates/confidence-thresholds.yaml` (PROPOSED), `BANXE-ENGINE-MATH.md`, ADR-171.

## 1. Mitigation map

| OWASP LLM Top-10 risk | BANXE mitigation |
|---|---|
| Prompt Injection | NeMo Guardrails + input sanitization (incl. KYC-document sanitization before any L2 agent) |
| Insecure Output Handling | structured outputs + JSON schema validation (Rich Card / tool-schema contracts) |
| Training Data Poisoning | FATE isolated training (federated, training moves to data) |
| Model DoS | rate limiting + Temporal timeout workflows |
| Supply Chain | GitHub Dependabot + SBOM (existing `sbom.yml` / `osv-scanner.yml` workflows remain authoritative) |
| Sensitive Info Disclosure | VaultGemma differential privacy + PII redaction before LLM |
| Insecure Plugin Design | MCP tool sandboxing + permission scoping (least-privilege per tool) |
| Excessive Agency | confidence threshold gates (**0.90 prod**, see gates config) |
| Overreliance | HITL (mandatory; Finance Agent Benchmark ≈57% ⇒ agents are NOT autonomous in finance) |
| Model Theft | self-hosted LLM (DeepSeek/Ollama, local-only) for sensitive data |

## 2. Multi-agent risks (OWASP Agents ASI06–ASI10)

- **Cascading failures / rogue agents** → mTLS + zero-trust between agents, circuit breakers (v3-E),
  **SOFAStack-style bulkhead isolation** between rooms/domains (complements circuit breakers: a failing
  agent cluster must not cascade), loop-guard + per-case budget cap.
- Adjacent existing control plane: `config/runtime_gate/agent-budget-policy.yaml` (ADR-030 §9, owned by the
  redgate/red-budget tracks) — this document does NOT modify it; integration is a cross-ref in ADR-171.

## 3. Placement rules

- Input guardrails (request filter) / Output guardrails (PII, unauthorized advice) / Action guardrails
  (limits, sanctions, AML — before any banking action) — three distinct layers, policy-as-code, versioned
  outside prompts (Configuration-over-Hardcoding, CLAUDE.md §10).
- Jurisdiction/supply-chain review is mandatory at license-audit for all foreign-origin components
  (sanctions canon: RU/IR/KP/BY/SY prohibited; other origins → review, e.g. DeepSeek weights allowed
  ONLY self-hosted/local in the PII contour).

---
*ENGREF01 | 2026-07-26 | PROPOSED, no activation.*
