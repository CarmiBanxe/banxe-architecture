# Feature Evaluation — OpenShip + Kimi CLI / K3 + apple-design SKILL (2026-07-21)

## Operator decision context

- Operator has issued an explicit ACCEPT order for using Kimi CLI / K3
  and related tooling, subject to factory/bank canon.
- This evaluation records the combined feature set:
  - OpenShip (self-hosted deployment platform with MCP support),
  - Kimi CLI / K3 (terminal coding agent with MCP/ACP, subagents, video input),
  - apple-design SKILL (Apple WWDC-inspired design principles with code examples).

## Audit summary (high-level)

- OpenShip: source-available, self-hostable deployment platform; candidate for
  factory ADR as an alternative to cloud PaaS (Vercel/AWS) under bank infra control.
- Kimi CLI / K3: open-source terminal agent backed by hosted Kimi models; powerful
  for coding and MCP/ACP workflows, but requires explicit data-handling guardrails
  under GDPR / AI Act for bank/factory use.
- apple-design SKILL: design-only skill; low data risk, suitable for Banksy UI
  as a recommended design standard.
