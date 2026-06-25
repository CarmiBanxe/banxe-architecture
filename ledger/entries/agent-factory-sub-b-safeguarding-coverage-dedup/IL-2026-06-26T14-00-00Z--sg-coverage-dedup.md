---
il_ts: 2026-06-26T14:00:00Z
session_id: agent-factory-sub-b-safeguarding-coverage-dedup
source: CEO
status: DONE
---
### safeguarding-engine coverage → 95.8% (gate 90 passes) + ADR-102 model dedup (test-infra only)

- **Objective:** Raise safeguarding-engine coverage to ≥90% HONESTLY so `make test-full` passes — real tests only, no padding, no gate weakening (`--cov-fail-under=90` unchanged). Plus ADR-102 model dedup. PR #213 branch (continues Phase 3.6 pass).
- **Live audit (source of truth, not memory):** banxe-emi-stack PR #213 branch HEAD 1752879 (was 32d3722, 34/34 green @ 74%); banxe-architecture origin/main@ec95496 IL max=539 → this provisional max+1=IL-540 (Rule 8 frozen-at-merge; MAIN regenerates). Coverage measured via canonical install path (`make install-safeguarding` then pytest --cov).
- **ADR-102 dedup:** `SafeguardingAccount` (and siblings) were defined TWICE — canonical `app/models/__init__.py` (Mapped[] DeclarativeBase, imported by alembic/env.py, 100%) and dead standalone `app/models/{safeguarding_account,safeguarding_position,breach_report,reconciliation_record}.py` (Column-style, **0 importers**, 0% coverage, latent `Base.metadata` duplicate-`accounts`-table conflict if ever imported). Verify-step: 0 importers each + 0% coverage. Removed the 4 dead files; canonical registry kept. No semantic change to the kept models.
- **Coverage work (real tests, no padding):** new `tests/test_internal_coverage.py` (13 tests) — MCP server register/dispatch + unknown-tool; Celery scheduler wires the 4 crontab entries (mocked Celery, no broker); dependency lifecycle (init/get/close db+redis lazy, `get_clickhouse_client` monkeypatched); integration client constructors + close(); service branches (record_obligation via SafeguardingRequest, update_account non-uuid id, record_balance_snapshot, detect_shortfall_breach positive/zero, report_breach via BreachCreate, recon get_detail 404, audit_logger ClickHouse-insert branch via mock client + immutability + generate_fca_report + log() alias); api accounts (create/update/balance) + health/ready.
- **Result:** `make test-full` (gate 90) PASSES — **74% → 95.82%**, **47 passed** (34 functional + 13 internal). ruff clean. Decimal-only / config-threshold / no-new-persistence rules intact. NO service business-logic changed this commit (only dead-file deletion + new tests).
- **Honest residual (35 lines ~4%, uncovered NOT padded, NO blanket #pragma):** unimplemented external integration method bodies (need live Modulr/Midaz/Telegram/n8n — STOP-CONDITION external infra), uvicorn `__main__`, lifespan startup (needs live DB/Redis), and 2 out-of-scope API stubs (`list_accounts`/`get_account` — not in the service-method scope). These are genuine external/entrypoint/out-of-scope lines, not Phase-3.6 service gaps; gate passes with comfortable margin.
- **STOP-CONDITION check:** 90% reached WITHOUT changing runtime business logic or fabricating tests; gate not weakened; no assert-True padding; no blanket coverage excludes.
- **ADR-102 self-dup (IL):** no prior coverage/dedup IL on main → non-duplicative; references PR #213 install/DI/conftest/Phase-3.6 shards.
- **Perimeter / canon:** test-infra + dead-dup-deletion only; no service logic change; no secrets; isolated worktree off banxe-architecture origin/main@ec95496; signed; sub-B hands to MAIN per §71/§74; --force-with-lease only.
- **Deliverable:** banxe-emi-stack PR #213 commit 1752879 (4 deletions + test_internal_coverage.py).
- **Refs:** PR #213 (32d3722 Phase 3.6, 1752879 coverage+dedup); app/models/__init__.py (canonical); ADR-102; pyproject --cov-fail-under=90; I-27 (CASS 15 P0).
