# BANXE-HEADLESS-PIPELINE.md — Modular Headless Generation Pipeline
**Plane:** Architecture | **Updated:** 2026-04-08

---

## Design Principles

1. **File-based state between stages** — no long-lived session as state carrier
2. **Each stage is independently restartable** — failure does not require full restart
3. **Sequential where dependencies exist, parallel where safe**
4. **Human checkpoints at compliance-sensitive stages**
5. **Fallback path if MCP/context tools unavailable**

---

## Pipeline Overview

```
Stage 1: Research / Spec Load           [Sequential first]
Stage 2: UI/UX System Validation        [Sequential]
Stage 3: Design Token Build             [Sequential]
Stage 4: Web Scaffold / Prototype       [After Stage 3]
Stage 5: Mobile Scaffold / Mock         [Parallel with Stage 4]
Stage 6: Storybook / Component Stories  [After Stage 4]
Stage 7: Tests / Accessibility          [After Stage 6]
Stage 8: Quality Gate / Final Review    [Sequential last]
```

---

## Stage Details

### Stage 1: Research / Spec Load
**Inputs:**
- `banxe-architecture/docs/BANXE-UI-UX-RESEARCH.md`
- `banxe-architecture/docs/BANXE-UI-UX-SYSTEM.md`
- `banxe-architecture/docs/BANXE-SCREEN-INVENTORY.md`
- `banxe-ui/mocks/data/*.json` (existing mock data)

**Outputs:**
- `banxe-ui/.pipeline/stage1-context.json` — loaded context summary
  ```json
  {
    "approved_tools": ["shadcn/ui", "Radix UI", "Tailwind", "Storybook"],
    "screens_required": ["W-01","W-02","W-03","W-04","W-05","W-06","M-01".."M-06"],
    "components_required": ["BalanceWidget", "TransactionRow", ...],
    "tokens_required": ["colors", "typography", "spacing", "radii", "shadows"],
    "timestamp": "2026-04-08T12:00:00Z"
  }
  ```

**Parallel:** No — must complete before any other stage.
**Approval required:** No
**Plane:** Developer
**Fallback (no MCP):** Claude Code reads files directly via Read tool. Stage still runs.

**Failure handling:** If any spec file is missing → abort pipeline, report missing files.

---

### Stage 2: UI/UX System Validation
**Inputs:** Stage 1 context + BANXE-UI-UX-SYSTEM.md

**Outputs:**
- `banxe-ui/.pipeline/stage2-validation.json`
  ```json
  {
    "token_coverage": "all_required_tokens_defined",
    "component_coverage": "N_of_M_components_specced",
    "screen_coverage": "all_screens_in_inventory",
    "gaps": []
  }
  ```

**Parallel:** No
**Approval required:** No — but gaps halt Stage 3 until resolved.
**Plane:** Developer

**Failure handling:** Gaps in component spec → generate `stage2-gaps.md` listing missing specs → human resolves → re-run stage.

---

### Stage 3: Design Token Build
**Inputs:** `packages/design-tokens/tokens/*.json`

**Outputs:**
- `packages/design-tokens/build/css/variables.css`
- `packages/design-tokens/build/js/tokens.ts`
- `packages/design-tokens/build/rn/tokens.ts`
- `banxe-ui/.pipeline/stage3-tokens.json` (token manifest with hash)

**Command:**
```bash
cd packages/design-tokens && npm run build
```

**Parallel:** No — all later stages depend on this output.
**Approval required:** No
**Plane:** Developer + Product (tokens are shared)

**Failure handling:** Token build fail → inspect Style Dictionary config → fix JSON syntax → re-run.

---

