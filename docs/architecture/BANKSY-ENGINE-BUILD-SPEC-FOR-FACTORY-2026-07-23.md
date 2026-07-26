# BANKSY ENGINE — BUILD-SPEC for the Factory — 2026-07-23

**BANK CORE / BUILD-SPEC (DISPATCH TO FACTORY) / DOCS-ONLY / NO CODE BUILT HERE / NO COMMIT**

Dispatcher note: this document **only specifies** the build. The factory (Reviewer + Canon-Guardian + Factory-Watchdog + quality-gate) assembles and brings up the engine under audit. No code is built or launched by this spec.

**Verified pre-conditions (shell-audited):**
- Banksy zone ready: `bank-rooms/F0-engine-manus-room/runtime/banksy-engine.config.toml` (bank-limited, `compiled_over_legion=false`, 0 secrets, Legion-extras excluded).
- Status: **SCAFFOLD — engine NOT running** (no process/port).
- Runtime code source = `banxe-emi-stack` (read-only). Template = OpenManus (read-only).
- **HEART_STACK = 32 verified files** (A12/B8/C5/D7) — the **single canonical** count (no "20+"/"21" variants). Preflight P2 spot-checks a **20-file subset** of the 32; the **full 32 is the canonical build input**. CEO-conductor + client-PM CONFIRMED. Legion = external trusted supplier (not in Banksy's stack).
- Bind port: **`banksy_bind_port = 8200`** (free; avoid 4000/8080/8095/8100/11434); never bind Legion's `:8080`.

## 1. Scope

- Assemble **production Banksy code** from the 32-file heart-stack (reference `banxe-emi-stack`, read-only) using the OpenManus **template**, deployed in `bank-rooms/F0-engine-manus-room/runtime/` (Banksy's own zone).
- Banksy is deployed **in its own zone from the same OSS tech as a template — NOT compiled over Legion**.
- **Do NOT touch Legion** (separate external engine on its own laptop/zone). Banksy ↔ Legion is **external request/response only** (client-info gathering + special databases), never a shared runtime.
- Out of scope: modifying `banxe-emi-stack` runtime, modifying OpenManus, any Legion runtime.

## 2. Build steps (factory executes; each step under quality-gate)

1. **Assemble code by layer.** Copy/adapt the 32-file heart-stack into the Banksy zone by layer A/B/C/D (per `../../bank-rooms/F0-engine-manus-room/engine-manus-stack.md`). **Reviewer** checks each module (self-critique + falsification). Source is referenced read-only; production code is authored/adapted in the zone, not moved out of `banxe-emi-stack`.
2. **Wire Banksy-own inference + substrate.** Banksy uses its **own** inference (`${BANKSY_INFERENCE_URL}` / `${BANKSY_MODEL}`), **NOT** Legion's private `127.0.0.1:8080` directly. Wire bank MCP tools + budget gate + lineage/recorders substrate.
3. **Exclude Legion-extra functions.** Ensure TOR networking, headless browser, web-crawl/OSINT, proxy/scrape, and direct-Legion-inference are **absent**. **Canon-Guardian** verifies none are present and that `compiled_over_legion=false`.
4. **Secrets via env only.** All secrets via Vault/env placeholders; **0 secrets in repo**. **Factory-Watchdog** scans the zone and rejects any real secret.
5. **Bring-up.** Start the Banksy process + bind a port in its own zone (e.g. `:8000`), run health-check. (Port is illustrative; factory picks a free port that does not collide with existing services — 4000 LiteLLM, 8095 midaz, 11434 ollama are already bound.)

## 3. Quality gates (mandatory before "online")

- **Reviewer:** self-critique + falsification before any PASS.
- **Canon-Guardian:** no-silent-rewrite; Legion-extras absent; `compiled_over_legion=false`; heart-stack = 32 files honoured.
- **Factory-Watchdog:** 0 secrets in zone; process/port genuinely live (not asserted).
- **install-audit + HITL-L4 sign-off (I-27)** before any "online" declaration. AI proposes; human decides.

## 4. Definition of "ONLINE" (honest criterion)

Status = **ONLINE** only when **all** of the following are simultaneously true and evidenced:
- Banksy process started and running,
- its port is actually listening (verified, not claimed),
- health-check is green,
- Banksy↔Legion boundary active as **external-only** (no shared runtime, no direct Legion inference),
- **0 secrets** in the zone,
- **all quality gates PASS** (Reviewer, Canon-Guardian, Factory-Watchdog) + install-audit + HITL-L4 sign-off.

Until every item is met and evidenced, status stays **SCAFFOLD / BUILDING** — **do NOT report "online".**

## 5. Gated / open

- `[counsel]`: Midaz/MCP→ledger write path; Banksy↔Legion cross-party data flow; any regulated advisory surface.
- `[pending human ratification]`: AML passport dedup (`aml_orchestrator.yaml` vs canonical `banxe_aml_orchestrator.yaml`); expansion-agent selection; fx_engine / design_pipeline ownership.
- No runtime (`banxe-emi-stack`) or Legion repo may be modified by the build.

---
**This does not replace legal advice.**
