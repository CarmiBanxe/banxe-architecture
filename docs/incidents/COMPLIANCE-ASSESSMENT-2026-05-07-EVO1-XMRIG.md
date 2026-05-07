# COMPLIANCE-ASSESSMENT-2026-05-07-EVO1-XMRIG — Compliance Assessment Framework (DRAFT)

**Тип:** Compliance Assessment Framework (DRAFT — не decision record)
**Severity:** P0
**Дата создания:** 2026-05-07 (CEST)
**Discovery:** 2026-05-07 11:21 CEST
**Базовый коммит:** `c17586a` (main)
**Связанный incident-документ:** `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md`
**Цель:** предоставить MLRO + DPO + AML каркас для assessment-решения по GDPR Art. 33/34, FCA SUP 15, AMLR/AMLD6 в окне таймеров

**ВАЖНО:** Этот документ — assessment framework (checklist + каркас), **не decision record**. Все решения «breach yes/no», «notify yes/no» принимает incident commander совместно с MLRO + DPO. Документ не содержит PII.

---

## Связанные записи

| Gap ID | Severity | Статус |
|---|---|---|
| `G-SECURITY-EVO1-XMRIG-CRYPTOMINER` | P0 | OPEN |
| `G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION` | P0 | OPEN |
| `G-SECURITY-EVO1-COMPROMISE-AUDIT-PENDING` | P0 | OPEN |
| `G-SECURITY-EVO2-IOC-SWEEP-PENDING` | P1 | OPEN |
| `G-SECURITY-LEGION-IOC-SWEEP-PENDING` | P1 | OPEN |

IL: `IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED`

---

## 1. Compliance Timers (точные)

| Таймер | Trigger | Старт | Дедлайн / окно | Статус | Ответственный |
|---|---|---|---|---|---|
| **GDPR Art. 33** | Notification to supervisory authority (72 h) | 2026-05-07 11:21 CEST | **≈ 2026-05-10 11:21 CEST** | Assessment pending | DPO + Legal & Privacy |
| **GDPR Art. 34** | Notification to data subjects | After Art. 33 decision | TBD | Pending Art. 33 outcome | DPO + Customer Operations |
| **FCA SUP 15** | Material incident notification (EMI TOMPAY LTD) | Discovery | «As soon as practicable» | Assessment pending | MLRO + Head of Compliance |
| **AMLR/AMLD6** | KYC/AML pipeline integrity | Discovery | Immediate assessment | Assessment pending | MLRO + Engineering |

### Внутренние SLA (ставится оператором)

| Milestone | Target | Статус |
|---|---|---|
| Incident commander → MLRO + DPO acknowledge | ≤ T+12h (≈ 2026-05-07 23:21 CEST) | `[ ]` Pending |
| First compliance review meeting | ≤ T+24h (≈ 2026-05-08 11:21 CEST) | `[ ]` Pending |
| Art. 33 decision (notify / do not notify) | ≤ T+60h (≈ 2026-05-09 23:21 CEST) | `[ ]` Pending |
| FCA SUP 15 decision | ≤ T+72h (≈ 2026-05-10 11:21 CEST) | `[ ]` Pending |

---

## 2. Roles & Responsibilities

| Роль | Ответственный | Зона |
|---|---|---|
| **Incident Commander** | `<operator>` (CEO / Owner) | Координация всех phases, escalation, final decisions |
| **MLRO TOMPAY LTD** | `<MLRO>` | FCA SUP 15, AMLR, SAR pipeline integrity |
| **DPO BANXE** | `<DPO>` | GDPR Art. 33/34, DPIA delta, data-subject notification |
| **Head of Compliance** | `<CCO>` | Regulatory communications, FCA liaison |
| **Engineering / Platform** | `<Eng>` | Forensic preservation, IoC sweep, network containment |
| **Security** | `<Sec>` | KMS / secrets rotation, IR runbook |
| **Legal & Privacy** | `<Legal>` | DPA, contractual obligations, external counsel |
| **Customer Operations** | `<CustOps>` | Data-subject notification draft (только если Art. 34) |
| **External CERT / IRP** | `<TBD>` | External incident response provider |

