#!/usr/bin/env bash
# Tests for scripts/guardian_ledger_gate.sh path taxonomy (ruling 2026-08-05).
# Required cases (a)-(d) + regression (e):
#   (a) gap-register-only PR passes without a shard
#   (b) canonical change without shard still FAILS
#   (c) rename of a canonical file into an admin path does NOT bypass
#   (d) mixed (admin + canonical) PR gets NO exemption
#   (e) canonical change WITH a new shard passes (existing behavior preserved)
set -euo pipefail

GATE="$(cd "$(dirname "$0")/../.." && pwd)/scripts/guardian_ledger_gate.sh"
FAIL=0

G() { git -C "$1" -c user.email=t@banxe.test -c user.name=gate-test "${@:2}"; }

mk_repo() {
  local R
  R=$(mktemp -d)
  G "$R" init -q
  mkdir -p "$R/ledger/entries" "$R/docs/governance"
  echo '{"gaps":[]}' > "$R/ledger/IL-GAP-REGISTER.json"
  echo '# canon' > "$R/docs/governance/CANON-SAMPLE.md"
  echo '# ledger' > "$R/INSTRUCTION-LEDGER.md"
  G "$R" add -A
  G "$R" commit -q -m seed
  echo "$R"
}

check() { # name want_exit repo base head
  local name="$1" want="$2" repo="$3" base="$4" head="$5" got
  if (cd "$repo" && "$GATE" "$base" "$head" >/dev/null 2>&1); then got=0; else got=1; fi
  if [ "$got" -eq "$want" ]; then
    echo "PASS: $name"
  else
    echo "FAIL: $name (expected exit $want, got $got)"
    FAIL=1
  fi
}

# (a) gap-register-only -> OK
R=$(mk_repo); B=$(G "$R" rev-parse HEAD)
echo '{"gaps":[{"il":1137,"status":"committed"}]}' > "$R/ledger/IL-GAP-REGISTER.json"
G "$R" add -A; G "$R" commit -q -m "gap-register correction"
check "(a) gap-register-only passes without shard" 0 "$R" "$B" "$(G "$R" rev-parse HEAD)"

# (b) canonical doc without shard -> FAIL
R=$(mk_repo); B=$(G "$R" rev-parse HEAD)
echo 'amendment' >> "$R/docs/governance/CANON-SAMPLE.md"
G "$R" add -A; G "$R" commit -q -m "canon change, no shard"
check "(b) canonical without shard fails" 1 "$R" "$B" "$(G "$R" rev-parse HEAD)"

# (c) rename canonical -> admin path does not bypass
R=$(mk_repo); B=$(G "$R" rev-parse HEAD)
G "$R" mv docs/governance/CANON-SAMPLE.md ledger/ALLOCATOR-RECOVERY-LOG.md
G "$R" commit -q -m "sneaky rename into admin path"
check "(c) rename into admin path does not bypass" 1 "$R" "$B" "$(G "$R" rev-parse HEAD)"

# (d) mixed admin + canonical without shard -> FAIL
R=$(mk_repo); B=$(G "$R" rev-parse HEAD)
echo '{"gaps":[{"il":9}]}' > "$R/ledger/IL-GAP-REGISTER.json"
echo 'amendment' >> "$R/docs/governance/CANON-SAMPLE.md"
G "$R" add -A; G "$R" commit -q -m "mixed change, no shard"
check "(d) mixed PR gets no exemption" 1 "$R" "$B" "$(G "$R" rev-parse HEAD)"

# (e) canonical WITH new shard -> OK (regression: existing behavior preserved)
R=$(mk_repo); B=$(G "$R" rev-parse HEAD)
echo 'amendment' >> "$R/docs/governance/CANON-SAMPLE.md"
mkdir -p "$R/ledger/entries/test-topic"
echo '# shard' > "$R/ledger/entries/test-topic/IL-2026-01-01T00-00-00Z--test.md"
G "$R" add -A; G "$R" commit -q -m "canon change with shard"
check "(e) canonical with shard passes" 0 "$R" "$B" "$(G "$R" rev-parse HEAD)"



# (f) sandbox mode short-circuits the shard requirement; absent policy stays strict.
R=$(mk_repo); B=$(G "$R" rev-parse HEAD)
echo 'amendment' >> "$R/docs/governance/CANON-SAMPLE.md"
G "$R" add -A; G "$R" commit -q -m "canon change, no shard"
check "(f-strict) no policy file => still requires shard" 1 "$R" "$B" "$(G "$R" rev-parse HEAD)"
mkdir -p "$R/policy" && printf 'mode: sandbox\n' > "$R/policy/mode.yaml"
G "$R" add -A; G "$R" commit -q -m "declare sandbox mode"
check "(f-sandbox) mode=sandbox => shard not required" 0 "$R" "$B" "$(G "$R" rev-parse HEAD)"
mkdir -p "$R/policy" && printf 'mode: prod\n' > "$R/policy/mode.yaml"
G "$R" add -A; G "$R" commit -q -m "switch to prod"
check "(f-prod) mode=prod => strict again" 1 "$R" "$B" "$(G "$R" rev-parse HEAD)"
exit $FAIL
