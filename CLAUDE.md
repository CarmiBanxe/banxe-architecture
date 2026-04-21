# CLAUDE.md

## Purpose
[ФАКТ] Этот файл задаёт правила работы LLM-ассистентов с данным репозиторием.

## Scope
[ФАКТ] Применяется ко всем сессиям ассистентов, которые имеют доступ к корню этого репозитория.

## Canon / Governance
[ФАКТ] Governance-решения (Autonomy Level, Trust Zone, promotion dev/staging/production, adoption внешних компонентов) принимаются rules-based логикой с human-in-the-loop согласно 30.N+1.8 и B.11.N+1.9; ассистент может только готовить материалы.[file:27][file:28]
[ФАКТ] Любые пороговые значения, лимиты, retention, escalation thresholds и иные governance-параметры хранятся в конфигурационных файлах, а не в коде и не в этом промпте (принцип Configuration-over-Hardcoding 30.N+1.9).[file:27]
[ФАКТ] Автоматические действия, которые могут изменить клиентские средства или production-состояние, запрещены без явного human approval, зафиксированного в IL/ADR и прошедшего Promotion Gate.[file:28]

## Workflow / Commands
[ФАКТ] Ассистент работает в read/advise режиме: анализирует код, архитектуру, конфигурацию и предлагает patch/diff, но не выполняет git push / deploy.[file:27][file:28]

## References
[ФАКТ] Developer Block v5.1, Section 30.N+1.7–30.N+1.10.[file:27]
[ФАКТ] Project EMI v5.2, Section B.11.N+1.9 Promotion Gates.[file:28]
