---
id: ADR-140
title: Residual Debt Register — Concept v12.0 Verification (8 non-technical debts)
status: ACCEPTED
date: 2026-06-27
accepted: 2026-06-27
supersedes: []
related:
  - "docs/adr/ADR-139-guardian-system.md (Guardian audit surface for branch/IL gates)"
  - "docs/adr/ADR-004-jube-adapter.md (Jube AGPLv3 boundary — GAP-081)"
  - "docs/adr/ADR-117-factory-project-perimeter-and-fullcycle-org.md (bus-factor org context — GAP-084)"
  - "docs/adr/ADR-056-ledger-coupling-merge-gate.md (ledger coupling this shard satisfies)"
  - "docs/GAP-REGISTER.md (GAP-079..GAP-086 rows this ADR anchors)"
il_anchor: IL-601
scope: BANXE-only
concept_only: false
---

# ADR-140 — Residual Debt Register — Concept v12.0 Verification

## Context

A full 16/16 verification of Concept v12.0 was completed (session 2026-06-27). All
shell/factory-fixable technical debts were resolved in that session:

- Routing remediation (ADR-136/137)
- P0-A CASS 15 recon fix (banxe-emi-stack)
- P0-B Ballerine health check
- Branch-protection enforcement (x3 repos)
- ADR-139 Guardian system architecture record (merged)
- banxe-ui / vibe-coding CI made non-blocking (R-10.2 / R-10.3)
- ADR dedup 11 → 1 remaining (ADR-139)

Eight residual debts **cannot be fixed by the factory** — they require operator,
business, legal, or organisational action. This ADR canonises them as tracked gaps
with verified evidence, owners, fix-paths, and (where applicable) exact operator
command sequences.

Each debt has a corresponding row in `docs/GAP-REGISTER.md` (GAP-079..GAP-086).

---

## Decision

Accept all 8 residual debts as **canonical tracked gaps** in the gap register.
None block the factory's continuous delivery; all have defined owners and fix-paths.
No factory code change is required to close them — only operator/business/legal action.

---

## Residual Debt Catalogue

### RD-01 · C-02.1 — Currency Count Mismatch (P1 product)

**Gap ID:** GAP-079  
**Severity:** P1 — product/regulatory exposure  
**Owner:** Operator / Product  
**Deadline:** Q3 2026

**Verified evidence:**
- Concept v12.0 claims "32 currencies" for the multi-currency wallet.
- Code hard-limits to **10 currencies**: GBP, EUR, USD, CHF, PLN, CZK, SEK, NOK, DKK, HUF.
  - `services/multi_currency/` — enum/allowlist enforces 10-currency limit.
  - OpenAPI schema — `currency` field enum: 10 values.
- No FX nostro accounts, EDD triggers, or correspondent bank coverage for the other 22.

**Regulatory exposure:** FCA PRIN 7 (fair, clear, not misleading) / Consumer Duty PS22/9
§4.11 (product information accuracy). Advertising 32 currencies to customers when the
system accepts only 10 is a PRIN 7 breach risk.

**Fix-path (choose one):**
1. **Option A (preferred short-term):** Correct the Concept document — change "32 currencies"
   to "10 currencies (GBP EUR USD CHF PLN CZK SEK NOK DKK HUF); roadmap to 32 subject to
   nostro/EDD expansion." No code change required.
2. **Option B (medium-term):** Expand allowlist to 32: add FX nostro accounts per currency,
   EDD triggers for high-risk currency corridors, correspondent bank coverage, Frankfurter
   ECB rate feeds for all 32. Estimated: 3–4 sprint weeks engineering + compliance sign-off.

---

### RD-02 · C-37.3 — Intent-First Banking / 6 Cards Not Implemented (P1 product)

**Gap ID:** GAP-080  
**Severity:** P1 — product  
**Owner:** Product  
**Deadline:** Q3 2026 (Sprint 14+)

**Verified evidence:**
- Concept v12.0 §37.3 describes "Intent-First Banking": Hybrid Intent Interface,
  IntentParser, SkillRouter, 6 physical/virtual card variants.
- `banxe-frontend` is a **compliance/operations console** — no consumer-facing UI,
  no card management screens, no IntentParser, no SkillRouter component.
