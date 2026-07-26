# Feature Evaluation — Kimi Code CLI / K3 (2026-07-20)

- Factory value: LOW — orchestration overlap (subagents, MCP, shell-approval) не перевешивает
  ранее зафиксированный риск Kimi K2 (UK GDPR Art.44 cross-border transfer, disabled in config).
- Banksy / project value: LOW — для EMI BANXE AI BANK любая работа через /login к hosted
  backend несёт тот же Art.44 риск для продукта, как и для фабрики.
- Placement: REJECT — оба значения LOW, причина REJECT = compliance risk (не misfit/duplication).
- Acceptance: REJECT — K2-предыдущий GDPR Art.44 finding остаётся решающим фактором; ничто
  из данных по K3/CLI не показывает, что cross-border путь больше не актуален.


## Operator sandbox note (2026-07-20)

- Operator explicitly authorises personal sandbox use of Kimi Code CLI / K3
  on a closed dev environment, separate from the Software Factory and EMI
  BANXE AI BANK production stack.
- This note does NOT override the REJECT placement for factory/project use:
  Kimi remains non-installed and non-used in the canonical factory stack and
  EMI BANXE product until a new, explicit compliance reassessment (UK GDPR
  Art.44 / cross-border transfer) is completed and ACCEPT is recorded.
- Sandbox usage must avoid real customer / EMI BANXE production data; it is
  limited to code, configs and synthetic/anonymised examples.

