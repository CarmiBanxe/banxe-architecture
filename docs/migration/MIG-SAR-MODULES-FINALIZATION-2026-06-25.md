# MIG — SERVER-AUDIT-REQUIRED modules finalization (DECISION close, docs-only)

> **Type:** finalization of the 4 `SERVER-AUDIT-REQUIRED` modules left open by
> `MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md` (IL-516). Converts each to a final
> **DROP / RESCOPE** verdict on **documentary basis** (canonical inventory + tech-stack
> evidence + EMI-license scope) — **no full legacy unpack** (ADR-103: full code stays on the
> factory server; only `services/auth` is partially present locally — verified).
> **Stage:** DECISION close — *not* a port. No scaffold, no code, no secrets.
> **Canon:** factory-only; shell = read-only audit; ADR-102 dup-audit; ADR-103 server-only;
> ADR-119/I-28 append-only; live-verified (no memory). **Aggregator** — references the
> residual register + M0 inventory; overwrites nothing.

---

## 0. Live-audit baseline (re-verified, not memory)

| Item | Value (live) |
|---|---|
| `banxe-architecture` origin/main (audit) | `03f987f` (IL max = 519) |
| Residual register (predecessor) | `MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md` (IL-516) — residual legacy-derived genuine-gap = 0 |
| Legacy unpack state | full BANXE.RAR **NOT** unpacked locally; only `/home/mmber/banxe-legacy-unpack/services/auth` partial (verified) → documentary-basis decision (ADR-103) |
| Self dup-audit (ADR-102) | no prior SAR-finalization doc on main → non-duplicative |

Sources read: `banxe_legacy_inventory.md` (M0), `banxe_legacy_domain_map.md` (M0),
`MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md` (IL-516).

---

## 1. Method

The residual register marked 4 modules `SERVER-AUDIT-REQUIRED` — verdict pending a deeper read.
This doc closes each by asking the **migration-decisive** question rather than an exhaustive
code read: *does any plausible internal detail change the DROP/RESCOPE verdict?* When the
verdict is **rebuild-not-port** (architecture mismatch), **tooling** (not a prod service),
**schema-only** (covered by the data platform), or **out-of-license-scope** (regulatory, not
code-dependent), the canonical inventory is **sufficient** → `SERVER-AUDIT-REQUIRED` →
**RESOLVED**. Where a future server-side read would still add value, it is recorded as an
**optional, non-blocking** salvage step (it does not gate the verdict).

---

## 2. Finalization table

| Module | Stack / LOC (inventory) | Verdict | Rationale (inventory evidence) | EMI-scope note | SERVER-AUDIT status |
|---|---|---|---|---|---|
| **`neuron`** | JS/PHP/TS, ~1,907,679 LOC, 6 654 files (php 1 406 / ts 1 141) | **RESCOPE / DROP** (rebuild-not-port) | Mixed PHP+TS **web monolith**, not an EMI microservice. Its only domain signals are **thin**: Wallets/accounts 785 (domain-map: "neuron/digital thin") and Trading-core 120. The canonical, well-tested wallets slice is `banxe` (NestJS, 502 tests) → already **COVERED** by EMI `ledger`/`midaz_mcp`. PHP web portions = same class as `banxe_site` (already RESCOPE). | A monolith does not port 1:1 onto the EMI microservice architecture; EMI rebuilds the covered domains, it does not lift the monolith. | **RESOLVED** — verdict is rebuild-not-port regardless of internals. *Optional non-blocking:* a future server-side salvage read to confirm no unique domain logic is lost before physical drop (does not gate this DECISION). |
| **`internal_dev`** | JS/Python/Shell, ~660,775 LOC, 2 087 files (**1 test file**) | **DROP** | Internal **dev tooling / mixed scripts** (1 test across 2 087 files = not a production service). EMI provides its own infra/tooling (`scripts/`, `deploy/`, `n8n`, CI). No EMI prod-service target; nothing to port. | Dev tooling is out of the EMI **product** perimeter; replaced by the EMI infra stack. | **RESOLVED** — tooling, not a service; inventory sufficient. |
| **`ilink`** | SQL only, ~2,367 LOC, 37 files | **RESCOPE** | **SQL-only**, 37 files — schema/data-integration fragment, **no application service**. Belongs to schema reconcile, covered by the EMI **data platform** (ClickHouse / dbt / `L-lake`) + ETL, not a standalone microservice port. | Schema/ETL concern, not an EMI service; reconcile-if-needed in the data-platform track. | **RESOLVED** — SQL-only + small; documentary sufficient (reconcile is a data-platform task, not a port). |
| **Trading-core** | crypto order-matching (banxe 536 + crypto-processing 213 + neuron 120; typeorm/bignumber/graphql) | **DROP** | Crypto **order-matching / exchange** engine. EMI has `fx_exchange`/`fx_engine` but **no** order-matching engine — by design. Consistent with the residual register. | **Categorically outside the EMI (e-money institution) licence** — no securities/crypto-exchange permission. This is a **regulatory** determination, independent of code internals. | **RESOLVED** — license-scope is documentary/regulatory, not code-dependent. |

---

## 3. DECISION close

- All **4** `SERVER-AUDIT-REQUIRED` modules are **RESOLVED** to a final verdict on documentary
  basis: **`neuron` RESCOPE/DROP**, **`internal_dev` DROP**, **`ilink` RESCOPE**,
  **Trading-core DROP**. **None** remains blocked; **none** requires a full unpack into the repo.
- One **optional, non-blocking** follow-up is recorded: a server-side salvage read of `neuron`
  (largest surface, 1.9M LOC) to confirm no unique domain logic is lost **before** any physical
  drop — this does **not** gate the migration DECISION (the RESCOPE/DROP verdict holds either way).
- Combined with the residual register (legacy-derived genuine-gap = 0), the **BANXE.RAR → EMI
  migration DECISION phase is complete**: every legacy module/domain is COVERED, RESCOPE, or
  DROP, with zero outstanding legacy-derived ports. Remaining migration value = depth/quality of
  covered services + the two operator gates (M2.8 frontend roster; KYC/KYB I-27 HITL-L4).

### Next step (best-solution, for operator)
No port is unblocked by this close. If the operator wants the `neuron` optional salvage read, it
runs **read-only on the factory server** (ADR-103) and returns as a docs artifact — never an
unpack into the repo. Otherwise the DECISION phase can be marked closed.

---

## 4. Canon confirmations

- **No secrets in repo** — no `.RAR` unpacked here; full legacy stays on the factory server
  (ADR-103); audit was repo-side reading of M0 inventory docs only.
- **No port, no scaffold, no code** — DECISION-close only; verdicts recorded, nothing created.
- **Append-only** — additive doc; references the residual register (IL-516) + M0 inventory;
  overwrites nothing.

### Refs
`MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md` (IL-516), `banxe_legacy_inventory.md`,
`banxe_legacy_domain_map.md`; ADR-102, ADR-103, ADR-119; EMI-license scope (e-money institution).
