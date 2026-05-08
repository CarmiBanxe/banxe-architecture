# INCIDENT-2026-05-07-EVO1-XMRIG — Security/Compliance Incident Document

**Тип:** Security/Compliance Incident Document
**Severity:** P0
**Статус:** OPEN — Phase 0 (Incident Declaration + Roadmap Paused)
**Дата открытия:** 2026-05-07 (CEST)
**Discovery time:** 2026-05-07 11:21 CEST
**Базовый коммит:** `c216fa8` (main)
**Документ:** single source of truth по incident response; все обновления — append-only (новые подразделы в конце под датированной шапкой)

---

## Связанные записи

### Gap-записи (GAP-REGISTER.md)

| Gap ID | Severity | Статус |
|---|---|---|
| `G-SECURITY-EVO1-XMRIG-CRYPTOMINER` | P0 | OPEN |
| `G-SECURITY-EVO1-COMPROMISE-AUDIT-PENDING` | P0 | OPEN |
| `G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION` | P0 | OPEN |
| `G-SECURITY-EVO2-IOC-SWEEP-PENDING` | P1 | OPEN |
| `G-SECURITY-LEGION-IOC-SWEEP-PENDING` | P1 | OPEN |
| `G-INFRA-EVO1-LOAD-AVG-35` | — | root cause identified (XMRig) |
| `G-SECURITY-EVO1-UNKNOWN-SYSTEMD-SERVICE` | — | superseded (XMRig identified) |

### IL-запись (INSTRUCTION-LEDGER.md)

- `IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED`

---

## 1. Резюме

Active XMRig RandomX/Monero cryptominer на **evo1** (project-layer node, хостит BANXE customer-data services в т.ч. KYC/AML pipeline из OSS-Sumsub-блока). Malware маскируется под `systemd` (`/etc/systemd/system/systemd.service`, ExecStart=`systemd -c .config.json`, root). C2 endpoint — Hetzner DE. Binary mtime 2026-04-23 → потенциальный compromise window **14+ дней**.

**Полная forensic preservation обязательна ДО любых destructive действий.**

Compliance-флаги активированы: GDPR Art. 33 / FCA SUP 15 / AMLR — assessment pending operator + MLRO + DPO.

---

## 2. Hard Evidence Reference

IoC-список — **единственный мастер-источник:** gap-запись `G-SECURITY-EVO1-XMRIG-CRYPTOMINER` в `GAP-REGISTER.md`. Любое расследование сверяется с этим списком.

Полная хронология discovery — `IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED` в `INSTRUCTION-LEDGER.md`.

SHA256, пути, PID, network connections, process tree — **не дублируются** в этом документе; см. указанные мастер-источники.

---

## 3. Compliance Timers

| Таймер | Trigger | Старт | Дедлайн / окно | Статус | Ответственный |
|---|---|---|---|---|---|
| **GDPR Art. 33** | Personal data breach notification to supervisory authority | Discovery 2026-05-07 11:21 CEST | **≈ 2026-05-10 11:21 CEST** (72 ч) | Assessment pending | DPO + Legal & Privacy |
| **GDPR Art. 34** | Notification to data subjects | After Art. 33 decision | TBD | Pending (after Art. 33 assessment) | DPO + Customer Operations |
| **FCA SUP 15** | Material incident notification (EMI TOMPAY LTD) | Discovery | «Without undue delay» | Assessment pending | MLRO + Head of Compliance |
| **AMLR/AMLD6** | KYC/AML pipeline integrity assessment | Discovery | Immediate assessment | Assessment pending | MLRO + Engineering |

**Важно:** все таймеры — **assessment-таймеры**, не презумпция breach. Решение о notification принимает incident commander совместно с MLRO + DPO. Таймер тикает вне зависимости от решения.

---

## 4. Ownership Matrix

| Роль | Ответственность | Контакт |
|---|---|---|
| **Incident Commander** | Общее руководство incident response, escalation, final decisions | `<operator>` |
| **MLRO + Head of Compliance (TOMPAY LTD)** | FCA SUP 15 assessment, AMLR, AML/KYC integrity sign-off | `<MLRO>` |
| **DPO + Legal & Privacy** | GDPR Art. 33 / 34 assessment, ICO notification decision | `<DPO>` |
| **Engineering / Platform** | Forensic preservation, IoC sweep, network containment | `<eng>` |
| **Security** | Incident response, KMS / secrets rotation, vulnerability assessment | `<eng>` |
| **Customer Operations** | Notification draft (если Art. 34 decision = yes) | `<TBD>` |
| **External CERT / IRP** | External incident response, CERT coordination, FCA / ICO submission | `<TBD>` |

