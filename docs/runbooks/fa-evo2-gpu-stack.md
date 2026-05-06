# FA-EVO2: restore AMD GPU stack (ROCm + Vulkan) and re-enable GPU-offload for heavy model
<!-- Gap: G-INFRA-EVO2-GPU-STACK | IL: IL-CANON-HW-BASELINE-2026-05-06 -->
<!-- Created: 2026-05-06 | Status: READY — execute when operator has physical/IPMI access -->

## Summary

evo2 (NucBox EVO-X2 vN) has 128 GB RAM, 1.9 TB SSD, and an AMD GPU. Currently
`vulkaninfo` shows only `llvmpipe` (software renderer) and `rocminfo` is either missing
or non-functional. As a result, qwen3:235b runs CPU-only at ~5 tok/s. This runbook
restores the hardware GPU stack (ROCm + Vulkan drivers) and re-enables Ollama GPU offload,
unblocking re-evaluation of maximum feasible model under 128 GB + GPU.

---

## Pre-conditions

- HW baseline canon in main (PR #111, `docs/canon/factory-project-stack-2026-05.md § HW Baseline`).
- `G-INFRA-EVO2-GPU-STACK` is OPEN (P1).
- Operator has physical or IPMI access to evo2 for possible reboots.
- Ollama service is currently running (`systemctl status ollama.service`).
- Artifact directory created: `mkdir -p ~/banxe-audit/evo2-gpu-2026-05-XX/`

---

## Phase A — Diagnostic snapshot (on evo2, no changes)

```bash
mkdir -p ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/

# Identify GPU SKU
lspci -nn | grep -iE 'vga|3d|display' \
  | tee ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/lspci-gpu.txt

# Check kernel GPU driver messages
dmesg | grep -iE 'amdgpu|drm|rocm' | tail -50 \
  | tee ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/dmesg-amdgpu.txt

# Current Vulkan state (expect llvmpipe only)
vulkaninfo --summary 2>/dev/null | head -50 \
  | tee ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/vulkaninfo-pre.txt

# ROCm state
which rocminfo && rocminfo 2>/dev/null | head -40 || echo 'rocminfo missing' \
  | tee ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/rocminfo-pre.txt

# Installed GPU/compute packages
apt list --installed 2>/dev/null \
  | grep -E 'rocm|mesa|vulkan|amdgpu|linux-firmware' | sort \
  | tee ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/apt-gpu-packages-pre.txt

# Kernel version and module state
uname -r
lsmod | grep amdgpu
```

From `lspci` output, identify the AMD GPU PCI ID (e.g. `[1002:7901]`) and cross-reference
with AMD GPU family to determine the correct gfx target (e.g. `gfx1151`, `gfx1100`, `gfx90c`).

---

## Phase B — Driver and firmware install

### Step B1 — Ensure kernel module is loaded

```bash
# Check if amdgpu module is present
lsmod | grep amdgpu
modinfo amdgpu | grep ^filename

# If not loaded, try loading manually
sudo modprobe amdgpu

# Check for firmware errors
dmesg | grep -iE 'amdgpu|firmware' | grep -i 'fail\|error\|missing' | tail -20
```

### Step B2 — Install Mesa Vulkan and firmware packages (Debian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install -y \
  mesa-vulkan-drivers \
  libvulkan1 \
  vulkan-tools \
  linux-firmware \
  libdrm-amdgpu1
```

### Step B3 — Install ROCm (for compute/Ollama GPU backend)

Add the official ROCm APT repository (adjust for distro and ROCm version):

```bash
# Download and add ROCm signing key
wget -q https://repo.radeon.com/rocm/rocm.gpg.key -O - \
  | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/rocm.gpg

# Add ROCm 6.x repository (verify current LTS release at https://rocm.docs.amd.com)
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/rocm.gpg] \
  https://repo.radeon.com/rocm/apt/6.2 jammy main" \
  | sudo tee /etc/apt/sources.list.d/rocm.list

sudo apt-get update
sudo apt-get install -y rocminfo rocm-smi-lib rocm-libs
```

### Step B4 — Add evo2 user to render and video groups

```bash
sudo usermod -aG render,video $USER
# Effective after next login or: newgrp render
```

### Step B5 — Reboot to apply kernel module changes

```bash
sudo reboot
```

After reboot, return to Phase C.

---

## Phase C — Environment and Ollama wiring

### Step C1 — Determine gfx target

```bash
rocminfo | grep 'gfx\|Name'
# or:
/opt/rocm/bin/rocminfo | grep 'gfx'
```

If `rocminfo` still doesn't list the GPU agent, set `HSA_OVERRIDE_GFX_VERSION` based on
the RDNA generation identified in Phase A (e.g. `gfx1151` for RDNA 4 Phoenix/Strix Halo,
`gfx1100` for RDNA 3):

```bash
export HSA_OVERRIDE_GFX_VERSION=gfx1151   # adjust to actual target
rocminfo
```

### Step C2 — Configure Ollama systemd unit

Create a drop-in override for the Ollama service:

```bash
sudo mkdir -p /etc/systemd/system/ollama.service.d/
sudo tee /etc/systemd/system/ollama.service.d/gpu.conf <<'EOF'
[Service]
Environment="HSA_OVERRIDE_GFX_VERSION=gfx1151"
Environment="AMD_VISIBLE_DEVICES=all"
Environment="OLLAMA_GPU_LAYERS=auto"
EOF

