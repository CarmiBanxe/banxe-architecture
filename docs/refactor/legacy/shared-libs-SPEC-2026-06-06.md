# Refactor SPEC #18 — Shared libraries consolidation (banxe-shared-libs)

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_REVIEW; NEW-driven; cross-cutting shared libs)
Scope: 12 KEEP-EXTRACT shared-lib legacy projects -> banxe-shared-libs monorepo
Source: BANXE.RAR; CLASS_REVIEW.tsv (shared lib targets)
NEW capability: cross-cutting infrastructure for C1-C25 (shared utilities consumed by all NEW services)
Related: SPEC #2 crypto-utils; SPEC #6 @banxe/circuit-breaker; ADR-019 GQL
Owner: Terminal B (smart refactor)

## Purpose

NEW-driven: 12 legacy shared-lib projects (utility code reused across many services) consolidate into banxe-shared-libs monorepo (NPM workspace). Mine genuinely-reusable utilities (validation, formatting, error types, common DTOs); drop legacy-specific glue. Consumed across NEW services C1-C25. Complements @banxe/circuit-breaker (SPEC #6) and banxe-crypto-utils (SPEC #1/#2).

## Decision (NEW-driven)

- 12 shared-lib projects -> banxe-shared-libs monorepo (NPM workspaces or pnpm).
- Keep: pure utilities (validation, money/decimal handling, error taxonomy, common types).
- Drop: legacy-framework-specific glue (old NestJS decorators, Apollo-coupled helpers per ADR-019).
- Each lib independently versioned; semver; consumed via internal registry (GitHub Packages).
- Anti-duplication: crypto utilities live in banxe-crypto-utils (SPEC #1/#2), NOT here; resilience in @banxe/circuit-breaker (SPEC #6), NOT here.

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + consolidation decision (this SPEC).
- Phase B-C (Terminal B): banxe-shared-libs monorepo; extract pure utilities from 12 projects; semver each.
- Phase D (Terminal B): unit tests per lib; dependency audit (no circular deps; no vendor lock-in).
- Phase E-F (Terminal B): NEW services consume via registry; ARCHIVE 12 legacy; IL record.

## Acceptance criteria

- banxe-shared-libs monorepo with independently-versioned pure utilities.
- No crypto/resilience duplication (those live in dedicated libs).
- Consumed by at least 3 NEW services.
- 12 legacy shared-lib projects ARCHIVE.

## References

- SPEC #2 crypto-utils-libs; SPEC #6 @banxe/circuit-breaker; ADR-019 GQL migration
- NEW-PROJECT-PRIORITY-MAP (cross-cutting infra); CLASS_REVIEW.tsv (12 shared-lib rows)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF Shared libraries SPEC #18 (CLASS_REVIEW; NEW-driven cross-cutting) ===
