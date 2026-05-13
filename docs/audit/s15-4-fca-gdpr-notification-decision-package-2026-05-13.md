# S15.4 FCA SUP 15 + GDPR Art.33 Notification Decision Package (Sprint S15.4)

**Status:** DECISION-PREP (awaits MLRO + DPO + Legal sign-off)
**Sprint:** S15.4
**Date:** 2026-05-13
**Layer:** 2 (Project / Audit)
**Executor:** Central via Claude Code (read-only inputs; no operator action) per
IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12.

## Anchors

- G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION (OPEN; this package = mitigation input)
- FCA SUP 15.3.11R — significant matters notification (EMI / safeguarding)
- FCA SUP 15.3.17R — operational risk / continuity notification
- GDPR Art.33 — notification of a personal data breach to the supervisory authority
- GDPR Art.34 — communication of a personal data breach to the data subject
- GDPR Art.4(12) — definition of "personal data breach"
- MLR 2017 Reg.28 — customer due diligence / record-keeping (contextual)
- ADR-027 — audit trail durability (5y CASS 15) — notification events anchor
- Sprint S15.1 / S15.2 (V8 user classification + Legion key cleanup),
  S15.3 (parent tracker), S15.5 (historical leaks audit — 0 P0 finding at HEAD),
  S20.8 (MLRO appointment — open dependency), S25.4 (HITL audit / quarterly)
- IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12 (line 7938 — S12.1 evidence)
- IL-OPS-S15-5-HISTORICAL-LEAKS-PREP-2026-05-13 (line 8569 — 0 P0 at HEAD)
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11

## A. Incident scope

The 2026-05-08 incident (anchor: IL line 7938 S12.1 evidence; V7-PART1 series) comprises
two operationally distinct but causally related events on the developer-plane host
infrastructure:

1. **evo1 V8 user classification leakage** — during read-only diagnostic on evo1
   (banxe-NucBox-EVO-X2) the Keycloak `--db-password=...` value was observed in
   `systemd ExecStart` (G-IAM-08), exposing the credential to any local user on the
   host via `ps -ef`. Scope of exposure: Keycloak DB role on `127.0.0.1:15433/keycloak`.
2. **Legion key cross-contamination** — developer-plane key material on Legion
   work-station crossed session boundaries during the parallel-session incident
   pattern documented in `.claude/rules/parallel-session-isolation.md`. Scope:
   developer-plane credentials; no customer-data path.

S15.5 audit findings (IL line 8569, 2026-05-13) characterise the historical-leak
component: gitleaks scan against current `main` HEAD returned **0 P0 active-prod
credentials**; the 6 P2 findings are all false positives (Midaz UUIDs, Keycloak
client UUIDs, SHA-256 anchor hashes). The "leak" exfiltration vector is therefore
empirically zero at HEAD as of the decision date; history-walk enumeration is
deferred to Sprint S17.

The incident did NOT touch the project-plane EMI BANXE AI BANK customer database,
the Modulr / ClearBank payment rails, the safeguarding accounts (ADR-013 Midaz
ledger), or any FIN060 / CASS 15 reconciliation evidence chain (ADR-027).

## B. GDPR Art.33 72h timeline check

| Field | Value |
|---|---|
| Incident becoming-aware date (TBC by MLRO) | 2026-05-08 (anchor: IL line 7938) |
| GDPR Art.33(1) 72h window expiry | 2026-05-11 ~00:00 UTC |
| Decision date (this package) | 2026-05-13 |
| Late by | ~5 days (~120 hours past Art.33(1) clock) |
| Art.33(1) compliance status | LATE — reasoned-justification framework required |

**Art.33(4) reasoned-justification framework.** Per Art.33(1), late notification
"shall be accompanied by reasons for the delay". Candidate justifications (DPO +
MLRO + Legal select):

- (J1) **Severity-assessment lag** — PII-impact characterisation required
  S15.1/S15.2 diagnostic + the S15.5 0-P0 audit (completed 2026-05-13) to
  confirm whether any data-subject record was reachable.
- (J2) **No data-subject reachability** — Keycloak DB role on evo1 governs
  developer-plane realm only; banxe-emi production realm is HOLD per S12.4
  (`/realms/banxe-emi/.well-known/openid-configuration` 404 on evo1 as of
  2026-05-12). Argument for Art.33(1) "unlikely to result in a risk to the
  rights and freedoms of natural persons" — DPO must confirm.
