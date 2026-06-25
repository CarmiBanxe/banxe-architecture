---
id: ADR-123
title: Claude permissions hardening — reconcile global vs project settings; protect main from global git push:* allow
status: ACCEPTED
date: 2026-06-26
accepted: 2026-06-26
supersedes: []
related:
  - ".claude/settings.json (project — correct no-popup + protected baseline)"
  - "~/.claude/settings.json (global/home — outside repo; AWAITS OPERATOR)"
  - "ADR-027 (Claude Code permissions reclassification)"
  - "ADR-120 (per-session worktree isolation — terminal pushes branch, never merges)"
  - "ADR-121 (destructive-action protection; parallel-session-isolation Rule 7)"
  - ".claude/rules/safety-rules.md, .claude/rules/approval-rules.md (stop-barriers)"
il_anchor: IL-540
scope: BANXE-only
concept_only: true
---

# ADR-123 — Claude permissions hardening: reconcile global vs project settings; protect `main` from the global `git push:*` allow

## Context

Audit on **2026-06-25** (HEAD `ec95496`, read live — not from memory) compared the two
permission layers Claude Code merges for this project:

### Project layer — `.claude/settings.json` (CORRECT)

- `defaultMode: acceptEdits` → no-popup edit flow, the intended factory ergonomics.
- A comprehensive **`deny`** that fails-closed on the dangerous git/secret surface:
  - `git push --force *` / `git push -f *` (+ `git -C * …` variants);
  - `git push origin main|master` and `git push * HEAD:main|master` (+ `-C` variants),
    i.e. **direct push to a protected branch is blocked** — consistent with the canon
    "terminal pushes a feature branch + PR, never merges `main`" (ADR-120, ADR-121,
    `parallel-session-isolation.md`);
  - `git reset --hard *`, `sudo *`, `npm publish *`;
  - read/write of `.env*`, `secrets/**`, `**/*.pem`, `**/*.key`, `**/.ssh/**`.

This layer is a sound **no-popup-yet-protected** baseline. No change is proposed to it.

### Global/home layer — `~/.claude/settings.json` (DIVERGENCE — the finding)

```jsonc
{
  "skipDangerousModePermissionPrompt": true,
  "permissions": {
    "allow": [
      "Bash(git push:*)",   // ← broader than the project deny on push origin main/master
      "Bash(npm:*)",        // ← broader than the project deny on npm publish
      ...
    ]
  }
}
```

Two divergences from the project baseline:

1. **`Bash(git push:*)` (allow)** is strictly **wider** than the project's `deny` on
   `git push origin main|master` / `--force`. The home layer has **no** matching `deny`.
2. **`skipDangerousModePermissionPrompt: true`** suppresses the human confirmation that
   normally guards entry into bypass-permissions ("dangerous") mode — a HITL stop-barrier.

### Why this is a real (defense-in-depth) gap, even though deny wins today

Claude Code merges settings with precedence
**enterprise-managed > CLI args > project-local > project > user/global**, and within the
merged set **`deny` > `ask` > `allow`**. So **while this project is the working directory,
the project `deny` does override the global `git push:*` allow** — a push to `main` is
blocked *here, today*. The exposure is structural, not immediate:

- **Per-project reliance.** Protection of `main` depends on *every* repo shipping the deny
  list. In any other directory/repo (or a fresh checkout before `.claude/settings.json`
  loads), the global `git push:*` allow stands alone → push to a protected branch is
  auto-allowed.
- **Prompt suppression amplifies it.** `skipDangerousModePermissionPrompt: true` removes the
  one interactive barrier that would otherwise surface such an action to a human, conflicting
  with CLAUDE.md §11 (no automatic production-state mutation without human approval) and the
  `safety-rules.md` / `approval-rules.md` stop-barrier canon.

The fail-safe default for a *global* config is "deny the dangerous targets at the global
layer too", so safety does not hinge on each project re-asserting it.

> Scope note: `~/.claude/settings.json` is the operator's **home** file, **outside this
> repository**. Per ADR-103 (no operator-local mutation by the factory) and the home-config
> boundary, this ADR is **`concept_only`** — it records the decision and the proposed fragment
> only. It is **AWAITS OPERATOR**; the factory does not edit the home file.

## Decision

1. **Narrow the global `allow` for `git push`** from the blanket `Bash(git push:*)` to a
   feature-branch-only set, and **mirror the project `deny`** at the global layer so the
   protected branches and `--force` are blocked **everywhere**, independent of any project's
   own deny list. (`deny` > `allow`, so a residual broad allow could not re-open `main`; we
   narrow the allow regardless, per least-privilege.)
2. **Mirror the `npm publish` deny** globally (parallels the project deny; `npm:*` alone
   leaves publish open in other directories).
