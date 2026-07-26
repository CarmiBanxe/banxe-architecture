# BANK LAUNCH CONTROL PANEL — 2026-07-18

**Status: DRAFT / NOT FOR MERGE** · База: origin/main @ c66c198 · Ветка: `agent/factory/bank-operating-model/20260718`
Producer: factory terminal (sandbox) для Central/оператора.
Маркировка: [ФАКТ] = подтверждено файлом · [ВЫВОД] = следует из фактов · [НЕИЗВЕСТНО] = не установлено.

## 1. Purpose

Этот документ — операторская панель запуска банка: одна страница, связывающая четырёхэтажную модель (source: `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md`), консолидированный roadmap v2 (source: `docs/roadmap/BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md`) и операционный план спринтов (source: `docs/roadmap/BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md`). Central использует её, чтобы выбирать следующий спринт, видеть блокеры и не терять critical path. Панель не заменяет реестры OD-R/ED/UNK — она на них ссылается.

## 2. Current state

[ФАКТ] **FLOOR 3 (banking domain) — сильнейший:** 16/16 сервисов REAL, safeguarding+recon v2 DONE, AML-движки в коде (source: four-floors memo §2, §7). **FLOOR 4 (governance) — зрелый на бумаге:** 17 HITL-гейтов, conformance 86%, append-only аудит; формы не live, кадровые пустоты (DPO/HoC/CCO), GDPR GAP-085 clock running. **FLOOR 2 (orchestration) — собран, обесточен:** LangGraph live, A2A/MCP merged, Qdrant не задеплоен, 32/70 паспортов PROPOSED, L3-gate не подписан. **FLOOR 1 (client/intent) — тончайший:** dispatcher merged, флаг OFF (GAP-091), клиентской поверхности нет.

[ВЫВОД] Банк «построен вчерне»; дефицит — активация и решения, не код. [НЕИЗВЕСТНО] — сгруппировано в §6.

## 3. Launch slice

[ФАКТ, roadmap v2 §9] **В скоупе запуска:** Intent Layer до **L2 Supervised** (каждая операция → confirmation card → человек); governance substrate целиком (ClientIntentRecord+SCA+revocation, budget-policy, LineageWrapper+AgentDecisionRecord, BPR v1, compliance overlay); минимальный HII (Home + чат + TransferCard/KYCProgressCard + human-escalation); FPS/SEPA; KYC Ballerine + sanctions Watchman + fraud Jube; CASS-контур live; два client-safe агента (analytics L0/L1, payments L2).
**Вне скоупа [PX]:** crypto (Paybis-gated), cards ([НЕИЗВЕСТНО] UNK-09), savings, marketplace, BaaS/White Label, внешний API/MCP, voice, автономия L3/L4.
[ВЫВОД] Это безопасный путь: ни одно движение денег не происходит без человека (I-27), все внешние поверхности закрыты, расширение — только после živого supervised-контура.

## 4. Lane model

| Lane | Назначение | Критерий входа | Примеры |
|---|---|---|---|
| **[LC] Launch Critical** | без этого запуска нет | блокирует go-live slice напрямую | governance substrate, HITL-формы, intent sandbox, CASS, rails, security, go-live |
| **[PL] Pre-Launch / Adjacent** | полезно до запуска, но slice не блокирует | параллелится без риска для хребта | CFO/RegData полный цикл, finance-агенты |
| **[PX] Post-Launch / Expansion** | строго после запуска | требует работающего slice и/или отдельных гейтов | crypto/Paybis, BaaS/API, marketplace, L3/L4, OSINT-углубление |

## 5. Sprint coverage (S-A0..S-A13)

(source: sprint plan; полные детали и exit-критерии — там)

