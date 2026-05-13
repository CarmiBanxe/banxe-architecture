# ADR-016: AI Plane and PII/AML Routing for EMI Stack

**Status:** Accepted
**Date:** 2026-05-03
**Source-of-determination:** body line `- **Status:** Accepted` (hyphen-prefixed list-form header — not matched by INDEX generator regex `^\*\*Status:\*\*`)

- **Status:** Accepted
- **Date:** 2026-05-03
- **Deciders:** Architecture WG (Banxe)
- **Scope:** banxe-emi-stack, banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher, all future EMI services
- **Supersedes:** —
- **Related:**
  - banxe-emi-stack ROADMAP Phase 3 sync (commit cbaf57c)
  - banxe-emi-stack docs/AI-PLUMBING.md (commit fe26fcb)
  - banxe-emi-stack docs/adr/ADR-021-ai-plane-pii-aml-routing.md (mirror, commit d1af542)
  - banxe-architecture INVARIANTS.md → I-32, I-33 (this rollout)
  - banxe-architecture GAP-REGISTER.md → G-AI-*, G-PII-*, G-MIG-01 (this rollout)

## Context

EMI стек выходит на исполнение FCA CASS 15 (deadline 2026-05-07). Исторически часть сервисов обращалась к внешним LLM-провайдерам напрямую, что несовместимо с PII/AML обязательствами и FCA MLR 2017.

Развёрнут локальный LiteLLM v2 router (http://legion:4000/v1, далее evo1) с алиасами: ai, ai-heavy, glm-air, reasoning, banxe-general, fast, coding. Идёт миграция Legion WSL2 → evo1 /data/banxe/ с двойным запасом (--user units на Legion сохранены до подтверждённого PASS на evo1).

## Decision

1. **Единый AI-plane.** LiteLLM v2 router — единственный санкционированный entrypoint для AI-вызовов из любого EMI-сервиса. Прямые вызовы внешних LLM из сервисного кода запрещены.
2. **Алиасы как контракт.** Сервисы обращаются только по алиасам. Backing-модели — деталь реализации plane.
3. **PII/AML guardrails — binding.** Контент по путям compliance/cases/*, kyc/raw/*, secrets/*, .env*, **/*.pem, **/id_* — обрабатывается ИСКЛЮЧИТЕЛЬНО локальными алиасами (ai, ai-heavy, glm-air, reasoning). Source of truth: banxe-infra/ai-routing/policy.yaml.
4. **Секреты.** LITELLM_MASTER_KEY — operator-supplied env; никогда не коммитится.
5. **Миграция как шаблон.** Legion WSL2 → evo1 /data/banxe/ по схеме «двойной запас»: старые --user units на Legion остаются включаемыми до PASS на evo1.
6. **Энфорсмент.** pre-commit hook + review checklist в каждом EMI-репо. Нарушение PII/AML routing = P0 security incident.

## Consequences

**Положительные**: единая точка аудита AI-трафика; возможность смены backing-моделей без рефакторинга сервисов; PII/AML guardrails проверяются централизованно.

**Риски**: точка отказа — LiteLLM router (митигация: health-checks, План B на evo1, rollback на Legion). Алиас reasoning (qwen3:235b-a22b) pending PASS — до PASS не использовать в проде compliance-флоу.

## Compliance mapping

- FCA CASS 15 (deadline 2026-05-07): контроль обработки клиентских данных — закрывается guardrails (п.3).
- FCA MLR 2017: policy provenance chain.
- GDPR Art. 5 / Art. 32: minimisation + security — закрывается локальной обработкой PII.

## Enforcement artefacts

- banxe-infra/ai-routing/policy.yaml (deny-paths, alias map)
- pre-commit hook: запрет прямых вызовов внешних LLM SDK в EMI-сервисах
- Review checklist: «AI calls go via LiteLLM aliases only»
- INVARIANTS.md: I-32 (no direct cloud LLM), I-33 (PII deny-paths routing)

## Rollout

- T+0: этот ADR Accepted в banxe-architecture/decisions/
- T+1: I-32, I-33 в banxe-architecture/INVARIANTS.md
- T+2: закрыть G-AI-*, G-PII-*, G-MIG-01 в banxe-architecture/GAP-REGISTER.md
- T+3: backlink в banxe-emi-stack/ROADMAP.md Phase 3 sync и docs/AI-PLUMBING.md на ADR-016 как канонический источник
