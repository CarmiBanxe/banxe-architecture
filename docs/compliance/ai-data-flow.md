# AI Data Flow — Banxe EMI On-Prem Inference Architecture

**Status:** Normative
**Date:** 2026-05-11
**Classification:** FCA/EMI audit-ready
**Owner:** Sub-terminal A (draft); Main factory terminal (merge authority)

---

## 1. Governing Constraints

This document is binding under:

| Regulation | Requirement |
|------------|-------------|
| **UK GDPR Art. 46** | Personal data may only be transferred to third countries or international organisations where appropriate safeguards exist. Sending regulated personal data (KYC identifiers, AML flags, transaction IDs, IBANs, national IDs) to an external LLM API constitutes a transfer under Art. 46 without an adequacy decision for inference providers. |
| **FCA PS25/12** | Operational resilience and third-party risk management. AI inference used in regulated workflows must be treated as a material operational dependency. Outages or data exposure at an external provider directly affect FCA-regulated services. |

**Hard rule:** All AI inference for regulated workloads MUST run on-prem (evo1/evo2).
No regulated content may reach an external API provider under any operational condition.

---

## 2. Hardware Pool

| Node | RAM | Role | Regulated workloads allowed |
|------|-----|------|-----------------------------|
| **evo1** | 128GB | On-prem AI master; Ollama `:11434`; Redis | YES — primary inference node |
| **evo2** | 128GB | Production inference worker; large models; fraud classifier | YES — production inference only |
| **Legion** (WSL2) | 64GB | Dev workstation; Claude Code; LiteLLM router | NO regulated workloads; dev only |

Total pool: 256GB RAM, fully on-prem.

---

## 3. Inference Routing — Legion LiteLLM Router

```
┌────────────────────────────────────────────────────────────────┐
│                     LEGION (WSL2 dev)                          │
│                                                                │
│   Developer prompt                                             │
│        │                                                       │
│        ▼                                                       │
│   ┌─────────────────────────────────────────────────────┐     │
│   │           LiteLLM Proxy (:4000)                     │     │
│   │                                                     │     │
│   │   ┌─────────────────────────────────────────────┐   │     │
│   │   │  Guardrail: block-regulated-paths           │   │     │
│   │   │  Keywords: /compliance/ /kyc/ /aml/         │   │     │
│   │   │           kyc_id aml_flag transaction_id    │   │     │
│   │   │           iban national_id                  │   │     │
│   │   │  Action: BLOCK — never reaches any backend  │   │     │
│   │   └──────────────┬──────────────────────────────┘   │     │
│   │                  │ (passes guardrail)               │     │
│   │                  ▼                                  │     │
│   │   ┌─────────────────────────────────────────────┐   │     │
│   │   │  Priority 1: evo1 Ollama                    │   │     │
│   │   │  http://evo1:11434                          │───┼─────┼──► evo1 (on-prem)
│   │   │  timeout: 30s, retries: 2                   │   │     │
│   │   └──────────────┬──────────────────────────────┘   │     │
│   │                  │ (evo1 unreachable or timeout)    │     │
│   │                  ▼                                  │     │
│   │   ┌─────────────────────────────────────────────┐   │     │
│   │   │  Priority 2 (FALLBACK ONLY):                │   │     │
│   │   │  Anthropic Claude API                       │───┼─────┼──► External API
│   │   │  NON-REGULATED CONTENT ONLY                 │   │     │   (internet)
│   │   └─────────────────────────────────────────────┘   │     │
│   └─────────────────────────────────────────────────────┘     │
└────────────────────────────────────────────────────────────────┘

NOTE: evo2 is NEVER a backend for Legion router.
      Dev traffic must not reach evo2:* under any condition.
```

---

## 4. Guardrail Enforcement

The `block-regulated-paths` guardrail fires **during_call** (before routing decision).
A blocked request is returned immediately with an error response; it does not fall
through to either evo1 or Anthropic.

Blocked keywords (exact match, substring):

```
/compliance/    /kyc/    /aml/
kyc_id          aml_flag    transaction_id
iban            national_id
```

This list is the minimum. Operators MAY extend it via the LiteLLM config
`block_request_if_contains` list. Shortening the list requires main factory terminal
approval and an IL entry.

---

## 5. Filesystem-Level Restrictions (Legion WSL2)

The following paths are **NOT mounted** into Legion WSL2 and **NOT symlinked**
into `~/banxe-dev/` or any sub-path thereof:

```
/data/kyc/
/data/transactions/
/data/aml/
```

Enforcement: these paths do not exist on Legion's filesystem. No NFS/CIFS mount,
no Docker volume mount, no WSL2 `/mnt/` bind referencing these paths is permitted.

Verification command (run on Legion):
```bash
mount | grep -E "(kyc|transactions|aml)" && echo "VIOLATION" || echo "CLEAN"
ls -la ~/banxe-dev/ | grep -E "(kyc|transactions|aml)" && echo "SYMLINK VIOLATION" || echo "CLEAN"
```

---

## 6. Anthropic Claude — Permitted Use Scope

| Context | Permitted | Rationale |
|---------|-----------|-----------|
| Dev code assistance (no customer data) | YES | No regulated content |
| Drafting documentation (no PII) | YES | No regulated content |
| Compliance doc review containing real KYC data | NO | UK GDPR Art. 46 block |
| AML flag analysis | NO | Regulated content |
| Transaction narrative analysis with real IBANs | NO | Regulated content |
| Fraud classifier input (real customer behaviour) | NO | Regulated content; evo2 only |

Anthropic Claude is accessed exclusively via the LiteLLM proxy on Legion.
Direct API calls bypassing the proxy are prohibited (deny rule in `settings.local.json`
enforces this at the Claude Code tool level).

---

## 7. Audit Trail

All inference requests routed through LiteLLM are logged to:
- LiteLLM proxy stdout (development)
- Future: ClickHouse `banxe.ai_inference_log` table (production integration, P1 item)

Blocked requests (guardrail hits) are logged with reason `block-regulated-paths`
and timestamp. These logs are NOT sent to any external service.
