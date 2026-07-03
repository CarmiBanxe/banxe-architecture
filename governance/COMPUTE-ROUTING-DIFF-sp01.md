# COMPUTE-ROUTING-DIFF-sp01 — целевой diff для LiteLLM `:4000` (docs-only, sp01)

> **apply = ОПЕРАТОР на Legion (репо `MetaClaw`) + рестарт LiteLLM `:4000` — НЕ в этом PR.**
>
> **apply = ОПЕРАТОР на Legion (репо `MetaClaw`) + рестарт LiteLLM `:4000` — НЕ в этом PR.**
>
> **apply = ОПЕРАТОР на Legion (репо `MetaClaw`) + рестарт LiteLLM `:4000` — НЕ в этом PR.**

Namespace: `agent/specproj/sp01/compute-optimize-flyfast`. Terminal-B / Orchestrating
Terminal. `banxe-architecture` (docs-only per ADR-103 server-only). Никакого runtime
здесь не мутируется; никакие ключи не пишутся. Все `<PLACEHOLDER>` — имена переменных
из operator-vault / `.env`; реальные значения — вне репозитория (per
`.claude/rules/security-policy.md` — no hardcoded secrets in code or docs).

Cross-ref (без дублирования — эти документы существуют и НЕ переписываются здесь):

- `docs/agent-engine-dossier/COMPUTE-ROUTING-TAXONOMY.md` §5.8 — источник таблицы
  скоростей и routing-принципа (этот же PR).
- `docs/runbooks/fa-02-litellm-canonical-aliases.md` — существующий шаблон/апплайер
  LiteLLM YAML. Формы `model_name` / `litellm_params` / `api_base` / `api_key` берутся
  оттуда. Этот doc — целевой diff поверх него; апплайер и содержимое runbook НЕ
  правятся в этом PR (server-only per ADR-103).
- `docs/adr/ADR-041-glm45-air-distributed.md` — контекст GLM-4.5-Air распределённого
  llama-server + Vulkan RPC.

---

## §1 — Целевые изменения в LiteLLM YAML (`model_list`)

Формат ссылок: строки referenced относительно текущего
`docs/runbooks/fa-02-litellm-canonical-aliases.md` §"model_list" (см. cross-ref выше);
номера строк указаны как «в шаблоне apply-блока», не в живой конфигурации Legion.

### §1.1 — `project-reason`: изменить target на `glm-air` (RPC-distributed)

**Текущая логика (шаблон, fa-02 §model_list):**

```yaml
- model_name: project-reason
  litellm_params:
    model: openai/qwen3
    api_base: http://192.168.0.15:8082/v1     # evo2 llama-server, 235b Q3_K_S
    # api_key: <RPC_Q235_API_KEY>             # bearer в operator vault
    timeout: 600
```

**Целевая логика (после apply оператором):**

```yaml
- model_name: project-reason
  litellm_params:
    model: openai/glm-4.5-air                 # llama-server chat-completions API
    api_base: http://192.168.0.72:8081/v1     # evo1 :8081 — master llama-server
    # api_key: <GLM_AIR_API_KEY>              # bearer в operator vault (если введён)
    timeout: 240                              # 21 tok/s → 240s достаточно
```

**Обоснование** (см. §5.8-B п.1): 21.2 tok/s vs 2.13 tok/s = ~10× ускорение
`project-reason` для non-MLRO reasoning. Distributed pair: master evo1 `:8081` +
Vulkan worker evo2 `:50052` (RPC). Master сам маршрутизирует layers на worker —
LiteLLM видит только `:8081`.

### §1.2 — Добавить отдельный async-heavy алиас для 235b (не `project-reason`)

**Новая запись (после apply оператором):**

```yaml
- model_name: async-heavy                     # НОВЫЙ алиас; не переиспользует project-reason
  litellm_params:
    model: openai/qwen3-235b
    api_base: http://192.168.0.15:8082/v1     # evo2 llama-server :8082
    # api_key: <RPC_Q235_API_KEY>             # bearer из operator vault
    timeout: 1800                             # single-slot 2.13 tok/s → батч/очередь
```

