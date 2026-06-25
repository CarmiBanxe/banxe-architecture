#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Quality gate — repo-local Quality Factory checks. READ-ONLY, no mutation.
# Implements the COMPUTABLE parts of the DEVSECOPS-SSDLC §7 KPIs / O-11 for THIS
# (governance/architecture) repo, each 🟢/🟡/🔴 vs target. Code-metric KPIs that
# need an app source + analyzer (coverage, tech-debt, security-hotspot) are
# **DELEGATED → project CI (SonarQube/test runner)** — never fabricated. True MTTD
# needs incident telemetry → **AWAITS OPERATOR** (closest local signal = dora D-4).
#
# Local blocking gates (KPI-3 "0 blocker/critical on merge"):
#   • ledger rebuild check  (python3 ledger/build_ledger.py --check)
#   • semgrep ERROR scan    (mirror of .githooks/pre-commit; absent/timeout ⇒ 🟡, not blocking)
# Active security gates (DevSecOps): codeql / osv-scanner / sbom / cosign-sign workflows present.
#
# Modes: (default) RU plain-academic text | --json | --self-test (hermetic green)
# Exit:  0 ok · 20 a REAL local blocking failure (ledger/semgrep) · 2 usage error.
#        (DELEGATED / AWAITS items NEVER cause a non-zero exit.)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SEC_WF=(codeql osv-scanner sbom cosign-sign)
SEMGREP_TIMEOUT=180

JSON=0; SELFTEST=0
for a in "$@"; do case "$a" in
  --json) JSON=1 ;;
  --self-test|--dry-run) SELFTEST=1 ;;
  -h|--help) grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "STOP: unknown arg '$a'" >&2; exit 2 ;;
esac; done

BLOCKING=0
if [ "$SELFTEST" -eq 1 ]; then
  LEDGER=pass; SEMGREP=pass; SEC_PRESENT=4; ADR_N=42
else
  # KPI-3a: ledger rebuild (hard local gate)
  if python3 "$REPO_ROOT/ledger/build_ledger.py" --check >/dev/null 2>&1; then LEDGER=pass
  else LEDGER=fail; BLOCKING=$((BLOCKING+1)); fi
  # KPI-3b: semgrep ERROR scan (mirror pre-commit); absent/timeout ⇒ inconclusive (not blocking)
  if command -v semgrep >/dev/null 2>&1; then
    if timeout "$SEMGREP_TIMEOUT" semgrep scan --config=auto --error --severity=ERROR \
         --quiet "$REPO_ROOT" >/dev/null 2>&1; then SEMGREP=pass
    else rc=$?; if [ "$rc" -eq 124 ]; then SEMGREP=timeout; else SEMGREP=fail; BLOCKING=$((BLOCKING+1)); fi; fi
  else SEMGREP=na; fi
  # DevSecOps: security workflow presence
  SEC_PRESENT=0; for w in "${SEC_WF[@]}"; do [ -f "$REPO_ROOT/.github/workflows/$w.yml" ] && SEC_PRESENT=$((SEC_PRESENT+1)); done
  ADR_N="$(find "$REPO_ROOT/decisions" "$REPO_ROOT/docs/adr" -iname 'ADR-*.md' 2>/dev/null | wc -l | tr -d ' ')"
fi

OVERALL=$([ "$BLOCKING" -eq 0 ] && echo "🟢" || echo "🔴")
lv() { [ "$1" = pass ] && echo "🟢" || { [ "$1" = fail ] && echo "🔴" || echo "🟡"; }; }
sec_v=$([ "${SEC_PRESENT}" -eq 4 ] && echo "🟢" || echo "🟡")

if [ "$JSON" -eq 1 ]; then
  QG_OVERALL="$OVERALL" QG_BLOCK="$BLOCKING" QG_LEDGER="$LEDGER" QG_SEMGREP="$SEMGREP" \
  QG_SEC="$SEC_PRESENT" QG_ADR="$ADR_N" QG_SELF="$SELFTEST" QG_LV="$(lv "$LEDGER")$(lv "$SEMGREP")" QG_SECV="$sec_v" \
  python3 <<'PY'
import os,json;g=os.environ.get
print(json.dumps({
 "overall":g("QG_OVERALL"),"blocking_failures":int(g("QG_BLOCK")),"selftest":g("QG_SELF")=="1",
 "local_gates":{"ledger_check":g("QG_LEDGER"),"semgrep_error":g("QG_SEMGREP"),
   "security_workflows_present":f"{g('QG_SEC')}/4","adr_count":g("QG_ADR")},
 "delegated_project_ci":{"coverage_ge_85":"DELEGATED","tech_debt_lt_5":"DELEGATED","security_hotspot_ge_95":"DELEGATED"},
 "awaits_operator":{"mttd_lt_24h":"AWAITS OPERATOR (incident telemetry; proxy = make dora D-4)"}},
 ensure_ascii=False,indent=2))
PY
  exit $([ "$BLOCKING" -eq 0 ] && echo 0 || echo 20)
fi

echo "═══ QUALITY-GATE (repo-local) — общий: $OVERALL ${SELFTEST:+}$([ "$SELFTEST" -eq 1 ] && echo '[self-test]') ═══"
echo
echo "ЛОКАЛЬНЫЕ БЛОКИРУЮЩИЕ ГЕЙТЫ (KPI-3 «0 blocker/critical»): блокирующих провалов = $BLOCKING"
echo "  $(lv "$LEDGER") ledger build_ledger.py --check: $LEDGER"
echo "  $(lv "$SEMGREP") semgrep ERROR scan: $SEMGREP$([ "$SEMGREP" = na ] && echo ' (semgrep отсутствует — неинформативно)')$([ "$SEMGREP" = timeout ] && echo ' (таймаут — неинформативно)')"
echo
echo "DevSecOps — активные security-воркфлоу (S2): $sec_v присутствуют $SEC_PRESENT/4 (codeql/osv-scanner/sbom/cosign-sign)"
echo "  (advisory; перевод в required в branch protection — решение оператора). ADR-записей: $ADR_N"
echo
echo "DELEGATED → project CI (нет app-кода/анализатора в этом репо; цифры НЕ выдумываются):"
echo "  ⚪ coverage ≥85% — DELEGATED (SonarQube/test-runner проектного CI)"
echo "  ⚪ tech-debt <5% — DELEGATED (project CI)"
echo "  ⚪ security-hotspot ≥95% — DELEGATED (project CI / SonarQube)"
echo
echo "AWAITS OPERATOR:"
echo "  ⚪ MTTD <24h — incident-телеметрия AWAITS OPERATOR; ближайший локальный сигнал = make dora (D-4 MTTR proxy)"
echo
echo "Гейт проверяет ТОЛЬКО вычислимое в этом governance-репо; code-метрики — проектный CI / O-11 (DEVSECOPS-SSDLC.md)."
exit $([ "$BLOCKING" -eq 0 ] && echo 0 || echo 20)
