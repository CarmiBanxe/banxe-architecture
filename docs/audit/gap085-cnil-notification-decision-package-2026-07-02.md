# GAP-085 CNIL Art.33 Notification Decision Package (ss1 Repo Public Exposure)

**Status:** DECISION-PREP (awaits Legal + DPO + MLRO sign-off)
**Date:** 2026-07-02
**Jurisdiction:** CNIL (French supervisory authority)
**Layer:** 2 (Project / Audit)
**Executor:** Central via Claude Code (read-only inputs; no operator action) per IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12.

## Anchors

- GAP-085 (docs/GAP-REGISTER.md line 154 — ss1 repo public exposure incident)
- GDPR Art.4(12) — definition of "personal data breach"
- GDPR Art.33 — notification of a personal data breach to the supervisory authority
- GDPR Art.34 — communication of a personal data breach to the data subject
- GDPR Art.5(1)(f) — integrity and confidentiality principle
- ADR-140 (breach notification governance)
- RD-07 (regulatory determination framework)
- docs/audit/s15-4-fca-gdpr-notification-decision-package-2026-05-13.md (pattern reference)
- Sprint S15.5 (historical leaks audit — parallel track)
- IL-OPS-GAP-REGISTER-UPDATED-2026-06-27 (GAP-085 awareness date)

## A. Incident scope

The ss1 repository (hereafter "the ss1 repo") was publicly accessible on GitHub until 2026-05-13.

**Incident timeline:**
- **Public window start:** Unknown (possibly at repository creation; TBC by Legal audit)
- **Public window end:** 2026-05-13 (repository made private)
- **Awareness date (Art.33(1) "becoming aware"):** 2026-06-27 (GAP-085 registered in INSTRUCTION-LEDGER.md)
- **Discovery window:** 44 days between repository becoming private and formal awareness

**Possible indexing vectors:**
- Google Cache (cache.google.com) — indexed during public period
- archive.org Wayback Machine — potential snapshots during public period
- GitHub public search — live search results during public period
- Direct GitHub URL access by unauthorized parties (timing unknown)

**Content of ss1 repo:**
- Repository scope, file listing, commit history content: **UNKNOWN — requires Legal audit**
- Presence of personal data (names, dates, case references, identifiers): **UNKNOWN — requires Legal audit**
- Customer data / case file excerpts: **UNKNOWN — requires Legal audit**

This decision package is PREP-stage: content assessment is explicitly deferred to Legal audit of ss1 commit history and file contents.

## B. GDPR Art.33(1) 72h timeline check

| Field | Value |
|---|---|
| Incident becoming-aware date (Art.33(1) trigger) | 2026-06-27 (GAP-085 awareness) |
| GDPR Art.33(1) 72h window expiry | 2026-06-30 ~00:00 UTC |
| Decision date (this package) | 2026-07-02 |
| Late by | ~5 days (~120 hours past Art.33(1) clock) |
| Art.33(1) compliance status | LATE — reasoned-justification framework required |

**Art.33(4) reasoned-justification framework.** Per Art.33(1), late notification "shall be accompanied by reasons for the delay". Candidate justifications (DPO + MLRO + Legal select):

- (J1) **Content-scope characterisation requires Legal audit** — the ss1 repository content (file listing, commit history, presence of personal data) was unknown at awareness date (2026-06-27). Immediate action was to escalate to Legal and register GAP-085 for structured assessment. Content audit is the prerequisite for Art.33(3) "categories of data" and "approximate number of data subjects" fields; this audit was not complete at the 72h window expiry.
- (J2) **Exposure scope unknown pending archive.org / Google Cache confirmation** — whether the ss1 repo was indexed by Google Cache or archive.org, and the indexing date range, is unknown at awareness date. Confirmation of indexing scope directly informs the Art.33(3) "likely consequences" field and breach-risk assessment. Immediate action was to initiate removal requests (step: contact Google/archive.org); results were not available within 72h.
- (J3) **MLRO / DPO appointment pending** — governance scaffolding for notification routing and signatory authority is incomplete (S20.8, TBD). This decision package supplies the missing framework. Procedurally weaker than (J1)/(J2) but relevant to operational capacity.

Art.33(4) reasoned-justification is **independent** of the data-subject risk assessment (Section C).

## C. GDPR Art.33(1) "risk to rights and freedoms" assessment

The threshold for Art.33 notification is met if the breach is "likely to result in a risk to the rights and freedoms of natural persons" (Art.33(1)).

