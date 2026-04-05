# Санкционная политика Banxe (UK FCA EMI, 2026)

**Источник:** UK FCA, OFAC, HMT, EU CSL, UN CSL  
**Последнее обновление:** 2026-04-05  
**Canonical implementation:** `vibe-coding/src/compliance/sanctions_check.py`

---

## Категория A — HARD BLOCK (REJECT немедленно)

Транзакция из/в эти юрисдикции → **REJECT**. Без исключений. Независимо от суммы, клиента, score.

| Юрисдикция | Код | Основание |
|------------|-----|----------|
| Россия / РФ | RU | UK/EU/US sanctions |
| Беларусь | BY | UK/EU/US sanctions |
| Иран | IR | OFAC SDN, HMT |
| КНДР / Северная Корея | KP | OFAC SDN, UN |
| Куба | CU | OFAC |
| Мьянма | MM | UK/EU sanctions |
| Афганистан | AF | UN, UK sanctions |
| Венесуэла (гос. структуры) | VE | OFAC |
| Крым | — | UK/EU/US sanctions |
| ДНР | — | UK/EU/US sanctions |
| ЛНР | — | UK/EU/US sanctions |

**Ответ агента:** `[Страна] → REJECT: заблокированная юрисдикция.`

---

## Категория B — EDD / HOLD (Enhanced Due Diligence обязателен)

Транзакции требуют HOLD + EDD. **Не REJECT по умолчанию.** Санкции частично или условно действуют.

| Юрисдикция | Код | Примечание |
|------------|-----|-----------|
| Сирия | SY | ⚠️ HOLD с июля 2025 (санкции Assad частично сняты; ранее был BLOCK) |
| Ирак | IQ | High-risk, FATF |
| Ливан | LB | Financial instability, Hezbollah risk |
| Йемен | YE | Conflict zone, UN arms embargo |
| Гаити | HT | Political instability |
| Мали | ML | Coup, UN sanctions |
| Буркина-Фасо | BF | Coup, security situation |
| Нигер | NE | Coup |
| Судан | SD | Conflict, US/EU sanctions |
| Ливия | LY | Arms embargo, conflict |
| Сомали | SO | Al-Shabaab risk, UN sanctions |
| ДР Конго | CD | Conflict, EU sanctions |
| ЦАР | CF | UN arms embargo |
| Зимбабве | ZW | HMT targeted sanctions |
| Никарагуа | NI | OFAC, democratic concerns |
| Южный Судан | SS | Arms embargo, conflict |

**Ответ агента:** `[Страна] → HOLD: EDD-юрисдикция, усиленная проверка.`

---

## Не заблокированы (стандартный AML)

Стандартные AML проверки, нет санкционных ограничений:

Южная Корея (KR), ОАЭ (AE), Япония (JP), Израиль (IL), Турция (TR), Индия (IN), Бразилия (BR), Мексика (MX), США (US), EU (все), UK (GB)

---

## Шаблон ответа агента

```
[Страна/транзакция] → [СТАТУС]: [одна строка причины]
```

Примеры:
- `Россия → REJECT: заблокированная юрисдикция.`
- `Сирия → HOLD: EDD-юрисдикция, усиленная проверка.`
- `Южная Корея £50,000 → HOLD: сумма >£10k, EDD обязателен.`
- `Южная Корея £500 → ALLOW: низкий риск, стандартный AML.`

Запрещено в ответах:
- Эмодзи (флаги стран, ✅, ❌)
- Таблицы
- Вопросы в конце
- Упоминание LexisNexis / SumSub / Dow Jones (не подключены)

---

## OFAC техническое примечание

**OFAC RSS feed не существует с 31 января 2025.**  
Используется HTML scraper: `ofac.treasury.gov/recent-actions`  
(Инвариант I-02 — см. `INVARIANTS.md`)
