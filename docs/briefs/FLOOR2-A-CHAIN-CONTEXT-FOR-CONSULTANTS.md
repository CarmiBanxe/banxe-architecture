# FLOOR-2 A-CHAIN CONTEXT FOR CONSULTANTS

Status: DRAFT / INTERNAL NAVIGATION ONLY / NO LEGAL STATUS

## Purpose
Этот файл объясняет внутренние технические термины, отсутствовавшие в исходном внешнем брифе, и указывает на первоисточники в репозитории. Это индекс-мост, не правовой документ; никакие regulatory/compliance выводы здесь не делаются.

## Canonical chain
- Floor-2 A-chain = миграционная линия «from basement code to rooms» (код banxe-emi-stack → комнатная governance-структура).
- S-A5 = install-аудиты identity-кластера (A-IDV / A-KYC / A-KYB) — выполнены 2026-07-20.
- S-A6 = следующая аудит-линия (ledger/EMI), разблокирована после закрытия S-A5-гейта; не исполнялась.

## Terms and file anchors

| Term | What it refers to here | Primary file anchor(s) | Status |
|---|---|---|---|
| Ballerine | self-hosted KYC/IDV-провайдер (инфра развернута) | `banxe-emi-stack/infra/ballerine/` | evidenced in S-A5 audit |
| SumSub | внешний KYC/IDV-провайдер, primary по спеке; live-адаптер credentials-gated | `docs/architecture/A-IDV-BUILD-SPEC.md`; порт: `banxe-emi-stack/services/kyc/kyc_provider_port.py` | mentioned as open point (primary-verdict) |
| PARKED / bkyc / binancekyc | legacy-KYC адаптеры, законсервированы каноном: наличие = норма, использование = нарушение | `banxe-emi-stack/services/compliance/legacy/` (по EMI-IMPL-STATE) | legacy / verify non-use [operator] |
| ADR-102 | «no smart refactor without duplication verification» — reuse-not-rebuild дисциплина (порт не реимплементируется) | `docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md` | reference only |
| ADR-174 | source governance: иерархия источников Tier-A/B/C; блокировки — только Tier-A | `docs/adr/ADR-174-compliance-source-governance.md` | reference only (DRAFT/PROPOSED) |
| I-27 | инвариант HITL: «AI PROPOSES, human DECIDES»; включает KYC/KYB/AML carve-out | `INVARIANTS.md` (repo root) | reference only |
| S-A5 | identity install-audit спринт (этот пакет) | `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md` + 3 аудита в `docs/audit/spec-audits/` | evidenced — complete (Case 2) |
| S-A6 | ledger/EMI аудит-спринт (D-GL/B-EMI + M2.5-verdict) | `docs/roadmap/S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` | canonical next step (not executed) |

## What S-A5 already established
- **A-IDV:** порт-контракт установлен (typed-ошибки, обязательный correlation_id), DI-фабрика + sandbox-workflow есть; маска-консьюмер существует; провайдер-live = credentials-pending (ED-03). Факт-база: shell/grep по коду.
- **A-KYC:** оркестрация+маска+retrigger-audit-emitter установлены; ADR-102-проверка — второй реализации порта нет.
- **A-KYB:** полный модуль установлен, включая Companies-House-адаптер (официальный API, не scraping); HITL enforced кодом: UBO sanctions-hit → L4 HITLProposal → MLRO (I-27).
- Факт-базовые пункты: всё перечисленное выше — из кода/shell-аудита. Нерешённые: см. следующую секцию (вынесены дословно из аудитов).

## Open questions for external review
- [operator] Ballerine-vs-SumSub primary в фактическом DI (`services/kyc/factory.py`) — спека говорит SumSub primary, инфра содержит Ballerine.
- [operator] Import-graph подтверждение неиспользования PARKED-legacy (bkyc/binancekyc).
- [operator] KYB `models.py` — отсутствие raw-PII persistence сверх redacted refs (spec-требование).
- [operator] UBO-скрин: подтверждение Tier-A-only для блокировок (ADR-174).
- [operator] IL-трейс sign-off'а существующего KYC-кода относительно I-27 carve-out.
- [counsel] Annex III-релевантность IDV/KYC-потоков (через Sprint-2 High-Risk Map).
- [counsel] KYB-периметр для merchant-acquiring связки (лицензионная сторона).
- [external reviewer] Достаточность correlation_id-модели ошибок как трассируемости для аудита провайдер-цепочки.

## Reading order
1. `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md`
2. `docs/audit/spec-audits/A-IDV-INSTALL-AUDIT-2026-07-20.md`
3. `docs/audit/spec-audits/A-KYC-INSTALL-AUDIT-2026-07-20.md`
4. `docs/audit/spec-audits/A-KYB-INSTALL-AUDIT-2026-07-20.md`
5. Референсы: ADR-102, ADR-174, `INVARIANTS.md` (I-27)
