# Refactor SPEC — crypto-api-keys-lib (legacy → banxe-crypto-utils + WalletPort)

Date: 2026-05-22
Status: SPEC (design baseline; binding implementation owned by Terminal B per House rule 10)
Source: legacy BANXE.RAR @ /home/banxe/banxe-rar-extracted/crypto-api/crypto-api-keys-lib (evo1)
Related: CLASS_KEEP.tsv (KEEP-EXTRACT row: multi-chain wallet SDK 15 networks); ADR-021 five-new-ports (WalletPort); ADR-017 vendor-to-os; REFACTOR_MASTER_PLAN.md
Owner: Central authors this SPEC; Terminal B owns implementation in NEW banxe-crypto-utils repo

## Purpose

Specify the smart refactor of the legacy `crypto-api-keys-lib` TypeScript SDK into the NEW EMI BANXE AI BANK ecosystem as the foundational implementation behind `WalletPort` (one of the five Hexagonal Ports per ADR-021). This SPEC produces an actionable design baseline that Terminal B can execute without further discovery work.

## Legacy inventory (read-only audit, 2026-05-22)

- Repo path: /home/banxe/banxe-rar-extracted/crypto-api/crypto-api-keys-lib
- Language: TypeScript (tsdx build, ts-node tests)
- Version: 0.0.13 (pre-1.0, API not stable)
- Author: single committer "noa" (bus-factor risk)
- License: MIT
- Size: 2.2 MB without node_modules/.git
- Node engine: >=10 (EOL, must be >=18 for NEW)
- Test framework: mocha + ts-node; 11 spec files (eth, btc, ltc, bch, eos, ripple, bsv, dash, emc, xdg, validate-addresses)
- Build entry: src/index.ts → dist/index.js + dist/index.d.ts (CJS + ESM dual export)

## Supported blockchains (15 networks confirmed)

From src/blockchains/ + README:

| # | Blockchain | File | Family | EMI relevance | Refactor verdict |
|---|---|---|---|---|---|
| 1 | Bitcoin | bitcoin.ts | UTXO | HIGH (custody) | KEEP |
| 2 | BitcoinSV | bitcoinsv.ts | UTXO fork | LOW | DROP (out-of-scope for EMI) |
| 3 | BitcoinCash | bitcoin-cash.ts | UTXO fork | LOW | DROP |
| 4 | Litecoin | litecoin.ts | UTXO fork | MID | KEEP (popular settlement) |
| 5 | Dogecoin | dogecoin.ts | UTXO fork | LOW | DROP (meme; FCA AML risk) |
| 6 | Ethereum | ethereum.ts | EVM | HIGH | KEEP (USDC/USDT settlement) |
| 7 | Binance (BSC) | binance.ts | EVM L1 | HIGH | KEEP (USDT settlement) |
| 8 | Tron (TRX) | tron.ts | UTXO-EVM hybrid | HIGH | KEEP (USDT-TRC20 settlement) |
| 9 | EOS | eos.ts | DPoS | LOW | DROP (negligible volume) |
| 10 | Ripple (XRP) | ripple.ts | DLT | MID | REVIEW (legal status) |
| 11 | Emercoin | emercoin.ts | UTXO | LOW | DROP |
| 12 | Dashcoin | dashcoin.ts | UTXO privacy | LOW | DROP (privacy coin, AML risk) |
| 13 | Polkadot | polkadot.ts | substrate | LOW | DROP |
| 14 | Terra v2 | terra20.ts | Cosmos SDK | LOW | DROP (post-Luna collapse) |
| 15 | Terra Classic | terra-classic.ts | Cosmos SDK legacy | LOW | DROP |

NEW WalletPort target coverage: 5 KEEP (Bitcoin, Litecoin, Ethereum, BSC, Tron), 1 REVIEW (Ripple), 9 DROP (audit-traceable but not in production).

## Strategic value

- Foundational dependency for WalletPort (ADR-021): without a stable multi-chain SDK, WalletPort is theoretical.
- Reuses 5 production-relevant blockchain modules already tested in legacy (BTC, LTC, ETH, BSC, TRX).
- Replaces the deprecated `ripple-lib 1.6.0` with modern `xrpl.js` if XRP survives REVIEW.
- Removes 9 unused blockchains, cutting attack surface and audit perimeter.
- Removes two internal GitLab fork dependencies (`bitcoinjs-lib`, `wallet-address-validator`) — see Dependencies migration section.
- Authoring shifts from one bus-factor developer to the BANXE engineering team with code review on every change.

## Legacy → NEW mapping

