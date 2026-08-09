#!/usr/bin/env bash
# verify-hook-parity.sh — detect ADR-160 hook-enforcement drift (gap G-9 of ADR-166-A).
#
# WHAT DRIFTS. `scripts/install-hooks.sh` treats `scripts/pre-push-branch-name.sh` as the
# SOURCE and copies it over `.githooks/pre-push` (see install-hooks.sh: SRC=...). So the
# installed hook is a DERIVED artifact. If someone edits `.githooks/pre-push` directly to
# add or repair a write-gate guard, the next `install-hooks.sh` bootstrap silently reverts
# that edit — the exact failure G-9 names ("bootstrap silently reverts four write-gate
# guards"). Divergence in the other direction is just as bad: a guard present only in the
# mirror is not enforced until someone re-runs the installer.
#
# WHAT THIS CHECKS.
#   1. Guard-token parity  — the set of G-N guards named in each file must match.
#   2. Content parity      — the two files must be byte-identical (a guard can be gutted
#                            while its G-N label survives, so token parity alone is weak).
#   3. Installer wiring    — install-hooks.sh must still copy the mirror we just compared.
#
# ADVISORY MODE. This script ALWAYS exits 0 and reports findings as WARN. Per ADR-166-A
# G-9, verified hook parity is currently a MANUAL preflight for promotion-related writes;
# this check makes the drift visible in CI without gating merges on it.
#
# TODO: promote to hard-error mode (exit 1 on any drift) once G-9 is fully closed by the
# operator gate that makes this check required. Note (verified 2026-08-08 on PR #1219):
# `continue-on-error: true` in the workflow does NOT by itself make a check non-blocking —
# `guardian-traceability` carries that flag and still blocked a merge because its context
# is listed in the branch-protection required_status_checks. What keeps this check advisory
# is its ABSENCE from that required list, plus the unconditional exit 0 below.
#
# Refs: ADR-166-A §Pre-ACCEPTED gaps G-9, ADR-160 (write-gate G-1..G-4), ADR-158 (G-5+),
#       ADR-060 (branch naming G-5), ADR-120 (worktree mandate).

set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || { echo "hook-parity: cannot enter repo root"; exit 0; }

HOOK='.githooks/pre-push'
MIRROR='scripts/pre-push-branch-name.sh'
INSTALLER='scripts/install-hooks.sh'

warns=0
note() { printf 'hook-parity: %s\n' "$*"; }
warn() { printf 'hook-parity: WARN — %s\n' "$*"; warns=$((warns + 1)); }

# ---- presence ---------------------------------------------------------------
for f in "$HOOK" "$MIRROR"; do
  if [ ! -f "$f" ]; then
    warn "missing '$f' — cannot compare hook against mirror (G-9 unverifiable)"
  fi
done
if [ "$warns" -gt 0 ]; then
  note "PARITY UNVERIFIABLE (advisory) — warnings=$warns"
  exit 0
fi

# ---- 1. guard-token parity --------------------------------------------------
guards_of() { grep -oE 'G-[0-9]+' "$1" 2>/dev/null | sort -u; }

hook_guards="$(guards_of "$HOOK")"
mirror_guards="$(guards_of "$MIRROR")"

missing="$(comm -23 <(printf '%s\n' "$hook_guards") <(printf '%s\n' "$mirror_guards") | tr '\n' ' ')"
extra="$(comm -13 <(printf '%s\n' "$hook_guards") <(printf '%s\n' "$mirror_guards") | tr '\n' ' ')"

if [ -n "${missing// /}" ]; then
  warn "guards present in installed hook but ABSENT from the mirror: ${missing% }"
  warn "  ⇒ the next 'bash $INSTALLER' would silently REVERT them (this is G-9)"
fi
if [ -n "${extra// /}" ]; then
  warn "guards present in the mirror but ABSENT from the installed hook: ${extra% }"
  warn "  ⇒ those guards are NOT enforced until '$INSTALLER' is re-run"
fi

# ---- 2. content parity ------------------------------------------------------
hook_sha="$(sha256sum "$HOOK" | cut -d' ' -f1)"
mirror_sha="$(sha256sum "$MIRROR" | cut -d' ' -f1)"

if [ "$hook_sha" != "$mirror_sha" ]; then
  warn "content differs (a guard body can be gutted while its G-N label survives)"
  note "  $HOOK   sha256 ${hook_sha:0:16}  ($(wc -l < "$HOOK") lines)"
  note "  $MIRROR sha256 ${mirror_sha:0:16}  ($(wc -l < "$MIRROR") lines)"
  note "  unified diff (mirror → hook), first 40 lines:"
  diff -u "$MIRROR" "$HOOK" | sed -n '1,40p' | sed 's/^/    /'
fi

# ---- 3. installer wiring ----------------------------------------------------
if [ -f "$INSTALLER" ]; then
  if ! grep -qF "$MIRROR" "$INSTALLER"; then
    warn "'$INSTALLER' no longer references '$MIRROR' — this check may be comparing the wrong pair"
  fi
else
  warn "missing '$INSTALLER' — installer wiring unverified"
fi

# ---- verdict ----------------------------------------------------------------
guard_count="$(printf '%s\n' "$hook_guards" | grep -c 'G-' || true)"

if [ "$warns" -eq 0 ]; then
  note "PARITY OK: guards=$guard_count ($(printf '%s' "$hook_guards" | tr '\n' ' '))"
  note "  installed hook and mirror are byte-identical (sha256 ${hook_sha:0:16})"
else
  note "PARITY WARN: $warns finding(s) — see above. ADR-166-A G-9 requires a MANUAL"
  note "  hook-parity preflight before promotion-related writes while this gap is open."
fi

# Advisory mode: never fail the build. See the TODO in the header.
exit 0
