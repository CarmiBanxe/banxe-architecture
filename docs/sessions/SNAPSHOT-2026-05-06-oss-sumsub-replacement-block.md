# SNAPSHOT — Open-Source Sumsub Replacement Stack: KYC/KYB/AML/Travel-Rule (EMI BANXE Assessment + Ownership)

**Тип:** Roadmap Block  
**Дата:** 2026-05-06 (CEST)  
**Базовый чекпоинт:** `checkpoint-2026-05-06-dac8-tax-reporting-block`  
**Тег после merge:** `checkpoint-2026-05-06-oss-sumsub-replacement-block`  
**Статус:** inventory / organisational mapping — код в `banxe-emi-stack` в этом блоке не затрагивается

**Источник:** пользовательский markdown «Open-Source аналог Sumsub для проекта BANXE» (180+ источников)

**Цель документа:** зафиксировать инвентаризацию open-source-инструментов как замены / дополнения Sumsub в KYC/KYB/AML/Travel-Rule, с фильтром «применимо в EMI BANXE / требует CASP-MiFID / только internal use» и каноническим распределением ownership. Переход не «руинируем»: возможна гибридная схема Sumsub (текущий поставщик) ↔ внутренний OSS-стек, с поэтапной миграцией. Полное «выкатить и забыть» — out-of-scope для этого блока.

---

## 1. Регуляторный контекст

| Правовой слой | Документ | Привязка к стеку |
|---|---|---|
| **FCA EMI / MLR 2017** | FCA SYSC / ML-regs | KYC/AML onboarding, sanctions, SAR, periodic review — весь стек |
| **5AMLD / 6AMLD / AMLR** | Directive 2018/843 / 2018/1673 / AMLR (EU) | Sanctions/PEP screening (Yente/Watchman), TM (Jube), CDD (Ballerine) |
| **GDPR (EU) 2016/679** | Art. 6, Art. 9, Art. 32 | Биометрия → Art. 9 DPIA; all PII self-hosted; residency EU/EEA |
| **PSD2 / SCA** | Directive 2015/2366 + RTS on SCA | Ory Kratos/Hydra (SCA/OAuth2/OIDC), Ballerine Open Banking |
| **MiCA / CASP** | Reg. (EU) 2023/1114 | KYB для CASP-контрагентов, Travel Rule scope |
| **FATF Travel Rule / R.16** | FATF R.16; MiCA AML/CFT | TRP + Walt.id; Sumsub Travel Rule network (VASP-совместимость) |
| **DAC8** | Council Directive (EU) 2023/2226 | self-certification через Ballerine workflow; JURISDICTION_CHANGED → ADR-028 |

---

## 2. Карта 10 функциональных слоёв с фильтром EMI BANXE

### Слой 1 — KYC/KYB Orchestration

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| Onboarding workflow, step routing, retry, audit | **Ballerine** | `ballerine-io/ballerine` | MIT | YES | Self-hosted required; GDPR residency EU/EEA | `services/kyc/*`, customer lifecycle FSM (ADR-028), DAC8 self-cert flow |

### Слой 2 — Document OCR / Document Verification

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| OCR (text extraction) | **EasyOCR** | `JaidedAI/EasyOCR` | Apache 2.0 | YES | — | `services/kyc/document_verifier` |
| OCR fallback + server-side | **Tesseract** | `tesseract-ocr/tesseract` | Apache 2.0 | YES | — | `services/kyc/ocr_service` |
| ID document verification (face + MRZ + NFC) | **FaceOnLive OpenKYC** | `FaceOnLive/ID-Verification-OpenKYC` | Commercial/OSS | PARTIAL | DPA required if SaaS API used; self-hosted preferred | `services/kyc/document_verifier` |
| Document classification + extraction | **Doubango KYC SDK** | `DoubangoTelecom/KYC-Documents-Verif-SDK` | Apache 2.0 | YES | Self-hosted; GDPR Art. 32 encryption at rest | `services/kyc/doc_classifier` |
| MRZ parsing (passports/IDs) | **MRZ scanner / passportmrzextractor** | `alsenet-labs/mrz-scanner`, `Azim-Kenzh/passportmrzextractor` | MIT | YES | — | `services/kyc/mrz_parser` |