Все имена — плейсхолдеры. Заполнение — операторская задача.

---

## 3. GDPR Art. 33 Assessment Framework

### Шаг 1: Квалификация инцидента

**Является ли инцидент «personal data breach» по GDPR Art. 4(12)?**

Определение: нарушение безопасности, ведущее к случайному или незаконному уничтожению, потере, изменению, несанкционированному раскрытию или доступу к персональным данным.

| Тип нарушения | Присутствует? | Примечание |
|---|---|---|
| **Confidentiality** (несанкционированный доступ) | `[ ]` yes / `[ ]` no / `[ ]` unknown — pending forensic | XMRig root-процесс мог читать любые файлы/память |
| **Integrity** (несанкционированное изменение) | `[ ]` yes / `[ ]` no / `[ ]` unknown — pending forensic | Проверить целостность persistent stores |
| **Availability** (потеря доступа) | `[ ]` yes / `[ ]` no / `[ ]` unknown — pending forensic | Load avg ≈35 → деградация сервисов |

### Шаг 1a: Сервисы и persistent stores с PII на evo1 (окно 2026-04-23..2026-05-07)

| Сервис / Store | PII? | Работал на evo1? | Integrity status |
|---|---|---|---|
| Customer Operations (customer data) | Yes | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` unknown |
| KYC/AML pipeline — Ballerine (workflow) | Yes | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` unknown |
| KYC/AML pipeline — Yente / Watchman (sanctions) | Yes | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` unknown |
| KYC/AML pipeline — Jube (fraud scoring) | Yes | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` unknown |
| KYC/AML pipeline — Marble (case mgmt) | Yes | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` unknown |
| KYC/AML pipeline — Ory (identity / auth) | Yes | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` unknown |
| DAC8 Tax-Reporting Function | Yes | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` unknown |
| Owner Control Agent (KPI aggregates) | No (по канону) | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` verify no PII leak |
| customer-privacy-right-v2 каркас | Meta only | `[ ]` yes / `[ ]` no / `[ ]` unknown | N/A |

### Шаг 2: Оценка риска

| Оценка | Ответ |
|---|---|
| «Likely to result in a risk to rights and freedoms» (Art. 33(1)) | `[ ]` yes / `[ ]` no / `[ ]` insufficient data |
| «High risk to rights and freedoms» (Art. 34(1)) | `[ ]` yes / `[ ]` no / `[ ]` insufficient data |

### Шаг 3: Scope

| Параметр | Значение |
|---|---|
| Физические лица EU/EEA | `[ ]` 0 / `[ ]` 1–100 / `[ ]` 100–1000 / `[ ]` 1000–10000 / `[ ]` >10000 / `[ ]` unknown |
| Физические лица UK | `[ ]` 0 / `[ ]` 1–100 / `[ ]` 100–1000 / `[ ]` 1000–10000 / `[ ]` >10000 / `[ ]` unknown |
| Категории данных | `[ ]` KYC identity / `[ ]` transactional / `[ ]` payment / `[ ]` biometric / `[ ]` contact / `[ ]` financial / `[ ]` unknown |

### Шаг 4: Связь с forensic preservation

Полная классификация возможна только после Phase 1 (Forensic Preservation evo1). Результаты Phase 1 будут прикреплены к этому assessment отдельным append-only обновлением.

→ Ссылка: `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md` → Phase 1.

### Шаг 5: Supervisory Authority

