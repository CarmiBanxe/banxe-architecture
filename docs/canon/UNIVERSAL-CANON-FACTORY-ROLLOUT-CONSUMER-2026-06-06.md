# Universal Canon — Central as Factory Canon-Rollout Consumer (House rule 13)

Date: 2026-06-06 00:30 CEST
Status: BINDING (extends House rule 10 topology; binding from this PR onwards)
Source: operator directive 2026-06-06 ("close all scripts through the factory; factory itself perfected in left terminal"); factory audit 2026-06-06 (~/factory v1.5.1, rollout-canon-to-repo.sh dry-run verified)

## Purpose

Formalises a new Central scope: Central runs the factory canon-rollout as a CONSUMER to distribute Factory canon into EMI BANXE banking repositories. The factory engine itself is built and perfected by the left terminal in ~/factory; Central never edits the factory engine. This document fixes the boundary so the two roles do not collide.

## Topology addition (extends House rule 10)

- Left terminal — owns ~/factory: builds and perfects the canon-guardian factory engine (canon/vX.Y.Z branches, checks, RED fixtures, regression, templates). Factory is the single producer of canon. Current stable tag: v1.5.1; work-in-progress: canon/v1.6.0.
- Right terminal — owns ~/banxe-architecture/docs/refactor/legacy/*: writes SPECs / CONTRACT specs / SCAFFOLD specs / migration docs for legacy BANXE.RAR → new EMI architecture.
- Central (Perplexity) — NEW: factory canon-rollout consumer. Runs ~/factory/scripts/rollout-canon-to-repo.sh <repo> --version <pinned> to create a canon-pin branch + PR in each EMI banking repo. Also continues its existing scope: docs/IL/ADR/runbooks/scripts/canon in banxe-architecture.

## House rule 13 — Factory canon-rollout consumer

- Central MAY run ~/factory/scripts/rollout-canon-to-repo.sh as a consumer: it copies 8 controlled canon files (CANON.md, .clauderules, .github/workflows/canon-guardian.yml, .github/workflows/canon-guardian-regression.yml, .claude/agents/canon-guardian.md, docs/canon/CANON-TOPOLOGY.md, docs/canon/OVERRIDES.md, docs/canon/MODULES.md) into a target banking repo, pins .factory-canon-version, and opens a canon-pin/vX.Y.Z branch + PR. Never force-push.
- Central MUST always pin a specific factory version (--version vX.Y.Z), never floating HEAD, to keep rollouts reproducible. Default pin: latest stable tag (v1.5.1 at this writing).
- Central MUST run --dry-run first on any repo it has not rolled out before, review the plan, then run the real rollout.
- Central MUST NOT edit the factory engine in ~/factory (canon/*, checks/*, RED fixtures, templates). That is the left terminal's exclusive zone. Central is consumer-only.
- Central MUST NOT modify the SPEC files in ~/banxe-architecture/docs/refactor/legacy/* beyond reading them. That is the right terminal's zone.
- Canon-pin PRs land in banking repos (banxe-payment-core, banxe-emi-stack, banxe-ai-infrastructure, banxe-audit, banxe-canon, banxe-dev, banxe-monitoring, banxe-operator-runbooks, banxe-platform, banxe-infra, banxe-ui, banxe-architecture). Each PR is reviewed/merged per that repo's branch protection; admin-bypass only if guardian-* checks cannot report and only with paired IL entry (Part A discipline extends to banking repos).
- Rollout is sequential per House rule 12: one repo at a time, dry-run then real, output reviewed, next repo follows.

## Acceptance

- House rule 13 binding from this PR's merge commit onwards.
- Central rollout consumer scope is now part of the topology alongside left (factory engine) and right (legacy SPECs).
- Factory version pinning (--version) is mandatory; floating-HEAD rollout is forbidden.

=== END OF FACTORY-ROLLOUT-CONSUMER CANON (snapshot 5579aae) ===
