# WalletPort CONTRACT SPEC — executable contract (custody-critical)

Date: 2026-06-06
Status: CONTRACT SPEC (executable; deepens SPEC #1 WalletPort; custody-critical, zero-mismatch conformance)
Scope: canonical WalletPort contract — types, operations, determinism rules, key-material handling, conformance tests
Source SPECs: crypto-api-keys-lib-SPEC-2026-05-22.md; crypto-utils-libs-SPEC-2026-05-22.md
Related: ADR-021 five-new-ports (WalletPort); RISK_REGISTER R-SEC-NEW-01 (key-derivation regression = fund loss); R-COMP-FCA-01
Owner: Terminal B (smart refactor) authors contract + owns Phase C adapter impl

## Purpose

SPEC #1 defined WalletPort at a high level. This CONTRACT SPEC turns it into an executable, custody-critical contract. Because key derivation and signing govern customer funds, every deterministic operation has a ZERO-mismatch conformance requirement against fixed test vectors. Terminal B implements BitcoinAdapter, LitecoinAdapter, EvmAdapter, TronAdapter (and conditional RippleAdapter) against this contract with no design ambiguity.

## Contract types

```typescript
export type ChainId = "BTC" | "LTC" | "ETH" | "BSC" | "TRX" | "XRP";
export type DerivationPath = string; // BIP-44, e.g. m/44'/0'/0'/0/0

export interface WalletAddress {
  chain: ChainId;
  address: string;
  derivationPath: DerivationPath;
  publicKey: string; // hex
}

export interface SignedTx {
  chain: ChainId;
  rawTx: string;  // hex / chain-native serialized
  txHash: string; // deterministic for given input
}

export interface SeedMaterial {
  // never logged, never persisted in plaintext, never crosses a network boundary
  entropy: Uint8Array;
}
```

Key-material handling rules:
- SeedMaterial.entropy is Uint8Array in memory only; never string, never logged, never sent over network.
- No adapter persists raw seed/private key; only encrypted blobs via encrypt()/decrypt().
- All key derivation happens in-process; no remote signing service in the base adapters.

## Operations

```typescript
export interface WalletPort {
  generateSeedPhrase(wordCount: 12 | 24): Promise<string>;
  seedPhraseToEntropy(phrase: string): Promise<SeedMaterial>;
  deriveAddress(seed: SeedMaterial, chain: ChainId, path: DerivationPath): Promise<WalletAddress>;
  signTx(seed: SeedMaterial, chain: ChainId, path: DerivationPath, txPayload: unknown): Promise<SignedTx>;
  verifySignature(chain: ChainId, address: string, message: string, signature: string): Promise<boolean>;
  validateAddress(chain: ChainId, address: string): Promise<boolean>;
  encrypt(plaintext: string, password: string): Promise<string>;
  decrypt(ciphertext: string, password: string): Promise<string>;
}
```

## Determinism rules (custody-critical)

- deriveAddress: given identical (seed, chain, path), MUST return byte-identical address + publicKey across legacy and NEW. ZERO mismatch tolerance.
- signTx: given identical (seed, chain, path, txPayload), MUST return identical txHash. ZERO mismatch tolerance for deterministic-nonce chains; for chains with random nonce (some ECDSA), signature MAY differ but MUST verify and produce identical spendable outcome.
- seedPhraseToEntropy: BIP-39 standard; identical phrase -> identical entropy.
- generateSeedPhrase: NON-deterministic (CSPRNG); the only operation allowed to differ between calls.
- encrypt/decrypt: roundtrip MUST recover plaintext; ciphertext MAY differ (random nonce) but decrypt(encrypt(x)) == x always.

## Conformance test suite (zero-mismatch, all adapters)

Reuse legacy tests/fixtures/vectors.ts from crypto-api-keys-lib AS-IS (reference data, never regenerated). Every adapter MUST pass:

1. seedPhraseToEntropy(known phrase) -> exact entropy from vectors.
2. deriveAddress(seed, chain, path) -> EXACT address + publicKey from vectors. ZERO mismatch.
3. deriveAddress across 10+ paths per chain -> all match vectors.
4. signTx(seed, chain, path, fixed tx) -> txHash matches vector (deterministic chains); verifies + spendable (random-nonce chains).
5. verifySignature(valid sig) -> true; tampered sig -> false.
6. validateAddress(valid per chain) -> true; malformed -> false; wrong-chain address -> false.
7. encrypt then decrypt -> original plaintext recovered.
8. decrypt(wrong password) -> throws, never returns garbage.
9. SeedMaterial never appears in any log line (assert via log capture).
10. Cross-check legacy crypto-api-keys-lib output vs NEW banxe-crypto-utils output for all 6 chains -> ZERO diff on deterministic ops (Phase D shadow gate).

Any single mismatch on a deterministic op BLOCKS Phase E cut-over (funds-at-risk).

## Acceptance criteria

- WalletPort interface frozen as defined here; changes require CONTRACT revision.
- 5-6 adapters (BTC, LTC, ETH, BSC, TRX, conditional XRP) each pass the 10-test conformance suite with ZERO deterministic mismatch.
- Legacy tests/fixtures/vectors.ts reused unchanged as the reference oracle.
- SeedMaterial handling rules enforced (no logging, no plaintext persistence, no network egress of key material).
- Phase D shadow comparison: 0 mismatches over the full vector set before any production wallet creation.

## References

- crypto-api-keys-lib-SPEC-2026-05-22.md (parent SPEC #1; high-level WalletPort + 15-chain classification)
- crypto-utils-libs-SPEC-2026-05-22.md (@noble/@scure crypto primitives)
- ADR-021 five-new-ports (WalletPort)
- RISK_REGISTER-2026-05-22.md (R-SEC-NEW-01 key-derivation regression = fund loss; R-COMP-FCA-01)
- emi-banking-partnerport-CONTRACT-SPEC-2026-06-06.md (sibling CONTRACT SPEC pattern)
- BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md
- UNIVERSAL-CANON 2026-05-22 + TOPOLOGY + BEST-SOLUTION-AND-SEQUENTIAL (House rules 1-12)

=== END OF WalletPort CONTRACT SPEC (executable; custody-critical; zero-mismatch) ===
