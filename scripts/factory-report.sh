#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Factory report collector — executable «ОТЧЁТ ФАБРИКИ».
# Spec: docs/governance/FACTORY-STATUS-REPORT-PROMPT.md (sections A–G).
#
# READ-ONLY audit — NO service mutation. Gathers REAL evidence from the repo and
# (when reachable) the hosts; degrades gracefully when host access is absent.
# Output: structured Russian report (default) | --json (machine) | --self-test
# (hermetic, repo-only, exits 0 with no host/network access).
#
# Modes:  (default) RU text  |  --json  |  --self-test [--json]  |  -h/--help
# Exit:   0 ok · 2 usage error. (Audit-only: never mutates, never blocks.)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PASSPORTS="$REPO_ROOT/agents/passports"
GH_REPO="CarmiBanxe/banxe-architecture"

JSON=0; SELF_TEST=0
for a in "$@"; do case "$a" in
  --json) JSON=1 ;;
  --self-test|--dry-run) SELF_TEST=1 ;;
  -h|--help) grep -E '^# ' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "STOP: unknown arg '$a'" >&2; exit 2 ;;
esac; done

now_utc() { date -u +%Y-%m-%dT%H:%M:%SZ; }
have() { command -v "$1" >/dev/null 2>&1; }
na()   { [ "$SELF_TEST" -eq 1 ] && echo "self-test:skip" || echo "n/a"; }

# ── agent records (B + D) — single python parse, tsv|json, classify swarm ──────
emit_agents() { # $1 = tsv|json
  have python3 || { echo ""; return 0; }
  python3 - "$PASSPORTS" "$1" <<'PY'
import sys,os,glob,json
try: import yaml
except Exception: yaml=None
d,fmt=sys.argv[1],sys.argv[2]; rows=[]
def j(v): return ", ".join(map(str,v)) if isinstance(v,list) else ("" if v is None else str(v))
for f in sorted(glob.glob(os.path.join(d,"*.yaml"))):
    try: m=yaml.safe_load(open(f)) if yaml else {}
    except Exception: m={}
    if not isinstance(m,dict): m={}
    aid=m.get("agent_id") or os.path.basename(f)[:-5]
    caps=m.get("capabilities") or []; sk=m.get("allowed_skills") or []
    hay=(aid+" "+j(caps)+" "+str(m.get("description") or "")).lower()
    def has(*k): return any(x in hay for x in k)
    if has("review","regulat","audit","invariant","assur","oversight"): sw="Ruflo"
    elif has("consensus","mixture","moa","voting","quorum"): sw="OpenClaw"
    elif has("scenario","simulat","behaviou","qa ","test","experiment","sandbox"): sw="MiroFish"
    elif has("router","gateway","litellm","routing","adapter","mcp","webhook","elt","writer"): sw="MetaClaw"
    else: sw="other"
    r=dict(agent_id=aid, level=j(m.get("level")), trust_zone=j(m.get("trust_zone")),
           line_of_defence=j(m.get("line_of_defence")), department=j(m.get("department")),
           smf=j(m.get("smf_function")), skills=j(sk), callers=j(m.get("allowed_callers")),
           callees=j(m.get("allowed_callees")), capabilities=j(caps), swarm=sw)
    rows.append(r)
if fmt=="json": print(json.dumps(rows))
else:
    for r in rows:  # \x1f (Unit Separator) keeps empty fields intact in `read`
        print("\x1f".join([r["agent_id"],r["level"],r["line_of_defence"],r["department"],
                           r["skills"],r["callers"],r["callees"],r["swarm"]]))
PY
}

