# ADR-075: PayJoin & HD Privacy Score for Ghost Mode

**Status:** PROPOSED
**Date:** 2026-05-07
**Context:** Ghost Mode Privacy Tech Stack — Phase 2

---

## Контекст

Ghost Mode (BANXE Self-Custody, out-of-scope EMI) требует:

- **BIP-77 Async PayJoin** — защита приватности отправителя через смешение inputs. Async-режим: стороны не обязаны быть онлайн одновременно (Oblivious HTTP). Production references: Cake Wallet, Bull Bitcoin Mobile, `rust-payjoin` 0.21.0.
- **BIP-32/44/84/86 HD Wallet + Privacy Score** — принудительная ротация адресов, burner-account режим, xPub isolation, real-time Privacy Score в UI.
- **Per-KYC stealth/silent meta-address limit** — защита от identity-fragmentation / structuring через множественные meta-addresses.

## Решение

To be specified at implementation.

При реализации решение должно покрывать:
1. Интеграцию BIP-77 async PayJoin в Self-Custody Bitcoin-кошелёк.
2. Принудительную HD-ротацию адресов (ON по умолчанию) с алертом при reuse.
3. Burner-account режим (изолированный sub-account).
4. Privacy Score v1 алгоритм (см. `ghost-mode-spec.md` §3).
5. Per-KYC limit на активные meta-addresses (I-58).

## Альтернативы

| Альтернатива | Причина отклонения |
|---|---|
| PayJoin v1 sync (BIP-78) | Требует одновременной online-доступности обеих сторон; UX-проблема для мобильного клиента |
| Глобальный лимит meta-addresses без per-KYC binding | Не защищает от sybil через множественные KYC-аккаунты; per-KYC binding обеспечивает attribution |
| CoinJoin (Wasabi/JoinMarket) | Запрещён по I-49 (mixer/coin-join); несовместим с EMI compliance |

## Последствия

- **UX-стоимость ротации:** новый адрес при каждой транзакции усложняет ручное управление; компенсируется UI (burner-account, auto-rotation).
- **PayJoin в EMI custody wallet — запрещён:** PayJoin добавляет inputs получателя, что ломает attribution в EMI ledger. Выполняется только в Self-Custody.
- **Privacy Score — локальный:** никакая серверная телеметрия не получает score или его компоненты.
- **Per-KYC limit:** конкретное значение определяется при реализации (conservative default).

## Связи

| Артефакт | Связь |
|---|---|
| ADR-027 | Audit-канал на стыке EMI ↔ Self-Custody |
| ADR-028 | KYC re-trigger events → пересмотр meta-address limit |
| ADR-074 | Stealth/silent payments — источник meta-addresses для limit |
| `customer-privacy-right-v2.md` | Базовый privacy-rights документ |
| I-54 | Ghost Mode = только Self-Custody |
| I-55 | Полный AML EMI на стыке контуров |
| I-58 | Per-KYC limit meta-addresses |
