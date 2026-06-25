#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Skills-binding audit — READ-ONLY proposal tool (no mutation). Factory upskilling.
# Spec/gap: live «ОТЧЁТ ФАБРИКИ» 2026-06-25 — ~40/57 passports have no bound skills.
#
# WHAT: iterate agents/passports/*.yaml; report per agent whether it has bound
#       allowed_skills / level / line_of_defence / department; for UNBOUND agents
#       PROPOSE genuinely-applicable skills from docs/SKILLS-MATRIX.md (NEVER invent
#       a skill outside the matrix); summarise counts + a priority list (Level-1/2
#       line-of-defence agents first). PROPOSALS ONLY — applies nothing (separate sprint).
# Modes: (default) RU plain-academic text | --json | --self-test (hermetic, exit 0).
# Exit:  0 always (audit report, not a gate) · 2 usage error.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PASSPORTS="$REPO_ROOT/agents/passports"
MATRIX="$REPO_ROOT/docs/SKILLS-MATRIX.md"

MODE=text
for a in "$@"; do case "$a" in
  --json) MODE=json ;;
  --self-test|--dry-run) MODE=selftest ;;
  -h|--help) grep -E '^# ' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "STOP: unknown arg '$a'" >&2; exit 2 ;;
esac; done

[ -d "$PASSPORTS" ] || { echo "STOP: passports dir not found: $PASSPORTS" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "STOP: python3 required" >&2; exit 2; }

# All logic in one python block (quoted heredoc — no shell interpolation of data).
SBA_PASSPORTS="$PASSPORTS" SBA_MATRIX="$MATRIX" SBA_MODE="$MODE" python3 <<'PY'
import os,glob,json,re
try: import yaml
except Exception: yaml=None
P=os.environ["SBA_PASSPORTS"]; MATRIX=os.environ["SBA_MATRIX"]; MODE=os.environ["SBA_MODE"]

def norm_id(s):  # mirrors scripts/train.sh norm_id (canonical snake_case skill id)
    s=re.sub(r'[^a-z0-9 ]+','',s.lower()); return re.sub(r'\s+','_',s.strip())

def matrix_ids(path):  # parse "## Skill N — Name" → allowed id set (source of truth)
    ids=set()
    try:
        for ln in open(path,encoding='utf-8'):
            m=re.match(r'^##\s*Skill\s*\d+\s*[—-]\s*(.+?)\s*$',ln)
            if m: ids.add(norm_id(m.group(1)))
    except FileNotFoundError: pass
    return ids

ALLOWED=matrix_ids(MATRIX)  # propose ONLY ids that exist here (never invent)

# (skill_id, reason, plane-tag) keyed predicates — proposed only if id in ALLOWED.
def proposals(aid, caps, dept, has_ports):
    hay=(aid+" "+" ".join(map(str,caps))+" "+str(dept)).lower()
    toks=re.findall(r'[a-z0-9]+',hay)  # token/prefix match — avoids "report"⊃"port" false hits
    def kw(*ks): return any(any(t==k or t.startswith(k) for t in toks) for k in ks)
    code = has_ports or kw("service","port","adapter","integration","pipeline","gateway","api","webhook","router","mcp","writer","elt")
    fin  = kw("payment","aml","recon","fraud","treasury","sanction","transaction","tx","alm","scoring","safeguard")
    spec = kw("orchestrat","governor","spec","propos","policy","oversight","audit","report","planning","lifecycle","return","board","compliance","risk")
    cand=[("context_memory_sync","универсальная непрерывность IL/audit-trail (MANDATORY)","M")]
    if spec: cand.append(("rapid_spec_builder","предлагает IL/ADR/спеки (MANDATORY)","M"))
    if code: cand.append(("clean_architecture_enforcer","чистая арх., нет cross-contour импортов (MANDATORY)","M"))
    if code: cand.append(("error_handling_standardizer","типизированные исключения на портах/адаптерах (Product MANDATORY)","M"))
    if code: cand.append(("api_contract_guardian","владеет *Port/API/webhook-контрактом (Product MANDATORY)","M"))
    if fin:  cand.append(("performance_scanner","критичный по времени путь payment/AML/recon (Product MANDATORY)","M"))
    if code: cand.append(("smart_test_generator","сценарные/port-тесты (CONTROLLED — review до merge)","C"))
    if kw("platform","sdk","ml_pipeline","data_lake","elt","build"):
        cand.append(("dependency_optimizer","аудит зависимостей/лицензий (CONTROLLED)","C"))
    return [c for c in cand if c[0] in ALLOWED]

