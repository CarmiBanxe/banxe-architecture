# Sprint 5 — RegData Cycle Runbook (FIN060 → CFO dry-run)

Status: DRAFT RUNBOOK / NOT FOR MERGE · **No automated submission; CFO-only in real cycle (H-010, non-delegable).**

## Purpose
Операционный цикл генерации FIN060 и CFO-ревью **без подачи в FCA** (dry-run). Реальная подача — вне этого runbook'а: CFO лично, через My FCA portal (manual upload, no API).

## Inputs
- Ledger-данные (Midaz через LedgerPort) · safeguarding recon результаты (daily) · dbt marts (`fin060_monthly`) · FX (Frankfurter) · период (месяц, UTC, cutoff 23:59:59).

## Steps / Roles / Timings
1. **T-7д до дедлайна** — `FIN060Generator` (`services/reporting/fin060_generator.py`) собирает драфт [агент, L3].
2. **T-6д** — `Reg Data Quality`-гейт (Great Expectations): валидация полноты/типов [агент, READ]; FAIL → шаг 1 с фиксацией причины.
3. **T-5д** — Head of Reg Reporting: содержательное ревью, сверка с safeguarding-recon трендом [человек].
4. **T-4д** — **CFO dry-run ревью**: построчный просмотр + подпись dry-run протокола [человек; HITL-010-класс, без submit].
5. **T-3д..0** — (вне runbook'а) реальный цикл: CFO лично подаёт; евиденс подачи → lineage/audit.
Каждый шаг эмитит lineage-запись (ADR-046) с общим correlation_id цикла.

## Outputs
FIN060-драфт (PDF/WeasyPrint) · quality-gate отчёт · dry-run протокол с CFO-подписью · lineage-трасса цикла.

## Failure modes
- Recon-расхождение в периоде → стоп цикла, эскалация CFO+MLRO (H-011-класс), FIN060 не финализируется до вердикта.
- Quality-gate FAIL повторно → эскалация Head of RegRep → CFO; фиксация root cause.
- Отсутствие CFO в окне → делегирование ЗАПРЕЩЕНО (H-010 non-delegable) → эскалация CEO для планирования окна.

## Register linkage
- Area **#1** (tax-смежный контур) и H-010-канон; свет не меняется; runbook = process-evidence.

## Room linkage
- `bank-rooms/F2-ledger-room/README.md`; исполнители — regrep-контур (Reporting/RegData/FIN060Generator).

## Open questions
- Точное дедлайн-расписание FCA-календаря на текущий период [Head of RegRep заполняет].
- Форма dry-run протокола (шаблон) — создать при первом прогоне.

## See also
- `sprint-5-tax-agent-autonomy-adr-draft.md` · Register: `../governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`
