# HANDOFF — crypto-ops Option B: spec-repo-map.tsv patch (Terminal A)

**Date:** 2026-06-07
**Owner of execution:** Terminal A / operator (factory engine zone)
**Source of truth:** ADR-050 (crypto-ops-subgroup delivery model, Option B)
**Status:** READY — blocked only on Terminal B SPEC paths

## Purpose

crypto-ops launch per ADR-050 Option B requires three per-capability SPECs plus three rows in the factory mapping `CarmiBanxe/factory: config/spec-repo-map.tsv`. Editing that file is Terminal A zone. This doc provides the exact, ready-to-apply patch so the operator applies it in one step once Terminal B reports the SPEC paths.

## Mapping file

- Repo: `CarmiBanxe/factory`
- Path: `config/spec-repo-map.tsv`
- Columns (header, authoritative): `spec_family\ttarget_repo_slug\toutput_type\tallowed_scope\tnotes`

## Patch — add three rows (tab-separated)

```
crypto-ops-monitor-contract\tCarmiBanxe/crypto-ops-monitor\tservice-code\tsrc/crypto-ops-monitor/**\tADR-050
portfolio-contract\tCarmiBanxe/banxe-portfolio\tservice-code\tsrc/portfolio/**\tADR-050
news-contract\tCarmiBanxe/banxe-news\tservice-code\tsrc/news/**\tADR-050
```

## Patch — retire parent row to design-only (ADR-050 step 3)

Change existing row `crypto-ops-subgroup` so its `output_type` becomes `design-only` (it currently is `service-code`). This stops the parent from emitting code while the three children carry implementation.

## Preconditions (hard gate)

1. Terminal B must FIRST create the three SPECs via B1 and report their exact paths + SHAs. Mapping rows MUST reference existing SPECs, otherwise the factory rejects them.
2. Target repos must exist: `crypto-ops-monitor`, `banxe-portfolio`, `banxe-news` (verify before commit).
3. Apply via PR (no direct push to factory main); dual guardian checks must pass.

## Execution order

1. [Terminal B] create SPECs (monitor/portfolio/news) → report paths/SHA.
2. [Terminal A] apply the patch above to `config/spec-repo-map.tsv` via PR → merge.
3. [factory] run capabilities ONE AT A TIME; verify each before the next.
4. [ledger] append IL-132+ with the factory commit SHA per capability.

## Anchors

ADR-050, ADR-044 (amendment 2026-06-07), ADR-052 (enforcement runtime), IL-131.
