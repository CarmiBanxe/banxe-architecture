#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# AgentOps / LLMOps status aggregator — READ-ONLY over EXISTING signals. No mutation.
# Reports the state of the AgentOps controls that ALREADY exist in canon, each
# 🟢/🟡/🔴/⚪. Asserts NO new thresholds, owners, or blocking gates — those are
# AWAITS OPERATOR (MODEL-RISK-MANAGEMENT §5/§6).
#
# Controls (existing mechanisms):
#   • Guardian   — 16 deterministic rules (8 factory F1-F8 + 8 project P1-P8);
#                  workflow present + ledger gate passes locally.
#   • Canon Judge— LLM eval vs ADR-025, AUDIT MODE (log-only, no block; qwen3.5:35b).
#                  Reported honestly as advisory; a BLOCKING T1 gate is AWAITS OPERATOR.
#   • Post-training eval — `make train-verify` (mandatory-skill binding gate).
#   • Skill-coverage eval — `make skills-audit` (bound/unbound passports; 57/0 target).
#   • Kill-switch / decommission — `ollama rm` per-model OPERATOR confirmation (MRM §4;
#                  governed MANUAL control, not an automated switch here).
#   • Explainability / monitoring thresholds — AWAITS OPERATOR (MRM §6) — not invented.
#
# Modes: (default) RU plain-academic text | --json | --self-test (hermetic green)
# Exit:  0 (status aggregator, not a gate) · 2 usage error.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CANON="$REPO_ROOT/docs/canon/software-factory-canon-v1.md"
MRM="$REPO_ROOT/docs/governance/MODEL-RISK-MANAGEMENT.md"

JSON=0; SELFTEST=0
for a in "$@"; do case "$a" in
  --json) JSON=1 ;;
  --self-test|--dry-run) SELFTEST=1 ;;
  -h|--help) grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "STOP: unknown arg '$a'" >&2; exit 2 ;;
esac; done

if [ "$SELFTEST" -eq 1 ]; then
  GUARD=pass; CJ=audit; TRAIN=pass; UNBOUND=0; KILL=present
else
  # Guardian: workflow present + ledger gate passes locally
  guard_wf=$([ -f "$REPO_ROOT/.github/workflows/guardian.yml" ] && echo 1 || echo 0)
  ledger_ok=$(python3 "$REPO_ROOT/ledger/build_ledger.py" --check >/dev/null 2>&1 && echo 1 || echo 0)
  GUARD=$([ "$guard_wf" -eq 1 ] && [ "$ledger_ok" -eq 1 ] && echo pass || echo fail)
  # Canon Judge: present in canon + audit/log-only mode
  if grep -qi "Canon Judge" "$CANON" 2>/dev/null && grep -qiE "audit mode.*(log only|no block)|audit mode" "$CANON" 2>/dev/null; then CJ=audit; else CJ=absent; fi
  # Post-training eval
  TRAIN=$(make -C "$REPO_ROOT" train-verify >/dev/null 2>&1 && echo pass || echo gap)
  # Skill-coverage eval
  UNBOUND=$(bash "$REPO_ROOT/scripts/skills-bind-audit.sh" --json 2>/dev/null \
            | python3 -c "import json,sys;print(json.load(sys.stdin)['summary']['unbound'])" 2>/dev/null || echo "?")
  # Kill-switch / decommission control documented
  KILL=$(grep -qi "ollama rm" "$MRM" 2>/dev/null && grep -qi "per-model operator confirmation" "$MRM" 2>/dev/null && echo present || echo absent)
fi

v_guard=$([ "$GUARD" = pass ] && echo "🟢" || echo "🔴")
v_cj=$([ "$CJ" = audit ] && echo "🟡" || echo "🔴")          # present but audit/log-only ⇒ advisory
v_train=$([ "$TRAIN" = pass ] && echo "🟢" || echo "🟡")
v_skills=$([ "$UNBOUND" = 0 ] && echo "🟢" || echo "🟡")
v_kill=$([ "$KILL" = present ] && echo "🟢" || echo "🔴")
overall=$([ "$GUARD" = pass ] && [ "$KILL" = present ] && echo "🟢" || echo "🟡")

if [ "$JSON" -eq 1 ]; then
  AO_OVR="$overall" AO_SELF="$SELFTEST" AO_G="$GUARD" AO_GV="$v_guard" AO_CJ="$CJ" AO_CJV="$v_cj" \
  AO_T="$TRAIN" AO_TV="$v_train" AO_U="$UNBOUND" AO_SV="$v_skills" AO_K="$KILL" AO_KV="$v_kill" python3 <<'PY'
import os,json;g=os.environ.get
print(json.dumps({
 "overall":g("AO_OVR"),"selftest":g("AO_SELF")=="1",
 "guardian":{"verdict":g("AO_GV"),"status":g("AO_G"),"rules":"16 deterministic (F1-F8 + P1-P8)"},
 "canon_judge":{"verdict":g("AO_CJV"),"mode":g("AO_CJ"),"note":"audit/log-only, no block (qwen3.5:35b, ADR-025)"},
 "post_training_eval":{"verdict":g("AO_TV"),"make_train_verify":g("AO_T")},
 "skill_coverage_eval":{"verdict":g("AO_SV"),"unbound":g("AO_U")},
 "kill_switch_decommission":{"verdict":g("AO_KV"),"status":g("AO_K"),"note":"ollama rm = per-model operator confirmation (governed manual, MRM §4)"},
 "awaits_operator":["BLOCKING independent-validation gate for T1 (MRM §5)","independent-validator OWNER — SR 11-7 effective challenge (MRM §5)",
   "revalidation cadence (MRM §5)","numeric eval / monitoring thresholds — drift/hallucination (MRM §6)"]},
 ensure_ascii=False,indent=2))
PY
  exit 0
fi

echo "═══ AgentOps / LLMOps — статус по существующим сигналам — общий: $overall $([ "$SELFTEST" -eq 1 ] && echo '[self-test]') ═══"
echo
echo "$v_guard Guardian — 16 детерминированных правил (F1-F8 + P1-P8): $GUARD (workflow + ledger-гейт локально)"
echo "$v_cj Canon Judge — LLM-оценка vs ADR-025: режим=$CJ (audit/log-only, НЕ блокирует; qwen3.5:35b)"
echo "    → блокирующий валидационный гейт для T1 = AWAITS OPERATOR (не утверждается здесь)"
echo "$v_train Post-training eval — make train-verify: $TRAIN (привязка mandatory-навыков)"
echo "$v_skills Skill-coverage eval — make skills-audit: unbound=$UNBOUND (цель 0)"
echo "$v_kill Kill-switch / decommission — ollama rm = per-model подтверждение оператора: $KILL"
echo "    (управляемый РУЧНОЙ контроль по MRM §4 — не автоматический switch в этом репо)"
echo
echo "AWAITS OPERATOR (НЕ выдумывается — MRM §5/§6):"
echo "  ⚪ блокирующий independent-validation гейт для T1 (§5)"
echo "  ⚪ владелец независимой валидации — SR 11-7 effective challenge (§5)"
echo "  ⚪ периодичность ревалидации (§5)"
echo "  ⚪ числовые eval/мониторинг-пороги — drift/hallucination (§6)"
echo
echo "Агрегатор только ЧИТАЕТ существующие сигналы (Guardian/Canon Judge/train-verify/skills-audit/MRM);"
echo "новые пороги, владельцы и блокирующие гейты — решения оператора/CRO."
exit 0
