# BANXE / Private Legion Engine — Ответы на открытые вопросы архитектуры

> **Статус документа:** Аналитический меморандум. Классифицирует каждый вопрос по типу: [ФАКТ] — подтверждён внешними источниками; [ВЫВОД] — логическое следствие из известных данных; [НЕИЗВЕСТНО] — нет внешних данных, требует решения владельца архитектуры.

***

## Блок 1 — Граница и связь двух движков

### 1.1 Физическая связь Banking Engine ↔ Private Legion Engine

[ФАКТ] Признанный отраслевой стандарт для регулируемых финансовых AI-систем — **двухзональная архитектура**: изолированный «доверенный» банковский контур и отдельный «открытый» контур для dev/research-задач. Между зонами не должно быть прямых сетевых маршрутов. Данные могут передаваться только через строго контролируемый API Gateway с логированием каждого пересечения границы.[^1][^2]

[ВЫВОД] По совокупности данных нашего разговора: **Legion Engine (OpenManus + uncensored Qwen3.6) — это изолированный приватный контур**. Он не должен иметь прямого доступа к банковским данным. Если Legion-агенту нужны данные из банковского контура, передача должна идти только через контролируемый API с явным audit trail. Прямой bash/browser-доступ Legion-агента к банковским БД или сетям — нарушение compliance-границы.

[НЕИЗВЕСТНО] Точная топология сети (evo1/evo2/Legion) — не задокументирована в публичных источниках. Решение принимает владелец архитектуры.

### 1.2 Uncensored-модель и банковский контур

[ФАКТ] Uncensored/abliterated-модели (тип HauhauCS Aggressive) принципиально несовместимы с банковским compliance по следующим причинам: они не поддерживают детерминированные guardrails, не могут быть верифицированы как «explainable AI» по требованию EU AI Act Article 13, и их поведение непредсказуемо при граничных запросах. EU AI Act требует, чтобы высокорисковые AI-системы в финансовом секторе имели задокументированную систему управления рисками на протяжении всего жизненного цикла.[^3][^4]

[ВЫВОД] **Qwen3.6-35B-A3B-Aggressive предназначена исключительно для приватного контура Legion**. Она никогда не должна участвовать в банковских решениях. Это не рекомендация — это архитектурная красная линия, продиктованная регуляторикой. Для банковского контура применяются censored-модели с NeMo Guardrails или аналогичными верифицируемыми guardrails.[^5][^6]

### 1.3 BDSL и Legion-агент

[ФАКТ] BDSL (Banking Decision Safety Layer) по определению является governance-слоем для систем, принимающих банковские решения. OpenManus на Legion — это dev/research-инструмент оператора, а не система принятия банковских решений.[^7][^8]

[ВЫВОД] **BDSL не распространяется на Legion-агента**. Это разные контуры с разными задачами. Legion-агент может иметь собственный, более простой governance (например, логирование вызовов инструментов), но его пороги и метрики не пересекаются с банковскими.

***

## Блок 2 — BDSL и «Лучшее решение»

### 2.1 Пороги BDSL: откуда числа?

[ФАКТ] MAUT требует, чтобы пороги принятия решений были «elicited» — т.е. получены через структурированный процесс опроса экспертов (swing-weighting или direct rating), а не назначены произвольно. В регулируемой банковской среде пороги классификатора решений (threshold calibration) должны быть согласованы с MLRO и CRO и задокументированы как часть модельной документации по требованию регулятора.[^9][^4]

[ФАКТ] Специальный порог 0.95 для payment-контура — типичная отраслевая практика для high-stakes операций, но конкретное число должно быть откалибровано на исторических данных ложноположительных/ложноотрицательных срабатываний для конкретной модели. Порог «из воздуха» без back-testing не принимается BaFin как валидная калибровка.[^10][^4]

[НЕИЗВЕСТНО] Были ли числа 0.90/0.70/0.95 согласованы с MLRO/CRO конкретно в BANXE. Это внутренний вопрос, требующий ответа от Compliance-функции.

### 2.2 MAUT-веса критериев

