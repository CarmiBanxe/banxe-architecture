---
title: "AMENDMENT 30.N: Perplexity Relay Protocol — Factory Plane"
parent_section: "DEVELOPERBLOCK.md, section 30.N positioned within §30, Factory processes and interfaces, near Manufacturing Cycle and cross-plane coordination subsections."
cycle: cycle-011-constitutional-materialization
amendment_id: "30.N"
amendment_version: v1
status: pending-integration
integration_rule: "Upon next major revision of DEVELOPERBLOCK.md, this amendment's content is integrated into the master file as section 30.N; this amendment file is then marked superseded and retained in history for audit."
---

# 30.N Perplexity Relay Protocol — Factory Plane

Данная секция дополняет Developer Block v5.1 описанием протокола взаимодействия с Perplexity Assistant. Секция 30.N вводится как новый раздел внутри §30, рядом с существующими подсекциями о Manufacturing Cycle и cross-plane coordination. Протокол определяет трёхуровневую архитектуру исполнения директив через Manufacturing Cycle.

---

## 30.N.1 Назначение

Perplexity Relay Protocol определяет, как conversational Claude — в роли ассистента, описанной Developer Block v5.1 — использует Perplexity Assistant для размещения, верификации и управления файлами в репозитории. Perplexity выполняет операции с файлами, навигацию по репозиторию и верификацию состояния, в то время как Claude Code выполняет runtime-операции: тесты, линтинг, сборку. Perplexity оперирует factory knowledge, manufacturing-cycles, factory agent contexts, factory templates и factory ADR. Perplexity не оперирует product-specific контекстом Project EMI v5.2.

## 30.N.2 Обязательные поля директивы

Каждая директива, передаваемая conversational Claude через Perplexity, должна содержать следующие семь обязательных полей. Директива без любого из полей отклоняется Perplexity без исполнения.

- **correlation_id** — уникальный идентификатор, привязанный к Manufacturing Cycle и IL-записи.
- **cycle_reference** — ссылка на cycle-NNN или указание out-of-cycle для одиночных операций.
- **target_files** — список файлов с указанием операции: create, update или delete.
- **expected_artifacts** — перечень ожидаемых результатов, включая файлы, коммиты и структуры.
- **acceptance_criteria** — проверяемые условия успешности, не допускающие субъективной интерпретации.
- **regulatory_anchor** — ссылка на применимое регуляторное требование, либо явное указание отсутствия compliance-измерения.
- **rollback_procedure** — процедура отката при обнаружении некорректности.

Perplexity проверяет полноту полей перед исполнением.

## 30.N.3 Проверки Perplexity перед исполнением

Perplexity Assistant выполняет четыре проверки перед исполнением любой директивы от Claude Code.

Первая проверка — наличие всех семи обязательных полей: подтверждается комплектность.

Вторая проверка — непротиворечивость: Perplexity сверяет директиву с текущим состоянием репозитория, включая CLAUDE.md, INSTRUCTION-LEDGER.md и cycle manifest.

Третья проверка — принадлежность путей: целевые файлы должны находиться в корректном плане (factory или product); файлы из docs или .claude относятся к product-плану.

Четвёртая проверка — factory-knowledge и .claude-factory: Perplexity сверяет наличие необходимых знаний в factory-knowledge слое.

Perplexity использует GitHub API для навигации и верификации; Claude Code execution instruction формируется только после прохождения всех проверок. Perplexity фиксирует результат каждой проверки в отчёте.

## 30.N.4 Протокол обратной связи

Perplexity формирует и возвращает отчёт после исполнения каждой директивы. Отчёт содержит: идентификатор директивы, список созданных или изменённых файлов с их git-хэшами, результаты каждого acceptance criterion с явной отметкой pass или fail, зафиксированные отклонения при наличии, рекомендацию о следующем шаге.

Отчёт сохраняется в cross-plane-messages/archive/ с привязкой к correlation_id для аудита conversational Claude. Conversational Claude использует отчёт для принятия решения о следующей директиве.

## 30.N.5 Декларация источника истины

Конституционный уровень — Developer Block v5.1: governance, methodology, архитектурные принципы, factory invariants. Операционный уровень — factory-knowledge и .claude-factory: контексты агентов, шаблоны, знания, sprint tasks.

Governance-правила конституционного уровня не могут быть переопределены operational-уровнем. При противоречии Perplexity и Claude Code следуют конституционному уровню, то есть Manufacturing Cycle scope и Developer Block v5.1.

Правила декларации:
- Perplexity не создаёт Manufacturing Cycle без IL-привязки.
- Perplexity не расширяет scope Manufacturing Cycle автономно.

## 30.N.6 Обработка ошибок

Perplexity обрабатывает ошибки исполнения, включая отказы GitHub API, конфликты версий и rate limit. При обнаружении ошибки Perplexity выполняет одну повторную попытку. При повторной неудаче операция помечается статусом blocked с указанием причины. Blocked-директива возвращается владельцу пула для принятия решения.

Perplexity не выполняет rollback автономно; процедура rollback описывается в отчёте, но исполняется только по явному указанию владельца.

## 30.N.7 Классификация директив относительно Manufacturing Cycle

Директивы классифицируются на два типа: требующие cycle-обёртки (structural changes) и одиночные (knowledge layers, factory agents, templates, methodology updates).

Structural changes — модификации, затрагивающие Manufacturing Cycle scope и timeline — требуют создания или привязки к существующему cycle. Perplexity проверяет наличие cycle manifest перед исполнением.

Одиночные директивы — обновления знаний, ADR, sprint plan, IL-записей — могут исполняться вне cycle-привязки при наличии корректного IL-идентификатора.

Conversational Claude определяет тип директивы. Perplexity верифицирует классификацию.

---

Конец секции 30.N.