- `src/` / `frontend/` — no `IntentParser`, `SkillRouter`, or card-issuance flows found.
- Paymentology issuer integration (GAP-074) is code-complete but **go-live blocked**
  on sandbox key; even when unblocked, no consumer card UI exists.

**Fix-path:**
Build the consumer-facing Hybrid Intent UI layer: IntentParser NLP component,
SkillRouter dispatch, card management screens (virtual + physical issuance). Requires
product design + separate frontend build targeting end-customers (not ops console).
Estimated: significant product sprint (8–12 weeks). No factory blocker on this item.

---

### RD-03 · AGPL-Boundary — Jube + MiroFish Cannot Be Externalised in BaaS (P1 product/legal)

**Gap ID:** GAP-081  
**Severity:** P1 — legal / channel activation  
**Owner:** Product / Legal  
**Deadline:** Before BaaS channel activation

**Verified evidence:**
- ADR-004: Jube (:5001) — AGPLv3. AGPL §13 copyleft propagation: if Jube is used in a
  network-accessible service exposed to third parties (BaaS channel), the entire service
  stack must be AGPL-licensed or Jube must be replaced with an Apache-2.0 alternative.
- MiroFish: licensed AGPL-3.0 (verified in repo `LICENSE`). Same constraint applies.
- Concept describes a BaaS channel (SDK / white-label API for third-party fintechs).
  Exposing Jube/MiroFish to BaaS customers triggers AGPL §13 network copyleft.

**Regulatory note:** Using AGPL software in a proprietary BaaS without source disclosure
is a licence compliance failure. Legal review required before BaaS go-live.

**Fix-path (choose one):**
1. **Option A:** Replace Jube with an Apache-2.0 fraud-scoring alternative (e.g. Feast +
   custom scoring service) before BaaS channel activation.
2. **Option B:** Replace MiroFish with Apache-2.0 equivalent.
3. **Option C:** Obtain commercial licence for Jube / MiroFish (if available from vendor).
4. **Option D:** Defer BaaS channel; keep AGPL tools for internal use only (no §13 trigger).

Legal must confirm chosen option. Factory implements replacement once option is chosen.

---

### RD-04 · R-09.14 — Legion Ports Exposed on 0.0.0.0 Without Firewall (P1 security)

**Gap ID:** GAP-082  
**Severity:** P1 — security (HIGH-RISK remote)  
**Owner:** Operator (physical / console access)  
**Deadline:** ASAP — before next external exposure

**Verified evidence:**
- `ufw` is **not installed** on Legion.
- 8 services bound to `0.0.0.0` (all interfaces):
  - `:4000` — LiteLLM gateway
  - `:8180`, `:8181` — Keycloak IAM
  - `:8096`, `:8098` — Hyperswitch payment processor
  - `:5001` — Jube fraud scoring
  - `:3000` — (UI / dashboard)
  - `:8765` — (WebSocket / misc)
- No host-based firewall restricts these to LAN/Tailscale.

**Risk:** Any machine on the same network segment (or via misconfigured router) can reach
Keycloak admin, Hyperswitch payment API, and LiteLLM (which proxies to Claude/GPT).

**Fix-path — execute with physical/console access only** (see Appendix A for safe sequence):

> ⚠️ **WARNING:** Applying `ufw default deny` before adding SSH allow will lock you out of
> the machine. Always add allowlist rules BEFORE enabling default-deny. Always set an `at`
> timer rollback as a safety net. Execute at the physical console or with a co-located
> session watching the timer.

See **Appendix A** for the exact safe ufw sequence.

---

### RD-05 · R-09.15 — Tailscale ACL/MagicDNS Not Configured (P2 network)

**Gap ID:** GAP-083  
**Severity:** P2 — network / ops  
**Owner:** Operator (Tailscale admin console)  
**Deadline:** Q3 2026

**Verified evidence:**
- `getent hosts evo1` and `getent hosts evo2` fail — MagicDNS resolution not working.
- SSH to evo1/evo2 via Tailscale blocked — ACL does not permit the connection.
- Guardian (:8195/:8196 on evo1) and LiteLLM gateway are Tailscale-gated but unreachable
  from CI runners due to missing ACL entries.
