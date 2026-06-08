# HANDOFF — crypto-exchange SPEC-1: spec-repo-map.tsv patch (Terminal A)

**Date:** 2026-06-08
**Owner of execution:** Terminal A / operator (factory engine zone)
**Source of truth:** VERIFIED discovery (/tmp/disc-cx.sh on evo1, 2026-06-08); SPEC-crypto-exchange.md (SHA d56e6d6e…bb82b); ADR-051/052
**Status:** READY — hold for operator confirm before push/PR/merge
**Guardrails:** single-artifact-per-step; PR + dual-guardian (Enforcer I-76/I-77 + Supervisor I-78); fail-closed; spec-build via LiteLLM (direct Anthropic = FAIL per ADR-052)

## Context

PR #349 patch covers crypto-ops Option B (monitor/portfolio/news per ADR-050). This patch is SEPARATE — it covers the crypto-exchange capability (SPEC-1), discovered and verified on 2026-06-08. The two patches MUST NOT be conflated.

## Mapping file

- Repo: `CarmiBanxe/factory`
- Path: `config/spec-repo-map.tsv`
- Columns (header): `spec_family\ttarget_repo_slug\toutput_type\tallowed_scope\tnotes`

## Patch — add three rows (tab-separated)

```tsv
crypto-api-exchange-contract	CarmiBanxe/crypto-api-exchange	service-code	src/**	ADR-051
fast-exchange-contract	CarmiBanxe/fast-exchange	service-code	src/**,migrations/**	ADR-051
crypto-exchange-api-contract	CarmiBanxe/crypto-exchange-api	service-code	src/trade/**,src/local-crypto-exchange/**	ADR-051
```

## Scope-out (NOT added)

| Legacy project | Reason |
|---|---|
| neuron-exchange-admin-2 | S5: no inbound refs in verified discovery |
| neuron-exchange-backend | S6: no inbound refs in verified discovery |

These are excluded per discovery triage. If future evidence shows inbound dependencies, a follow-up patch with its own ADR is required.

## Row semantics

| spec_family | target_repo | rationale |
|---|---|---|
| crypto-api-exchange-contract | CarmiBanxe/crypto-api-exchange | Core exchange API — trade execution, order management. Full src/ scope (flat service layout). |
| fast-exchange-contract | CarmiBanxe/fast-exchange | Fast/instant exchange service — rate quotes + instant swaps. Includes migrations/ for DB schema (Alembic/Sequelize). |
| crypto-exchange-api-contract | CarmiBanxe/crypto-exchange-api | Composite exchange API — trade routing + local-crypto-exchange integration. Scoped to src/trade/** and src/local-crypto-exchange/** only. |

## Preconditions (hard gate)

1. SPEC-crypto-exchange.md exists and SHA matches d56e6d6e…bb82b.
2. Target repos exist on GitHub: `crypto-api-exchange`, `fast-exchange`, `crypto-exchange-api`.
3. ADR-051 accepted (governs these rows).
4. ADR-052 enforced (LiteLLM routing; direct Anthropic = FAIL).
5. Dual-guardian pass: Enforcer (I-76/I-77) + Supervisor (I-78).
6. PR only — no direct push to factory main.

## Execution order

1. [Operator] confirm this patch → factory agent opens PR.
2. [Guardian] dual-check (Enforcer I-76/I-77 + Supervisor I-78) → PASS required.
3. [Operator] approve + merge PR.
4. [Factory] run capabilities ONE AT A TIME; verify each before next.
5. [Ledger] append IL-132 with factory commit SHA after merge.

## Guardian check expectations

- Enforcer I-76: rows reference existing repos (verify via `gh repo view`).
- Enforcer I-77: allowed_scope patterns are valid glob syntax.
- Supervisor I-78: no overlap with existing rows (crypto-ops-monitor/portfolio/news are separate families).
- Fail-closed: ANY guardian FAIL blocks the PR.

## Diff preview (for operator review)

```diff
--- a/config/spec-repo-map.tsv
+++ b/config/spec-repo-map.tsv
+crypto-api-exchange-contract	CarmiBanxe/crypto-api-exchange	service-code	src/**	ADR-051
+fast-exchange-contract	CarmiBanxe/fast-exchange	service-code	src/**,migrations/**	ADR-051
+crypto-exchange-api-contract	CarmiBanxe/crypto-exchange-api	service-code	src/trade/**,src/local-crypto-exchange/**	ADR-051
```

## Anchors

ADR-051, ADR-052, SPEC-crypto-exchange.md (SHA d56e6d6e…bb82b), IL-132 (to be appended AFTER merge), discovery /tmp/disc-cx.sh (evo1, 2026-06-08).
