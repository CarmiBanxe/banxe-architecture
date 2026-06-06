# WalletPort CONTRACT SPEC — executable contract (custody-critical)

Date: 2026-06-06
Status: CONTRACT SPEC (executable; deepens SPEC #1 WalletPort; custody-critical, zero-mismatch conformance)
Scope: canonical WalletPort contract — types, operations, determinism rules, key-material handling, conformance tests
Source SPECs: crypto-api-keys-lib-SPEC-2026-05-22.md; crypto-utils-libs-SPEC-2026-05-22.md
Related: ADR-021 five-new-ports (WalletPort); RISK_REGISTER R-SEC-NEW-01 (key-derivation regression = fund loss); R-COMP-FCA-01
Owner: Terminal B (smart refactor) authors contract + owns Phase C adapter impl

Build target: CarmiBanxe/banxe-payment-core (pure Python)
Build scope: src/wallet/**
Output type: contract-code
Port style: abc.ABC + @abstractmethod async coroutines, @dataclass value types, Enum closed sets — consistent with src/ports/{ledger,issuer,payment_switch}_port.py

## Purpose

SPEC #1 defined WalletPort at a high level. This CONTRACT SPEC turns it into an executable, custody-critical contract. Because key derivation and signing govern customer funds, every deterministic operation has a ZERO-mismatch conformance requirement against fixed test vectors. Terminal B implements BitcoinAdapter, LitecoinAdapter, EvmAdapter, TronAdapter (and conditional RippleAdapter) against this contract with no design ambiguity.

## Language surface

This contract is frozen. Only the language surface is rendered in Python here; no method, parameter, type, or semantic differs from the original TypeScript contract. Translation map: `Promise<T>` → `async def … -> T`; `Uint8Array` → `bytes`; string-literal union → `enum.Enum`; `interface` → `abc.ABC` / `@dataclass`; `12 | 24` literal → `typing.Literal[12, 24]`; `unknown` → `object` (top type, must be narrowed); camelCase identifiers → snake_case (idiomatic Python, matches existing ports).

## Contract types

```python
from dataclasses import dataclass
from enum import Enum


class ChainId(Enum):
    BTC = "BTC"
    LTC = "LTC"
    ETH = "ETH"
    BSC = "BSC"
    TRX = "TRX"
    XRP = "XRP"


DerivationPath = str  # BIP-44, e.g. m/44'/0'/0'/0/0


@dataclass
class WalletAddress:
    chain: ChainId
    address: str
    derivation_path: DerivationPath
    public_key: str  # hex


@dataclass
class SignedTx:
    chain: ChainId
    raw_tx: str  # hex / chain-native serialized
    tx_hash: str  # deterministic for given input


@dataclass
class SeedMaterial:
    # never logged, never persisted in plaintext, never crosses a network boundary
    entropy: bytes
```

Key-material handling rules:
- SeedMaterial.entropy is bytes in memory only; never str, never logged, never sent over network.
- No adapter persists raw seed/private key; only encrypted blobs via encrypt()/decrypt().
- All key derivation happens in-process; no remote signing service in the base adapters.

## Operations

```python
from abc import ABC, abstractmethod
from typing import Literal


class WalletPort(ABC):
    @abstractmethod
    async def generate_seed_phrase(self, word_count: Literal[12, 24]) -> str: ...

    @abstractmethod
    async def seed_phrase_to_entropy(self, phrase: str) -> SeedMaterial: ...

    @abstractmethod
    async def derive_address(
        self, seed: SeedMaterial, chain: ChainId, path: DerivationPath
    ) -> WalletAddress: ...

    @abstractmethod
    async def sign_tx(
        self, seed: SeedMaterial, chain: ChainId, path: DerivationPath, tx_payload: object
    ) -> SignedTx: ...

    @abstractmethod
    async def verify_signature(
        self, chain: ChainId, address: str, message: str, signature: str
    ) -> bool: ...

    @abstractmethod
    async def validate_address(self, chain: ChainId, address: str) -> bool: ...

    @abstractmethod
    async def encrypt(self, plaintext: str, password: str) -> str: ...

    @abstractmethod
    async def decrypt(self, ciphertext: str, password: str) -> str: ...
```

## Determinism rules (custody-critical)

- derive_address: given identical (seed, chain, path), MUST return byte-identical address + public_key across legacy and NEW. ZERO mismatch tolerance.
- sign_tx: given identical (seed, chain, path, tx_payload), MUST return identical tx_hash. ZERO mismatch tolerance for deterministic-nonce chains; for chains with random nonce (some ECDSA), signature MAY differ but MUST verify and produce identical spendable outcome.
- seed_phrase_to_entropy: BIP-39 standard; identical phrase -> identical entropy.
- generate_seed_phrase: NON-deterministic (CSPRNG); the only operation allowed to differ between calls.
- encrypt/decrypt: roundtrip MUST recover plaintext; ciphertext MAY differ (random nonce) but decrypt(encrypt(x)) == x always.

## Conformance test suite (zero-mismatch, all adapters)

Reuse legacy conformance vectors from crypto-api-keys-lib AS-IS (reference data, never regenerated), relocated to the Python-reachable oracle tests/fixtures/vectors.py. Every adapter MUST pass:

1. seed_phrase_to_entropy(known phrase) -> exact entropy from vectors.
2. derive_address(seed, chain, path) -> EXACT address + public_key from vectors. ZERO mismatch.
3. derive_address across 10+ paths per chain -> all match vectors.
4. sign_tx(seed, chain, path, fixed tx) -> tx_hash matches vector (deterministic chains); verifies + spendable (random-nonce chains).
5. verify_signature(valid sig) -> True; tampered sig -> False.
6. validate_address(valid per chain) -> True; malformed -> False; wrong-chain address -> False.
7. encrypt then decrypt -> original plaintext recovered.
8. decrypt(wrong password) -> raises, never returns garbage.
9. SeedMaterial never appears in any log line (assert via log capture).
10. Cross-check legacy crypto-api-keys-lib output vs NEW banxe-crypto-utils output for all 6 chains -> ZERO diff on deterministic ops (Phase D shadow gate).

Any single mismatch on a deterministic op BLOCKS Phase E cut-over (funds-at-risk).

## Acceptance criteria

- WalletPort ABC frozen as defined here; changes require CONTRACT revision.
- 5-6 adapters (BTC, LTC, ETH, BSC, TRX, conditional XRP) each pass the 10-test conformance suite with ZERO deterministic mismatch.
- Legacy conformance vectors reused unchanged as the reference oracle (tests/fixtures/vectors.py).
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
