# ADR-018: Hybrid 5-layer AI Compute Architecture (canonical target)

**Status:** ACCEPTED (canon, locked)
**Date:** 2026-05-03T18:34:15+02:00
**Author:** Moriel Carmi
**Supersedes:** none
**Related:** ADR-016 (AI plane PII/AML routing), ADR-021 (banxe-emi-stack mirror), HW-MODEL-UPGRADE-matrix.md

## Context
Кластер из Legion + EVO-X2 #1 + EVO-X2 #2 должен использоваться **на 100% эффективности** для:
- работы с Фабрикой разработчика (multi-repo CI, AI-assisted PR review),
- production задач BANXE EMI bank (KYC/AML/compliance/payments),
- любых будущих проектов после BANXE (regtech, AI-продукты, личные эксперименты, любая другая R&D).

Архитектура должна быть **bound**, а не «один из вариантов» — то есть зафиксирована как canonical target на уровне ADR.

## Decision

5-layer гибридная архитектура. Это **canonical target**, не предмет обсуждения.

### Layer 1 — Reasoning (70B–235B)
- llama.cpp RPC: master на evo1, worker на evo2:50052 через USB4 (10.0.0.1/30 ↔ 10.0.0.2/30, 9.12 Gbit/s, 0.5 ms RTT).
- Pipeline #1 (live): GLM-4.5-Air-Q4_K_M (~110B, 73 GiB) — 21 t/s gen, master :8081.
- Pipeline #2 (target): qwen3:235b-a22b-Q4_K_M (~235B, ~95 GiB GGUF) — 5–8 t/s gen, master :8082 (новый).
- Оба iGPU задействованы (evo1 + evo2), оба CPU задействованы, USB4 как шина.

### Layer 2 — Mid-size (10B–70B)
- Ollama balance между evo1 + evo2.
- Active aliases: `ai`, `ai-heavy`, `fast`, `coding`, `banxe-general`, `reasoning` (LB fallback), etc.
- Параллельная нагрузка от нескольких клиентов; failover автоматический через LiteLLM router num_retries=2.

### Layer 3 — Small specialized (≤7B)
- AMD XDNA 2 NPU на evo1 (126 TOPS) + evo2 (126 TOPS) = **252 TOPS aggregate**.
- Setup: AMD Ryzen AI SDK + onnxruntime-directml.
- Use cases: embedding (BANXE knowledge retrieval), PII/AML classification, KYC photo verify, sentiment, fast classification.
- LiteLLM aliases: `embed-fast`, `pii-classify`, `sentiment`, `kyc-photo`.

### Layer 4 — Cloud meta-plane
- Anthropic Claude Code для PR review, scaffolding, генерации кода, workflow рекомендаций.
- Чувствительные данные НЕ уходят в облако: deny_paths из ADR-016 (compliance/cases/*, kyc/raw/*, secrets/*, .env*, **/*.pem, **/id_*).

### Layer 5 — Routing
- LiteLLM v2 на Legion :4000, systemd --user unit (Restart=always).
- Master key sk-banxe-llm-gateway-2026.
- Router выбирает Layer 1/2/3 по типу запроса:
  - быстрая classification → Layer 3 (NPU).
  - средний chat → Layer 2 (Ollama LB).
  - deep reasoning → Layer 1 (RPC big model).
- Fallback chain: deep → mid → small если нагрузка/блокеры.

## BIOS UMA decision (canonical, asymmetric)
- **evo1 = 96 GiB iGPU / 32 GiB CPU** (AI heavy node, GPU-bound).
- **evo2 = 32 GiB iGPU / 96 GiB CPU** (DB + CPU fallback node, для qwen3:235b CPU-only inference, Postgres/ClickHouse page cache, observability stack).
- Это **асимметричный** UMA-split: каждый узел делает то, на что заточен.

