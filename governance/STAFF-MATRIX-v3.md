# STAFF-MATRIX-v3 — Banxe AI Bank Agent Passport Registry (NORMATIVE)

> **Status:** Sprint-4 Audit Baseline (2026-07-02). **Normative** — child of the org canon.
> **Parent:** `governance/CANONICAL-ORG-CHART-v2.md` (frozen org structure).
> **Supersedes (append-only):** `governance/STAFF-MATRIX-v2.md` (Sprint-3, 44 passports). v2 remains
> the frozen Sprint-3 record. **This document is the authoritative post-audit snapshot.**
> **Audit basis:** 2026-07-02 filesystem scan of `agents/passports/` — 70 YAML files found.
> **Scope:** records current passport inventory, evo2 infrastructure profile, duplicate flags,
> and P1 governance gaps. Does NOT activate or deactivate any passport (I-24 append-only).

---

## 1. Passport Inventory Summary

| Metric | Count |
|--------|-------|
| Passports total (filesystem scan 2026-07-02) | **70** |
| — active / ACTIVE | ~31 |
| — PROPOSED (pending operator activation) | ~39 |
| Sprint-3 baseline (STAFF-MATRIX-v2) | 44 |
| Delta since v2 | +26 new passport files |
| HITL gates | 17 (HITL-MATRIX.yaml — unchanged) |

> **Note:** v2 recorded 44 passports. Filesystem scan shows 70. The delta (+26) includes
> new passports added during Sprints 4–5 (finance/, channel orchestrators, governors, etc.)
> without a corresponding STAFF-MATRIX update. This v3 closes that gap.

---

## 2. Full Passport Registry

### 2a. L1–L2 Department Heads (from STAFF-MATRIX-v2, all active)

| agent_id | autonomy | human_double (SM&CR) | HITL gates | status |
|----------|----------|----------------------|------------|--------|
| `ceo_orchestration_agent` | L2_REVIEW | CEO Moriel Carmi (SMF1) | HITL-004,007,008,012,015,017 | active |
| `board_reporting_agent` | L2_REVIEW | CEO / Board | (reporting, no approval gate) | active |
| `internal_audit_agent` | L2_REVIEW | Grant Thornton UK (SMF5) | (independent assurance) | active |
| `risk_oversight_agent` | L2_REVIEW | CRO Elena Vasilenko (SMF4) | HITL-012,014 | active |
| `compliance_monitoring_agent` | L2_REVIEW | Head of Compliance | HITL-002,006,009 | active |
| `cfo_orchestration_agent` | L2_REVIEW | CFO David Goldstein (SMF2) | HITL-010,011,016 | active |
| `coo_operations_agent` | L2_REVIEW | COO James Hargreaves (SMF24) | HITL-009,016 | active |
| `cto_platform_agent` | L2_REVIEW | CTO Oleg (SMF26) | HITL-013,014,015 | active |
| `front_office_agent` | L2_REVIEW | CCO (Commercial lead) | (→ HITL-017 CEO) | active |
| `legal_corporate_agent` | L2_REVIEW | Legal Counsel | (agreements, no approval gate) | active |
| `banxe_aml_orchestrator` (root) | — | MLRO SMF17 | see §3 DUPLICATE flag | active |
| `privacy_compliance_agent` | L2_REVIEW | DPO | — | PROPOSED* |

*`privacy_compliance_agent` shows PROPOSED in passport YAML — verify against v2 which marked it active.

### 2b. AML / Compliance Sub-agents (`agents/passports/aml/`)

| agent_id | autonomy | status | path |
|----------|----------|--------|------|
| `banxe_aml_orchestrator` | L3 | active | `agents/passports/aml/banxe_aml_orchestrator.yaml` |
| `jube_adapter_core` | L3 | active | `agents/passports/aml/jube_adapter_core.yaml` |
| `mlro_report_agent` | L2 | active | `agents/passports/aml/mlro_report_agent.yaml` |
| `sanctions_check_core` | L3 | active | `agents/passports/aml/sanctions_check_core.yaml` |
| `tx_monitor_core` | L3 | active | `agents/passports/aml/tx_monitor_core.yaml` |
| `watchman_adapter_core` | L3 | active | `agents/passports/aml/watchman_adapter_core.yaml` |
| `yente_adapter_agent` | L3 | active | `agents/passports/aml/yente_adapter_agent.yaml` |

### 2c. Core Platform Agents (root level, active)

