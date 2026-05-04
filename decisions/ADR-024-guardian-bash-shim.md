# ADR-024 — Guardian Bash Shim: Claude Code Pre-Command Enforcement

| Field | Value |
|-------|-------|
| **Status** | Accepted |
| **Date** | 2026-05-04 |
| **Deciders** | Moriel Carmi (CEO/CTIO), FinDev Agent |
| **Refs** | I-36, G-GUARD-01..04, PR #48 (banxe-emi-stack) |

---

## Context

Claude Code (Anthropic CLI) executes arbitrary bash commands on behalf of the FinDev Agent
during development sessions. These commands have direct access to production secrets,
financial data, and infrastructure — yet bypassed BANXE Guardian's Policy Decision Point
(PDP) entirely.

BANXE Guardian provides `/audit` POST endpoint returning `{verdict: {result, summary, reasons}}`
for `{subject_type, subject_id, scope, prompt, actor}` payloads. Two instances run on evo1:
factory (:8195, general policy) and project (:8196, per-repo policy).

Two constraints complicate wiring:
1. **WSL2 DNS gap:** `evo1` hostname does not resolve inside Legion WSL2; IP `192.168.0.72`
   must be used directly.
2. **Claude Code hook API:** Only `PreToolUse`, `PostToolUse`, and `Stop` hook types are
   supported. `PRE_COMMAND_HOOK` env var approach (S3) is not supported by the ELF binary.

---

## Decision

Implement a **bash shim** (`claude-bash-shim.sh`) that:
1. Is invoked via Claude Code native `PreToolUse` hook with `matcher: "Bash"` (Strategy-S1)
2. Extracts the bash command from `$TOOL_INPUT` JSON
3. Masks secrets before transmission (sed regex: `password|secret|api_key|access_token|...`)
4. POSTs to Guardian `/audit` with `scope=claude.bash`
5. Applies verdict: `pass`/`warn`/`unknown` → proceed; `fail` → proceed (audit) or block (enforce)
6. Logs all decisions to `~/.claude/guardian-shim/audit.log` (JSON-lines)

**Default mode:** `audit` (non-blocking). **Rollout to enforce:** T+7 for compliance repos,
T+14 everywhere.

**Fail modes:**
- Guardian unreachable + `GUARDIAN_MODE=audit` → fail-open (exit 0, log `unreachable`)
- Guardian unreachable + `GUARDIAN_MODE=enforce` → fail-closed (exit 2, block command)

---

## Alternatives Considered

| Strategy | Description | Decision |
|----------|-------------|----------|
| **S1 (chosen)** | Native `PreToolUse` Bash hook in `.claude/settings.json` | ✅ Cleanest; no shell alias fragility |
| S2 | `alias claude='~/.banxe/guardian-shim/claude-wrap.sh'` | ❌ Fragile; bypassed by `\claude` or env |
| S3 | `PRE_COMMAND_HOOK` env var | ❌ Not supported by Claude Code ELF binary |

---

## Consequences

### Positive
- Every bash command executed by Claude Code is audited (or bypassed with log in `off` mode)
- Secret masking before Guardian POST prevents PII/credential leakage to policy engine
- Fail-closed enforce mode enables zero-trust enforcement for compliance repos (G-GUARD-02)
- Local `audit.log` provides session-scoped forensic trail independent of Guardian availability

### Negative / Gaps
- **G-GUARD-01:** Scope `claude.bash` not yet registered in Guardian rules → all commands
  receive `unknown` verdict (non-blocking). Rule coverage target ≥90% by 2026-05-11.
- **G-GUARD-03:** Guardian ClickHouse retention must be configured for 12 months (FCA-grade).
  Target: 2026-05-31.
- Shim requires manual install to `~/.banxe/guardian-shim/` per operator machine; not yet
  automated in onboarding scripts.

---

## Implementation

| Artefact | Location |
|----------|----------|
| Shim script | `infra/guardian-shim/scripts/claude-bash-shim.sh` |
| Env template | `infra/guardian-shim/scripts/claude-bash-shim.env` |
| Tests (T1-T8) | `infra/guardian-shim/tests/test-shim.sh` |
| S1 hook wiring | `.claude/settings.json` → `hooks.PreToolUse[matcher=Bash]` |
| Activation log | `infra/guardian-shim/README.md` § Activation log 2026-05-04 |

---

## Invariants Introduced

| ID | Rule |
|----|------|
| **I-36** | Every Claude Code Bash tool call MUST route through Guardian Shim before execution |

---

## Rollout Schedule

| Date | Action | Gate |
|------|--------|------|
| 2026-05-04 | Merged PR #48; AUDIT default; shim installed on Legion | G-GUARD-02 pending |
| 2026-05-11 | Switch to ENFORCE for compliance repos (banxe-emi-stack, vibe-coding) | G-GUARD-01 (scope rules) |
| 2026-05-18 | ENFORCE everywhere | G-GUARD-04 |
| 2026-05-31 | Guardian ClickHouse 12-month retention configured | G-GUARD-03 |