## Reusability beyond BANXE
- Архитектура портабельна: меняется только content (модели подкачиваются под задачу).
- Любой следующий проект (другой банк, regtech, AI-продукт, личный R&D) использует ту же 5-layer структуру.
- Factory baseline (.claude/settings.json + canon + deny_paths) переносится в новый репо за минуты.

## Consequences
- **+** 100% утилизация AI компонентов кластера (RPC + Ollama LB + NPU одновременно).
- **+** Универсальность: применимо к любому будущему проекту.
- **+** Чёткое разделение secret/non-secret через cloud meta-plane.
- **−** Требуется одноразовый sprint P4.3 (BIOS rebalance) + P4.4 (XDNA SDK setup) + P4.3-Q235 (qwen3:235b GGUF + RPC pipeline #2).

## Status
**LOCKED canonical target.** Все будущие архитектурные решения и sprint planning должны соответствовать этой 5-layer структуре.

---

## Implementation Status — P4.3-Q235 COMPLETE (2026-07-02)

> **This section is an append-only addendum (I-24). The decision above is unchanged.**

**Sprint P4.3-Q235 completed.** Pipeline #2 (qwen3:235b GGUF + RPC pipeline) is now live.

### evo2 Deployment State (as-built)

| Property | Value |
|----------|-------|
| Host | evo2 (NucBox EVO X2-2) |
| CPU | 32 cores |
| RAM | 123 GiB |
| iGPU | AMD Radeon 8060S (GFX1151), 40 GPU layers loaded |
| `HSA_OVERRIDE_GFX_VERSION` | 11.5.1 |
| BIOS UMA split | 32 GiB iGPU / 96 GiB CPU (as spec'd: DB+CPU fallback node) |

### Running Services

| Service | Endpoint | Model | Quant | Systemd reference |
|---------|----------|-------|-------|------------------|
| qwen3-235b-master (llama.cpp) | `:8082` | qwen3-235b-A22B | Q3\_K\_S | `banxe-qwen3.service` — "ADR-018 P4.3-Q235" |
| llama-rpc-worker | `:50052` | GPU offload shard | — | USB4 peer 10.0.0.1 (identity TBD — OD-3) |
| ollama | `:11434` | Auxiliary models | — | — |

**Note on quant:** As-deployed uses Q3\_K\_S (not Q4\_K\_M as originally planned in the consequences paragraph). The difference is reduced VRAM requirement vs. modestly lower quality — acceptable given evo2 VRAM budget.

### Security Posture (P4.3-Q235 as-built)

- Internal-network only. No external API published.
- No API key on `:8082` or `:11434` (boundary enforced by network segmentation).
- Residual risk: network boundary breach exposes inference without credentials. Mitigated by host firewall; see GAP-082 (ufw on Legion) for related review.
- PII/AML routing constraints from ADR-016 apply — prompts must be sanitised before routing to evo2.

### Open Items

| ID | Item | Owner |
|----|------|-------|
| OD-3 | USB4 peer 10.0.0.1 physical identity and hostname not yet documented | Operator |
| OQ-018-1 | Systemd units for llama-rpc-worker and ollama not yet confirmed | CTIO |
| OQ-018-2 | Logging/monitoring for qwen3-235b inference requests | CTIO |

### Scope Boundary

This addendum documents as-built state of P4.3-Q235 only. It does NOT:
- Modify HITL gates, trust zones, or human approver duties
- Authorise autonomous financial decisions via LLM inference
- Replace Layer 5 (LiteLLM router) ADRs or runtime/API authoring

Not-allowed via any inference tier regardless of model: SAR filing, sanctions reversal,
AML/fraud threshold change, FCA RegData submission, production deploy approval,
AI model update approval, safeguarding shortfall suppression.

Refs: ADR-016 (AI Plane PII/AML routing); GAP-091 (STAFF-MATRIX-v3 §6, IL-800);
STAFF-MATRIX-v3 §4 (evo2 infrastructure profile, IL-800).
