# Safeguard-Safe Phrasing — defender-voice discipline (ALWAYS LOADED)
# Source: operator instruction 2026-08-06 (after a Fable 5 safeguards false-positive)
# Status: CANON | Scope: all Banxe writing — prompts, ADRs, commit messages, PR bodies, runbooks

## Why this exists

Fable 5 ships with intentionally broad model-side safeguards (dual-use classifiers).
They cannot be disabled by us and we do NOT attempt to evade them. But they pattern-match
words, not intent — and compliance engineering legitimately discusses sanctions, bypass
prevention, secrets and adversarial testing. Attack-framed shorthand in our own texts
triggers false positives and drops the session to a fallback model mid-tact.

The fix is NOT weaker meaning — it is **defender-voice phrasing**: say what we protect,
not what an attacker does. Meaning stays identical; framing states the defensive intent
explicitly instead of leaving it implied.

## Rules

1. **Defender-voice first.** Name the control, not the attack. The protected asset and
   the enforcement mechanism lead the sentence; adversary actions appear only as the
   thing being prevented, tested, or rejected.
2. **Never write attack-framed shorthand when a defensive phrasing carries the same
   meaning.** Reference table:

| Вместо (триггерное) | Пишем (то же значение, defender-voice) |
|---|---|
| «обход санкционной проверки» | «предотвращение обхода санкционного контроля», «anti-bypass инвариант санкционного пути» |
| «память может выучить обход» | «не допустить выученных исключений в санкционном контроле» |
| «kill switch» | «human override / аварийная остановка агента» |
| «атака», «эксплойт» (в бытовом смысле) | «негативный тест», «adversarial-проверка», «сценарий отказа» |
| «утечка секретов» (как сценарий) | «контроль неразглашения секретов», «секреты не покидают vault-канал» |
| «сломать/обойти гейт» | «подтвердить fail-closed поведение гейта» |
| «отравление памяти/модели» | «валидация целостности памяти/модели перед использованием» |

3. **Adversarial-тесты описываются как проверки контроля**: «held-out проверка, что
   кандидат НЕ ослабляет I-01..I-04», а не «пробуем обойти I-01..I-04».
4. **This rule changes wording only.** It never weakens, hides, or renames an actual
   control, and it is not a technique for slipping disallowed content past safeguards —
   drafting genuinely harmful content remains forbidden regardless of phrasing.
5. **Fable-5 persona is role-defined, not model-instance-defined.** If the harness
   falls back to another model on a flagged turn, the advisory/consultation remains
   valid (ADR-181 unaffected); note the fallback in the response if relevant, continue
   the tact, and consider `/feedback` for the false positive.

## Refs

ADR-181 (second-opinion protocol), .claude/rules/fable5-second-opinion.md,
INVARIANTS I-01..I-04 (the controls this phrasing describes),
https://www.anthropic.com/news/claude-fable-5-mythos-5 (safeguards context).
