# PAYBIS sandbox install — final state (canonical navigation/status)

**Plane:** docs-plane (статус-карта; no runtime). **Date:** 2026-06-27. **Mode:** SANDBOX-only,
flag-gated, default OFF. Все live-поверхности **fenced** на внешних входах. Один канонический
источник состояния для operator + MAIN.

## Источник (EMI, branch `agent/factory/paybis/wave-a-adapter` @ `c21bf2e`)
6 commits (all `%G?=N` — unsigned, **НЕ merge-blocker**: `required_signatures=false`):
`2edf49d` Wave A · `42563df` Wave B fenced scaffold · `b012c40` docs · `669fa58` sandbox install ·
`887b2aa` provider+smoke · `c21bf2e` DI-gate.
8 PAYBIS-модулей + 2 тест-файла; **30 тестов pass**; `paybis_provider` 100% cov; ruff + semgrep
`banxe-rules` чисто; секретов нет.

## State matrix (layer × status — evidence-traced)
| Layer | Status | Evidence |
|---|---|---|
| feature flag + selector + façade + DI-gate (processing surface) | **REAL** (flag-gated, **default OFF**) | `api/deps.py` `_select_crypto_processing_adapter` / `get_crypto_application_service` (lru_cache@247, processing@261) |
| env config / sandbox guard (refuses PRODUCTION) / idempotency / error-mapping | **REAL** | `paybis_sandbox.py`, `paybis_provider.py` |
| transport responses (quote / order / status) | **MOCKED** (deterministic `SandboxMockPaybisTransport`) | `paybis_provider.py` |
| live HTTP / endpoints / auth headers / signature verify | **FENCED** | `endpoint_for` / `auth_headers` / `verify_signature` raise |
| Travel-Rule go-live | **OUT OF SCOPE** (Wave C) | ADR-114 gate |
| funds movement / wallet-balance via PAYBIS | **OUT OF SCOPE** (non-custodial) | `OUT_OF_PAYBIS_SCOPE`, ADR-108 |

## Invariants preserved
FROZEN `CryptoLedgerPort`/`CryptoRpcPort` unchanged; **I-01** Decimal; **I-24**; non-custodial boundary;
microservice boundaries intact; NeuroNext-replacement compatible (ADR-138); **default OFF = zero regression**.

## Live-activation blockers (внешние входы — operator/PAYBIS, НЕ inventable)
1. **Sandbox base-URL + API creds** (vault) — в рамках approved domains/URLs/ICT/use-cases scope.
2. **SRC-06** — endpoints, auth scheme, **signature algorithm + signed fields**, request/response &
   webhook schemas, fee model → un-fences `endpoint_for`/`auth_headers`/`verify_signature` + real sandbox transport.
3. **SRC-07 + ADR-114** — Travel-Rule status + MLRO/HITL go-live (Wave C).
4. **Full agreement `.docx`** — approved domains/ICT/security/incident/audit clauses (dossier §3b всё ещё **НЕИЗВЕСТНО**).

## Activation path (когда входы придут)
- **on base-URL + creds + SRC-06:** реализовать реальный `PaybisTransport` за `PaybisTransportPort`
  (un-fence), `verify_signature` по алгоритму SRC-06, real sandbox smoke против live-sandbox; tests ≥90%
  (mock + fenced-live boundary).
- **затем:** wallet/rpc substitution; PAYBIS-as-default **только** после live-enablement + ADR-114 go-live.
- **landing:** per `LANDING-HANDOFF-MAIN.md` (rebase linear-history, PRE-MERGE `nosemgrep` fix, required
  checks green; signatures не требуются).

## Cross-ref
ADR-138, ADR-108, ADR-114; `PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md`; `LANDING-HANDOFF-MAIN.md`;
`SRC-INTAKE-REGISTER.md`; EMI `services/ledger/production/PAYBIS-WAVE-A.md` (per-wave detail).
