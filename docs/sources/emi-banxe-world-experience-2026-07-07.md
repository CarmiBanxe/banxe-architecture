---
title: "EMI BANXE AI BANK — Мировой опыт банков-ИИ-агентов: Азия, Китай, Япония, Латинская Америка, Ближний Восток"
source-origin: "operator Downloads (Legion), staged evo1 zero-loss"
intake-date: 2026-07-07
sha256-body: db72a7ea2b675f50a1a7ad1cedd098651030c8ad11094c45edb0f486fddeeea9
body-bytes: 68409
verify: "tail -c 68409 <this-file> | sha256sum == sha256-body"
related-findings: "#1059 (OSS intake), #1051 (EMI-stack intake)"
status: SSOT-RESTORED
---
# EMI BANXE AI BANK — Мировой опыт банков-ИИ-агентов: Азия, Китай, Япония, Латинская Америка, Ближний Восток

## Дополнение к основному исследованию UX/UI и Open Source стека

***

## Резюме

Настоящий документ является дополнением к предыдущему исследованию UX/UI банка-ИИ-агента EMI BANXE AI BANK. В нём систематизирован мировой опыт проектирования и эксплуатации финансовых ИИ-агентов на целевых рынках: Китай, Япония, Южная Корея, Юго-Восточная Азия, Латинская Америка, Ближний Восток и Австралия. Особое внимание уделено open source компонентам, архитектурным паттернам, лучшим UX-практикам и конкретным примерам развёртывания банков, которые уже работают как ИИ-агенты. В завершении приводится готовый промт-поручение для AI-дизайнера с учётом всего найденного мирового опыта.

***

## 1. Китай: Наиболее продвинутые банки-ИИ-агенты в мире

### 1.1 Alipay «Проект Сокровище» (阿里巴巴 / Ant Group)

Ant Group с мая 2026 года проводит крупнейший редизайн Alipay за двадцать лет — «Проект Сокровище» (Project Treasure / «Баозань»). Ключевой элемент: конверсационный ИИ-агент **«Абао» (Ah Bao / A Bao)**, заменяющий традиционную сетку иконок единым чат-окном. Пользователь свайпом вправо переключается с классического интерфейса на AI-версию.[^1][^2]

**Возможности Абао:**
- Вызов такси, заказ кофе, доставка еды, покупка паевых фондов — через единую текстовую или голосовую команду[^3]
- Более 10 000 сервисов внутри экосистемы Alipay доступны через NL-команды[^1]
- Для мини-программ, не адаптированных разработчиками, используется технология «screen reading» — ИИ симулирует нажатия пользователя[^4]
- Введён «Token Pay» для микротранзакций и «AI Wallets» для автономных агентских трат[^4]
- Окончательное подтверждение любой финансовой операции — только руками пользователя; ИИ не имеет автономного права на списание средств[^1]

По состоянию на май 2026 года Alipay сообщает о более чем **300 миллионах AI-транзакций**, что подтверждает принятие пользователями агентской модели управления финансами.[^4]

**Уроки для BANXE:** «Двойной трек» — классический интерфейс остаётся по умолчанию, AI-версия включается одним свайпом. Ни один платёж не проходит без явного подтверждения пользователя. Для небольших повторяющихся платежей — предзаряженная AI-карта с лимитом.

### 1.2 WeChat Pay и WorkBuddy (Tencent)

Tencent выбрал консервативный путь: встраивание AI-агента **WorkBuddy** в существующую экосистему WeChat без отдельного интерфейса. Запущена **«AI Exclusive Card»** (AI-эксклюзивная карта) — отдельный кошелёк для агентских транзакций с предзарядкой и многоуровневой авторизацией.[^5][^6]

Первый реализованный сценарий: пользователь вызывает «Meituan Life Assistant» в WorkBuddy, спрашивает о групповых скидках поблизости, AI рекомендует список, затем оплата производится через AI-карту с подтверждением.[^6]

**Технические подходы WeChat и Alipay к mini-programs:**
- Alipay: «screen reading» для совместимости без изменений на стороне мерчанта[^4]
- WeChat: два пути для разработчиков — предоставить исходный код («Automatic Mode») или вручную упаковать сервисы в стандартизированные «Skills»[^4]

**Критика (источник Huxia, июнь 2026):** «Ни один AI-платёжный продукт не вышел за рамки традиционной платёжной схемы. Для простых платёжных сценариев прямое нажатие иконки на экране по-прежнему эффективнее, чем описание запроса в естественном языке».[^6]

### 1.3 WeBank: Крупнейший открытый банковский open source стек Китая

WeBank — первый цифровой банк Китая (Shenzhen, основан Tencent) — создал самый масштабный в Азии открытый финтех-стек. Ключевые open source проекты:[^7]