### Слой 3 — Biometrics / Liveness / NFC

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| Face recognition + similarity | **DeepFace** | `serengil/deepface` | MIT | YES + DPIA mandatory | Art. 9 GDPR (биометрика = special category); retention policy; right to erasure | `services/kyc/biometric_service/face_match` |
| Face recognition SDK | **Faceplugin SDK** | `Faceplugin-ltd/Open-Source-Face-Recognition-SDK` | Commercial/OSS | PARTIAL | Art. 9 GDPR + DPIA + DPA with vendor | `services/kyc/biometric_service` |
| Liveness detection | **FaceOnLive Liveness** | `FaceOnLive/Face-Liveness-Detection-SDK-Linux` | Commercial/OSS | PARTIAL | Art. 9 GDPR; DPIA; self-hosted mandatory | `services/kyc/biometric_service/liveness_check` |
| NFC ePassport reading | **NFCPassportReader** | `AndyQ/NFCPassportReader` | MIT | YES | iOS-only; GDPR Art. 32 (chip data encryption) | Mobile KYC flow (Expo) |
| NFC passport reader (Android) | **tananaev/passport-reader** | `tananaev/passport-reader` | Apache 2.0 | YES | Android; GDPR Art. 32 | Mobile KYC flow (Expo) |

**GDPR Art. 9 note (биометрия):** все биометрические данные — специальная категория (Art. 9). Обязательны: отдельная DPIA, legal basis Art. 9(2)(g) или Art. 9(2)(b), retention-политика совместимая с DAC8/AML (min 5 лет для audit trail vs. right to erasure для биометрики — конфликт требует legal-review и ADR-062).

### Слой 4 — AML Screening (Sanctions / PEP / Adverse Media)

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| Sanctions/PEP screening data | **OpenSanctions** | `opensanctions/opensanctions` | CC BY-NC / Enterprise | YES | Enterprise licence for commercial use; self-hosted data | `services/aml/screening_service` |
| Sanctions/PEP API server | **Yente** | `opensanctions/yente` | MIT | YES | Self-hosted; screening decisions audit-logged (ADR-027) | `services/aml/screening_service` |
| OFAC + global watchlists | **Moov Watchman** | `moov-io/watchman` | Apache 2.0 | YES | — | `services/aml/watchman_adapter` |
| Adverse media / negative news | **kyc-analyst** | `vyayasan/kyc-analyst` | MIT | INTERNAL-ONLY | Human-in-the-loop compliance tool; not client-facing automated flow | Compliance Officer dashboard |

### Слой 5 — Real-Time AML Transaction Monitoring

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| Rule-based TM + ML scoring | **Jube** | `jube-home/aml-fraud-transaction-monitoring` | AGPL-3.0 | PARTIAL + AGPL-flag | AGPL требует публикации модификаций при сетевом сервисе; изолированный сервис обязателен; legal-review-required | `services/aml/transaction_monitor` |

**AGPL-обязательство Jube:** Jube распространяется под AGPL-3.0. Если BANXE предоставляет KYC/AML-функциональность как сетевой сервис (SaaS), AGPL может потребовать публикации всех модификаций Jube. Обязательно: развёртывать Jube как изолированный микросервис с чётким API-интерфейсом, без прямой линковки с проприетарными компонентами BANXE. Лицензионный риск = legal-review-required. Альтернативы: коммерческая лицензия Jube (если доступна), замена на Marble (Apache) для rule-based части + ML на Flink/Kafka (Q2 2026). Решение — в ADR-058.

### Слой 6 — Fraud Detection / Case Management

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| Fraud rules + case management | **Marble** | `checkmarble/marble` | Apache 2.0 | YES | Self-hosted; no AGPL issues | `services/aml/fraud_detection`, `services/case_management` |

### Слой 7 — KYB (Know Your Business)

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| KYB workflow orchestration | **Ballerine KYB** | `ballerine-io/ballerine` | MIT | YES | — | `services/kyc/kyb_service` |
| Company registry data | **OpenCorporates API** | — | Commercial | YES | DPA; no PII issue (company data) | `services/kyc/kyb_service/registries` |
| GLEIF LEI data | **GLEIF API** | — | CC-BY | YES | Public data | `services/kyc/kyb_service/registries` |
| UK companies | **Companies House API** | — | OGL v3 | YES | Public data | `services/kyc/kyb_service/registries` |
| FR companies | **SIRENE API** | — | ODbL | YES | Public data | `services/kyc/kyb_service/registries` |

### Слой 8 — Identity / SCA / PSD2

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| Identity management + MFA | **Ory Kratos** | `ory/kratos` | Apache 2.0 | YES | Self-hosted; EU residency | `services/iam/*`, `services/auth/*` |
| OAuth2 / OIDC / SCA | **Ory Hydra** | `ory/hydra` | Apache 2.0 | YES | PSD2 RTS SCA compliance path | `services/iam/*`, Keycloak co-existence (ADR-017) |

