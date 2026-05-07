# Customer Privacy Rights — v2 Base Specification

**Статус:** BASE SPEC
**Дата:** 2026-05-07
**Контекст:** BANXE.COM holding → TOMPAY LTD (FCA EMI) + NEURONEXT (CASP/VASP)
**Регуляторная основа:** GDPR (EU 2016/679), UK GDPR + DPA 2018, eIDAS 2.0 ARF, PSD2/PSR 2017, FCA Consumer Duty, AMLD6/AMLR, MiCA, DAC8

---

## 1. Purpose

Настоящий документ определяет базовый набор прав клиента на конфиденциальность персональных данных в периметре группы BANXE.COM, охватывающий оба юрлица:

- **TOMPAY LTD** — UK Authorised Electronic Money Institution (FCA), фиат-операции, KYC/AML, Safeguarding, платежи.
- **NEURONEXT** — CASP/VASP (MiCA, DAC8, FATF Travel Rule), криптоактивы, кастодирование.

Документ является точкой отсчёта (base spec) для всех последующих privacy-related спецификаций и ADR в рамках архитектуры BANXE.

---

## 2. Scope

### В периметре (in-scope)

| Контур | Охват |
|---|---|
| EMI (TOMPAY LTD) | KYC/KYB данные, транзакции, AML-кейсы, complaints, Safeguarding ledger, FCA reporting data |
| CASP (NEURONEXT) | KYC/KYB данные, wallet addresses, on-chain transaction data (attribution), DAC8 self-cert, Travel Rule fields |
| Holding (BANXE.COM) | Агрегированные KPI (Owner Control Agent), корпоративная аналитика — только non-PII агрегаты |

### Вне периметра (out-of-scope данного документа)

- Детальная спецификация криптографических privacy-технологий (Ghost Mode) — будет определена в отдельном follow-up PR.
- Внутренние HR/employee data privacy policies.
- Third-party vendor DPA registry (отдельный трек).

---

## 3. Customer Privacy Rights Baseline

Клиент BANXE (физическое или юридическое лицо, прошедшее KYC/KYB) обладает следующими правами в отношении своих персональных данных:

### 3.1 Right to Information (GDPR Art. 13–14)

- Клиент информируется о целях обработки, правовом основании, категориях данных, сроках хранения и получателях при onboarding и при каждом существенном изменении.
- Privacy notice доступен на портале BANXE.COM и в приложении.

### 3.2 Right of Access (GDPR Art. 15)

- Клиент вправе запросить копию всех персональных данных, обрабатываемых TOMPAY и/или NEURONEXT.
- Срок ответа: 30 календарных дней (UK GDPR / EU GDPR).
- Формат: машиночитаемый (JSON/CSV) или PDF по выбору клиента.

### 3.3 Right to Rectification (GDPR Art. 16)

- Клиент вправе потребовать исправления неточных персональных данных.
- Изменения, затрагивающие KYC/KYB-статус (имя, гражданство, адрес, бенефициарный владелец), инициируют KYC re-verification (ADR-028: `JURISDICTION_CHANGED`, `ROLE_CHANGED`, `BENEFICIAL_OWNER_CHANGED`).
- Rectification не применяется к данным, зафиксированным в regulatory reporting (FCA RegData, DAC8 XML CARF) после submission — эти записи immutable по требованию регулятора.

### 3.4 Right to Restriction of Processing (GDPR Art. 18)

- Клиент вправе потребовать ограничения обработки при оспаривании точности данных, при незаконной обработке, или когда данные более не нужны контроллеру, но требуются клиенту для юридических претензий.
- Ограничение не распространяется на обработку, обязательную по закону (AML monitoring, Safeguarding, regulatory reporting).

### 3.5 Right to Object (GDPR Art. 21)

- Клиент вправе возразить против обработки на основании legitimate interest.
- Возражение не применяется к обработке на основании legal obligation (AML/CFT, FCA, MiCA, DAC8) или contract performance (платёжные услуги).

---

## 4. Data Access and Export

### 4.1 Data Portability (GDPR Art. 20)

- Клиент вправе получить свои данные в структурированном, машиночитаемом формате и передать их другому контроллеру.
- Охват: данные, предоставленные клиентом (KYC-документы, contact info, preferences) и данные, сгенерированные на основании согласия или контракта.
- Исключения: данные, сгенерированные в ходе AML-анализа (risk scores, SAR narratives, internal flags) — не подлежат портабельности (legal obligation basis).

### 4.2 Export Format

| Тип данных | Формат |
|---|---|
| KYC profile | JSON |
| Transaction history | CSV |
| Complaints history | PDF |
| On-chain attribution data (NEURONEXT) | JSON (addresses, timestamps, amounts — без internal risk scores) |

---

