# HANDOFF 2026-05-06 — Canon Stack + Phase A live-evidence + BIOS uplift plan
<!-- Created: 2026-05-06 | Branch: docs/handoff-canon-stack-bios-uplift-2026-05-06 -->
<!-- Purpose: state transfer from 2026-05-06 session to the next session -->

## 1. Назначение

Документ — пакет переноса состояния сессии 2026-05-06 в следующую сессию.
В новой сессии команда: сначала включить и настроить BIOS на evo1 и evo2,
затем привести Legion (WSL2 + локальный coder) к канону, затем выровнять модели
и агентскую оркестрацию (Ruflo, LiteLLM маршруты, OpenClaw/Guardian) в искомый вид.
Финальные закрытия задач — только по operator-confirmation.

---

## 2. main HEAD на момент handoff

- **SHA:** `aa1c3bc8b648291b81ed868013c2c2679f4de4e1`
- Последние ключевые PR (закрытые/смерженные):

| PR | Описание |
|----|----------|
| #98 | Factory/Project Stack Canon |
| #99 | Ruflo orchestration canon |
| #100 | IL-CANON-RUFLO-2026-05-06 |
| #104 | G-FACTORY-LITELLM-DUPLICATE closed |
| #109 | runbook G-FACTORY-WSL2-RAM-CAP |
| #111 | HW baseline canon |
| #112 | runbooks evo1 BIOS/UMA + evo2 ROCm/Vulkan |
| #115 | Phase A IL для evo1 + Legion + evo2; +2 новых gap |
| #116 | IL-CANON-PROCESS-INCIDENT-2026-05-06 |

---

## 3. Канонический стек (binding)

- **Legion** = developer factory layer (64 GB RAM, 4+ TB SSD, NVIDIA RTX 4070 Laptop 8 GB VRAM).
- **evo1** = infrastructure / services layer (128 GB RAM, large SSD).
- **evo2** = heavy model / project reasoning layer (128 GB RAM, 1.9 TB SSD, AMD GPU [1002:1586]).
- Один канонический LiteLLM gateway: `litellm-v2.service` на `0.0.0.0:4000`.
- Ruflo обязателен в pipeline для regulated операций:
  `request → ARL → Ruflo → target agent → response`.
- Все будущие решения по моделям/сервисам — со ссылкой на HW baseline и live shell.

Источники: `docs/canon/factory-project-stack-2026-05.md`, IL-CANON-STACK-2026-05-06,
IL-CANON-RUFLO-2026-05-06, IL-CANON-HW-BASELINE-2026-05-06.

---

## 4. Подтверждённое физическое железо (DMI + lshw, 2026-05-06)

| Узел | Конфигурация памяти | Physical RAM |
|------|-------------------|-------------|
| evo1 | 8 × 16 GB Samsung DDR5 8000 MT/s, каналы P0 CHANNEL A..H | **128 GB** |
| evo2 | 8 × 16 GB Micron DDR5 8000–8532 MT/s, каналы P0 CHANNEL A..H | **128 GB** |
| Legion | Canon (физическое подтверждение через спецификацию) | **64 GB** |

- evo2 AMD GPU: `lspci c5:00.0 [1002:1586] rev c1`; `vulkaninfo` не показывает hardware
  device; `rocminfo` отсутствует (команда не найдена).
- Legion NVIDIA: RTX 4070 Laptop 8 GB VRAM; `nvidia-smi` GPU-Util 0%; нет compute процессов.