[ФАКТ] MAUT-веса (regulatory 0.40 / harm 0.30 / revenue 0.15 / cost 0.15) должны быть получены через формальную процедуру элицитации предпочтений у стейкхолдеров. Веса «по умолчанию» без такой процедуры — это экспертная оценка консультанта, не прошедшая валидацию. Для регулируемого использования требуется документированное обоснование каждого веса.[^11][^4][^9]

[ВЫВОД] Предложенные веса разумны по структуре (regulatory-доминирующий вес корректен для EMI/банка), но статус «предложение консультанта» должен быть явно зафиксирован в ADR. До утверждения MLRO/CRO эти веса нельзя считать «каноном».

[ФАКТ] Sensitivity analysis (±20% перебор весов) является обязательным шагом MAUT для проверки устойчивости решения. Если изменение веса regulatory с 0.40 на 0.32 или 0.48 меняет итоговый ранжир альтернатив — веса нестабильны и требуют пересмотра.[^9]

### 2.3 CREDIT-домен и выделенный агент

[ФАКТ] EU AI Act Annex III §5 явно классифицирует «AI systems used to evaluate creditworthiness or establish credit score» как high-risk. Для таких систем требуется: conformity assessment, полная техническая документация, регистрация в EU AI Database, human oversight capability.[^12][^13][^3]

[ФАКТ] По последним данным (LinkedIn, май 2026): обязательства Art. 6(2), покрывающие кредитный скоринг, страхование и AML, **перенесены с 2 августа 2026 на 2 декабря 2027**.[^13]

[ВЫВОД] Отсутствие выделенного credit_decision_agent — это **осознанный или неосознанный риск**. Если кредитная логика присутствует внутри finance/apar_agent без явного документирования как high-risk системы, это создаёт regulatory gap. Рекомендуется: либо явно вывести кредитную логику в отдельного агента с полной документацией, либо зафиксировать в ADR, что кредитные решения принимаются человеком, а AI только предоставляет «preparatory task» (что позволяет использовать filter-mechanism Art. 6(3) для избежания high-risk классификации).[^13]

***

## Блок 3 — Оркестратор и архитектурные развилки

### 3.1 LangGraph (Banking) vs OpenManus (Legion) — почему два оркестратора?

[ФАКТ] LangGraph — единственный из ведущих фреймворков, специально оптимизированный для **production-grade stateful workflows с compliance-level control flow, durable execution и human-in-the-loop**. Для banking-движка с BDSL, threshold gates и audit trail — LangGraph является техническим каноном 2026 года.[^14][^15][^7]

[ФАКТ] OpenManus — это Manus-подобный агент для **autonomous task execution** (web browsing, code execution, file management). Он оптимизирован для dev/research-задач, а не для compliance-контролируемых банковских workflow.[^16][^17]

[ВЫВОД] **Два оркестратора — это осознанное и правильное разделение**. Это не противоречие, а архитектурный паттерн: compliance-controlled banking engine на LangGraph + autonomous private engine на OpenManus. Они решают принципиально разные задачи и не должны быть объединены в один оркестратор именно потому, что требования к ним противоположны.

### 3.2 DeerFlow, CrewAI, AutoGen — статус в архитектуре

[ФАКТ] DeerFlow (ByteDance) — SuperAgent-паттерн с Docker-sandbox isolation, специализирован для deep research и multi-step autonomous tasks. **Статус: альтернатива OpenManus для Private Legion Engine**, особенно если нужна более строгая sandbox-изоляция.[^18][^19]

[ФАКТ] CrewAI — оптимален для role-based multi-agent workflows с быстрым setup, но без production-grade state management и без compliance features. **Статус для banking engine: отвергнут** по причине отсутствия auditable state machine и human-in-the-loop нужного уровня.[^20][^14]

[ФАКТ] AutoGen (Microsoft) — conversational multi-agent patterns, .NET support, хорошо для R&D и experimentation. **Статус для banking engine: отвергнут** по тем же причинам (probabilistic, не deterministic-first). Для Private Engine — альтернатива, но OpenManus/DeerFlow предпочтительнее для local deployment.[^21]