### Слой 9 — Bank Account Verification (PSD2 Open Banking)

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| Open Banking (PIS/AIS) | **Ballerine Open Banking** | `ballerine-io/ballerine` | MIT | YES | Berlin Group NextGenPSD2 standard; TPP authorisation required | `services/kyc/bank_account_verifier` |

### Слой 10 — Travel Rule (VASP-to-VASP)

| Sumsub функция | OSS-кандидат | Репозиторий | Лицензия | Применимость | Регуляторные риски | Связи в BANXE |
|---|---|---|---|---|---|---|
| Travel Rule messaging | **TRP open standard** | `TransparencyRegistry/trp` | Open | RESERVE | CASP licence / MiCA required for custodial; pending ADR-061 | `services/aml/travel_rule` (future) |
| VC / DID / W3C credentials | **Walt.id identity** | `walt-id/waltid-identity` | Apache 2.0 | RESERVE | MiCA CASP perimeter; pending ADR-061 | future `services/identity/vc_service` |
| OpenCred VC issuer | **opencred** | `stateofca/opencred` | Apache 2.0 | RESERVE | Same MiCA CASP scope | future |

Travel Rule note: поддерживать совместимость с 2100+ VASP-сетью Sumsub Travel Rule при переходе — обязательно. Полная миграция Travel Rule выкатывается под ADR-061 совместно с CASP-обвязкой.

---

## 3. EMI-периметр: резюме применимости

| Категория | Инструменты | Условие |
|---|---|---|
| YES — in scope | Ballerine, EasyOCR, Tesseract, Doubango, MRZ tools, DeepFace, NFCPassportReader/tananaev, Yente/OpenSanctions, Moov Watchman, Marble, Ory Kratos/Hydra, Ballerine Open Banking, KYB + public registries | Self-hosted EU/EEA; GDPR residency; DPIA для биометрики |
| PARTIAL / AGPL-flag | Jube (AGPL-3.0), FaceOnLive/Faceplugin (commercial SDK) | Jube: изолированный сервис + legal-review; FaceOnLive/Faceplugin: DPA + Art. 9 DPIA |
| INTERNAL-ONLY | kyc-analyst (adverse media) | Compliance Officer tool; не клиентский автоматический поток |
| RESERVE | TRP + Walt.id + opencred (Travel Rule / VC) | CASP licence / MiCA perimeter; ADR-061 |
| OUT-OF-SCOPE | Публичные SaaS-эндпоинты любого OSS-вендора без DPA | GDPR Art. 6 / Art. 32; FCA data-residency |

### Запреты (canonical)

1. PII EU/EEA-клиентов не отправляются в публичные SaaS-эндпоинты без DPA и legal basis (GDPR Art. 6).
2. Jube не линкуется с проприетарными компонентами BANXE (AGPL изоляция).
3. Биометрика без отдельной DPIA и Art. 9 legal basis — запрещена.
4. Гибридный режим Sumsub ↔ OSS-стек без отдельного ADR — запрещён.
5. Деградация текущего уровня KYC/AML относительно compliance-фрейма FCA — запрещена.

---

## 4. Архитектурная карта (ASCII)

