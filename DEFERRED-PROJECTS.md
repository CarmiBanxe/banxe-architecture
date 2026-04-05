# Отложенные проекты Banxe

Эти проекты зафиксированы как **планируемые**, но **не разрабатываются сейчас**.

Причина фиксации: чтобы не путать с текущей архитектурой и не делать ненужные интеграции "под будущее".

---

## Отложенные проекты

| Проект | Описание | Почему отложен | Инсталляция |
|--------|----------|----------------|-------------|
| **Telegram-бот (клиентский)** | Банковское приложение для клиентов: платежи, баланс, KYC onboarding | Требует FCA authorisation, отдельная архитектура | Отдельный OpenClaw instance |
| **CM migration plan** | Миграция кейсов при смене case management layer | Marble единственный CM, миграция нулевая задача | Триггер: второй CM-провайдер ИЛИ смена лицензии Marble |
| **Web-приложение Banxe** | Личный кабинет клиента (браузер) | Зависит от API readiness, design, auth service | Отдельный проект |
| **Мобильное приложение** | iOS / Android банковское приложение | Зависит от web-app + доп. FCA requirements | Отдельный проект |
| **Telegram-бот для клиентского KYC** | Onboarding через Telegram | Зависит от PassportEye/DeepFace Phase 3 | Часть клиентского бота |
| **PublicAPI / Open Banking** | PSD2-совместимый API для партнёров | FCA licensing + SCA требования | Отдельный проект |

## Не отложено (активная разработка)

| Компонент | Статус | Описание |
|-----------|--------|----------|
| `@mycarmi_moa_bot` | ACTIVE | Терминал оператора-дублёра (MLRO/CTIO) |
| Marble UI (:5003) | ACTIVE | Case management для оператора |
| Compliance stack (:8090) | ACTIVE | AML/KYC/Sanctions API |
| Training pipeline | ACTIVE | Обучение агентов (developer only) |
| Promptfoo eval cron | ACTIVE | Воскресенье 04:00 UTC |
| Feedback loop + train-agent.sh | DONE | GAP 4 — corpus → patches → auto-deploy |
| Drift monitoring 6h | DONE | GAP 5 — Evidently AI + cron |

## GAP-задачи (не блокирующие)

| GAP | Описание | Приоритет |
|-----|----------|----------|
| GAP 4 | feedback RAG | Низкий |
| GAP 5 | Realtime drift monitoring каждые 6ч | Средний |
| GAP 6 | Autoresearch program.md | Низкий |
| GAP 7 | OpenRLHF pipeline | Низкий |
| GAP 8 | TinyTroupe / AMLSim adversarial | Низкий |
