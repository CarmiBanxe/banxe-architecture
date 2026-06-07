# SESSION-HANDOFF — 2026-06-07

> Пакет переноса сессии. Создан: 2026-06-07 22:30 CEST.  
> Оператор: Moriel Carmi (CEO BANXE EMI AI Bank, github: CarmiBanxe)  
> Источник: Perplexity Comet factory session — прервана по лимиту длины.  
> Цель: продолжить незавершённую работу в новой сессии Perplexity без потери контекста.

---

## 1. СТАТУС НА МОМЕНТ РАЗРЫВА

### Что было начато:
- **Задача:** Создать `OPERATOR-PLAYBOOK.md` — сводный операторский плейбук с принципами канона и всеми операторскими промптами/командами для сессий Perplexity.
- **Выполнено:** 2 подготовительных шага (структура, заголовки).
- **НЕ завершено:** Тело плейбука — оставалось заполнить блоки операторских промптов, команд Claude Code, сессионных шаблонов и quick-reference.

### Текущий статус файлов:
- `OPERATOR-PLAYBOOK.md` — **создан** (см. этот коммит, параллельный файл).
- `SESSION-HANDOFF-2026-06-07.md` — **этот файл**.

---

## 2. ПОЛНЫЙ КАНОН — КРАТКОЕ РЕЗЮМЕ

### Ключевые binding-документы:
| Документ | Расположение | Суть |
|---|---|---|
| `PROMPT-CANON-PROJECT.md` | banxe-architecture root | §1-16 binding rules: язык, тиеры, мульти-терминал, no-вопросы |
| `PROMPT-CANON-DEVELOPER.md` | banxe-architecture root | Developer rules: один скрипт, proof SHA, scope-чистота |
| `INVARIANTS.md` | banxe-architecture root | I-01..I-74+ технические инварианты |
| `INSTRUCTION-LEDGER.md` | banxe-architecture root | append-only ledger всех IL-блоков |
| `HITL-MATRIX.yaml` | banxe-architecture root | HITL роли и gates |
| `COMPLIANCE-ARCH.md` | banxe-architecture root | FCA / AML / GDPR compliance архитектура |
| `AGENTS.md` | banxe-architecture root | Паспорта AI агентов |
| `ADRs` | banxe-architecture/adrs/ | Architecture Decision Records |
| `constitution/` | banxe-architecture/constitution/ | Конституция + amendments |

### Binding §§ из PROMPT-CANON-PROJECT.md:
- **§13** — Русский язык для оператора, английский для технических артефактов (BINDING).
- **§14** — Perplexity Capability Tiers T1-T6 (T2-T5 sandbox-granted, T6 standby).
- **§15** — Три терминала, один writer. Pre-flight check обязателен.
- **§16** — Запрет вопросов на безопасные команды. Self-answer по BDP §4.

### Binding из PROMPT-CANON-DEVELOPER.md:
- Один большой скрипт вместо серии мелких.
- 100% completion или OPEN ticket.
- Один scope = один commit = один proof SHA.
- ASCII-only в Python-коде.
- Push = privileged action (требует явного `yes` от оператора).
- Handoff в `/tmp/` обязателен в конце каждой сессии.

---

## 3. РЕПОЗИТОРИИ — КАРТА

| Репо | URL | Назначение |
|---|---|---|
| banxe-architecture | https://github.com/CarmiBanxe/banxe-architecture | Governance, canon, ADRs, constitution, ledger |
| banxe-emi-stack | https://github.com/CarmiBanxe/banxe-emi-stack | EMI финансовый стек, FCA CASS 15, analytics |
| banxe-platform | https://github.com/CarmiBanxe/banxe-platform | TypeScript платформа |
| banxe-ui | https://github.com/CarmiBanxe/banxe-ui | UI прототип |
| banxe-infra | https://github.com/CarmiBanxe/banxe-infra | Инфраструктура |
| banxe-payment-core | https://github.com/CarmiBanxe/banxe-payment-core | Hyperswitch + Paymentology + Midaz (ADR-015) |
| banxe-monitoring | https://github.com/CarmiBanxe/banxe-monitoring | Мониторинг |
| banxe-ai-infrastructure | https://github.com/CarmiBanxe/banxe-ai-infrastructure | AI инфраструктура |
| banxe-collaboration | https://github.com/CarmiBanxe/banxe-collaboration | Shared dev infra (Claude Code + Aider) |
| banxe-business-processes | https://github.com/CarmiBanxe/banxe-business-processes | ArchiMate 3.2 бизнес-процессы |

---

## 4. НЕЗАВЕРШЁННАЯ РАБОТА — ЧТО ДЕЛАТЬ В НОВОЙ СЕССИИ

### Статус OPERATOR-PLAYBOOK.md:
Файл создан в этом коммите. В новой сессии нужно:
- [ ] Проверить содержимое через `cat OPERATOR-PLAYBOOK.md`.
- [ ] Если требуются дополнения — добавить секции через amendment-процесс.
- [ ] Добавить IL-запись в INSTRUCTION-LEDGER.md для этого плейбука.

### Следующий шаг в новой сессии:
```
Промпт для старта новой Perplexity сессии:

"Читай SESSION-HANDOFF-2026-06-07.md из репо CarmiBanxe/banxe-architecture и продолжай с места разрыва.
Первое действие: gh api repos/CarmiBanxe/banxe-architecture/contents/OPERATOR-PLAYBOOK.md | jq -r '.content' | base64 -d"
```

---

## 5. СЕССИОННЫЙ КАНОН — QUICK REFERENCE

### Старт каждой сессии:
```bash
# 1. Sync оба репо
git -C ~/banxe-architecture fetch --all --prune && git -C ~/banxe-architecture pull --ff-only origin main
git -C ~/banxe-emi-stack fetch --all --prune && git -C ~/banxe-emi-stack pull --ff-only origin main

# 2. Статус
git -C ~/banxe-architecture log --oneline -10
git -C ~/banxe-emi-stack log --oneline -10

# 3. Открытые PR
gh pr list -R CarmiBanxe/banxe-architecture --state open
gh pr list -R CarmiBanxe/banxe-emi-stack --state open
```

### Конец каждой сессии:
```bash
# Handoff
cat > /tmp/banxe_handoff_$(date +%Y-%m-%d_%H%M).md << 'EOF'
## Handoff [DATE]
- Статус IL: [статус]
- Proof SHA: [sha]
- Blockers: [блокеры]
- Parking: [паркинг]
- Next session: [следующий шаг]
EOF
```

---

## 6. OPERATOR CONTACT

- Оператор: **Moriel Carmi** (CEO BANXE EMI AI Bank)
- GitHub: `CarmiBanxe`
- Локация: Antibes, FR (CEST timezone)
- Рабочий инструментарий: Perplexity Comet (factory terminal) + Claude Code (worker) + bash/Linux

---

*Handoff создан Perplexity (factory terminal) 2026-06-07. Следующая сессия: продолжить с OPERATOR-PLAYBOOK review + IL-запись.*