- (J3) **MLRO / DPO appointment pending** (S20.8) — governance scaffolding
  for notification routing was not in place at incident date; this package
  supplies the missing framework. Procedurally weaker than (J2).

Art.33(4) reasoned-justification is **independent** of the FCA SUP 15
significance assessment (Section C).

## C. FCA SUP 15.3.11R significance assessment

FCA SUP 15.3.11R requires notification to the FCA of any "significant" matter
affecting a firm's ability to meet its threshold conditions, its safeguarding
obligation, or the integrity of its regulatory permissions. SUP 15.3.17R adds
operational-risk and continuity events.

| Criterion | Observed state | Significance contribution |
|---|---|---|
| Scope — number of customer records reachable | 0 (developer-plane only; banxe-emi realm HOLD per S12.4) | LOW |
| Volume — value of client funds at risk | £0 — no safeguarding-account access path through exposed credential | LOW |
| Risk — duration of exposure window | TBC by MLRO; password observable from incident date to G-IAM-08 fix landing (S12.5) | MEDIUM (open exposure to local-host user) |
| Regulatory exposure — CASS 15 / SYSC 4.1 / SYSC 15A | SYSC 4.1 (governance) implicated — credential in `ps -ef`; CASS 15 NOT implicated (no safeguarding-chain touch) | MEDIUM |
| Operational resilience — service availability | Keycloak service on evo1 remained available throughout; no outage | LOW |
| Reportable per SUP 15 thresholds | TBC by MLRO consultation — borderline based on SYSC 4.1 governance touch | TBC |

**Significance matrix verdict (PREP-stage, MLRO confirms):** the incident sits in
the **borderline / TBC band** under SUP 15.3.11R. The credential exposure satisfies
SYSC 4.1 governance-failure criteria (operational hygiene), but the zero
customer-data reachability and zero safeguarding-chain touch reduce the SUP 15
significance argument. Final NOTIFY / DO-NOT-NOTIFY determination is an MLRO
judgement call informed by FCA's published expectations and firm precedent. See
TODO below on exact subsection wording.

## D. S15.5 update impact

The S15.5 audit (IL line 8569; companion doc `docs/audit/s15-5-historical-leaks-audit-2026-05-13.md`)
materially affects the decision matrix:

- **Exfiltration vector downgraded.** With 0 P0 active-prod credentials at HEAD
  and all 6 P2 findings classified false-positive (account UUIDs / anchor hashes),
  the historical-leak surface does not currently carry data-subject risk.
- **FCA SUP 15 operational-resilience obligation persists.** SYSC 15A operational-
  resilience requirements are NOT cancelled by the absence of a leak. The credential-
  in-`ps -ef` finding (G-IAM-08) is itself an operational-hygiene defect that may
  warrant SUP 15 notification independently of any data-leak conclusion.
- **GDPR Art.33 weight reduces.** The Art.33(1) "risk to rights and freedoms"
  threshold is harder to clear when 0 P0 active-prod credentials are present at
  HEAD, supporting candidate justification (J2) in Section B.
- **History-walk caveat.** S15.5 used `--no-git` scope. If Sprint S17's history-walk
  scan reveals a historical P0, this decision package must be re-assessed (per
  EDGE CASES below).

## E. Decision matrix

Four candidate paths. Trigger / action / owner / deadline per row. MLRO + DPO + Legal
select the recommended path at sign-off; this section is decision-prep only.

| # | Path | Trigger | Action | Owner | Deadline |
|---|---|---|---|---|---|
| 1 | NOTIFY-FCA-SUP-15 | SUP 15.3.11R significance assessment (Sec. C) = YES by MLRO | Submit FCA Form A (or current equivalent) via FCA Connect; populate per runbook D2 §A | Operator (executor) + MLRO (signatory) | Same-business-day from MLRO determination |
| 2 | NOTIFY-ICO-ART-33 | DPO assesses Art.4(12) "personal data breach" threshold = MET; Art.33(1) "unlikely to risk rights and freedoms" = NOT clear | Submit ICO ReportIT with Art.33(3) fields + Art.33(4) reasoned-justification per runbook D2 §B | Operator + DPO (signatory) | Immediate upon DPO determination; late + justified per Art.33(4) |
| 3 | NOTIFY-CUSTOMER-ART-34 | DPO assesses Art.34(1) "high risk to rights and freedoms" = MET | Direct customer comms per Art.34(2) content requirements per runbook D2 §C | DPO + Legal (channel + content sign-off) | Without undue delay after DPO determination |
| 4 | INTERNAL-LOG-ONLY | SUP 15 = NO AND Art.4(12) = NO (or Art.33(1) "unlikely" carrier met by J2) | Document determination in IL with rationale; no external submission; G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION CLOSED with `notify=none` evidence | MLRO + DPO (joint determination) + Central (IL custodian) | Same as decision sign-off date |

