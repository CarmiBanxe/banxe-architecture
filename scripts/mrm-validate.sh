#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Model Risk Management (MRM) validator — READ-ONLY hygiene check. No mutation.
# Parses docs/governance/MODEL-RISK-MANAGEMENT.md §3 (Risk Tiering) → enumerates
# models/roles per tier (T1/T2/T3); checks whether a MODEL CARD exists for each
# (convention: docs/governance/model-cards/<model-slug>.md); compares locally
# installed models (ollama, read-only, degrades) against the tier list; emits a
# tier-by-tier coverage summary with 🟢/🟡/🔴 (🔴 if a T1 model lacks a card).
#
# HONESTY BOUNDARY: operator-gated items are NOT asserted — numeric monitoring
# thresholds (drift/hallucination, §6), the binding T1/T2/T3 regulatory
# classification (§3), the blocking independent-validation gate (§5), and the
# ai-heavy backend routing choice are reported as AWAITS OPERATOR, never invented.
#
# Modes: (default) RU plain-academic text | --json | --self-test (hermetic, synthetic)
# Exit:  0 ok (report, not a gate) · 2 usage error.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MRM="$REPO_ROOT/docs/governance/MODEL-RISK-MANAGEMENT.md"
CARDS="$REPO_ROOT/docs/governance/model-cards"

JSON=0; SELFTEST=0
for a in "$@"; do case "$a" in
  --json) JSON=1 ;;
  --self-test|--dry-run) SELFTEST=1 ;;
  -h|--help) grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "STOP: unknown arg '$a'" >&2; exit 2 ;;
esac; done
command -v python3 >/dev/null 2>&1 || { echo "STOP: python3 required" >&2; exit 2; }

# local installed models (read-only; skipped in self-test; degrade if no ollama)
if [ "$SELFTEST" -eq 0 ] && command -v ollama >/dev/null 2>&1; then
  OLLAMA="$(ollama list 2>/dev/null | awk 'NR>1{print $1}' | paste -sd',' - || true)"
else OLLAMA=""; fi

MRM_FILE="$MRM" CARDS_DIR="$CARDS" MRM_OLLAMA="$OLLAMA" \
MRM_JSON="$JSON" MRM_SELFTEST="$SELFTEST" python3 <<'PY'
import os,re,json
g=os.environ.get
JSON=g("MRM_JSON")=="1"; SELF=g("MRM_SELFTEST")=="1"
CARDS=g("CARDS_DIR")

def slug(m): return re.sub(r'[^a-z0-9.]+','-',m.lower()).strip('-')

def parse_tiers(path):
    """Parse MRM §3 table → {tier: [model-id,...]} from the 'Models / roles' column."""
    tiers={}
    try: txt=open(path,encoding='utf-8').read()
    except FileNotFoundError: return tiers
    for ln in txt.splitlines():
        m=re.match(r'^\|\s*\*\*T([123])\b.*?\*\*\s*\|',ln)
        if not m: continue
        cols=[c.strip() for c in ln.split('|')]
        cell=cols[3] if len(cols)>3 else ""
        ids=set(re.findall(r'`([^`]+)`',cell))                       # backtick aliases/ids
        ids|=set(re.findall(r'\b([a-z][a-z0-9]*(?:[.:+_-][a-z0-9]+)+)\b',cell))  # id-with-separator
        ids={i for i in ids if '/' not in i}                          # drop route paths
        tiers[f"T{m.group(1)}"]=sorted(ids)
    return tiers

if SELF:  # hermetic synthetic data — all cards "present" → green, exit 0
    tiers={"T1":["synthetic-t1"],"T2":["synthetic-t2"],"T3":["synthetic-t3"]}
    present={"synthetic-t1","synthetic-t2","synthetic-t3"}
    ollama=[]
else:
    tiers=parse_tiers(g("MRM_FILE"))
    present={slug(m) for t in tiers.values() for m in t
             if os.path.isfile(os.path.join(CARDS,slug(m)+".md"))}
    ollama=[x for x in (g("MRM_OLLAMA") or "").split(",") if x]

# per-tier coverage + verdict (🔴 if any T1 model lacks a card)
def verdict(tier,miss):
    if not miss: return "🟢"
    return "🔴" if tier=="T1" else "🟡"
rep={}; all_models=set()
for t in ("T1","T2","T3"):
    ms=tiers.get(t,[]); all_models|=set(map(slug,ms))
    miss=[m for m in ms if slug(m) not in present]
    rep[t]=dict(models=ms,total=len(ms),present=len(ms)-len(miss),missing=miss,verdict=verdict(t,miss))
overall="🔴" if rep["T1"]["missing"] else ("🟡" if (rep["T2"]["missing"] or rep["T3"]["missing"]) else "🟢")
# ollama cross-check (best-effort substring match on the slug stem)
def tiered(name):
    s=slug(name)
    return any(s.startswith(x.split('-')[0]) or x in s or s in x for x in all_models)
untiered=[o for o in ollama if not tiered(o)]
awaits=["numeric monitoring thresholds (drift/hallucination) §6","binding T1/T2/T3 regulatory classification §3",
        "blocking independent-validation gate for T1 §5","ai-heavy backend routing choice"]

if JSON:
    print(json.dumps(dict(overall=overall,tiers=rep,cards_dir="docs/governance/model-cards",
        installed=ollama,untiered_installed=untiered,awaits_operator=awaits,selftest=SELF),
        ensure_ascii=False,indent=2)); raise SystemExit(0)

print(f"═══ MRM-ВАЛИДАЦИЯ (read-only) — общий: {overall} {'[self-test]' if SELF else ''} ═══")
print(f"Конвенция карточек моделей: docs/governance/model-cards/<model-slug>.md (шаблон: TEMPLATE.md)")
for t in ("T1","T2","T3"):
    r=rep[t]
    print(f"\n{r['verdict']} {t} — карточек {r['present']}/{r['total']}"
          + (f" | ОТСУТСТВУЮТ: {', '.join(r['missing'])}" if r['missing'] else " | все карточки на месте"))
    print(f"    модели/роли: {', '.join(r['models']) if r['models'] else '—'}")
if not SELF:
    print(f"\nЛокально установленные модели (ollama, read-only): {', '.join(ollama) if ollama else 'n/a (host-аудит)'}")
    if untiered: print(f"  ⚠ запущены, но не отнесены к tier в §3: {', '.join(untiered)}")
print("\nAWAITS OPERATOR (не утверждается этим валидатором):")
for a in awaits: print(f"  - {a}")
print("Валидатор проверяет ТОЛЬКО гигиену (наличие карточек/конвенция). Пороги, обязывающая")
print("регуляторная классификация и выбор backend — решения оператора/CRO (MODEL-RISK-MANAGEMENT.md).")
PY