| Risk dimension | Observed state | Risk contribution |
|---|---|---|
| **Content scope** | UNKNOWN (pending Legal audit) | TBC |
| **Personal data presence** | UNKNOWN (pending Legal audit) | TBC |
| **Data subjects affected** | UNKNOWN (pending Legal audit — case files?) | TBC |
| **Indexing scope** | UNKNOWN (pending Google/archive.org confirmation) | TBC |
| **Exposure duration** | 44 days minimum (2026-05-13 → 2026-06-27); actual start unknown | MEDIUM to HIGH (public search, cache retention) |
| **Sensitive data risk** | Case files typically contain: names, dates, decision references, identifiers (TBC by Legal) | MEDIUM to HIGH if personal data present |
| **Regulatory / FCA touch** | Possible: if case files contain customer case information (TBC by Legal) | MEDIUM if customer data present |

**Significance matrix verdict (PREP-stage, Legal confirms):** the incident sits in the **TBC band** pending Legal audit of ss1 repository content. The public exposure duration (44+ days) and archival-indexing risk are substantial. If the ss1 repository contains case files with personal data identifiers, the Art.33(1) "risk to rights and freedoms" threshold is likely **MET**, requiring Art.33 notification.

## D. Decision matrix

Four candidate paths. Trigger / action / owner / deadline per row. Legal + DPO + MLRO select the recommended path at sign-off; this section is decision-prep only.

| # | Path | Trigger | Action | Owner | Deadline |
|---|---|---|---|---|---|
| 1 | NOTIFY-CNIL-ART-33 | Legal audit confirms personal data present in ss1 repo (Art.4(12) "personal data breach" = MET); Art.33(1) "risk to rights and freedoms" = MET | Submit CNIL notification via notifications.cnil.fr with Art.33(3) fields (nature, categories, subjects count, records count, DPO contact, consequences, measures) + Art.33(4) reasoned-justification; simultaneous DMCA removal requests per Path 2 | DPO (signatory + Art.33(3) certification) + Operator (executor) + Legal (Art.33(4) text) | Immediate upon Legal determination; late + justified per Art.33(4) |
| 2 | DMCA-REMOVAL | Personal data confirmed present in ss1 repo (Legal audit) | Contact Google (google.com/webmasters/tools/legal → "Content removal request") + archive.org (info@archive.org → "Content removal" subject) with repository URL + personal data justification; track removal confirmation | Legal + Operator | Same-business-day from Legal determination; parallel to Path 1 |
| 3 | NOTIFY-DATA-SUBJECTS-ART-34 | DPO assesses Art.34(1) "high risk to rights and freedoms of data subjects" = MET (high-risk scenario: case file identifiers in public archive) | Direct notification to affected data subjects per Art.34(2) content requirements (breach nature, data controller contact, recommended precautions); Legal drafts content; DPO/MLRO approve channel + content | DPO + Legal (content + channel) + Operator (executor) | Without undue delay after DPO determination; can be concurrent with Path 1 |
| 4 | INTERNAL-LOG-ONLY | Legal audit confirms NO personal data in ss1 repo (Art.4(12) = NOT MET, OR Art.33(1) "unlikely to result in a risk" carrier met) | Document Legal determination in IL with detailed rationale (what was audited, why no breach found); GAP-085 CLOSED with `notify=none` evidence; no external submission | Legal + DPO (joint determination) + Central (IL custodian) | Same as Legal determination date |

**Mutual exclusivity:** #1 and #4 mutually exclusive (CNIL-side). #2 is conditional on #1 (parallel). #3 is conditional on #1 (nested; can follow immediately after #1 DPO approval). #1 and #3 can coexist.

## E. Recommended path

**TBC by Legal + DPO + MLRO consultation.** Based on this package's PREP-stage analysis:

- If ss1 repo contains **case file content** (names, dates, customer references): **Path 1 + 2 + 3** (NOTIFY-CNIL-ART-33 + DMCA-REMOVAL + NOTIFY-DATA-SUBJECTS-ART-34)
- If ss1 repo contains **NO personal data** (code only, no identifiers): **Path 4** (INTERNAL-LOG-ONLY)
- If ss1 repo scope is **ambiguous** (partial audit): **Path 1** (NOTIFY-CNIL-ART-33 with precautionary disclosure + continued audit)

Final recommendation is a **Legal + DPO + MLRO joint determination**. Central supplies the framework and templates only; Central does NOT make the content assessment.

## F. CNIL Art.33(3) notification fields (template, for DPO/Legal completion)

CNIL portal: https://notifications.cnil.fr

**Required fields per Art.33(3):**