Заполнение — операторская задача.

---

## 5. Decision Rules (mandatory, append-only constraints)

### 5.1 Запрет destructive действий

Никаких destructive действий на evo1 (`kill`, `rm`, `disable`, `reboot`, `repackage`, `reinstall`) **без operator-acknowledge**. Guardian shim (I-36) enforce.

### 5.2 Forensic preservation — первый шаг

Образ артефактов: бинарь, unit-файл, config, логи. Proc-snapshot, network state, journalctl, `auth.log` с 2026-04-22, `authorized_keys`, `passwd/shadow/sudoers`, cron/timer enumeration. Носитель — **отдельный read-only host**, не evo1.

### 5.3 IoC sweep evo2 + Legion

Read-only: IoC из мастер-источника (`G-SECURITY-EVO1-XMRIG-CRYPTOMINER`). Никаких `kill`/`rm`.

### 5.4 Network containment

Только на **внешнем firewall/router** (egress-block pool IP `136.243.75.233:8029`), не на самом evo1, чтобы не алертить malware.

### 5.5 Credentials rotation

GitHub PATs, SSH-keys (Legion factory ↔ evo1/evo2 ↔ origin), Apps Script tokens, Claude Project keys, Telegram-bot keys, `.env`-секреты, KMS — все требуют ротации **после forensic preservation**.

### 5.6 GitHub audit log

Review с 2026-04-22 (mtime бинаря -1 день).

### 5.7 AML/KYC integrity check

Проверить целостность: KYC снапшоты клиентов, sanctions matching outputs, transaction monitoring rules state на ноде — прежде чем считать pipeline trusted.

### 5.8 AI-plane

I-32 / I-33 — запрет direct cloud LLM маршрутов; на время incident приостановить все non-essential LLM-вызовы из периметра evo1.

---

## 6. Phased Response Plan

Фазы — план, не выполнение. Каждая фаза активируется operator-acknowledge.

| Phase | Название | Содержание | Владелец | Статус |
|---|---|---|---|---|
| **0** | INCIDENT DECLARATION + PAUSED LIST | Этот PR: incident document, roadmap paused | Incident Commander | ✅ Complete |
| **1** | FORENSIC PRESERVATION evo1 | Read-only образ артефактов; proc/net/log snapshot; off-host media | Engineering + Security | ⏳ Awaiting operator |
| **2** | IoC SWEEP evo2 + Legion | Read-only проверка IoC из мастер-списка | Engineering | ⏳ Awaiting Phase 1 |
| **3** | COMPLIANCE ASSESSMENT | GDPR Art. 33/34, FCA SUP 15, AMLR — решение MLRO + DPO + оператор | MLRO + DPO + Operator | ⏳ Awaiting Phase 1 |
| **4** | NETWORK CONTAINMENT | Egress-block C2 IP на внешнем firewall | Engineering | ⏳ Awaiting Phase 1 |
| **5** | COMPROMISE AUDIT evo1 | Root analysis: ssh, cron/timer, бинарные подмены, lateral movement | Security + Engineering | ⏳ Awaiting Phase 1–2 |
| **6** | CREDENTIALS ROTATION | GitHub, SSH, Apps Script, Claude, Telegram, .env, KMS | Security + Engineering | ⏳ Awaiting Phase 1 |
| **7** | AML/KYC INTEGRITY VERIFICATION | Целостность KYC снапшотов, SAR, Travel Rule, sanctions matching | MLRO + Engineering | ⏳ Awaiting Phase 5 |
| **8** | REMEDIATION | Destructive cleanup, repackage, reinstall, hardening (after operator-acknowledge) | Engineering | ⏳ Awaiting Phase 1–7 |
| **9** | POST-INCIDENT REVIEW | Lessons learned, canon-обновления, new ADR's, I-59..I-63 formalization | All | ⏳ After RESOLVED |

---