## 5. Erasure Constraints (Right to Erasure — GDPR Art. 17)

Право на удаление ограничено обязательными сроками хранения:

| Категория данных | Минимальный срок хранения | Основание |
|---|---|---|
| KYC/KYB identity documents | 5 лет после закрытия отношений | MLR 2017 reg. 40 (UK); AMLD6 Art. 40 (EU) |
| Transaction records | 5 лет после исполнения | MLR 2017 reg. 40; PSD2 |
| SAR / STR narratives | 5 лет (или до закрытия расследования, если дольше) | POCA 2002; MLR 2017 |
| FCA RegData submissions | 6 лет | FCA SYSC 9.1 |
| DAC8 reporting data | 5 лет после reporting period | DAC8 Art. 8ab(12) |
| Safeguarding reconciliation records | 6 лет | FCA CASS 7 |
| Complaints (DISP) | 5 лет | FCA DISP 1.9 |

**Правило:** данные удаляются автоматически по истечении максимального применимого срока хранения, если отсутствуют активные legal holds или незавершённые расследования. До истечения срока — клиенту предоставляется право на restriction (§3.4), но не на erasure.

---

## 6. Support and Compliance Handling Flow

```
Клиент подаёт запрос (DSAR / rectification / erasure / restriction / objection)
    │
    ▼
Customer Operations: регистрация, идентификация клиента
    │
    ▼
DPO (Data Protection Officer): классификация запроса
    │
    ├─ Стандартный (access/portability/rectification) → 30 дней
    ├─ Erasure → проверка retention obligations → ответ с обоснованием
    ├─ Restriction / objection → оценка legal basis → ответ
    └─ Комплексный (cross-entity TOMPAY+NEURONEXT) → координация → 30 дней
         (расширение до 60 дней при обосновании, с уведомлением клиента)
    │
    ▼
MLRO consultation (если запрос затрагивает AML/SAR data — tipping-off prohibition)
    │
    ▼
Ответ клиенту
```

**Tipping-off rule:** если запрос на доступ/удаление касается данных, связанных с активным SAR или расследованием, DPO и MLRO координируют ответ так, чтобы не раскрыть факт расследования (POCA 2002 s.333A; MLR 2017 reg. 39A).

---

## 7. Links and Dependencies

| Артефакт | Связь |
|---|---|
| ADR-027 (Audit trail durability) | Retention records для DSAR responses хранятся в audit trail |
| ADR-028 (KYC re-verification triggers) | Rectification → re-verification flow |
| DAC8-блок | DAC8 reporting data retention (5 лет) |
| OSS-Sumsub-блок (Ballerine/Yente/Jube/Marble) | KYC/AML pipeline — источник данных для DSAR export |
| Owner Control Agent (ADR-063..069) | Агрегированные KPI — non-PII; не содержит клиентских ПД |
| INVARIANTS.md | I-45 (no PII via ClaudeInput), I-46 (approved AI-plane) |

---

## 8. Ghost Mode — Follow-Up (отдельный PR)

> **Примечание:** детальная спецификация криптографических privacy-технологий
> (Ghost Mode: ERC-5564 stealth addresses, BIP-352 silent payments, BIP-77 PayJoin,
> RAILGUN zk-SNARK, W3C VC + ZKP identity, Privacy Score) будет определена
> в отдельном follow-up PR на ветке `feature/ghost-mode-privacy-stack`.
>
> Настоящий документ является **обязательной зависимостью** (base spec) для Ghost Mode spec.
> ADR-резерв Ghost Mode: ADR-074, ADR-075, ADR-076.
>
> Ghost Mode не включён в данный документ и не реализован в данном PR.

---

## 10. Ghost Mode — Privacy Tech Stack (ссылка)

Детальная спецификация Ghost Mode зафиксирована отдельным feature-spec документом в той же ветке.

- **Документ:** `docs/privacy/ghost-mode-spec.md`
- **Ветка:** `feature/ghost-mode-privacy-stack`
- **Контур:** только BANXE Self-Custody (out-of-scope EMI)
- **ADR-резерв:** 074 (stealth + silent + VC), 075 (payjoin + privacy score + per-KYC limit), 076 (RAILGUN — PENDING LEGAL REVIEW)
- **Pending invariants:** I-54, I-55, I-56, I-57, I-58
- **Блокирующие milestones:** FCA CP26/13 (UK, ~09.2026), TFR Art. 37 (EU, 2026-06-30), ACPR (FR, отдельная юр-консультация)
- **Статус:** FEATURE SPEC / PLANNED — реализация после legal/regulatory gates

Ghost Mode не реализуется на EMI-стороне как клиентская фича; на стыке EMI ↔ Self-Custody действует полный AML EMI (CDD, sanctions screening, Travel Rule, DAC8, blockchain analytics).
