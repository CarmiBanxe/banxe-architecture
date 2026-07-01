#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# UI/UX pipeline validator — GOVERNANCE-side, READ-ONLY. No mutation.
# Validates the §6 "UI/UX Delivery Process (5 stages)" governance present in THIS
# repo (docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md), each 🟢/🟡/🔴:
#   • all 5 stages declared in §6 (parsed);
#   • canonical input artifacts present (BANXE-UI-UX-RESEARCH/SYSTEM + the canon);
#   • design_pipeline_agent passport present + bound (allowed_skills);
#   • stages 3-5 gating references quality-gate.sh + invariants (wiring statement);
#   • [advisory] evidence-ingest: findings envelope per UIUX-RUNTIME-CONTRACT (P1, v1.0.0) —
#     absent envelope => 'unknown', NEVER runtime-passed (transport [UNKNOWN], P2 project-side);
#   • [advisory] Layer-B static audit (spec #916): tokens / components / states-declared / drift /
#     semantic-a11y (on the design-system docs — NOT banxe-ui runtime);
#   • [BLOCKING] DEDUP (ADR-102): duplicate / unsourced-variant declarations block (the ONLY new
#     hard-gate term; all other Layer-B checks are advisory and never affect exit).
#   • [Layer D · spec #916] CONSOLIDATED REPORT: every verdict above aggregated into one findings[] array
#     shaped to schemas/uiux-audit-findings.schema.json (result: requirement/status/severity + file_paths/
#     confidence/remediation; category/source are report annotations) + one `decision`
#     (overall/blocking_count/one_next_step). READ-ONLY aggregation — introduces NO new gate; the
#     `blocking` counter and exit codes are already fixed above and are NOT changed here.
#   • [Layer E · spec #916] the `decision` is the single repo-side merge-readiness surface the factory
#     (left terminal) consumes; it binds existing canon by pointer only — CONFLICT-LEDGER (deconfliction) ·
#     TERMINAL-OWNERSHIP (zones) · ADR-154 (arbiter) · UIUX-GATE-POLICY (severity map) · dedup-before-merge
#     = the ADR-102 blocking term. No parallel governance model is introduced.
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

# ADVISORY (non-blocking) — evidence-ingest per UIUX-RUNTIME-CONTRACT.md (P1, contract_version 1.0.0).
# The findings envelope is emitted by banxe-ui (project-side); transport/location is [UNKNOWN] (P2 decision).
# Checks a declared/overridable path; ABSENCE => 'unknown', NEVER asserts runtime as passed. NEVER feeds `blocking`/exit.
_ENV_PATH=g("UX_EVIDENCE_ENVELOPE") or "evidence/uiux-findings.json"
_CONTRACT_VERSION="1.0.0"
def _ingest():
    p=os.path.join(ROOT,_ENV_PATH)
    if not os.path.isfile(p):
        return ("unknown","envelope absent (transport [UNKNOWN], P2 project-side) — runtime NOT asserted passed")
    try: env=json.load(open(p,encoding='utf-8'))
    except Exception as e: return ("unknown",f"envelope unreadable: {e}")
    missing=[k for k in ("contract_version","commit_sha","generated_at","results") if k not in env]
    if missing: return ("unknown",f"envelope missing required fields {missing}")
    if env.get("contract_version")!=_CONTRACT_VERSION:
        return ("unknown",f"contract_version {env.get('contract_version')!r} != {_CONTRACT_VERSION} — re-emit")
    nres=len(env.get("results") or [])
    return ("present",f"contract {env['contract_version']}, commit {str(env.get('commit_sha'))[:7]}, {nres} results (freshness vs frontend commit = P2 wiring)")
if SELF:
    ing_status,ing_msg=("present","self-test")
else:
    ing_status,ing_msg=_ingest()
sv_ingest="🟢" if ing_status=="present" else "🟡"   # advisory: 🟡 when unknown/absent — NEVER 🔴, NEVER blocking

# Layer B static audit (spec #916) applying UIUX-GATE-POLICY.md (#918) — governance-side, read-only, on THIS
# repo's design-system docs (NOT banxe-ui runtime). Advisory checks 🟡 NEVER feed `blocking`; DEDUP (ADR-102) is
# the ONLY new BLOCKING term (duplicate / unsourced-variant per gate-policy §1).
_UXSYS="docs/BANXE-UI-UX-SYSTEM.md"
def _read(rel):
    try: return open(os.path.join(ROOT,rel),encoding='utf-8').read()
    except FileNotFoundError: return ""
