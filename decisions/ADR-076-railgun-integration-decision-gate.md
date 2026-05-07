# ADR-076: RAILGUN Integration Decision Gate

**Status:** PENDING LEGAL REVIEW
**Date:** 2026-05-07
**Context:** Ghost Mode Privacy Tech Stack — Phase 3 (conditional)

---

## Контекст

RAILGUN — open-source протокол zk-SNARK приватности для EVM-чейнов (Ethereum, Arbitrum, Polygon). Технологически: Groth16 proofs, Merkle Tree UTXOs, nullifiers. TVL ~$70M, объём транзакций >$2B.

**RAILGUN ≠ Tornado Cash:**
- Tornado Cash: pool-based mixer → запрещён OFAC. **Не поддерживается BANXE.**
- RAILGUN: UTXO-based ZK proof → не mixer. Имеет compliance hooks: Viewing Keys (read-only audit), Private Proofs of Innocence (PPOI — ZK-доказательство отсутствия связи с sanctioned actors), tax exports.

**Проблема:** регуляторная позиция EU/UK по RAILGUN не финализирована. Интеграция RAILGUN в Ghost Mode (BANXE Self-Custody) требует предварительного legal clearance.

## Решение

Условное. Активация RAILGUN в Ghost Mode возможна **только после** выполнения всех gate-условий:

1. **Legal opinion EU/UK** — письменное заключение юристов о допустимости использования RAILGUN для non-custodial кошелька, зарегистрированного в EU/UK.
2. **OFAC nexus rules** — подтверждение, что RAILGUN protocol (в отличие от Tornado Cash) не подпадает под OFAC SDN; Viewing Keys + PPOI достаточны для compliance.
3. **PPOI / Viewing Keys production validation** — подтверждение работоспособности compliance hooks в продакшен-флоу (не только testnet).
4. **FCA CP26/13 clearance** (для UK-аудитории) — если Ghost Mode с RAILGUN затрагивает «arranging» perimeter.

До выполнения всех gate-условий: RAILGUN в UI скрыт / disabled (`🔐 ZK Shield (RAILGUN) — PENDING LEGAL REVIEW`).

## Fallback

Без RAILGUN: Ghost Mode работает на уровнях 1–4 и 6 (ERC-5564 stealth, BIP-352 silent payments, BIP-77 PayJoin, HD rotation + Privacy Score, W3C VC + ZKP identity). Privacy Score: компонент RAILGUN = 0 баллов до gate clearance.

## Альтернативы

| Альтернатива | Причина отклонения |
|---|---|
| Интеграция без legal gate | Регуляторный риск: RAILGUN может быть переклассифицирован; юридические последствия для EMI holder (BANXE.COM) |
| Tornado Cash | Запрещён OFAC; pool-based mixer. Запрещён по I-49 |
| Aztec Network (ZK L2) | Менее зрелый; нет production compliance hooks уровня PPOI/Viewing Keys |
| Полный отказ от ZK privacy layer | Снижает общий уровень приватности Ghost Mode; fallback приемлем, но не оптимален |

## Последствия

- **При ACCEPTED:** RAILGUN shield активируется в Ghost Mode UI; Privacy Score += 10; Viewing Keys доступны для holder's choice audit.
- **При REJECTED:** Fallback (уровни 1–4 + 6); Privacy Score max = 90 вместо 100.
- **OFAC/EU/UK sanctions:** при попадании контрагента/адреса в санкционные списки — RAILGUN-операция блокируется на on/off-ramp и через VC-policy, независимо от PPOI.
- **UI:** до gate clearance — `PENDING LEGAL REVIEW` (I-57).

## Связи

| Артефакт | Связь |
|---|---|
| ADR-074 | Stealth/silent payments — уровни 1–2 (работают без RAILGUN) |
| ADR-075 | PayJoin + Privacy Score — уровни 3–4 (работают без RAILGUN) |
| `customer-privacy-right-v2.md` | Базовый privacy-rights документ |
| I-57 | RAILGUN активируется только после ADR-076 legal clearance |
| I-54 | Ghost Mode = только Self-Custody |
| I-56 | Stablecoin issuer freeze/denylist без исключений (включая RAILGUN shielded tokens) |