| Sprint | Title | Lane | Actions | Primary objective | Main blockers |
|---|---|---|---|---|---|
| S-A0 | Planning baseline | [LC] | [op][code] | ратифицировать план v2 | OD-R09 |
| S-A1 | Governance & roles | [LC] | [op] | GDPR + кадры + 8 conformance | OD-R01..R06, ED-12 |
| S-A2 | Runtime prereqs | [LC] | [code][op] | Qdrant + cost-caps | OD-R10, UNK-11 |
| S-A3 | HITL live binding | [LC] | [code][op] | 17 живых форм + L2-петля | OD-R13 |
| S-A4 | Intent substrate + L0/L1 | [LC] | [code][op] | ClientIntentRecord/SCA/BPR v1 + флаг ON (sandbox) | OD-R11, OD-R21, UNK-07 |
| S-A5 | Overlay + L2 + KYC | [LC] | [code][op][ext] | compliance overlay + supervised операции | OD-R14, ED-03/04/05 |
| S-A6 | CASS closure | [LC] | [code][op][ext] | recon live + FIN060 dry-run | OD-R20, ED-10 |
| S-A7 | Rails activation | [LC] | [code][op][ext] | FPS/SEPA controlled live | OD-R07/R16, ED-01/02 |
| S-A8 | CFO stack | [PL] | [code][op][ext] | finance-агенты + RegData live | OD-R14, ED-10 |
| S-A9 | Crypto readiness | [PX] | [code][op][ext] | Paybis Wave B/C | OD-R17, ED-08/09 |
| S-A10 | HII surface + XAI | [LC]-min | [code][op] | минимальное клиентское лицо slice | OD-R22, UNK-12, ED-06(PL) |
| S-A11 | API/BaaS exposure | [PX] | [code][op] | контролируемая внешняя поверхность | OD-R18, UNK-06 |
| S-A12 | Security closure | [LC] | [code][op] | 0 открытых P1 security-GAP | GAP-082/090, ED-07 |
| S-A13 | Dry-run + L3-gate + go-live | [LC] | [code][op][ext] | запуск | OD-R15, ED-11, UNK-03 |

## 6. Blockers and open decisions

(полные реестры: roadmap v2 §6–§8; здесь — группировка)

- **Операторские решения (22, OD-R01..R22):** немедленное — OD-R01 (GDPR); пакет одного HITL-сеанса — OD-R02..R06 + R09; активации — R10/R11/R13/R14; ратификации — R21 (Ladder+ClientIntentRecord→ADR), R19 (CTO-interface ADR); внешний контур — R16/R20; финал — R15, R22; прочее — R07/R08/R12/R17/R18.
- **Внешние зависимости (13, ED-01..ED-13):** ключи ClearBank/Modulr (ED-01/02 — длиннейший lead-time, запросить немедленно [ВЫВОД]), Sumsub/Sardine/Twilio (ED-03..05), FOS (ED-06), offsite (ED-07), Paybis SRC-06/07/08 (ED-08/09), FCA (ED-10), Grant Thornton (ED-11), Legal (ED-12), BIN sponsor условно (ED-13).
- **Неизвестные (13, UNK-01..UNK-13):** кадры/штат (UNK-04), Board-процедура (UNK-03), cards/BIN scope (UNK-09), commercial-допущения — файл «Nachalnye-shagi» в S3 (UNK-13), BaaS-модель (UNK-06), 6 intent-вариантов (UNK-07), cost-runtime (UNK-11), гейты фаз 3/4 (UNK-01/02), FCA-последствия CASS-дедлайна (UNK-10), Private Engine место (UNK-05), маппинг v7-v9 (UNK-08), product-владелец (UNK-12).

## 7. Recommended execution sequence

[ВЫВОД] 1) OD-R01 GDPR — сегодня, вне очереди. 2) S-A0+S-A1: ратификация плана и пакет кадровых/conformance-решений (один HITL-сеанс = 9 решений). 3) Параллельно запросить ED-01/02. 4) S-A2→S-A3: субстрат движка и живой HITL (надзор прежде входа). 5) S-A4→S-A5: intent sandbox, затем supervised L2 + KYC (вход прежде денег). 6) S-A6, затем S-A7 по ключам (деньги прежде рельсов). 7) S-A12 параллельно с A7+. 8) S-A10 минимум после A4. 9) S-A13: dry-run → L3-gate → go-live. 10) После запуска — [PX]-lanes (A9/A11, L3/L4, commercial).

## 8. Central use protocol

- **Как читать:** §2 — где мы; §5 — что делать; §6 — что мешает; сверка деталей — всегда в sprint plan и roadmap v2 (панель не самодостаточна).
- **Как выбирать следующий спринт:** первый незакрытый [LC]-спринт, чьи блокеры из §6 сняты; [PL]/[PX] — только если [LC]-хребет не ждёт операторского действия, доступного сейчас.
- **Что НЕ считать одобренным:** все файлы этой ветки — DRAFT / NOT FOR MERGE; ни одна [PLAN-CONCEPT]-схема (ClientIntentRecord, Ladder L0–L4, overlay-латентности) не является каноном до ратификации OD-R21; merge любого файла — только операторским single-writer процессом (I-71).

---
*DRAFT / NOT FOR MERGE. Источники: four-floors memo, roadmap v2, sprint plan, delta memo — все в этой ветке @ 2b9cc37.*
