# H-SUPPORT — Support Ticketing + Escalation + SLA + Complaints (DISP) Build-Spec

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** H-support · **Priority:** P2 · **Sprint:** 12 · **Promotes:** the 0% (new support-ticketing definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the support contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **PRIVACY/CONDUCT FENCE (read §8 first).** H-support is a **specification of a support-ticketing process
> only** — the factory collects/stores/processes **no** real customer support PII; it defines the contract. Support
> data is **PII under privacy-by-design** (minimisation, retention, PII Proxy/Presidio). **Complaints handling = FCA
> DISP regulatory process** (8-week final-response SLA, **FOS escalation rights**) + **Consumer Duty PS22/9** — a
> legitimate customer-protection process. **No marketing / secondary use of support data.**

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/H-CRM-BUILD-SPEC.md` (IL-521) | CRM golden record + **case history** (aggregates support cases by reference) + DSAR | **keep / REUSE boundary** — **H-support OWNS the ticket lifecycle**; it **emits case references** that H-crm's `CaseHistory` aggregates. H-crm customer-record logic **not** duplicated (ADR-102) |
| ORG support stack (**Chatwoot** + Ollama + **n8n**) | helpdesk / conversational / workflow tooling | **keep / DELEGATE via port** — H-support delegates the helpdesk surface to the support stack via a `SupportProviderPort`; the stack is **not** reimplemented |
| `ROADMAP-MATRIX.md` I-security | PII Proxy (Presidio) + IAM | **keep / REUSE** — H-support **integrates** PII Proxy for support PII; **does NOT reimplement** PII infra |
| `docs/architecture/G-RT` / `F-aml` (fraud/AML) | fraud + financial-crime handling | **keep / reference** — a fraud/AML-flagged contact is **handed off** to G-rt/F-aml; H-support does not adjudicate fraud/AML |

No existing `H-SUPPORT-BUILD-SPEC` / support artifact on main (live audit: `find docs -iname '*h-support*'`/`*support*BUILD*` ⇒ empty; `ls docs/architecture` has A-*/B-*/D-*/E-TREASURY/G-*/H-CRM/I-API). New file is **non-duplicative**; it owns the ticket lifecycle around the delegated support stack + feeds H-crm, it does not re-implement CRM/PII infra.

## 1. Scope — support ticketing, escalation, SLA, complaints

H-support defines four layers; all targets are **config-as-data** (CLAUDE.md §10 — SLA targets not hardcoded):

1. **Ticket lifecycle** — create / route / assign / respond / resolve / close; channels (email/chat/in-app) via the support stack; categorisation + priority.
2. **Escalation workflows** — priority-based + **SLA-breach-triggered** escalation (tier-1 → tier-2 → specialist/manager); vulnerable-customer + fraud/AML routing.
3. **SLA tracking** — config-as-data targets (**first-response**, **resolution**) with timers, pause/resume (waiting-on-customer), and breach flags; reporting for Consumer Duty outcome monitoring.
4. **Complaints handling (FCA DISP)** — identify a contact as a **complaint** (DISP definition), run the regulated workflow: acknowledge, **final response within 8 weeks**, inform of **FOS (Financial Ombudsman Service) escalation rights**, root-cause + outcome record; HITL on complaint resolution / FOS path.

**Out** of H-support: the CRM customer record (H-crm), PII-redaction/IAM infrastructure (I-security), fraud/AML adjudication (G-rt/F-aml), account/payment operations (D/C blocks).

## 2. Data model (Ticket / Escalation / SLATimer / Complaint)

Declarative, config-as-data; PII minimised (§6); customer linkage by reference.

### 2.1 `Ticket`
- `ticket_id`, `customer_ref` (H-crm golden id — by reference, not raw PII), `channel`, `category`, `priority`, `state` (`new | open | pending | resolved | closed`), `assignee`, `provider_ref` (SupportProviderPort handle), `created_at`, `updated_at`, `summary` (PII-redacted).

### 2.2 `Escalation`
- `escalation_id`, `ticket_id`, `trigger` (`sla_breach | priority | vulnerable_customer | fraud_aml | manual`), `from_tier`/`to_tier`, `reason`, `raised_at`, `handoff_ref` (G-rt/F-aml if applicable).

### 2.3 `SLATimer`
- `timer_id`, `ticket_id`, `sla_type` (`first_response | resolution`), `target` (config-as-data), `started_at`, `paused_intervals[]` (waiting-on-customer), `due_at`, `breached` (bool).

### 2.4 `Complaint` (FCA DISP)
- `complaint_id`, `ticket_id`, `customer_ref`, `received_at`, `disp_category`, `ack_sent_at`, `final_response_due_at` (received + 8 weeks, config), `final_response_at`, `outcome`, `fos_rights_notified` (bool), `redress` (if any), `root_cause_ref`, `reviewed_by` (HITL), `consumer_duty_outcome` (fair-value/harm flag).

## 3. Support flow (delegated stack; escalation; SLA; complaints)

```
contact (email/chat/in-app) → SupportProviderPort (Chatwoot/n8n)
  1. create Ticket (categorise, prioritise, route/assign)   [state: new → open]
  2. start SLATimer(first_response, resolution)             [targets config-as-data]
  3. handle: respond / pending(waiting-customer → pause SLA) / resolve
  4. escalate on SLA breach / priority / vulnerable / fraud-AML
       fraud/AML contact → hand off to G-rt/F-aml (H-support does not adjudicate)
  5. if contact = COMPLAINT (DISP): run regulated workflow
       acknowledge → final response ≤ 8 weeks → notify FOS rights → outcome + root cause  [HITL]
  6. on resolve/close → emit case reference → H-crm CaseHistory
  7. audit every transition (ADR-027); PII via Proxy; Consumer Duty outcome monitoring
```

- H-support **owns** the ticket lifecycle; it **emits case references** to H-crm (H-crm aggregates, does not own tickets).
- Complaints follow the **regulated DISP path** (8-week SLA, FOS rights) — never silently closed; HITL on resolution.
- SLA targets, escalation thresholds, DISP timers = **config-as-data** (CLAUDE.md §10).

## 4. Support-stack delegation (SupportProviderPort — not reimplemented)

- The helpdesk surface (conversations, assignment, channels) is delegated to the **support stack** (Chatwoot primary; n8n for workflow automation; Ollama for assist) via a **`SupportProviderPort`** — H-support **orchestrates** ticket/SLA/complaint domain logic; the helpdesk tooling is **not** reimplemented.
- Any AI-assist (draft replies via Ollama) is **suggestion-only / HITL** — no autonomous customer-facing send on regulated/complaint matters.

## 5. Producer/consumer contracts (referenced, not duplicated)

- **Emits case references → H-crm** (`H-CRM-BUILD-SPEC` IL-521): resolved/notable tickets + complaints referenced into H-crm `CaseHistory`. H-support owns the ticket; H-crm aggregates the customer-centric history.
- **Delegates to support stack** (`SupportProviderPort`): Chatwoot/n8n/Ollama. Tooling not reimplemented.
- **Hands off to G-rt/F-aml**: fraud/AML-flagged contacts. H-support routes; those blocks adjudicate.
- **Integrates I-security**: PII Proxy for support PII. Not reimplemented.

## 6. Privacy-by-design (support PII)

- **Lawful basis:** contract (service) + legal obligation (DISP complaints) — recorded per purpose.
- **Data minimisation:** tickets link to customer by **reference** (H-crm golden id); only support-relevant data; **no marketing / no secondary use** of support data.
- **PII Proxy (Presidio):** all support PII (messages, contact details) routed via the proxy; no PII in logs/audit beyond redacted fields.
- **Retention:** per category (config-as-data); complaints retained per DISP/FCA evidence requirement; PII purged at retention end (subject to legal hold).
- **Audit:** every ticket/escalation/complaint transition logged (ADR-027, 5Y per I-24/I-28).

## 7. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_ticket_lifecycle` (new→open→pending→resolved→closed; route/assign; via `SupportProviderPort`).
- [ ] `test_sla_timer_pause_resume_breach` (first-response/resolution targets config-as-data; pause on waiting-customer; breach flag).
- [ ] `test_escalation_on_sla_breach_and_priority` (breach/priority/vulnerable triggers escalation tier).
- [ ] `test_fraud_aml_handoff` (flagged contact → G-rt/F-aml; H-support does not adjudicate; boundary test).
- [ ] `test_complaint_disp_8week_and_fos_rights` (DISP workflow; final response ≤ 8 weeks; FOS rights notified; HITL).
- [ ] `test_emits_case_reference_to_h_crm` (case reference emitted; H-support does not store the customer record; boundary test).
- [ ] `test_support_stack_delegated_via_port` (helpdesk via `SupportProviderPort`; not reimplemented; AI-assist HITL-only).
- [ ] `test_privacy_support_pii_via_proxy_no_secondary_use` (PII via Proxy; minimisation; no marketing/secondary use; audited).
- [ ] `test_consumer_duty_outcome_flag` (poor-outcome/harm flagged for monitoring).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; H-crm/I-security/G-rt/F-aml boundaries respected; audit rows per ADR-027.

## 8. PRIVACY/CONDUCT FENCE (support + DISP only — fail-closed)

- H-support (and this build-spec) defines a **support-ticketing + complaints process only**. The factory collects/stores/processes **no** real customer support PII; it defines the contract.
- **Complaints = FCA DISP** regulated process (8-week final-response SLA, **FOS escalation rights**) + **Consumer Duty PS22/9** outcome monitoring — legitimate customer protection.
- Privacy-by-design (§6): lawful basis per purpose, data minimisation, retention limits, PII Proxy (Presidio), audit; **no marketing / no secondary use of support data**.
- **Fail-closed:** if any requirement would enable marketing/secondary use of support data, autonomous customer-facing replies on regulated/complaint matters, or silently closing a complaint without the DISP path → **STOP + operator brief**; do not implement.

## 9. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no CRM customer-record reimplementation** (H-crm owns the golden record; H-support emits case references); **no PII-infrastructure / IAM reimplementation** (I-security owns PII Proxy/Keycloak); **no support-stack reimplementation** (Chatwoot/n8n/Ollama delegated via `SupportProviderPort`); **no fraud/AML adjudication** (G-rt/F-aml); **no account/payment operations** (D/C blocks); **no marketing / secondary use of support data**; no autonomous customer-facing send on regulated/complaint matters (HITL); no silent complaint closure (DISP path mandatory).

## 10. Operator gates NOT crossed

- **Cross-repo runtime** — implementing H-support in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Live support operation / complaint final-response sign-off / FOS referral** = operator + HITL (conduct oversight) — not done here.
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/architecture/H-CRM-BUILD-SPEC.md` (IL-521 — case-history consumer of H-support case references);
ORG support stack: Chatwoot + n8n + Ollama (delegated via `SupportProviderPort`);
`ROADMAP-MATRIX.md` (H-crm sibling, I-security, G-rt rows);
FCA DISP (complaints handling, 8-week SLA, FOS escalation); Consumer Duty PS22/9 (outcome monitoring);
ADR-027 (audit), ADR-102/103/115/116/117/119; I-24/I-28; CLAUDE.md §9/§10/§11; I-security (PII Proxy / Presidio).
