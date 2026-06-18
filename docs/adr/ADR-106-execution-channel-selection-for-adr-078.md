# ADR-106: Execution Channel Selection Gate for ADR-078

**Status:** PROPOSED  
**Date:** 2026-06-18  
**Deciders:** Operator, Central  
**Trust Zone:** AMBER  
**Change Class:** CLASS_B

## Context

Banxe Architecture currently has a blocked execution path for new ADR and ledger actions authored via CLAUDE CODE, pending explicit selection of an approved execution channel for the first ADR-078 pull request.

A concrete candidate channel, referred to as **Channel C**, has now been partially identified through read-only inspection of existing pull requests. PR #508 and PR #509 were created by the GitHub user `CarmiBanxe`, not by a bot account, and use branch names `agent/factory/m1/m1.4-status-taxonomy-plan` and `agent/factory/m1/m1.4-il-shard`.

This resolves one important uncertainty: Channel C is capable of creating branches and opening pull requests in `banxe-architecture`, and it does so inside the same repository-level execution pattern already accepted for other factory tasks.

However, two critical uncertainties remain:

- the **entrypoint** of Channel C is still unknown, meaning it is not yet clear whether M1.4 work is launched through a dedicated Claude/terminal session, a queue, scheduled automation, GitHub-native automation, or manual operator triggering; and
- the **scope** of Channel C is still unknown, meaning it is not yet clear whether it accepts only M1-line work or can also execute arbitrary `agent/factory/<track>/<slug>` tasks such as ADR-078 on `arch-stack-002`.

Until those uncertainties are resolved, any new write action for ADR-078 would bypass the current governance requirement that approval be attached to a specific controlled execution path, not merely to an abstract intent.

## Decision

New ADR or ledger actions via CLAUDE CODE remain **blocked by default** until one execution channel is explicitly selected for the first ADR-078 pull request and the operator confirms that the selected channel is both controlled and applicable to the ADR-078 track.

Channel C is elevated from “unknown candidate” to **provisionally viable candidate**, because it has demonstrated the ability to push branches and open pull requests in the accepted `agent/factory/...` style under the identity `CarmiBanxe`.

Channel C may be approved for the first ADR-078 pull request only if the following are explicitly confirmed by its owner/operator:

1. the launch mechanism for M1.4 work;
2. the input artifact or trigger expected by the runner/process; and
3. whether the process accepts non-M1 factory tracks, specifically `agent/factory/arch-stack-002/...`.

Until those conditions are confirmed, Central is limited to read-only audit, operator-facing analysis, and task framing. It must not produce new ADR/ledger write actions for ADR-078 through CLAUDE CODE.

## Consequences

### Positive

- The decision preserves a strict binding between approval and the real execution path, reducing the risk of governance drift between intent and actual side effects.
- Channel C is no longer treated as opaque; the known facts now support targeted operator inquiry instead of broad speculation.
- The next operator action becomes simple and testable: ask the owner of Channel C how it is started and what task scope it accepts.

### Negative / Risks

- ADR-078 remains blocked for write execution until Channel C’s entrypoint and scope are confirmed or another channel is explicitly chosen.
- If Channel C is hard-scoped to M1 only, operator time spent validating it will still end in fallback to Channel A or B.
- If Channel C depends on an informal or person-bound launch path, repeatability and auditability may remain weaker than desired even if it is technically usable.

## Operator Protocol

The operator should resolve Channel C in the following order:

1. Confirm the owner: already established as `CarmiBanxe` via read-only PR inspection.
2. Ask for the launch mechanism: dedicated terminal/Claude instance, queue, scheduler, GitHub automation, or manual execution.
3. Ask for scope: M1-only versus arbitrary `agent/factory/<track>/<slug>` tasks including `arch-stack-002`.
4. Approve or reject Channel C for the first ADR-078 PR based on those answers.

## Related

- ADR-014 — Composable Financial Stack.
- PR #508 and PR #509 — evidence that Channel C can create branches and PRs under the `agent/factory/m1/m1.4-*` naming pattern.
- Execution-governance principle: approval must attach to the actual execution path before side effects are allowed.
