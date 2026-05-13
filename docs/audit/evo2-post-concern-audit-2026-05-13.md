# evo2 Full State Audit — 2026-05-13 16:46 CEST

Document ID: AUDIT-EVO2-POST-CONCERN-2026-05-13
Trigger: operator concern that evo2 was physically powered off (would imply model loss)
Status: NO INCIDENT DETECTED

## OS-level evidence
- Hostname: banxe-NucBox-EVO-X2-2
- Uptime: 4 days 16 hours (no recent reboot)
- Load: 1.05 (normal)
- Date: 2026-05-13 14:46 UTC

## Ollama state
- Service: active since 2026-05-11 (PID 24211, no crash)
- Models on disk: 11 (matches PR #217 baseline plus qwen2.5:0.5b from PR #234)
- qwen2.5:0.5b digest a8b0c5157701 — preserved
- qwen3:235b-a22b digest 754a872f1290 — preserved
- qwen3:235b-a22b-banxe digest 3161844859cd — preserved
- 8 shared models digests match baseline
- Loaded into VRAM right now: 0 (cold, as expected for sandbox shadow mode)

## llama-server :8082
- Process active since 2026-05-09 (PID 2122)
- Model: /data/models/qwen3-235b-Q3_K_S.gguf, --n-gpu-layers 40
- Reachable from Legion via 100.99.208.21:8082

## Disk + RAM
- /var/lib/ollama: 429 GB used / 1.4 TB free
- RAM: 80 GB available out of 128 GB

## Network
- Tailscale 100.99.208.21: reachable from Legion, RTT 1.9 ms
- /api/tags returns all 11 models via Tailscale

## Sandbox shadow tap (Legion side)
- litellm.service: active
- clickhouse-tunnel.service: active
- banxe_audit.hitl_decisions: 5 rows (growing from production traffic)

## Decision
No incident. No model loss. No service crash. No action required.
Operator concern was based on outdated mental model; this audit is the
authoritative current state.

## Hard rules going forward
- Re-run smoke harness (tools/sandbox/smoke-pilot-readiness-2026-05-12.sh)
  any time operator suspects state drift; takes <30s, no mutations.
- Disk and audit sink row count are monitored via /api/ps + ClickHouse
  count queries; both inside Sub-A authority for read-only checks.

Refs: PR #192, #217, #234, #243, #256, #265, SESSION-CANON Clauses 1..17