# ── A: factory overall ────────────────────────────────────────────────────────
collect_A() {
  A_HEAD="$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo n/a)"
  A_MAIN="$(git -C "$REPO_ROOT" log --oneline -1 origin/main 2>/dev/null || echo n/a)"
  A_WT="$(git -C "$REPO_ROOT" worktree list 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$SELF_TEST" -eq 1 ]; then A_LEDGER="self-test:skip"; else
    A_LEDGER="$(python3 "$REPO_ROOT/ledger/build_ledger.py" --check >/dev/null 2>&1 && echo OK || echo FAIL)"; fi
  if [ "$SELF_TEST" -eq 0 ] && have gh; then
    # `|| true` guards set -e+pipefail when grep matches 0 PRs (open_prs=0 is valid).
    A_PRS="$( { gh pr list --repo "$GH_REPO" --state open --json number 2>/dev/null | grep -o '"number"' | wc -l | tr -d ' '; } || true )"
    A_PRS="${A_PRS:-0}"
  else A_PRS="$(na)"; fi
}

# ── C: skills gap (train verify, read-only) ───────────────────────────────────
collect_C() {
  if have bash && [ -x "$REPO_ROOT/scripts/train.sh" ]; then
    C_OUT="$(bash "$REPO_ROOT/scripts/train.sh" verify 2>&1 || true)"
    C_STATUS="$(printf '%s' "$C_OUT" | grep -qiE 'fail|missing|✗' && echo "GAPS" || echo "OK")"
  else C_OUT="train.sh absent"; C_STATUS="$(na)"; fi
}

# ── E/F: hardware + models (host-dependent, degrade) ──────────────────────────
collect_EF() {
  if [ "$SELF_TEST" -eq 1 ]; then E_OLLAMA="self-test:skip"; F_MODELS="self-test:skip"
  elif have ollama; then
    F_MODELS="$(ollama list 2>/dev/null | awk 'NR>1{print $1}' | paste -sd',' - || echo n/a)"
    E_OLLAMA="local ollama: $(ollama list 2>/dev/null | awk 'NR>1' | wc -l | tr -d ' ') models"
  else E_OLLAMA="ollama n/a (host audit needed)"; F_MODELS="n/a"; fi
  E_DOCKER="$([ "$SELF_TEST" -eq 0 ] && have docker && echo "$(docker ps -q 2>/dev/null | wc -l | tr -d ' ') containers" || na)"
  F_CARDS="$(find "$REPO_ROOT" -path '*/.git' -prune -o -iname '*model-card*' -print 2>/dev/null | grep -c . || true)"
}

# ── G: quality schedule + UIUX presence ───────────────────────────────────────
collect_G() {
  G_PRE="$([ -f "$REPO_ROOT/.githooks/pre-commit" ] && echo present || echo absent)"
  G_CRON="$([ -f "$REPO_ROOT/deploy/cron/traffic-light.crontab" ] && echo present || echo absent)"
  G_TL="$([ -x "$REPO_ROOT/scripts/traffic-light.sh" ] && echo present || echo absent)"
  G_UIUX="$([ -f "$PASSPORTS/design_pipeline_agent.yaml" ] && echo present || echo absent)"
}

collect_all() { collect_A; collect_C; collect_EF; collect_G; AGENT_N="$(ls "$PASSPORTS"/*.yaml 2>/dev/null | wc -l | tr -d ' ')"; }