### Stage 4: Web Scaffold / Prototype Generation
**Inputs:**
- Stage 3 tokens (built)
- Stage 1 context (screen list, component list)
- BANXE-UI-UX-SYSTEM.md (design decisions)
- mocks/data/*.json (API response shapes)

**Outputs (per component/screen):**
- `packages/ui/src/financial/{ComponentName}/index.tsx`
- `packages/ui/src/financial/{ComponentName}/{ComponentName}.test.tsx`
- `apps/web/src/screens/{ScreenName}/{ScreenName}.tsx`

**Parallel with Stage 5:** Yes — web and mobile can scaffold simultaneously once tokens are built.
**Approval required:** No (prototype), Yes (before Product Plane promotion)
**Plane:** Developer

**Claude Code command per component:**
```bash
claude --print "
Read packages/design-tokens/build/js/tokens.ts.
Read mocks/data/transactions.json.
Implement TransactionRow component in packages/ui/src/financial/TransactionRow/index.tsx.
Use tokens, no hardcoded values. Include all states from BANXE-SCREEN-INVENTORY.md.
" > .pipeline/stage4-transactionrow.log
```

**Failure handling:** Component fails TypeScript check → log error → skip component → continue with others → report gaps at Stage 8.

---

### Stage 5: Mobile Scaffold / Mock Generation
**Inputs:** Same as Stage 4 (tokens + context + mocks)

**Outputs:**
- `apps/mobile/app/(tabs)/{screen}.tsx` (per mobile screen)
- `apps/mobile/src/components/` (mobile-specific overrides)

**Parallel with Stage 4:** Yes
**Approval required:** No (prototype)
**Plane:** Developer

**Failure handling:** Same as Stage 4.

---

### Stage 6: Storybook / Component Stories
**Inputs:** Stage 4 outputs (components must exist)

**Outputs:**
- `packages/ui/stories/{ComponentName}.stories.tsx` (per component)
- Storybook build: `storybook/storybook-static/`

**Command:**
```bash
# Generate stories then build to verify
claude --print "Generate Storybook stories for BalanceWidget covering: Loaded, Loading, Error, PrivacyMode" \
  > .pipeline/stage6-stories.log
npm run build-storybook
```

**Parallel with Stage 5 mobile:** No — depends on Stage 4 web components.
**Approval required:** No
**Plane:** Developer

**Failure handling:** Story fails to render in build → component has a bug → fix component first (Stage 4) → re-run Stage 6.

---

### Stage 7: Tests / Accessibility Checks
**Inputs:** Stage 6 outputs (components + stories built)

**Substages (can run in parallel):**

**7a: Unit tests**
```bash
npx vitest run --reporter=json > .pipeline/stage7a-unit.json
```

**7b: Accessibility**
```bash
bash scripts/check-a11y.sh > .pipeline/stage7b-a11y.json
```

**7c: Visual regression** (optional in prototype phase)
```bash
npx playwright test tests/visual/ --reporter=json > .pipeline/stage7c-visual.json
```

**Parallel:** 7a + 7b + 7c can run in parallel.
**Approval required:** If 7c shows visual regression changes → human must approve/reject.
**Plane:** Developer

**Failure handling:**
- Unit test fail → fix component → re-run from Stage 4
- Accessibility critical violation → MUST fix before Stage 8
- Visual regression → human decision: accept new baseline or fix

---

### Stage 8: Quality Gate / Final Review
**Inputs:** All stage outputs + pipeline logs

**Command:**
```bash
bash scripts/banxe-build.sh --stage quality-gate
```

**Outputs:**
- `banxe-ui/.pipeline/stage8-report.json`
  ```json
  {
    "typescript": "PASS",
    "lint": "PASS",
    "unit_tests": "PASS | FAIL (N failures)",
    "storybook_build": "PASS",
    "accessibility": "PASS | FAIL (critical: N, moderate: M)",
    "visual_regression": "PASS | CHANGED (human approved: yes/no)",
    "overall": "PASS | FAIL",
    "promotion_eligible": true | false
  }
  ```

**Parallel:** No — final gate.
**Approval required:** Yes — human reviews report before any promotion decision.
**Plane:** Developer (prototype) → Product (after promotion)

**Failure handling:** Any FAIL → pipeline does not mark as promotion-eligible. Fix → re-run affected stages.

---

## Fallback Paths

| Failure Scenario | Fallback |
|-----------------|---------|
| MCP filesystem unavailable | Claude Code uses Read tool directly |
| Context7 MCP unavailable | Claude Code uses existing docs + WebFetch |
| Figma MCP unavailable | Use BANXE-UI-UX-SYSTEM.md as source of truth |
| Stage 3 token build fails | Use previous built tokens (cached) if hash matches |
| Stage 4 component gen fails | Skip failed component, continue, report at Stage 8 |
| Stage 7 visual regression tool unavailable | Skip 7c, mark as "not checked" in report |

---

## Pipeline State Files

All pipeline state lives in `banxe-ui/.pipeline/` (gitignored).

```
.pipeline/
├── stage1-context.json
├── stage2-validation.json
├── stage3-tokens.json
├── stage4-*.log
├── stage5-*.log
├── stage6-stories.log
├── stage7a-unit.json
├── stage7b-a11y.json
├── stage7c-visual.json   (optional)
└── stage8-report.json    (FINAL)
```

Each stage writes its output before the next stage reads it.
If a stage fails, its output file is marked with `"status": "FAILED"`.

---

## Pipeline Commands

```bash
# Full pipeline:
bash scripts/banxe-build.sh

# Resume from specific stage:
bash scripts/banxe-build.sh --from-stage 4

# Single stage:
bash scripts/banxe-build.sh --stage 3

# Check pipeline state:
cat banxe-ui/.pipeline/stage8-report.json | jq '.overall'
```