| Фреймворк | Banking Engine | Private Legion | Причина |
|---|---|---|---|
| **LangGraph** | ✅ Канон | ❌ Избыточен | Stateful, auditable, compliance-grade [^7] |
| **OpenManus** | ❌ Не подходит | ✅ Канон | Autonomous task execution, browser/bash tools [^16] |
| **DeerFlow** | ❌ | ⚠️ Альтернатива | Docker sandbox, но нет local-first deployment [^18] |
| **CrewAI** | ❌ Отвергнут | ⚠️ Прототип | Нет compliance control flow [^14] |
| **AutoGen** | ❌ Отвергнут | ⚠️ R&D only | Probabilistic, нет audit trail [^21] |

### 3.3 Память: Qdrant / Mem0 / LlamaIndex / Zep

[ФАКТ] По состоянию на июль 2026 — это не взаимозаменяемые инструменты, а разные слои памяти с разными функциями:[^22][^23]

| Инструмент | Тип памяти | Оптимальное применение | Compliance |
|---|---|---|---|
| **Qdrant** | Vector store (semantic retrieval) | Banking: RAG по политикам, KYC-документам[^24] | ✅ Audit trail через DataSunrise[^25] |
| **Mem0** | Long-term персональная память | Private Engine: контекст сессий пользователя[^26] | ⚠️ Managed SaaS option — не для банковских данных |
| **Zep/Graphiti** | Temporal knowledge graph | Banking: история решений с временной привязкой[^27] | ✅ Open-source, self-hosted |
| **LlamaIndex** | Document pipeline + RAG orchestration | Banking: ingestion pipeline для регуляторных документов[^23] | ✅ Self-hosted |

[ВЫВОД] **Канон для banking engine**: Qdrant (vector store) + Zep/Graphiti (temporal knowledge graph) — оба self-hosted, оба совместимы с LangGraph. Mem0 — только для Private Legion Engine (приватные dev-сессии). LlamaIndex — pipeline для документов, не хранилище.[^22]

***

## Блок 4 — Числа и оргструктура

### 4.1 47 паспортов (34+13)

[НЕИЗВЕСТНО] Конкретные числа 47 / 48 / 34 / 13 являются внутренними данными BANXE. Внешних источников для верификации нет. Рекомендация: зафиксировать в ADR как «baseline at vX.Y date», с явным указанием, что флот растёт и числа не статичны.

### 4.2 13 PROPOSED-агентов: решающие vs domain-service

[ФАКТ] Для определения, какой агент «принимает решения» (и попадает под BDSL/EU AI Act), используется следующий критерий EU AI Act Art. 6(3): агент является high-risk если его output **напрямую влияет на доступ клиента к услуге** (кредит, платёж, onboarding). Агент, который «улучшает результат ранее завершённой человеческой активности» или «выполняет preparatory task», может быть исключён из high-risk через self-assessment.[^13]

[ВЫВОД] Из 13 PROPOSED-агентов под BDSL попадают те, чьи outputs входят в payment-цепочку, KYC/AML-решения или кредитные оценки. Агенты-координаторы (orchestrators) и агенты-сервисы (data fetchers, formatters) могут быть исключены. Решение ENROL/EXCLUDE принимается Compliance с документированным обоснованием.

### 4.3 Hermes: Factory vs Banking

[ВЫВОД] Hermes как Factory-агент (разработка, code review, документация) — вне банковского compliance scope. Client-advisory функция Hermes должна быть явно задокументирована как **advisory-only** (output — информация, не решение). Пока human-in-the-loop является обязательным перед любым action, Hermes не является high-risk системой по критерию Art. 6(3)(b).[^13]

***

## Блок 5 — Регуляторика и сроки

### 5.1 EU AI Act: кто под high-risk и когда?

[ФАКТ] Полная применимость EU AI Act для high-risk систем Annex III в финансовом секторе — **2 августа 2026** (для новых систем). Системы, находившиеся в production до этой даты, имеют переходный период до **2 августа 2027** (Article 111).[^28][^29][^12]

[ФАКТ] Важное уточнение (май 2026): обязательства Art. 6(2), покрывающие кредитный скоринг и AML AI, **перенесены на 2 декабря 2027** в рамках AI Omnibus. Это снижает давление дедлайна для кредитных агентов.[^13]

