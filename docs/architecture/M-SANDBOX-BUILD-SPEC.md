# M-SANDBOX — Sandbox Environment Build-Spec (test accounts, mock rails, demo scenarios)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** M-sandbox · **Priority:** P2 · **Sprint:** 12 · **Promotes:** the 0% — **consolidates the accepted sandbox ADR set (ADR-086, ADR-096–101 / SBOX-1..6)** into one actionable spec.
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/consolidates**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **ISOLATION FENCE (read §8 first).** M-sandbox is an **isolated TEST/SANDBOX environment only** — test
> accounts, **mock** payment rails, **synthetic** data. **Hard isolation from production:** **no real money, no
> live rails, no real ledger postings, no real PII, no production data** — synthetic test data only. This spec
> **consolidates the accepted ADRs**; it does not duplicate or contradict them.

---

## 0. Duplication Audit (ADR-102) — consolidation, not duplication

| Artifact | Role | Decision |
|---|---|---|
| `docs/adr/ADR-086-risk-earn-baas-readonly-sandbox.md` (ACCEPTED) | Risk & Earn BaaS **read-only** sandbox endpoints — analytics-only, no execution | **keep / CONSOLIDATE** — read-only analytics surface within the sandbox; this spec references, does not change |
| `docs/adr/ADR-096-unified-sandbox-mode-surface.md` (SBOX-1, ACCEPTED) | **Unified sandbox-mode surface** — explicit internal sandbox state, mock-safe | **keep / CONSOLIDATE** — the sandbox-mode flag/surface is the spine (§1.1) |
| `docs/adr/ADR-097-sandbox-demo-scenarios.md` (SBOX-2, ACCEPTED) | **Demo scenarios** — deterministic, mock-only demo journeys | **keep / CONSOLIDATE** — `DemoScenario` model (§2) |
| `docs/adr/ADR-098-sandbox-session-recorder-replay.md` (SBOX-3, ACCEPTED) | **Session recorder & replay** — observability over advisory seams | **keep / CONSOLIDATE** — `Session` record/replay (§2) |
| `docs/adr/ADR-099-partner-sandbox-pack.md` (SBOX-4, ACCEPTED) | **Partner sandbox pack** — sample partner profiles + demo bundles, mock-only | **keep / CONSOLIDATE** — partner pack provisioning (§1.5) |
| `docs/adr/ADR-100-sandbox-educational-gamification.md` (SBOX-5, ACCEPTED) | **Educational gamification** — demo-only, no real-money / G4 mechanics | **keep / CONSOLIDATE** — optional gamification (§1.6), demo-only |
| `docs/adr/ADR-101-sandbox-portal-ux-shell.md` (SBOX-6, ACCEPTED) | **Portal / UX shell** — internal demo shell over SBOX-1..5 | **keep / CONSOLIDATE** — portal shell (§1.7) |
| `docs/devportal/sandbox-portal.md` | sandbox portal devportal doc | **keep / reference** — portal surface |
| `docs/architecture/M-GATEWAY-BUILD-SPEC.md` (IL-525) | dev-platform; issues **sandbox API keys + sandbox visibility** | **keep / REUSE** — sandbox keys/visibility come from M-gateway; not reimplemented |
| `docs/payments/C-FPS/C-SEPA/C-SWIFT-BUILD-SPEC.md` | real payment rails | **keep / reference + FENCE** — M-sandbox provides **MOCK** rails mirroring the rail interfaces; **no real rail / no settlement** (ADR-102) |
| `docs/architecture/B-EMI-BUILD-SPEC.md` (IL-498) | product catalogue | **keep / reference** — sandbox **test** product accounts mirror B-emi product shapes (synthetic) |

No existing `M-SANDBOX-BUILD-SPEC` artifact on main (live audit: `find docs -iname '*m-sandbox*'`/`*sandbox*BUILD*` ⇒ empty). New file is **non-duplicative**; it **consolidates the accepted SBOX ADRs** into one build-spec, it does not re-decide them or reimplement rails/M-gateway.

## 1. Scope — sandbox environment (consolidating SBOX-1..6 + ADR-086)

All sandbox behaviour is **config-as-data** (CLAUDE.md §10) and **mock-only**:

