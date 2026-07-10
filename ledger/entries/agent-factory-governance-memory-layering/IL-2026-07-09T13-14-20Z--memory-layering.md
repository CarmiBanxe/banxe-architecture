---
il_ts: 2026-07-09T13:14:20Z
session_id: agent-factory-governance-memory-layering
source: CEO
status: PROPOSED
---
### ADR-166 memory layering — decision-memory + working-memory + ledger SoT (complementary, XOR clarified) — PROPOSED

DOCUMENT-ONLY ADR (`docs/adr/ADR-166-memory-layering.md`) recording the operator ruling that the two
memory contours COEXIST and complement each other (not either/or), and clarifying the memoir XOR
precondition. Three complementary layers by authority: Ledger (ADR-059 supreme SoT) > reasoning_bank
(emi-stack PROJECT decision-memory — append-only/immutable, EU AI Act Art.13, feedback never
auto-applied I-27 → authoritative decision-record) > memoir (factory working-memory — git-plumbing
versioned, NON-authoritative, regenerable, never touches code/ledger/prod/dispatch). Role separation:
decision-memory (WHAT was decided, immutable, audit-grade) ≠ working-memory (HOW the agent worked,
versioned, disposable) — different questions, different perimeters (reasoning_bank=project;
memoir=factory). XOR clarification (PRECOND-04): XOR forbids two substrates OF THE SAME ROLE on one
fork (agentmemory XOR memoir as working-memory); it does NOT forbid a decision-memory layer +
working-memory layer coexisting → reasoning_bank + memoir coexistence PERMITTED. Reliability =
defense-in-depth (losing memoir loses nothing authoritative; ledger + reasoning_bank immutability
preserve the record). Perimeter (ADR-117): factory memoir and project reasoning_bank share NO store,
no cross-perimeter memory. No authority (ADR-130/127): all layers read-only w.r.t. authority; recall
confers no permission. Consequence: two contours canonically complementary (ruling satisfied), XOR
intact; a future project working-memory stays XOR-gated within its role, needs its own ADR + IronClaw.
Status PROPOSED — nothing activated; no code/config/perimeter change. Refs: ADR-136, ADR-137, ADR-059,
ADR-130, ADR-127, ADR-117, ADR-102, I-27/I-24/I-28.
