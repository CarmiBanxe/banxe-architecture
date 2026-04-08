# BANXE-UI-UX-RESEARCH.md — Tool Landscape & Classification
**Plane:** Architecture | **Updated:** 2026-04-08 | **IL:** IL-046-prep

---

## Purpose

Classify every relevant tool category for BANXE AI BANK UI/app work.
Determine: what is inspiration-only, what is prototype-capable, what is implementation-safe.
All classifications respect BANXE plane separation (Developer / Product / Standby).

---

## 1. Reference / Screenshot-to-UI Tools

| Tool | What it does | Local/Cloud | Use level | Dev Plane | Product Plane | Notes |
|------|-------------|-------------|-----------|-----------|---------------|-------|
| screenshot.rocks | Mock device framing for screenshots | Cloud (free tier) | Inspiration only | ✅ safe | ❌ not applicable | No code generation |
| Mobbin | Curated UI pattern library (fintech, banking) | Cloud | Inspiration only | ✅ safe | ❌ not applicable | **Highest value for BANXE** — real fintech flows |
| Screenlane | Mobile UI screenshot archive | Cloud | Inspiration only | ✅ safe | ❌ not applicable | Good for mobile pattern research |
| Dribbble / Behance | Visual reference | Cloud | Inspiration only | ✅ safe (reference) | ❌ | Often non-functional — aesthetic only, avoid copy |
| UI Prep / UI8 | UI kits / Figma kits | Cloud | Inspiration + token extraction | ✅ safe | ❌ without review | Can extract token values, not code |
| Figma Community | Open design files | Cloud | Inspiration + reference | ✅ safe | ❌ without review | Useful for layout rhythm patterns |

**BANXE Recommendation:**
Use **Mobbin** as primary UI reference for real fintech interaction patterns.
Use Figma Community files only for structural reference (spacing, layout rhythm), never lift components directly.

---

## 2. AI Web App Builders / Prototype Generators

| Tool | What it does | Local/Cloud | Code quality | Dev Plane | Product Plane | Risks |
|------|-------------|-------------|--------------|-----------|---------------|-------|
| **v0.dev** (Vercel) | React + Tailwind + shadcn/ui component generation from prompts | Cloud | Medium | ✅ prototype exploration | ❌ not without gate | Code sent to Vercel servers. No PII. Prototype only. |
| **bolt.new** (StackBlitz) | Full-stack app from prompt, browser-based | Cloud | Medium | ✅ prototype | ❌ | Fast, unreliable architecture discipline |
| **lovable.dev** | React app from prompt + design-to-code | Cloud | Medium-Low | ✅ prototype | ❌ | Fast scaffolding, weak quality controls |
| **Replit Agent** | Full app build in Replit env | Cloud | Low-Medium | ✅ experimental | ❌ | Runtime data stored in Replit — unacceptable for Product |
| **create.xyz** | Component generation from images/prompts | Cloud | Low | ✅ inspiration | ❌ | Uncertain: unknown data handling policy |
| **Claude Code itself** | Iterative file-based code generation | Local (Claude API) | High | ✅ full | ✅ with gate | **Primary tool for BANXE** |
| **GitHub Copilot Workspace** | PR-scoped AI coding | Cloud (GitHub) | Medium-High | ✅ | ⚠️ uncertain | Sends code context to GitHub/Microsoft |

**BANXE Recommendation:**
- **v0.dev** acceptable for Developer Plane prototype exploration only. Never for Product Plane.
- **Claude Code** is the only tool approved for Product Plane code authoring.
- bolt.new / lovable.dev: useful for rapid visual mock generation, never promoted to product.

---

## 3. Mobile Mock / Mobile App Shell Builders

| Tool | What it does | Local/Cloud | Dev Plane | Product Plane | Notes |
|------|-------------|-------------|-----------|---------------|-------|
| **Expo (React Native)** | Cross-platform mobile via React Native | Local + cloud build | ✅ full | ✅ with gate | **Recommended for BANXE mobile** — local dev, clean |
| **React Native CLI** | Pure RN without Expo overhead | Local | ✅ full | ✅ with gate | More control, more setup |
| **FlutterFlow** | Visual Flutter builder | Cloud | ✅ prototype | ❌ | Sends flow data to cloud. Prototype mock only. |
| **Draftbit** | React Native cloud builder | Cloud | ✅ prototype | ❌ | Good for quick screen mocks |
| **Figma + Figma Prototype** | Clickable screen mock | Cloud | ✅ full | ✅ (no code) | Recommended for non-developer stakeholder demos |
| **Framer** | Interactive web prototype | Cloud | ✅ prototype | ❌ | Very good for interactive web demo, no mobile native |

**BANXE Recommendation:**
- **Expo** for actual mobile implementation shell.
- **Figma prototype** for clickable stakeholder demo (fastest, no code).
- FlutterFlow / Draftbit: quick visual mock generation only, never source of truth.

---

## 4. Component-Aware Development Tools

