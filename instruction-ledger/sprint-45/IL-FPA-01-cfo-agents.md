# IL-FPA-01: CFO Office Agents — FPAAgent + BIAgent (PROPOSED → IMPLEMENTED)

- Sprint: 45
- Status: DONE (2 of 4 agents shipped; 2 deferred)
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#166 (MERGED, squash, SHA ecede803)
- Created: 2026-06-09

## Context
ORG-STRUCTURE.md §2.5 (CFO, SMF2) listed four PROPOSED agents: FPAAgent (§2.5.2),
ForecastAgent (§2.5.2), TreasuryAgent (§2.5.3), BIAgent (§2.5.5). The L2 client-facing
agent pattern (ADR-049 §D2 gate-chain, ADR-046 lineage) governs a call to an injected
port CONTRACT. Only two of the four agents bind to an existing port; the other two have
no injectable port CONTRACT in banxe-emi-stack. Operator decision (sprint-45): ship the
two READY agents now, defer the two blocked ones.

## Delivered (PROPOSED → IMPLEMENTED)
- **FPAAgent** (§2.5.2, L1 Auto) — budget vs actuals reporting. Injects `LedgerPort`
  (`services/ledger/ledger_port.py`, read-only GL: get_account_balance / get_journal_entry).
  Source soul: `agents/souls/budget-agent.md`.
- **BIAgent** (§2.5.5, L1 Auto) — dashboard generation + KPI alerts. Injects `AnalyticsPort`
  (`services/reporting_analytics/analytics_port.py`, read-only ClickHouse OLAP).
  Source soul: `agents/souls/finance-bi-agent.md`.

Both enforce the full ADR-049 §D2 gate-chain (process_ref → scope allow-list → confidence
band → cost_cap → compliance → [step-up N/A] → port) and emit one ADR-046
`AgentDecisionRecord` per action. Read-only, AUTO-only (below-AUTO read → re-check halt; no
money movement, no biometric step-up). Ports + DecisionRecorder are constructor-injected;
shared primitives imported from `services/agents/_lineage.py` (no DRY duplication).

R-SEC (R-SEC-NEW-01): only opaque handles (account_id / report_id / entity_id) reach a
lineage record — never balances or PII; values ride on `AgentOutcome.result` only.

## Verification
- 63/63 tests pass (`tests/agents/test_fpa_agent.py` + `tests/agents/test_bi_agent.py`).
- 100% coverage on both new modules (`fpa_agent.py`, `bi_agent.py`).
- ruff check + ruff format clean; semgrep (banxe-rules) clean; full repo suite 10444 passed.
- PR #166 merged via `--admin` under the documented R3 non-reporting-guardian exception:
  `guardian-factory` + `guardian-project` are external-webhook contexts with no workflow in
  the repo (perpetually unreported); `enforce_admins=false`; all 13 real checks GREEN
  (Pytest cov≥80, Ruff, Semgrep×3, Gitleaks, Biome, Vitest, CodeRabbit, Smoke Gate mock).
  Same condition under which prior PRs #163/#164/#165 (S6/S8) merged.

## Deferred to sprint-46 / ADR-078
- **TreasuryAgent** (§2.5.3, L2 Review, CFO sign-off >£100k) — NOSTRO reconciliation + FX
  exposure. Blocked: `recon_port.py` is safeguarding-specific (not NOSTRO/correspondent
  recon); no FX-exposure port CONTRACT exists.
- **ForecastAgent** (§2.5.2, L2 Review) — liquidity forecasting. Blocked: no
  forecast/liquidity/cash-position port CONTRACT exists.
- Both require new port CONTRACTs (architect/ADR-gated) before the mask pattern can govern
  them; fabricating ports would violate I-10 (no fake integrations). Source souls staged:
  `fx-exposure-agent.md`, `cash-position-agent.md`, `forecast-agent.md`.

## Doc-sync (this PR, banxe-architecture)
- `docs/ORG-STRUCTURE.md` §2.5 — removed `(PROPOSED)` marker on FPAAgent (§2.5.2) and
  BIAgent (§2.5.5) only; ForecastAgent + TreasuryAgent remain `(PROPOSED)`.
- `MEMORY.md` — appended sprint-45 entry.
- This ledger entry (append-only; new file under instruction-ledger/sprint-45/).