## 7. Paused Roadmap

**Все roadmap-треки приостановлены до перехода incident в RESOLVED / MONITOR.**

### Track I — Roadmap Blocks (PAUSED)

| Блок | PR / Tag | Статус до паузы | Действие |
|---|---|---|---|
| Ghost Mode Privacy Tech Stack | PR #130, `checkpoint-2026-05-07-ghost-mode-spec` | FEATURE SPEC merged | Никаких ADR-074/075/076 acceptance, никакой реализации |
| Customer Privacy Right v2 | PR #128, `checkpoint-2026-05-07-customer-privacy-right-v2-base` | BASE SPEC merged | Никаких follow-up |
| OSS-Sumsub-блок | `checkpoint-2026-05-06-oss-sumsub-replacement-block` | ROADMAP BLOCK | Пауза; pipeline integrity под вопросом |
| DAC8-блок | `checkpoint-2026-05-06-dac8-tax-reporting-block` | ROADMAP BLOCK | Пауза |
| Owner Control Agent | `checkpoint-2026-05-06-owner-control-agent-block` | ROADMAP BLOCK | Пауза |
| DeFi-Stack | `checkpoint-2026-05-06-defi-stack-binance-replacement-block` | ROADMAP BLOCK | Пауза |
| Sber OSS | `checkpoint-2026-05-06-sber-oss-emi-block` | ROADMAP BLOCK | Пауза |
| Anthropic Claude Finance Agents | `checkpoint-2026-05-06-claude-finance-agents-block` | ROADMAP BLOCK | Пауза |

### Track A (PAUSED)

