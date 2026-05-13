# Factory → evo2 235B Routes Enabled — 2026-05-13

Document ID: HITL-ASK-2026-05-13-002
Trigger: operator question — why is factory not routing to evo2 235B?
Status: APPLIED + VERIFIED

## Gap discovered

Canon (`docs/canon/factory-project-stack-2026-05.md` + `docs/roadmap/audit-2026-05/A4-agents-orchestration-proposal.md`) declares:

- `project-reason` → evo2 qwen3:235b-master :8082 (Q3_K_S)
- `factory-heavy` → cluster heavy reasoning

But canonical LiteLLM (`~/litellm-config.yaml` on Legion :8080) had no
entry for either alias. Factory was using evo1+evo2 only for the small
`classifier-qwen2.5-0.5b` and load-balanced `default`/`banxe/operations`.
The 235B reasoning path declared in canon was wired in MetaClaw
`:4000` only, not in the canonical :8080 router.

## Fix (Sub-A autonomous per Clause 17)

### Backup created
- `~/litellm-config.yaml.bak-pre-235b-route-2026-05-13`
- `~/.config/litellm/.env.bak-pre-235b-route-2026-05-13`

### Env var added
- `Q235_API_KEY=sk-rpc-q235-2026` in `~/.config/litellm/.env` (chmod 600)
  This matches the `--api-key` argument of the running llama-server on
  evo2 :8082.

### model_list entries appended (3 aliases, same backend)
```yaml
- model_name: project-reason
  litellm_params:
    model: openai/qwen3-235b-Q3_K_S.gguf
    api_base: http://100.99.208.21:8082/v1
    api_key: os.environ/Q235_API_KEY
    timeout: 600
- model_name: factory-heavy
  litellm_params: (same backend)
- model_name: reasoning-235b
  litellm_params: (same backend)
```

### LiteLLM canonical restart
- systemctl --user restart litellm → active
- Application startup complete, listener 127.0.0.1:8080

## Verification (live)

| Endpoint | Result |
|---|---|
| POST /v1/chat/completions model=project-reason | 200, finish=stop, 83 completion tokens, reply='4' |
| POST direct llama-server :8082 (control) | 200, finish=stop, 125 tokens, reply='4' |

Smoke prompt: "Reply briefly: what is 2+2?"  → Model responds.

## Canon alignment

- `factory-project-stack-2026-05.md` §Orchestration: "heavy reasoning to evo2" ✅
- `A4-orchestration-proposal.md` §Factory plane orchestration: `project-reason → evo2 :8082` ✅
- F-02 placement: this is a factory-side gateway change, recorded in factory canon.

## Hard rules going forward

- 235B reasoning route MUST go through canonical LiteLLM :8080
  (single observable, audited, guardrail-passed surface).
- llama-server :8082 master_key MUST remain in env var (Q235_API_KEY),
  never inline in config.
- Any future change to `project-reason` / `factory-heavy` /
  `reasoning-235b` MUST cite this HITL-ASK and include rollback path.

## Rollback (one command if needed)

```bash
cp ~/litellm-config.yaml.bak-pre-235b-route-2026-05-13 ~/litellm-config.yaml && \
systemctl --user restart litellm
```

Refs: ADR-019, ADR-024, ADR-026, ADR-044 (AI Pool Roadmap),
docs/canon/factory-project-stack-2026-05.md,
docs/roadmap/audit-2026-05/A4-agents-orchestration-proposal.md,
PR #265 (shadow tap), PR #269 (A-8 mitigation), PR #271 (agent inventory),
SESSION-CANON Clauses 1..17.
