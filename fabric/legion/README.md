# fabric/legion — Legion execution-node code (ADR-104 §3)

Code that runs on the **Legion** node — the fabric's **only execution gate** per ADR-104.
Authored server-side via the factory (ADR-103) and promoted here so it can be **deployed to
Legion** (the evo1/evo2 node code lives on its own host under `~/banxe-fabric/`).

## `gate_exec.py` — the execution gate (DRY-RUN by default)

- Accepts a proposed action + an evo1 `gate.policy` verdict (+ optional HITL confirmation)
  and decides whether it **would** execute. **`execute_enabled` defaults to `false`** →
  it logs `WOULD EXECUTE: …` and runs **nothing**.
- **fail-closed REFUSE** when: no valid policy verdict, `correlation_id` missing/invalid or
  mismatched, verdict not `allowed`/`compliant`, or `requires_hitl` without confirmation.
- **Real execution is F1.5** (HITL-activated) and is intentionally **not implemented** —
  even with `execute_enabled=true` this module refuses to run a real action (defense in depth).
- Self-contained stdlib (zero deps); the canonical `correlation_id` format lives in evo1
  `fabric_common` and is validated here, not imported (cross-node, no shared FS — §4).

## OPERATOR ACTION — activation (NOT done by the factory)

1. Deploy `gate_exec.py` to the Legion execution node and run it as the `gate.exec` receiver.
2. Wire `gate.exec` to the shared bus (Redis streams — needs `REDIS_PASS`, operator-gated).
3. Flipping `execute_enabled=true` + implementing the real executor = **F1.5**, HITL-gated.

Until F1.5, this is **decision/dry-run only** — it executes no production action.