- `tailscale status` shows devices connected but no ACL grants exist for cross-device SSH.

**Fix-path:**
1. Log into Tailscale admin console (`login.tailscale.com/admin/acls`).
2. Add ACL entry permitting SSH (port 22) from CI runner tags / development machines to evo1/evo2.
3. Enable MagicDNS in the tailnet settings.
4. Verify: `tailscale ping evo1`, `ssh evo1`, `getent hosts evo1` from a dev machine.
5. Optionally add `autoApprovers` for self-hosted runner registration (R-10.3 follow-up).

No code change required — purely admin console configuration.

---

### RD-06 · R-16.1 — Bus Factor = 1 / No Org / No Second Reviewer (P2 org)

**Gap ID:** GAP-084  
**Severity:** P2 — operational / governance  
**Owner:** Operator / Org  
**Deadline:** Before Sprint 5 (as flagged in Concept itself)

**Verified evidence:**
- All 8 repos under personal account `CarmiBanxe` (not a GitHub org).
- No teams configured → no CODEOWNERS meaningful enforcement (6/8 repos missing CODEOWNERS).
- Every protected PR requires `--admin` merge (bypass) because there are no second reviewers.
- Concept v12.0 §16 explicitly flags bus factor = 1 as a risk to address before Sprint 5.
- `CODEOWNERS` files in repos reference team slugs that do not exist in GitHub.

**Fix-path:**
1. Create GitHub Organisation: e.g. `BanxeAI` or `banxe-emea`.
2. Transfer all 8 repos to the org.
3. Invite at least 1 additional team member with write access.
4. Configure branch protection to require 1 real peer review (not admin bypass).
5. Create `CODEOWNERS` files referencing `@OrgName/team-slug` patterns.
6. Once team exists, CODEOWNERS enforcement becomes meaningful.

Estimated: 1–2 hours setup time. Blocking nothing in factory until team exists.

---

### RD-07 · ss1 GDPR — Public Repo Until 2026-05-13, Possible Indexing (P2 legal)

**Gap ID:** GAP-085  
**Severity:** P2 — legal / data protection  
**Owner:** Legal (French jurisdiction — CNIL)  
**Deadline:** ASAP if personal data was in repo

**Verified evidence:**
- Repo `ss1` (guiyon/ss1) was **public until 2026-05-13**, now PRIVATE.
- During the public window, Google Search / archive.org / GitHub cache may have indexed
  content including any personal data committed to the repo.
- French jurisdiction applies (guiyon = French entity, CNIL oversight).

**GDPR exposure (Art.5, Art.33):**
- If personal data (customer PII, financial records, staff data) was committed and indexed,
  a data breach notification to CNIL may be required within 72 hours of becoming aware
  (Art.33 GDPR). The awareness date is now (2026-06-27).
- If no personal data was in the repo, no notification required — legal must confirm.

**Fix-path:**
1. Legal reviews ss1 repo commit history for personal data presence.
2. If personal data found:
   a. Submit DMCA / content-removal request to Google (`google.com/webmasters/tools/legal`).
   b. Submit removal request to archive.org (`archive.org/about/contact.php`).
   c. Notify CNIL (`notifications.cnil.fr`) if breach threshold met (Art.33).
3. If no personal data: document the assessment and close gap.

**Note:** The 72-hour Art.33 clock runs from the point the controller becomes aware.
Legal must assess immediately.

---

### RD-08 · self-hosted-runner — AI-Eval CI Needs evo1 Access (P3 infra)

**Gap ID:** GAP-086  
**Severity:** P3 — infrastructure / ops  
**Owner:** Factory / Ops  
**Deadline:** Q4 2026

**Verified evidence:**
- vibe-coding `banxe-verification-tests.yml` + `training-quality-report.yml` run
  LangGraph / DeepEval / Evidently evaluation against `run_verification()` which
  calls the LLM endpoint at `evo1:11434` (Ollama) via Tailscale.
- GitHub `ubuntu-latest` runners cannot reach evo1 (Tailscale ACL blocked — see GAP-083).
- Fix applied (R-10.3): `continue-on-error: true` + `::warning::` — CI no longer red.
  This is the **temporary** fix; the permanent fix is a self-hosted runner.