| agent_id | autonomy | status |
|----------|----------|--------|
| `aml_orchestrator` | — | active |
| `clickhouse_writer` | — | active |
| `crypto_aml` | — | active |
| `data_lake_elt_agent` | — | active |
| `design_pipeline_agent` | — | ACTIVE |
| `gap_tracker_agent` | L1_AUTO | ACTIVE |
| `jube_adapter` | — | active |
| `sanctions_check` | — | active |
| `spec_first_auditor` | L2_REVIEW | ACTIVE |
| `treasury_alm_agent` | — | active |
| `tx_monitor` | — | active |
| `watchman_adapter` | — | active |
| `yente_adapter` | — | active |

### 2d. Finance Sub-agents (`agents/passports/finance/` — all PROPOSED)

| agent_id | autonomy | status |
|----------|----------|--------|
| `apar_agent` | L2_REVIEW | PROPOSED |
| `beancount_export_agent` | L1_AUTO | PROPOSED |
| `consolidation_agent` | L2_REVIEW | PROPOSED |
| `gl_close_agent` | L2_REVIEW | PROPOSED |
| `ifrs_agent` | L2_REVIEW | PROPOSED |
| `tax_compliance_agent` | L2_REVIEW | PROPOSED |

### 2e. New / Proposed Agents (root level, PROPOSED — pending operator activation)

| agent_id | autonomy | status |
|----------|----------|--------|
| `adverse_media_governor` | — | PROPOSED |
| `agreement_agent` | L2_REVIEW | PROPOSED |
| `alerting_agent` | L2_REVIEW | PROPOSED |
| `bi_dashboard_governor` | L2_REVIEW | PROPOSED |
| `case_management_agent` | L2_REVIEW | PROPOSED |
| `channel_c_sepa_orchestrator` | L2_REVIEW | PROPOSED |
| `channel_c_swift_orchestrator` | L2_REVIEW | PROPOSED |
| `crm_dsar_governor` | L2_REVIEW | PROPOSED |
| `customer_lifecycle_agent` | L1_AUTO | PROPOSED |
| `document_management_agent` | L2_REVIEW | PROPOSED |
| `experiment_copilot_agent` | L2_REVIEW | PROPOSED |
| `fatca_crs_reporting_governor` | L2_REVIEW | PROPOSED |
| `hr_agent` | L2_REVIEW | PROPOSED |
| `m_gateway_api_governor` | L2_REVIEW | PROPOSED |
| `midaz_mcp_agent` | L2_REVIEW | PROPOSED |
| `ml_pipeline_agent` | L2_REVIEW | PROPOSED |
| `multi_tenancy_agent` | L2_REVIEW | PROPOSED |
| `payment_router_agent` | L3_MLRO | PROPOSED |
| `pricing_fee_governor` | L2_REVIEW | PROPOSED |
| `reasoning_bank_agent` | L2_REVIEW | PROPOSED |
| `regulatory_returns_governor` | — | PROPOSED |
| `reporting_agent` | L3_MLRO | PROPOSED |
| `resilience_agent` | L2_REVIEW | PROPOSED |
| `safeguarding_audit_agent` | L2_REVIEW | PROPOSED |
| `safeguarding_recon_governor` | — | PROPOSED |
| `sandbox_rails_governor` | L2_REVIEW | PROPOSED |
| `sdk_release_governor` | L2_REVIEW | PROPOSED |
| `support_sla_governor` | L2_REVIEW | PROPOSED |
| `user_preferences_agent` | L2_REVIEW | PROPOSED |
| `webhook_orchestrator_agent` | L2_REVIEW | PROPOSED |
| `webhooks_agent` | L2_REVIEW | PROPOSED |
| `wind_down_planning_agent` | L2_REVIEW | PROPOSED |

---

## 3. Duplicate Flag — ACTION REQUIRED

| agent_id | status | paths | action |
|----------|--------|-------|--------|
| `banxe_aml_orchestrator` | ⚠️ DUPLICATE_DETECTED | `agents/passports/banxe_aml_orchestrator.yaml` (root, autonomy=unset) vs `agents/passports/aml/banxe_aml_orchestrator.yaml` (L3, more complete) | **Operator to resolve:** deprecate root copy or reconcile autonomy fields. Do NOT delete either (I-24) until operator decision. |

> The `aml/` copy appears more complete (explicit autonomy L3). The root copy may be a legacy
> pre-sprint artifact. Resolution requires MLRO/CTIO sign-off (AML orchestrator is trust-zone RED).

---

## 4. evo2 Infrastructure Profile

> **Source:** 2026-07-02 audit via tailscale SSH. Documented here for STAFF-MATRIX record;
> full ADR is pending (see §5 open decisions).