[ФАКТ] Санкции за несоответствие: до 35 млн евро или 7% мирового оборота (запрещённые практики); до 15 млн евро или 3% (прочие нарушения).[^3]

Агенты, вероятно попадающие под high-risk Annex III для BANXE/EMI:

| Агент-тип | Annex III основание | Срок |
|---|---|---|
| Кредитный скоринг/decisioning | §5 — creditworthiness assessment [^12] | 2 дек 2027 |
| AML/KYC screening | §6 — law enforcement adjacent [^29] | 2 авг 2026 |
| Payment processing (автоматические) | §5 — essential private services [^12] | 2 авг 2026 |
| Fraud detection в транзакциях | §6 — потенциально [^3] | 2 авг 2026 |
| Advisory-only агенты | Исключены через Art. 6(3) | — |

### 5.2 DLP-граница для Legion-агента

[ФАКТ] AI Agent Data Loss Prevention (DLP) — это обязательный слой для агентов с browser и internet access. Основные механизмы: inference guardrails (NeMo/LlamaFirewall) на уровне prompt/response; agent-side hooks для permission gating перед tool call; OS-level sandbox (Landlock, seccomp, namespaces) для filesystem isolation.[^30]

[ФАКТ] Legion-агенту с browser_use_tool и duckduckgo_search запрещено выносить наружу: банковские данные клиентов, PII, API keys, internal credentials, source code с секретами. Это не должно достигаться политикой — это должно быть архитектурно невозможным через сетевую изоляцию banking zone от Legion zone.[^31][^1][^30]

[ВЫВОД] Конкретная DLP-граница: Legion-агент работает в сети **без маршрутов к banking databases, internal APIs banking engine, и payment infrastructure**. Если Legion нужны данные из banking zone — только через read-only, logged API endpoint, без write-access.

***

## Блок 6 — Приоритет и источник правды

### 6.1 Иерархия документов при конфликте

[ФАКТ] Отраслевая практика для AI-систем в regulated environments — явная иерархия Architecture Decision Records (ADR): наиболее поздний ADR с явным supersedes-полем перекрывает предыдущий. Без supersedes-поля конфликтующие ADR требуют формального разрешения через governance committee.[^4]

[ВЫВОД] Рекомендуемая иерархия для BANXE:
1. **Regulatory mandate** (EU AI Act, BaFin, DORA) — абсолютный приоритет
2. **Последний подписанный ADR** с явным supersedes-полем
3. **BDSL-спецификация** (пороги, веса) — после утверждения MLRO/CRO
4. **Архитектурные чертежи** (agent passports, fleet registry)
5. **Рабочие черновики** — не источник правды

### 6.2 Что реализовано в коде vs что замысел

[НЕИЗВЕСТНО] Конкретное состояние кодовой базы BANXE не является публично верифицируемым. Рекомендация: провести **inventory audit** по следующей матрице:

| Компонент | Статус (заполнить) | Проверка |
|---|---|---|
| llama-server на Legion | ПЛАН / РЕАЛИЗОВАНО | `systemctl status llama-qwen` |
| OpenManus установлен | ПЛАН / РЕАЛИЗОВАНО | `cd OpenManus && python main.py` |
| LangGraph banking agents | ПЛАН / РЕАЛИЗОВАНО | Наличие граф-файлов в repo |
| Qdrant instance | ПЛАН / РЕАЛИЗОВАНО | Qdrant health endpoint |
| BDSL threshold layer | ПЛАН / РЕАЛИЗОВАНО | Code review |
| NeMo Guardrails | ПЛАН / РЕАЛИЗОВАНО | Конфиг-файлы |
| EU AI Act documentation | ПЛАН / РЕАЛИЗОВАНО | Наличие risk management docs |

***

## Блок «Вопросы к консультанту»

### Q1: ADR-103 (Legion — тонкий клиент) vs Manus-агент на Legion — противоречие?

[ВЫВОД] **Это два независимых контура, не противоречие**. ADR-103 описывает banking-клиент: Legion как thin client, который обращается к banking engine на evo1 через API — без локальных вычислений в banking zone. Manus-агент (OpenManus) — это отдельный Private Engine для приватных dev-задач оператора. Они сосуществуют на Legion физически, но логически изолированы. Private Engine работает автономно; banking-client Legion отдельно обращается к evo1.