| Authority | Применимость | Статус |
|---|---|---|
| **UK ICO** | TOMPAY LTD — UK EMI, UK GDPR + DPA 2018 | `[ ]` lead / `[ ]` not lead / `[ ]` TBD |
| **FR CNIL** | Если cross-border processing с FR data subjects | `[ ]` applicable / `[ ]` not applicable / `[ ]` TBD |
| **EU Lead Supervisory Authority** | Определяется по main establishment + cross-border | `[ ]` identified: ______ / `[ ]` TBD |

Lead authority определяется по establishment + cross-border processing scope. Операторская + Legal задача.

### Шаг 6: Template Notification Draft (плейсхолдер)

> **ПРИМЕЧАНИЕ:** Это шаблон-заготовка, НЕ текст для подачи. Финальный текст готовится Legal + DPO после решения.

**a) Description of breach (без PII):**
`[PLACEHOLDER: описать характер инцидента — unauthorized access via cryptominer malware on project-layer node, compromise window estimate, services potentially affected]`

**b) Categories and approximate number of data subjects:**
`[PLACEHOLDER: заполнить по итогам Шаг 3]`

**c) Contact point (DPO):**
`[PLACEHOLDER: DPO name, email, phone — заполняется оператором]`

**d) Likely consequences:**
`[PLACEHOLDER: potential unauthorized access to personal data, potential integrity compromise of KYC/AML pipeline, potential availability degradation]`

**e) Measures taken / proposed:**
`[PLACEHOLDER: incident declared, forensic preservation initiated, network containment planned, credentials rotation planned, roadmap paused, AML/KYC integrity check planned]`

### Шаг 7: Decision

| Решение | Отметка | Обоснование |
|---|---|---|
| **Notify** supervisory authority (Art. 33) | `[ ]` | `[PLACEHOLDER]` |
| **Do not notify** (with documented justification) | `[ ]` | `[PLACEHOLDER]` |

**Решение принимает: Incident Commander + DPO + Legal. Не агент.**

---

## 4. GDPR Art. 34 Assessment Framework (Data-Subject Notification)

### Условие

«High risk to the rights and freedoms of natural persons» (Art. 34(1)).

| Оценка | Ответ |
|---|---|
| High risk to rights and freedoms? | `[ ]` yes / `[ ]` no / `[ ]` insufficient data |
| Mitigated by encryption / pseudonymisation? | `[ ]` yes / `[ ]` no / `[ ]` partially |
| Mitigated by subsequent measures rendering risk unlikely? | `[ ]` yes / `[ ]` no |
| Disproportionate effort → public communication instead? | `[ ]` yes / `[ ]` no |

### Каналы уведомления (если Art. 34 = yes)

| Канал | Статус | Примечание |
|---|---|---|
| Email (через утверждённый ESP) | `[ ]` planned | Primary |
| App push notification | `[ ]` planned | Secondary |
| In-app banner | `[ ]` planned | Persistent |
| SMS | ❌ Не использовать | Риск phishing |
| Signed letter (postal) | `[ ]` if required | По запросу регулятора |

### Локализация

| Язык | Применимость |
|---|---|
| EN | `[ ]` yes |
| FR | `[ ]` yes |
| RU | `[ ]` if applicable |

### Audit

Все уведомления логируются в ADR-027 audit trail. Retention — по GDPR / FCA / DAC8 retention canon (см. `customer-privacy-right-v2.md` §5).

### Decision

| Решение | Отметка | Обоснование |
|---|---|---|
| **Notify** data subjects (Art. 34) | `[ ]` | `[PLACEHOLDER]` |
| **Do not notify** (with documented justification) | `[ ]` | `[PLACEHOLDER]` |

**Решение принимает: Incident Commander + DPO + Legal. Не агент.**

---

## 5. FCA SUP 15 Assessment Framework (Material Incident)

### Квалификация

Категория: cyber incident affecting EMI license holder **TOMPAY LTD** (FCA-authorised).