| Field | Value |
|-------|-------|
| Hostname | banxe-NucBox-EVO-X2-2 |
| Tailscale FQDN | banxe-NucBox-EVO-X2-2.tailea8745.ts.net |
| Hardware | MinisForum NucBox EVO X2-2 |
| CPU | 32 cores |
| RAM | 123 GiB |
| GPU | AMD Radeon 8060S GFX1151 (iGPU, Vulkan/ROCm) |
| ROCm compatibility | HSA_OVERRIDE_GFX_VERSION=11.5.1 (non-native GFX1151 workaround) |
| OS | Ubuntu 24.04.4 LTS, kernel 6.17.0-35-generic |
| Storage | /data/models/ + /data/llama-cpp/ |

### Active Services (systemd)

| Service | Port | Model / Role | Auth |
|---------|------|-------------|------|
| `qwen3-235b-master.service` | :8082 | qwen3-235b-Q3_K_S.gguf, 40 GPU layers, ctx 8192 | bearer sk-rpc-q235-2026 |
| `llama-rpc-worker.service` | :50052 | USB4 RPC worker (thunderbolt0 / 10.0.0.2/30) | — |
| `ollama.service` | :11434 | qwen3:235b Q4_K_M (on-demand) + qwen2.5:0.5b (routing) | — |

### USB4 Distributed Inference Topology

```
evo2 (10.0.0.2/30, thunderbolt0) ←—USB4/Thunderbolt—→ 10.0.0.1 (ARP 02:4d:fd:67:8e:09)
     RPC worker :50052                                   OFFLINE 2026-07-02 | identity UNCONFIRMED
```

> Peer 10.0.0.1 is physically present (ARP resolved) but unreachable via SSH. Identity unknown.
> Operator must physically identify and document for governance completeness.

**ADR reference:** ADR-018 — ✅ **EXISTS** at `decisions/ADR-018-hybrid-5-layer-ai-compute.md` (ACCEPTED 2026-05-03).
Production systemd unit (`qwen3-235b-master.service`) references "ADR-018 P4.3-Q235" — reference is valid.
P4.3-Q235 as-built implementation status documented and CLOSED by IL-801 (PR #956, append-only addendum to ADR-018).

---

## 5. Open Operator Decisions

| # | Decision | Owner | Urgency |
|---|----------|-------|---------|
| OD-1 | `banxe_aml_orchestrator.yaml` duplication: deprecate root copy or reconcile (§3) | MLRO / CTIO | Q2-2026 |
| OD-2 | MIG-M2.4: A/B/C selection for PSD2 router consolidation | CTIO | Q2-2026 |
| OD-3 | USB4 peer 10.0.0.1: physically identify + document (ADR-018 §Open Items OD-3) | Operator | Q3-2026 |
| OD-4 | ADR-018 EXISTS — P4.3-Q235 addendum merged (PR #956, IL-801). CLOSED. | Factory | DONE |
| OD-5 | `privacy_compliance_agent` status mismatch: v2 says active, YAML says PROPOSED — reconcile | DPO / CTIO | Q3-2026 |

---

## 6. P1 GAP Status (as of 2026-07-02)

> Full register: `docs/GAP-REGISTER.md` (updated IL-799). Summary of highest-priority open items:

| GAP | Description | Owner | Target | Status |
|-----|-------------|-------|--------|--------|
| GAP-082 | ufw physical/console access to Legion laptop | CTIO | — | 🔴 OPEN |
| GAP-085 | GDPR Art.33 72h notification — clock running since 2026-06-27 | Legal | URGENT | 🔴 OPEN |
| GAP-090 | OpenClaw LiteLLM bypass (3 processes bypass :4000, no audit trail) | CTIO | Q2-2026 | 🔴 OPEN |
| GAP-091 | ADR-049 Intent-First deployment gap (ACCEPTED/not-deployed, INTENT_LAYER_ENABLED=false) | Product | Q3-2026 | 🔴 OPEN |
| GAP-092 | Guardian webhook delivery gap (blocks merge without --admin) | Factory/CTIO | Q2-2026 | 🔴 OPEN |

---

## 7. Append-only lineage

| Version | Date | Passports | Key change |
|---------|------|-----------|------------|
| v1 | Sprint-2 | 34 | Initial passport registry |
| v2 | 2026-06-21 | 44 | 10 dept-head agents activated (GAP-078 closed) |
| **v3** | **2026-07-02** | **70** | **Post-audit snapshot, evo2 profile, duplicate flag, P1 GAPs** |

---

*Sprint-4 audit baseline · child of `governance/CANONICAL-ORG-CHART-v2.md` · append-only over v2. I-24 enforced.*