if SELF:
    b_tok=b_comp=b_states=b_drift=b_sem=True; dedup_dups=0
else:
    _sys=_read(_UXSYS)
    b_tok=bool(re.search(r'--(space|text|color)-|^##\s*UI System',_sys,re.M))                        # tokens declared
    b_comp=bool(re.search(r'(?i)component (patterns|catalog)|Balance Widget|Transaction Row',_sys))  # component catalog
    b_states=bool(re.search(r'(?i)(empty|loading|error)[- ]?state',_sys))                            # states declared (static)
    b_sem=bool(re.search(r'(?i)WCAG|aria|semantic|keyboard|focus',_sys))                             # a11y/semantic declared
    b_drift=(_has(_CANON_REL,r'Taste Rubric \(advisory bands\)')==bool(re.search(r'^##\s*Taste Rubric \(advisory\)',_sys,re.M)))  # canon<->doc pointer consistent
    _heads=re.findall(r'^#{2,3}\s+(.+?)\s*$',_sys,re.M)                                               # DEDUP: duplicate H2/H3 declarations
    _cnt={}
    for _h in _heads: _cnt[_h.strip().lower()]=_cnt.get(_h.strip().lower(),0)+1
    dedup_dups=sum(1 for _c in _cnt.values() if _c>1)
dedup_ok=(dedup_dups==0)
va=lambda ok:"🟢" if ok else "🟡"                       # advisory verdict — NEVER 🔴
sv_tok,sv_comp,sv_states,sv_drift,sv_sem=va(b_tok),va(b_comp),va(b_states),va(b_drift),va(b_sem)
sv_dedup="🟢" if dedup_ok else "🔴"                     # DEDUP is BLOCKING per ADR-102 / gate-policy §1

n_stage=len(stages); n_in=len(present_inputs)
blocking = (n_stage!=5) + (n_in!=len(INPUTS)) + (0 if passport_bound else 1) + (0 if gating else 1) + (0 if dedup_ok else 1)
def v(ok): return "🟢" if ok else "🔴"
sv_stage=v(n_stage==5); sv_in=v(n_in==len(INPUTS)); sv_pp=v(passport_bound); sv_gate=v(gating)
overall="🟢" if blocking==0 else "🔴"
delegated=["Storybook deploy (banxe-ui)","design-token machine source (banxe-ui/packages/design-tokens)","axe-core accessibility CI (banxe-ui)"]
awaits=["Head of Design — RACI holder (§7.2)","Design System Lead — named owner (§7.2)"]

# ── Layer D (spec #916): CONSOLIDATED REPORT — aggregates every verdict above into one findings[] array shaped
# to schemas/uiux-audit-findings.schema.json. Core keys (requirement/status/severity/file_paths/confidence/
# remediation) match the schema's result object exactly; category/source are report-only annotations. This is a
# READ-ONLY re-projection of verdicts ALREADY computed — it adds NO gate; `blocking`/exit stay as fixed above.
def _f(req,status,severity,category,source,paths,remediation,confidence=None):
    d=dict(requirement=req,status=status,severity=severity,category=category,source=source,file_paths=list(paths),remediation=remediation)
    if confidence is not None: d["confidence"]=confidence
    return d
