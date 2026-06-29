---
il_ts: 2026-06-28T00:00:00Z
session_id: agent-factory-agenteng04-runtime-addendum
source: factory
status: prepared
---

### Runtime addendum A-003 — VERIFIED-RUNTIME-SNAPSHOT dossier

Append-only addendum to `docs/agent-engine-dossier/VERIFIED-RUNTIME-SNAPSHOT.md` (line-count verified).

**New content from A-003 audit (live shell observation @ origin/main ad99f63, 2026-06-28):**

1. **OpenClaw 4 instances** (NOT in snapshot v2): ctio :18791, guiyon :18794, moa :18789, mycarmibot :18793
   - All via OLLAMA direct (bypass of LiteLLM gateway :4000 — known gap G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY)
   - moa = MOA multi-agent orchestration role
   - Severity: P1 (CTIO owner)

2. **ADR-049 dispatcher-spec** — Intent-Layer L1→L2 client-facing mask spec
   - Status: NOT DEPLOYED
   - Cross-ref: target-audit #842 GAP "Intent Dispatcher not deployed"
   - Severity: P1 (architectural gap)

3. **G-GUARDIAN-WEBHOOK-MISSING** — GitHub App id 15368 webhook → evo1:8195/8196 not delivering checkruns
   - Severity: P1 (CTIO owner)
   - Impact: Guardian cannot receive GitHub checkrun events; automated PR gates inoperative

**Scope changes:**
- File modified: `docs/agent-engine-dossier/VERIFIED-RUNTIME-SNAPSHOT.md`
- New section appended: "Runtime addendum (A-003 audit)"
- Zero duplication of existing ports/services (snapshot v2 ports already documented: 8094/8195/8196/4000/9000/5678/8180/5001/5002/3000)
- All content sourced from verified live shell observation, not invented

**Validation:**
- No conflict markers
- OpenClaw 4 instances confirmed with ports
- G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY gap documented
- ADR-049 dispatcher-spec cross-ref documented
- G-GUARDIAN-WEBHOOK-MISSING (App 15368) documented
- Gaps summary table (3 rows) present
- ADR-144 orphan-check: 0 orphans

**Refs:** A-003 corpus fragment (live shell), target-audit #842, ADR-049, ADR-144 orphan-check, ADR-143-A IL allocator.

---

## Amendment A2 (2026-06-28)

Added runtime addendum (A2 audit) section to `VERIFIED-RUNTIME-SNAPSHOT.md`:

**New A2 content:**
1. **Hyperswitch :8096/:8098** (ADR-015/140) + Jube-PG :15432 + Jube-Redis :16379
2. **OpenClaw MoA :18789** = 10 agents (`.claude/agents/openclo.md`, GMKtec); MoA pattern documented
3. **Model alias resolution** (LiteLLM cards):
   - `project-reason` → qwen3-235b-a22b Q3_K_S evo2:8082
   - `factory-mid` → qwen3-30b-a3b MoE LB :11434 (evo1+evo2)
   - `reasoning` = legacy alias → `project-reason`

**Validation (A2):**
- File: `docs/agent-engine-dossier/VERIFIED-RUNTIME-SNAPSHOT.md`
- Line count: 241 → 301 (+60 lines)
- Hyperswitch + Jube infra: CONFIRMED
- OpenClaw MoA = 10 agents: CONFIRMED
- Alias resolution table: CONFIRMED
- passport = 70: PRESERVED (not changed)
- A-003 content NOT duplicated in A2 section: CONFIRMED
- No conflict markers: CONFIRMED
- ADR-144: 0 orphans (pending ledger rebuild)

**Refs:** A2 audit corpus fragment (F/R/G), GMKtec `.claude/agents/openclo.md`, model-cards/, ADR-015, ADR-140, ADR-144 orphan-check.
