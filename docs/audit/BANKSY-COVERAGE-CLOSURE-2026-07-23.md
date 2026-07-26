# Banksy Coverage Closure (34 repos) — 2026-07-23

**GOVERNANCE-AUDIT / COVERAGE CLOSURE / DOCS-ONLY / READ-ONLY**
Closes the coverage question before Banksy finalization. The two largest blind spots (banxe=354 agents, merged-repo=100 agents) were shell-audited and found to be **mirrors** (79/79 overlap with emi-stack) — no new bank agents/engine. Repo presence spot-checked read-only. Do not double-count mirrors.

## §1 Coverage register (34 repos)

| repo | audited | py | agents | verdict |
|---|---|---|---|---|
| banxe-emi-stack | y | — | 129 bank + heart-32 | **SOURCE** |
| OpenManus (Legion) | y | — | template/RL | **SOURCE** (external, template) |
| factory | y | — | 9 workers | **SOURCE** (external company) |
| MetaClaw | y | — | canon/analysis | **SOURCE** |
| banxe-architecture | y | — | ADR/canon | **SOURCE** |
| arch-repo (this) | y | — | governance | **SOURCE** |
| banxe | y | — | 354 (79/79 overlap) | **AGGREGATE / MIRROR** — umbrella monorepo (contains emi-stack, MetaClaw, MiroFish, banxe-architecture) `[do not double-count]` |
| merged-repo | y | — | 100 (79/79 overlap) | **MIRROR** — emi-stack + OpenManus merge (submodule verl) `[do not double-count]` |
| llama.cpp (+source) | n | — | — | INFRA (inference) — low priority |
| AMLSim | n | — | — | DATA (AML sim) — low priority |
| AMLGentex | n | — | — | DATA — low priority |
| banxe-ui | n | — | — | FRONT — low priority |
| banxe-infra | n | — | — | INFRA — low priority |
| banxe-monitoring | n | — | — | INFRA — low priority |
| banxe-platform | n | — | — | INFRA — low priority |
| legal-reference-fr | n | — | — | DATA (legal ref) — low priority |
| developer / developer-core | n | — | ~2 | UTIL — low priority `[optional spot-check]` |
| braslina | n | — | — | UTIL — low priority |
| vibe-coding | n | — | ~4 | UTIL — low priority `[optional spot-check]` |
| crypto-ops-monitor | n | — | — | INFRA — low priority |
| banxe-training-data | n | — | — | DATA — low priority |
| obsidian-vault | n | — | — | DATA (notes) — low priority |
| gpt-archive-toolkit | n | — | — | UTIL — low priority |
| claude-code | n | — | — | UTIL — low priority |
| MiroFish / banxe-mirofish | n | — | ~1 | FRONT/UTIL — low priority `[optional spot-check]` |
| banxe-payment-core | n | — | ~6 | SOURCE-adjacent (payments) — low priority `[optional spot-check]` |
| OpenRLHF | n | — | — | UTIL (RL) — low priority, non-banking |
| banxe-business-processes | n | — | — | DATA (process docs) — low priority |
| banxe-lexisnexis-distro | n | — | — | DATA (distro) — low priority |
| wt/temp-clone | n | — | — | UTIL (temp) — low priority |

(`py`/`agents` counts shown only where provided by the audit; `—` = not separately counted. INFRA/DATA/FRONT/UTIL repos are not sources of engine/bank agents.)

## §2 Verdict

- **Banksy bank-agent coverage = COMPLETE.** 129 bank agents from `banxe-emi-stack`; `banxe` and `merged-repo` add only duplicates (79/79 overlap), **no new** bank/engine agents.
- **Remaining blind spots = INFRA / DATA / FRONT / UTIL only** — not sources of missed engine or bank agents.
- **banxe = umbrella** (contains already-audited repos); **merged-repo = emi-stack + OpenManus merge** → both marked **`[MIRROR — do not double-count]`**.
- The Banksy registry (emi-stack: 129 bank + heart-32) is complete on the banking side; the coverage question does not block finalization.

## §3 Residual low-priority spot-checks (optional, `[pending]`)

Small, likely mirrors — **not blocking Banksy finalization**:
- `banxe-payment-core` (~6 agents) — payments; likely emi-stack mirror → `[optional spot-check pending]`.
- `developer-core` (~2) → `[optional spot-check pending]`.
- `vibe-coding` (~4) → `[optional spot-check pending]`.
- `MiroFish` (~1) → `[optional spot-check pending]`.

If any spot-check surfaces a genuinely new bank agent, it routes through the census → BANK-MASTER placement; none expected.

## Notes
- Mirrors (banxe, merged-repo) are **not** double-counted into the 129.
- Any contested count → `[pending human ratification]`; all legal/regulatory → `[counsel]`.
- No repo modified; nothing committed.

---
**This does not replace legal advice.**

## Update — 2026-07-23 (S-B0 spot-check result)

The optional spot-checks (§3) were run:
- **banxe-payment-core → 3 NEW bank agents** (Payments/FX-Exchange/Wallet ADR-049 masks) — added to BANK-MASTER (**129 → 132**); NOT mirrors. See `SB0-NEW-BANK-AGENTS-2026-07-23.md`.
- **developer-core / vibe-coding** policy/workflow/review agents → FACTORY dev-tooling (not bank).
- **vibe-coding** = factory dev/training pipeline (not engine).
- **MiroFish** report_agent = out-of-bank app.

**Revised verdict:** bank coverage now **132** (was 129); the 6-mask ADR-049 §D3 series is complete; no further engine/bank-agent gaps in the checked repos. Remaining un-audited repos stay INFRA/DATA/FRONT/UTIL.
