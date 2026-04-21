# Cycle 012 — Scope

## Allowed Operations

Создание трёх файлов в manufacturing-cycles/cycle-012-execution-protocol-formalization/ — manifest.md, scope.md, outcomes.md. Создание четырёх amendment-файлов в constitution/amendments/ — amendment-B.11.N+2-execution-protocol-formalization.md, amendment-B.11.N-claude-code-execution.md, amendment-30.N+1-supplement-extensions.md, amendment-B.11.N+1-supplement-promotion-gates.md. Append четырёх тематических записей IL-CYCLE-012-EXEC-PROTOCOL, IL-CYCLE-012-AMEND-B.11.N, IL-CYCLE-012-AMEND-30.N+1, IL-CYCLE-012-AMEND-B.11.N+1 в INSTRUCTION-LEDGER.md. Append итоговой записи IL-CYC012-01 в INSTRUCTION-LEDGER.md при закрытии цикла. Обновление manifest.md и outcomes.md cycle-012 для фиксации статусов и результатов. Commits с сообщениями формата «cycle-012: <действие>». Push в origin/main после локальной валидации Auditor PASS.

## Prohibited Operations

Git tag без отдельной санкции на конкретную операцию. GitHub Release через gh CLI без отдельной санкции. Делегирование любых операций записи Perplexity Assistant. Модификация ранее размещённых amendments, включая amendment-30.N-perplexity-relay-protocol.md из cycle-011. Модификация артефактов завершённых циклов, включая директорию manufacturing-cycles/cycle-011-constitutional-materialization/. Модификация root CLAUDE.md. Использование ключа --amend на коммиты других авторов. Commit через --no-verify (обход Spec-First Auditor). Push без предварительной локальной валидации Auditor PASS. Создание сопутствующих файлов в cycle-012 за пределами трёх канонических (manifest, scope, outcomes). Использование Copilot-префиксов в commit-messages.

## Rollback Conditions

Auditor FAIL на любом commit — немедленный halt операции, диагностика причины, повторная итерация только после устранения нарушений. Обнаружение расхождения текста amendment с эталоном v3-пакета при cat-валидации перед git add — halt до сверки. Обнаружение неавторизованного tag, release или ledger edit в любой момент цикла — немедленный rollback по паттерну Фазы 1 cycle-011. Санкция владельца на rollback — безусловное прекращение цикла с закрытием статусом CLOSED-WITH-DEVIATIONS и документированием в outcomes.md.
