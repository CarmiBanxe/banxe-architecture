# LiteLLM Shadow-Tap Activation Patch (READY, not applied)

Document ID: RUNBOOK-LITELLM-SHADOW-TAP-2026-05-12
Status: PREPARED — apply only when Condition D is live
Owner: Sub-terminal A (autonomous per Clause 17)

## Purpose
Captures the exact config patch that activates a shadow-mode
classifier tap in canonical LiteLLM on Legion (127.0.0.1:8080)
using pre-staged qwen2.5:0.5b on evo2 (Tailscale 100.99.208.21:11434,
HITL-ASK-2026-05-12-001).

Patch NOT applied. Application requires:
1. Condition D (HITL audit sink) live in ClickHouse per PR #225.
2. Conditions B+C drafts converted to operator activations.
3. Fresh Clause 17 conflict check at apply time.
4. Self-fixed HITL-ASK-<next-NNN>.

## Patch — model_list entry
- model_name: classifier-qwen2.5-0.5b
  litellm_params:
    model: ollama/qwen2.5:0.5b
    api_base: http://100.99.208.21:11434
    timeout: 10

## Patch — litellm_settings shadow tap hook
litellm_settings:
  callbacks:
    - litellm.callbacks.SuccessCallback
  success_callback:
    - shadow_classifier_tap

## Hook stub (conceptual; final form needs Condition D contract)
async def shadow_classifier_tap(kwargs, response, start, end):
    if response is None: return
    prompt_hash = sha256(kwargs.get("messages", [])).hexdigest()
    classifier_resp = await call_classifier(
        endpoint="http://100.99.208.21:11434/api/generate",
        model="qwen2.5:0.5b",
        prompt=sanitize(kwargs["messages"]),
        timeout=0.1,
    )
    if classifier_resp:
        await write_clickhouse_row(
            table="banxe_audit.hitl_decisions",
            row={
                "ts": now_utc(),
                "decision_id": uuid4(),
                "level": "L0",
                "action": "shadow_classify",
                "prompt_hash": prompt_hash,
                "classifier_out": classifier_resp,
                "outcome": "approve",
            },
        )

## Apply procedure (when Condition D live)
1. Conflict check (Clause 17.2)
2. Backup ~/litellm-config.yaml
3. Apply patch
4. Validate YAML
5. systemctl --user restart litellm
6. Smoke test: non-regulated prompt; shadow row appears in ClickHouse <5s
7. Self-fix new HITL-ASK with pre/post state

## Rollback (one-liner)
cp ~/litellm-config.yaml.bak-shadow-tap-pre ~/litellm-config.yaml
systemctl --user restart litellm

## Hard constraints
- Classifier tap NEVER alters routing decisions.
- Classifier tap NEVER receives regulated keyword prompts.
- Tap timeout 100ms; classifier failure does NOT block user response.
- All taps generate audit rows; missing row = silent bypass = halt.