| Компонент | Репозиторий | Назначение |
|-----------|-------------|------------|
| **FATE** (Federated AI Technology Enabler) | [FederatedAI/FATE](https://github.com/FederatedAI/FATE) | Federated learning для обучения ML-моделей на данных без их передачи | [^8] |
| **FISCO BCOS** | [FISCO-BCOS/FISCO-BCOS](https://github.com/FISCO-BCOS/FISCO-BCOS) | Enterprise blockchain для финансовых операций, KYC, аудита | [^9] |
| **WeIdentity** | WeBankFinTech/WeIdentity | Децентрализованная идентификация на блокчейне, аналог SSI | [^10] |
| **WeEvent** | WeBankFinTech/WeEvent | Event-driven архитектура для cross-platform уведомлений | [^10] |
| **WeBASE** | WeBankBlockchain/WeBASE | UI для управления FISCO BCOS-нодами | [^11] |
| **WeDataSphere** | WeBank | Big Data платформа на базе Hadoop/Spark с финансовой защитой | [^12] |
| **WeCube** | WeBank | All-in-one ops-платформа для distributed architecture | [^12] |

FATE используется более чем **1000 организаций по всему миру** и является первым в мире промышленным federated learning фреймворком. Техника Private Set Intersection (RSA-шифрование) позволяет двум банкам совместно обучать модели кредитного скоринга, не передавая друг другу данные клиентов.[^13][^7]

**WeBank производительность:** 750 миллионов транзакций в сутки в пике, обслуживание 290 миллионов клиентов накопленно. 98% входящих обращений клиентов обрабатывается чат-ботом WeBank. eKYC с распознаванием лица выполнил более 640 миллионов верификаций.[^14][^7]

**Применение для BANXE:** FATE — прямое решение для случая, когда BANXE нужно обучать антифрод и кредитные модели совместно с партнёрами-банками без нарушения GDPR (federated learning означает данные не покидают BANXE). FISCO BCOS — audit trail для регуляторов EU AI Act.

### 1.4 MYBank (Ant Group / Alibaba): Cloud-native лидер

MYBank — первый полностью cloud-native банк Китая, работающий на **SofaStack** и **OceanBase**.[^15]

**Ключевые открытые технологии:**
- [SofaStack](https://github.com/sofastack) — масштабируемая open source финансовая архитектура (44 репозитория)[^16]
- OceanBase — distributed SQL database с финансовым уровнем надёжности
- Три AI-системы кредитования: **Tomtit** (сельское финансирование), **Goose** (финансирование цепочки поставок), **Lark** (управление рисками кредитов)[^15]

***

## 2. Япония: Minna Bank — мировой эталон cloud-native цифрового банка

### 2.1 Minna Bank: «Банк для всех»

Minna Bank (яп. «Банк для всех», Fukuoka Financial Group) — первый в Японии полностью цифровой банк, запущен в мае 2021 года. Мировой рекорд: **первый в мире банк на полностью облачном core banking системе на публичном облаке (Google Cloud)**.[^17][^18]

**Технологический стек:**
- Google Cloud (GKE — Google Kubernetes Engine) как единственная инфраструктура
- Microservices архитектура, каждый сервис с собственным GKE-кластером[^19]
- Multi-cloud: Google Cloud + AWS + Azure + Oracle Cloud
- API-first подход, embedded finance через открытые API[^20]
- Разработан и запущен за **20 месяцев** во время пандемии[^21]

В июне 2025 года Zerobank Design Factory (дочерняя компания) **впервые предоставила систему внешнему клиенту** — крупнейшему банку Японии MUFG Bank. Это означает, что Minna Bank-стек теперь доступен как «Banking System as a Service» для других банков.[^18]

**Текущие метрики (2025):** 1,3 миллиона счетов. Получил **Red Dot Design Award 2021** как первое финансовое учреждение с этой наградой.[^22][^18]

**UX-принципы Minna Bank:**
- Только смартфон: нет отделений, нет веб-версии для основных операций
- eKYC 24/7/365 через сканирование водительского удостоверения + видеоподтверждение[^19]
- «Box» (сберегательные ячейки) с хэштегами для целей
- Агрегация счетов из других банков через MoneyForward[^19]
- Встроенный e-commerce внутри банковского приложения[^20]

**Применение для BANXE:** Minna Bank — прямой архитектурный прообраз. Google Kubernetes Engine как инфраструктура; API-first как принцип взаимодействия; «сберегательные ячейки» как UX-паттерн персонализации.

### 2.2 SBI Shinsei Bank: AI-оператор call-центра

В феврале 2026 года SBI Shinsei Bank запустил **AI phone operator** — первый в Японии голосовой ИИ-оператор в call-центре, разработанный совместно со стартапом Recho Inc.. Ключевые характеристики:[^23]
- Естественная разговорная речь, неотличимая от человека[^23]
- Обучен на ~200 вопросно-ответных паттернах
- Способность понимать намерения и управлять прерываниями в диалоге
- Успешность в тестовых сессиях: **99%**[^23]
- Первоначально направлен на обслуживание клиентов 60+ (сервис Bright60)

***

## 3. Южная Корея: KakaoBank и Toss — ИИ-агентный банкинг Gen Z

### 3.1 KakaoBank AI: Интегрированный конверсационный сервис

15 декабря 2025 года KakaoBank запустил **«KakaoBank AI»** — интегрированный конверсационный AI-сервис, объединивший ранее разрозненные AI-функции (AI Search, AI Financial Calculator, AI Transfer, Consultation Chatbot) в единое чат-окно.[^24]

**Добавлен отдельный «AI Tab»** в нижней навигационной панели приложения — одно нажатие для доступа к AI из любого места. В верхней части экрана ИИ проактивно предлагает полезную информацию: «Спросите AI» или «Сообщу расписание налогового вычета».[^24]

**24 ноября 2025:** KakaoBank запустил **первый в Южной Корее AI Transfer** — перевод через обычный диалог с ИИ. Пользователь пишет «Мама, 300 000 вон» — ИИ распознаёт получателя (по истории переводов), сумму и инициирует перевод. При неясности ИИ переспрашивает.[^25]

**Стек KakaoBank:** **Azure OpenAI** (GPT-4o) запущен 26 мая 2025 года — первый в Корее AI Search для банковского мобильного приложения.[^26]

**Планы:** AI Group Treasurer (групповая касса с ИИ), AI Sign Language Consultation для глухих клиентов, расширение AI на продуктовые объяснения и инвестиционные сервисы.[^24]

### 3.2 Toss Bank: AI-агент следующего поколения

17 декабря 2025 года Toss Bank получил designation Financial Innovation Service (регуляторный статус финансовой инновации) для AI-консультанта нового поколения.[^27]

**Архитектурные особенности:**
- Специализированные AI-агенты по продуктам (в отличие от единого генерального агента)[^27]
- LLM понимает не только FAQ, но и сложные продуктовые процедуры и внутренние политические документы[^27]
- Проактивная защита потребителей: AI обнаруживает и устраняет повторяющиеся жалобы клиентов[^27]
- 4 сервиса на AWS Bedrock: Code Review, Marketing & Legal Review, Management & Financial Analysis, Text to SQL[^28]

**HelpChat** — собственная система чат-консультирования с **4-кратным ускорением** ответа по сравнению с внешним решением. Доступна без регистрации в Toss через веб-браузер.[^29]

**AI-верификация документов:** 99,5% точность обнаружения поддельных ID на базе 100 000+ образцов. Голосовая транскрипция 150 000 звонков в месяц в реальном времени (собственная STT-модель).[^30]

**Сравнение KakaoBank vs Toss vs K Bank (апрель 2026)**:[^31]

| Параметр | KakaoBank | Toss Bank | K Bank |
|----------|-----------|-----------|--------|
| Конверсационный интерфейс | ✅ Полный AI Tab | Частичный (keyword chatbot) | AI-поиск только |
| AI Transfer | ✅ Запущен | В разработке | Нет |
| Собственные LLM | Нет (Azure OpenAI) | В разработке | Нет |
| Регуляторный статус ИИ | Обычный | 6 Financial Innovation | Нет |
| AWS Bedrock | Нет | ✅ 4 сервиса | Нет |

***

## 4. Юго-Восточная Азия: Экосистема суперприложений

### 4.1 Сингапур — DBS: «Лучший AI-банк в мире 2025»

DBS Bank (Сингапур) — признан **World's Best AI Bank** в 2024–2025 годах (Global Finance). Ключевые метрики за 2025 год:[^32]
- **430+ AI use cases**, работающих на более чем **2000 AI-моделях**[^33]
- **S$1 миллиард экономической стоимости** от AI-инициатив (рост на 33% по сравнению с S$750 млн в 2024)[^34]
- **Harvard Business School** опубликовал первый в истории кейс-стади об AI-стратегии азиатского банка на примере DBS[^32]

**DBS Joy** (корпоративный AI-ассистент, запущен ноябрь 2025):[^32]
- Обрабатывает более **15 000 AI-чатов в месяц**[^33]
- Customer Satisfaction Score улучшился на **23%**[^32]
- Снижение удержания на линии (hold time) на **33%** через CSO Assistant[^33]

**DBS-GPT** предоставляет всем 40 000 сотрудникам банка возможность создавать **персональные AI-агенты** и иметь доступ к 4 миллионам документов.[^33]

**Пилот Visa Intelligent Commerce (февраль 2026):** DBS — первый банк в Азиатско-Тихоокеанском регионе, тестирующий платёжные агенты от Visa.[^35]

### 4.2 Сингапур — OCBC: «Avatar Banking» с Wendy и Wayne

1 июля 2026 года OCBC запустил **OCBC WoW** — «avatar banking» платформу с виртуальными финансовыми советниками:[^36]
- Два аватара: **«Wendy»** и **«Wayne»**, созданные на основе реальных сотрудников OCBC
- Знают портфель клиента и персонализированы под него
- Пример запроса: «Что будет означать добавление SpaceX в мой портфель?»[^36]
- Начальный запуск: 50 пользователей (бета), затем wealth-клиенты, потом ритейл
- OCBC планирует инвестировать **более S$1 миллиарда ежегодно** в течение 3 лет на AI[^36]

**Важный принцип:** аватары пока работают только на английском; расширение до мандаринского, бахаса Индонезия, бахаса Малайзия планируется.[^36]

### 4.3 Малайзия: GXBank и Ryt Bank — AI-цифровые банки

По данным Bank Negara Malaysia, пять цифровых банков Малайзии к концу 2025 года: **2,4 миллиона клиентов и RM 4,2 миллиарда депозитов**.[^37]

- **GXBank** (Grab-backed): 1,4 миллиона пользователей, 450 миллионов транзакций с запуска, 70% acceptance rate по SME-кредитам[^37]
- **Ryt Bank**: 1,2 миллиона пользователей — позиционирует себя как AI banking bank

### 4.4 Гонконг: WeLab Bank — AI-First с DeepSeek и Google

WeLab Bank — крупнейший цифровой банк Гонконга по выручке:[^38]
- Первый в Азии банк, развернувший **DeepSeek локально** (в замкнутой среде для безопасности данных)[^39]
- Стратегическое партнёрство с **Google** (Gemini, Veo, Vertex AI)[^38]
- H1 2025: ~HK$460 миллионов выручки (+70% год к году)[^38]
- NIM 10,7% — намного выше рыночного среднего (единичные цифры)[^38]
- Деlinquency rate упал на 3,7% при росте рынка на 8,5%[^38]
- В январе 2026 года: раунд Series D — **US$220 миллионов**, крупнейший для цифрового банка в Азии в 2025 году[^40]

**Ключевая UX-инновация:** AI-powered FX service с «Best Rate Guarantee» — первый в Гонконге. AI-сравнение курсов в реальном времени, 0% наценка, гарантия лучшего курса.[^41]

### 4.5 Вьетнам: MoMo и VietBank

**MoMo** (Вьетнам) — каждая транзакция обрабатывается **6–7 AI-моделями одновременно**. AI-кредитный скоринг занял топ-3 в рейтинге AI Excellence Awards Вьетнама.[^42]

**VietBank:** построил AI-системы полностью in-house на open source компонентах с self-hosted LLM — «потому что чувствительные банковские данные не должны покидать банк». Система документооборота SOTs сократила циклы согласования на **35%**, создана за 3,5 месяца с ограниченным бюджетом.[^43]

***

## 5. Латинская Америка: Nubank — Эталонная AI-архитектура на открытом стеке

### 5.1 Nubank: крупнейший цифровой банк мира

Nubank (Бразилия, листинг NYSE, тикер NU) — **120+ миллионов клиентов** в Бразилии, Мексике и Колумбии; рыночная капитализация $80–120 миллиардов. В 2026 году инвестиции в Бразилии — **R$45 миллиардов (US$8,2 млрд)**, из которых значительная часть — на AI.[^44][^45][^46]

**Nubank AI-стек (технические детали, ICLR 2026):**[^47]
1. **nuFormer** — трансформерная self-supervised модель, обученная на последовательностях транзакций (не на NL-тексте). Учит «язык денег» из миллиардов транзакций
2. **4-уровневая LLM-экосистема**: LangChain + LangGraph + LangSmith + automated evaluation pipelines
3. **LLM-as-a-judge**: каждый ответ оценивается вторым LLM по критериям: Correctness, Conciseness, Preference Alignment[^48]
4. **DSPy + Japa optimizer**: автоматическая оптимизация промтов вместо ручного написания (устойчивость при смене версии LLM)[^48]
5. **Prompt Semantic Versioning**: промты делятся на модули (Tone, Tooling, Safety), каждый версионируется независимо[^48]
6. **Composite Tools**: детерминированные бизнес-процессы вынесены в tool-функции, LLM только «нажимает кнопку», не рассуждает о последовательности шагов[^48]

**Производственные результаты:**
- **8,5 миллионов обращений клиентов в месяц**, 60% решаются при первом касании через LLM[^49]
- Сценарий AI Transfer: время взаимодействия снизилось с **70 секунд (9 экранов) до <30 секунд**[^49]
- Evals-First подход: 100% аудит разговоров через TNPS вместо традиционного NPS[^48]
- Автоматические Simulation + Red-Teaming перед каждым продакшн-запуском[^48]
- Архитектура приобретённого стартапа **Hyperplane** (Silicon Valley) — proprietary foundation models на first-party financial data[^49]

**Голосовой банкинг в WhatsApp:** «Отправь 50 реалов Марии» — интеграция с WhatsApp без открытия банковского приложения. Nubank обрабатывает **каждую четвёртую Pix-транзакцию в Бразилии**.[^45]

### 5.2 MercadoPago: AI-ассистент на 68 миллионов пользователей

В октябре 2025 года Mercado Pago (LatAm, 68 млн пользователей) запустил **AI Financial Assistant**:[^50]
- Доступен через текст или голос
- Первая версия: оплата счетов, переводы, анализ расходов, создание и управление сберегательными целями
- **60+ функций** через конверсационный интерфейс[^51]
- Официальный Claude Marketplace плагин: Mercado Pago Claude Marketplace — первый в LatAm верифицированный Anthropic плагин для банка[^52]

**Открытая документация:** [https://www.mercadopago.cl/developers/en/docs/ai-resources](https://www.mercadopago.cl/developers/en/docs/ai-resources)[^52]

### 5.3 BBVA Mexico: «Blue» — 34 миллиона клиентов с ChatGPT

Январь 2026 года: BBVA Mexico запустил **бесплатный ChatGPT Go** для всех **34 миллионов клиентов** — глобальное партнёрство с OpenAI, подписанное в 2025 году.[^53]

Виртуальный ассистент **Blue** интегрирован в BBVA Mx app — **27 миллионов индивидуальных пользовательских опытов**, один на каждого клиента. Гиперперсонализация на основе транзакционного следа.[^54]

**Latin America Digital Neo-Banking Market:** $18,5 млрд в 2025 году → прогноз $148,7 млрд к 2034 году, CAGR 28%.[^55]

***

## 6. Ближний Восток: GCC Banking AI — Переход от пилотов к production

ОАЭ, Саудовская Аравия и Бахрейн объявили 2026 год годом, когда AI перестаёт быть «слайдами» и становится частью ядра банковской инфраструктуры. Восемь крупнейших банков ОАЭ развернули **open finance** системы в 2025 году.[^56]

**AI-применения в регионе:**
- AI кредитный скоринг для SME (сжатие сроков одобрения с дней до часов)[^56]
- Генеративное составление кредитных решений с учётом Sharia-compliant продуктов[^56]
- AI customer onboarding с проверкой документов
- Рынок AI-в-fintech GCC: **US$7 миллиардов**, прогноз сильного роста до 2030[^56]

**Saudi Arabia Vision 2030:** First open banking license (Lean Technologies) — первый в Саудовской Аравии. **Tabby** (Buy Now Pay Later, Саудовская Аравия): оценка $4,5 миллиарда в 2026 году.[^57]

***

## 7. Австралия: ANZ — Первый в APAC Agentic AI CRM

В феврале 2026 года ANZ Bank развернул **Salesforce Agentforce 360** — первый в Азиатско-Тихоокеанском регионе коммерческий agentic AI CRM в банковском масштабе:[^58]
- Консолидация данных из **20 платформ** в единый дашборд[^59]
- Bankers экономят **эквивалент одного рабочего месяца в год**[^59]
- ANZ Plus и Transactive for corporate clients — designed for agentic AI from day one[^60]

**CBA (Commonwealth Bank Australia)** — стратегические инвестиции в Anthropic, использование Claude для трансформации клиентского опыта.[^60]

***

## 8. Африка: M-Pesa MCP — ИИ-агенты для мобильных денег

Разработчик Gabriel Mahia создал **mpesa-mcp** — первый MCP-сервер для африканских финтех-API:[^61]
- `pip install mpesa-mcp` или `uvx mpesa-mcp`
- Инструменты: `mpesa_stk_push`, `mpesa_stk_query`, `mpesa_transaction_status`, `sms_send`, `airtime_send`[^61]
- Поддержка Paystack (Нигерия/Гана/Кения/ЮАР), MTN Mobile Money (17 стран)[^61]
- Первый African fintech вход в awesome-mcp-servers (82k звёзд)[^61]

Это означает: **ИИ-агент BANXE может через MCP напрямую вызывать M-Pesa, MTN MoMo, Paystack** — без кастомных интеграций.

***

## 9. Архитектурные паттерны: Чему учит мировой опыт

### 9.1 Общие паттерны успешных банков-ИИ-агентов

На основе анализа более 20 банков из 10 регионов выделяются следующие паттерны:

| Паттерн | Примеры | Применение для BANXE |
|---------|---------|---------------------|
| **Dual-Track UX** — классический + AI | Alipay, KakaoBank | Внедрение без ломки привычек |
| **Composite Tools** — детерминированная бизнес-логика вне LLM | Nubank | Уменьшение галлюцинаций |
| **TNPS вместо NPS** | Nubank | Реальный A/B контроль качества ИИ |
| **Local LLM deployment** | WeLab Bank (DeepSeek), VietBank | GDPR-совместимость, безопасность |
| **Federated Learning для данных** | WeBank FATE | Обучение без передачи клиентских данных |
| **Специализированные агенты по продуктам** | Toss Bank | Меньше ошибок, чем у генерального агента |
| **Avatar Banking** | OCBC Wendy & Wayne | Доверие через персонализацию |
| **Payment Confirmation Gate** | Alipay Abao, WeChat AI Card | EU AI Act / защита потребителей |
| **MCP-first** для внешних сервисов | Alipay, MercadoPago | Открытая экосистема партнёров |

### 9.2 Nubank «5 Hardest Lessons» — Blueprint для BANXE

На конференции ICLR 2026 и QCon AI NY Nubank опубликовал 5 ключевых уроков для production AI-агентов:[^48]

1. **Evals-First**: измеряйте 100% разговоров через LLM-as-judge, не ждите ручных NPS-отзывов
2. **ReAct Paradigm**: агент = Prompt (мозг) + Tools (руки) + Data (память RAG + сессионный контекст)
3. **Prompt Optimization не ручной**: используйте DSPy, Japa, Semantic Versioning — не пишите пятистраничные промты вручную
4. **Не файн-тюнить без повода**: настройка весов модели нужна только для последних 5% точности; сначала исчерпайте потенциал frontier models
5. **Move Logic to Tools**: детерминированные цепочки шагов — в composite tools, LLM только принимает решение «какой tool вызвать»

***

## 10. Open Source стек для «Фабрики» BANXE: Лучшие решения по регионам

### 10.1 Расширенная таблица open source компонентов с мировым опытом

| Категория | Компонент | Звёзды / Лицензия | Кто использует | Статус |
|-----------|-----------|-------------------|----------------|--------|
| **Federated AI** | FATE (WeBankFinTech) | 5.7k / Apache 2.0 | WeBank, 800+ компаний | Production | [^8] |
| **Enterprise Blockchain** | FISCO BCOS | 3.4k / Apache 2.0 | 5000+ организаций Китая | Production | [^9] |
| **Core Banking** | Formance Stack | $21M funded / MIT | EU Neobanks | Production | |
| **Decentralized Identity** | WeIdentity | — / Apache 2.0 | WeBank | Production | [^10] |
| **Conversational UI** | assistant-ui | 7k+ / MIT | YC W25 | Production | |
| **Conversational React** | rustic-ui-components | — / MIT | AI chat platforms | Active | [^62] |
| **Agent Framework** | LangGraph | 12k+ / MIT | Nubank, 1000s | Production | [^48] |
| **Prompt Optimization** | DSPy | 24k+ / MIT | Nubank, Stanford | Research→Prod | [^48] |
| **LLM Gateway** | LiteLLM | 18k+ / MIT | Banks, enterprises | Production | |
| **Vector DB** | Qdrant | 22k+ / Apache 2.0 | Enterprise banking | Production | |
| **Observability** | Langfuse | 8k+ / MIT | AI-first companies | Production | |
| **MCP Payments Africa** | mpesa-mcp | — / MIT | Kenya, 20+ countries | Active | [^61] |
| **Banking Infrastructure** | SOFAStack (Alibaba) | 9k+ / Apache 2.0 | MYBank, Alibaba | Production | [^16] |
| **Voice** | Whisper (OpenAI) | 75k+ / MIT | SBI Shinsei, OCBC | Production | |
| **Workflow** | Temporal | 12k+ / MIT | Nubank, Stripe | Production | |
| **Event Streaming** | Apache Kafka | 29k+ / Apache 2.0 | Nubank (Kafka + Datomic) | Production | |

### 10.2 Особые рекомендации для фабрики BANXE (по региону)

**Из опыта Китая (WeBank/MYBank):**
- FATE для federated learning — совместимо с GDPR через federated architecture
- FISCO BCOS для audit trail — все транзакции агента записаны в неизменяемый ledger
- SOFAStack — production-ready microservices framework для финтех

**Из опыта Японии (Minna Bank):**
- Multi-cloud на GKE (Google Kubernetes Engine) — первый в мире банк на public cloud
- API-first: каждая функция доступна как API для embedded finance
- Zerobank Design Factory — возможный партнёр для BANXE

**Из опыта Кореи (Toss/Kakao):**
- AWS Bedrock для быстрого старта LLM-агентов с финансовой специализацией
- Специализированные агенты по продуктам (Toss approach) — лучше, чем один general agent

**Из опыта Латинской Америки (Nubank):**
- LangGraph + LangSmith + LangChain как основной AI-orchestration stack
- DSPy для автоматической оптимизации промтов
- Composite Tools как архитектурный принцип

**Из опыта Юго-Восточной Азии (DBS/WeLab):**
- Self-hosted LLM (DeepSeek R1/V2) для compliance и безопасности данных
- Google Gemini via Vertex AI для production deployments
- Open Banking API через Axway или Adorsys PSD2 Gateway

***

## 11. Промт-поручение для AI-дизайнера BANXE (версия 2.0 — глобальный опыт)

Следующий мастер-промт предназначен для группы AI-дизайнеров (Figma AI / Nodey / UX Pilot / v0.dev / Bolt.new), синтезирующий лучшее из всех изученных банков.

***

```
MASTER PROMPT: BANXE AI BANK — GLOBAL BEST-IN-CLASS UX/UI v2.0

КОНТЕКСТ ПРОЕКТА:
Ты — AI-дизайнер, разрабатывающий приложение EMI BANXE AI BANK. Это банк нового поколения для EU-рынка (GDPR, EU AI Act, PSD3), построенный на open source стеке. Клиенты банка — цифровые мигранты, фрилансеры, SME-предприниматели в Европе.

ТВОЯ ЗАДАЧА:
Создать полный дизайн-пакет для мобильного (iOS/Android) и веб-приложения банка-ИИ-агента. Дизайн должен воплощать концепцию «Hybrid Intent Interface» — пользователь может взаимодействовать через чат/голос ИЛИ через традиционные кнопки, по своему выбору.

ВДОХНОВЛЯЮЩИЕ ЭТАЛОНЫ (обяательно изучи):
1. Alipay «Project Treasure» (Абао) — June 2026: dual-track design, один свайп для AI-режима
2. KakaoBank AI Tab (December 2025): AI Tab в bottom navigation, проактивные подсказки вверху
3. Nubank Mobile (Brazil): минималистичный дизайн, хроматически чистый, акцент на числах
4. WeLab Bank (Hong Kong): «Where life meets intelligence», тёмная тема, trust-первый дизайн
5. Minna Bank (Japan): Red Dot Award 2021, первая цифровая банковская награда за дизайн
6. OCBC WoW Avatar Banking (July 2026): персонализированные AI-аватары-консультанты
7. DBS Joy (Singapore): корпоративный AI-чат с 23% ростом CSAT
8. Toss (Korea): Gen Z-ориентированный, игровые элементы, прозрачность данных
9. MercadoPago AI Assistant (LatAm): 60+ функций в одном конверсационном UI

ОБЯЗАТЕЛЬНЫЕ ЭКРАНЫ ДЛЯ РАЗРАБОТКИ:

=== МОБИЛЬНОЕ ПРИЛОЖЕНИЕ (iOS + Android) ===

ЭКРАН 1 — HOME SCREEN (DUAL-TRACK):
- Вверху: персонализированное приветствие («Доброе утро, Мориэль») + баланс крупным шрифтом
- Проактивная AI-карточка: «Анализирую ваши расходы за неделю...» с CTA
- Quick Actions row: Перевод / Платёж / Валюта / Вложить
- НИЖНЯЯ НАВИГАЦИЯ: Home | История | [AI TAB — центр, выделен] | Карты | Профиль
- AI Tab: пульсирующий иконка-индикатор активности агента

ЭКРАН 2 — AI CHAT (HYBRID INTENT INTERFACE):
- Чистый чат-интерфейс с градиентным фоном (#0A0E1A → #1A1F35)
- Строка ввода с микрофоном справа (голос Whisper)
- Rich Cards появляются прямо в чате:
  * TransferCard (получатель, сумма, кнопка Подтвердить/Отмена)
  * SpendingInsightCard (график трат за месяц с категориями)
  * ExchangeCard (курс EUR/USD/GBP с AI Best Rate Guarantee как WeLab)
  * LoanOfferCard (персональное предложение на основе поведения)
- Typing indicator когда агент «думает»
- Decision Lineage (EU AI Act): значок ⓘ на каждом решении, нажав — объяснение почему

ЭКРАН 3 — TRANSFER (CONVERSATIONAL + CLASSIC):
- Две вкладки вверху: [Написать/Сказать] | [Форма]
- Режим «Написать»: пользователь набирает «Переведи 200 евро Ивану» — AI парсит, показывает TransferCard
- КРИТИЧЕСКИ ВАЖНО: финальный экран подтверждения ВСЕГДА требует биометрии (Face ID / Touch ID)
- Отображать: «AI предложил → Ты подтверждаешь» (EU AI Act принцип human-in-the-loop)

ЭКРАН 4 — SPENDING ANALYTICS:
- Главный виджет: категорированные расходы за текущий месяц (sunburst chart)
- AI Insight: «В этом месяце ты тратишь на 23% больше на рестораны» с конкретной рекомендацией
- Временная шкала: неделя / месяц / 3 месяца / год
- Сравнение с прошлым периодом в виде simple horizontal bars

ЭКРАН 5 — SAVINGS POCKETS (паттерн Minna Bank / KakaoBank):
- Визуальные «карманы» (circles/containers) для целей
- AI предлагает создать новый pocket на основе паттернов расходов
- Progress bars с геймификацией (звёздочки при достижении 25/50/75/100%)
- Каждый pocket: имя цели, emoji, сумма, дата достижения AI-прогноз

ЭКРАН 6 — KYC / ONBOARDING (3 шага максимум):
- Шаг 1: Фото документа + selfie (eKYC, паттерн Minna Bank)
- Шаг 2: Подтверждение данных + согласия GDPR (progressive disclosure — одно согласие на экране)
- Шаг 3: AI-приветствие агента «Я уже изучил ваш профиль...» с первым insight

ЭКРАН 7 — VOICE INTERFACE (Push-to-Talk):
- Большая кнопка микрофона в центре (паттерн Google Assistant)
- Живые волны звука во время записи
- Транскрипция появляется в реальном времени (Whisper)
- Результат AI-ответа: Rich Card или текст + голос TTS

ЭКРАН 8 — NOTIFICATIONS CENTER:
- Умная группировка: Транзакции | AI-инсайты | Безопасность | Советы
- AI-генерированные push: «Ваш счёт за электричество будет списан через 3 дня. Нужна помощь?»
- Нажатие на уведомление → сразу открывает релевантный экран или AI-чат

ЭКРАН 9 — COMPLIANCE / AUDIT TRAIL (EU AI Act):
- Раздел «Мои данные и ИИ»
- История решений AI (когда и почему AI что-то предложил)
- Переключатели: «Использовать AI для анализа расходов», «AI-советы по инвестированию»
- Export GDPR-данных в один клик
- «Объяснить решение» для любого AI-действия

ЭКРАН 10 — SETTINGS & PROFILE:
- Биометрия, 2FA, PIN
- Уровень AI-автономии: Ручной → Помощник → Полуавтономный
- Языковые настройки (EU: EN, FR, DE, ES, IT, RU)
- Обратная связь по качеству AI

=== ВЕБ-ВЕРСИЯ (Desktop + Responsive) ===

WEB-1 — DASHBOARD:
- Left sidebar: навигация (Обзор, Переводы, Аналитика, AI Советник, Настройки)
- Центр: виджеты-карточки с балансом, последними транзакциями, AI-инсайт дня
- Справа: AI Chat panel (collapsible) — всегда доступен без перехода на другую страницу
- Header: поисковая строка («Найди транзакцию...», «Сколько я потратил в апреле?»)

WEB-2 — AI ADVISOR PAGE:
- Полноэкранный чат + history слева
- Возможность прикрепить документ (выписка, счёт) для анализа
- AI отвечает Rich Cards: таблицы, графики, карточки транзакций прямо в чате
- Для бизнес-клиентов: экспорт аналитики в PDF / CSV

WEB-3 — TRANSACTION HISTORY:
- Фильтрация через естественный язык: «Покажи все рестораны в Ницце за май»
- AI категоризация с возможностью ручной корректировки
- Bulk action: «Категоризировать все похожие транзакции как Еда»

ДИЗАЙН-СИСТЕМА:

ЦВЕТА:
- Primary: #1A1F35 (deep navy, как WeLab Bank «Where life meets intelligence»)
- Accent: #00D4AA (teal-green, доверие + технологии)
- Success: #22C55E | Warning: #F59E0B | Error: #EF4444
- Background Light: #F8FAFC | Background Dark: #0A0E1A
- Text Primary: #1E293B | Text Secondary: #64748B
- AI Indicator: #8B5CF6 (фиолетовый для всего AI-генерированного)

ТИПОГРАФИКА:
- Heading: Inter Variable (open source, как у Revolut, Toss)
- Body: Inter
- Monospace (числа, балансы): JetBrains Mono
- Размеры: 12/14/16/20/24/32/40px

ИКОНКИ: Lucide Icons (open source MIT, совместимы с Figma и React)

КОМПОНЕНТЫ (open source):
- Chat UI: assistant-ui (MIT, YC W25) — https://github.com/assistant-ui/assistant-ui
- Conversational React: rustic-ui-components (MIT) — https://github.com/rustic-ai/rustic-ui-components
- Base UI: shadcn/ui (MIT) — https://ui.shadcn.com
- Charts: Recharts или Chart.js (MIT)
- Animations: Framer Motion (MIT)

ПРИНЦИПЫ UX (обязательны):

1. TRUST FIRST: каждое AI-действие с финансами требует явного подтверждения пользователя (EU AI Act)
2. DUAL-TRACK: классический + AI режим доступны всегда (паттерн Alipay Project Treasure)
3. PROGRESSIVE DISCLOSURE: не показывать все функции сразу; AI вводит новые возможности контекстно
4. RICH CARDS вместо текстовых ответов: конверсационный UI должен генерировать интерактивные карточки
5. AUDITABILITY: каждое AI-решение — кнопка ⓘ «Почему AI так решил?» (EU AI Act Article 13)
6. ACCESSIBILITY: WCAG 2.1 AA минимум; AI Sign Language Consultation (паттерн KakaoBank)
7. ЛОКАЛИЗАЦИЯ: EU multi-language из коробки (i18n)
8. БЕЗОПАСНОСТЬ: никаких финансовых операций без биометрии (паттерн всех азиатских банков)
9. AI LEVEL CONTROL: пользователь сам регулирует автономность агента (slider: Ручной → Полуавтономный)
10. SPEED: все экраны <300ms time-to-interactive; AI Rich Cards стримятся, не блокируют UI

ФОРМАТ ВЫВОДА:
- Figma файл со всеми экранами и компонентами
- Design System документация (цвета, типографика, компоненты)
- Прототип с clickable flows (онбординг, перевод через AI, AI-аналитика)
- React Native / Flutter компоненты для мобильной версии
- Responsive CSS (Tailwind CSS v4) для веб-версии
- Accessibility audit report (WCAG 2.1 AA)
```

***

## 12. CI/CD «Фабрика» BANXE: Агентная интеграция

GitHub в феврале 2026 года запустил **Agentic Workflows** в Technical Preview — AI-агенты внутри GitHub Actions, которые автоматически триажируют ошибки сборки, открывают PR с исправлением, тагируют нужного ревьюера.[^63][^64]

**Архитектурный паттерн агентного CI/CD для BANXE (на основе production примеров):**[^65]

```
Detection → Diagnosis → Fix → Deploy

Специализированные агенты:
- Analysis Agent: код-ревью каждого PR (Claude Code Action)
- Security Agent: сканирование OWASP Top 10 LLM + Agents (флаггирует уязвимости)
- Execution Agent: развёртывание в staging (threshold confidence ≥ 0.90 для prod)
```

**Threshold таблица для BANXE:**

| Риск | Threshold | Действие |
|------|-----------|----------|
| Низкий | 0.60+ | Комментарии кода, теги |
| Средний | 0.75+ | Запуск тестов, staging deploy |
| Высокий | 0.90+ | Production deploy, инфра-изменения |

**Каждое агентное действие записывается в audit log** — требование EU AI Act для high-risk AI systems.[^65]

***

## Заключение: Топ-10 «продвинутых создателей» банков-ИИ-агентов в мире

| Ранг | Банк / Компания | Страна | Главный вклад |
|------|----------------|--------|---------------|
| 1 | **WeBank** | Китай | FATE (federated learning), FISCO BCOS, open source banking ecosystem |
| 2 | **Nubank** | Бразилия | LangGraph+LangSmith stack, nuFormer, 5 production lessons, 131M users |
| 3 | **DBS Bank** | Сингапур | 430 AI use cases, S$1B value, World's Best AI Bank |
| 4 | **Alipay / Ant Group** | Китай | «Абао» conversational super-app, 300M AI transactions |
| 5 | **KakaoBank** | Корея | Первый AI Transfer, KakaoBank AI Tab, Azure OpenAI |
| 6 | **Minna Bank** | Япония | Первый cloud-native banking system (Google Cloud), Red Dot Design Award |
| 7 | **WeLab Bank** | Гонконг | AI-first с DeepSeek local, Google Gemini, Best Rate Guarantee FX |
| 8 | **Toss Bank** | Корея | 6 Financial Innovation designations, AWS Bedrock, composite AI agents |
| 9 | **MercadoPago** | LatAm | Claude Marketplace плагин, 60+ функций в AI Assistant |
| 10 | **VietBank** | Вьетнам | 100% in-house open source AI, SOTs за 3,5 месяца, ASEAN Innovation Award |

---

## References

1. [Alipay and WeChat Pay Race to Turn AI Agents Into China’s New Shopping Gateways - The China Technology Review](https://the-ctr.net/alipay-and-wechat-pay-race-to-turn-ai-agents-into-china-s-new-shopping-gateways) - China’s payment giants turn to AI China’s two dominant digital payment platforms are moving beyond t...

2. [AI-Powered Alipay in Internal Testing: Biggest Revamp in 20 Years, Conversational UI Replaces Traditional Interface](https://aiskillnav.com/en/news/ai-alipay-beta-testing-ltwweb) - Ant Group is internally testing an AIpowered version of Alipay, codenamed "Bao Project," marking the...

3. [Jack Ma-backed Ant Group set for high-stakes overhaul of billion-user Alipay](https://www.businesstimes.com.sg/companies-markets/banking-finance/jack-ma-backed-ant-group-set-high-stakes-overhaul-billion-user-alipay) - The company’s impending update reflects a broader trend sweeping the AI arena Read more at The Busin...

4. [Fully Entering the AI Era: Alipay Bets on Conversation, WeChat Holds Fast to Social | Approfondimenti HTX](https://www.htx.com/it-it/news/fully-entering-the-ai-era-alipay-bets-on-conversation-wechat-44wjLqD1/) - In May 2026, Alipay announced over 300 million AI payment transactions. Shortly after, WeChat opened...

5. [WeChat Pay's “AI Exclusive Card” to Launch as Early as This Week ...](https://news.futunn.com/en/post/74665968/exclusive-wechat-pay-s-ai-exclusive-card-to-launch-as) - ①WeChat Pay is collaborating with Tencent’s intelligent agent product WorkBuddy to test AI-powered p...

6. [China Digital Retail Report (@chinadigitalretailreport)](https://substack.com/@chinadigitalretailreport/note/c-282628236?r=7f0cdi) - DO AI AGENTS FOR ALIPAY AND WECHAT PAY LACK ADDED VALUE? Last week, both Alipay and WeChat Pay launc...

7. [WeBank leads in financial performance and application of AI and ...](https://www.theasianbanker.com/updates-and-articles/webank-recorded-best-financial-growth-among-peer-banks-with-excellent-digital-service) - The bank's AI team developed the open source industrial grade Federated Learning Framework FATE (“Fe...

8. [GitHub - FederatedAI/FATE: An Industrial Grade Federated Learning ...](https://github.com/federatedai/fate) - FATE (Federated AI Technology Enabler) is the world's first industrial grade federated learning open...

9. [FISCO-BCOS/docs/README_EN.md at master · FISCO-BCOS/FISCO-BCOS](https://github.com/FISCO-BCOS/FISCO-BCOS/blob/master/docs/README_EN.md) - FISCO BCOS（发音为/ˈfɪskl bi:ˈkɒz/）是一个稳定、高效、安全的许可区块链平台，已被广泛应用于现实的行业应用。截至目前，已拥有5000多家企事业单位，400多个产业数字化标杆应用...

10. [GitHub - WeBankBlockchain/All-Projects](https://github.com/WeBankBlockchain/All-Projects) - Contribute to WeBankBlockchain/All-Projects development by creating an account on GitHub.

11. [FISCO BCOS, the Most Popular Permissioned Framework in Chinese Mainland](https://medium.com/use-case-library/fisco-bcos-the-most-popular-permissioned-framework-in-chinese-mainland-da8baae96266) - FISCO BCOS is a reliable, secure, and efficient open-source blockchain platform built by the FISCO o...

12. [Prime Minister of the Republic of Singapore Intrigued by WeBank's Fintech-powered Services at SFF x SWITCH](https://www.prnewswire.com/news-releases/prime-minister-of-the-republic-of-singapore-intrigued-by-webanks-fintech-powered-services-at-sff-x-switch-300957345.html) - /PRNewswire/ -- From Nov. 11 to 13, 2019, WeBank showcased a series of new generation fintech capabi...

13. [Utilization of FATE in Risk Management of Credit in Small and Micro Enterprises](https://medium.com/@FateFedAI/utilization-of-fate-in-risk-management-of-credit-in-small-and-micro-enterprises-85683d447cb0) - Authors: Henry Zhang, Layne Peng

14. [WeBank: The World's Leading Digital Bank Decoded](https://www.prnewswire.com/in/news-releases/webank-the-world-s-leading-digital-bank-decoded-811666527.html) - /PRNewswire/ -- From Nov. 11 - 13, 2019, WeBank, the first digital-only bank in China, will showcase...

15. [MYbank's Jiang Hao: “The adoption of AI in banking is irreversible”](https://www.theasianbanker.com/updates-and-articles/mybanks-jiang-hao-the-adoption-of-ai-in-banking-is-irreversible) - China’s first cloud-native digital-only bank showcased digital solutions at the 2023 Singapore Finte...

16. [SOFAStack](https://github.com/orgs/sofastack/repositories) - Scalable Open Financial Architecture Stack. SOFAStack has 44 repositories available. Follow their co...

17. [Japan’s first digital ‘bank for everyone’ starts commercial operations in May](https://www.bernama.com/en/news.php?id=1945708) - Japan’s first digital ‘bank for everyone’ st

18. [Das vollständig cloudbasierte Bankensystem der Minna Bank wird der MUFG Bank und damit zum ersten Mal extern bereitgestellt](https://www.businesswire.com/news/home/20250623146705/de) - Minna Bank gab bekannt, dass das vollständig cloudbasierte Bankensystem, das von Zerobank Design Fac...

19. [Minna Bank – the new Japanese bank with digital natives at its core ...](https://www.retailbankerinternational.com/features/minna-bank-the-new-japanese-bank-with-digital-natives-at-its-core-gets-off-to-a-flier-2/) - Japan’s digital challenger Minna Bank only fully launched in May 2021 but aims is to achieve 1.2 mil...

20. [Japan's Minna Bank Revolutionizes Digital Finance with ...](https://www.linkedin.com/posts/rafey-hussain-b66720279_digitalbanking-fintech-neobank-activity-7432863026648641536-RfGZ) - 🚨 What happens when a 100-year-old banking mindset meets cloud-native innovation? Japan built Minna ...

21. [Japan's first smartphone-only bank built from scratch for the ...](https://www.qorusglobal.com/innovations/23030-japans-first-smartphone-only-bank-built-from-scratch-for-the-digital-native-generation) - Minna Bank was established in 2021 as Japan's first digital bank targeting digital natives. The bank...

22. [Minna Bank's Full Cloud-Based Banking System to be Provided ...](https://markets.financialcontent.com/stocks/article/bizwire-2025-6-26-minna-banks-full-cloud-based-banking-system-to-be-provided-externally-for-the-first-time-to-mufg-bank) - Minna Bank's Full Cloud-Based Banking System to be Provided Externally for the First Time to MUFG Ba...

23. [Japan's SBI Shinsei Bank introduces AI phone operator that can ...](https://mainichi.jp/english/articles/20260206/p2a/00m/0bu/010000c) - Japan's SBI Shinsei Bank introduces AI phone operator that can converse naturally. February 7, 2026 ...

24. [Launch of Integrated Service "KakaoBank AI"](https://view.asiae.co.kr/en/article/2025121509114183684) - KakaoBank launched "KakaoBank AI," an integrated conversational artificial intelligence (AI) service...

25. [“Mom, 300000 won,” say it and the AI transfers···KakaoBank launches ...](https://www.khan.co.kr/en/article/202511241639537) - “Mom, 300,000 won.” On the 24th, internet-only bank KakaoBank launched the first transfer service in...

26. [KakaoBank Launches Korea's First Azure OpenAI-Powered ...](https://www.microsoft.com/en/customers/story/24967-kakao-bank-azure-openai) - On May 26, 2025, KakaoBank launched its Azure OpenAI-powered AI Search service within its mobile app...

27. [Toss Bank Introduces 'AI Agent' for Financial Consultation](https://cm.asiae.co.kr/en/article/2025121814245881645) - Toss Bank is introducing a 'next-generation financial consultation' service that utilizes artificial...

28. [Toss Bank Designated for Four Generative AI Innovative Financial ...](https://cm.asiae.co.kr/en/article/2025121509093168061) - Toss Bank is accelerating internal work innovation by utilizing generative artificial intelligence (...

29. [Toss Bank announced on the 30th that it has introduced "HelpChat," a self-developed real-time chat c..](https://www.mk.co.kr/en/economy/11305416) - Toss Bank announced on the 30th that it has introduced "HelpChat," a self-developed real-time chat c...

30. [Toss Bank aims to create an environment where all organizations ...](https://www.mk.co.kr/en/special-edition/11418955) - Toss Bank aims to create an environment where all organizations can utilize artificial intelligence ...

31. [Internet Banks' AI Services Fall Short of "Hyper-Personalization ...](https://en.sedaily.com/news/2026/04/20/internet-banks-ai-services-fall-short-of-hyper) - Korea's internet-only banks Kakao Bank, K Bank, and Toss Bank are still far from delivering the hype...

32. [DBS rolls out Gen AI-powered chatbot to all corporate clients](https://www.dbs.com/newsroom/DBS_rolls_out_Gen_AI_powered_chatbot_to_all_corporate_clients)

33. [Inside DBS' AI journey – from use cases to workforce transformation](https://www.youtube.com/watch?v=tNYKxBYqApA) - ... Kim Yong speaking at Committee of Supply debate 2026 2:09 DBS CEO Tan Su Shan speaking about AI ...

34. [DBS unlocks S$1 billion in AI value in 2025 - The Business Times](https://www.businesstimes.com.sg/companies-markets/dbs-unlocks-s1-billion-ai-value-2025) - But as Singapore’s lenders seek to ride the wave, agentic artificial intelligence’s rise poses chall...

35. [DBS is First Bank in Asia Pacific to Pilot Visa Intelligent Commerce ...](https://www.theasianbanker.com/mediafeed-news/details?rkey=20260215AE88523) - "AI agents are unlocking a new phase in digital payments, where routine transactions can be complete...

36. [OCBC rolls out its ‘avatar banking' platform with ‘Wendy' and ‘Wayne,' two virtual financial advisors, as banks integrate AI into wealth management](https://finance.yahoo.com/technology/ai/articles/ocbc-rolls-avatar-banking-platform-102614794.html) - Still, new CEO Tan Teck Long promised to hire 600 new relationship managers, as wealth management be...

37. [STARTUP PULSE | Monday, 15 June 2026](https://mystartupplaybookpodcast.substack.com/p/startup-pulse-monday-15-june-2026) - Your weekly dose of Malaysia & Southeast Asia startup news

38. [WeLab Bank Reports Continued Profitability in H1 2025](https://www.welab.co/en/press/welab-bank-reports-continued-profitability-h1-2025/) - Get the latest news on our awards, press releases and coverage from business, technology and financi...

39. [WeLab Bank Accelerates AI Deployment With Deepseek to ...](https://fintechnews.hk/32632/virtual-banking/welab-bank-ai-deployment-deepseek/) - WeLab Bank AI deployment accelerates with DeepSeek, enhancing customer experience, security, and eff...

40. [WeLab completes US$220 million Series D strategic financing ...](https://www.prnewswire.com/apac/news-releases/welab-completes-us220-million-series-d-strategic-financing-marking-the-largest-digital-banking-capital-raise-in-asia-in-2025-302661768.html) - /PRNewswire/ -- WeLab, a leading pan-Asian fintech platform, announced the successful closing of its...

41. [WeLab Bank Rolls Out Hong Kong's First AI-Powered FX Service ...](https://www.welab.bank/en/newsroom/welab-bank-rolls-out-hong-kongs-first-ai-powered-fx-service-best-fx-rates-in-town-best-rate-guarantee/) - WeLab Bank

42. [Finance Is Becoming Asia's Cleanest AI Deployment Proving Ground](https://asianintelligence.ai/reports/finance-is-becoming-asias-cleanest-ai-deployment-proving-ground) - A source-first synthesis of why finance is producing some of Asia's clearest AI deployment signals a...

43. [VietBank CIO on Agentic AI, Homegrown Innovation, and Why ...](https://www.cio.com/podcast/4179694/vietbank-cio-on-agentic-ai-homegrown-innovation-and-why-vision-beats-scale.html)

44. [Nubank to invest R$ 45 billion in Brazil in 2026 - Nu International](https://international.nubank.com.br/company/nubank-to-invest-r-45-billion-in-brazil-in-2026/) - The amount has nearly doubled in the last two years and will support advances in artificial intellig...

45. [$50B fintech CEO says stop selling AI. Customers don't ... - Fortune](https://fortune.com/2025/10/21/nubank-ceo-livia-chanes-ai-selling/) - The CEO of the largest digital bank says stop peddling new technology as your selling point.

46. [Brazil Fintech Nubank 2026 - pdpspectra](https://pdpspectra.com/blog/brazil-fintech-nubank-ecosystem-2026/) - Brazil has the most successful neobank in the world. The fintech landscape in 2026 — where Nubank do...

47. [Efficient LLM Training and Scaling AI Agents for 131 Million Lives](https://iclr.cc/virtual/2026/expo-talk-panel/10020576)

48. [Building AI agents for 131 million customers - Building Nubank](https://building.nubank.com/building-ai-agents-for-131-million-customers/) - Lessons from Modeling State, Change, and Complexity with Values and Functions

49. [Nashet Ali's Post - LinkedIn](https://www.linkedin.com/posts/cloudifywithnashet_ai-llm-fintech-activity-7448105638850740224-Ea41) - Nubank is quietly becoming one of the most interesting #AI and #LLM‑driven banks on the planet. 🧠💸 B...

50. [Mercado Pago launches financial assistant with AI](https://www.snackvideo.com/news/detail/FAUt75kBnm6ewQHbg6yv)

51. [Mercado Pago AI Assistant - Product Update](https://www.youtube.com/watch?v=vyJQlttSIHw)

52. [Documentación - Mercado Pago Developers](https://www.mercadopago.cl/developers/en/docs/ai-resources)

53. [ChatGPT Go Free: BBVA reaches 34 million Mexicans - Veritas News](https://repo.enc.edu/2026/01/31/chatgpt-go-free-bbva-reaches-34-million-mexicans/) - El proyecto busca acercar capacidades de Inteligencia Artificial (IA) a los usuarios para simplifica...

54. [BBVA Mexico brings personalization and zero fees to the digital space](https://www.bbva.com/en/bbva-mexico-brings-personalization-and-zero-fees-to-the-digital-space/) - At BBVA Summit 2025: Futura, Hugo Nájera, Head of Retail Banking at BBVA Mexico, presented the new d...

55. [Latin American Digital Neo-Banking Platform Market - Research Intelo](https://researchintelo.com/report/latin-american-digital-neo-banking-platform-market/amp) - The Latin American digital neo-banking platform market was valued at $18.5 billion in 2025 and is pr...

56. [GCC Banks Race to Harness Generative AI in Fintech as Regulators ...](https://www.theplatinumcapital.com/article/gcc-banks-race-to-harness-generative-ai-in-fintech-as-regulators-tighten-rules-on-data-risk-and-virtual-assets) - Generative artificial intelligence is moving from pilot projects to production inside Gulf banks and...

57. [Fintech News Middle East](https://fintechnews.ae/page/14/?blackhole=dce2484aa9) - Fintech news, startup updates and regulatory insights from the UAE, GCC and wider MENA region.

58. [ANZ launches agentic AI-powered CRM to transform business banking](https://www.anz.com.au/newsroom/media/2026/february/anz-launches-agentic-ai-powered-crm-to-transform-business-banking/) - ANZ is investing in its business banking experience by deploying Salesforce's Agentforce 360 platfor...

59. [ANZ rolls out agentic AI CRM tool that will save bankers 1 ...](https://asianbankingandfinance.net/banking-technology/news/anz-rolls-out-agentic-ai-crm-tool-will-save-bankers-1-month-time) - The new CRM consolidates data from 20 different platforms.

60. [How artificial intelligence could transform the banking industry](https://www.fool.com.au/2025/05/22/how-artificial-intelligence-could-transform-the-banking-industry/) - AI agents will initially work alongside bankers to help with everyday tasks and help to prepare for ...

61. [Why M-Pesa, Africa's Talking, and USSD are missing from AI agent ...](https://dev.to/gabrielmahia/why-m-pesa-africas-talking-and-ussd-are-missing-from-ai-agent-tooling-and-what-i-did-about-it-56fo) - I spend a lot of time building tools for Kenya. Payment flows, agricultural alerts, county budget...

62. [GitHub - rustic-ai/rustic-ui-components: React component library for crafting user-friendly and engaging conversational experiences](https://github.com/rustic-ai/rustic-ui-components) - React component library for crafting user-friendly and engaging conversational experiences - rustic-...

63. [GitHub Just Put an AI Agent Inside Your CI CD Pipeline](https://www.youtube.com/watch?v=BcKhhCB26k0) - GitHub just launched Agentic Workflows in technical preview — AI agents that run automatically insid...

64. [GitHub Just Made AI Agents Part of CI/CD - YouTube](https://www.youtube.com/watch?v=LDpqHo1Gd1w) - Your CI/CD pipeline just got a brain. GitHub's new Agentic Workflows capability lets AI triage issue...

65. [Agent-Operated CI/CD: The Architecture Making AI Coding Agents ...](https://alexlavaee.me/blog/agent-operated-cicd-pipelines/) - Engineers using AI coding agents are reporting significant productivity gains—GitHub's research show...