```
+----------------------------------------------------------------------------+
|                BANXE EMI -- KYC/AML/Travel-Rule OSS Stack                  |
+----------------------------------------------------------------------------+
|                                                                            |
|  BANXE Customer UI / Mobile (Expo)                                         |
|        |                                                                   |
|        v                                                                   |
|  +----------------------------------------------+                         |
|  |      kyc-orchestrator (Ballerine)            |                          |
|  | onboarding workflow * KYB * periodic review  |                          |
|  | DAC8 self-cert flow * Open Banking (PSD2)    |                          |
|  +------+-----------------------+---------------+                          |
|         |                       |                                          |
|  +------v--------+   +----------v-----------------+                        |
|  | document-     |   |    biometric-service        |                       |
|  | verifier      |   | DeepFace + Faceplugin       |                       |
|  | FaceOnLive    |   | FaceOnLive Liveness         |                       |
|  | EasyOCR + MRZ |   | face-match / liveness-check |                       |
|  | Doubango      |   | [DPIA mandatory -- ADR-062] |                       |
|  | ocr-service   |   +-----------------------------+                       |
|  | mrz-parser    |                                                          |
|  +---------------+                                                          |
|         |                                                                  |
|  +------v------------------------------------------+                       |
|  |              screening-service                   |                      |
|  |  Yente (opensanctions) * Moov Watchman           |                      |
|  |  AML / sanctions / PEP * adverse media           |                      |
|  +------+------------------------------------------+                       |
|         |                                                                  |
|  +------v------------------------------------------+                       |
|  |  transaction-monitor (Jube AGPL)                 |                      |
|  |  [isolated service -- API boundary only]         |                      |
|  +------+------------------------------------------+                       |
|         |                                                                  |
|  +------v------------------------------------------+                       |
|  |  fraud-detection (Marble)                        |                      |
|  |  case-management * rule-engine                   |                      |
|  +------+------------------------------------------+                       |
|         |                                                                  |
|  +------v------------------------------------------+                       |
|  |  identity-provider (Ory Kratos / Hydra)          |                      |
|  |  SCA * OAuth2/OIDC * PSD2 RTS                    |                      |
|  +------+------------------------------------------+                       |
|         |                                                                  |
|  +------v------------------------------------------+                       |
|  |  travel-rule  (TRP + Walt.id)  [RESERVE]         |                      |
|  +--------------------------------------------------+                       |
|                                                                            |
|  -- Параллельные каналы ---------------------------------------------------  |
|  ClickHouse audit trail (ADR-027)  <-- все решения KYC/AML/TM/Fraud        |
|  KycReTriggerEvent / JURISDICTION_CHANGED (ADR-028)                        |
|    --> Ballerine re-screen + DAC8 Change-in-Circumstances                  |
|  Alert routing (ADR-033)  <-- AML/fraud events из Jube/Marble              |
|  Webhook reliability (ADR-034) <-- Sumsub fallback + Ballerine callbacks    |
|  DAC8 Tax-Reporting Function  <-- смена юрисдикции                         |
|  MLRO / SAR pipeline  <-- эскалация из TM/Fraud                            |
+----------------------------------------------------------------------------+
```

### Стыковка с существующим BANXE

| OSS-компонент | Существующий сервис BANXE | Интеграция |
|---|---|---|
| Ballerine | `services/kyc/*` | Замена/дополнение Sumsub workflow engine |
| Yente/Watchman | `services/aml/screening_service` | Переиспользование existing adapters |
| Jube | `services/aml/transaction_monitor` | Изолированный Docker сервис; API-only граница |
| Marble | `services/aml/fraud_detection`, `services/case_management` | Event-driven через `services/events/event_bus` |
| Ory Kratos/Hydra | `services/iam/*`, `services/auth/*` | Co-existence с Keycloak (ADR-017) |
| ClickHouse | ADR-027 audit trail | Все решения стека → append-only, TTL >= 5 лет |

---

## 5. Ownership Matrix (каноническое распределение)

| Роль | Подразделение BANXE | Главные обязанности | Артефакты в репо |
|---|---|---|---|
| Process Owner (canonical) | KYC/AML Operations (Compliance & Reporting, под MLRO) | Onboarding/periodic review, sanctions/PEP screening, TM, fraud cases, SAR pipeline, Travel Rule; AML risk tier decisions, EDD, account closure | `services/kyc/*`, `services/aml/*`, SAR pipeline, ADR-027 audit trail |
| Data Ingestion Co-owner | Customer Operations (KYC/Onboarding/CS) | Сбор документов, self-certification (DAC8), уведомления, ремайндеры, эскалация в KYC/AML Operations | `services/customer_lifecycle/*`, `services/notifications/*`, Ballerine workflow (onboarding) |
| Engineering / Platform | Platform Engineering | Деплой и поддержка OSS-стека (Ballerine, Yente, Watchman, Jube, Marble, Ory), интеграция с event bus, ClickHouse, FSM | `banxe-emi-stack`, future ADR-056..062 |
| Legal & Privacy / DPO | Legal & Privacy | DPIA биометрия (Art. 9), AGPL-обвязка Jube, DPA с feed-поставщиками (OpenSanctions/OpenCorporates/GLEIF), Travel Rule VASP контракты | DPIA register, Privacy Policy, legal review tracker |
| Security | Security Engineering | Sandbox/segregation биометрических моделей, KMS/secrets для API-feed-ключей, pen-test биометрических SDK | `.semgrep/*`, secrets management, security reviews |
| Finance / Procurement | Finance & Procurement | TCO-анализ vs Sumsub, экономика миграции, OpenSanctions enterprise licence | Migration KPI dashboard |
| Risk / Audit | Risk Management | KPI миграции (FNR/FPR, time-to-decision, sanctions-hit rate, SAR throughput), compliance evidence FCA / EU регулятора | Audit reports, KPI tracking |