1. **Unified sandbox-mode surface (ADR-096 / SBOX-1)** — an explicit internal `sandbox` state flag threaded through the surface; mock-safe by construction; every sandbox response is unambiguously marked sandbox.
2. **Test-account provisioning** — synthetic `TestAccount`s mirroring B-emi product shapes (e-money/card/IBAN-format), **no real IBAN issuance**, no real balances — synthetic only.
3. **Mock payment rails** — `MockRailResponse` adapters mirroring the **C-fps / C-sepa / C-swift** `PaymentRailPort` interfaces with deterministic mock responses; **no real settlement, no NOSTRO movement, no live PSP/SWIFT calls**.
4. **Demo scenarios (ADR-097 / SBOX-2)** — deterministic, mock-only demo journeys (onboarding → account → payment → recon) as config-driven `DemoScenario`s.
5. **Partner sandbox pack (ADR-099 / SBOX-4)** — sample partner profiles + demo bundles (mock-only) for partner DX/evaluation.
6. **Educational gamification (ADR-100 / SBOX-5, optional)** — demo-only learning mechanics; **no real-money, no G4/real reward mechanics**.
7. **Portal / UX shell (ADR-101 / SBOX-6)** — internal demo shell over SBOX-1..5 (`docs/devportal/sandbox-portal.md`).
8. **Read-only Risk & Earn BaaS analytics (ADR-086)** — analytics-only sandbox endpoints; **no execution**.
9. **Session recorder & replay (ADR-098 / SBOX-3)** — record/replay sandbox sessions for observability/demo.

**Out** of M-sandbox: any production environment/data, real payment rails, real ledger postings, real PII, sandbox-key infrastructure (M-gateway), real product/IBAN issuance (B-emi).

## 2. Data model (SandboxTenant / TestAccount / MockRailResponse / DemoScenario / Session)

Declarative, config-as-data; synthetic data only; sandbox-marked.

### 2.1 `SandboxTenant`
- `tenant_id`, `partner_profile_ref` (ADR-099 pack), `sandbox_key_ref` (issued by M-gateway, sandbox visibility), `created_at`, `isolation` (= `production_isolated`, always true).

### 2.2 `TestAccount`
- `test_account_id`, `tenant_id`, `product_shape` (mirrors B-emi type), `synthetic_iban` (format-valid, **non-issuable**), `mock_balance` (synthetic), `currency`. **Marked synthetic; never linked to a real customer/account.**

### 2.3 `MockRailResponse`
- `mock_id`, `rail` (`fps | sepa | swift`), `request_shape` (mirrors real `PaymentRailPort`), `deterministic_response` (config-as-data: settled/returned/rejected fixtures), `latency_sim`. **No real settlement.**

### 2.4 `DemoScenario`
- `scenario_id`, `steps[]` (deterministic mock journey), `expected_outcomes`, `pack_ref` (partner pack). Config-driven (ADR-097).

### 2.5 `Session`
- `session_id`, `tenant_id`, `recorded_events[]` (ADR-098), `replayable` (bool). Observability/demo only.

## 3. Sandbox flow (mock-only, production-isolated)

```
partner/dev → M-gateway issues SANDBOX key (sandbox visibility)
  1. provision SandboxTenant (production_isolated=true) + TestAccount[] (synthetic)
  2. run DemoScenario → MockRail adapters return deterministic responses  [NO real rail/settlement]
  3. mock GL/recon are simulated views only — NO real ledger postings (D-gl untouched)
  4. read-only Risk&Earn analytics (ADR-086) — analytics-only, no execution
  5. record Session (ADR-098) → replay for demo/observability
  6. portal shell (ADR-101) presents SBOX-1..5; optional gamification (ADR-100, demo-only)
```

- **Sandbox ≠ production:** a hard boundary — sandbox code paths never touch production rails, ledger, PII, or data. The `sandbox` flag (ADR-096) is explicit and mock-safe.
- Mock rails **mirror** the real `PaymentRailPort` interface (so client code is portable) but return **deterministic fixtures** — never a live PSP/SWIFT call, never settlement.

## 4. Producer/consumer contracts (referenced, not duplicated)