# ── JSON output (robust: data via env + QUOTED heredoc, no shell interpolation) ─
emit_json() {
  local AG; AG="$(emit_agents json)"; [ -z "$AG" ] && AG="[]"
  FR_TS="$(now_utc)" FR_MODE="$([ "$SELF_TEST" -eq 1 ] && echo self-test || echo live)" \
  FR_HEAD="$A_HEAD" FR_MAIN="$A_MAIN" FR_WT="$A_WT" FR_LEDGER="$A_LEDGER" FR_PRS="$A_PRS" \
  FR_C="$C_STATUS" FR_OLLAMA="$E_OLLAMA" FR_DOCKER="$E_DOCKER" FR_MODELS="$F_MODELS" \
  FR_CARDS="$F_CARDS" FR_PRE="$G_PRE" FR_TL="$G_TL" FR_CRON="$G_CRON" FR_UIUX="$G_UIUX" \
  FR_N="$AGENT_N" FR_AGENTS="$AG" python3 <<'PY'
import os,json
g=os.environ.get
print(json.dumps({
 "ts":g("FR_TS"),"mode":g("FR_MODE"),
 "A":{"head":g("FR_HEAD"),"main":g("FR_MAIN"),"worktrees":g("FR_WT"),
      "ledger_check":g("FR_LEDGER"),"open_prs":g("FR_PRS")},
 "B_agents": json.loads(g("FR_AGENTS","[]") or "[]"),
 "C":{"train_verify":g("FR_C")},
 "E":{"ollama":g("FR_OLLAMA"),"docker":g("FR_DOCKER")},
 "F":{"models":g("FR_MODELS"),"model_cards_found":g("FR_CARDS")},
 "G":{"pre_commit":g("FR_PRE"),"traffic_light":g("FR_TL"),"cron":g("FR_CRON"),"uiux_pipeline":g("FR_UIUX")},
 "agent_count":g("FR_N")}, ensure_ascii=False, indent=2))
PY
}

# ── RU text output ────────────────────────────────────────────────────────────
emit_text() {
  echo "═══ ОТЧЁТ ФАБРИКИ — $(now_utc) ($([ $SELF_TEST -eq 1 ] && echo self-test || echo live)) ═══"
  echo; echo "A. ФАБРИКА В ЦЕЛОМ"
  echo "  HEAD=$A_HEAD | main: $A_MAIN"
  echo "  worktrees=$A_WT | ledger --check=$A_LEDGER | открытых PR=$A_PRS"
  echo; echo "B. АГЕНТЫ ($AGENT_N паспортов) — id | level | line-of-defence | департамент | навыки | callers→callees | рой"
  emit_agents tsv | while IFS=$'\x1f' read -r id lv lod dep sk cl ce sw; do
    echo "  • $id | L:${lv:-?} | ЛЗ:${lod:-—} | ${dep:-—} | навыки:[${sk:-—}] | ${cl:-—}→${ce:-—} | рой:$sw"; done
  echo; echo "C. РАЗРЫВЫ ПО НАВЫКАМ (train verify): $C_STATUS"
  printf '%s\n' "$C_OUT" | sed 's/^/    /' | head -8
  echo; echo "D. КЛАССИФИКАЦИЯ ПО РОЮ (вывод из capabilities/agent_id — Ruflo/OpenClaw/MiroFish/MetaClaw/other)"
  emit_agents tsv | awk 'BEGIN{FS="\037"} {c[$8]++} END{for(k in c) printf "    %s: %d\n",k,c[k]}'
  echo; echo "E. ОБОРУДОВАНИЕ (топология: Legion 64GB=фабрика; evo1/evo2 128GB=проект)"
  echo "    ollama=$E_OLLAMA | docker=$E_DOCKER"
  echo "    (evo1/evo2 — read-only ssh-аудит на хосте; деградирует при недоступности)"
  echo; echo "F. МОДЕЛИ И ЭФФЕКТИВНОСТЬ"
  echo "    модели=$F_MODELS | model-card файлов найдено=$F_CARDS"
  if [ "${F_CARDS:-0}" = "0" ]; then echo "    ПРОБЕЛ: карточки моделей не найдены (см. MODEL-RISK-MANAGEMENT.md) — AWAITS OPERATOR"; fi
  echo; echo "G. ДОП. ОБЯЗАННОСТИ: контроль качества + UI/UX"
  echo "    per-PR gate(.githooks/pre-commit)=$G_PRE | traffic-light=$G_TL | cron 08:00/20:00 CEST=$G_CRON"
  echo "    UI/UX pipeline(design_pipeline_agent)=$G_UIUX"
  echo; echo "Автоматизация: A,B,C,D,G=полная (репо); E,F=частичная (нужен host-аудит ollama/ssh)."
}

collect_all
if [ "$JSON" -eq 1 ]; then emit_json; else emit_text; fi
