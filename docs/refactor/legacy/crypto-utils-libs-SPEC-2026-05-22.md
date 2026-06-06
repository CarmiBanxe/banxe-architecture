# Refactor SPEC — crypto utility libs consolidation

Date: 2026-05-22
Status: SPEC (design baseline; impl owned by Terminal B per House rule 10)
Scope: bitcoinjs-lib + wallet-address-validator + coinselect -> banxe-crypto-utils
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/crypto-api/ on evo1
Related: SPEC #1 crypto-api-keys-lib; ADR-021 WalletPort; ADR-017 vendor-to-os
Owner: Central authors SPEC; Terminal B owns impl

## Purpose

Consolidate three legacy crypto utility libs (deps of crypto-api-keys-lib SPEC #1) into one NEW package banxe-crypto-utils. All three are forks of upstream OSS with minimal BANXE-specific mods. This SPEC decides per lib: drop fork (use upstream), inline modification, or keep thin wrapper. Without this consolidation SPEC #1 cannot be implemented.

## Legacy inventory (read-only audit 2026-05-22)

### 1. bitcoinjs-lib (fork of bitcoinjs/bitcoinjs-lib v5.2.0)

- Path: crypto-api/bitcoinjs-lib
- Lang: TypeScript, Node >=8 (EOL)
- Size: 2.5 MB
- Upstream now: v7.x (2026)
- BANXE mods: EMC network fix; bech32 1.1.4 lock; tiny-secp256k1 lock; version locks
- Tests: ecpair, script, transaction, address, payments, block, classify, bitcoin.core

### 2. wallet-address-validator (fork of OSS multi-altcoin validator)

- Path: crypto-api/wallet-address-validator
- Lang: plain JS, no TypeScript
- Size: 696 KB
- Coverage: 20+ altcoins (BTC, BCH, LTC, Decred, DOGE, ETH, XRP, DASH, NEO, ZCash, Qtum, Monero, Segwit, Nano, Vertcoin, EMC)
- Modules: bitcoin_validator.js, ethereum_validator.js, monero_validator.js, ripple_validator.js, currencies.js
- BANXE mods: EMC validator added; Nano support; Vertcoin segwit
- Tests: karma + Travis CI

### 3. coinselect-with-decimals-feerate (fork of bitcoinjs/coinselect v3.1.12)

- Path: crypto-api/coinselect-with-decimals-feerate
- Lang: plain JS, minimal
- Size: 152 KB
- Upstream now: v3.x by Daniel Cousens
- Modules: accumulative.js, blackjack.js, break.js, index.js, utils.js
- BANXE mod: all fees ceil-rounded (decimal feerate handling)
- Tests: mocha

## Decision per lib

### bitcoinjs-lib fork: DROP
- Reason: Upstream v7.x is well-maintained; v5.2.0 fork is 2 major versions behind.
- BANXE mods (EMC network, version locks) are no longer needed: EMC is DROP per SPEC #1; version locks were workarounds for old Node.
- Replacement: use upstream bitcoinjs-lib v7.x as transient dep, but prefer @noble/curves + @scure/btc-signer for new code per SPEC #1.
- Migration: zero code in banxe-crypto-utils from this fork; lessons-learned doc only.

### wallet-address-validator fork: DROP
- Reason: Plain JS, no types, 696 KB for 20+ altcoins where NEW only needs 5-6 chains.
- BANXE mods (EMC, Nano, Vertcoin) all map to DROP chains in SPEC #1.
- Replacement: chain-native validators in banxe-crypto-utils/src/chains/hain>/address.ts using @noble + chain rules.
- Migration: zero code; reference only.

### coinselect fork: INLINE THE MODIFICATION
- Reason: 152 KB minimal lib; only mod is "all fees ceil-rounded" for decimal feerate.
- Decision: keep upstream coinselect v3.x as dep; add thin wrapper banxe-crypto-utils/src/coinselect-ceil.ts that applies Math.ceil to feerate before delegating.
- Alternative: PR upstream (low confidence; project is mature, slow merges).
- Migration: copy the one-line ceil modification logic; tests required.

## Legacy to NEW mapping

| Legacy lib | NEW location | Verdict | Migration effort |
|---|---|---|---|
| bitcoinjs-lib (fork) | (none; SPEC #1 uses @noble + @scure) | DROP | zero code; reference only |
| wallet-address-validator (fork) | banxe-crypto-utils/src/chains/*/address.ts | DROP fork | rewrite per chain (5-6 chains only) |
| coinselect (fork) | banxe-crypto-utils/src/coinselect-ceil.ts (thin wrapper) | INLINE mod | one-line ceil wrapper + tests |

Net result: 3.3 MB of legacy code reduced to ~5 KB wrapper + 6 chain-native validators (~50 lines each).

## Refactor strategy (Phases tied to SPEC #1)

- Phase A (done): inventory + decision per lib (this SPEC).
- Phase B (Terminal B): scaffold banxe-crypto-utils repo as part of SPEC #1 Phase B.
- Phase C (Terminal B): chain-native validators + coinselect-ceil wrapper alongside WalletPort adapters.
- Phase D (Terminal B): contract tests compare legacy validator vs new validator for the 5-6 KEEP chains.
- Phase E (Terminal B): remove the three legacy forks from NEW dep tree; verify with ripgrep.
- Phase F (Terminal B): tag forks ARCHIVE in BANXE.RAR mirror; record decommission in IL.

This SPEC progresses lock-step with crypto-api-keys-lib-SPEC-2026-05-22; no independent timeline.

## Risk register tie-in

- R-MIG-02 (legacy on evo1 only): mirror all three fork dirs to off-evo1 backup per R4 PREP.
- R-SEC-NEW-01 (crypto regressions): contract tests against legacy validators for the 5-6 KEEP chains; zero-mismatch threshold.
- R-MIG-LICENSE-01 (fork divergence): diff each fork vs upstream tag before Phase C; record divergence here.

## Acceptance criteria

- All three forks DROP/INLINE decisions implemented per this SPEC.
- No legacy fork import remaining in NEW dep tree (verified by ripgrep).
- coinselect-ceil wrapper has unit tests covering Math.ceil feerate behaviour.
- Chain-native validators in banxe-crypto-utils match legacy validator output for 5-6 KEEP chains on 100+ test vectors.

## References

- crypto-api-keys-lib-SPEC-2026-05-22.md (parent SPEC; this is its dependency layer)
- ADR-021 five-new-ports (WalletPort)
- ADR-017 vendor-to-OpenSource policy
- REFACTOR_MASTER_PLAN.md (270-project Transform-first plan)
- CLASS_KEEP.tsv (three KEEP-EXTRACT rows for these libs)
- RISK_REGISTER-2026-05-22.md (R-MIG-02, R-SEC-NEW-01, R-MIG-LICENSE-01)
- UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10)

=== END OF crypto-utils-libs SPEC (snapshot ef4b7db) ===

## NEW capability anchor (per NEW-PROJECT-PRIORITY-MAP canon)

Serves NEW capabilities C1 (custody primitives) + C2 (crypto address validation) per ADR-021 WalletPort. Canon: NEW drives legacy reuse — these three forks are reused only because C1/C2 need their crypto primitives and validators; the fork modifications (EMC, version locks) are dropped because no NEW capability needs them. No decision change; NEW-need-first justification confirmed.
