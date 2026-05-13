# A-8 Regression Mitigation — 2026-05-13

Document ID: HITL-ASK-2026-05-13-001
Trigger: Full AI agent audit revealed litellm-v2.service running on 0.0.0.0:4000
Status: MITIGATED

## Discovery
During the full audit at 2026-05-13 16:59 CEST a second LiteLLM listener
was found on :4000 (PID 323) with --host 0.0.0.0. Initially flagged as
an A-8 regression from PR #200.

## Root cause
Not a regression: ~/.config/systemd/user/litellm-v2.service was created
after Sprint 2 as a deliberate "LiteLLM v2 LAN Gateway (port 4000)".
Unit was enabled via default.target.wants/ and auto-started on reboot.
Distinct from canonical litellm.service on 127.0.0.1:8080.

## Risk assessment
- Bind on 0.0.0.0 exposed :4000 on every interface (LAN + Tailscale).
- No POST /v1/chat/completions traffic; only idle GET /v1/models health
  pings from 127.0.0.1 every 5 minutes.
- No active external clients observed.
- Severity: MEDIUM (open port, no hot traffic, no confirmed exploit).

## Action taken (Sub-A Clause 17 autonomous, HITL-ASK-2026-05-13-001)
- Backup unit -> litellm-v2.service.bak-pre-a8-mitigation-2026-05-13
- sed -i s/--host 0.0.0.0/--host 127.0.0.1/ in unit ExecStart
- systemctl --user daemon-reload
- systemctl --user restart litellm-v2.service
- New PID 132935 active, listener now 127.0.0.1:4000 only
- External Tailscale interface 100.101.218.26:4000 confirmed BLOCKED
- No other listeners on :4000

## Acceptance
- ss -tlnp shows 127.0.0.1:4000 only
- curl http://100.101.218.26:4000 from Legion times out (correct)
- canonical litellm.service on 127.0.0.1:8080 untouched, still active
- shadow tap classifier still firing into banxe_audit.hitl_decisions

## Rollback
cp ~/.config/systemd/user/litellm-v2.service.bak-pre-a8-mitigation-2026-05-13 \\
   ~/.config/systemd/user/litellm-v2.service
systemctl --user daemon-reload && systemctl --user restart litellm-v2.service

## Hard rule going forward
- Any new LiteLLM gateway service on Legion MUST bind 127.0.0.1 only.
- LAN/Tailscale exposure requires a separate gateway with mTLS or token.

Refs: PR #200 (original A-8 closure), ADR-035, ADR-036,
SESSION-CANON Clauses 1..17