**Mutual exclusivity:** #1 and #4 mutually exclusive (FCA-side). #2 and #4
mutually exclusive (ICO-side). #3 is conditional on #2. #1 and #2 can coexist.

## F. Recommended path

**TBC by MLRO + DPO consultation.** Based on this package's PREP-stage analysis:

- Section C significance is **borderline TBC** — leans toward path #1 (NOTIFY-FCA-SUP-15)
  on SYSC 4.1 governance grounds, but rebuttable.
- Section D update supports path #4 (INTERNAL-LOG-ONLY) on the ICO-side if DPO
  accepts candidate justification (J2) "no data-subject reachability" under
  Art.33(1) "unlikely to result in a risk".

Final recommendation is an MLRO + DPO judgement call. Central does NOT make this
determination — Central supplies the framework and templates only (D1 + D2).

## G. Open dependencies

- **MLRO appointment (Sprint S20.8)** — borderline SUP 15.3.11R determination
  awaits a qualified MLRO signatory. Operator-interim per HITL canon is possible
  for the time-critical FCA SUP 15 path but cannot substitute for a qualified
  MLRO on the final notification decision.
- **DPO appointment (TBD)** — Art.33 / Art.34 determination awaits a qualified
  DPO. Legal counsel may serve as interim DPO advisor under Art.37(6) (single
  data-protection officer for a group) but cannot substitute for a designated
  DPO on the customer-notification path (#3).
- **Legal counsel** — FCA Form A current name + ICO ReportIT JSON schema validation
  + Art.34 customer-comms channel selection are Legal-counsel determinations.
- **Sprint S17 history-walk** — if Sprint S17 gitleaks history walk uncovers a
  historical P0 active-prod credential, this decision package MUST be re-opened
  per EDGE CASES (#5 below).

## EDGE CASES

1. If incident date 2026-05-08 is uncertain at sign-off, mark TBC by MLRO with
   anchor to IL line 7938 (S12.1 evidence). Art.33(1) "becoming aware" clock
   is the MLRO determination, not the calendar date of the diagnostic.
2. If FCA Form A is no longer the current notification artefact (FCA Connect
   2026 may use a different form / process), runbook D2 §A captures TODO with
   anchor; final form is Legal-counsel determination at submission time.
3. If MLRO is not yet appointed (S20.8 pending), path #1 awaits MLRO with
   operator-interim per HITL canon. Operator interim cannot substitute for
   MLRO on the final notification decision; same-business-day SUP 15 timing
   may slip and require reasoned-justification.
4. If DPO is not appointed, paths #2 / #3 await DPO with Legal-counsel
   interim. Legal interim covers Art.33(4) reasoned-justification drafting
   but not the Art.34(1) "high risk" determination.
5. If S15.5 0-P0 finding is contested by Sprint S17 history-walk scan, this
   decision package supports re-assessment without rewrite — Section D
   update impact would reverse, Section C SYSC 15A component would
   strengthen, decision matrix re-runs.

## TODOs

- Verify FCA SUP 15.3.11R / 15.3.17R **exact current subsection numbering** at
  FCA Handbook 2026 publication date; anchor here pending Legal counsel.
- Verify FCA Form A current name / form ID for SUP 15 EMI notifications at
  FCA Connect 2026; anchor here pending Legal counsel + MLRO.
- Verify ICO ReportIT JSON field schema (per Art.33(3) (a)-(d)) against
  current ICO portal at submission time; anchor in runbook D2 §B pending DPO.
- MLRO + DPO + Legal **joint sign-off** on recommended path (Section F).
  Logged as IL-OPS-S15-4-FCA-GDPR-NOTIFICATION-DECISION-<YYYY-MM-DD> post-determination.
- G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION moves DONE only at decision sign-off
  with `notify=<path>` evidence (or `notify=none` with documented rationale).
