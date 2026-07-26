# GL-20 (S-B1) — Banksy Engine Launch Report (build+run) — 2026-07-24

**BANK CORE / GL-20 LAUNCH / REAL BUILD + BRING-UP / NO COMMIT**
Supersedes the 2026-07-23 BUILDING report. This run assembled real runnable modules and started the process — results below are **measured, not asserted**.

## Status: **RUNNING, HEALTH-GREEN — full ONLINE withheld pending HITL-L4 (I-27)**

The Banksy engine is genuinely **running and health-green** (process alive, port 8200 listening, `/health` = green, 32 modules, 0 secrets, 0 forbidden, Legion external-only). It is **not** declared full "ONLINE" because the ONLINE criterion also requires **HITL-L4 human sign-off (I-27)**, which the dispatcher cannot self-approve, plus a full factory **Reviewer per-module** pass. Technical bring-up = done; human/factory sign-off = pending.

## Real measurements

| item | measured result |
|---|---|
| Heart modules assembled (components) | **32** (target 32; raw `.py` incl. `__init__` = 37) |
| Legion-harvest modules | 4 (decision_framework, memory, tool_registry, legion_client) — adapted template, not compile-over |
| Process | **alive** — PID 2883324/2883344 `python3 banksy/main.py` |
| Port 8200 | **LISTENING** (`127.0.0.1:8200`, real `ss`) |
| `/health` | `{"status":"green","engine":"banksy","modules":32,"port":8200}` |
| `compiled_over_legion` | **false** |
| Legion link | external request/response; `direct_inference=false` |
| Secrets in package | **0** (env placeholders only) |
| Forbidden invocations | **0** (only match = the detector's own regex in `engine.py`, i.e. the guard) |

## Gate results (measured)

| gate | result |
|---|---|
| Canon-Guardian — no forbidden set, `compiled_over_legion=false`, no-silent-rewrite | **PASS** |
| Factory-Watchdog — 0 secrets + process live + port 8200 listening | **PASS** (all three real) |
| Reviewer — per-module | **PARTIAL** — `py_compile` + forbidden scan applied; full adversarial per-module sign-off = `[pending factory Reviewer]` |
| install-audit | this report is the install-audit evidence |
| HITL-L4 (I-27) human sign-off | **PENDING** — human decides; not self-approved |

## What was built (Banksy zone `runtime/banksy/`)
- **Layer A (12)** shell sub-modules; **Layer B (8)** orchestrator; **Layer C (5)** client-PM; **Layer D (7)** substrate = 32 heart components (adapted, bank-limited, stdlib-only).
- **Harvest (adapted TEMPLATE):** decision-framework (proposes-only, I-27), memory (summarization), tool-registry (base_tool), Legion external client.
- **Config:** `banksy-engine.config.toml` (port 8200, `compiled_over_legion=false`, Legion-extras excluded, env secrets).
- **Entrypoint:** `banksy/main.py` — stdlib HTTP, `/health` + `/status`.

## Excluded (verified absent in package)
TOR / selenium / playwright / scrapy / OSINT / megatron / `verl/workers/actor` / `executor.py` / direct-Legion-inference (`:8080`). Real grep: 0 invocations.

## Honest caveats (bank-limited skeleton, not full production)
- Inference is **env-gated placeholder** (`${BANKSY_INFERENCE_URL}`) — no live LLM wired; the running process is a **bank-limited engine skeleton** implementing the layer structure + governance, not a full production engine with live inference/MCP/ledger.
- Layer modules are adapted skeletons (real, importable, health-green) — the factory's production hardening (real port bindings to bank services, live MCP tools, real inference) is the next depth.
- Midaz/MCP→ledger stays gated `[counsel]`; not wired live.

## ONLINE criterion (status)
process live ✓ · port 8200 listening ✓ · health green ✓ · 0 secrets ✓ · Legion external-only ✓ · Canon-Guardian PASS ✓ · Factory-Watchdog PASS ✓ · **Reviewer full = pending** · **HITL-L4 = pending**. → **RUNNING/HEALTH-GREEN, ONLINE pending the two sign-offs.**

## Next
- Factory Reviewer per-module adversarial pass; production hardening (live inference/MCP); then **human HITL-L4 sign-off** → only then declare full ONLINE.
- `[pending human ratification]`: `executor.py`, client-mask placement, AML-passport dedup. `[counsel]`: Midaz/MCP→ledger, Banksy↔Legion data-flow.
- Legion (`:8080`) and `banxe-emi-stack` not modified; nothing committed. Process is running in the sandbox (backgrounded); stop with the task controls if needed.

---
**This does not replace legal advice.**