### Q2: evo1 «unavailable» — временно или выводится?

[НЕИЗВЕСТНО] Статус evo1 — внутренняя инфраструктурная информация. Критичность ответа: если evo1 выводится из эксплуатации, banking engine должен быть перенесён на новую инфраструктуру (evo2 или Legion с переопределением ролей). Если временная проблема — banking engine продолжает проектироваться под evo1. Этот вопрос блокирует финальную архитектуру и требует немедленного ответа от инфраструктурной команды.

[ФАКТ] При недоступности основного вычислительного узла для банковской AI-системы рекомендованная практика — failover на secondary node с сохранением всех compliance-требований (logging, audit trail). «Fallback на Legion без compliance controls» не является допустимым сценарием.[^2][^1]

### Q3: Порог 0.95 для payment — согласован с MLRO/CRO?

[ФАКТ] В банковском compliance governance AI-модели с threshold-based decisions должны проходить формальную валидацию: back-testing на исторических данных, stress testing, документированное утверждение первой и второй линии защиты (risk management). Порог «предложен консультантом» ≠ «утверждён MLRO/CRO».[^4]

[ВЫВОД] До формального утверждения 0.95 является **рабочей гипотезой**, а не операционным порогом. В production использовать только после: (a) back-testing на реальных транзакционных данных, (b) документированного approval MLRO, (c) фиксации в model card как часть risk management system.

### Q4: Память Qdrant при недоступности evo1

[ВЫВОД] При недоступности evo1 варианты:
- **Временный Qdrant на evo2** — требует миграции векторных индексов, проверки репликации
- **Qdrant на Legion** — технически возможно, но создаёт смешение banking-памяти и private-контура, что нарушает data boundary
- **Раздельные Qdrant-инстансы** — банковская память ≠ Legion-память, это архитектурная граница, не рекомендация[^2][^22]

[ВЫВОД] **Память Private Engine (OpenManus на Legion) должна быть отдельной от банковской памяти**. Это не опционально — это data governance требование. На Legion: Qdrant для private tasks, никакого доступа к banking vector store.

### Q5: CREDIT-домен и EU AI Act

[ФАКТ] Как указано в Блоке 2.3: обязательства для кредитного скоринга перенесены на 2 декабря 2027. Это даёт время для проектирования credit_decision_agent с правильной документацией.[^13]

[ВЫВОД] Рекомендуется: до 2 декабря 2027 провести formal classification exercise для всех агентов, которые касаются кредитных данных. Если кредитная логика в finance/apar_agent является «preparatory task» (данные для человека-аналитика) — она может быть исключена из high-risk через Art. 6(3). Если она автономно влияет на кредитные лимиты или решения — требует отдельного агента с полной compliance-документацией.

### Q6: Uncensored-модель и банковские решения

[ФАКТ] Это однозначный ответ, подтверждённый регуляторными требованиями: **uncensored/abliterated-модели не могут использоваться в системах, принимающих банковские решения**, по следующим основаниям:
1. EU AI Act Art. 13 требует transparency и explainability — abliterated-модель не имеет документированного поведения[^3]
2. NeMo Guardrails требует предсказуемых refusal patterns для safety rail implementation[^6][^5]
3. BaFin ожидает воспроизводимый audit trail — abliterated-модель имеет непредсказуемые граничные случаи[^4]

Qwen3.6-35B-A3B-Aggressive предназначена **исключительно для приватного контура Legion**. Красная линия подтверждена.

***

## Итоговая матрица неопределённостей

| Вопрос | Статус | Приоритет | Кто решает |
|---|---|---|---|
| Статус evo1 (временно/выводится) | [НЕИЗВЕСТНО] | 🔴 Критический | Инфраструктурная команда |
| Пороги BDSL согласованы с MLRO/CRO | [НЕИЗВЕСТНО] | 🔴 Критический | Compliance/MLRO |
| MAUT-веса: экспертиза или данные | [НЕИЗВЕСТНО] | 🟡 Высокий | Архитектор + MLRO |
| Что реализовано в коде vs план | [НЕИЗВЕСТНО] | 🔴 Критический | Inventory audit |
| Credit domain: in scope или нет | [НЕИЗВЕСТНО] | 🟡 Высокий | Compliance (дедлайн дек 2027) |
| 47 паспортов: финальный флот или растёт | [НЕИЗВЕСТНО] | 🟢 Средний | Product/Architecture |
| Иерархия конфликтующих ADR | [НЕИЗВЕСТНО] | 🟡 Высокий | Architecture governance |