**Обоснование** (см. §5.8-B п.2): 235b перестаёт быть sync `project-reason` target;
остаётся только для async-heavy egress-0 (MLRO/FCA reasoning с 235B-precision
требованием — §2 taxonomy). `timeout: 1800` — эмпирический потолок для длинного
reasoning на 2.13 tok/s. Consumers обязаны использовать batch/queue паттерн, не
sync request-response.

### §1.3 — `factory-coder`: без изменений (уже на coder-next)

Существующая запись `factory-coder → qwen3-coder-next:q4_K_M` на evo1 `:11434`
(`api_base: http://192.168.0.72:11434`) — соответствует §5.8-B п.3. Изменений НЕ
требуется.

### §1.4 — `factory-mid`: без изменений (уже на 30b-a3b)

Существующая запись `factory-mid → ollama/qwen3:30b-a3b` на evo1 `:11434` (и evo2
`:11434` как второй backend) — соответствует §5.8-B п.4. Изменений НЕ требуется.

### §1.5 — `factory-fast`: добавить Legion-endpoint (если ещё не в списке)

**Целевая запись (после apply оператором; проверить наличие перед добавлением):**

```yaml
- model_name: factory-fast
  litellm_params:
    model: ollama/qwen2.5-coder:7b
    api_base: http://192.168.0.72:11434       # если Legion ollama в LAN на :11434
    # или Legion-IP если отдельный host — оператор сверяет с своей SERVICE-MAP
    # api_key: <LEGION_LOCAL_KEY>             # LAN-local, не cloud secret
    timeout: 60                               # 52 tok/s → 60s достаточно для fast-tasks
```

**Обоснование** (см. §5.8-B п.5): 52 tok/s, помещается в 8 GB VRAM. Если запись
уже присутствует в `model_list` — оператор оставляет как есть; иначе добавляет
согласно приведённой форме.

### §1.6 — Удалить/пометить все алиасы на Legion `qwen2.5-coder:14b-banxe-factory`

**Действие оператора (grep-check перед apply):**

```
grep -n "qwen2.5-coder:14b-banxe-factory\|14b-banxe-factory" <litellm-config.yaml>
```

**Правило:** любая найденная запись `model_name: <любой> → model:
ollama/qwen2.5-coder:14b-banxe-factory` **удаляется** из `model_list`. Если такой
записи нет — no-op.

**Обоснование** (см. §5.8-B п.6 и §5.7-D): 9 GB > 8 GB VRAM → CPU-fallback 7.6
tok/s → GPU idle. Серверный `factory-coder → qwen3-coder-next` (Strix Halo, 51B,
38.9 tok/s) полностью замещает эту модель на более высоком уровне возможностей.

---

## §2 — Оператор-команды как ТЕКСТ (НЕ выполнять из этого PR)

Все команды ниже — **справочный текст для оператора**. Terminal-B не выполняет их;
Terminal-A (оператор на Legion) применяет по своему усмотрению в отдельной сессии
с destructive-op verify-step per `safety-rules.md`.

### §2.1 — keep-alive: systemd override для Legion ollama, чтобы 7b держался в VRAM

**Цель:** избежать холодного load `qwen2.5-coder:7b` (52 tok/s upstream) между
factory-fast запросами. По умолчанию `ollama` выгружает модель через 5 мин
неактивности; для роли factory-fast это добавляет ~10–15 сек cold-start
регулярно.

**Команды (оператор на Legion, root/sudo):**

```
# 1) Verify-step (обязательно per safety-rules destructive-op protocol):
systemctl status ollama.service | head -20
sudo systemctl cat ollama.service | head -40

# 2) Создать override (idempotent — если файл уже есть, оператор мержит вручную):
sudo systemctl edit ollama.service
# в открывшемся editor вставить:
#   [Service]
#   Environment="OLLAMA_KEEP_ALIVE=24h"
#   Environment="OLLAMA_MAX_LOADED_MODELS=2"

# 3) Reload + restart:
sudo systemctl daemon-reload
sudo systemctl restart ollama.service

# 4) Verify после restart:
systemctl show ollama.service -p Environment
curl -s http://127.0.0.1:11434/api/tags | head -5
```

**Ожидаемый эффект:** `qwen2.5-coder:7b` держится в VRAM 24h после первого хита;
последующие factory-fast запросы стартуют без cold-load. `OLLAMA_MAX_LOADED_MODELS=2`
оставляет slot для одной дополнительной модели, если оператор захочет также
держать `qwen3:4b` (fallback).

