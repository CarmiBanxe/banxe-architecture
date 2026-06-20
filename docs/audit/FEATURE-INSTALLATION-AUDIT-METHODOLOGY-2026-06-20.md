# Feature-Installation Audit — Methodology (2026-06-20)

Read-only methodology to verify whether a roadmap feature is truly **installed**, not just governed-on-paper. Audit only — no feature code is changed.

## 3-Level Installation Model

| Level | Question | Evidence source |
|-------|----------|-----------------|
| **L1 GOVERNANCE** | Does an ADR / passport / GAP / policy exist? (what our sprints produced) | banxe-architecture (decisions/, docs/adr/, GAP-REGISTER, SAD, ledger) |
| **L2 CODE** | Does a real implementing module exist in a code-repo? | banxe-emi-stack / banxe-payment-core / crypto-ops-monitor / braslina (services/*, api/*, tests/*) |
| **L3 WIRED / LIVE** | Is the code integrated, tests green, NOT stub/scaffold, no blocked API-key? | tests pass + no STUB/scaffold markers + no key-gated go-live |

**Per-feature record:** `L1 ref (ADR/GAP)` · `L2 evidence (repo path + tests)` · `L3 status (live / STUB / blocked)` · `gap-delta` (what's missing to reach L3).

**Installation % (per feature):** L1 only = 33% · L1+L2 = 66% · L1+L2+L3 = 100%. Blocked-on-key counts as L2 done / L3 gated.

## Method steps
1. Enumerate features (GAP-064..074 + SP-CO2/SP-BM2/SP-PR2) with their ADR.
2. For each: grep code-repos for implementing modules; check tests; check STUB/scaffold/blocked markers.
3. Classify L1/L2/L3; compute installation %.
4. Cross-repo: banxe-architecture (governance) vs banxe-emi-stack / banxe-payment-core / crypto-ops-monitor / braslina (code).

## Feature inventory — first-pass classification
(Deep L2/L3 verification per the audit roadmap AU-tasks; "AU-pending" = not yet verified in this pass.)

| Feature | ADR | L1 | L2 (code evidence) | L3 status | install% |
|---------|-----|----|--------------------|-----------|----------|
| GAP-064 adverse-media EDD | (MLR2017 Reg.28) | ✓ GAP | AU-3 pending (emi-stack adverse_media / Ballerine/Marble) | AU-pending | ~33-66% |
| GAP-065 crypto-ops-monitor | ADR-109 | ✓ | ✓ crypto-ops-monitor (SP-CO2: ruff+mypy+pytest green, 20 tables) | partial — RPC live needs rpc_url; DB bootstrap wired | ~66-100% |
| GAP-066 braslina onboarding | ADR-110 | ✓ | AU-4 pending (standalone braslina repo) | AU-pending (partial KYB) | ~33-66% |
| GAP-067 OSS supply-chain/license | — | ✓ GAP | AU-3 pending (SBOM/SCA/license-audit) | AU-pending | ~33% |
| GAP-068 crypto-AML graph | ADR-111 | ✓ | AU-1 pending (GraphSense/Neo4j/ML) | AU-pending | ~33% |
| GAP-069 voice AI support | ADR-112 | ✓ | AU-5 pending (LiveKit/Whisper/TTS) | AU-pending | ~33% |
| GAP-070 quant pricing/risk advisory | ADR-113 | ✓ | AU-5 pending (QuantLib + DSE, advisory-seam) | AU-pending | ~33% |
| GAP-071 payment distribution | ADR-108 ACCEPTED | ✓ | governance + Tompay/Paybis distribution | residual: Paybis go-live, CASP T&C, Travel Rule | ~66% |
| GAP-072 Travel Rule | ADR-114 | ✓ | AU-2 pending (Paybis TR-provider vs MLRO) | AU-pending (gates ADR-036) | ~33% |
| GAP-073 execution channel (Channel C) | ADR-106 | ✓ | ✓ Ruflo factory (this track) | **LIVE** (factory landing PRs) | **100%** |
| GAP-074 acquiring/issuing | ADR-015 | ✓ SAD §3.7 | ✓ banxe-payment-core (297 tests, 97% cov) | **BLOCKED on keys** (Modulr BT-001 + Paymentology sandbox) | ~66% (L3 key-gated) |

**Cross-repo principle:** L1 lives in banxe-architecture; L2/L3 live in the code-repos. A feature at L1 only (ADR/GAP with no code) is "governed, not installed". Source of truth for L2/L3 = code reality, never the business-model doc.

## Audit Verdicts (2026-06-20)

Read-only code-audit across code-repos (no feature code changed). Source of truth = code reality.

| Feature | ADR | Verdict | L2/L3 evidence | gap-delta |
|---------|-----|---------|----------------|-----------|
| GAP-064 adverse-media | MLR2017 Reg.28 | **L1 ONLY** | no code in banxe-emi-stack services/src (only .claude/worktrees draft) | implement in emi-stack |
| GAP-065 crypto-ops-monitor | ADR-109 | **L3 WIRED** | origin/main 33463fa0; init_db wired in api/main.py; real_rpc_base hardened; 297+ tests | — |
| GAP-066 braslina | ADR-110 | **L2 CODE** | braslina src complete (agent/checklist/crm/purchases/register), production v1.0.0 | wire/live |
| GAP-067 OSS supply-chain | policy | **L1 GOVERNANCE** (correct — policy by nature) | — | — |
| GAP-068 crypto-AML graph | ADR-111 | **L1 ONLY** | no GraphSense/Neo4j/GraphSAGE in code | implement |
| GAP-069 voice-AI | ADR-112 | **L1 ONLY** | no LiveKit/Whisper/telephony in code | implement |
| GAP-070 quant advisory | ADR-113 | **L1 ONLY** | no Heston/Avellaneda in code | implement |
| GAP-071 distribution | ADR-108 ACCEPTED | **L1 GOVERNANCE** (correct — decision) | — | — |
| GAP-072 Travel Rule | ADR-114 | **L1 GOVERNANCE** (correct — decision) | — | — |
| GAP-073 factory channel | ADR-106 ACCEPTED | **L3 LIVE** | ruflo/start-ruflo.sh | — |
| GAP-074 acquiring | SAD §3.7 / ADR-015 | **L2 CODE / L3 BLOCKED** | banxe-payment-core adapters (hyperswitch/paymentology/midaz) + 297 tests; live blocked on API keys (BT-001 Modulr / Paymentology) | provision keys |

### Summary
- **Code-installed (L2/L3) = 4:** GAP-065 (crypto-ops, L3), GAP-066 (braslina, L2), GAP-073 (factory, L3-live), GAP-074 (acquiring, L2 / L3-blocked-on-keys).
- **Governance-only, correct by nature (decision/policy) = 3:** GAP-067, GAP-071, GAP-072.
- **Implementation-delta (ADR/L1 without code) = 4:** GAP-064 (adverse-media), GAP-068 (crypto-AML graph), GAP-069 (voice-AI), GAP-070 (quant advisory).
- **Total GAP-064..074 = 11** (4 + 3 + 4).
- **Installation %:** code-installed L2/L3 ≈ **31%** of the 13-feature roadmap (incl. SP-CO2/SP-BM2/SP-PR2 cross-repo), ≈36% of 11 GAPs; governance L1 = **100%**; **implementation-delta = 4 features** (next build targets).
