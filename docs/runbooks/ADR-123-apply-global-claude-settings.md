# Runbook — Apply ADR-123 global Claude permissions hardening to `~/.claude/settings.json`

> **Type:** operator runbook (manual, by-hand). **Scope:** `~/.claude/settings.json` — the
> operator's HOME file, **outside this repository**. Per **ADR-103** (no operator-local
> mutation by the factory) the factory does **not** edit it; this runbook is the by-hand
> procedure the operator follows. **Anchors:** `docs/adr/ADR-123-claude-permissions-hardening.md`
> (the decision; `concept_only`, `il_anchor: IL-540`), ADR-027, ADR-103, ADR-120, ADR-121,
> CLAUDE.md §11/§12, `.claude/rules/safety-rules.md`, `.claude/rules/approval-rules.md`.

## 0. Why this is a manual step (read first)

- `~/.claude/settings.json` lives in the operator's **home directory**, not in any repo. The
  factory/terminal is forbidden to mutate operator-local files (**ADR-103**), so applying the
  ADR-123 fragment is an **operator hand-edit** — it cannot be done by a `[CLAUDE CODE]`
  artifact.
- **Merge of ADR-123 (PR #787) and this apply step are independent operator actions.** The
  audit on 2026-06-25 (HEAD `ec95496`) confirmed the precondition for merge is **not yet
  satisfied** (fail-closed): the global file still has `skipDangerousModePermissionPrompt: true`,
  a blanket `Bash(git push:*)` allow, and **no** push-deny block. Apply this fragment **before**
  treating ADR-123 as operationally live.
- This runbook changes **no** project file and **no** repo state. It documents a host-config
  change only.

## 1. Before → after (permission-relevant keys only)

The rest of the global `allow` list is unchanged. Only the keys below move.

### 1.1 BEFORE (current, audited 2026-06-25 @ HEAD `ec95496`)

```jsonc
{
  "skipDangerousModePermissionPrompt": true,
  "permissions": {
    "allow": [
      "Bash(gh pr checkout:*)",
      "Bash(gh pr create:*)",
      "Bash(ruff format:*)",
      "Bash(pytest:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",        // ← blanket: wider than project deny on main/master + --force
      "Bash(git status:*)",
      "Bash(git fetch:*)",
      "Bash(git checkout:*)",
      "Bash(git show:*)",
      "Bash(mkdir:*)",
      "Bash(semgrep:*)",
      "Bash(jq:*)",
      "Bash(npm:*)",             // ← blanket: wider than project deny on npm publish
      "Write(//tmp/**)",
      "Edit(//tmp/**)"
    ]
  }
}
```

There is **no** `deny` block today, and `skipDangerousModePermissionPrompt: true` suppresses the
dangerous-mode HITL confirmation.

### 1.2 AFTER (target — apply this)

```jsonc
{
  "permissions": {
    "deny": [
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(git push * --force*)",
      "Bash(git push origin main)",
      "Bash(git push origin main *)",
      "Bash(git push origin master)",
      "Bash(git push origin master *)",
      "Bash(git push * HEAD:main)",
      "Bash(git push * HEAD:main *)",
      "Bash(git push * HEAD:master)",
      "Bash(git push * HEAD:master *)",
      "Bash(git -C * push --force *)",
      "Bash(git -C * push origin main)",
      "Bash(git -C * push origin main *)",
      "Bash(git -C * push origin master)",
      "Bash(git -C * push origin master *)",
      "Bash(npm publish *)"
    ],
    "allow": [
      "Bash(gh pr checkout:*)",
      "Bash(gh pr create:*)",
      "Bash(ruff format:*)",
      "Bash(pytest:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push)",
      "Bash(git push origin HEAD)",
      "Bash(git push -u origin HEAD)",
      "Bash(git push --dry-run *)",
      "Bash(git push origin *)",
      "Bash(git status:*)",
      "Bash(git fetch:*)",
      "Bash(git checkout:*)",
      "Bash(git show:*)",
      "Bash(mkdir:*)",
      "Bash(semgrep:*)",
      "Bash(jq:*)",
      "Bash(npm install *)",
      "Bash(npm ci *)",
      "Bash(npm run *)",
      "Bash(npm test *)",
      "Write(//tmp/**)",
      "Edit(//tmp/**)"
    ]
  }
}
```

### 1.3 Unified diff (the three changes)

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

**The three changes, in words:**

1. **Narrow `git push` allow** — blanket `Bash(git push:*)` → feature-branch-only set
   (`git push`, `git push origin HEAD`, `git push -u origin HEAD`, `git push --dry-run *`,
   `git push origin *`). `Bash(git push origin *)` keeps feature-branch pushes friction-free.
2. **Add a global `deny`** mirroring the project deny — `origin main|master`, `* HEAD:main|master`,
   `--force`/`-f`, and `git -C *` variants, plus `npm publish *`. Because **`deny` > `allow`**,
   protected branches and force-push are blocked **everywhere**, not just inside this repo's cwd.
3. **Remove `skipDangerousModePermissionPrompt: true`** (omit the key → it defaults `false`),
   restoring the human confirmation before bypass-permissions/dangerous mode (CLAUDE.md §11,
   `safety-rules.md`).

## 2. Apply procedure (operator, by hand)

> Run these in a shell **as the operator** — this edits a host file, not a repo. Replace the
> editor of your choice for step 2.3.

```bash
# 2.1 — Back up the current file first (verify-step before any mutation; safety-rules canon)
SETTINGS="$HOME/.claude/settings.json"
[ -f "$SETTINGS" ] || { echo "STOP: $SETTINGS does not exist"; exit 1; }
cp -av "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%dT%H%M%S)"

# 2.2 — Confirm the BEFORE state matches the audit (so the diff applies cleanly)
jq -e '.skipDangerousModePermissionPrompt == true' "$SETTINGS"   # expect: true
jq -e '.permissions.allow | index("Bash(git push:*)")' "$SETTINGS"  # expect: an index (not null)
jq -e '.permissions | has("deny") | not' "$SETTINGS"             # expect: true (no deny yet)

# 2.3 — Edit by hand: apply §1.3 (remove skipDangerousMode…, add deny[], rewrite git push / npm allows)
#        Use the §1.2 AFTER block as the authoritative target for the permissions object.
${EDITOR:-nano} "$SETTINGS"

# 2.4 — Validate JSON well-formedness after the edit
jq empty "$SETTINGS" && echo "JSON OK"
```

## 3. VERIFY block

### 3.1 File-level checks (jq on the file — authoritative)

```bash
SETTINGS="$HOME/.claude/settings.json"

# (a) skipDangerousModePermissionPrompt must be ABSENT (omitted → default false)
jq -e 'has("skipDangerousModePermissionPrompt") | not' "$SETTINGS" \
  && echo "PASS: skipDangerousModePermissionPrompt absent" \
  || echo "FAIL: key still present"

# (b) deny block exists and protects main + master
jq -e '.permissions.deny | index("Bash(git push origin main)") and index("Bash(git push origin master)")' "$SETTINGS" \
  && echo "PASS: deny protects origin main + master" \
  || echo "FAIL: main/master not denied"

# (c) deny also covers HEAD:main|master, --force/-f, -C variants, npm publish
for pat in \
  "Bash(git push * HEAD:main)" \
  "Bash(git push * HEAD:master)" \
  "Bash(git push --force *)" \
  "Bash(git push -f *)" \
  "Bash(git -C * push origin main)" \
  "Bash(npm publish *)"; do
  jq -e --arg p "$pat" '.permissions.deny | index($p)' "$SETTINGS" >/dev/null \
    && echo "PASS deny: $pat" || echo "FAIL deny missing: $pat"
done

# (d) blanket allows are gone; narrowed allows are present
jq -e '.permissions.allow | index("Bash(git push:*)") | not' "$SETTINGS" \
  && echo "PASS: blanket git push:* removed" || echo "FAIL: blanket git push:* still allowed"
jq -e '.permissions.allow | index("Bash(npm:*)") | not' "$SETTINGS" \
  && echo "PASS: blanket npm:* removed" || echo "FAIL: blanket npm:* still allowed"
jq -e '.permissions.allow | index("Bash(git push origin *)")' "$SETTINGS" >/dev/null \
  && echo "PASS: feature-push allow present" || echo "FAIL: feature-push allow missing"
```

### 3.2 ⚠️ `git push --dry-run` does **NOT** validate the Claude permission layer

> **Critical:** a bash command such as `git push origin main --dry-run` exercises **git's** own
> network/ref negotiation — it runs in the shell and **bypasses `settings.json` entirely**. The
> Claude permission layer (`allow`/`ask`/`deny`) is enforced by **Claude Code when it decides
> whether to invoke the `Bash` tool**, not by git. So a green `--dry-run` in a raw terminal tells
> you **nothing** about whether the deny rule is active.

Validate the permission layer the only two correct ways:

1. **File check (§3.1)** — `jq` assertions on `~/.claude/settings.json` confirm the rule set is
   present and well-formed. This is the authoritative static check.
2. **Behaviour inside Claude Code** — in a Claude Code session, ask it to run
   `git push origin main --dry-run`. With the fragment applied, the **deny rule must block the
   tool call** (Claude refuses / reports the command is denied) — and entering dangerous mode
   must now **prompt for confirmation** (because `skipDangerousModePermissionPrompt` was removed).
   Conversely a feature-branch push (`git push origin HEAD`) must remain allowed. Test from a
   directory **other than this repo** too, to confirm protection no longer depends on the project
   deny list.

> Do **not** accept a bare-shell `--dry-run` as evidence the deny works. Permission enforcement
> = (jq on the file) **AND** (observed Claude Code tool-call behaviour). Never the shell alone.

## 4. ADR-060 cross-check — branch protection + Merge Queue (operational step)

ADR-123 hardens the **client-side** (Claude permission) layer. It is **not** the primary defense
of `main` — per **ADR-060**, `main` is protected **server-side** by GitHub **branch protection +
Merge Queue**, not by a local pre-push hook. (`core.hooksPath=.githooks`'s pre-push gate only
checks **branch naming**; it does not gate pushes to `main`.) If server-side protection is off,
`main`'s safety would rest on the Claude config alone — which is exactly the single-layer reliance
ADR-123 warns about. **Confirm both layers are active:**

```bash
# Requires gh with admin/maintain read on the repo. Read-only.
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"

# (a) Branch protection on main is present and strict
gh api "repos/$REPO/branches/main/protection" \
  --jq '{required_status_checks: .required_status_checks.strict,
         required_pr_reviews: .required_pull_request_reviews.required_approving_review_count,
         enforce_admins: .enforce_admins.enabled}'

# (b) Merge Queue is enabled for main (GraphQL; mergeQueue is non-null when on)
gh api graphql -f query='
  query($owner:String!,$name:String!){
    repository(owner:$owner,name:$name){
      mergeQueue(branch:"main"){ id configuration { mergeMethod } }
    }
  }' -F owner="${REPO%/*}" -F name="${REPO#*/}" \
  --jq '.data.repository.mergeQueue | if . == null then "FAIL: Merge Queue OFF" else "PASS: Merge Queue ON" end'
```

Or visually in **GitHub → Settings → Branches → Branch protection rules → `main`**: confirm
**“Require a pull request before merging”**, **“Require status checks … up to date”** (strict),
and **“Require merge queue”** are all checked.

> If either is OFF, that is the real gap — fix server-side protection first. The Claude permission
> hardening (ADR-123) is **defense-in-depth on top of** ADR-060, never a replacement for it.

## 5. Rollback

```bash
SETTINGS="$HOME/.claude/settings.json"
# Restore the most recent backup made in §2.1
cp -av "$(ls -1t "$SETTINGS".bak.* | head -1)" "$SETTINGS"
jq empty "$SETTINGS" && echo "rolled back, JSON OK"
```

## 6. Done criteria

- [ ] §2.1 backup created.
- [ ] §1.2 AFTER applied by hand; `jq empty` passes.
- [ ] §3.1 file checks all PASS (skipDangerous absent; deny covers main/master/HEAD/-force/-C/npm publish; blanket allows removed).
- [ ] §3.2 understood: `--dry-run` in bash is **not** a permission-layer test; validated via jq + Claude Code behaviour.
- [ ] §4 ADR-060 cross-check: branch protection + Merge Queue confirmed ON server-side.
- [ ] ADR-123 (PR #787) precondition now satisfied → operator may proceed to merge (merge = operator step).