| Legacy artefact | NEW location | Verdict | Notes |
|---|---|---|---|
| src/index.ts | banxe-crypto-utils/src/index.ts | TRANSFORM | Export shape stays; impl rewritten as factory pattern. |
| src/types.ts | banxe-crypto-utils/src/types.ts | TRANSFORM | Add discriminated unions; drop EOS/Polkadot/Terra/etc enum values. |
| src/network-configs.ts | banxe-crypto-utils/src/networks.ts | TRANSFORM | Keep only KEEP-marked chain configs (5+1). |
| src/blockchains/bitcoin.ts | banxe-crypto-utils/src/chains/bitcoin/ | KEEP-REWRITE | Replace bip32+bitcoinjs-lib fork with upstream noble-curves + scure-bip32. |
| src/blockchains/bitcoin-base.ts | banxe-crypto-utils/src/chains/bitcoin/base.ts | KEEP-REWRITE | Same. |
| src/blockchains/litecoin.ts | banxe-crypto-utils/src/chains/litecoin/ | KEEP-REWRITE | Same family as bitcoin. |
| src/blockchains/ethereum.ts | banxe-crypto-utils/src/chains/evm/ethereum.ts | KEEP-REWRITE | Replace ethereumjs-tx (v2 EOL) with viem 2.x. |
| src/blockchains/binance.ts | banxe-crypto-utils/src/chains/evm/bsc.ts | KEEP-REWRITE | Reuse EVM module; BSC is just a chainId. |
| src/blockchains/tron.ts | banxe-crypto-utils/src/chains/tron/ | KEEP-REWRITE | Replace internal signer with tronweb 6.x. |
| src/blockchains/ripple.ts | banxe-crypto-utils/src/chains/ripple/ | REVIEW | Conditional on legal review; if KEEP, use xrpl.js 4.x not ripple-lib 1.x. |
| src/blockchains/{bsv-base,bitcoinsv,bitcoin-cash,dogecoin,emercoin,dashcoin,polkadot,terra20,terra-classic,eos}.ts | ARCHIVE-RESEARCH | DROP | Not in NEW WalletPort coverage; keep in legacy archive for forensic audit. |
| src/blockchains/address-utils.ts | banxe-crypto-utils/src/address.ts | TRANSFORM | Validate via noble + chain-specific checks; remove wallet-address-validator fork dep. |
| src/utils.ts, src/lib.ts | banxe-crypto-utils/src/internal/ | TRANSFORM | Internal helpers; review each for vendor lock-in. |
| tests/*.spec.ts | banxe-crypto-utils/tests/ | KEEP | Mocha → vitest; same test vectors must pass on NEW. |
| tests/fixtures/vectors.ts | banxe-crypto-utils/tests/fixtures/vectors.ts | KEEP-AS-IS | Test vectors are reference data; do not regenerate. |

## WalletPort contract (Hexagonal port, ADR-021)

The WalletPort interface that banxe-crypto-utils implements (or supports as a default adapter):

```typescript
export type ChainId = "BTC" | "LTC" | "ETH" | "BSC" | "TRX" | "XRP";

export interface WalletAddress {
  chain: ChainId;
  address: string;
  derivationPath: string;
}

export interface SignedTx {
  chain: ChainId;
  rawTx: string;
  txHash: string;
}

export interface WalletPort {
  // seed phrase ops
  generateSeedPhrase(wordCount: 12 | 24): Promise<string>;
  seedPhraseToEntropy(phrase: string): Promise<Uint8Array>;

  // key derivation
  deriveAddress(seed: Uint8Array, chain: ChainId, path: string): Promise<WalletAddress>;

  // tx ops
  signTx(seed: Uint8Array, chain: ChainId, path: string, txPayload: unknown): Promise<SignedTx>;
  verifySignature(chain: ChainId, address: string, message: string, signature: string): Promise<boolean>;

  // address validation
  validateAddress(chain: ChainId, address: string): Promise<boolean>;

  // encryption helpers (sodium replacement)
  encrypt(plaintext: string, password: string): Promise<string>;
  decrypt(ciphertext: string, password: string): Promise<string>;
}
```

Contract notes:
- Six chains only in initial WalletPort coverage; remaining nine legacy chains live in ARCHIVE-RESEARCH and do not enter the production NEW path.
- All async by default (legacy mixed sync/async; NEW unifies).
- Seed material flows as Uint8Array, never as raw hex string outside encrypt/decrypt boundary.
- Adapter contract tests (one set, multiple adapters) must pass for every implementation candidate.

## Refactor strategy (Phases A-F per TRADING_REFACTOR_TASKS pattern)

### Phase A — Inventory (this SPEC)
- [x] Legacy structure inventory (src/blockchains/, tests/, package.json, README) — done in this SPEC.
- [x] 15 blockchains classified to KEEP / REVIEW / DROP — done in Legacy inventory table.
- [x] WalletPort contract drafted — done above.
- [x] Vendor dependency audit (ethereumjs-tx EOL, ripple-lib 1.x deprecated, two internal GitLab forks) — done.

### Phase B — Extraction (Terminal B, S22 or earlier)
- [ ] Create empty NEW repo banxe-crypto-utils (Node >=18, TypeScript 5+, vitest, tsup build).
- [ ] Copy tests/fixtures/vectors.ts AS-IS into NEW; this is reference data, not implementation.
- [ ] Migrate 11 legacy mocha specs (eth, btc, ltc, bch, eos, ripple, bsv, dash, emc, xdg, validate-addresses) to vitest; mark eos/bsv/bch/emc/xdg/dash as `describe.skip` (DROP chains, kept for forensic).
- [ ] Re-run kept tests against unchanged legacy impl as baseline (CI green = no regression target later).

### Phase C — Port + Adapters (Terminal B, S22 implementation)
- [ ] Implement WalletPort interface in banxe-crypto-utils/src/port.ts.
- [ ] Implement BitcoinAdapter using noble-curves + scure-bip32 (replaces bitcoinjs-lib fork).
- [ ] Implement LitecoinAdapter reusing Bitcoin family code with LTC params.
- [ ] Implement EvmAdapter (ETH + BSC sharing one impl via chainId).
- [ ] Implement TronAdapter using tronweb 6.x.
- [ ] Implement RippleAdapter conditional on legal REVIEW outcome (xrpl.js 4.x).
- [ ] Contract tests pass for all 5 (or 6) adapters against one shared test set.

### Phase D — Shadow mode (Terminal B, S23 QA + Production Ready)
- [ ] Run legacy and NEW side-by-side in a controlled non-prod environment.
- [ ] Diff outputs of generateSeedPhrase, deriveAddress, signTx, validateAddress for every supported chain.
- [ ] Alert on any mismatch above noise floor (0 mismatches expected for deterministic ops).

### Phase E — Cut-over (Terminal B, S24 FCA Submission)
- [ ] Replace legacy crypto-api-keys-lib imports in NEW services with banxe-crypto-utils.
- [ ] Remove legacy crypto-api-keys-lib from NEW dependency tree.
- [ ] Final security review by SecOps before FCA submission package.

### Phase F — Decommission (Terminal B, S25 Go-Live)
- [ ] Tag legacy crypto-api-keys-lib v0.0.13 ARCHIVE in BANXE.RAR mirror.
- [ ] Document the decommission in INSTRUCTION-LEDGER.md.
- [ ] No legacy import remaining anywhere in the NEW dependency tree.

## Dependencies migration (vendor lock-in resolution)

| Legacy dep | Replacement in NEW | Reason |
|---|---|---|
| bitcoinjs-lib (internal GitLab fork) | @noble/curves + @scure/bip32 + @scure/bip39 | Audited, zero-dep, modern crypto primitives. |
| wallet-address-validator (internal GitLab fork) | chain-native address checks via noble + custom validators | Remove fork dependency; avoid second GitLab pull. |
| ethereumjs-tx 2.x | viem 2.x | Original is EOL; viem is the de-facto EVM client in 2026. |
| ethereumjs-util 7.x | viem utils | Same. |
| @ethereumjs/tx 3.5 | viem 2.x | Same. |
| ethers 5.5.1 | viem 2.x | Smaller bundle; type-safe; better tree-shaking. |
| eosjs 21.x / eosjs-ecc 4.x | DROP | EOS not in NEW WalletPort. |
| ripple-lib 1.6.0 + ripple-keypairs + ripple-address-codec | xrpl.js 4.x (only if REVIEW = KEEP) | ripple-lib 1.x is deprecated by Ripple itself. |
| @polkadot/api 4.x | DROP | Polkadot not in NEW WalletPort. |
| @terra-money/terra.js 3.x | DROP | Terra not in NEW WalletPort. |
| bchaddrjs | DROP | Bitcoin Cash not in NEW WalletPort. |
| sodium-plus | @noble/ciphers (xchacha20poly1305) | Pure-JS, audited, smaller. |
| create-hash, elliptic | @noble/hashes + @noble/curves | Audited, modern. |
| bip32 2.x | @scure/bip32 | Upstream maintained, audited. |
| bip39 3.x | @scure/bip39 | Same. |
| node-fetch 2.x | native fetch (Node 18+) | Built-in; no extra dep. |

Net result: dependency tree shrinks from ~25 packages (many transitive deep) to ~6 audited primitives + 2 chain-specific clients (viem, tronweb). Removes both internal GitLab pull-credentials from CI.

## Risk register tie-in

| Risk ID | Description | Mitigation |
|---|---|---|
| R-MIG-02 | Legacy source code physically present only on evo1 (single point); loss = total refactor blocker. | Mirror /home/banxe/banxe-rar-extracted/crypto-api/crypto-api-keys-lib to off-evo1 backup (R4 PREP scope); take SHA256 of tests/fixtures/vectors.ts. |
| R-SEC-NEW-01 | Migration introduces new crypto code paths; key-derivation regressions = customer fund loss. | Phase D shadow mode mandatory; zero-mismatch threshold for deterministic ops (deriveAddress, signTx with same input). |
| R-MIG-LICENSE-01 | Two internal GitLab forks (bitcoinjs-lib, wallet-address-validator) may carry undocumented modifications. | Phase A audit diff of forks vs upstream; document any divergence in this SPEC before Phase C starts. |
| R-OPS-AUTHOR-01 | Single author "noa" of legacy SDK; no review history. | NEW banxe-crypto-utils enforces 2-reviewer rule on every PR per R5 governance. |
| R-COMP-FCA-01 | Six chains in NEW (BTC LTC ETH BSC TRX XRP-conditional) must each have AML provenance check before customer flow. | Tie WalletPort initialisation to a Travel Rule v2 ready check (R-REG-03 in RISK_REGISTER 2026-05-22). |

## Acceptance criteria (DONE definition for this refactor)

The refactor of crypto-api-keys-lib into banxe-crypto-utils is DONE when ALL of the following are observed:

- Phase A done (this SPEC merged into main).
- Phase B done (empty NEW repo + migrated tests baseline green).
- Phase C done (6-chain WalletPort adapters, contract tests green).
- Phase D done (shadow mode 0 mismatches over 14 days).
- Phase E done (no legacy crypto-api-keys-lib import remains in NEW dependency tree; verified by ripgrep).
- Phase F done (legacy v0.0.13 tagged ARCHIVE; IL entry recorded; final security review signed).
- Acceptance criteria of WalletPort itself (per ADR-021) satisfied.
- R-MIG-02, R-SEC-NEW-01, R-MIG-LICENSE-01, R-OPS-AUTHOR-01, R-COMP-FCA-01 each marked CLOSED or MITIGATED in RISK_REGISTER refresh.

## Open questions

- Should Ripple (XRP) survive the legal REVIEW? Owner: Legal + MLRO. Blocks Phase C RippleAdapter.
- Should Litecoin remain in NEW WalletPort given declining settlement volume? Owner: Treasury. Re-evaluate at Phase C kickoff.
- Where does the banxe-crypto-utils NEW repo live (separate GitHub repo vs monorepo subpackage)? Owner: Terminal B + Architecture WG.
- Does Travel Rule v2 enforcement happen inside WalletPort or upstream in NEW transaction module? Owner: Compliance + Architecture WG.
- Will Phase D shadow mode share infrastructure with R3 webhook telemetry, or build its own diff sink? Owner: SRE + Terminal B.

## References

- Legacy source path: /home/banxe/banxe-rar-extracted/crypto-api/crypto-api-keys-lib (evo1, read-only audit 2026-05-22)
- ADR-021 — five new Hexagonal Ports (WalletPort definition)
- ADR-017 — vendor-to-OpenSource migration policy
- REFACTOR_MASTER_PLAN.md (270-project Transform-first plan; this SPEC instantiates one KEEP-EXTRACT row)
- CLASS_KEEP.tsv (row: crypto-api/crypto-api-keys-lib → KEEP-EXTRACT → banxe-crypto-utils Multi-chain wallet SDK 15 networks)
- TRADING_REFACTOR_TASKS.md (Phase A-F naming convention reused here)
- RISK_REGISTER-2026-05-22.md (R-MIG-02 + adjacent risks)
- UNIVERSAL-CANON-2026-05-22.md (section 8 R0-DISCOVERY rules; section 13 ranked priority)
- UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10; Central authors SPEC, Terminal B implements)
- R-TRACKS-CLOSURE-AUDIT-2026-05-22.md (R-tracks 9/9 status snapshot)

=== END OF crypto-api-keys-lib REFACTOR SPEC (snapshot ef4b7db) ===

## NEW capability anchor (per NEW-PROJECT-PRIORITY-MAP canon)

Serves NEW capability C1 (Multi-chain custody: key gen, derive, sign) per ADR-021 WalletPort. Canon: NEW drives legacy reuse — the 5 KEEP chains were selected by NEW EMI custody need, not by legacy presence; the 9 DROP chains are anti-mapped (legacy code exists but no NEW custody need). No decision change; NEW-need-first justification confirmed.
