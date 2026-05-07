# ADR-074: Stealth Addresses, Silent Payments & ZKP Identity for Ghost Mode

**Status:** PROPOSED
**Date:** 2026-05-07
**Context:** Ghost Mode Privacy Tech Stack — Phase 1 + Phase 2 (identity layer)

---

## Контекст

Ghost Mode (BANXE Self-Custody, out-of-scope EMI) требует криптографических примитивов для приватности получателя на публичных блокчейнах:

- **ERC-5564 + ERC-6538** — stealth addresses для EVM-чейнов (Ethereum, Arbitrum, Polygon, Base, Optimism). Singleton contract: `0x55649E01B5Df198D18D95b5cc5051630cfD45564`. Крипто-схема: SECP256k1.
- **BIP-352** — silent payments для Bitcoin (Complete v1.0.2). SDK: `bdk-sp` (Bitcoin Dev Kit). Hardware wallet: BIP-375 (DLEQ proofs).
- **W3C VC 2.0 + ZKP** — verifiable credentials с BBS+ signatures / AnonCreds для selective disclosure identity. SDK: walt.id. Регуляторная опора: eIDAS 2.0 ARF, GDPR Art. 25.

## Решение

To be specified at implementation.

При реализации решение должно покрывать:
1. Интеграцию ERC-5564 stealth meta-address в Self-Custody кошелёк (EVM).
2. Интеграцию BIP-352 silent payments в Self-Custody кошелёк (Bitcoin).
3. Выпуск W3C VC после KYC через EMI BANXE с обязательным non-PII AML-anchor для lawful access.
4. Механизм revocation и expiry для VC.
5. Per-KYC limit на активные meta-addresses (I-58).
6. Scan-инфраструктуру с гарантией privacy-by-design (meta-address ↔ device не привязываются).

## Альтернативы

| Альтернатива | Причина отклонения |
|---|---|
| Голая HD-ротация (BIP-32/44) без stealth/silent | Недостаточный уровень приватности: адреса связываются через xPub и change outputs |
| Отказ от VC selective disclosure | Нарушает GDPR Art. 25 (data minimisation); не соответствует eIDAS 2.0 ARF |
| Privacy coins (Monero, Zcash shielded) | Запрещены по I-49; несовместимы с AML/CFT канвейером |

## Последствия

- **Scanning overhead:** recipient должен сканировать blockchain (ERC-5564) / все транзакции (BIP-352) для обнаружения входящих. Light-client — open research.
- **Gas overhead:** ERC-5564 `announce()` добавляет gas cost (существенно на L1, приемлемо на L2).
- **Key management:** потеря scan/spend keys = потеря возможности обнаружить/потратить средства. Self-Custody канон: BANXE не восстанавливает.
- **VC lifecycle:** обязательный non-PII AML-anchor, expiry, revocation list. ADR-028 события триггерят revocation.
- **Provider-side observability:** scan-сервер не должен привязывать meta-address ↔ device (I-58).

## Связи

| Артефакт | Связь |
|---|---|
| ADR-027 | Все события на стыке EMI ↔ Self-Custody логируются через audit-канал |
| ADR-028 | `JURISDICTION_CHANGED` / `ROLE_CHANGED` / `BENEFICIAL_OWNER_CHANGED` → revocation VC |
| `customer-privacy-right-v2.md` | Базовый privacy-rights документ; обязательная зависимость |
| I-54 | Ghost Mode = только Self-Custody |
| I-55 | Полный AML EMI на стыке контуров |
| I-56 | Stablecoin issuer freeze/denylist без исключений |
| I-58 | Per-KYC limit meta-addresses; scan privacy-by-design |
