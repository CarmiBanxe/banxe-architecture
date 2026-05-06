# FA-EVO1: BIOS/UMA audit and RAM visibility reconciliation (target 128 GB)
<!-- Gap: G-INFRA-EVO1-RAM-VISIBILITY | IL: IL-CANON-HW-BASELINE-2026-05-06 -->
<!-- Created: 2026-05-06 | Status: READY — execute when operator has physical/IPMI access -->

## Summary

evo1 (NucBox EVO-X2) has 128 GB physical RAM; Linux currently reports ~30 GiB via `free -h`.
The mismatch is a BIOS/UMA Frame Buffer / Memory Remap issue, not a real capacity limit.
This runbook reconciles OS-visible RAM with physical 128 GB and unblocks honest capacity
planning for evo1 services, small models, Keycloak, and Postgres.

---

## Pre-conditions

- HW baseline canon in main (PR #111, `docs/canon/factory-project-stack-2026-05.md § HW Baseline`).
- Operator has physical or IPMI access to evo1 for BIOS reboots.
- A maintenance window is open (evo1 restart will interrupt services).
- Artifact directory created: `mkdir -p ~/banxe-audit/evo1-bios-2026-05-XX/`

---

## Phase A — Non-disruptive software audit (run on evo1, no reboot)

```bash
mkdir -p ~/banxe-audit/evo1-bios-$(date +%Y-%m-%d)/

sudo dmidecode -t memory \
  | tee ~/banxe-audit/evo1-bios-$(date +%Y-%m-%d)/dmidecode-memory.txt

sudo dmidecode -t 17 \
  | grep -E 'Size|Locator|Speed|Manufacturer' \
  | tee ~/banxe-audit/evo1-bios-$(date +%Y-%m-%d)/dmidecode-t17-summary.txt

cat /proc/meminfo | head -20 \
  | tee ~/banxe-audit/evo1-bios-$(date +%Y-%m-%d)/proc-meminfo.txt

lsmem --summary \
  | tee ~/banxe-audit/evo1-bios-$(date +%Y-%m-%d)/lsmem.txt

sudo lshw -short -C memory \
  | tee ~/banxe-audit/evo1-bios-$(date +%Y-%m-%d)/lshw-memory.txt
```

Record results in the runbook changelog section below.

---

## Phase B — Interpretation of dmidecode output

### Case 1 — dmidecode sees N modules × M GB ≈ 128 GB, but `free -h` shows ~30 GiB

This is a **BIOS UMA Frame Buffer / Memory Remap mismatch**. The BIOS has reserved a large
UMA frame buffer (common on AMD APUs: default 64 GB or "Auto" which resolves to a large value)
that is subtracted from OS-visible RAM. Proceed to Phase C.

### Case 2 — dmidecode sees < 128 GB total

Platform or DIMM issue; physical slot inspection may be required before proceeding.
Do NOT change BIOS settings until slots and DIMM seating are verified.

### Case 3 — dmidecode matches physical but `free -h` is still low

Kernel ACPI or BIOS memory-map reservation. Check `dmesg | grep -i memory` and
`cat /proc/iomem | grep -i ram` for large BIOS-reserved regions. May require a
firmware update rather than a settings change.

---

## Phase C — BIOS audit (operator-executed; requires evo1 reboot)

### Entering BIOS on NucBox EVO-X2

- Reboot evo1; press `DEL` or `F2` (varies by BIOS revision) at POST.

### Settings to inspect and record

| Setting | Location | Recommended value | Prior value |
|---------|----------|-------------------|-------------|
| Memory Configuration (total) | Advanced → Memory | Should show 128 GB | _record_ |
| UMA Frame Buffer Size | Advanced → AMD CBS → NBIO → UMA | 512 MB or 1 GB | _record_ |
| Memory Remap / Above 4G Decoding | Advanced → PCI | Enabled | _record_ |
| Memory Frequency | Advanced → Memory | Auto (or DIMM spec) | _record_ |

**Key action:** change **UMA Frame Buffer Size** from `Auto` / large value → `512 MB` (or the
minimum available). This returns the reserved VRAM allocation to OS-visible RAM.

Do not change Memory Frequency unless you have confirmed the DIMM spec supports a higher rate.

Record all prior and new values in the changelog at the bottom of this file before saving BIOS.

### Save and reboot

- Save changes (F10 or Save & Exit).
- Allow evo1 to boot fully before Phase D checks.

---

## Phase D — Verify after BIOS reboot

```bash
# Expected: MemTotal close to 128 GiB (~131 GB = 128 GB in base-10)
free -h

# Should show no large BIOS reservation warnings
dmesg | grep -i memory | grep -iv 'BIOS-provided\|firmware provided' | head -20

# Re-capture artifacts
sudo dmidecode -t memory \
  | tee ~/banxe-audit/evo1-bios-$(date +%Y-%m-%d)/post-bios-dmidecode-memory.txt

cat /proc/meminfo | head -5 \
  | tee ~/banxe-audit/evo1-bios-$(date +%Y-%m-%d)/post-bios-meminfo.txt
```

**Pass criteria:**

- `free -h` total ≥ 110 GiB (accounting for kernel + firmware reservations).
- `dmidecode -t 17` still lists all physical DIMMs with correct sizes.
- No unexpected kernel panics or boot failures.

---

## Phase E — Capacity replan (after successful Phase D)

Only after Phase D passes:

- Review gap `G-INFRA-04` (evo1 swap pressure) — may be fully explained by the RAM
  mismatch now resolved; close if swap pressure disappears.
- Re-evaluate whether "evo1 is under pressure → migrate to evo2" decisions made
  before this audit are still valid.
- Add an IL entry `IL-OPS-G-INFRA-EVO1-RAM-VISIBILITY-EXECUTED-YYYY-MM-DD` to
  `INSTRUCTION-LEDGER.md` once operator confirms ≥ 110 GiB visible.
- Mark `G-INFRA-EVO1-RAM-VISIBILITY` as `[x] CLOSED` **only** after that IL entry.

If `free -h` remains ~30 GiB after BIOS change:

- Leave `G-INFRA-EVO1-RAM-VISIBILITY` OPEN.
- Escalate: may be a platform firmware bug; check NucBox EVO-X2 BIOS release notes
  for memory remap fixes; consider BIOS update.

---

## Rollback

```bash
# 1. Reboot evo1 into BIOS.
# 2. Restore all changed settings to prior values (see changelog below).
# 3. Save and reboot.
# 4. Verify: free -h returns to ~30 GiB baseline (as before this runbook).
# 5. Record rollback in changelog below.
```

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| UMA reduction breaks iGPU video output | Medium | Test on a monitor; set UMA to 512 MB, not 0 MB |
| Memory Remap=Enabled causes boot hang on some BIOS | Low | Restore prior value if POST hangs >60 s |
| Wrong BIOS setting causes no-boot | Medium | NucBox typically has CMOS reset jumper or battery pull |

---

## Changelog

| Date | Operator | Action | Notes |
|------|----------|--------|-------|
| _YYYY-MM-DD_ | _name_ | Phase A audit | `free -h` = _X_ GiB; dmidecode shows _Y_ |
| _YYYY-MM-DD_ | _name_ | Phase C BIOS change | UMA: _old_ → _new_; Memory Remap: _old_ → _new_ |
| _YYYY-MM-DD_ | _name_ | Phase D verify | `free -h` = _Z_ GiB; PASS/FAIL |

---

## References

- GAP: `GAP-REGISTER.md` → `G-INFRA-EVO1-RAM-VISIBILITY`
- HW baseline: `docs/canon/factory-project-stack-2026-05.md` § HW Baseline
- IL: `INSTRUCTION-LEDGER.md` → `IL-CANON-HW-BASELINE-2026-05-06`
- Related gap: `G-INFRA-04` (evo1 swap pressure)