| Критерий | Присутствует? |
|---|---|
| Material impact on services | `[ ]` yes / `[ ]` no / `[ ]` unknown |
| Potential customer harm | `[ ]` yes / `[ ]` no / `[ ]` unknown |
| Potential prudential impact (CASS 7 safeguarding integrity) | `[ ]` yes / `[ ]` no / `[ ]` unknown |
| Reputational risk | `[ ]` yes / `[ ]` no / `[ ]` unknown |

### CASS 7 / CASS 7A Sub-Assessment

| Вопрос | Ответ |
|---|---|
| evo1 hosts services touching client money operations? | `[ ]` yes / `[ ]` no / `[ ]` unknown — pending forensic |
| Safeguarding account reconciliation affected? | `[ ]` yes / `[ ]` no / `[ ]` unknown |
| Client money shortfall possible? | `[ ]` yes / `[ ]` no / `[ ]` unknown |

### Communication Channels

| Канал | Назначение |
|---|---|
| Dedicated FCA supervisor | Informal pre-notification (рекомендуется) |
| FCA Connect | Formal submission |
| RegData out-of-cycle | Если требуется data return |

### Timing

«As soon as practicable» — внутренний target: **≤ T+72h** от discovery (2026-05-10 11:21 CEST), чтобы совпасть с GDPR Art. 33 окном.

### Decision

| Решение | Отметка | Обоснование |
|---|---|---|
| **Notify FCA** via SUP 15.3 | `[ ]` | `[PLACEHOLDER]` |
| **Do not notify** (with justification) | `[ ]` | `[PLACEHOLDER]` |
| **Escalate to dedicated supervisor first** (informal) | `[ ]` | `[PLACEHOLDER]` |

**Решение принимает: Incident Commander + MLRO + Head of Compliance. Не агент.**

---

## 6. AMLR / AMLD6 Assessment Framework

### KYC/AML Pipeline Integrity

| Компонент (OSS-Sumsub-блок) | На evo1? | Integrity |
|---|---|---|
| **Ballerine** (KYC workflow) | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` compromised / `[ ]` unknown |
| **Yente / Watchman** (sanctions matching) | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` compromised / `[ ]` unknown |
| **Jube** (fraud scoring) | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` compromised / `[ ]` unknown |
| **Marble** (case management) | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` compromised / `[ ]` unknown |
| **Ory** (identity / auth) | `[ ]` yes / `[ ]` no / `[ ]` unknown | `[ ]` intact / `[ ]` compromised / `[ ]` unknown |

### Pipeline Outputs Assessment

| Вопрос | Ответ |
|---|---|
| KYC pipeline integrity compromised? | `[ ]` yes / `[ ]` no / `[ ]` unknown |
| Sanctions matching outputs altered? | `[ ]` yes / `[ ]` no / `[ ]` unknown |
| Transaction monitoring rule state altered? | `[ ]` yes / `[ ]` no / `[ ]` unknown |
| SAR queue affected? | `[ ]` yes / `[ ]` no / `[ ]` unknown |
| Travel Rule data exposed? | `[ ]` yes / `[ ]` no / `[ ]` unknown |

### Decision

| Решение | Отметка | Обоснование |
|---|---|---|
| **Re-screen** affected customer cohort | `[ ]` | `[PLACEHOLDER]` |
| **Re-run** sanctions screening (full / partial) | `[ ]` | `[PLACEHOLDER]` |
| **Re-evaluate** ongoing monitoring rules | `[ ]` | `[PLACEHOLDER]` |
| **No further action** | `[ ]` | `[PLACEHOLDER]` |

### Если pipeline скомпрометирован

**Sub-flow:** replay все KYC/AML decisions с **2026-04-22** (binary mtime -1 день) на чистой инфраструктуре.

**SAR pipeline integrity:** проверить, не были ли потеряны / искажены SAR-events с 2026-04-23. Если да → MLRO decision: re-submit / supplement.

**Решение принимает: MLRO. Не агент.**

---

## 7. Customer Notification Framework (Art. 34 + коммерческое)

