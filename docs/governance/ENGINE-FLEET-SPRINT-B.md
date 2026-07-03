# Engine Fleet — Sprint B execution package (install / access / health)

> **Status:** governance writeup for the Sprint-B engine-fleet package. **Additive, pointer-first (ADR-102).**
> **Prepare-only:** the factory **prepares** operator-run scripts + a monitoring passport; it **installs
> nothing, starts no daemon, invents no source, bypasses no auth, and touches no legal/ss1/GUYON / ADR /
> perimeter config.** All install/run is **operator-executed**, bound to the **#1004 Install Provenance
> Guardrail**.

## 1. What this package delivers (all prepare-only, operator-run)
| File | Purpose | Who runs |
|---|---|---|
| `scripts/engines/install-engines.sh` | idempotent installer, **operator-run**, provenance-bound to #1004 | operator |
| `scripts/engines/engines-access.sh` | symlinks installed engines into `~/bin/engines/` + `engines-status` | operator |
| `scripts/engines/engine-health-check.sh` | one-shot read-only health probe (bin + port); prints `ALERT` on fail | operator |
| `config/agents/passports/engine-health-agent.yaml` | **EngineHealthAgent** passport (read-only platform monitor) | — (PROPOSED) |

## 2. Install — trusted / source-identified only (bound to #1004)
Per the **Install Provenance Guardrail** (#1004, `FRAMEWORK-ADOPTION-SPRINT-B.md`), `install-engines.sh` only
installs verified sources; **blocked/blocking engines are NOT installed — only escalated:**

| Engine | Action in the script | Provenance (#1004) |
|---|---|---|
| openclaw | install from npm (trusted publisher) — idempotent | trusted |
| aider | `pipx install aider-chat` (**not `aider`**) — idempotent | trusted |
| metaclaw | `pipx install metaclaw` — idempotent | trusted |
| mirofish | **build-from-local `~/MiroFish`** (docker-compose / npm; **not** a registry package) | source-identified, local-only |
| **nanoclaw** | **no install** — `[BLOCKING: operator]` comment (publisher unverified) | blocking |
| **hermes** | **no install** — `# BLOCKED per #1004; escalate` (BANXE canon role, not a public package) | blocked |
| **ironclaw** | **no install** — `# BLOCKED per #1004; escalate` (wrong publisher, kumareth) | blocked |

Each installed engine is **idempotent** (`command -v` guard) with echo-logs + exit codes; the script header is
**"OPERATOR-RUN ONLY … dual-use"** and it never auto-runs.

## 3. Simplified access
`engines-access.sh link` symlinks each **installed** engine into `~/bin/engines/` (solving "engines are hard to
find"); `engines-access.sh status` (and the `engines-status` function) prints bin + version per engine. It
**links only what is installed** — it installs nothing, and **excludes blocked/blocking engines** by construction.

## 4. EngineHealthAgent (read-only AI monitor)
`config/agents/passports/engine-health-agent.yaml` — a **platform-monitoring** passport (**required-fields-complete
+ fleet-convention-conformant** against `schemas/agent_passport.schema.json`; note the schema's strict
`additionalProperties: false` is **not enforced fleet-wide** — the existing ~70 passports carry the same extra
fields, so this passport matches the de-facto fleet convention, not the strict schema): **`trust_zone: GREEN`, `level: 1`, `autonomy: L1_AUTO` (read-only/observe,
ADR-128), `human_double: Head of AI Platform`, `reports_to: CTO`, `hitl_gate: none`.** Tasks: health-check every
`[RATIFY]` min, alert operator on unavailability (`[ENGINE-ALERT]` via Telegram/Hermes ADR-126 read-only), log
to ledger. **Invariants: never installs/starts/stops/manages; no authority expansion; blocked engines
expected-absent; no auth bypass.** The probe logic is `engine-health-check.sh`.
- **PROPOSED, not activated** — `PROPOSED→ACTIVE` is a separate **operator ADR-135 gate** (#989); kept under
  `config/agents/passports/` (prepare-only), **not injected into the canonical `agents/passports/` fleet** until
  the operator promotes it.
- **7/24 daemonisation** (systemd timer / cron) is **operator-run** — this package does not daemonise.

## 5. Boundaries (Rule 6 / perimeter)
- **0 installs, 0 daemons started** — scripts are prepared, operator-executed.
- **No invented source** — blocked stays blocked (hermes/ironclaw); `[BLOCKING]` stays blocking (nanoclaw);
  mirofish is local-build-only.
- **No auth bypassed**; **no legal/ss1/GUYON, no ADR, no perimeter/compliance config touched**; no passport
  outside the one created; dirty checkouts not touched (Rule 6).

## ORCHESTRATION-NOTICE (Central + Right terminals)
- Engine installation is **operator-executed**, provenance-bound to **#1004**; the factory prepared only the
  scripts + a **read-only** monitoring passport (GREEN, L1, no control authority).
- **AWAITS-OPERATOR:** (a) run `install-engines.sh` (dual-use, license-review per ADR-148 / CLAUDE.md §9);
  (b) provide a **trusted source for hermes / nanoclaw**, or keep them blocked; (c) **ironclaw stays blocked**
  (wrong publisher); (d) **activate** EngineHealthAgent (ADR-135) + **daemonise** the 7/24 health-check.
- Coordinates with the #985 consolidation program + #1003 repo manifest; **no conflict**, no terminal's work
  overwritten.

## Changelog
- **v1.0.0 (2026-07-03):** initial engine-fleet package — installer (provenance-bound #1004), access helper,
  read-only health-check, EngineHealthAgent passport (PROPOSED), writeup. *(Append future revisions; do not
  rewrite prior entries — append-only.)*

## Anchors
`docs/governance/FRAMEWORK-ADOPTION-SPRINT-B.md` (#992 + #1004 Install Provenance Guardrail — the provenance
binding) · `docs/governance/AGENT-LIVENESS-SPEC.md` (#988 — the agent-scoped liveness contract EngineHealthAgent
observes) · `docs/governance/AGENT-STATUS-NORMALIZATION.md` (#989 — status enum PROPOSED; activation = ADR-135) ·
`schemas/agent_passport.schema.json` (passport schema) · `docs/adr/ADR-128-banking-agents-hitl-matrix.md`
(L1 auto / read-only) · `docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md` (Telegram/alerting read-only) ·
`docs/adr/ADR-148-handson-ai-adoption-pack-v1.md` (no-import-without-license-review) · CLAUDE.md §9
(external-adoption + HITL) · `.claude/rules/agents.md` (MiroFish research-agent :3001) · ADR-102 (Duplication
Audit — restates none). Operator directive 2026-07-03 (Sprint-B engine install/access/health package;
prepare-only; install nothing; respect #1004; no auth bypass).