**Fix-path (permanent — after GAP-083 Tailscale ACL is resolved):**
```bash
# On evo1 (192.168.0.72) — requires Tailscale access (resolve GAP-083 first)
mkdir -p ~/actions-runner && cd ~/actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.317.0.tar.gz
# Get registration token from GitHub: Settings → Actions → Runners → New self-hosted runner
./config.sh --url https://github.com/CarmiBanxe/vibe-coding --token <REGISTRATION_TOKEN>
sudo ./svc.sh install && sudo ./svc.sh start
```
Then update `vibe-coding` workflows: `runs-on: ubuntu-latest` → `runs-on: self-hosted`.
Remove `continue-on-error: true` once the runner is stable and evals pass.

Blocked by: GAP-083 (Tailscale ACL). Sequence: resolve GAP-083 → then GAP-086.

---

## Appendix A — Safe `ufw` Sequence for Legion (RD-04 / GAP-082)

> ⚠️ **EXECUTE WITH PHYSICAL/CONSOLE ACCESS ONLY.**
> A remote SSH session risks permanent lockout if a step fails or the connection drops.
> The `at` timer is a safety net — do not skip it.

```bash
# ── Step 0: Safety net — auto-disable ufw in 5 minutes if something goes wrong ──
# Run FIRST, before any other ufw command
echo "ufw --force disable" | at now + 5 minutes
# Confirm the timer is set:
atq

# ── Step 1: Install ufw ──
sudo apt-get update -qq && sudo apt-get install -y ufw

# ── Step 2: Add allowlist rules BEFORE enabling ──
sudo ufw allow ssh                          # port 22 — remote access
sudo ufw allow from 192.168.0.0/24          # LAN (all ports — adjust if needed)
# If Tailscale interface is tailscale0:
TAILSCALE_SUBNET=$(ip addr show tailscale0 2>/dev/null | grep 'inet ' | awk '{print $2}')
[ -n "$TAILSCALE_SUBNET" ] && sudo ufw allow in on tailscale0

# ── Step 3: Set default deny (inbound) ──
sudo ufw default deny incoming
sudo ufw default allow outgoing

# ── Step 4: Enable (DRY-RUN review first) ──
sudo ufw show added              # review all rules before enabling
# If rules look correct:
sudo ufw --force enable

# ── Step 5: Verify connectivity (from another terminal / session) ──
# Test SSH still works. If yes, cancel the at timer:
atrm $(atq | awk '{print $1}')
# If SSH is broken, the at timer will disable ufw in ≤5 minutes — wait it out.

# ── Step 6: Verify rules ──
sudo ufw status verbose
```

**Expected open ports after:**
- 22/tcp — SSH (all sources, or restrict to LAN: `ufw allow from 192.168.0.0/24 to any port 22`)
- LAN subnet 192.168.0.0/24 — all ports (Tailscale + local dev)
- Tailscale interface (tailscale0) — all ports

**Services that will be firewalled from external:**
LiteLLM :4000, Keycloak :8180/:8181, Hyperswitch :8096/:8098, Jube :5001, :3000, :8765.
Access these via LAN or Tailscale after enabling ufw.

---

## Consequences

**Positive:**
- All 8 residual debts have canonical IDs (GAP-079..GAP-086), owners, and fix-paths.
- Factory delivery is unblocked — none of these gaps block CI/CD or code delivery.
- Regulatory exposure (PRIN7, Consumer Duty, GDPR Art.33) is formally acknowledged
  with documented fix-paths, supporting FCA audit trail.
- ufw safe-sequence in Appendix A prevents accidental lockout during R-09.14 remediation.

**Negative / risks:**
- GAP-085 (GDPR ss1) has a time-sensitive Art.33 clock — legal must assess without delay.
- GAP-082 (ufw) remains a live security gap until operator executes with physical access.
- GAP-084 (bus factor) means any factory outage has no coverage — no mitigation until org
  and team members are onboarded.

## References