_ps=lambda ok:"pass" if ok else "fail"       # blocking-class: satisfied→pass, else fail
_pa=lambda ok:"pass" if ok else "advisory"   # advisory-class: satisfied→pass, else advisory (never fail/block)
findings=[
  _f("delivery_stages_5",_ps(n_stage==5),"blocking","governance","design-system-canon §6",[INPUTS[2]],"Declare all 5 §6 delivery stages in the canon" if n_stage!=5 else "clean",1.0),
  _f("canonical_inputs",_ps(n_in==len(INPUTS)),"blocking","governance","this-repo",[p for p in INPUTS if p not in present_inputs] or INPUTS,"Restore missing canonical input artifact(s)" if n_in!=len(INPUTS) else "clean",1.0),
  _f("design_pipeline_agent_passport",_ps(passport_bound),"blocking","governance","passport",[PASSPORT],"Bind allowed_skills in the passport" if not passport_bound else "clean",1.0),
  _f("stage_gating_quality_invariants",_ps(gating),"blocking","governance","design-system-canon §6",[INPUTS[2]],"Reference quality-gate.sh + invariants in §6 stages 3-5" if not gating else "clean",1.0),
  _f("duplication",_ps(dedup_ok),"blocking","duplication","ADR-102 / gate-policy §1",[_UXSYS],(f"Resolve {dedup_dups} duplicate/unsourced declaration(s) before merge" if not dedup_ok else "clean"),1.0),
  _f("taste_rubric",_pa(taste_ok),"advisory","taste","UI-UX-DESIGN-SYSTEM-CANON §5A",[INPUTS[1],INPUTS[2]],"Complete taste A/B/C (advisory; θ=on-canon feeds only the impeccable loop, never promotion)" if not taste_ok else "clean"),
  _f("tokens",_pa(b_tok),"advisory","static","spec #916 Layer-B",[_UXSYS],"Declare design tokens in the design-system doc" if not b_tok else "clean"),
  _f("components",_pa(b_comp),"advisory","static","spec #916 Layer-B",[_UXSYS],"Declare the component catalog" if not b_comp else "clean"),
  _f("state_coverage",_pa(b_states),"advisory","static","spec #916 Layer-B",[_UXSYS],"Declare empty/loading/error states (runtime coverage = banxe-ui evidence)" if not b_states else "clean"),
  _f("drift",_pa(b_drift),"advisory","static","spec #916 Layer-B",[INPUTS[1],INPUTS[2]],"Reconcile canon↔design-system pointer" if not b_drift else "clean"),
  _f("semantic_a11y_static",_pa(b_sem),"advisory","static","spec #916 Layer-B",[_UXSYS],"Declare a11y/semantic (WCAG runtime gate stays banxe-ui axe-core)" if not b_sem else "clean"),
  _f("evidence_ingest",("pass" if ing_status=="present" else "unknown"),"advisory","runtime-evidence","UIUX-RUNTIME-CONTRACT v"+_CONTRACT_VERSION,[_ENV_PATH],ing_msg),
]
# One next step (deterministic): highest-severity OPEN finding — blocking-fail first (gate order above),
# then advisory/unknown, else none. This is the ONE Best-Single-Artifact next action (CLAUDE.md §12).
_open_block=[x for x in findings if x["severity"]=="blocking" and x["status"]!="pass"]
_open_adv=[x for x in findings if x["severity"]=="advisory" and x["status"]!="pass"]
if _open_block:
    _n=_open_block[0]; one_next="[BLOCK] "+_n["requirement"]+": "+_n["remediation"]
elif _open_adv:
    _n=_open_adv[0]; one_next="[ADVISORY] "+_n["requirement"]+": "+_n["remediation"]
else:
    one_next="No action — 5 hard gates green · dedup clean · advisories satisfied and evidence known."
decision=dict(overall=overall,blocking_count=blocking,
    blocking_open=[x["requirement"] for x in _open_block],
    advisory_open=[x["requirement"] for x in _open_adv],
    one_next_step=one_next)

if JSON:
    print(json.dumps(dict(overall=overall,blocking=blocking,selftest=SELF,
        stages=dict(verdict=sv_stage,count=n_stage,names=stages),
        inputs=dict(verdict=sv_in,present=present_inputs,missing=[p for p in INPUTS if p not in present_inputs]),
        design_pipeline_agent=dict(verdict=sv_pp,bound=passport_bound),
        gating_quality_gate_invariants=dict(verdict=sv_gate,present=gating),
        taste_declaration=dict(verdict=sv_taste,advisory=True,a_rubric=t_a,b_governance=t_b,adr149_loop=t_c),
        evidence_ingest=dict(verdict=sv_ingest,advisory=True,status=ing_status,detail=ing_msg,contract_version=_CONTRACT_VERSION,envelope_path=_ENV_PATH),
        layer_b_static=dict(tokens=dict(verdict=sv_tok,advisory=True,ok=b_tok),components=dict(verdict=sv_comp,advisory=True,ok=b_comp),states_declared=dict(verdict=sv_states,advisory=True,ok=b_states),drift=dict(verdict=sv_drift,advisory=True,ok=b_drift),semantic_a11y=dict(verdict=sv_sem,advisory=True,ok=b_sem)),
        dedup=dict(verdict=sv_dedup,blocking=True,duplicate_declarations=dedup_dups,ok=dedup_ok),
        consolidated=dict(findings=findings,decision=decision),
        delegated_banxe_ui=delegated,awaits_operator=awaits),ensure_ascii=False,indent=2))
    raise SystemExit(0 if blocking==0 else 20)

