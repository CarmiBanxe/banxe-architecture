# NEW-PROJECT PRIORITY MAP — NEW EMI BANXE AI BANK drives legacy reuse (not the reverse)

Date: 2026-06-06
Status: GOVERNING DOCUMENT (sits above the 11 refactor SPECs; defines the priority inversion principle)
Scope: authoritative NEW capability list (from ADR + roadmap + EMI licence), each mapped to legacy-serves / build-fresh / drop-legacy
Source: ADR-016..021, ROADMAP_8Q, RISK_REGISTER, EMI/ACPR licence requirements — NOT derived from legacy inventory
Related: all 11 refactor SPECs in docs/refactor/legacy/; BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md
Owner: Terminal B (smart refactor)

## Priority principle (correction of earlier method)

Earlier SPECs were legacy-driven: start from a legacy project, decide KEEP/TRANSFORM/DROP, then map to NEW. This document inverts the priority correctly: the NEW EMI BANXE AI BANK target capabilities are authoritative; legacy is reused ONLY where it serves a NEW capability. Legacy presence is never a reason to keep code; NEW need is the only reason. Absence of legacy for a NEW need means build-fresh, not skip.

Decision verbs:
- legacy-serves: a NEW capability is satisfied by transforming specific legacy code (the 11 SPECs detail how).
- build-fresh: a NEW capability has no usable legacy source; build from scratch.
- drop-legacy: legacy code exists but no NEW capability needs it; drop regardless of code quality.

## NEW EMI capabilities (authoritative — from ADR + roadmap + EMI licence)

These are the capabilities the NEW bank MUST have for ACPR/FCA EMI operation. Each is independent of whether legacy code exists.