sudo systemctl daemon-reload
sudo systemctl restart ollama.service
```

Adjust `HSA_OVERRIDE_GFX_VERSION` value to the confirmed gfx target from Step C1.

---

## Phase D — Verify GPU stack and Ollama GPU offload

### Step D1 — Vulkan hardware adapter

```bash
vulkaninfo --summary 2>/dev/null \
  | tee ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/vulkaninfo-post.txt
# Expected: AMD RADV or AMDVLK device, NOT llvmpipe
```

### Step D2 — ROCm GPU agent

```bash
rocminfo | grep -A5 'Agent' \
  | tee ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/rocminfo-post.txt
# Expected: one or more GPU agents listed (not only CPU agents)
```

### Step D3 — Ollama smoke test with GPU monitoring

In one terminal, start GPU monitor:

```bash
watch -n1 radeontop -d -   # or: rocm-smi --showuse
```

In another terminal, send a test request:

```bash
curl -sS http://127.0.0.1:11434/api/generate \
  -d '{"model":"qwen3:235b","prompt":"Reply with one word: hello","stream":false}' \
  | python3 -c "import sys,json; r=json.load(sys.stdin); print('tok/s:', r.get('eval_rate','?'))"
```

**Pass criteria:** GPU utilisation visible in radeontop / rocm-smi during inference (> 0%).

### Step D4 — Save post-verify artifacts

```bash
apt list --installed 2>/dev/null \
  | grep -E 'rocm|mesa|vulkan|amdgpu' | sort \
  | tee ~/banxe-audit/evo2-gpu-$(date +%Y-%m-%d)/apt-gpu-packages-post.txt
```

---

## Phase E — Model re-selection (after Phase D passes)

Only after GPU offload is confirmed:

- Assess maximum feasible model under 128 GB RAM + GPU VRAM.
- Consider heavier quant of qwen3:235b (Q4_K_M) or a different architecture if GPU
  throughput proves sufficient.
- Any model change MUST be recorded as a new IL entry and update
  `docs/canon/HW-MODEL-UPGRADE-matrix.md`.
- Add IL `IL-OPS-G-INFRA-EVO2-GPU-STACK-EXECUTED-YYYY-MM-DD` to `INSTRUCTION-LEDGER.md`
  once operator confirms hardware GPU offload.
- Mark `G-INFRA-EVO2-GPU-STACK` as `[x] CLOSED` **only** after that IL entry.

---

## Rollback

```bash
# 1. Remove drop-in GPU config for Ollama:
sudo rm -f /etc/systemd/system/ollama.service.d/gpu.conf
sudo systemctl daemon-reload
sudo systemctl restart ollama.service

# 2. Unset override GFX version if set in shell:
unset HSA_OVERRIDE_GFX_VERSION

# 3. If ROCm packages caused instability:
sudo apt-get remove rocminfo rocm-smi-lib rocm-libs
sudo apt-get autoremove

# 4. Reboot if kernel module behaviour changed.
# 5. Record reason for rollback in changelog below.
```

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Incompatible ROCm version with kernel | High | Check ROCm compatibility matrix before install; match kernel version |
| Wrong `HSA_OVERRIDE_GFX_VERSION` → silent CPU fallback | Medium | Verify radeontop shows non-zero during inference |
| amdgpu module fails to load → no display | High | Have IPMI/serial access; fallback to `radeon` or `nomodeset` kernel param |
| ROCm packages conflict with existing mesa | Low | Install in test env first; use `apt-get install --no-install-recommends` |

---

## Changelog

| Date | Operator | Action | Notes |
|------|----------|--------|-------|
| _YYYY-MM-DD_ | _name_ | Phase A snapshot | GPU SKU: _X_; Vulkan: llvmpipe; rocminfo: missing |
| _YYYY-MM-DD_ | _name_ | Phase B install | ROCm _version_ installed; reboot done |
| _YYYY-MM-DD_ | _name_ | Phase C Ollama config | HSA_OVERRIDE=_gfxXXXX_; service restarted |
| _YYYY-MM-DD_ | _name_ | Phase D verify | vulkaninfo: _AMD device_; rocminfo: GPU agent; tok/s: _N_ |

---

## References

- GAP: `GAP-REGISTER.md` → `G-INFRA-EVO2-GPU-STACK`
- HW baseline: `docs/canon/factory-project-stack-2026-05.md` § HW Baseline
- IL: `INSTRUCTION-LEDGER.md` → `IL-CANON-HW-BASELINE-2026-05-06`
- Model upgrade matrix: `docs/canon/HW-MODEL-UPGRADE-matrix.md`
- Related gap: `G-CLUSTER-01` (fp16 model deleted when GPU stack was broken)
- ROCm compatibility: https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html
