# Sprint 5 — Tax Agent Autonomy — ADR DRAFT

Status: DRAFT ADR (номер НЕ выделен — allocation при ратификации, во избежание коллизий) / NOT FOR MERGE

## Context
`TaxComplianceAgent` (стек Odoo/ERPNext, accounting-swarm; human double: Tax Manager, SMF2-линия) числится в register **#1 (Tax, AMBER)** с нерешённой ратификацией уровня автономии. Внешнего правила, прямо решающего L2 vs L3 для propose-only tax-агента, не найдено — классификация является внутренним governance-вопросом. Существующий образец непередаваемого human-submit: **H-010** (FCA RegData — CFO лично кликает submit).

## Decision (предлагаемое)
**TaxComplianceAgent = L2 propose-only, human-submit**: агент готовит расчёты/позиции/черновики филингов; НИКОГДА не подаёт самостоятельно; каждая налоговая подача исполняется человеком (Tax Manager, эскалация CFO) по паттерну H-010; каждый propose-акт эмитит lineage-запись (ADR-046) с evidence-цепочкой; изменение уровня автономии — только новым ADR.

## Forces
- За L2: propose-only + human-submit сохраняет человеческую ответственность за позиции; операционная скорость подготовки; симметрия с FIN060-контуром.
- За L3: налоговые позиции затрагивают внешние обязательства (HMRC) — консервативный аргумент к «человек решает каждый шаг».
- Балансир: L2 с обязательным human-submit функционально эквивалентен L3 на точке подачи — спор сводится к статусу промежуточных расчётов.

## Alternatives
(а) L3 полностью — отвергнуто предварительно: дублирует human-submit, замедляя подготовку без прироста контроля на точке подачи; (б) L1 auto — отвергнуто: недопустимо для внешних обязательств.

## Register linkage
- Area **#1 (Tax)** — AMBER; этот draft = evidence-кандидат для AMBER→GREEN **после** (i) ратификации ADR оператором/Board и (ii) counsel-ответа по §Open questions. Свет этим документом не меняется.

## Room linkage
- `bank-rooms/F2-ledger-room/README.md` (Sprint 5 subsection).

## Open questions (tax legal — counsel only)
- Существует ли HMRC/professional-standards требование advisor sign-off, делающее внешнюю валидацию обязательной поверх human-submit?
- Меняет ли автоматизированная подготовка позиций распределение ответственности Tax Manager vs SMF2?
- Требуются ли отдельные режимы для разных типов филингов (VAT vs CT vs информационные)?

## See also
- `sprint-5-regdata-cycle-runbook.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`
