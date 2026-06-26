---
il_ts: 2026-06-26T23:30:00Z
session_id: agent-factory-sub-b-paybis-e9-guard
source: CEO
status: DONE
---
### E9 NeuroNext/Bitrix forward-guard (semgrep deny-rules) — Architecture-Conformance track

- **Objective:** Add CI/lint guard forbidding reintroduction of NeuroNext + Bitrix in EMI runtime code (E9 of mandatory Architecture-Conformance track, ADR-126). CI/lint asset only; no app logic.
- **Live audit (read-only shell, not memory):** banxe-emi-stack origin/main — every semgrep invocation loads --config .semgrep/banxe-rules.yml (FILE): quality-gate.yml:149, lint-python.yml:89, .pre-commit-config.yaml:84, Makefile:140; the .semgrep/banxe-rules/ DIR is loaded by nothing; semgrep YAML cannot include other config files. Footprint baseline neuronext=0 bitrix=0 in services/app. banxe-architecture: this shard + PLAN §1A E9 flip on branch agent/factory/paybis/neuronext-retirement-adr; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN re-ids).
- **Deliverable (emi branch agent/factory/paybis/wave-a-guard, commit cfe185d, SSH-signed):** 2 ERROR deny-rules appended to .semgrep/banxe-rules.yml — banxe-no-neuronext-reintroduction (regex (?i)neuronex) + banxe-no-bitrix-reintroduction (regex (?i)(bitrix|битрикс)); paths include **/services/** + **/app/**, exclude **/tests/** **/docs/** **/.semgrep/**.
- **ADR-102 single mechanism (not parallel/dead file):** rules placed in the actually-loaded banxe-rules.yml (NOT a new .semgrep/banxe-rules/ file which would be dead — dir unconfigured). Deviation from "one new file" is evidence-based and documented; otherwise the guard would not enforce.
- **Verification (recorded):** clean tree → 0 new-rule findings; in-repo positive test (temp services/ file with neuronext_api+Bitrix24 from repo root) → BOTH rules detect, scratch discarded (NOT committed); full --config banxe-rules.yml --error on clean services/ → exit 0; pre-commit full-repo scan (3412 files, 15 rules) → 0 findings, completed successfully; no secrets; yaml valid (13→15 rules).
- **Merge NOTE for MAIN:** PaybisCryptoAdapter (sibling branch wave-a-adapter) docstrings literally mention 'NeuroNext retired' (governance) → will trip banxe-no-neuronext-reintroduction when both land; add '# nosemgrep: banxe-no-neuronext-reintroduction' on those comment lines or reword at merge.
- **PLAN update:** §1A E9 READY → DONE (with verification note).
- **Perimeter / canon:** CI/lint asset only; no app/runtime logic; no secrets; gitleaks-clean; single guard mechanism; isolated worktrees; signed; sub-B hands to MAIN per §71/§74 (MAIN pushes/PRs emi guard branch + this arch update).
- **Refs:** ADR-126; PLAN §1A/§5A (IL-553/554); Wave-A (IL-552); .semgrep/banxe-rules.yml; quality-gate.yml/lint-python.yml/pre-commit/Makefile; ADR-102/119/I-28; I-SEC.
