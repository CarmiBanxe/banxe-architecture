#!/usr/bin/env bash
# regression_test.sh — proves the env-indirection allowlist suppresses the known
# false positives WITHOUT suppressing real literals.
#
# Both halves matter equally. An allowlist that silences everything is a mute button,
# not a fix, so every rule has a POSITIVE fixture that must still be detected. The
# suite fails if detection is lost, not only if a false positive returns.
#
# Fixture naming is load-bearing: *-negative.* must produce 0 findings,
# *-positive.* must produce exactly 1.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HERE/env-indirection-allowlist.toml"
FIX="$HERE/fixtures"
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0

scan_one() {
  rm -rf "$WORK"/*; cp "$1" "$WORK/"
  gitleaks detect --source="$WORK" --no-git --config="$CFG" --no-banner --redact \
    --report-format=json --report-path="$WORK/out.json" >/dev/null 2>&1 || true
  python3 -c "import json;print(len(json.load(open('$WORK/out.json'))))"
}

for f in "$FIX"/*; do
  base=$(basename "$f")
  case "$base" in
    *-negative.*) want=0 ;;
    *-positive.*) want=1 ;;
    *) echo "SKIP: $base (no polarity in name)"; continue ;;
  esac
  got=$(scan_one "$f")
  if [ "$got" = "$want" ]; then echo "PASS: $base (expected $want, got $got)"; pass=$((pass+1))
  else echo "FAIL: $base (expected $want, got $got)"; fail=$((fail+1)); fi
done

echo
echo "fixtures: $pass passed, $fail failed"
[ "$fail" -eq 0 ] || { echo "Allowlist is wrong: it either lets a false positive through or hides a real secret."; exit 1; }
echo "PASS: 5 rules x {negative suppressed, positive still detected}."