print(f"═══ UI/UX-PIPELINE (governance, read-only) — общий: {overall} {'[self-test]' if SELF else ''} ═══")
print(f"\n{sv_stage} §6 этапы доставки: {n_stage}/5"+ (f" — {', '.join(f'{i+1}.{s}' for i,s in enumerate(stages))}" if stages else " — НЕ найдены"))
print(f"{sv_in} канонические входные артефакты: {n_in}/{len(INPUTS)} присутствуют")
for p in INPUTS: print(f"      {'✓' if p in present_inputs else '✗'} {p}")
print(f"{sv_pp} design_pipeline_agent: паспорт {'bound (allowed_skills)' if passport_bound else 'НЕ привязан/отсутствует'}")
print(f"{sv_gate} стадии 3-5 gating: ссылка на quality-gate.sh + инварианты {'присутствует' if gating else 'ОТСУТСТВУЕТ'} (§6)")
print(f"{sv_taste} taste declaration (ADVISORY, non-blocking): A-rubric={'✓' if t_a else '✗'} B-governance={'✓' if t_b else '✗'} ADR-149-loop={'✓' if t_c else '✗'} — advisory only; WCAG §5 + 4 governance checks remain the only hard gates")
print(f"{sv_ingest} evidence ingest (ADVISORY, non-blocking): {ing_status} — {ing_msg}; per UIUX-RUNTIME-CONTRACT v{_CONTRACT_VERSION}; absent envelope = НЕИЗВЕСТНО, never runtime-passed (transport P2 [UNKNOWN])")
print(f"{sv_tok} tokens (ADVISORY, static): design-system tokens declared={'✓' if b_tok else '✗'}")
print(f"{sv_comp} components (ADVISORY, static): component catalog declared={'✓' if b_comp else '✗'}")
print(f"{sv_states} states-declared (ADVISORY, static): empty/loading/error declared={'✓' if b_states else '✗'} (runtime coverage = banxe-ui evidence)")
print(f"{sv_drift} drift (ADVISORY, static): canon↔design-system pointer consistent={'✓' if b_drift else '✗'}")
print(f"{sv_sem} semantic/a11y-static (ADVISORY, static): a11y/semantic declared={'✓' if b_sem else '✗'}")
print(f"{sv_dedup} DEDUP (ADR-102, BLOCKING): duplicate declarations={dedup_dups} — {'clean' if dedup_ok else 'DUPLICATE/unsourced-variant → BLOCKS'}")
print("\nDELEGATED → banxe-ui (отдельный репо; фронтенд/axe-core НЕ выполняются здесь):")
for x in delegated: print(f"  ⚪ {x}")
print("AWAITS OPERATOR:")
for x in awaits: print(f"  ⚪ {x}")
print("\nВалидатор проверяет ТОЛЬКО governance/process-сторону в этом репо; код фронтенда,")
print("Storybook и axe-core CI — в banxe-ui (DEVSECOPS/quality-gate проектного CI).")
# ── Layer D/E CONSOLIDATED DECISION SURFACE (spec #916) — the single repo-side merge-readiness signal.
_nb=sum(1 for x in findings if x['severity']=='blocking'); _na=sum(1 for x in findings if x['severity']=='advisory')
print(f"\n═══ CONSOLIDATED DECISION (Layer D/E) — {overall} · blocking={blocking} ═══")
print(f"  findings: {len(findings)} (blocking-class={_nb}, advisory-class={_na}); severity map per UIUX-GATE-POLICY")
if decision['blocking_open']: print(f"  ⛔ blocking-open: {', '.join(decision['blocking_open'])}")
if decision['advisory_open']: print(f"  🟡 advisory-open: {', '.join(decision['advisory_open'])}")
print(f"  ▶ NEXT (one action): {one_next}")
print("  orchestration (Layer E): repo-side decision surface for the factory (left terminal); binds")
print("  CONFLICT-LEDGER · TERMINAL-OWNERSHIP · ADR-154 · UIUX-GATE-POLICY by pointer; dedup-before-merge")
print("  = ADR-102 blocking term above. No parallel governance model; no runtime asserted passed w/o evidence.")
raise SystemExit(0 if blocking==0 else 20)
PY