def load(f):
    try:
        d=yaml.safe_load(open(f,encoding='utf-8')) if yaml else {}
        return d if isinstance(d,dict) else {}
    except Exception: return {}

rows=[]
for f in sorted(glob.glob(os.path.join(P,"*.yaml"))):
    d=load(f); aid=d.get("agent_id") or os.path.basename(f)[:-5]
    sk=d.get("allowed_skills") or []; sk=sk if isinstance(sk,list) else []
    lvl=d.get("level"); lod=d.get("line_of_defence"); dep=d.get("department")
    rec=dict(agent_id=aid, n_skills=len(sk), bound=bool(sk),
             level=("" if lvl is None else str(lvl)),
             has_level=lvl is not None, has_lod=bool(lod), has_dept=bool(dep),
             proposals=[] if sk else proposals(aid, d.get("capabilities") or [], dep, "ports" in d))
    rows.append(rec)

# ── priority: unbound, Level-1/2 with a line-of-defence first ──────────────────
def lvl_key(r):
    try: n=int(re.sub(r'\D','',r["level"]) or 99)
    except Exception: n=99
    return n
unbound=[r for r in rows if not r["bound"]]
prio=sorted(unbound, key=lambda r:(not r["has_lod"], lvl_key(r), r["agent_id"]))

S=dict(total=len(rows), bound=sum(r["bound"] for r in rows), unbound=len(unbound),
       no_level=sum(not r["has_level"] for r in rows),
       no_lod=sum(not r["has_lod"] for r in rows),
       no_dept=sum(not r["has_dept"] for r in rows),
       matrix_skills=len(ALLOWED))

if MODE=="json":
    print(json.dumps(dict(summary=S, matrix_ids=sorted(ALLOWED), agents=rows,
                          priority=[r["agent_id"] for r in prio[:15]]), ensure_ascii=False, indent=2))
elif MODE=="selftest":
    ok = S["total"]>0 and S["matrix_skills"]>0 and all(
        all(p[0] in ALLOWED for p in r["proposals"]) for r in rows)
    print(f"SELF-TEST {'OK' if ok else 'FAIL'} — passports={S['total']} matrix_skills={S['matrix_skills']} "
          f"bound={S['bound']} unbound={S['unbound']} (proposals⊆matrix={ok})")
    raise SystemExit(0 if ok else 1)
else:
    print(f"═══ АУДИТ ПРИВЯЗКИ НАВЫКОВ (skills-bind) — read-only, предложения ═══")
    print(f"Паспортов: {S['total']} | со связанными навыками: {S['bound']} | БЕЗ навыков: {S['unbound']}")
    print(f"Без level: {S['no_level']} | без line_of_defence: {S['no_lod']} | без department: {S['no_dept']} | навыков в матрице: {S['matrix_skills']}")
    print("\nA. СОСТОЯНИЕ ПО АГЕНТАМ (id | навыки | level | LoD | dept)")
    for r in rows:
        print(f"  • {r['agent_id']} | навыки:{r['n_skills'] if r['bound'] else '—'} | "
              f"L:{r['level'] or '?'} | LoD:{'да' if r['has_lod'] else '—'} | dept:{'да' if r['has_dept'] else '—'}")
    print("\nB. ПРЕДЛОЖЕНИЯ ПО ПРИВЯЗКЕ (только агенты БЕЗ навыков; навыки строго из SKILLS-MATRIX)")
    for r in prio:
        if not r["proposals"]: continue
        print(f"  ▸ {r['agent_id']} (L:{r['level'] or '?'}, LoD:{'да' if r['has_lod'] else '—'}):")
        for sid,reason,tag in r["proposals"]:
            print(f"      - {sid} [{tag}] — {reason}")
    print("\nC. ПРИОРИТЕТ ПРИВЯЗКИ (Level-1/2 с line-of-defence — первыми)")
    for i,r in enumerate(prio[:10],1):
        print(f"  {i}. {r['agent_id']} (L:{r['level'] or '?'}, LoD:{'да' if r['has_lod'] else '—'}, "
              f"предложено навыков: {len(r['proposals'])})")
    print("\nПРИМЕЧАНИЕ: read-only предложения; ничего не применено. auto_refactor_pro не предлагается "
          "(CONTROLLED + запрещён на compliance-контурах, I-20). Применение — отдельный sprint по группам.")
PY
