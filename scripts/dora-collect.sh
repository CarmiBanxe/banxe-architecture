#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# DORA collector — REPO-DERIVED (proxy). READ-ONLY, no mutation.
# Computes the four DORA keys (D-1..D-4) from data the repo already has
# (merged PRs via `gh` + commit timestamps), compared to KPI-DORA-FRAMEWORK.md
# targets. Emits 🟢/🟡/🔴 per key with the number.
#
# IMPORTANT (honesty boundary): these are **repo-derived proxies**, NOT the live
# production telemetry. The canonical DORA pipeline = Prometheus + Grafana on evo2
# (KPI-DORA-FRAMEWORK.md §4.2) and remains **AWAITS OPERATOR**. This collector
# closes the *computable* part of S3 without inventing infra metrics.
#
# Targets (KPI-DORA-FRAMEWORK.md, RECONCILED 2026-06-22):
#   D-1 Deployment Frequency  ≥ 1 deploy/day per squad
#   D-2 Lead Time for Changes < 1 day   (proxy: PR createdAt → mergedAt)
#   D-3 Change Failure Rate   ≤ 15%
#   D-4 MTTR                  < 1 hour
#
# Modes: (default) RU plain-academic text | --json | --self-test (hermetic, synthetic)
# Flags: --since N  (window in days, default 30)
# Exit:  0 ok · 2 usage error. (Report, not a gate.)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

GH_REPO="CarmiBanxe/banxe-architecture"
DAYS=30; JSON=0; SELFTEST=0
while [ $# -gt 0 ]; do case "$1" in
  --json) JSON=1 ;;
  --self-test|--dry-run) SELFTEST=1 ;;
  --since) shift; DAYS="${1:?--since needs N}" ;;
  --since=*) DAYS="${1#*=}" ;;
  -h|--help) grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "STOP: unknown arg '$1'" >&2; exit 2 ;;
esac; shift; done
MODE=$([ "$JSON" -eq 1 ] && echo json || echo text)   # output format (orthogonal to data source)
case "$DAYS" in (*[!0-9]*|'') echo "STOP: --since must be an integer" >&2; exit 2 ;; esac

command -v python3 >/dev/null 2>&1 || { echo "STOP: python3 required" >&2; exit 2; }

# ── gather PR data (synthetic in self-test; gh in live; degrade if gh absent) ──
if [ "$SELFTEST" -eq 1 ]; then
  NOW="2026-06-25T22:00:00Z"
  PRS='[
   {"number":1,"title":"feat: a","createdAt":"2026-06-24T10:00:00Z","mergedAt":"2026-06-24T18:00:00Z"},
   {"number":2,"title":"docs: b","createdAt":"2026-06-23T10:00:00Z","mergedAt":"2026-06-23T12:00:00Z"},
   {"number":3,"title":"revert: bad change","createdAt":"2026-06-22T10:00:00Z","mergedAt":"2026-06-22T13:00:00Z"},
   {"number":4,"title":"fix(hotfix): prod","createdAt":"2026-06-21T10:00:00Z","mergedAt":"2026-06-21T11:30:00Z"},
   {"number":5,"title":"feat: c","createdAt":"2026-06-20T10:00:00Z","mergedAt":"2026-06-20T20:00:00Z"}
  ]'
  NOTE="self-test (synthetic data)"
else
  NOW="auto"   # data-anchored: window ends at the latest merge (immune to host-clock skew)
  if command -v gh >/dev/null 2>&1; then
    PRS="$( gh pr list --repo "$GH_REPO" --state merged --base main --limit 400 \
            --json number,title,createdAt,mergedAt 2>/dev/null || echo '[]' )"
    NOTE="repo-derived (proxy) from merged PRs to main"
  else
    PRS='[]'; NOTE="gh unavailable — repo-derived DORA needs gh (host audit); degraded"
  fi
fi