| # | NEW capability | Source | Decision | Serving legacy (if any) |
|---|---|---|---|---|
| C1 | Multi-chain custody (key gen, derive, sign) | ADR-021 WalletPort | legacy-serves | crypto-api-keys-lib (SPEC #1) |
| C2 | Crypto address validation | ADR-021 WalletPort | legacy-serves | wallet-address-validator (SPEC #2, rewrite) |
| C3 | Fiat payment rails (SEPA, Open Banking) | ADR-020 PartnerPort | legacy-serves | sepa-service + banxe-open-banking (SPEC #5) |
| C4 | Banking-as-a-Service (account issuance) | ADR-021 PartnerPort | legacy-serves | banxe-baas (SPEC #5) |
| C5 | KYC/AML onboarding + tiers | ADR-028 KYCProviderPort | legacy-serves | banxe-baas SumSub (SPEC #8) |
| C6 | Crypto exchange / trading | ADR-016 ExchangePort | legacy-serves | fast-exchange + neuron-bitshares-ui (SPEC #4) |
| C7 | Portfolio analytics | roadmap | legacy-serves (rewrite Python) | crypto-api-portfolio (SPEC #7) |
| C8 | Multi-chain RPC ops | roadmap R3 | legacy-serves | crypto-api-rpc (SPEC #7) |
| C9 | User notifications (Telegram, push) | roadmap | legacy-serves | telegram-bot + neuron-push (SPEC #3) |
| C10 | Referral / CRM | roadmap | legacy-serves | banxe-referrers (SPEC #6) |
| C11 | Tariff / fees | roadmap | legacy-serves | banxe-tariff (SPEC #6) |
| C12 | File / document service | roadmap | legacy-serves | files-api (SPEC #6) |
| C13 | Resilience (circuit breaker) | ADR (resilience) | legacy-serves (as lib) | banxe-circuit-breaker (SPEC #6) |
| C14 | Ledger / double-entry accounting | ADR-013 midaz | build-fresh (Midaz OSS, not banxe legacy) | midaz-ledger (PR #303, not banxe-rar) |
| C15 | Audit trail (CASS 15 5y) | ADR-027 | build-fresh (Guardian + ClickHouse) | none in banxe-rar |
| C16 | Travel Rule v2 (IVMS101) | ADR-036 | build-fresh | none in banxe-rar (NEW requirement) |
| C17 | Observability (Prometheus/Grafana) | R3 | build-fresh | none in banxe-rar |
| C18 | News feed | roadmap | legacy-serves | crypto-api-news (SPEC #7) |

## Build-fresh gaps (NEW needs WITHOUT legacy source)

These NEW capabilities have NO usable legacy in banxe-rar; they must be built fresh, not refactored:

- C14 Ledger: use Midaz OSS (already running, PR #303); legacy BANXE had no double-entry ledger worth keeping.
- C15 Audit trail CASS 15: Guardian + ClickHouse (build-fresh; ADR-027).
- C16 Travel Rule v2 IVMS101: NEW regulatory requirement; no legacy implementation exists.
- C17 Observability: Prometheus/Grafana stack (build-fresh; R3).

Implication: 4 of 18 NEW capabilities (22%) are build-fresh. Earlier legacy-driven SPECs never surfaced these because they only looked at what legacy HAD, not what NEW NEEDS.

## Anti-map (legacy WITHOUT NEW need — drop regardless of quality)

Legacy code present in banxe-rar but serving NO NEW capability:

- 9 of 15 blockchains in crypto-api-keys-lib (BSV, BCH, DOGE, EOS, Emercoin, Dashcoin, Polkadot, Terra x2) - no NEW custody need.
- cex/cex + cex/gql-cex (bare gits) - no NEW capability.
- standalone banxe-open-banking (older copy) - superseded; no NEW need.
- neuron-push-notifications-chat (skeleton) - no NEW capability beyond NotificationPort.
- banxe-trade-view (skeleton) - superseded by trade-view-new.
- WordPress sites, gambling-acquiring, BitShares blockchain core - no NEW EMI capability.

## Audit register — 11 existing SPECs against NEW-priority standard

Each SPEC reviewed: was it NEW-need-first or legacy-first? Revision needed?

| SPEC | NEW capability served | Was NEW-need-first? | Revision verdict |
|---|---|---|---|
| #1 crypto-api-keys-lib | C1 custody | PARTIAL (15-chain table classified by EMI relevance = NEW-driven; but inventory-first ordering) | MINOR: add C1 capability ref at top; no content change |
| #2 crypto-utils-libs | C1/C2 support | NO (pure legacy fork analysis) | MINOR: state it serves C1/C2; otherwise valid |
| #3 notification-port | C9 notifications | PARTIAL | MINOR: add C9 ref |
| #4 trading-ui-group | C6 trading | YES (DROP decisions driven by NEW scope) | OK: no revision |
| #5 emi-banking-services | C3/C4 fiat + BaaS | PARTIAL | MINOR: add C3/C4 ref |
| #6 fiat-backend-utils | C10/C11/C12/C13 | NO (utilities grouped by legacy folder) | MEDIUM: re-anchor to C10-C13 capabilities |
| #7 crypto-ops-subgroup | C7/C8/C18 | YES (Python rewrite = NEW-driven) | OK: no revision |
| #8 kyc-provider-port | C5 KYC | YES (extract driven by ADR-021 port need) | OK: no revision |
| INDEX | all | PARTIAL | MEDIUM: add capability column linking C1-C18 |
| PartnerPort CONTRACT | C3/C4 | YES (contract = NEW-need-first) | OK |
| WalletPort CONTRACT | C1 | YES (custody-critical NEW requirement) | OK |

## Revision priority

- HIGH: none — no SPEC is fundamentally wrong (legacy DROP/TRANSFORM verdicts all align with NEW need by coincidence of good classification).
- MEDIUM (2): SPEC #6 re-anchor to C10-C13; INDEX add capability column.
- MINOR (4): SPEC #1/#2/#3/#5 add a NEW-capability reference line.
- OK (5): SPEC #4/#7/#8 + both CONTRACTs already NEW-need-first.

## Conclusion

The existing 11 SPECs are SUBSTANTIVELY correct under the NEW-priority canon (legacy verdicts align with NEW need), but METHODOLOGICALLY they were legacy-first. The fix is lightweight: add a NEW-capability anchor to each SPEC linking it to C1-C18 in this map, and re-anchor SPEC #6 + INDEX. No SPEC requires rewriting its decisions. This map is now the governing reference; future SPECs MUST start from a Cn capability, not from a legacy folder.

=== END OF NEW-PROJECT PRIORITY MAP (governing document; NEW drives legacy reuse) ===

## Amendment — capabilities C19-C30 (surfaced by NEW-driven category sweeps)

The original C1-C18 came from ADR-021 + roadmap. NEW-driven sweeps of CLASS_PORT/MERGE/REVIEW/TAIL surfaced 12 additional mandatory capabilities that a legacy-first pass would have missed:

| # | Capability | Surfaced by | SPEC | Decision |
|---|---|---|---|---|
| C19 | Authentication / identity / 2FA | CLASS_PORT sweep | #12 | legacy-serves (IAMPort/TokenManagerPort/TwoFactorPort) |
| C20 | Account management | CLASS_PORT sweep | #13 | legacy-serves (AccountPort) |
| C21 | Webhook ingestion | CLASS_PORT sweep | #14 | legacy-serves (WebhookPort) |
| C22 | Card issuance | CLASS_MERGE sweep | #15 | legacy-serves (CardPort + Paymentology) |
| C23 | Customer lifecycle / reference data | CLASS_MERGE sweep | #16 | legacy-serves (banxe-customer-lifecycle) |
| C24 | KYB business onboarding | CLASS_MERGE sweep | #17 | legacy-serves (Ballerine) |
| C25 | FX rate engine | CLASS_MERGE sweep | #17 | legacy-serves (fx_engine) |
| C26 | FinOps automation | CLASS_REVIEW sweep | #19 | legacy-serves (banxe-finops) |
| C27 | Workflow automation / triggers | CLASS_TAIL sweep | #20 | legacy-serves (banxe-automation-platform) |
| C28 | Enhanced Due Diligence (FCA EDD) | CLASS_TAIL sweep | #21 | legacy-serves (banxe-edd-platform) |
| C29 | Settlements (CASS 15) | CLASS_TAIL sweep | #21 | legacy-serves (banxe-settlements) |
| C30 | Support operations | CLASS_TAIL sweep | #21 | legacy-serves (banxe-support-ops) |

Lesson confirmed: NEW-driven canon surfaced 12 mandatory capabilities (40% more than the original 18) by analysing what legacy categories implied about NEW needs. A legacy-first pass would have refactored code without knowing these capabilities were required.

## Total capability count: 30 (C1-C30)

- 18 original (ADR-021 + roadmap).
- 12 surfaced (NEW-driven category sweeps).
- 4 build-fresh with no legacy (C14 ledger, C15 audit, C16 Travel Rule, C17 observability).

=== END OF C19-C30 AMENDMENT (governing canon complete; 30 capabilities) ===
