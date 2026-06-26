# PAYBIS dossier — source intake register

**Plane:** docs-plane only (register; no runtime). **Track:** F-crypto-provider (PAYBIS) dossier.
**Date:** 2026-06-26 · **Companion:** ADR-138 (IL-545), DOSSIER (IL-546), SRC-01 (IL-547).

**Purpose / назначение:** отслеживать каждый источник dossier — статус, blocker, путь ингестии. **Roadmap-эпики зависят от этого регистра**: эпик не стартует, пока его SRC-xx не ingested (см. §«Roadmap gating rule»).

---

## Confirmed-present sources (in repo / verified)

| ID | Источник | Статус | Traceability |
|---|---|---|---|
| ADR-108 | Paybis distribution model (MiCA CASP; data-processor/controller split; non-custodial; settlement via Tompay IBAN) | **PRESENT** | `docs/adr/ADR-108-payment-distribution-model.md` @ origin/main |
| ADR-114 | Travel Rule on Paybis (FATF R.16, UK MLR 2017, GBP 1,000; MLRO fallback; CryptoCompliancePort seam) | **PRESENT** | `docs/adr/ADR-114-travel-rule-paybis-casp.md` @ origin/main |
| ADR-138 | NeuroNext retired, PAYBIS sole external crypto provider (forward guard; no dual-provider) | **PRESENT** | `docs/adr/ADR-138-...md` (this branch, IL-545) |
| AUDIT-01 | live audit: **0** NeuroNext / **0** Bitrix footprint в `services/`+`app/` (emi `b23593c`) | **PRESENT** | grep @ origin/main b23593c (recorded IL-516/IL-545) |
| SRC-01 | dossier intake — BANXE↔PAYBIS agreement (placeholder) | **PRESENT, но contractual fields НЕИЗВЕСТНО** | `docs/paybis-dossier/SRC-01-banxe-paybis-agreement.md` (IL-547) |

> **SRC-02 / SRC-03** — не назначены в данном регистре (зарезервированы; контент НЕИЗВЕСТНО). Нумерация недостающих источников ниже следует постановке оператора (SRC-04…SRC-08).

---

## Missing / blocked sources (operator or Paybis must provide)

> Для каждого: id · type · что разблокирует · status=**BLOCKED** · ingestion path · owner. Контент **не выдуман** — где неизвестно, помечено **НЕИЗВЕСТНО**.

| ID | Type | Unblocks | Status | Ingestion path | Owner |
|---|---|---|---|---|---|
| **SRC-04** | BANXE↔PAYBIS agreement — `Corporate-On_Off-Ramp_BANXE-LTD-rev.-1.docx` (excerpt: §8 payment, §9.3 shortfall, General) | dossier **Section 3** commercial/settlement layer (payment terms, shortfall set-off, party/notice, annexes, warranty) | **PRESENT (excerpt INGESTED into SRC-01 §FACT; full .docx pending)** | provided by operator → ingested `docs/paybis-dossier/SRC-01-...md` | **operator / legal** |
| **SRC-05** | Paybis distribution/integration guide («IT — ProWallet×Paybis» preview) | dossier **approved-environments** + integration surface | **PARTIAL** (preview ingested → `SRC-05-06-paybis-integration-map.md`; **domains/ICT/use-cases/prior-approval still НЕИЗВЕСТНО**, clean binary pending) | preview → integration-map; full doc → operator/Paybis | **operator / Paybis** |
| **SRC-06** | PAYBIS **API spec** («GE — Интеграция с Paybis» preview) | `CryptoLedgerPort` **adapter scope** (BuyCrypto/SellCrypto/Order/Refund + webhook) | **PARTIAL** (structural identifiers ingested; **literal endpoints/auth/signature/schemas НЕИЗВЕСТНО**, clean spec pending) | preview → integration-map; openapi → Paybis | **Paybis** |
| **SRC-07** | Travel-Rule **data contract / TR-status schema** (preview: TR + KYB on Paybis) | `CryptoCompliancePort` **scope** (receive TR-status; go-live gate) | **PARTIAL** (TR/KYB touchpoint confirmed structural; **TR-status schema НЕИЗВЕСТНО**) | preview → integration-map; schema → Paybis/MLRO | **Paybis / MLRO** |
| **SRC-08** | MLRO **oversight procedure** owner + **CASP T&C disclosure** status (due 2026-07-01) | compliance go-live gate (ADR-114 option-b fallback) | **BLOCKED** | md/record → `docs/paybis-dossier/` | **operator / compliance** |

**Всё, что не подтверждено документом, = НЕИЗВЕСТНО** (содержимое SRC-04…08 не известно до ингестии).

---

## Audit provenance (обоснование BLOCKED — audit-based, не memory)

- **Off-repo filesystem audit (mark-legion, live shell, operator-reported):** физический SP-PR3 / BANXE↔PAYBIS agreement файл **НЕ найден** нигде; присутствуют лишь копии ADR-114 по worktree-ам + уже созданные dossier-артефакты.
- **Content grep** для `approved domains / prior written approval / distribution agreement / outsourcing agreement` = **EMPTY**.
- **Подтверждено независимо (sub-B, предыдущий ход):** исчерпывающий read-only поиск — оба git-tree (только ссылки в ADR-108/114), полная ФС `/home/mmber/**` (pdf/docx/txt), `~/.claude/paste-cache/*` (совпадения = тексты task-промптов, не соглашение), scratchpad, `/tmp` → агримент отсутствует.
- **Обновление 2026-06-26:** оператор предоставил agreement excerpt (`Corporate-On_Off-Ramp_BANXE-LTD-rev.-1.docx`, §8/§9.3/General) → **SRC-04 BLOCKED → PRESENT** (commercial/settlement layer ингестирован в SRC-01 как FACT; dossier §3a = FACT). Остаются BLOCKED/НЕИЗВЕСТНО (вне excerpt): SRC-05 approved-domains/ICT, SRC-06 API, SRC-07 TR-schema, SRC-08 MLRO/CASP-T&C; §3b dossier остаётся НЕИЗВЕСТНО до полного `.docx`.

---

## Roadmap gating rule

- **GATED (не стартуют до ингестии своего SRC-xx):** эпики, затрагивающие **contractual** / **approved-environment** / **API** / **compliance** слои —
  - contractual/approved-env → ждут **SRC-04 / SRC-05**;
  - `CryptoLedgerPort` PAYBIS-adapter (provider/API) → ждёт **SRC-06**;
  - `CryptoCompliancePort` / Travel-Rule → ждут **SRC-07 / SRC-08** (+ ADR-114 go-live gate: TR-confirmation contract + MLRO procedure).
- **NOT blocked (можно вести параллельно, docs/analysis-plane):** анализ архитектурных seam-ов (`CryptoLedgerPort`/`CryptoCompliancePort` контракт уже в коде), consolidation-analysis (ADR-102 dup-audit duplicate/legacy/_v2-вариантов, без слома контракта), test-strategy-каркас (injectable-mock — без live API).
- **Инвариант:** ни один runtime-вызов к PAYBIS не идёт live, пока не закрыт ADR-114 go-live gate. Register — единая точка истины по готовности источников.

---

### Refs
ADR-108/114/138; SRC-01 (IL-547); DOSSIER (IL-546); `services/ledger/crypto_ledger_port.py`; AUDIT-01 (emi `b23593c`); off-repo mark-legion audit; ADR-119/I-28. **SP-PR3 (SRC-04) — НЕ найден, требуется от оператора.**
