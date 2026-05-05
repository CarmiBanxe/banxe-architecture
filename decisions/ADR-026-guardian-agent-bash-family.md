# ADR-026: Guardian Third Family — agent.bash

- **Status:** ACCEPTED
- **Date:** 2026-05-05
- **Authors:** Moriel Carmi (operator), Comet/Claude (agent draft)
- **Supersedes:** —
- **Superseded by:** —
- **Related:** ADR-019 (Guardian two-family), ADR-025 (Agent Interaction Canon)

## Context

ADR-019 определяет двухсемейную модель Guardian: `factory` (build-time governance) и `project` (runtime compliance). При реализации G-GUARD-01 (V-01) обнаружено, что bash-команды AI-агентов не вписываются ни в одну из двух семей:

- `factory` — проверяет CI/CD pipelines, factory-guard.yml, baseline файлы. Субъект: PR/commit.
- `project` — проверяет invariants, deny-paths, sprint-scope, payment flows. Субъект: diff/branch.
- **agent.bash** (NEW) — проверяет runtime bash-команды AI-агентов на соответствие канону §8/§10/§6. Субъект: prompt (одна bash-команда).

Попытка маршрутизировать agent bash через scope="project" приводит к семантическому конфликту: ProjectRules ожидает diff/branch context, а shim отправляет prompt (текст одной команды).

## Decision

Расширить Guardian тремя scope-семьями: `factory`, `project`, `agent.bash`. Третья family обслуживается `ClaudeBashRules` (реализация: commit d122a61 в CarmiBanxe/MetaClaw).

## Rules (agent.bash family)

| Rule ID | Canon § | Verdict | Описание |
|---------|---------|---------|----------|
| CB1-deny-path | §10 | BLOCK | ADR-031 deny-paths в аргументах команды |
| CB2-secret-leak | §8 | BLOCK | cat .env, printenv, base64 *.pem |
| CB3-frozen-sandbox | §6 | WARN | Операции в /data/banxe-emi-stack (frozen) |
| CB4-dangerous-cmd | — | BLOCK | rm -rf /, git push --force, DROP TABLE |

## Scope routing (auditor.py)

```python
if scope == "factory":
    verdict = self._aggregate("factory", self.factory.evaluate_all(ctx, memory))
elif scope == "project":
    verdict = self._aggregate("project", self.project.evaluate_all(ctx, memory))
elif scope == "claude.bash":
    verdict = self._aggregate("claude.bash", self.claude_bash.evaluate_all(ctx, memory))
else:
    return AuditOutcome(result="unknown", ...)
```

## Shim configuration

Guardian-shim (banxe-emi-stack/infra/guardian-shim/) POST'ит с scope: `claude.bash` (уже в production с 2026-05-04).

## Consequences

### Positive

- Semantic clarity: agent commands don't pollute project/factory rule namespaces.
- Extensible: future rules (§1 OCAT bash-level heuristics, §5 length) добавляются в ClaudeBashRules.
- ADR-019 design intact: two original families unchanged.

### Negative

- Third family добавляет maintenance surface.
- Memory loader на evo1 должен видеть banxe-architecture clone (закрыто: /home/banxe/banxe-architecture/ + cron pull).

## References

- ADR-019: Guardian two-family design.
- ADR-025: Agent Interaction Canon (canonical behavioral contract).
- Implementation: CarmiBanxe/MetaClaw commit d122a61.
- Tests: guardian/tests/test_claude_bash_rules.py (13 cases).
- Deploy: systemd banxe-guardian-factory.service on evo1.