> Активируется **только** в случае Art. 34 = «yes» или операторского коммерческого решения.

### Содержание уведомления (template, без PII)

1. Что произошло (без PII): unauthorized access to a project-layer server via malware; compromise window estimate.
2. Какие данные потенциально затронуты (категории, без значений).
3. Что делает BANXE: incident response, forensic analysis, credentials rotation, enhanced monitoring.
4. Что должны сделать клиенты: rotate passwords, enable 2FA if not yet, watch for phishing, report suspicious activity.
5. Контакты DPO: `[PLACEHOLDER]`.

### Локализация

EN, FR (по locale BANXE), RU при необходимости.

### Каналы

Email через утверждённый ESP, app push, in-app banner. **Никаких SMS** для security-уведомлений (риск phishing).

### Audit

Запись в ADR-027 audit trail. Retention по GDPR / FCA / DAC8 retention canon (см. `customer-privacy-right-v2.md` §5).

---

## 8. Связь с Canon Track I

| Артефакт | Статус | Assessment-связь |
|---|---|---|
| **Ghost Mode** (PR #130, ADR-074/075/076) | PAUSED | Если incident затронет ZK-Identity AML-anchor (W3C VC) — заметка для post-incident review |
| **Customer Privacy Right v2** | PAUSED | Privacy-by-design не отменяется AML/CFT обязательствами; incident = пример compliance-first (I-31) |
| **DAC8 Tax-Reporting** | PAUSED | Assessment: была ли скомпрометирована DAC8 self-cert pipeline; если да — DAC8 Change-in-Circumstances re-trigger по cohort |
| **OSS-Sumsub-стек** | PAUSED | Assessment: целостность Ballerine workflow, Yente sanctions cache, Marble case mgmt (см. §6) |
| **Owner Control Agent** | PAUSED | Assessment: целостность KPI агрегатов; по канону — нет PII, но verify факт |
| **DeFi-Stack / Sber OSS / Claude Finance Agents** | PAUSED | Не активируем до RESOLVED |
| **ADR-028** (KYC re-trigger) | PAUSED | Рассмотреть массовый `KycReTriggerEvent` для затронутых клиентов после assessment |
| **ADR-027** (audit trail) | ACTIVE | Все assessment-решения логируются через canonical audit-канал |

---

## 9. Pending Invariant Proposals (без правки INVARIANTS.md)

| ID | Формулировка |
|---|---|
| **I-64** | Compliance assessment frameworks (GDPR/FCA/AMLR) являются обязательной частью каждого P0 security incident; запускаются параллельно forensic preservation, не последовательно. |
| **I-65** | GDPR Art. 33/34 / FCA SUP 15 / AMLR — таймеры начинаются от discovery, а не от remediation; assessment-документ не делает решения, но обязан быть готов до истечения первых SLA-окон. |
| **I-66** | Project-layer compromise автоматически триггерит integrity check всех AML/KYC/Travel-Rule/DAC8 pipeline outputs за весь окно подозрительной активности (binary mtime минус 1 день). |

---

## Status Updates (append-only)

---

### 2026-05-07 — ASSESSMENT FRAMEWORK CREATED (P0)

- Compliance assessment framework создан: `docs/incidents/COMPLIANCE-ASSESSMENT-2026-05-07-EVO1-XMRIG.md`.
- Связанный incident-документ: `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md`.
- Связанные gap-записи: `G-SECURITY-EVO1-XMRIG-CRYPTOMINER` (P0), `G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION` (P0), остальные — см. incident-документ.
- Связанная IL: `IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED`.
- GDPR Art. 33 deadline: **≈ 2026-05-10 11:21 CEST**.
- Все assessment-чеклисты — pending forensic (Phase 1) + operator/MLRO/DPO decisions.
- Все решения — операторские; документ — framework, не decision record.

**Awaiting: operator + MLRO + DPO acknowledge для запуска assessment-процесса.**
