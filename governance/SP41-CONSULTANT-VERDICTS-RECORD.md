# SP41 §5 — Independent-Consultant Verdicts Record (ADVISORY / PROPOSED)

- **Status:** PROPOSED · **Kind:** governance record (ADVISORY only — activates nothing)
- **Date:** 2026-07-11 · **Attach point / SoT:** `governance/ADOPTION-FINALIZATION-SP41.md` §5
- **Pointer-first (ADR-102):** this record does NOT restate the 965-line verdicts file — it records
  *that* verdicts were received and the hard-conditions/red-lines that gate any future action.

> **Nothing here activates an adopt/reject.** Every final call — converting a DEFER→ADOPT, or
> clearing a legal red-line — is an **operator/SMF decision**, tracked separately. This record only
> registers receipt of the independent-consultant verdicts and the conditions attached to them.

## What was received
An independent consultant returned verdicts for **all 48** SP41 §5 items (**43 DEFER-band + 5
PAYBIS-track**). The full verdicts, the questions, and the design note are on `main`:

- **Verdicts (full, 965 lines):** `docs/handoff/CONSULTANT-VERDICTS-SP41-2026-07-09.md`
  (65 `VERDICT:` lines incl. **5× `ADOPT-AS-PAYBIS-DISTRIBUTION = YES`**).
- **Questions (48):** `docs/handoff/CONSULTANT-49Q-PACKAGE.md`.
- **Design input:** `docs/handoff/DESIGN-56-assistant-ui-with-mastra.md`.
- **Source questions:** `governance/ADOPTION-FINALIZATION-SP41.md` §5.

**Verdict mix** (per the handoff file — not re-listed here; read the file for the per-item detail):
ADOPT / DEFER / REJECT across the 43 DEFER-band items, plus **5 ADOPT-AS-PAYBIS-DISTRIBUTION = YES**
on the PAYBIS-track items. All 48 answered.

## HARD CONDITIONS carried forward (these GATE any future work)
Verbatim in the verdicts file; reproduced here as the conditions that must be satisfied *before* the
named item can proceed:

1. **#52 FATE — DEFER.** WeBank FATE is stale (~597d). A **parallel Flower / OpenFL evaluation is
   MANDATORY** before any adoption recommendation is possible.
2. **#61 FinNLP — ADOPT (conditioned).** Stale (~738d). Requires **fork-validation + an
   accuracy benchmark** against a labelled dataset **before production** use.
3. **#100 Skyvern — ADOPT (conditioned).** Licence is **AGPL-3.0**, not MIT. Requires a **legal
   AGPL-3.0 licence-compatibility review** before any embedding in a BANXE service.
4. **#116 onionsearch / #118 reputell (§5.G) — DEFER / LEGAL-RED-LINE.** Dark-web Tor OSINT.
   **MUST NOT proceed to even a sandbox** without **qualified UK legal counsel** (Computer Misuse
   Act 1990 unauthorised-access analysis) **and a UK-GDPR DPIA** — the consultant's five-gate
   condition applies.

## Known issue (not fixed here)
SP41 §5 **advertises 49** items (44 DEFER + 5 PAYBIS) but **contains 48** — item **#67** is absent
from §5's clusters. Content of that discrepancy survives in the `CONSULTANT-49Q-PACKAGE.md` footer
(`EXTRACTED: 43 DEFER + 5 PAYBIS = 48 (expected 44+5=49)`). This record does **not** fix it;
re-adding #67 to §5 is a separate operator/SMF decision.

## Operator-decision-required
- Converting any **DEFER → ADOPT**, or **clearing a legal red-line** (esp. §5.G #116/#118), is an
  **operator/SMF action**, recorded separately (per the consultant-escalation protocol).
- This record confers no authority and activates no decision (advisory only).

## Cross-references
- `governance/ADOPTION-FINALIZATION-SP41.md` (SP41 SoT, §5 questions).
- `docs/handoff/CONSULTANT-VERDICTS-SP41-2026-07-09.md`, `docs/handoff/CONSULTANT-49Q-PACKAGE.md`,
  `docs/handoff/DESIGN-56-assistant-ui-with-mastra.md` (the verdicts/questions/design — PR #1123).
- `docs/sources/consultant-escalation-protocol-2026-07-07.md` (escalation path).
- ADR-102 (pointer-first / no-restate).
