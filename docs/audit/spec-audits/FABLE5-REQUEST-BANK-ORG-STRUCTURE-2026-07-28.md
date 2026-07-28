# Запрос к Fable-5 — эталонная орг-структура банка (для сравнения и коррекции)

**Выровнено по ADR-102** (references, no restate). Documentation/governance only; no PROD. PolyForm-NC (sandbox).

## Контекст
Готовим фундамент банка ПЕРЕД разнесением документации по «ячейкам». Иерархия-цель:
`i-agent (единица) → отдел (с начальником) → департамент → набор департаментов → директор банка (движок Banksy — организатор И контролёр)`, с ОБЯЗАТЕЛЬНЫМИ контурами доп-контроля и аудита.

## Наша текущая структура (ссылки, не рестейт — для сравнения Fable-5)
- `governance/CANONICAL-ORG-CHART-v2.md`
- `AGENT-ORG-STRUCTURE.md`, `docs/ORG-STRUCTURE.md`, `docs/DEPARTMENT-MAP.md`
- `docs/governance/AGENT-REGISTRY-MASTER-2026-07-22.md`
- `docs/governance/TERMINAL-OWNERSHIP.md`, `TERMINAL-OWNERSHIP-AND-ANTIDRIFT.md`
- `config/gitnexus/org-contour.schema.json` + `docs/canon/GITNEXUS-PHASE3-ORG-CONTOUR-VERDICT.md`

## Open-points к Fable-5 (не покрыты нашим каноном — просим ответ + коррекции)
1. Эталонная каноническая иерархия банка (agent→отдел→департамент→директор): какие уровни ОБЯЗАТЕЛЬНЫ, какие опциональны; правила формирования отделов/департаментов «по технологии/необходимости».
2. Минимальный обязательный набор департаментов для EMI-банка (FCA-контур): какой перечень Fable-5 считает каноническим?
3. Обязательные контуры доп-контроля/аудита: где именно в иерархии они сидят (3 линии защиты, независимый аудит, MLRO-линия), как связаны с директором Banksy.
4. Роль директора Banksy как одновременно организатора И контролёра — какие механизмы разделения (segregation of duties), чтобы контролёр не совпадал с исполнителем?
5. Где в нашей текущей структуре ПРОБЕЛЫ относительно эталона Fable-5 — просим список коррекций (что достроить ДО разнесения документации).
6. Как эталон Fable-5 ложится на GitNexus org-contour (`org-contour.schema.json`) — совместимо ли, что скорректировать?

## Что НЕ спрашиваем (покрыто каноном)
Terminal-ownership A/B/Central, anti-drift — уже в `TERMINAL-OWNERSHIP*`.

## Ограничения
Documentation/governance only; no PROD; PolyForm-NC (sandbox). GitNexus-объём допуска запрашивается у фабрики отдельно (инфраструктурный гейт).
