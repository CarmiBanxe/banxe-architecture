# Runbook: OfficeCLI on Legion (Dev-Only, Sandboxed)
# ADR-035 ROADMAP Part 3 / Step 5
# Date: 2026-05-11 | Author: Sub-terminal A

## Overview

OfficeCLI 0.2.52 is installed on Legion WSL2 as a dev-only tool for generating
ADR documents, compliance presentations, and reports (PPTX / DOCX / XLSX) from
natural language prompts.

**Install scope: Legion only. Never install on evo1 or evo2.**

---

## What OfficeCLI Does

Generates Office documents from natural language:
```
officecli new pptx   "ADR-035 AI pool architecture"
officecli new docx   "FCA CASS 15 compliance summary Q2 2026"
officecli new xlsx   "safeguarding reconciliation template"
officecli new report "pool audit findings 2026-05-11"
officecli new img    "architecture diagram AI inference pool"
```

Requires an API key for generation beyond the free trial quota.

---

## Install Steps (performed 2026-05-11)

### Prerequisites
- Legion WSL2 (Ubuntu 22.04+)
- Node.js via nvm (v22.22.0+)
- Running as `mmber` (non-root — REQUIRED)

### 1. Install via npm
```bash
npm install -g officecli
```

The postinstall script downloads the Linux x64 binary from
`github.com/officecli/officecli-dist` and verifies checksums.
No external secrets or tokens are required for install.

### 2. Verify install
```bash
officecli --version
# Expected: officecli version 0.2.52 (...)
```

### 3. Create sandboxed workspace
```bash
mkdir -p ~/banxe-dev/office-workspace
# Verify: no symlinks into /data/*
find ~/banxe-dev/office-workspace -type l
# Expected: (no output)
```

### 4. Set workspace env var
```bash
grep -q OFFICECLI_WORKSPACE ~/.bashrc || \
  echo 'export OFFICECLI_WORKSPACE="$HOME/banxe-dev/office-workspace"' >> ~/.bashrc
source ~/.bashrc
```

### 5. Configure output directory
```bash
officecli config set output-dir ~/banxe-dev/office-workspace
```

---

## Binary Location

OfficeCLI is installed via nvm-managed npm:
```
~/.nvm/versions/node/v22.22.0/bin/officecli
  → ../lib/node_modules/officecli/bin/officecli.js  (Node.js wrapper)
  → downloads runtime binary to node_modules/officecli/runtime/officecli
```

The `officecli` command is available in PATH when nvm is active (default on Legion).

---

## Config and Auth

| Command                          | Purpose                          |
|----------------------------------|----------------------------------|
| `officecli config status`        | Show current config              |
| `officecli auth status`          | Show API key / quota status      |
| `officecli auth set-key <key>`   | Set paid API key                 |
| `officecli config set <k> <v>`   | Update a config value            |

Config file: `~/.config/officecli/config.json`

**API key storage:** `~/.config/officecli/config.json` — never commit this file.
Add to `.gitignore` if the home directory is ever tracked.

---

## Smoke Test (non-network)
```bash
officecli --version           # version line
officecli config status       # shows config without hitting API
officecli auth status         # shows quota without generating content
```

Expected output (as of 2026-05-11):
```
Config file: /home/mmber/.config/officecli/config.json
Generation service configured: false
Default output directory: ./output
Default generation mode: fast
```

---

## Deny Boundary

OfficeCLI must never read from or write to regulated data paths.

The following paths are denied at the Claude Code CLI layer via
`~/.claude/settings.json` deny rules:

```
Read(/data/kyc/**)
Read(/data/transactions/**)
Read(/data/aml/**)
```

Any shell command, `--prompt-file`, or `officecli` invocation that attempts
to access these paths will be blocked before execution. No runtime test is
required — the deny rules are enforced at the tool-use permission layer.

**Additional hard constraints:**
- Never use `--prompt-file` pointing into `/data/*`
- Never set `OFFICECLI_WORKSPACE` to any `/data/*` path
- Never symlink `~/banxe-dev/office-workspace` into `/data/*`

---

## Usage Examples (Banxe context)

```bash
# Generate ADR presentation
officecli new pptx "ADR-035 Hybrid AI Pool — architecture and rationale" \
  --audience "engineering team" --lang en --out ~/banxe-dev/office-workspace

# Generate compliance summary doc
officecli new docx "FCA CASS 15 safeguarding controls Q2 2026" \
  --mode best --out ~/banxe-dev/office-workspace

# Score an existing deck
officecli score pptx ~/banxe-dev/office-workspace/deck.pptx

# Review a generated document
officecli review pptx ~/banxe-dev/office-workspace/deck.pptx
```

---

## Upgrade
```bash
officecli upgrade          # checks for newer release
npm install -g officecli   # force reinstall latest
```

---

## Do-Not-Do List

| Action                                         | Reason                                      |
|------------------------------------------------|---------------------------------------------|
| `ssh evo1 'npm install -g officecli'`          | evo1/evo2 are inference/prod nodes — dev tools banned |
| `sudo npm install -g officecli`                | Never run as root in WSL2 (shared token store) |
| Mount `/data/kyc`, `/data/transactions`, `/data/aml` into workspace | Regulated paths — denied at CLI layer |
| Use `--prompt-file` with paths in `/data/*`    | Would read regulated data into AI generation context |
| Set `OFFICECLI_WORKSPACE=/data/*`              | Workspace must stay under `~/banxe-dev/` |
| Commit `~/.config/officecli/config.json`       | Contains API key — secret |
| Use `officecli agent-bridge` for autonomous generation | HITL required (I-27) — agent output must be human-reviewed |

---

## Invariants

| Invariant | Check |
|-----------|-------|
| I-02 | OfficeCLI service backend (officecli.io) — verify not sanctioned jurisdiction before production use |
| I-27 | Agent-bridge mode disabled; all generation requires explicit human invocation |
| I-24 | No audit trail data passed to OfficeCLI; output documents are not audit records |

---

## Current State (2026-05-11)

| Item               | Value                                      |
|--------------------|---------------------------------------------|
| Version            | 0.2.52                                      |
| Binary             | ~/.nvm/.../officecli (Node.js + Linux x64)  |
| Workspace          | ~/banxe-dev/office-workspace                |
| OFFICECLI_WORKSPACE| Set in ~/.bashrc                            |
| API key            | Not configured (free trial quota: 0 used)   |
| Symlinks in workspace | None                                    |
| /data/* access     | Blocked by settings.json deny rules         |