| Tool | What it does | Local | Dev Plane | Product Plane | Notes |
|------|-------------|-------|-----------|---------------|-------|
| **Storybook** | Component documentation + isolation dev | Local | ✅ full | ✅ full | **Required for BANXE** — quality gate integration |
| **Chromatic** | Visual regression testing via Storybook | Cloud (GitHub CI) | ✅ | ⚠️ | Sends screenshots to Chromatic cloud. Acceptable for non-sensitive UI. |
| **shadcn/ui** | Unstyled accessible component primitives (copy-paste) | Local | ✅ full | ✅ full | **Recommended base** — you own the code |
| **Radix UI** | Headless accessible primitives | Local | ✅ full | ✅ full | Solid accessibility foundation |
| **MUI / Ant Design** | Full opinionated component libraries | Local | ✅ | ⚠️ | Heavy, requires customization. Risk of non-BANXE aesthetic. |
| **Tailwind CSS** | Utility-first CSS | Local | ✅ full | ✅ full | Recommended for token-aligned styling |

**BANXE Recommendation:**
**shadcn/ui + Radix UI + Tailwind** as component foundation.
**Storybook** as mandatory component documentation and development tool.
Own all component code — no dependency on cloud-rendered component platforms.

---

## 5. Context / Memory / MCP / Hooks Tools

| Tool | What it does | Local/Cloud | Dev Plane | Notes |
|------|-------------|-------------|-----------|-------|
| **Claude Code hooks** | Pre/post tool call automation | Local | ✅ full | Already active in BANXE (G-21 + IL-gate) |
| **Claude Code MCP filesystem** | Local file context access | Local | ✅ full | Enables reading design tokens, screen inventory into Claude context |
| **Claude Code slash commands** | Custom workflow triggers | Local | ✅ full | GSD commands already defined in developer-core |
| **Claude Code memory** | Cross-session memory via MEMORY.md | Local files | ✅ full | Used across all BANXE planes |
| **Context7 MCP** | Library docs injection | Cloud | ✅ | Sends library name queries — acceptable for dev tools |
| **Figma MCP** | Figma file reading in Claude | Cloud (Figma API) | ✅ prototype | Useful for token extraction from design files |
| **Playwright MCP** | Browser automation | Local | ✅ full | Useful for visual regression and E2E |

---

## 6. Automation / Headless Build Tools

| Tool | What it does | Local | Notes |
|------|-------------|-------|-------|
| **Claude Code headless** | Non-interactive Claude Code | Local | `--print` flag. File-based stage pipeline. |
| **Playwright** | Browser testing + screenshot capture | Local | Good for visual QA and E2E |
| **Storybook test-runner** | Automated Storybook story tests | Local | Integrates with Jest |
| **axe-core / axe-playwright** | Accessibility testing | Local | Required for BANXE accessibility compliance |
| **Style Dictionary** | Design token transformation | Local | Converts tokens to CSS, JS, RN — **recommended** |
| **Turborepo** | Monorepo build orchestration | Local | Useful if monorepo structure adopted |

---

## 7. Privacy / Governance Suitability Summary

```
CLOUD TOOLS — APPROVED FOR DEVELOPER PLANE (prototype/exploration only):
  v0.dev, bolt.new, lovable.dev, FlutterFlow, Draftbit, Mobbin, Screenlane, Figma

CLOUD TOOLS — NOT APPROVED FOR PRODUCT PLANE:
  All of the above (code/data must not originate from cloud AI builders)

LOCAL TOOLS — APPROVED FOR ALL PLANES:
  Claude Code, Expo, shadcn/ui, Radix UI, Tailwind, Storybook, Playwright,
  Style Dictionary, Turborepo, axe-core

UNCERTAIN (mark and monitor):
  create.xyz (unknown data policy), Chromatic (screenshot cloud), Context7 MCP
```

---

## 8. BANXE Recommendation Matrix

| Goal | Recommended Tool | Plane | Certainty |
|------|-----------------|-------|-----------|
| UI pattern inspiration | Mobbin, Screenlane | Dev ✅ | High |
| Visual reference for fintech | Mobbin | Dev ✅ | High |
| Quick web prototype mock | v0.dev | Dev ✅ (prototype only) | High |
| Clickable stakeholder demo | Figma Prototype | Dev ✅ | High |
| Mobile mock for demo | Figma Prototype / Expo | Dev ✅ | High |
| Component foundation | shadcn/ui + Radix UI + Tailwind | Dev + Product ✅ | High |
| Component dev/doc | Storybook | Dev + Product ✅ | High |
| Design tokens | Style Dictionary | Dev + Product ✅ | High |
| Web implementation | Claude Code + React + TypeScript | Product ✅ | High |
| Mobile implementation | Claude Code + Expo + TypeScript | Product ✅ | High |
| Visual regression | Playwright screenshots / Chromatic | Dev ✅ | Medium |
| Accessibility | axe-core + axe-playwright | Dev + Product ✅ | High |
| Build orchestration | bash pipeline + Turborepo | Dev + Product ✅ | High |
| Context injection | Claude Code MCP filesystem | Dev + Product ✅ | High |

---

## Key Decisions

1. **No cloud AI builder code enters Product Plane.** Period.
2. **Claude Code is the sole code-authoring agent for Product Plane.**
3. **Prototype code (v0.dev, bolt) is inspiration + structural reference only** — must be rewritten under quality gate before promotion.
4. **shadcn/ui is preferred** because you own the code (copy-paste model, not npm black-box).
5. **Storybook is mandatory** — serves as component contract and visual regression baseline.
6. **Figma is approved for non-code artifacts** — designs, clickable demo, token definitions.
