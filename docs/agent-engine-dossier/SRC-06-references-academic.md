# SRC-06 — Академические ссылки и внешние источники

**Статус:** INGESTED
**Загружен:** 2026-06-28
**Источник:** Часть аналитического корпуса, передана оператором

---

## Содержание

[ФАКТ] В корпусе упомянуты следующие академические источники (авторы):
- Yao et al. — предположительно ReAct paper
- Schick et al. — предположительно toolformer / tool-use
- Liu et al. — [НЕИЗВЕСТНО] конкретная работа без shell-верификации
- Li et al. — [НЕИЗВЕСТНО] конкретная работа без shell-верификации
- Wei et al. — предположительно Chain-of-Thought paper
- Hong et al. — [НЕИЗВЕСТНО] конкретная работа без shell-верификации

[НЕИЗВЕСТНО] Точные arxiv-идентификаторы и полные названия работ — не включены в переданный корпус без детального указания.

[ФАКТ] Упомянут AMLSim — размещён локально на Legion по пути /home/mmber/AMLSim.

[ФАКТ] Упомянуты технические блоги: Temporal, LangGraph, AutoGen.

[ВЫВОД] Академические источники подтверждают теоретическую обоснованность паттернов (SRC-02), но требуют дополнительной верификации точных ссылок перед включением в официальную документацию.

---

## Cross-references

- SRC-02 (theory principles) — теория, опирающаяся на эти источники
- ADR-043 (Aider integration) — engineering-источник для агентного tooling
- VERIFIED-RUNTIME-SNAPSHOT.md — AMLSim на Legion

---

## Pending

Точные arxiv-идентификаторы требуют уточнения от оператора.

---

## AMLSim — VERIFIED-LOCAL (добавлено 2026-06-28)

[ФАКТ] AMLSim git-репозиторий присутствует локально на Legion: `/home/mmber/AMLSim` (git repo).
Статус: **VERIFIED-LOCAL** — источник доступен для offline-анализа synthetic transaction data.

**Назначение (из SRC-06 §AMLSim):** генерация синтетических AML-транзакций для backtesting
и обучения fraud/AML-агентов без реальных ПД.

**Implikationen:** при разработке Sprint A (design contracts для AML-агентов) AMLSim
может быть использован как test-data generator. Внедрение в pipeline = Sprint B/infra-scope.
