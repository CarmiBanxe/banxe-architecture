#!/usr/bin/env bash
# train.sh — S-FAC-63 (R2 Training, T0) factory training runner.
#
# Source of truth: docs/SKILLS-MATRIX.md (skills + per-plane enforcement).
# Bindings:        agents/passports/**/*.yaml  (allowed_skills: <snake_case skill id>).
# Modes:
#   dry-run  — parse matrix↔passport mapping, report, NO writes (always 0 if parseable).
#   verify   — assert every MANDATORY skill has a passport binding; non-zero on any gap.
#   run      — T0 scaffold: host-aware plan (no model mutation yet; real training = later sprints).
# Host-aware: GPU paths only where an NVIDIA GPU is present (legion RTX 4070); evo1/evo2 degrade.
# No hardcoded secrets. POSIX-ish bash.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MATRIX="${SKILLS_MATRIX:-$ROOT/docs/SKILLS-MATRIX.md}"
PASSPORT_DIR="${PASSPORT_DIR:-$ROOT/agents/passports}"

log() { printf '[train] %s\n' "$*"; }
die() { printf '[train] ✗ %s\n' "$*" >&2; exit 1; }

# "Context Memory Sync" -> context_memory_sync ; "CI/CD Quick Setup" -> cicd_quick_setup
norm_id() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 ]+//g; s/ +/_/g; s/^_+|_+$//g'; }

# Emit "<id>\t<mandatory 0|1>\t<name>" per skill (mandatory = MANDATORY in Developer OR Product plane).
parse_skills() {
  [ -f "$MATRIX" ] || die "SKILLS-MATRIX not found: $MATRIX"
  awk '
    /^## Skill [0-9]+ —/ { if (have) print name "\t" mand; name=$0; sub(/.*— /,"",name);
                           gsub(/^[ \t]+|[ \t]+$/,"",name); mand=0; have=1; next }
    have && /^\|[ ]*Developer Plane[ ]*\|/ && /MANDATORY/ { mand=1 }
    have && /^\|[ ]*Product Plane[ ]*\|/   && /MANDATORY/ { mand=1 }
    END { if (have) print name "\t" mand }
  ' "$MATRIX"
}

# Union of allowed_skills ids across every passport (top + nested dirs).
collect_bound() {
  local f
  for f in "$PASSPORT_DIR"/*.yaml "$PASSPORT_DIR"/**/*.yaml; do
    [ -f "$f" ] || continue
    awk '/^allowed_skills:/{f=1;next} f&&/^[a-zA-Z_]+:/{f=0}
         f&&/^[[:space:]]*-/{gsub(/#.*/,"");gsub(/[[:space:]-]/,"");if($0!="")print}' "$f"
  done | sort -u
}

detect_gpu() { if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then echo yes; else echo no; fi; }

# Shared analysis: populates SKILLS_TSV (file) + BOUND (file); echoes counts.
analyze() {
  SKILLS_TSV="$(mktemp)"; BOUND="$(mktemp)"
  parse_skills > "$SKILLS_TSV"
  collect_bound > "$BOUND"
  local n_sk n_mand n_pp
  n_sk=$(wc -l < "$SKILLS_TSV"); n_pp=$(find "$PASSPORT_DIR" -name '*.yaml' | wc -l)
  n_mand=$(awk -F'\t' '$2==1' "$SKILLS_TSV" | wc -l)
  log "matrix=$MATRIX skills=$n_sk mandatory=$n_mand passports=$n_pp bound_ids=$(wc -l < "$BOUND")"
}

# Print per-mandatory-skill binding status; return count of unbound mandatory skills.
report_bindings() {
  local id mand name unbound=0
  while IFS=$'\t' read -r name mand; do
    [ "$mand" = "1" ] || continue
    id="$(norm_id "$name")"
    if grep -qxF "$id" "$BOUND"; then
      printf '  ✓ %-32s bound\n' "$id"
    else
      printf '  ✗ %-32s UNBOUND (mandatory, no passport allowed_skills)\n' "$id"; unbound=$((unbound+1))
    fi
  done < "$SKILLS_TSV"
  return "$unbound"
}

mode_dry() {
  log "MODE dry-run (validate matrix↔passport mapping; NO writes)"
  analyze
  set +e; report_bindings; local u=$?; set -e
  log "dry-run: $u mandatory skill(s) without a passport binding (informational; gate = verify)"
  rm -f "$SKILLS_TSV" "$BOUND"
  log "✅ dry-run OK (no writes)"; return 0
}

mode_verify() {
  log "MODE verify (gate: every MANDATORY skill must have a passport binding)"
  analyze
  set +e; report_bindings; local u=$?; set -e
  rm -f "$SKILLS_TSV" "$BOUND"
  if [ "$u" -gt 0 ]; then die "verify FAILED — $u mandatory skill(s) unbound (see ✗ above; close in S-FAC-66)"; fi
  log "✅ verify OK — all mandatory skills bound"; return 0
}

mode_run() {
  log "MODE run (T0 scaffold — no model mutation; real training is later sprints)"
  local gpu; gpu="$(detect_gpu)"
  analyze
  if [ "$gpu" = "yes" ]; then log "host: GPU present → GPU training path enabled (legion RTX 4070 class)"
  else log "host: NO GPU → degrade gracefully (validate-only; defer GPU train to a GPU host, e.g. legion)"; fi
  log "T0 plan: train/bind $(awk -F'\t' '$2==1' "$SKILLS_TSV" | wc -l) mandatory skill(s) to their passports."
  rm -f "$SKILLS_TSV" "$BOUND"
  log "✅ run T0 scaffold complete (no-op execution path wired)"; return 0
}

main() {
  case "${1:-}" in
    dry-run|--dry-run|dry) mode_dry ;;
    verify|--verify)       mode_verify ;;
    run|--run|"")          mode_run ;;
    -h|--help) sed -n '2,12p' "$0" ;;
    *) die "unknown mode '${1:-}' (use: dry-run | verify | run)" ;;
  esac
}
main "$@"
