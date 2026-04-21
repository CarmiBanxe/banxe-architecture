# Cycle 012 — Execution Protocol Formalization

## Статус
OPEN

## Дата открытия
2026-04-22

## Предшествующий цикл
cycle-011-constitutional-materialization — CLOSED-WITH-DEVIATIONS (HEAD на коммите 13fcfe9 на момент открытия cycle-012)

## Scope

Цикл формализует исполнительный protocol для всех операций записи в banxe-architecture с жёсткими guardrails, выведенными из constitutional breach cycle-011 (неавторизованные git tag и GitHub Release через Perplexity, коллизионная запись IL-002, отчёт о полном завершении при фактическом размещении одного amendment из четырёх). В объём работы входит размещение четырёх amendments в constitution/amendments/: amendment-B.11.N+2-execution-protocol-formalization.md как самостоятельный артефакт cycle-012, а также три оставшихся amendment из v3-пакета cycle-011 — amendment-B.11.N-claude-code-execution.md, amendment-30.N+1-supplement-extensions.md, amendment-B.11.N+1-supplement-promotion-gates.md, — чьё размещение было отложено при закрытии cycle-011 с deviation.

## Директивы

### IL-CYCLE-012-EXEC-PROTOCOL
Формализация execution-protocol через размещение amendment-B.11.N+2-execution-protocol-formalization.md в constitution/amendments/. Текст amendment формируется в cycle-012 от нуля на основе правил, зафиксированных в outcomes.md cycle-011 и Секциях три и семь TRANSFER_PACKAGE_cycle-012_open.md. Статус: OPEN.

### IL-CYCLE-012-AMEND-B.11.N
Размещение amendment-B.11.N-claude-code-execution.md в constitution/amendments/ по тексту из артефакта cycle-011_perplexity_directives_v3.md. Статус: BLOCKED-AWAITING-MATERIAL.

### IL-CYCLE-012-AMEND-30.N+1
Размещение amendment-30.N+1-supplement-extensions.md в constitution/amendments/ по тексту из артефакта cycle-011_perplexity_directives_v3.md. Статус: BLOCKED-AWAITING-MATERIAL.

### IL-CYCLE-012-AMEND-B.11.N+1
Размещение amendment-B.11.N+1-supplement-promotion-gates.md в constitution/amendments/ по тексту из артефакта cycle-011_perplexity_directives_v3.md. Статус: BLOCKED-AWAITING-MATERIAL.

## Исполнительная модель

Shell-based исполнение через git CLI и gh CLI на рабочей станции Mark-Legion под per-block санкцию владельца. Perplexity Assistant исключён из цепочки на время cycle-012 — ни read-only диагностика, ни операции записи через Perplexity не делегируются. Все commits проходят через pre-commit Spec-First Auditor; PASS по всем блокам обязателен. Commit-messages формируются без Copilot-префиксов. Git tag и GitHub Release запрещены в рамках cycle-012 без отдельной санкции.
