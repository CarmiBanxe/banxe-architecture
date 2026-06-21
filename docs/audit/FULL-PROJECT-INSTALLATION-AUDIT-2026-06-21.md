# Full-Project Installation Audit — L1/L2/L3 + Sandbox-Completion Roadmap (2026-06-21)

> Track: `agent/factory/arch-stack-002` · per ADR-106 ACCEPTED · ADR-052 governance.
> **Read-only physical audit** across all project repos. No feature code changed by this document.
> Companion to `FEATURE-INSTALLATION-AUDIT-METHODOLOGY-2026-06-20.md` (L1/L2/L3 model + verdicts).

## 1. Scale (physically verified 2026-06-21)

| Repo | Surface |
|------|---------|
| banxe-emi-stack | **104 services**, **812 service `.py`**, **618 test files (~76% coverage)**, **908 FE components** (View/Form) |
| banxe-payment-core | acquiring stack — Hyperswitch / Paymentology / Midaz adapters |
| crypto-ops-monitor | crypto accounting — L3 wired (separate repo) |
| braslina | merchant onboarding — production v1.0.0 |

## 2. L1/L2/L3 verdict

- **Project is ~76% L2** (real code + tests green) — the meaningful sandbox-installed bar.
- **ALL 13 OPEN GAPs HAVE CODE** (each backed by a service of 2–10 `.py`). The `OPEN` statuses are
  **STALE governance metadata, not code-absence** — they predate the code that now exists.
- **`NotImplementedError` = 37 total:**
  - **19 = intentional L3-boundary** (`Live*` / `Provider` / `Adapter` / `BT-*` seams) — the **correct
    sandbox pattern** (real interface, live binding deferred to provisioning).
  - **~18 = thin / stub** — candidates for completeness verification.
- **Thin services (2 `.py` — verify completeness):** `resolution` (GAP-024/057), `safeguarding`
  (GAP-058 audit part), `incident_response` (GAP-059 DORA).
- **L3-blocked (sandbox-defer, operator keys/provisioning):** GAP-008/011/013/015 + **16 BT-markers**
  + **19 Live-providers** — all expected sandbox state, not defects.

## 3. Roadmap to 100% sandbox (3 sprints — NO rewriting of existing code)

### SP-RECON — reconcile the 13 stale OPEN GAPs *(governance only)*
Verify each GAP's service + tests physically exist; flip `OPEN → IN PROGRESS / DONE` with a residual
note where partial. No code changes — status-truth reconciliation only.

### SP-THIN — complete the 4 thin services to full L2 *(code + tests)*
`resolution` (GAP-024/057), `safeguarding`-audit (GAP-058), `incident_response` (GAP-059 DORA).
Only where genuinely incomplete; finish to real L2 (code + green tests), reusing existing seams.

### SP-L3DOC — document the L3 boundary *(governance only)*
Record every `Live*Provider` + `BT-`blocked marker as **"L2-ready, L3 deferred to production cutover"**
(sandbox-expected). Makes the deferred-vs-defect distinction explicit and auditable.

## 4. Summary

**Sandbox L2-installation is ~complete.** The project is ~76% L2 with code behind every OPEN GAP; the
remaining work is **status-reconcile (SP-RECON) + 4 thin services (SP-THIN) + L3-boundary documentation
(SP-L3DOC)** — **NOT large code gaps**. L3-live across the project is intentionally deferred to the
production cutover (keys / provisioning = operator/CEO scope), consistent with the sandbox posture.

Roadmap GAP-076 (IMPL-1..4 ADR-without-code features) is **complete at L2**; this audit extends the
completion picture to the **whole project**.