---

## 6. Связи с ADR / Track'ами и резерв будущих ADR

### Существующие ADR с прямой привязкой

| ADR | Тема | Привязка к OSS-стеку |
|---|---|---|
| ADR-017 | Keycloak IAM cutover | Co-existence с Ory Kratos/Hydra (SCA/PSD2) |
| ADR-027 | Audit-trail durability (append-only ClickHouse) | Обязателен для всех решений KYC/AML/TM/Fraud |
| ADR-028 | KYC re-verification triggers (JURISDICTION_CHANGED) | KycReTriggerEvent → Ballerine re-screen + Yente re-scan; DAC8 Change-in-Circumstances |
| ADR-033 | Alert routing | AML/fraud события из Jube/Marble → MLRO/Compliance |
| ADR-034 | Webhook reliability | Sumsub fallback + Ballerine callbacks — shared reliability layer |

### Резерв будущих ADR (диапазон ADR-056..062 — не пересекается с DAC8 045..049 и DeFi 045..050)

| ADR | Тема |
|---|---|
| ADR-056 | KYC/AML Open-Source stack adoption policy (Ballerine-centric, on-premise, EU residency, hybrid Sumsub migration) |
| ADR-057 | AML screening canonical pipeline (Yente + OpenSanctions enterprise + Moov Watchman + adverse media kyc-analyst) |
| ADR-058 | Real-time transaction monitoring: Jube AGPL isolation boundary, alternative paths (Marble rule-engine, Flink/Kafka Q2 2026) |
| ADR-059 | Fraud / Case Management: Marble integration boundary, event-driven interface, SAR pipeline integration |
| ADR-060 | Identity / SCA / PSD2: Ory Kratos/Hydra adoption, co-existence with Keycloak (ADR-017 extension) |
| ADR-061 | Travel Rule VASP-to-VASP: TRP open standard + Walt.id, Sumsub Travel Rule network compatibility (2100+ VASPs) |
| ADR-062 | Biometrics/Liveness: DPIA framework (GDPR Art. 9), legal basis, retention policy vs DAC8/AML conflict resolution |

---

## 7. Pending Invariant Proposals (без правки INVARIANTS.md)

| ID | Формулировка | ADR для формализации |
|---|---|---|
| I-42 | All PII of EU/EEA clients processed in KYC/AML stack must be processed on self-hosted infrastructure with EU/EEA data residency; no transmission to public SaaS endpoints of OSS vendors without DPA and GDPR Art. 6 legal basis | ADR-056 |
| I-43 | Jube (AGPL-3.0) must be deployed as a fully isolated microservice with an API-only boundary; no direct linking or shared code with proprietary BANXE components; AGPL compliance is legal-review-required before production deployment | ADR-058 |
| I-44 | Biometric data (face recognition, liveness detection) constitutes special category data under GDPR Art. 9; processing requires a completed DPIA, Art. 9(2) legal basis, defined retention policy, and erasure procedure compatible with DAC8/AML minimum retention obligations | ADR-062 |

---

## 8. Якоря для продолжения

- **Базовый тег:** `checkpoint-2026-05-06-dac8-tax-reporting-block`
- **Новый тег после merge:** `checkpoint-2026-05-06-oss-sumsub-replacement-block`

### Возможные следующие шаги (отдельные треки)

| Трек | Содержание | Зависимость |
|---|---|---|
| ADR-056 | OSS stack adoption policy + hybrid Sumsub migration plan | Legal/DPO + MLRO sign-off |
| ADR-057 | AML screening pipeline (Yente + Watchman) | OpenSanctions enterprise licence decision |
| ADR-058 | Jube AGPL isolation + alternatives | Legal-review AGPL + commercial licence inquiry |
| ADR-059 | Marble integration | ADR-056 accepted |
| ADR-060 | Ory Kratos/Hydra + Keycloak co-existence | ADR-017 review |
| ADR-061 | Travel Rule VASP (TRP + Walt.id) | MiCA CASP perimeter decision |
| ADR-062 | Biometrics DPIA | DPO + Security approval |
| Нумерация коллизия | DAC8 ADR-045..049 vs DeFi ADR-045..050 — согласование до создания ADR | Operator / architecture sign-off |
| Prototype | Ballerine + Yente + Watchman в banxe-emi-stack (отдельный трек) | ADR-056 accepted |
| Pending legal review | AGPL Jube, DPIA биометрия, OpenSanctions enterprise, Travel Rule VASP контракты | Legal & Privacy (DPO) |
