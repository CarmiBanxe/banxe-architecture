#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# UI/UX pipeline validator — GOVERNANCE-side, READ-ONLY. No mutation.
# Validates the §6 "UI/UX Delivery Process (5 stages)" governance present in THIS
# repo (docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md), each 🟢/🟡/🔴:
#   • all 5 stages declared in §6 (parsed);
#   • canonical input artifacts present (BANXE-UI-UX-RESEARCH/SYSTEM + the canon);
#   • design_pipeline_agent passport present + bound (allowed_skills);
#   • stages 3-5 gating references quality-gate.sh + invariants (wiring statement).
#
# HONESTY BOUNDARY — frontend lives in the SEPARATE banxe-ui repo:
#   • DELEGATED → banxe-ui: Storybook deploy, design-token machine source
#     (banxe-ui/packages/design-tokens), axe-core accessibility CI. Not run here.
#   • AWAITS OPERATOR: Head-of-Design / Design-System-Lead RACI holder (§7.2).
# No frontend code is invented; axe-core is NOT executed in this governance repo.
#
# Modes: (default) RU plain-academic text | --json | --self-test (hermetic green)
# Exit:  0 ok · 20 a real governance gap (missing stage/artifact/binding) · 2 usage.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

JSON=0; SELFTEST=0
for a in "$@"; do case "$a" in
  --json) JSON=1 ;;
  --self-test|--dry-run) SELFTEST=1 ;;
  -h|--help) grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "STOP: unknown arg '$a'" >&2; exit 2 ;;
esac; done
command -v python3 >/dev/null 2>&1 || { echo "STOP: python3 required" >&2; exit 2; }

UX_ROOT="$REPO_ROOT" UX_JSON="$JSON" UX_SELF="$SELFTEST" python3 <<'PY'
import os,re,json
g=os.environ.get; ROOT=g("UX_ROOT"); JSON=g("UX_JSON")=="1"; SELF=g("UX_SELF")=="1"
CANON=os.path.join(ROOT,"docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md")
INPUTS=["docs/BANXE-UI-UX-RESEARCH.md","docs/BANXE-UI-UX-SYSTEM.md","docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md"]
PASSPORT="agents/passports/design_pipeline_agent.yaml"

def parse_stages(path):
    try: txt=open(path,encoding='utf-8').read()
    except FileNotFoundError: return []
    sec=re.search(r'##\s*6\..*?(?=\n##\s)',txt,re.S)
    body=sec.group(0) if sec else txt
    return re.findall(r'^\|\s*[1-5]\s*\|\s*\*\*(.+?)\*\*',body,re.M)

if SELF:
    stages=["Design Discovery","Wireframing","Design System","Front-end","Usability"]
    present_inputs=list(INPUTS); passport_bound=True; gating=True
else:
    stages=parse_stages(CANON)
    present_inputs=[p for p in INPUTS if os.path.isfile(os.path.join(ROOT,p))]
    try:
        import yaml; d=yaml.safe_load(open(os.path.join(ROOT,PASSPORT),encoding='utf-8')) or {}
        passport_bound=bool(d.get("allowed_skills"))
    except Exception: passport_bound=False
    ct=open(CANON,encoding='utf-8').read() if os.path.isfile(CANON) else ""
    gating=("quality-gate.sh" in ct and "invariant" in ct.lower())

# ADVISORY (non-blocking) — taste-declaration presence; NEVER feeds `blocking`/exit code.
_CANON_REL="docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md"
def _has(rel,pat):
    try: return bool(re.search(pat,open(os.path.join(ROOT,rel),encoding='utf-8').read(),re.M))
    except FileNotFoundError: return False
if SELF:
    t_a=t_b=t_c=True
else:
    t_a=_has("docs/BANXE-UI-UX-SYSTEM.md",r'^##\s*Taste Rubric \(advisory\)')         # A substance
    t_b=_has(_CANON_REL,r'^##\s*5A\.\s*Taste & Polish')                                # B governance
    t_c=_has(_CANON_REL,r'ADR-149') and _has(_CANON_REL,r'(?i)completion[- ]criteria|stop-condition|MAX_ITER')  # ADR-149 loop
taste_ok=t_a and t_b and t_c
sv_taste="🟢" if taste_ok else "🟡"   # advisory: 🟡 worst case — NEVER 🔴, NEVER blocking

n_stage=len(stages); n_in=len(present_inputs)
blocking = (n_stage!=5) + (n_in!=len(INPUTS)) + (0 if passport_bound else 1) + (0 if gating else 1)
def v(ok): return "🟢" if ok else "🔴"
sv_stage=v(n_stage==5); sv_in=v(n_in==len(INPUTS)); sv_pp=v(passport_bound); sv_gate=v(gating)
overall="🟢" if blocking==0 else "🔴"
delegated=["Storybook deploy (banxe-ui)","design-token machine source (banxe-ui/packages/design-tokens)","axe-core accessibility CI (banxe-ui)"]
awaits=["Head of Design — RACI holder (§7.2)","Design System Lead — named owner (§7.2)"]

if JSON:
    print(json.dumps(dict(overall=overall,blocking=blocking,selftest=SELF,
        stages=dict(verdict=sv_stage,count=n_stage,names=stages),
        inputs=dict(verdict=sv_in,present=present_inputs,missing=[p for p in INPUTS if p not in present_inputs]),
        design_pipeline_agent=dict(verdict=sv_pp,bound=passport_bound),
        gating_quality_gate_invariants=dict(verdict=sv_gate,present=gating),
        taste_declaration=dict(verdict=sv_taste,advisory=True,a_rubric=t_a,b_governance=t_b,adr149_loop=t_c),
        delegated_banxe_ui=delegated,awaits_operator=awaits),ensure_ascii=False,indent=2))
    raise SystemExit(0 if blocking==0 else 20)

print(f"═══ UI/UX-PIPELINE (governance, read-only) — общий: {overall} {'[self-test]' if SELF else ''} ═══")
print(f"\n{sv_stage} §6 этапы доставки: {n_stage}/5"+ (f" — {', '.join(f'{i+1}.{s}' for i,s in enumerate(stages))}" if stages else " — НЕ найдены"))
print(f"{sv_in} канонические входные артефакты: {n_in}/{len(INPUTS)} присутствуют")
for p in INPUTS: print(f"      {'✓' if p in present_inputs else '✗'} {p}")
print(f"{sv_pp} design_pipeline_agent: паспорт {'bound (allowed_skills)' if passport_bound else 'НЕ привязан/отсутствует'}")
print(f"{sv_gate} стадии 3-5 gating: ссылка на quality-gate.sh + инварианты {'присутствует' if gating else 'ОТСУТСТВУЕТ'} (§6)")
print(f"{sv_taste} taste declaration (ADVISORY, non-blocking): A-rubric={'✓' if t_a else '✗'} B-governance={'✓' if t_b else '✗'} ADR-149-loop={'✓' if t_c else '✗'} — advisory only; WCAG §5 + 4 governance checks remain the only hard gates")
print("\nDELEGATED → banxe-ui (отдельный репо; фронтенд/axe-core НЕ выполняются здесь):")
for x in delegated: print(f"  ⚪ {x}")
print("AWAITS OPERATOR:")
for x in awaits: print(f"  ⚪ {x}")
print("\nВалидатор проверяет ТОЛЬКО governance/process-сторону в этом репо; код фронтенда,")
print("Storybook и axe-core CI — в banxe-ui (DEVSECOPS/quality-gate проектного CI).")
raise SystemExit(0 if blocking==0 else 20)
PY