3. **Remove `skipDangerousModePermissionPrompt: true`** (omit → default `false`), restoring
   the human confirmation before bypass-permissions/dangerous mode. Rationale: it is a HITL
   stop-barrier required by CLAUDE.md §11 and `safety-rules.md`; suppressing it globally is
   the amplifier that turns finding (1) from theoretical into reachable. Keeping it saves one
   confirmation per dangerous-mode entry — not worth removing a governance barrier.

This is **additive to** and consistent with ADR-027 (permissions reclassification), ADR-120
(terminal pushes a branch, never merges), ADR-121 (destructive-action protection), and the
merge canon (merge of `main` = operator step). It changes **no** project file behaviour.

## Proposed corrected global fragment (concept_only — DO NOT auto-apply; AWAITS OPERATOR)

Operator applies this by hand to `~/.claude/settings.json`. Shown as the before→after of the
permission-relevant keys (the rest of the global `allow` list is unchanged).

```diff
 {
-  "skipDangerousModePermissionPrompt": true,
   "permissions": {
+    "deny": [
+      "Bash(git push --force *)",
+      "Bash(git push -f *)",
+      "Bash(git push * --force*)",
+      "Bash(git push origin main)",
+      "Bash(git push origin main *)",
+      "Bash(git push origin master)",
+      "Bash(git push origin master *)",
+      "Bash(git push * HEAD:main)",
+      "Bash(git push * HEAD:main *)",
+      "Bash(git push * HEAD:master)",
+      "Bash(git push * HEAD:master *)",
+      "Bash(git -C * push --force *)",
+      "Bash(git -C * push origin main)",
+      "Bash(git -C * push origin main *)",
+      "Bash(git -C * push origin master)",
+      "Bash(git -C * push origin master *)",
+      "Bash(npm publish *)"
+    ],
     "allow": [
       "Bash(gh pr checkout:*)",
       "Bash(gh pr create:*)",
       "Bash(ruff format:*)",
       "Bash(pytest:*)",
       "Bash(git add:*)",
       "Bash(git commit:*)",
-      "Bash(git push:*)",
+      "Bash(git push)",
+      "Bash(git push origin HEAD)",
+      "Bash(git push -u origin HEAD)",
+      "Bash(git push --dry-run *)",
+      "Bash(git push origin *)",
       "Bash(git status:*)",
       "Bash(git fetch:*)",
       "Bash(git checkout:*)",
       "Bash(git show:*)",
       "Bash(mkdir:*)",
       "Bash(semgrep:*)",
       "Bash(jq:*)",
-      "Bash(npm:*)",
+      "Bash(npm install *)",
+      "Bash(npm ci *)",
+      "Bash(npm run *)",
+      "Bash(npm test *)",
       "Write(//tmp/**)",
       "Edit(//tmp/**)"
     ]
   }
 }
```

Notes on the fragment:

- `Bash(git push origin *)` keeps feature-branch pushes friction-free; the new global `deny`
  on `origin main|master` / `HEAD:main|master` / `--force` blocks the protected targets
  (deny > allow) — the "feature-branches-only" property without enumerating branch names.
- `npm:*` → explicit subcommand allows; `npm publish` denied globally (mirrors project).
- Removing `skipDangerousModePermissionPrompt` restores the dangerous-mode confirmation; if
  the operator wants to keep one-key dangerous-mode entry, that is an explicit operator
  override to record — the safe default is to omit it.

## Consequences

- **Positive.** `main`/`master` and `--force` are blocked at the **global** layer →
  protection no longer depends on each repo carrying its own deny list; the dangerous-mode
  HITL barrier is restored; least-privilege on `git push` and `npm`. No change to the
  project's no-popup edit ergonomics.
- **Cost.** Operator performs a one-time hand-edit of the home file (factory cannot, by
  ADR-103). A genuine push to `main` (rare, operator-driven) now requires an explicit
  override instead of being silently auto-allowed — intended.
- **Verification (after operator applies).** `git push origin main --dry-run` from any
  directory should be denied; entering dangerous mode should prompt for confirmation.

## Status

**ACCEPTED (governance / concept_only).** Decision recorded; proposed global fragment attached
as a diff. **NOT applied** to `~/.claude/settings.json` — **AWAITS OPERATOR** (home config,
outside repo; ADR-103). No project file changed. DO NOT MERGE pending operator review (merge =
operator step, merge canon / ADR-120).

## Anchors

- Live audit 2026-06-25, HEAD `ec95496`: `.claude/settings.json` (project) vs
  `~/.claude/settings.json` (global).
- ADR-027 (Claude Code permissions reclassification); ADR-103 (no operator-local mutation by
  factory); ADR-120 (per-session worktree isolation — push branch, never merge); ADR-121 /
  `parallel-session-isolation.md` Rule 7 (destructive-action protection, fail-closed).
- CLAUDE.md §11 (no automatic production-state mutation without human approval); §12
  (best-decision); `safety-rules.md`, `approval-rules.md` (stop-barriers).
- IL-540 (this decision's ledger anchor).
