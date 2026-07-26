# S-B0 — New Bank Agents (ADR-049 client masks) — 2026-07-23

**GOVERNANCE-AUDIT / S-B0 SPOT-CHECK RESULT / DOCS-ONLY / READ-ONLY**
S-B0 spot-check of the low-priority repos surfaced **3 genuinely new bank agents** (not mirrors) in `banxe-payment-core/src/agents/`. Added to BANK-MASTER (129 → 132). Verified read-only. NOT-BANK findings recorded separately in the FACTORY registry.

## 3 new bank agents (added)

| agent_id | agent | source_path | class | ADR |
|---|---|---|---|---|
| AG-F2-049 | Payments mask | banxe-payment-core/src/agents/payments_agent.py | PaymentsAgent | ADR-049 §D3 Payments |
| AG-F2-050 | FX/Exchange mask | banxe-payment-core/src/agents/fx_exchange_agent.py | FxExchangeAgent | ADR-049 §D3 FX/Exchange |
| AG-F2-051 | Wallet mask | banxe-payment-core/src/agents/wallet_agent.py | WalletAgent | ADR-049 §D3 Wallet (6th & final) |

**Justification (ADR-049):** all three are `L2 client-facing ... mask (ADR-049)` client-facing intent masks — the Intent-First **L2 Execution** layer. Verified in-file markers: `ADR-049`, `Client-Facing`, `L2`, `Mask`. New path `src/agents/` (not `services/`); dup-check: no `services/agents` payments/wallet/fx client-mask in emi-stack → **not a mirror**; distinct from `services/payment/*` service agents already in the registry.

## §2 The 6 ADR-049 §D3 client-facing masks — series check

`wallet_agent` declares itself "the sixth and final L2 client-facing agent". ADR-049 §D3 defines exactly **6** client-facing masks (scoping the 6 CONTRACT ports: WalletPort, PartnerPort, ExchangePort, KYCProviderPort, NotificationProviderPort, CRMProviderPort):

| # | ADR-049 §D3 mask | agent | in BANK-MASTER? |
|---|---|---|---|
| 1 | Payments | banxe-payment-core/src/agents/payments_agent.py | **NEW** → AG-F2-049 |
| 2 | FX / Exchange | banxe-payment-core/src/agents/fx_exchange_agent.py | **NEW** → AG-F2-050 |
| 3 | KYC onboarding | banxe-emi-stack/services/agents/kyc_onboarding_agent.py | already → AG-F2-001 |
| 4 | Notifications | banxe-emi-stack/services/agents/notification_agent.py | already → AG-F1-015 |
| 5 | Referral / CRM | banxe-emi-stack/services/agents/crm_agent.py | already → AG-F1-010 |
| 6 | Wallet | banxe-payment-core/src/agents/wallet_agent.py | **NEW** → AG-F2-051 |

**Series verdict:** the 6-mask ADR-049 §D3 series is now **COMPLETE** in BANK-MASTER (3 were already present under other rooms; 3 added here). **No further mask gaps** identified.

## Room / ownership
- Placed in **F2-payments** (money-movement client masks), human_double COO/SMF24.
- **`[pending human ratification]`:** FX/Exchange mask room — F2-payments vs F3-treasury (client-facing exchange vs treasury FX). Also: whether the client-mask layer should sit in F0 engine client-PM (Role-2) rather than departmental rooms — consistent with how masks #3–#5 were placed in departments, but flagged for `[audit]`.

## Notes
- `[verify not-duplicate of emi-stack payments]`: confirmed distinct (new `src/agents/` path; no services/agents client-mask dup).
- All legal/regulatory → `[counsel]`; contested room → `[pending human ratification]`.
- BANK-MASTER updated append-only (129 → 132); existing rows untouched; nothing committed.

---
**This does not replace legal advice.**
