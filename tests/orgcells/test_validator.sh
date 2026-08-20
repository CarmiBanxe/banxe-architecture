#!/usr/bin/env bash
# test_validator.sh — negative + positive tests for scripts/validate_orgcells.py
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
V="python3 scripts/validate_orgcells.py"
pass=0; fail=0
chk(){ if echo "$3" | grep -q "$2"; then echo "PASS: $1"; pass=$((pass+1)); else echo "FAIL: $1"; fail=$((fail+1)); fi; }

W=$(mktemp -d); trap 'rm -rf "$W"' EXIT

# (1) cross-line vertical edge is rejected
mkdir -p "$W/a"; cp docs/orgcells/CELL-ENGINE-DIRECTOR.md docs/orgcells/CELL-MLRO-ROOT.md "$W/a/"
python3 - "$W/a" <<'PY'
import sys,os
p=os.path.join(sys.argv[1],"CELL-MLRO-ROOT.md"); s=open(p).read()
s=s.replace("manager_ref: null","manager_ref: engine-director",1)
open(p,"w").write(s)
PY
chk "cross-line vertical edge rejected (V2/V4)" "cross-line vertical edge" "$($V --dir "$W/a" 2>&1)"

# (2) null manager outside the LINE REGISTRY is INVALID
mkdir -p "$W/b"; cp docs/orgcells/CELL-ENGINE-DIRECTOR.md "$W/b/CELL-ROGUE.md"
python3 - "$W/b" <<'PY'
import sys,os
p=os.path.join(sys.argv[1],"CELL-ROGUE.md"); s=open(p).read()
s=s.replace("cell_id: engine-director","cell_id: rogue-root").replace("reporting_line: ENGINE_HIERARCHY","reporting_line: SHADOW_LINE")
open(p,"w").write(s)
PY
chk "null manager outside registry INVALID (V1'/V7)" "not in the LINE REGISTRY" "$($V --dir "$W/b" 2>&1)"

# (3) no false positive: a horizontal[] row merely mentioning DPIA must NOT trip V3b
mkdir -p "$W/c"; cp docs/orgcells/CELL-CTO-DEPT.md "$W/c/"
out=$($V --dir "$W/c" 2>&1)
if echo "$out" | grep -q "V3b"; then echo "FAIL: (3) V3b false positive on cto-dept"; fail=$((fail+1));
else echo "PASS: (3) no V3b false positive on cooperation rows"; pass=$((pass+1)); fi

echo; echo "validator tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