- Concept v12.0 verification session: 2026-06-27
- GAP-079..GAP-086: `docs/GAP-REGISTER.md`
- ufw safe-sequence: Appendix A (this document)
- ADR-004 Jube AGPLv3: `docs/adr/ADR-004-jube-adapter.md`
- ADR-117 bus factor / org: `docs/adr/ADR-117-factory-project-perimeter-and-fullcycle-org.md`
- CNIL Art.33 portal: `notifications.cnil.fr`
- Tailscale ACL console: `login.tailscale.com/admin/acls`


---

## Amendment 1 — 2026-06-27: S-PROD-1 Safeguarding Production Residual (GAP-087)

**Raised by:** Late verification audit (2026-06-27). **Ledger:** IL-606.

A ninth residual debt was identified after ADR-140 was originally accepted. It was **not
captured** in the original 8-gap set (GAP-079..GAP-086) because:

- GAP-003 (J-engine) + GAP-004 (J-audit) were marked ✅ DONE on code-complete (IL-SAF-01 v1,
  banxe-emi-stack#24), and the original ADR-140 scope focused on
  **operator/business/legal/org** debts only.
- The full **production delivery** gap — 3-leg tie-out, Midaz production hook, shortfall
  auto-FCA — was not in scope of the original verification pass.

### RD-09 · S-PROD-1 — Safeguarding Engine Production Delivery

**Gap ID:** GAP-087
**Severity:** P0 — FCA CASS 15 authorisation blocker
**Owner:** CTIO / CFO
**Deadline:** OVERDUE — 2026-05-07
**Status:** 🔴 OPEN

**Verified evidence:**
`docs/ROADMAP-STATUS-2026-06-23.md:69` — *"S-PROD-1 | P0 | Safeguarding Engine —
J-engine (IL-SAF-01 prompt-ready), J-audit, E-safeguard | CASS 15 / PS10-15; Midaz |
⚠ OVERDUE — deadline 2026-05-07 passed. Highest priority; daily-recon + shortfall
auto-FCA (immutable, no-suppress)."*

**Distinction from GAP-003/004/005:**

| Gap | Status | Scope |
|-----|--------|-------|
| GAP-003 J-engine | ✅ DONE | Code-complete: IL-SAF-01 v1 (banxe-emi-stack#24). Initial implementation. |
| GAP-004 J-audit | ✅ DONE | Code-complete: ClickHouse audit trail basic setup. |
| GAP-005 E-safeguard | 🟡 IN PROGRESS | Daily segregated-accounts recon — active. |
| **GAP-087** | 🔴 OPEN | **Full production delivery**: 3-leg tie-out (A Midaz ↔ B safeguarding ↔ C rail), Midaz production hook, daily shortfall auto-FCA (immutable/no-suppress). None live. |

**Distinction from 2026-06-27 ClickHouse-auth fix:**
The ClickHouse connection-auth fix (banxe-recon exit=0, done this session) resolves an
infra authentication issue. It does **not** constitute CASS 15 production-readiness —
the 3-leg tie-out and Midaz production hook remain outstanding.

**Fix-path:**
1. Complete `banxe-emi-stack` 3-leg wire-up (active branch: `agent/factory/safeguarding/wire-3leg-agent`;
   PR #218 merged Leg C rail port + CASS 15 three-leg tie-out A==B==C).
2. Wire `SafeguardingAccountPort` → real Midaz Leg A balance endpoint (replace stub).
3. Activate daily-recon governor (`agents/passports/safeguarding_recon_governor.yaml`, GAP-005).
4. Implement shortfall auto-FCA notification pipeline (append-only I-24, immutable, no-suppress).
5. Ops sign-off: CTIO confirms live daily run; CFO signs off on relevant-funds computation.

**Regulatory basis:** FCA CASS 15 §7.15 (daily reconciliation), PS25/12 (safeguarding
reform), CASS 7.15.5 (shortfall notification within 1 business day). EMI authorisation
cannot proceed while this is not live.

**Specs:**
- `docs/safeguarding/J-ENGINE-BUILD-SPEC.md`
- `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md`
- `docs/safeguarding/J-CROSS-REPO-HANDOFF.md`
- `docs/safeguarding/E-D-CROSS-REPO-HANDOFF.md`
