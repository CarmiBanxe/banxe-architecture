---
il_ts: 2026-06-23T20:51:00Z
session_id: agent-factory-factory-s-fac-63-training-runner
source: CEO
status: DONE
---
### S-FAC-63 (R2 Training T0) — training runner scripts/train.sh + Makefile train/train-dry/train-verify (train-dry GREEN)
- **Date:** 2026-06-23 · **Type:** factory tooling; scripts + Makefile + ledger; reads SKILLS-MATRIX↔passports (no model training yet — T0 scaffold).
- **Decision:** Deliver the missing training runner. `scripts/train.sh` reads `docs/SKILLS-MATRIX.md` as source-of-truth, resolves passport bindings under `agents/passports/**/*.yaml` (`allowed_skills`), and exposes three modes; Makefile wires `train` / `train-dry` / `train-verify`.
- **Instrukciya:** Close S-FAC-63 R2 T0: training runner present, `make train-dry` green (validates matrix↔passport mapping, no writes); GPU-aware (legion RTX 4070 only; evo1/evo2 degrade).
- **Basis (audit):** S-FAC-63 roadmap + live skills-matrix/passport audit 2026-06-23. SKILLS-MATRIX = 10 skills (`## Skill N — <name>`, per-plane MANDATORY/ADVISORY/PROHIBITED/CONTROLLED); 70 passports; 7 mandatory skills (Dev∪Prod).
- **Modes (best-solution):** `dry-run` parses + reports the mapping, NO writes, exit 0 if parseable; `verify` gates that every MANDATORY skill has a passport `allowed_skills` binding, exit non-zero on gap; `run` = T0 host-aware scaffold (GPU path on legion, graceful degrade off-GPU; no model mutation — real training is later sprints). `set -euo pipefail`; no hardcoded secrets; not Python ⇒ S320/S314 N/A.
- **Proof:** `make train-dry` → exit 0 GREEN (skills=10, mandatory=7, passports=70, bound_ids=7). `make train` (run T0) → exit 0, GPU detected on legion. `make train-verify` → exit 1 (honest gate).
- **Finding (flagged, NOT invented):** `verify` surfaces **1 mandatory skill unbound — `cicd_quick_setup`** (CI/CD Quick Setup, MANDATORY in Developer plane) appears in no passport `allowed_skills` (it is a Dev-plane infra skill, not a runtime-agent capability). Real binding gap → close in **S-FAC-66** (skill↔passport↔ledger binding). The other 6 mandatory skills are bound.
- **DoD:** **MET for T0** — runner exists, `train-dry` green. (Full adoption — verify all-green — is S-FAC-66 scope per the 100%-adoption gate.)
- **Change (minimal, no duplication):** +`scripts/train.sh` (exec 100755); +3 Makefile targets (separate `.PHONY` line appended, existing targets untouched); +1 ledger shard. No skills/agents invented — parsed from existing SKILLS-MATRIX/passports.
- **Canon compliance:** live-audit source of truth; best-solution; minimal-diff; append-only ledger (ADR-119 frozen IL, max+1); authored in ISOLATED worktree off origin/main (ADR-120, NOT shared checkout); branch ADR-060-compliant (`agent/factory/factory/s-fac-63-training-runner`); hooks enabled (no `--no-verify`/`--admin`/bypass); STOP before merge.
- **Coupling/append-only:** branch off origin/main@ac2d8be; single new shard; no prior entry modified.
- **Proof (ledger):** `build_ledger.py --check` exit 0; guardian-ledger / ledger-append-only / guardian-ledger-shards / guardian-branch-naming green (local); squash PR to main (merge-queue); operator merges.
- **Refs:** `docs/SKILLS-MATRIX.md`; `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §S-FAC-63; `agents/passports/` (`allowed_skills`); `.claude/rules/agents.md` (allowed_skills = permission to use); ADR-120; ADR-119; ADR-060.