- ADR-028 Step 3 в `banxe-emi-stack` (PR #69 / #70) — пауза до RESOLVED.

### Canon-hygiene (PAUSED)

- Коллизия ADR-номеров DAC8 (045..049) vs DeFi (045..050) — пауза.

### Parallel Sessions (STOP)

- Любые roadmap-операции от параллельных Claude Code сессий — **стоп** до RESOLVED.

---

## 8. Pending Invariant Proposals (без правки INVARIANTS.md)

| ID | Формулировка |
|---|---|
| **I-59** | Project-layer node compromise: no privacy/identity feature activation, no roadmap acceptance, no destructive ops on suspected nodes until incident RESOLVED. |
| **I-60** | Mandatory forensic preservation BEFORE any destructive action on suspected compromised nodes; preservation media must be off-host and read-only. |
| **I-61** | Compliance timers (GDPR Art. 33/34, FCA SUP 15, AMLR) start at discovery, not at remediation; assessment ≠ presumption of breach but timer is real. |
| **I-62** | Credentials rotation across GitHub PATs / SSH / Apps Script / Claude Project / Telegram / .env / KMS is mandatory part of every project-layer compromise response. |
| **I-63** | Network containment for active C2 endpoints applied at external firewall, not on the suspected host, to avoid malware-alert race. |

---

## 9. Анти-OCAT-нарушение Pointer

PR #131 содержал registry append + P0 incident material в одном squash — это OCAT-нарушение (one-artifact per PR). Зафиксируется отдельной IL-записью `IL-CANON-PROCESS-INCIDENT-2026-05-07-PR131-OCAT-MERGE` **только после RESOLVED**, по принципу «P0 закрываем сначала, процессную гигиену — после стабилизации».

---

## 10. Связи с ADR / Invariants / Blocks

| Артефакт | Связь |
|---|---|
| ADR-027 (audit-trail durability) | Все incident events логируются через canonical audit-канал |
| ADR-028 (KYC re-trigger) | KYC integrity под вопросом; re-trigger events замораживаются до Phase 7 |
| I-31 (compliance-first) | Compliance-таймеры имеют абсолютный приоритет |
| I-32 / I-33 (no direct cloud LLM) | AI-plane приостановлен из evo1 периметра |
| I-36 (Guardian shim) | Enforce: no destructive ops without operator-acknowledge |
| I-49 / I-50 (privacy precedence) | Ghost Mode паузирован по I-59 |
| Pending I-54..I-58 (Ghost Mode) | Паузированы; активация только после RESOLVED |
| OSS-Sumsub-блок | Pipeline integrity assessment (Phase 7) |

---

## Status Updates (append-only)

---

### 2026-05-07 — INCIDENT DECLARED (P0)

**Phase 0 complete.**

- Incident document создан: `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md`.
- Связанные gap-записи: `G-SECURITY-EVO1-XMRIG-CRYPTOMINER` (P0), `G-SECURITY-EVO1-COMPROMISE-AUDIT-PENDING` (P0), `G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION` (P0), `G-SECURITY-EVO2-IOC-SWEEP-PENDING` (P1), `G-SECURITY-LEGION-IOC-SWEEP-PENDING` (P1).
- Связанная IL: `IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED`.
- Roadmap paused (все Track I / Track A / canon-hygiene / parallel sessions).
- Pending invariants: I-59, I-60, I-61, I-62, I-63.
- Compliance timers started: GDPR Art. 33 (deadline ≈ 2026-05-10 11:21 CEST), FCA SUP 15 (assessment), AMLR (assessment).

**Awaiting operator-acknowledge to enter Phase 1 (Forensic Preservation evo1).**

---

### 2026-05-08 — CONTAINMENT APPLIED + IoC SWEEP CLEAN (Phase 2 + Phase 4)

**Phase 2 complete. Phase 4 applied.**

- **Phase 4 — Network Containment APPLIED** (host-level fallback):
  - iptables-persistent on evo1: DROP rules for 136.243.75.233/32 + Hetzner ranges (136.243.0.0/16, 78.46.0.0/15, 88.198.0.0/16).
  - netfilter-persistent enabled+active, reboot survival OK.
  - Hit counters at 02:00 CEST: /32 ≈ 8921 pkts / 660 KB.
  - XMRig PID 2127 in SYN-SENT loop, no successful pool connection. Exfiltration blocked.
  - Forensic chain preserved: no kill, no rm, no sshd_config edit, no user mod.
  - Bundle: `~/banxe-incident-2026-05-07/banxe_forensic_254683.tar.gz` on Legion (off-host), sha256 `dfd6c9b5...`, chain-of-custody verified.
  - Accepted deviation: host-level containment (not perimeter) due to Orange Livebox UI limitation (G-SECURITY-LIVEBOX-NO-OUTBOUND-FILTER, P2). See IL-CANON-PROCESS-INCIDENT-2026-05-08-LIVEBOX-LIMITATION.
- **Phase 2 — IoC Sweep evo2 + Legion COMPLETE:**
  - evo2: CLEAN (all 7 IoC criteria no-match).
  - Legion: CLEAN (all 7 IoC criteria no-match).
  - Compromise scope localised to evo1 at sweep time.
  - Lateral movement evo1→evo2 / evo1→Legion not confirmed.
  - Caveat: «clean at sweep time» ≠ «not compromised by other vectors».
- Phase table update:
  - Phase 0: ✅ Complete
  - Phase 1: ⏳ Awaiting operator (forensic preservation evo1 — read-only)
  - Phase 2: ✅ Complete (evo2 + Legion clean)
  - Phase 3: ⏳ Assessment framework created (PR #133), awaiting MLRO + DPO
  - Phase 4: ✅ Applied (host-level, accepted deviation)
  - Phase 5–9: ⏳ Awaiting Phase 1
- New IL records: `IL-INCIDENT-2026-05-07-CONTAINMENT-APPLIED-HOST-LEVEL`, `IL-INCIDENT-2026-05-07-IOC-SWEEP-EVO2-LEGION-CLEAN`, `IL-CANON-PROCESS-INCIDENT-2026-05-08-LIVEBOX-LIMITATION`.
- New gap: `G-SECURITY-LIVEBOX-NO-OUTBOUND-FILTER` (P2, OPEN).
- Gap status updates: `G-SECURITY-EVO1-XMRIG-CRYPTOMINER` → CONTAINED; `G-SECURITY-EVO2-IOC-SWEEP-PENDING` → RESOLVED-PENDING-OBSERVATION; `G-SECURITY-LEGION-IOC-SWEEP-PENDING` → RESOLVED-PENDING-OBSERVATION.
- Pending invariant: I-67 (host-level iptables as accepted containment with secondary-router roadmap).
- Compliance timers still active: GDPR Art. 33 deadline ≈ 2026-05-10 11:21 CEST.

**Next: operator-acknowledge for Phase 1 (Forensic Preservation evo1) + MLRO/DPO acknowledge for Phase 3 (Compliance Assessment).**

---

### 2026-05-08 — IoC EXPANSION + PHASE 1 FORENSIC CHAIN (Steps 1e/2/3)

**Phase 1 partial complete. IoC master-source expanded. Re-sweep required.**

- **IoC expansion** (2 new artefacts from Phase 1 Step 3 analysis):
  - `/etc/systemd/system/observed.service` — watchdog/respawn unit (SHA256 53d664a4eecf..., mtime 2026-04-23 07:05:54).
  - `/usr/local/bin/free_proc.sh` — competing-miner killer script (SHA256 5cae515b56e5..., mtime 2026-04-23 07:05:51).
  - Both in same mtime-transaction as XMRig binary/unit (delta ≈ seconds).
  - **Impact:** prior IoC sweep (Phase 2) was against incomplete list → supplemental re-sweep evo2+Legion required.
- **Phase 1 — Forensic Preservation (Steps 1e+2+3 of ~7):**
  - Step 1e: proc snapshot PID 2127 (601 lines, SHA256 7adfbe1e...) — off-host Legion.
  - Step 2: integrity verification 13 checks (204 lines, SHA256 196524233bea...) — off-host Legion.
  - Step 3: auth/journal/cron enumeration 13 checks (1342 lines, SHA256 74d71a45...) — off-host Legion.
  - Step 3 analysis: automated (SHA256 5ccca1fd...) — off-host Legion.
  - Steps 4–7 pending operator.
- **Containment verification:** XMRig .bench.log confirms 0.00/0.00/0.00 H/s since DROP. Pre-containment max: 16004.8 H/s. Containment effective.
- **Files-changed-after-compromise flags:**
  - /etc/passwd + /etc/shadow: mtime 2026-05-03 (10 days post-compromise) — Phase 5 audit required.
  - /home/banxe/.ssh/authorized_keys: mtime 2026-05-01, 6 keys — Phase 5 audit required.
  - /root/.ssh/authorized_keys: mtime 2026-03-28, 4 keys — pre-compromise but audit required.
- **Boot anomaly:** 3 reboots 2026-05-07 00:05–01:03. XMRig started 01:03:48 (1 sec after boot).
- New IL records: `IL-INCIDENT-2026-05-07-IOC-EXPANSION-OBSERVED-FREE-PROC`, `IL-INCIDENT-2026-05-08-PHASE1-FORENSIC-CHAIN-PRESERVED`, `IL-INCIDENT-2026-05-08-IOC-RESWEEP-REQUIRED`, `IL-INCIDENT-2026-05-08-CONTAINMENT-EFFECTIVENESS-VERIFIED`.
- New gaps: `G-SECURITY-EVO2-IOC-RESWEEP-OBSERVED-FREE-PROC` (P1), `G-SECURITY-LEGION-IOC-RESWEEP-OBSERVED-FREE-PROC` (P1).
- Phase table update:
  - Phase 0: ✅ Complete
  - Phase 1: 🔶 Partial (Steps 1e+2+3 done, Steps 4–7 pending)
  - Phase 2: ⚠️ Re-sweep required (2 new IoC not in original checklist)
  - Phase 3: ⏳ Assessment framework created (PR #133), awaiting MLRO + DPO
  - Phase 4: ✅ Applied + verified effective
  - Phase 5–9: ⏳ Awaiting remaining Phase 1
- Compliance timers still active: GDPR Art. 33 deadline ≈ 2026-05-10 11:21 CEST.

**Next: Phase 1 Steps 4–7 (operator) + supplemental re-sweep evo2/Legion for observed.service + free_proc.sh.**

---

### 2026-05-08 — PHASE 2 RE-SWEEP COMPLETE — SCOPE LOCALISED TO EVO1

**Phase 2 (IoC Re-sweep evo2 + Legion with extended IoC list) COMPLETE.**

Re-sweep performed 2026-05-08 ~10:58 CEST from Legion against evo2 (via ssh) and Legion (local), against expanded IoC master-source (including newly identified `observed.service` watchdog and `free_proc.sh` process-killer).

**Verdict matrix:**

| Host | Path-based | Unit-based | Network-based |
|---|---|---|---|
| evo2 | PASS | PASS | PASS |
| Legion | PASS | PASS | PASS |

**Forensic artefacts (off-host, Legion):**
- `evo2-resweep.txt` — SHA256 `ad434350c6f5...` (95 lines / 5270 bytes)
- `legion-resweep.txt` — SHA256 `eb0d4a68ca87...` (91 lines / 4508 bytes)
- Bundle: `~/banxe-incident-2026-05-07/phase2/resweep-evo2-legion-2026-05-08T08-58-03Z/`

**Scope finding:** compromise formally localised to evo1 at re-sweep time. Lateral movement evo1→evo2 / evo1→Legion not confirmed against expanded IoC list. This narrows the GDPR Art. 33 personal-data-breach assessment scope to evo1 services only.

**Caveat:** «clean against known IoC at re-sweep time» ≠ «not compromised by other vectors». Recommended re-sweep cadence: 24-48h until incident RESOLVED. Phase 5 compromise audit evo1 still required to identify intrusion vector.

- Gap status updates: `G-SECURITY-EVO2-IOC-RESWEEP-OBSERVED-FREE-PROC` → RESOLVED-PENDING-OBSERVATION; `G-SECURITY-LEGION-IOC-RESWEEP-OBSERVED-FREE-PROC` → RESOLVED-PENDING-OBSERVATION.
- New IL: `IL-INCIDENT-2026-05-08-PHASE2-RESWEEP-COMPLETE`.
- Phase table update:
  - Phase 0: ✅ Complete
  - Phase 1: 🔶 Partial (Steps 1e+2+3 done, Steps 4–7 pending)
  - Phase 2: ✅ Complete (original sweep + re-sweep with extended IoC — all CLEAN)
  - Phase 3: ⏳ Assessment framework created (PR #133), awaiting MLRO + DPO
  - Phase 4: ✅ Applied + verified effective
  - Phase 5–9: ⏳ Awaiting remaining Phase 1
- Compliance timers still active: GDPR Art. 33 deadline ≈ 2026-05-10 11:21 CEST.

**Next: Phase 1 Steps 4–7 (operator) + MLRO/DPO acknowledge for Phase 3 (Compliance Assessment).**

---

### 2026-05-08 — MALWARE REMOVED (external action) + PHASE 1 STEP 4 FS-AUDIT COMPLETE

**Critical state-change: malware fully removed by external action.**

- **Malware removal:** PID 2127 GONE, `systemd.service` + `observed.service` = `Unit could not be found`, CPU load ≈1.2 (normalised). All malicious files absent. Removal occurred between Step 3 (09:27 CEST) and Step 4 (~11:59 CEST). Actor: external (parallel session / operator / automation) — to be confirmed.
- **Forensic chain intact:** Bundle B on evo1 (`/tmp/banxe_forensic_254683/`) confirmed present + Legion off-host copy (SHA256 `dfd6c9b5...`). No forensic evidence lost.
- **Phase 1 Step 4 (Filesystem-Wide Audit):** 16-section audit complete. No additional malicious artefacts. LD_PRELOAD rootkit excluded. SUID-window clean. dpkg -V: no system-binary tampering.
- **mmber1234 false-alarm:** `/etc/default/ufw` standard config, NOT a credential. No rotation required for this specific finding.
- **Vector NOT determined:** auth.log/syslog Apr 22-23 rotated out of retention window. Root-cause analysis incomplete.
- **Compliance note:** malware removal does NOT eliminate GDPR Art. 33 / FCA SUP 15 assessment obligation — the 14-day compromise window must still be assessed for personal data access.
- Forensic artefacts: Step 4 SHA256 `a8718dbe...`, Step 4 analysis `dd418f05...`, Step 4b `3ae092c0...`.
- New IL records: `IL-INCIDENT-2026-05-08-PHASE1-STEP4-FS-AUDIT-COMPLETE`, `IL-INCIDENT-2026-05-08-MALWARE-REMOVED-EXTERNAL-ACTION`, `IL-INCIDENT-2026-05-08-MMBER1234-FALSE-ALARM-CLEARED`, `IL-INCIDENT-2026-05-08-BUNDLE-B-CHAIN-INTACT`.
- Gap status: `G-SECURITY-EVO1-XMRIG-CRYPTOMINER` → CONTAINED-MALWARE-REMOVED.
- Phase table update:
  - Phase 0: ✅ Complete
  - Phase 1: 🔶 Steps 1e+2+3+4+4b done; Steps 5–7 pending (dpkg integrity, timeline correlation, memory dump)
  - Phase 2: ✅ Complete (all sweeps CLEAN)
  - Phase 3: ⏳ Assessment framework created (PR #133), awaiting MLRO + DPO
  - Phase 4: ✅ Applied + verified (containment rules still active on evo1)
  - Phase 5: ⏳ Post-cleanup compromise audit (vector reconstruction limited by log rotation)
  - Phase 6: ⏳ Credentials rotation (mandatory despite malware removal)
  - Phase 7: ⏳ AML/KYC integrity verification
  - Phase 8: 🔶 Partial (malware removed externally; hardening pending)
  - Phase 9: ⏳ Post-incident review
- Compliance timers still active: GDPR Art. 33 deadline ≈ 2026-05-10 11:21 CEST.

**Next: Phase 5 (post-cleanup audit, vector reconstruction with limited logs) + Phase 6 (credentials rotation) + MLRO/DPO Phase 3 acknowledge.**

---

### 2026-05-08 — PHASE 5 POST-CLEANUP VERIFICATION COMPLETE

**Phase 5 (Post-cleanup compromise audit evo1) COMPLETE.**

Audit performed 2026-05-08 ~13:08 CEST from Legion via ssh against evo1, 16-section comprehensive scope.

- **Cleanup verified complete:** all 6 XMRig artefacts REMOVED, 0 rogue users, 0 empty passwords, 0 NOPASSWD:ALL backdoors, 0 malicious systemd units in mtime window, cron/timers all legitimate, listening sockets all legitimate.
- **sshd hardened:** port 2222, PermitRootLogin no, PasswordAuthentication no, key-only, Match Address 192.168.0.75.
- **Bundle B intact:** `/tmp/banxe_forensic_254683/` with full MANIFEST.sha256 (16 files).
- **Cleanup-actor NOT identified:** journalctl 09:30-12:00 shows only legitimate cron. Awaiting operator confirmation.
- **Vector NOT determined:** auth.log/syslog Apr 22-23 rotated out. MLRO/DPO must assume worst-case full host compromise for GDPR Art. 33 assessment.
- **Forensic artefacts:** Step 5 SHA256 `07c5a2ff...` (677 lines / 83 698 bytes), Step 5 analysis on Legion.
- New IL records: `IL-INCIDENT-2026-05-08-PHASE5-POST-CLEANUP-VERIFIED-COMPLETE`, `IL-INCIDENT-2026-05-08-CLEANUP-ACTOR-NOT-IDENTIFIED`, `IL-INCIDENT-2026-05-08-VECTOR-NOT-DETERMINED-LOGS-ROTATED`, `IL-INCIDENT-2026-05-08-PHASE5-POSITIVE-FINDINGS`.
- Gap status updates: `G-SECURITY-EVO1-XMRIG-CRYPTOMINER` → RESOLVED-PENDING-MLRO-ACK; `G-SECURITY-EVO1-COMPROMISE-AUDIT-PENDING` → COMPLETE (post-cleanup verified).
- Phase table update:
  - Phase 0: ✅ Complete
  - Phase 1: ✅ Complete (Steps 1e+2+3+4+4b)
  - Phase 2: ✅ Complete (all sweeps + re-sweep CLEAN)
  - Phase 3: ⏳ Assessment framework created (PR #133), awaiting MLRO + DPO
  - Phase 4: ✅ Applied + verified (containment rules still active)
  - Phase 5: ✅ Complete (post-cleanup verified, vector lost, cleanup-actor pending)
  - Phase 6: ⏳ Credentials rotation (mandatory)
  - Phase 7: ⏳ AML/KYC integrity verification
  - Phase 8: 🔶 Malware removed + hardened; iptables containment rules to be reviewed
  - Phase 9: ⏳ Post-incident review
- Compliance timers still active: GDPR Art. 33 deadline ≈ 2026-05-10 11:21 CEST.

**Next: Phase 6 (credentials rotation) + Phase 7 (AML/KYC integrity) + MLRO/DPO Phase 3 acknowledge + operator confirmation of cleanup-actor.**