```
(a) Nature of personal data breach:
    ☐ Unauthorized disclosure / Accidental public access
    ☐ Loss of availability
    ☐ Integrity compromise
    Selected: Unauthorized disclosure to public via GitHub repository (2026-05-13 repository made private; public window start unknown)

(b) Categories of personal data affected:
    TBC by Legal audit of ss1 repository. Candidate categories if present:
    ☐ Names / identifiers
    ☐ Dates of birth / contact information
    ☐ Case decision references / sensitive personal data (Art.9 special categories)
    ☐ Other: [specify]

(c) Approximate number of data subjects:
    TBC by Legal audit of ss1 repository.

(d) Likely consequences:
    - Increased re-identification risk due to archive.org / Google Cache indexing
    - Potential unauthorized access by third parties to publicly available repository
    - Reputational / competitive harm if case information disclosed

(e) Data controller contact:
    [Operator contact; TBC by DPO]

(f) Data Protection Officer contact:
    [DPO contact; TBC by DPO appointment]

(g) Measures taken or proposed:
    - Repository made private: 2026-05-13
    - DMCA removal requests to Google Cache / archive.org: [in progress / pending]
    - Content audit: [in progress]
    - Notification: this submission

(h) Delay justification (Art.33(4)):
    J1: Content-scope characterisation required Legal audit of ss1 commit history.
    J2: Archival indexing scope (Google Cache, archive.org) unknown at Art.33(1) 72h trigger.
    J3: Governance scaffolding (DPO appointment S20.8) not in place at breach awareness.
```

## G. Google / archive.org removal request templates

**Google Cache removal:**
- URL: https://google.com/webmasters/tools/legal
- Process: sign in with Google account with repo access → "Content removal request" → select "Cached content" → enter ss1 repo URL → submit
- Confirmation: email from Google within 1-2 business days
- TTL: cached content removed from Google search within 6 months (expedited for sensitive data)

**archive.org Wayback Machine removal:**
- Email: info@archive.org
- Subject: "Content removal request — personal data (GDPR Art.33)"
- Body:
  ```
  Repository URL: [ss1 repo GitHub URL]
  Reason: GDPR Art.4(12) personal data breach — repository was publicly accessible
  Request: Remove all snapshots from Wayback Machine
  Justification: Sensitive data (case files / identifiers) exposed during public window
  Urgency: GDPR Art.33 breach notification (urgent)
  ```
- Confirmation: response typically within 1-3 business days
- TTL: removal effective upon email confirmation (archive.org policy)

## H. Open dependencies

- **Legal audit of ss1 repository** (P0 blocker for all paths) — content scope, presence of personal data, categories of affected data subjects must be determined before Art.33(3) fields can be populated. Blocking.
- **Google Cache / archive.org indexing confirmation** (P1 for Path 2) — whether the ss1 repo was indexed and when. Informs Art.33(1) "risk to rights and freedoms" assessment.
- **DPO appointment (S20.8, TBD)** — Art.33(1) "risk" threshold assessment and Art.34(1) "high risk" determination require a qualified DPO. Legal counsel may serve as interim DPO advisor but cannot substitute for a designated DPO on the customer-notification path.
- **MLRO awareness** — if GAP-085 overlaps with any FCA SUP 15 reportability threshold (unlikely; separate from S15.4 incident), MLRO must be consulted. Cross-ref S15.4 for pattern.
- **Concurrent safeguarding audit (S15.5)** — ss1 repository scope may intersect with S15.5 historical-leaks audit if commit history contains developer-plane secrets or safeguarding-account artifacts. Co-ordinate with S15.5 if overlap is detected during Legal audit.

## I. HITL gate

**HITL-L4 (Human Only):** All notification paths require explicit approval:

- **Content determination:** Legal + DPO joint audit of ss1 repository. Central proposes framework only.
- **Notification decision:** Legal + DPO + MLRO joint sign-off on recommended path (Section E).
- **CNIL submission:** DPO is the signatory for CNIL Art.33(3) notification. Operator executes submission only upon DPO approval.
- **No autonomous CNIL submission:** Central does NOT call the CNIL API or submit notifications. All Art.33 submissions are manual, signed, and auditable.

## J. TODOs

- Verify CNIL notifications.cnil.fr current portal structure (2026-07-02 field schema) at submission time; anchor pending DPO.
- **[CRITICAL] Legal audit of ss1 repository:** enumerate files, commit history, personal data categories, data subject count. Output: structured audit report with PII-presence determination (yes/no/ambiguous).
- Confirm whether ss1 repository was indexed by Google Cache / archive.org (request removal if confirmed).
- MLRO + DPO + Legal **joint sign-off** on recommended path (Section E). Logged as IL-OPS-GAP-085-CNIL-NOTIFICATION-DECISION-<YYYY-MM-DD> post-determination.
- GAP-085 moves CLOSED only at decision sign-off with `notify=<path>` evidence (or `notify=none` with documented legal rationale).
- Post-notification (if Path 1 executed): log removal confirmation from Google/archive.org in IL for regulatory record.
