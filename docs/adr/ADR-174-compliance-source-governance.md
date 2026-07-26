# ADR-174: Compliance source governance — иерархия источников, risk weighting, evidence usage

**Status:** Proposed (DRAFT / NOT FOR MERGE — ратификация MLRO + оператор)
**Date:** 2026-07-18
**Numbering note:** номер выделен локально (следующий после ADR-173); Central подтверждает при merge.
**Scope:** только clearnet/official sources и regulator anchor; источники вне этого периметра — **explicitly out of scope** до отдельного решения MLRO/Board.

## Context

Compliance-стек банка объединяет open-source OSINT (OpenSanctions/yente, Watchman, corporate registers, adverse media/courts) и коммерческий anchor (LexisNexis, minimal contract) для EDD high/critical. Без формальной иерархии источников, весов риска и правил использования evidence: (а) скрининг-результаты неаудируемы (какой источник дал сигнал и с каким весом), (б) SAR/EDD-решения не имеют объяснимой доказательной базы, (в) конфликтующие сигналы источников разрешаются ad-hoc.

## Decision

1. **Иерархия источников (source hierarchy):** Tier-A regulator/official (OFSI/UN/EU/UK sanctions lists via OpenSanctions, Companies House, FinCEN BOI) → Tier-B commercial anchor (LexisNexis, только EDD high/critical) → Tier-C open OSINT (GDELT, OCCRP Aleph, CourtListener). Блокирующие решения (auto-block HITL-003) — только на Tier-A. Tier-B/C — сигналы для scoring/EDD, не для автоблокировок.
2. **Risk weighting:** каждый источник получает вес в скоринге; веса — конфиг-as-data (не хардкод), изменение весов = операторский акт уровня AML_threshold_change (HITL-012, CRO+CEO).
3. **Evidence usage:** каждый compliance-сигнал в Decision Lineage (ADR-046) хранит `source_id`, tier, версию списка/датасета и timestamp — Audit Pack восстанавливает полную доказательную цепочку.
4. **AML Policy update:** политика ссылается на данную иерархию; MLRO — владелец периметра источников.

## Consequences

**Positive:** аудируемый скрининг; объяснимые EDD/SAR-решения; управляемое расширение источников. **Negative/costs:** ведение реестра версий датасетов; договорная работа по anchor (ED-14).

## Alternatives considered

(а) Единый плоский пул источников без tier'ов — отвергнуто: неразличимость regulator-grade и open-signal в аудите; (б) только коммерческий провайдер (World-Check-модель) — отвергнуто: vendor lock-in, противоречит open-source канону движка.
