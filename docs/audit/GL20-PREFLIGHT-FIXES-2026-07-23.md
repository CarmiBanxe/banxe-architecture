# GL-20 (S-B1) Pre-flight Fixes — 2026-07-23

**GOVERNANCE-AUDIT / GL-20 PRE-FLIGHT / CONFIG+DOCS ONLY / NO CODE / NO COMMIT**
Two pre-flight blockers found before GL-20 (S-B1 build+launch) fixed at config/spec level. No code built/launched; Legion/runtime untouched.

## Fix 1 — Banksy bind port (8100 taken)

- Preflight: 8100 taken; 8000 / 8200 / 9100 free. Chose **8200** (8000 may be claimed by a dev-server).
- `bank-rooms/F0-engine-manus-room/runtime/banksy-engine.config.toml`: added **`banksy_bind_port = 8200`** with comment "avoid 4000(litellm)/8080(legion)/8095(midaz)/8100(taken)/11434(ollama)".
- Legion `:8080` not touched; Banksy does not bind Legion ports.
- Note: the config previously had **no** explicit bind port — this fix **adds** one (8200), it did not overwrite an 8100 setting.

## Fix 2 — Unify heart criterion to a single number = 32

- Canonical: **HEART_STACK = 32 verified files** (A12·B8·C5·D7=32, verified in `engine-manus-stack.md`). Ambiguity "either 32 or 20+" removed.
- Patched: `BANKSY-ENGINE-INTEGRATION-PLAN.md` (leftover `[reconcile] "21" vs 32` → closed as 32); `BANKSY-ENGINE-BUILD-SPEC-FOR-FACTORY.md` (states 32 canonical + preflight-subset note).
- Already-consistent (32) and left as-is: `BANKSY-ENGINE-STACK-REGISTRY.md`, `engine-manus-stack.md`, roadmap "heart-32" references (GENERAL-LINE, BANKSY-ENGINE-ROADMAP).
- **No "heart≈20+" / "20+" wording found** anywhere — the only variants were the "21" audit-figure leftovers, now closed.
- Build-spec now records: **preflight P2 spot-checks a 20-file subset of the 32; the full 32 is the canonical build input.**

## Fix 3 — Readiness

- Status: **fixes applied; re-run preflight required before factory build.**
- Ready checks for the re-run: (1) 8200 still free at build time; (2) heart criterion = 32 everywhere; (3) Legion/runtime untouched; (4) 0 secrets in zone.
- GL-20 remains **PENDING** (not started); ONLINE only on a green health-check + all gates (Reviewer / Canon-Guardian / Factory-Watchdog) + install-audit + HITL-L4.

## Notes
- Config/docs only; no code assembled or launched; Legion (:8080) and `banxe-emi-stack` runtime not modified.
- `[counsel]`: Midaz/MCP→ledger, Banksy↔Legion data-flow. `[pending human ratification]`: client-mask placement, AML-passport dedup, executor.py.

---
**This does not replace legal advice.**