- **Sandbox keys/visibility from M-gateway** (`M-GATEWAY-BUILD-SPEC` IL-525): sandbox API keys + sandbox environment visibility issued by M-gateway; M-sandbox consumes. Key infra not reimplemented.
- **Mock rails mirror C-fps/C-sepa/C-swift** interfaces (`PaymentRailPort`): same interface shape, mock responses. Real rails **not** reimplemented; no settlement.
- **Test accounts mirror B-emi** product shapes: synthetic accounts; B-emi product logic not duplicated; no real issuance.
- **No D-gl/D-recon**: GL/recon are **simulated views** in sandbox; real posting/recon engines untouched.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_sandbox_mode_flag_explicit_and_marked` (ADR-096; every sandbox response marked sandbox; mock-safe).
- [ ] `test_test_account_synthetic_no_real_issuance` (synthetic IBAN format-valid but non-issuable; no real balance).
- [ ] `test_mock_rail_mirrors_paymentrailport_no_settlement` (mock fps/sepa/swift mirror interface; deterministic fixtures; **no real settlement/NOSTRO/PSP call**; boundary test).
- [ ] `test_demo_scenario_deterministic` (ADR-097; config-driven, reproducible).
- [ ] `test_no_real_ledger_posting` (sandbox GL is a simulated view; D-gl untouched; boundary test).
- [ ] `test_risk_earn_analytics_read_only` (ADR-086; analytics-only, no execution).
- [ ] `test_session_record_replay` (ADR-098).
- [ ] `test_partner_pack_provisioning_mock_only` (ADR-099; sample profiles, mock bundles).
- [ ] `test_gamification_demo_only_no_real_money` (ADR-100; no real-money/G4 mechanics).
- [ ] `test_sandbox_keys_from_m_gateway` (keys/visibility consumed from M-gateway; not reimplemented).
- [ ] `test_production_isolation` (sandbox paths never touch production rails/ledger/PII/data; hard isolation).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; M-gateway/C-rails/B-emi/D-gl boundaries respected.

## 6. Perimeter

- **In:** sandbox environment — sandbox-mode surface, synthetic test accounts, mock rails, demo scenarios, partner pack, portal shell, optional gamification, read-only Risk&Earn analytics, session record/replay (all per the consolidated ADRs).
- **Out (fail-closed, §7):** production environment/data, real rails/settlement, real ledger postings, real PII, sandbox-key infra (M-gateway), real product/IBAN issuance (B-emi).
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§9).

## 7. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no production access / no production data / no real PII** (hard isolation, §8); **no real payment rails / no settlement / no live PSP-SWIFT calls** (mock only; mirrors C-* interfaces, does not reimplement them); **no real ledger postings** (D-gl untouched; sandbox GL is a simulated view); **no real money / no real rewards** (gamification demo-only); **no sandbox-key-infra reimplementation** (M-gateway issues keys); **no real product/IBAN issuance** (B-emi); no re-deciding or contradicting the consolidated ADRs (this spec consolidates ACCEPTED ADR-086/096-101).

## 8. ISOLATION FENCE (sandbox-only — fail-closed)

- M-sandbox is an **isolated test/sandbox environment only**. **Hard isolation from production:** no real money, no live rails, no real ledger postings, no real PII, no production data — **synthetic test data only**.
- Mock rails **mirror** real rail interfaces for client-code portability but return **deterministic fixtures** — never a live call, never settlement.
- The sandbox-mode surface (ADR-096) is **explicit and mock-safe**; every sandbox artifact is marked sandbox.
- **Fail-closed:** if any requirement would have the sandbox touch production rails/ledger/PII/data, move real money, or issue real products → **STOP + operator brief**; do not implement.

## 9. Operator gates NOT crossed

- **Cross-repo runtime** — implementing M-sandbox in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Sandbox environment deployment / partner sandbox enablement** = operator-authorized action — not done here.
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched. The consolidated ADRs (086/096-101) remain ACCEPTED — not re-decided.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 10. References

`docs/adr/ADR-086-risk-earn-baas-readonly-sandbox.md`; `ADR-096-unified-sandbox-mode-surface.md` (SBOX-1); `ADR-097-sandbox-demo-scenarios.md` (SBOX-2); `ADR-098-sandbox-session-recorder-replay.md` (SBOX-3); `ADR-099-partner-sandbox-pack.md` (SBOX-4); `ADR-100-sandbox-educational-gamification.md` (SBOX-5); `ADR-101-sandbox-portal-ux-shell.md` (SBOX-6) — all ACCEPTED, consolidated here;
`docs/devportal/sandbox-portal.md` (portal surface);
`docs/architecture/M-GATEWAY-BUILD-SPEC.md` (IL-525 — sandbox keys/visibility);
`docs/payments/C-FPS/C-SEPA/C-SWIFT-BUILD-SPEC.md` (rail interfaces mocked); `docs/architecture/B-EMI-BUILD-SPEC.md` (IL-498 — product shapes mirrored);
ADR-027 (audit), ADR-102/103/115/116/117/119; CLAUDE.md §9/§10/§11.