# ── compute D-1..D-4 in python (robust date math), render text|json ───────────
DORA_PRS="$PRS" DORA_NOW="$NOW" DORA_DAYS="$DAYS" DORA_MODE="$MODE" DORA_NOTE="$NOTE" python3 <<'PY'
import os,json,re,statistics as st
from datetime import datetime,timedelta
def iso(s): return datetime.fromisoformat(s.replace("Z","+00:00"))
g=os.environ.get
mode=g("DORA_MODE"); days=int(g("DORA_DAYS")); note=g("DORA_NOTE")
try: prs=json.loads(g("DORA_PRS") or "[]")
except Exception: prs=[]
# now: data-anchored (latest mergedAt) when "auto", else explicit (self-test fixed)
_merged=[iso(p["mergedAt"]) for p in prs if p.get("mergedAt")]
now = (max(_merged) if _merged else iso("2026-06-25T22:00:00Z")) if g("DORA_NOW")=="auto" else iso(g("DORA_NOW"))
since=now-timedelta(days=days)
# window = merged within [since, now]
W=[p for p in prs if p.get("mergedAt") and since<=iso(p["mergedAt"])<=now]
FAIL=re.compile(r'\b(revert|rollback)\b|hotfix',re.I)
def lead_hours(p):  # proxy: PR createdAt → mergedAt (lightweight; open-to-deploy lead time)
    if not p.get("createdAt") or not p.get("mergedAt"): return None
    return (iso(p["mergedAt"])-iso(p["createdAt"])).total_seconds()/3600.0
n=len(W); fails=[p for p in W if FAIL.search(p.get("title",""))]
capped = len(prs)>=400 and n==len(prs)   # hit the gh fetch --limit → window truncated
d1=n/days if days else 0.0
leads=[h for h in (lead_hours(p) for p in W) if h is not None]
d2=st.median(leads)/24.0 if leads else None           # days
d3=(len(fails)/n*100.0) if n else 0.0                  # percent
fl=[h for h in (lead_hours(p) for p in fails) if h is not None]
d4=st.median(fl) if fl else None                       # hours (approx restore)
def col(v,green,yellow,higher_better):
    if v is None: return "⚪"
    if higher_better: return "🟢" if v>=green else ("🟡" if v>=yellow else "🔴")
    return "🟢" if v<=green else ("🟡" if v<=yellow else "🔴")
c1=col(d1,1.0,0.5,True); c2=col(d2,1.0,2.0,False) if d2 is not None else "⚪"
c3=col(d3,15.0,25.0,False); c4=col(d4,1.0,4.0,False) if d4 is not None else "⚪"
res=dict(window_days=days, since=since.isoformat(), now=now.isoformat(), merges=n, note=note, capped=capped,
  D1=dict(name="Deployment Frequency",value=round(d1,2),unit="deploys/day",target="≥1/day",verdict=c1),
  D2=dict(name="Lead Time",value=(round(d2,2) if d2 is not None else None),unit="days",target="<1d",verdict=c2),
  D3=dict(name="Change Failure Rate",value=round(d3,1),unit="%",target="≤15%",verdict=c3,failures=len(fails)),
  D4=dict(name="MTTR (approx)",value=(round(d4,2) if d4 is not None else None),unit="hours",target="<1h",verdict=c4))
if mode=="json":
    print(json.dumps(res,ensure_ascii=False,indent=2)); raise SystemExit(0)
print(f"═══ DORA (repo-derived proxy) — окно {days}д, слияний={n} [{note}] ═══")
cap=" ⚠ выборка ограничена 400 PR — D-1 = нижняя оценка (уменьшите --since)" if capped else ""
print(f"  {res['D1']['verdict']} D-1 Deployment Frequency: {res['D1']['value']} deploys/day (цель ≥1/день){cap}")
v2='n/a' if d2 is None else f"{res['D2']['value']} дн"
print(f"  {c2} D-2 Lead Time: {v2} (цель <1 дн)")
print(f"  {res['D3']['verdict']} D-3 Change Failure Rate: {res['D3']['value']}% ({len(fails)}/{n} revert/hotfix) (цель ≤15%)")
v4='n/a' if d4 is None else f"{res['D4']['value']} ч"
print(f"  {c4} D-4 MTTR (approx): {v4} (цель <1 ч)")
print("\nЭвристики (честно): D-3 = доля PR с revert/rollback/hotfix в заголовке; D-4 = медиана lead-time")
print("этих PR как приближение времени восстановления (приблизительно). D-2 = медиана (PR createdAt→merge).")
print("ГРАНИЦА: это repo-derived прокси. Каноничный сбор = Prometheus+Grafana на evo2")
print("(KPI-DORA-FRAMEWORK.md §4.2) — AWAITS OPERATOR; инфра-метрики здесь НЕ выдумываются.")
PY
