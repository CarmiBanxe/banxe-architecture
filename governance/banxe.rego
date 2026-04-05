# banxe.rego — OPA (Open Policy Agent) pilot rules for BANXE
#
# Status:    PILOT SPEC — не задеплоен (G-14, G-19)
# Sprint:    3 (критические правила), 4 (полная реализация)
# Связь:     FINOS AIGF v2.0, INVARIANTS.md I-21/I-22/I-23/I-25
# Деплой:    OPA sidecar к banxe_aml_orchestrator.py
#
# Input structure (от каждого агентного вызова):
#   input.agent_level    : int     (0=MLRO, 1=Orchestrator, 2=L2-agent, 3=Feedback)
#   input.agent_id       : string  ("kyc_agent", "sanctions_agent", ...)
#   input.action         : string  ("write_file", "submit_sar", "reject_transaction", ...)
#   input.target_path    : string  (filesystem path, если action=write_file)
#   input.mlro_approved  : bool    (для SAR и high-risk actions)
#   input.amount         : float   (для транзакционных решений, GBP)
#   input.explanation_bundle_present : bool
#
# Каждый deny → audit log event в Decision Event Log (I-24)

package banxe.compliance

import future.keywords.if
import future.keywords.in

# ── Rule 1: Level 2 агент не пишет в policy layer (Invariant I-22) ────────────

deny contains msg if {
    input.agent_level == 2
    input.action == "write_file"
    startswith(input.target_path, "developer-core/compliance/")
    msg := sprintf(
        "BLOCKED [I-22]: Agent '%v' (level 2) cannot write to policy layer. Path: %v",
        [input.agent_id, input.target_path],
    )
}

deny contains msg if {
    input.agent_level in {2, 3}
    input.action == "write_file"
    path := input.target_path
    path_in_soul := [
        contains(path, "SOUL.md"),
        contains(path, "AGENTS.md"),
        contains(path, "IDENTITY.md"),
        contains(path, "BOOTSTRAP.md"),
    ]
    path_in_soul[_] == true
    msg := sprintf(
        "BLOCKED [I-21]: Agent '%v' (level %v) cannot write to behavioral identity docs. Path: %v",
        [input.agent_id, input.agent_level, input.target_path],
    )
}

# ── Rule 2: SAR submission requires MLRO approval ─────────────────────────────

deny contains msg if {
    input.action == "submit_sar"
    not input.mlro_approved == true
    msg := "BLOCKED: SAR submission requires MLRO approval (mlro_approved must be true)"
}

# ── Rule 3: Decisions > £10,000 require ExplanationBundle (Invariant I-25) ───

deny contains msg if {
    input.action in {"reject_transaction", "hold_transaction", "file_sar"}
    input.amount > 10000
    not input.explanation_bundle_present == true
    msg := sprintf(
        "BLOCKED [I-25]: Decisions on transactions above £10,000 require ExplanationBundle. Amount: £%v",
        [input.amount],
    )
}

# ── Rule 4: Emergency stop must be checked before any automated decision ──────
# (Invariant I-23)

deny contains msg if {
    input.action in {"approve_transaction", "reject_transaction", "hold_transaction"}
    input.emergency_stop_checked != true
    msg := "BLOCKED [I-23]: Emergency stop state must be verified before any automated decision"
}

# ── Rule 5: Level 3 (Feedback Agent) cannot push to developer-core ───────────

deny contains msg if {
    input.agent_level == 3
    input.action == "git_push"
    contains(input.target_repo, "developer-core")
    msg := sprintf(
        "BLOCKED [I-21]: Feedback Agent cannot push directly to developer-core. Use PR + Level 0 approval. Agent: %v",
        [input.agent_id],
    )
}

# ── Helper: allowed actions for each level ────────────────────────────────────

allowed_actions := {
    0: {"*"},  # MLRO: all actions
    1: {"route", "emit_decision", "read_policy", "escalate"},
    2: {"read_external", "write_output", "call_api"},
    3: {"read_corpus", "propose_patch"},
}

# ── Default: allow if not explicitly denied ───────────────────────────────────

default allow := false

allow if {
    count(deny) == 0
}
