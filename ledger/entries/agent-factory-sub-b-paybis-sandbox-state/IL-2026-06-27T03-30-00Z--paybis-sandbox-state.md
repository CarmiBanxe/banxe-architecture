---
il_ts: 2026-06-27T03:30:00Z
session_id: agent-factory-sub-b-paybis-sandbox-state
source: CEO
status: DONE
---
### PAYBIS sandbox final-state map — canonical navigation/status doc (docs-plane)

- **Objective:** Record one canonical PAYBIS sandbox completeness/state doc (docs/paybis-dossier/PAYBIS-SANDBOX-STATE.md) so operator + MAIN have a single source of state. Docs-plane; no runtime.
- **Live audit (evidence, not memory):** EMI branch agent/factory/paybis/wave-a-adapter @ c21bf2e — 6 commits (2edf49d Wave A / 42563df Wave B / b012c40 docs / 669fa58 sandbox install / 887b2aa provider+smoke / c21bf2e DI-gate), all %G?=N (unsigned; NOT a merge-blocker — required_signatures=false verified gh-api). 30 tests pass; paybis_provider 100% cov; ruff+semgrep clean; no secrets. api/deps.py: lru_cache@247 on get_crypto_application_service, processing=_select_crypto_processing_adapter()@261 (line refs corrected from operator's 217/261 — main drifted). banxe-architecture origin/main IL max=559; this shard on branch agent/factory/paybis/neuronext-retirement-adr; provisional IL = max+1 frozen-at-merge (Rule 8).
- **State matrix recorded:** REAL = flag+selector+façade+DI-gate (default OFF) + env-config/sandbox-guard/idempotency/error-mapping; MOCKED = transport responses (SandboxMockPaybisTransport); FENCED = live HTTP/endpoints/auth/signature; OUT OF SCOPE = Travel-Rule go-live (ADR-114) + funds/wallet-balance (non-custodial ADR-108).
- **Invariants:** FROZEN CryptoLedgerPort/CryptoRpcPort unchanged; I-01/I-24; non-custodial; micro-boundaries intact; ADR-126 NeuroNext-replacement compatible; default OFF = zero regression.
- **Live-activation blockers (external, NOT inventable):** sandbox base-URL+creds (vault, approved-scope); SRC-06 (endpoints/auth/signature/schemas/fee); SRC-07+ADR-114 (Travel-Rule go-live); full agreement .docx (§3b НЕИЗВЕСТНО).
- **Activation path:** real PaybisTransport + verify_signature on SRC-06 → wallet/rpc substitution → PAYBIS-as-default only after live enablement + ADR-114 → landing per LANDING-HANDOFF-MAIN.md.
- **Perimeter / canon:** docs-plane only; every status evidence-traced (no invented literals); FROZEN ports untouched; isolated worktree off arch origin/main; sub-B hands to MAIN per §71/§74.
- **Deliverable:** docs/paybis-dossier/PAYBIS-SANDBOX-STATE.md, this IL shard.
- **Refs:** EMI wave-a-adapter@c21bf2e (Wave A/B + sandbox install + provider + DI-gate); ADR-126/108/114; PLAN/LANDING-HANDOFF/SRC-INTAKE-REGISTER; ADR-119/I-28; required_signatures=false (gh-api).