### §2.2 — 14b cleanup: удаление весов на Legion (destructive)

**Цель:** освободить ~9 GB на Legion после того, как `qwen2.5-coder:14b-banxe-factory`
полностью удалён из LiteLLM routing (§1.6). Модель уже НЕ помещается в 8 GB VRAM,
дублирует серверный `factory-coder → qwen3-coder-next` на более слабом уровне,
CPU-fallback 7.6 tok/s не даёт полезного throughput.

**Обоснование удаления:**

1. **Не роутится ни одним алиасом** (§5.8-B п.6 запрещает; §1.6 удаляет).
2. **Дублирует серверный `qwen3-coder-next`** (Strix Halo, 51B, 38.9 tok/s) — на
   более слабом уровне.
3. **9 GB disk footprint** — экономия конкретная.

**Команды (оператор на Legion; destructive — НЕ автоматизировать):**

```
# 1) Verify-step (обязательно per safety-rules destructive-op protocol):
ollama list | grep "qwen2.5-coder:14b-banxe-factory"
ollama show qwen2.5-coder:14b-banxe-factory | head -10
du -sh ~/.ollama/models/blobs/* 2>/dev/null | sort -h | tail -20

# 2) Verify отсутствия в LiteLLM routing (см. §1.6 сначала):
grep -n "qwen2.5-coder:14b-banxe-factory\|14b-banxe-factory" <litellm-config.yaml>
# Ожидание: 0 matches. Если matches есть — сначала §1.6, потом §2.2.

# 3) Destructive op (после явного подтверждения оператора):
ollama rm qwen2.5-coder:14b-banxe-factory

# 4) Verify после rm:
ollama list | grep -c "14b-banxe-factory"    # ожидание: 0
df -h ~/.ollama                              # проверить освобождение ~9 GB
```

**HW-MODEL-UPGRADE-matrix §3.2 gate:** удаление весов Legion-модели — не RED-zone
операция (compliance_config не затрагивается), но по канону
`safety-rules.md` требуется verify-step + destructive-op confirmation. Оператор
самостоятельно принимает решение о времени применения.

---

## §3 — Что этот PR НЕ делает (границы)

1. **НЕ мутирует LiteLLM `:4000`** — весь §1 описан как целевой diff; apply —
   в отдельном PR в `MetaClaw` под ADR-103 server-only.
2. **НЕ создаёт файлы вне `banxe-architecture`** — этот doc и §5.8 taxonomy
   единственные writes.
3. **НЕ содержит реальных api-key значений** — все `<PLACEHOLDER>` — имена
   переменных, значения в operator-vault / `.env`.
4. **НЕ удаляет weights** — все `ollama rm` команды §2.2 — справочный текст для
   оператора; выполнение — вне PR, с verify-step.
5. **НЕ трогает `~/MetaClaw/*`** — Terminal-A perimeter.
6. **НЕ логирует секретов** — `sk-rpc-*`, `<RPC_Q235_API_KEY>`, `<GLM_AIR_API_KEY>`
   упомянуты только как placeholder-имена.
7. **НЕ включает `AGENT_ROUTING_ENABLED=true`** — routing gate остаётся закрытым
   до Ruflo mandatory middleware (см. `.claude/rules/agents.md` §ARL).

---

## §4 — Anchors

- `docs/agent-engine-dossier/COMPUTE-ROUTING-TAXONOMY.md` §5.8 (routing-принцип,
  этот же PR)
- `docs/runbooks/fa-02-litellm-canonical-aliases.md` (существующий шаблон
  `model_list`, source-of-truth формы записи)
- `docs/adr/ADR-041-glm45-air-distributed.md` (GLM-4.5-Air distributed
  llama-server + Vulkan RPC)
- `docs/adr/ADR-103-server-only-refactoring-policy.md` (apply-контур: Terminal-A
  на MetaClaw)
- `docs/canon/HW-MODEL-UPGRADE-matrix.md` §3.2 (destructive model-removal gate)
- `.claude/rules/safety-rules.md` §"Destructive operation verify-step" (protocol
  для §2.1/§2.2)
- `.claude/rules/security-policy.md` (no hardcoded secrets)
- `.claude/rules/agents.md` §ARL (AGENT_ROUTING_ENABLED gate)
