#!/usr/bin/env bash
# test_tooling_allowlist.sh — the control-infra allowlist is narrow and default-deny.
#
# Six cases, per the ruling of 2026-08-06. The ones that matter most are (3) and (6):
# they are what distinguishes an exact-path allowlist from a '^tools/' prefix, which
# would have silently exempted every future file dropped under that directory.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
GATE="$PWD/scripts/guardian_ledger_gate.sh"

WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0

# build a throwaway repo, apply a file-set, return the gate's exit code.
# SETUP (optional, via the SETUP env var) runs BEFORE the base commit, so files it
# creates exist at BASE and a later rename shows up as a real rename in BASE..HEAD.
# Getting this wrong makes case (5) trivially pass: if the "pre-existing" file is
# created after BASE, the net diff never contains its canonical path at all.
run_case() { # <name> <expect 0|1> <cmds...>
  local name="$1" want="$2"; shift 2
  rm -rf "$WORK/r"; mkdir -p "$WORK/r"; cd "$WORK/r"
  git init -q -b main; git config user.email t@t; git config user.name t
  mkdir -p ledger/entries; echo base > README.md
  [ -n "${SETUP:-}" ] && bash -c "$SETUP"
  git add -A; git commit -qm base
  local BASE; BASE=$(git rev-parse HEAD)
  "$@"
  git add -A; git commit -qm change
  local HEAD; HEAD=$(git rev-parse HEAD)
  set +e; bash "$GATE" "$BASE" "$HEAD" >/dev/null 2>&1; local rc=$?; set -e
  cd - >/dev/null
  if [ "$rc" = "$want" ]; then echo "PASS: $name (exit $rc)"; pass=$((pass+1))
  else echo "FAIL: $name (expected exit $want, got $rc)"; fail=$((fail+1)); fi
}

mk() { mkdir -p "$(dirname "$1")"; printf '%s\n' "${2:-x}" > "$1"; }

# (1) an allowlisted tools/ file passes with no shard
run_case "(1) allowlisted tools/ file exempt" 0 \
  bash -c 'mkdir -p tools/gitleaks-fix; echo cfg > tools/gitleaks-fix/env-indirection-allowlist.toml'

# (2) canonical content outside every exemption still requires a shard
run_case "(2) canonical without shard fails" 1 \
  bash -c 'mkdir -p docs; echo doc > docs/some-canon.md'

# (3) a canonical-LOOKING file INSIDE tools/ but NOT allowlisted must fail.
#     This is the case a '^tools/' prefix would have wrongly exempted.
run_case "(3) unlisted tools/ file is canonical" 1 \
  bash -c 'mkdir -p tools/gitleaks-fix; echo canon > tools/gitleaks-fix/NOT-ALLOWLISTED.md'

# (4) a mixed PR inherits nothing: one allowlisted file + one canonical file -> shard required
run_case "(4) mixed PR gets no exemption" 1 \
  bash -c 'mkdir -p tools/gitleaks-fix docs; echo cfg > tools/gitleaks-fix/README.md; echo doc > docs/canon.md'

# (5) renaming canonical content INTO an allowlisted path must not launder it.
#     --no-renames lists both sides, so the old canonical path still trips the gate.
SETUP='mkdir -p docs && echo doc > docs/canon.md' \
run_case "(5) rename canonical -> exempt does not bypass" 1 \
  bash -c 'mkdir -p tools/gitleaks-fix && git mv docs/canon.md tools/gitleaks-fix/README.md'

# (6) an unknown file TYPE under tools/ is canonical, not infra — extension is not a licence
run_case "(6) unknown type under tools/ is canonical" 1 \
  bash -c 'mkdir -p tools/other; echo bin > tools/other/mystery.bin'

echo
echo "control-infra allowlist: $pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
echo "PASS: allowlist is narrow (exact paths) and default-deny."