---

## References

1. [Air-Gapped LLM Deployment Compliance for Regulated ...](https://qapitol-website-six.vercel.app/insights/air-gapped-llm-deployment-compliance-regulated-financial-institutions) - ✓An air-gapped inference architecture requires four independently verifiable components: model weigh...

2. [AI Deployment in Air-Gapped Financial Networks - Seven Labs](https://www.sevenlabs.site/blogs/air-gapped-financial-ai) - Learn the architecture rules for AI deployment in air-gapped networks. We cover zero-trust LLMs, loc...

3. [EU AI Act Hits 90 Days: What High-Risk Financial Systems ...](https://www.deepidv.com/media/news/eu-ai-act-high-risk-financial-90-days-may-2026) - The EU AI Act high-risk financial system deadline is August 2, 2026. Here is what classification mea...

4. [AI governance in banking: complete 2026 guide](https://www.backbase.com/blog/ai-governance-in-banking) - AI governance banking frameworks help financial institutions deploy artificial intelligence safely w...

5. [NVIDIA NeMo Guardrails and TrueFoundry AI Gateway](https://www.truefoundry.com/blog/nvidia-nemo-guardrails-truefoundry-ai-gateway) - NVIDIA NeMo Guardrails is an open-source Python toolkit for putting programmable safety rails around...

6. [NVIDIA NeMo Guardrails Library](https://github.com/NVIDIA-NeMo/Guardrails) - The NeMo Guardrails library enables developers building LLM-based applications to add programmable g...

7. [LangChain, LangGraph, or Custom? Choosing the Right ...](https://www.turgon.ai/post/langchain-langgraph-or-custom-choosing-the-right-agentic-framework) - This post is a practical, CTO-level comparison of today's most prominent agentic frameworks — from s...

8. [Artificial Intelligence Governance for Banking Compliance](https://elevateconsult.com/insights/artificial-intelligence-governance-banking-compliance/) - This piece explores how banking institutions can create effective AI governance structures that prot...

9. [Multi-Attribute Utility Theory (MAUT) Calculator](https://metricgate.com/docs/multi-attribute-utility/) - Multi-Attribute Utility Theory (MAUT) is a structured decision analysis method for ranking and selec...

10. [Deterministic Guardrails for Agentic Financial Systems ...](https://arxiv.org/html/2604.01483v1) - This architecture provides cryptographic-level compliance certainty at microsecond latency, directly...

11. [Multi-Attribute Utility Theory](https://www.emergentmind.com/topics/multi-attribute-utility-theory) - Multi-Attribute Utility Theory is a decision-making framework that models preferences over multiple ...

12. [AI Act | Shaping Europe's digital future - European Union](https://digital-strategy.ec.europa.eu/en/policies/regulatory-framework-ai) - The AI Act entered into force on 1 August 2024, and will be fully applicable 2 years later on 2 Augu...

13. [Draft High-Risk AI Classification under the EU AI Act](https://www.linkedin.com/pulse/draft-high-risk-ai-classification-under-eu-act-what-katarzyna-kfslf) - Art. 6(2) obligations (covering credit scoring, insurance, AML) apply from 2 December 2027. Financia...

14. [Best AI Agent Frameworks for 2026: LangGraph vs CrewAI vs ...](https://www.youtube.com/watch?v=RSvYae1L9YI) - Best AI Agent Frameworks for 2026: LangGraph vs CrewAI vs AutoGen (Production Guide) | Intellipaat. ...

15. [The best AI agent frameworks in 2026](https://www.langchain.com/resources/ai-agent-frameworks) - We reviewed 7 AI agent frameworks across orchestration, observability, and production readiness. See...

16. [FoundationAgents/OpenManus: No fortress, purely open ... - GitHub](https://github.com/FoundationAgents/OpenManus) - Installation. We provide two installation methods. Method 2 (using uv) is recommended for faster ins...

17. [OpenManus 源码解析_python - AtomGit AI 社区](https://tianqi.csdn.net/6a2d298f662f9a54cb7e2837.html) - OpenManus 是一个基于大语言模型的通用 AI Agent 框架，采用 ReAct 架构模式，支持多模型调用（OpenAI、Azure、AWS Bedrock等）并提供丰富的工具集（Python...

18. [ByteDance DeerFlow Superagent Review: The Open ...](https://flowtivity.ai/blog/bytedance-deerflow-superagent-review/) - DeerFlow sits in an interesting position in the agent framework landscape. Compared to LangChain Dee...

19. [DeerFlow: A Modular Multi-Agent Framework ...](https://www.linkedin.com/pulse/deerflow-modular-multi-agent-framework-deep-research-ramichetty-pbhxc) - The framework integrates seamlessly with both open-source and proprietary tools, making it versatile...

20. [AI Agent Frameworks: LangGraph vs CrewAI vs AutoGen 2026](https://pecollective.com/blog/ai-agent-frameworks-compared/) - For most 2026 production agents, LangGraph or one of the vendor SDKs is the default. CrewAI and Auto...

21. [CrewAI vs LangGraph vs AutoGen vs OpenAgents — Best ...](https://openagents.org/blog/posts/2026-02-23-open-source-ai-agent-frameworks-compared) - In this guide, we compare four of the most prominent open source AI agent frameworks — CrewAI, LangG...

22. [Observable AI Memory: mem0, LangGraph, and Qdrant with ...](https://vadim.blog/observable-ai-memory-mem0-langgraph-qdrant/) - TL;DR — This field report shows how to build an agent memory layer where every operation honors a co...

23. [AI Agent Memory Frameworks in 2026: Memory vs. Context](https://www.graphlit.com/blog/survey-of-ai-agent-memory-frameworks) - This article is a 2026 survey of AI agent memory frameworks - Mem0, Supermemory, Membase, Memory Sto...

24. [Building Performant, Scaled Agentic Vector Search with Qdrant](https://qdrant.tech/articles/agentic-builders-guide/) - Qdrant supports real-time upserts, giving your agent access to the freshest data for short-term memo...

25. [Qdrant Audit Trail: An Overview of Logging and Monitoring Features](https://www.datasunrise.com/knowledge-center/qdrant-audit-trail/) - Qdrant Audit Trail: Learn about Qdrant's audit trail capabilities, its built-in tracking features an...

26. [Agent Memory & Knowledge Systems Compared (2026 Guide)](https://fountaincity.tech/resources/blog/agent-memory-knowledge-systems-compared/) - Compare Mem0, Zep, Letta, Cognee, and Cloudflare Agent Memory — plus the build-it-yourself path. 5 q...

27. [Mem0 vs Zep: Which AI Memory Solution Should You Choose?](https://gamgee.ai/vs/mem0-vs-zep/) - They represent different philosophies: Mem0 offers the broadest framework ecosystem and fastest path...

28. [Timeline for the Implementation of the EU AI Act](https://ai-act-service-desk.ec.europa.eu/en/ai-act/timeline/timeline-implementation-eu-ai-act) - 02 Aug 2026. The majority of rules of the AI Act come into force and enforcement starts. Rules for h...

29. [When does the EU AI Act take effect? | FluxForce](https://www.fluxforce.ai/answers/when-does-the-eu-ai-act-take-effect) - August 2, 2026: Full application of high-risk AI rules under Annex III. This is the date that matter...

30. [AI Agent Data Loss Prevention - PipeLab](https://pipelab.org/learn/ai-agent-data-loss-prevention/) - AI agent DLP is the detection and blocking of sensitive data (credentials, API keys, PII, payment da...

31. [Data loss prevention - Cloudflare One](https://developers.cloudflare.com/cloudflare-one/data-loss-prevention/) - Cloudflare Data Loss Prevention (DLP) allows you to scan your web traffic and SaaS applications for ...

