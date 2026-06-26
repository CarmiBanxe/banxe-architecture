# PAYBIS dossier — IL re-mint map (frozen at merge, ADR-119 Rule 8)

At landing onto `origin/main`, `build_ledger.py` re-minted the 28 provisional dossier IL shards to
`max+1` over the up-to-date base (prior origin/main IL max = **567**) → final range **IL-568…595**.
Append-only verified: **added=28, mutated=0, removed=0**. The canonical numbers live in
`ledger/IL-SEQUENCE.json` + `INSTRUCTION-LEDGER.md` (authoritative). Shard bodies were written with
**provisional** numbers (each self-notes "provisional IL = max+1 frozen-at-merge; MAIN re-ids"); use
this table to map any provisional `[IL-NNN]` in shard/doc prose to its final value.

> **Not blanket-rewritten in prose** by design: provisional IL-551…554 are ambiguous across branches
> (this dossier branch vs the `phase36/impl-state-refresh` branch, which independently used 551…554),
> and historical refs (IL-516/535/538/541) must stay. Numeric prose ≠ authoritative; this table + the
> regenerated `INSTRUCTION-LEDGER.md` are.

| session-id | provisional | final |
|---|---|---|
| neuronext-paybis-retirement (ADR) | 545 | **568** |
| paybis-dossier | 546 | **569** |
| paybis-src01 | 547 | **570** |
| paybis-intake-register | 548 | **571** |
| paybis-src04-ingest | 549 | **572** |
| paybis-src0506-ingest | 550 | **573** |
| paybis-plan-roadmap | 551 | **574** |
| paybis-wave-a | 552 | **575** |
| paybis-arch-conformance | 553 | **576** |
| paybis-e10-audit | 554 | **577** |
| paybis-e9-guard | 555 | **578** |
| paybis-e10-v2-audit | 557 | **579** |
| paybis-e12-conformance | 556 | **580** |
| paybis-e10-legacy-wave2 | 558 | **581** |
| paybis-i27-kyc-park | 559 | **582** |
| paybis-consolidation-closed | 560 | **583** |
| paybis-landing-handoff | 561 | **584** |
| paybis-signature-blocker | 562 | **585** |
| paybis-signature-note-repair | 563 | **586** |
| paybis-sandbox-state | 564 | **587** |
| paybis-governance-facts | 565 | **588** |
| paybis-landing-refresh | 566 | **589** |
| paybis-legacy-flow-map | 567 | **590** |
| paybis-flowmap-safeguard-fix | 568 | **591** |
| e10-auth-orphan-exec | 569 | **592** |
| e10-wave1-closed | 570 | **593** |
| landing-5branch | 571 | **594** |
| adr-126-to-138-renumber | 572 | **595** |

ADR: provisional ADR-126 → **ADR-138** (collision with merged `ADR-126-hermes`; ADR-119).
