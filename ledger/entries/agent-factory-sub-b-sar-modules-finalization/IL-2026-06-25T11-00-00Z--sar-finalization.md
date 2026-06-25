---
il_ts: 2026-06-25T11:00:00Z
session_id: agent-factory-sub-b-sar-modules-finalization
source: CEO
status: DONE
---
### SERVER-AUDIT-REQUIRED modules finalization — DECISION close (docs-only, no port, no unpack)

- **Objective:** Finalize the 4 SERVER-AUDIT-REQUIRED modules left by the residual register (IL-516) to final DROP/RESCOPE on documentary basis (canonical M0 inventory + tech-stack + EMI-license scope) — no full legacy unpack (ADR-103). Completes the BANXE.RAR → EMI migration DECISION phase.
- **Live audit (source of truth, not memory):** banxe-architecture origin/main@03f987f (IL max=519) → provisional max+1 frozen-at-merge per Rule 8 (MAIN rebases+regenerates). Full BANXE.RAR NOT unpacked locally — only /home/mmber/banxe-legacy-unpack/services/auth partial (verified) → documentary-basis decision is correct, not a shortcut. Open PR #767 (central skills-bind-group2) untouched.
- **Method:** close each module by the migration-decisive question (does any plausible internal detail change DROP/RESCOPE?) rather than an exhaustive code read. rebuild-not-port / tooling / schema-only / out-of-license-scope ⇒ inventory sufficient ⇒ SERVER-AUDIT-REQUIRED → RESOLVED; optional server-side reads recorded as non-blocking.
- **Verdicts (4/4 RESOLVED, none blocked):**
  - **neuron** (JS/PHP/TS web monolith, ~1.9M LOC, 6654 files): **RESCOPE/DROP** — monolith ≠ EMI microservice; domain signals thin (Wallets 785 "thin", Trading 120) and already COVERED by banxe→ledger/midaz_mcp; PHP web = banxe_site class (RESCOPE). RESOLVED (rebuild-not-port either way); optional non-blocking server-side salvage read before physical drop (does not gate DECISION).
  - **internal_dev** (JS/Python/Shell, ~660K LOC, 2087 files, 1 test): **DROP** — internal dev tooling/scripts, not an EMI prod service; replaced by EMI infra (scripts/deploy/n8n/CI). RESOLVED.
  - **ilink** (SQL only, ~2367 LOC, 37 files): **RESCOPE** — schema/data-integration fragment, no application service; covered by EMI data platform (ClickHouse/dbt/L-lake)+ETL, reconcile-not-port. RESOLVED.
  - **Trading-core** (crypto order-matching; banxe 536 + crypto-processing 213 + neuron 120): **DROP** — categorically outside EMI e-money-institution licence (no securities/crypto-exchange permission); regulatory determination, code-independent; consistent with residual register. RESOLVED.
- **Result:** with residual register (genuine-gap=0) + these 4 verdicts, the BANXE.RAR → EMI migration DECISION phase is COMPLETE — every legacy module/domain is COVERED, RESCOPE, or DROP; zero outstanding legacy-derived ports. Remaining value = depth/quality of covered services + 2 operator gates (M2.8 roster; KYC/KYB I-27).
- **STOP-CONDITION check:** no module's verdict required server-side code read to justify (each is rebuild-not-port / tooling / schema-only / out-of-scope); none fabricated; none left STILL-REQUIRED. neuron's optional salvage read is recorded as non-blocking, not as an unresolved blocker.
- **ADR-102 self-dup:** no prior SAR-finalization doc on main (verified absent) → non-duplicative; references residual register (IL-516) + M0 inventory, overwrites nothing.
- **Perimeter / canon:** docs/migration plane only; no secrets in repo (no .RAR unpack; full legacy stays on factory server, ADR-103); no port/scaffold/code; isolated worktree off origin/main@03f987f; signed commit; sub-B does NOT push/PR/merge — hands to MAIN per §71/§74.
- **Deliverable:** docs/migration/MIG-SAR-MODULES-FINALIZATION-2026-06-25.md.
- **Refs:** MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md (IL-516); banxe_legacy_inventory.md; banxe_legacy_domain_map.md; ADR-102/103/119; I-27/I-28; EMI-license scope.
