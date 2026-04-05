# ADR-006: EvidenceBundle — контракт доказательной базы

**Статус:** ПРИНЯТО  
**Дата:** 2026-04-05  
**Автор:** Moriel Carmi (CEO)

---

## Контекст

SAR-workflow и FCA аудит требуют evidence pack — набор артефактов (match results, источники данных, правовые основания), обосновывающих каждое AML-решение.

До EvidenceBundle каждый модуль хранил evidence по-своему:
- `sanctions_check.py` → строка в reason
- `tx_monitor.py` → список rules
- `crypto_aml.py` → flags в dict

Нет единого контракта → нет возможности автоматически собрать evidence pack для NCA SAR.

## Решение

`EvidenceBundle` как явный dataclass в `models.py`, включённый в `AMLResult`.

Каждый AML-модуль обязан заполнять `evidence: list[EvidenceBundle]` при генерации AML-решения.

```python
@dataclass
class EvidenceBundle:
    evidence_id: str          # UUID
    evidence_type: str        # "sanctions_match" | "tx_pattern" | "pep_hit" | ...
    source: str               # "watchman" | "jube" | "redis_velocity" | "pep_db"
    raw_payload: dict         # оригинальный ответ источника
    confidence: float = 1.0  # 0.0-1.0, для fuzzy matches
    match_score: float = 0.0 # score от источника
    authority: str = ""      # "SAMLA 2018", "FCA MLR 2017 §19"
```

## Последствия

- `tx_monitor.py`, `sanctions_check.py`, `crypto_aml.py` — обновить для генерации EvidenceBundle (отдельная задача, не блокирующая)
- `AMLResult.to_audit_dict()` включает `evidence_count`, `evidence_types`, `evidence_sources`
- ClickHouse `compliance_screenings` получит колонку `evidence_count` при следующем schema migration
- SAR generator (`sar_generator.py`) использует `EvidenceBundle` для автоматической сборки evidence pack

## Ссылки

- `vibe-coding/src/compliance/models.py` — реализация
- `INVARIANTS.md` I-20 (EvidenceBundle как shared contract)
- `COMPLIANCE-ARCH.md` — AMLResult
