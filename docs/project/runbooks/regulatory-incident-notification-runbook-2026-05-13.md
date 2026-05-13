# Regulatory Incident Notification Runbook (FCA SUP 15 + GDPR Art.33/34)

Document ID: RB-REG-INCIDENT-NOTIFY-2026-05-13
Status: SKELETON
Sprint: S15.4 (G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION mitigation)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
HITL gate: REQUIRED (MLRO + DPO + Legal + Central sign-off; NO EMERGENCY override)
Anchors: ADR-027; FCA SUP 15.3.11R + 15.3.17R; GDPR Art.33 + Art.34 + Art.4(12); MLR 2017 Reg.28; ICO ReportIT; Sprint S15.4 per IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11.

## A. FCA SUP 15 notification flow

1. MLRO receives incident escalation (Central + operator + Guardian alert per ADR-019/027).
2. MLRO triages per SUP 15.3.11R significance: client funds / safeguarding (MLR 2017 + EMR 2011); regulatory permissions; operational resilience per DORA Art.14.
3. If significant: MLRO completes Form A or current FCA Connect equivalent (TODO confirm form name 2026).
4. Required fields per SUP 15.3.17R: incident datetime UTC; scope; root cause hypothesis; mitigations; status; contact + SMF.
5. Submission: FCA Connect under MLRO authority; operator-side execution; MLRO co-signs.
6. Timing: "as soon as reasonably practicable" — no fixed 72h deadline.

## B. GDPR Art.33 notification flow (ICO)

1. DPO receives incident escalation parallel to MLRO.
2. DPO assesses per Art.4(12): unauthorized access/disclosure; alteration/destruction; availability breach.
3. If breach: ICO ReportIT submission required.
4. Art.33(1) deadline 72h. Current incident 2026-05-08 → expired 2026-05-11 → ~5 days late at 2026-05-13. Art.33(4) reasoned-justification required.
5. Required fields per Art.33(3): nature + categories + records; approximate subjects + records count; DPO contact; consequences; measures.
6. Submission: ICO ReportIT under DPO authority; operator-side; DPO co-signs.

## C. Art.34 customer notification flow

1. DPO assesses Art.34(1) high-risk threshold.
2. If high-risk: direct customer comms required.
3. Required content per Art.34(2): nature in plain language; DPO contact; consequences; measures.
4. Channels TBD: email primary; in-app / Telegram secondary per S20.5; postal fallback.
5. Submission: direct to data subjects under DPO + Operator.
6. Art.34(3) exceptions: technical measures + measures eliminating high risk + disproportionate effort (public communication).

## D. Templates (placeholders only; NO real data)

### D.1 FCA Form A
Incident datetime UTC: {{INCIDENT_DT_UTC}}
Firm: BANXE EMI (FCA: {{FCA_REF}})
SMF17 MLRO: {{SMF17_MLRO_NAME}}
Category: {{CATEGORY}}
Scope: {{SCOPE}}
RCA preliminary: {{RCA}}
Mitigations: {{MITIGATIONS}}
Status: {{OPEN_CONTAINED_CLOSED}}
Contact: {{MLRO_CONTACT}}

text

### D.2 ICO ReportIT JSON
```json
{
  "type": "personal_data_breach",
  "incident_dt_utc": "{{INCIDENT_DT}}",
  "awareness_dt_utc": "{{AWARENESS_DT}}",
  "delay_hours": "{{DELAY_HOURS}}",
  "delay_reasons": "{{ART_33_4_REASONS}}",
  "categories": "{{CATEGORIES}}",
  "subjects_count": "{{COUNT}}",
  "records_count": "{{RECORDS}}",
  "dpo_contact": "{{DPO_CONTACT}}",
  "consequences": "{{CONSEQUENCES}}",
  "measures": "{{MEASURES}}"
}
```

### D.3 Art.34 customer email
Subject: Notification of a personal data incident — action recommended
Dear {{CUSTOMER_NAME}}, we inform you of a personal data incident affecting your account.
Nature: {{NATURE}}. Consequences: {{CONSEQUENCES}}. Measures: {{MEASURES}}.
Contact DPO: {{DPO_EMAIL}}. We apologise for the concern.

text

## E. HITL gate

MLRO + DPO + Legal + Central sign-off required. NO EMERGENCY override (regulatory submission is legally binding). Audit ClickHouse Guardian per ADR-027 (5y CASS 15).

## F. Rollback

If submission erroneous: correction via same channel (FCA Connect / ICO ReportIT / customer comms). Document correction event to IL with operator + MLRO/DPO co-sign.

## G. Audit trail

Submission events emitted to ClickHouse Guardian per ADR-027 (5y CASS 15 retention). Fields: event datetime UTC, submitter SMF/DPO, channel, regulator reference number, IL anchor.

## H. Open dependencies

- MLRO appointment (Sprint S20.8 Sarah Mitchell or UK interim) — required for SUP 15 authority.
- DPO appointment (TBD) — required for Art.33 + Art.34 authority.
- Legal counsel engagement — reasoned-justification framing + customer notification language.
- FCA Form A current name verification 2026 (TODO).
- Current incident decision path TBC by MLRO + DPO per S15.4 decision package (docs/audit/s15-4-fca-gdpr-notification-decision-package-2026-05-13.md).