Источник: IL-OPS-G-INFRA-EVO1-PHASE-A-2026-05-06, IL-OPS-G-FACTORY-LEGION-PHASE-A-2026-05-06,
IL-OPS-G-INFRA-EVO2-PHASE-A-2026-05-06 (все в main через PR #115).

---

## 5. Зазоры (OS-visible vs physical)

| Узел | OS-visible | Physical | % видимости | Причина |
|------|-----------|---------|-------------|---------|
| Legion | ~23.5 GiB (WSL2) | 64 GB | ~37% | WSL2 default cap |
| evo1 | ~31.9 GiB (`lsmem`) | 128 GB | ~25% | BIOS/UMA mismatch |
| evo2 | ~93.9 GiB (`/proc/meminfo`) | 128 GB | ~73% | BIOS/UMA mismatch (меньший масштаб) |
| evo2 GPU | 0% utilisation | AMD GPU | — | ROCm/Vulkan stack inactive |
| Legion coder | нет (OLLAMA_HOST→evo1) | RTX 4070 8 GB | — | локальная модель не установлена |

---

## 6. Открытые HW/ops gaps (binding в GAP-REGISTER)

| Gap ID | Priority | Статус | Описание |
|--------|----------|--------|----------|
| G-INFRA-EVO1-RAM-VISIBILITY | P1 | OPEN | BIOS/UMA mismatch на evo1; ждёт Phase C |
| G-INFRA-EVO2-GPU-STACK | P1 | OPEN | Vulkan/ROCm не активен на evo2 |
| G-INFRA-EVO2-RAM-VISIBILITY | P2 | OPEN | BIOS/UMA mismatch на evo2 (~93.9 GiB vs 128 GB) |
| G-FACTORY-WSL2-RAM-CAP | P2 | OPEN | WSL2 cap на Legion (~23.5 GiB vs 64 GB) |
| G-FACTORY-OLLAMA-OFFLOAD | P2 | OPEN | Legion без локального coder; RTX 4070 idle |
| G-CANON-HW-BASELINE | P2 | **CLOSED** | Canon применён через PR #111 |

---

## 7. Runbooks для следующей сессии (operator-gated)

| Runbook | Назначение |
|---------|-----------|
| `docs/runbooks/fa-evo1-bios-uma-audit.md` | evo1 BIOS Phase C (UMA / Memory Remap) |
| `docs/runbooks/fa-evo2-gpu-stack.md` | evo2 GPU stack: Mesa + ROCm install + Ollama wiring |
| `docs/runbooks/fa-wsl2-ram-cap-and-ollama-cache.md` | Legion WSL2 memory + Ollama cache to SSD |

**Дополнительно:** BIOS audit на evo2 (RAM visibility) использует `fa-evo1-bios-uma-audit.md`
как шаблон до появления отдельного evo2-specific runbook'а.

---

## 8. Точный план следующей сессии

Шаги выполняются **ПОСЛЕДОВАТЕЛЬНО** (BIOS первым). Каждый шаг — отдельная `IL-OPS-*-EXECUTED`
запись. Ни один gap не закрывается без operator-confirmation и live-shell acceptance criteria.

### Шаг 1. evo1 BIOS uplift → 128 GiB видимых

Runbook: `fa-evo1-bios-uma-audit.md` Phase C.

Настройки BIOS (записать prior values перед изменением):

| Настройка | Расположение | Цель |
|-----------|-------------|------|
| UMA Frame Buffer Size | Advanced → AMD CBS → NBIO → UMA | 512 MB (минимум; не 0 MB) |
| Memory Remap / Above 4G Decoding | Advanced → PCI | Enabled |
| Memory Frequency | Advanced → Memory | Auto (или паспорт DIMM: DDR5 8000 MT/s) |

**Verify (Phase D):**
```bash
free -h                                    # ожидание: ≥ 110 GiB total
lsmem --summary                            # online memory ≈ 128G
dmesg | grep -i memory | grep -iv 'BIOS-provided\|firmware provided' | head -20
```

Pass criteria: `free -h` total ≥ 110 GiB; no unexpected boot failures; all DIMMs intact.

**На успех:** IL-OPS-G-INFRA-EVO1-PHASE-C-EXECUTED-2026-05-XX → `G-INFRA-EVO1-RAM-VISIBILITY` CLOSED.
**На неуспех:** оставить gap OPEN; escalate к BIOS firmware update или физической проверке DIMM.

---

### Шаг 2. evo2 BIOS uplift → 128 GiB видимых

Аналогично шагу 1 (UMA Frame Buffer Size → 512 MB, Memory Remap → Enabled, Above 4G Decoding → Enabled).
Цель: `free -h` ≥ 110 GiB на evo2.

**На успех:** IL-OPS-G-INFRA-EVO2-RAM-VISIBILITY-EXECUTED-2026-05-XX → `G-INFRA-EVO2-RAM-VISIBILITY` CLOSED.

---

### Шаг 3. evo2 GPU stack restore (ROCm + Vulkan)

Runbook: `fa-evo2-gpu-stack.md` Phase B–D.

```bash
# Phase B — установка пакетов
sudo apt-get install -y mesa-vulkan-drivers libvulkan1 vulkan-tools linux-firmware libdrm-amdgpu1
# ROCm репозиторий + установка
wget -q https://repo.radeon.com/rocm/rocm.gpg.key -O - | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/rocm.gpg
sudo apt-get install -y rocminfo rocm-smi-lib rocm-libs
sudo usermod -aG render,video $USER && sudo reboot

# Phase C — gfx target
rocminfo | grep 'gfx\|Name'
# GPU [1002:1586] — определить RDNA поколение, задать HSA_OVERRIDE_GFX_VERSION

# Ollama drop-in (после определения gfx target)
sudo mkdir -p /etc/systemd/system/ollama.service.d/
sudo tee /etc/systemd/system/ollama.service.d/gpu.conf <<'EOF'
[Service]
Environment="HSA_OVERRIDE_GFX_VERSION=gfxXXXX"   # заменить по rocminfo
Environment="AMD_VISIBLE_DEVICES=all"
Environment="OLLAMA_GPU_LAYERS=auto"
EOF
sudo systemctl daemon-reload && sudo systemctl restart ollama.service
```

**Verify (Phase D):**
- `vulkaninfo --summary` → AMD RADV или AMDVLK device (не llvmpipe).
- `rocminfo` → GPU agent в списке.
- Smoke test: Ollama + `watch -n1 radeontop` → GPU utilisation > 0% во время инференса.

**На успех:** IL-OPS-G-INFRA-EVO2-GPU-STACK-EXECUTED-2026-05-XX → `G-INFRA-EVO2-GPU-STACK` CLOSED.

---

### Шаг 4. Legion WSL2 + Ollama cache + локальная coding-модель

Runbook: `fa-wsl2-ram-cap-and-ollama-cache.md`.

```
# C:\Users\<user>\.wslconfig
[wsl2]
memory=56GB
processors=auto
swap=8GB
localhostForwarding=true
```

```bash
# После wsl --shutdown и перезапуска
free -h                                    # ожидание: ~50–56 GiB
rsync -av ~/.ollama/models/ /mnt/d/ollama-models/
export OLLAMA_MODELS=/mnt/d/ollama-models  # добавить в ~/.bashrc или systemd unit
# OLLAMA_HOST=127.0.0.1:11434 (локальный)
# Установить coding-модель через Ollama: 32B+ class с GPU-offload на RTX 4070
# Верифицировать через LiteLLM factory-fast маршрут
```

**Модель для Legion (ориентир):** Qwen2.5-Coder-32B Q4_K_M или эквивалент (8 GB VRAM
с частичным CPU offload; или 7B Q8 если только GPU). Выбор финализируется по результатам
шагов 1–3 (какие узлы освободились).

**На успех:**
- IL-OPS-G-FACTORY-WSL2-RAM-CAP-EXECUTED-2026-05-XX → `G-FACTORY-WSL2-RAM-CAP` CLOSED.
- IL-OPS-G-FACTORY-OLLAMA-OFFLOAD-EXECUTED-2026-05-XX → `G-FACTORY-OLLAMA-OFFLOAD` CLOSED.

---

### Шаг 5. Models + Agent orchestration uplift

Сверить и при необходимости обновить после шагов 1–4:

**Canon-файлы для обновления:**
- `docs/canon/HW-MODEL-UPGRADE-matrix.md` — какая модель на каком узле.
- `docs/canon/factory-project-stack-2026-05.md` — ссылки на актуальные coding и heavy модели.

**LiteLLM маршруты (цель):**

| Маршрут | Цель |
|---------|------|
| `factory-fast` | Legion local coder (RTX 4070, после шага 4) |
| `factory-mid` | подходящий узел (уточнить после uplift'ов) |
| `factory-heavy` / `project-reason` | evo2 heavy model (qwen3:235b или апгрейд после GPU fix) |

**Ruflo:**
- Подтвердить: для всех regulated-маршрутов (payment / compliance / KYC / AML / EMI/FCA)
  pipeline проходит: `request → ARL → Ruflo → target agent → response`.
- Проверить логирование Ruflo через Guardian: factory `:8195` / project `:8196`.
- Каждое изменение маршрутов — ADR + IL.

---

### Шаг 6. Эффективность и upgrade canon

- Раз в N дней (определить отдельно) supervisor запускает live-shell аудит:
  `uptime / free / df / nvidia-smi / ss / docker / systemctl` на Legion + evo1 + evo2.
- Проверяет внешние источники (GitHub, ML-сообщество) на предмет более эффективных моделей.
- Предложения апгрейда фиксируются: ADR + IL + GAP-REGISTER.

---

## 9. Operator-confirmation gate (binding)

- **Ни один gap не закрывается** без явного operator-confirmation и live-shell проверки
  соответствующего acceptance criterion из runbook'а.
- Любая попытка закрыть gap «по предположению» или «по памяти» — нарушение канона.
- При обнаружении leakage между сессиями (canon-файлы в чужом PR без явной заявки)
  supervisor обязан зафиксировать инцидент через `IL-CANON-PROCESS-INCIDENT` и не
  маркировать задачу как выполненную.

Источник: IL-CANON-PROCESS-HYGIENE-2026-05-06, IL-CANON-PROCESS-INCIDENT-2026-05-06.

---

## 10. Что новая сессия должна сделать в первые шаги

1. Прочитать этот HANDOFF до конца (без сокращений).
2. Выполнить **read-only live-shell проверку** всех трёх машин:
   ```bash
   # На каждом узле (Legion / evo1 / evo2):
   uptime; free -h; df -h /; lspci -nn | grep -iE 'vga|3d|display'
   ss -tlnp | grep -E '4000|11434|8082|8195|8196'
   systemctl --user status litellm-v2.service  # Legion
   systemctl status ollama.service             # evo1 / evo2
   ```
3. Сверить результаты с разделами 4–5 этого документа.
4. При расхождениях — оформить новую `IL-OBSERVE` запись, **не трогая канон**.
5. Только после этого запустить Шаг 1 (evo1 BIOS) по runbook'у.

---

## 11. Anchors

- **main HEAD at handoff:** `aa1c3bc8b648291b81ed868013c2c2679f4de4e1`
- **Canon-файлы:**
  - `docs/canon/factory-project-stack-2026-05.md`
  - `GAP-REGISTER.md`
  - `INSTRUCTION-LEDGER.md`
  - `.claude/rules/parallel-session-isolation.md`
  - `.claude/rules/safety-rules.md`
- **Runbooks:**
  - `docs/runbooks/fa-wsl2-ram-cap-and-ollama-cache.md`
  - `docs/runbooks/fa-evo1-bios-uma-audit.md`
  - `docs/runbooks/fa-evo2-gpu-stack.md`
- **Ключевые IL:**
  - `IL-CANON-STACK-2026-05-06`
  - `IL-CANON-RUFLO-2026-05-06`
  - `IL-CANON-HW-BASELINE-2026-05-06`
  - `IL-CANON-PROCESS-HYGIENE-2026-05-06`
  - `IL-CANON-PROCESS-INCIDENT-2026-05-06`
  - `IL-OPS-G-INFRA-EVO1-PHASE-A-2026-05-06`
  - `IL-OPS-G-FACTORY-LEGION-PHASE-A-2026-05-06`
  - `IL-OPS-G-INFRA-EVO2-PHASE-A-2026-05-06`
  - `IL-OPS-G-FACTORY-LITELLM-DUPLICATE-2026-05-06`
