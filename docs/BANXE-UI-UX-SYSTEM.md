# BANXE-UI-UX-SYSTEM.md — UI + UX Design System
**Plane:** Architecture | **Updated:** 2026-04-08

---

## Design Philosophy

BANXE AI BANK must feel:
- **Premium** — not SaaS generic, not crypto-neon
- **Trustworthy** — every state is legible, every number is clear
- **Operationally serious** — stress-tested clarity over novelty
- **Assistive AI** — AI features are transparent, framed, never magical
- **Fintech-grade** — FCA-regulated product, compliance visible at appropriate moments

**Anti-patterns to avoid:**
- Glowing orb / animated gradient hero aesthetics
- Ambiguous balance display (user must always know: available, pending, total)
- "AI magic" without explanation or confidence framing
- Overpacked screens with many equal-weight actions
- Crypto-bro dark mode with neon accents

---

## UI System

### Color System

```
Base Palette (Dark Premium Fintech):

Background layers:
  --color-bg-base:       #080C14   (deepest surface — page background)
  --color-bg-surface:    #0F1520   (card / panel surface)
  --color-bg-elevated:   #16202E   (modal, dropdown, elevated card)
  --color-bg-overlay:    #1E2A3A   (hover / selected states)

Border:
  --color-border-subtle: #1F2D3D   (soft separator)
  --color-border-default:#2A3D52   (standard border)
  --color-border-strong: #3D5570   (emphasized border)

Text:
  --color-text-primary:  #E8EDF5   (headings, primary content)
  --color-text-secondary:#8DA0B5   (labels, captions, hints)
  --color-text-disabled:  #4A5F72  (disabled state)
  --color-text-inverse:   #080C14  (text on light surface)

Brand:
  --color-brand-primary:  #1A7FD4  (BANXE blue — primary CTA, links)
  --color-brand-light:    #3A9FE8  (hover, lighter accent)
  --color-brand-subtle:   #1A3A5C  (tinted surface, pill backgrounds)

Status — Finance specific:
  --color-success:        #22C55E  (confirmed, matched, received)
  --color-success-subtle: #0F2B1A
  --color-warning:        #F59E0B  (pending, review required)
  --color-warning-subtle: #2B1F08
  --color-error:          #EF4444  (failed, blocked, rejected)
  --color-error-subtle:   #2B0F0F
  --color-info:           #60A5FA  (informational, AI insight)
  --color-info-subtle:    #0F1F3A

AI / Trust Indicators:
  --color-ai-accent:      #7C3AED  (AI-generated content markers)
  --color-ai-subtle:      #1A0F2B
  --color-compliance:     #F59E0B  (compliance flag color)
  --color-pending:        #6B7280  (grey — awaiting, processing)
```

**Dark/Light mode:** Ship dark mode first (premium fintech context). Light mode is v2.

### Typography

```
Font Family:
  --font-sans: 'Inter', 'DM Sans', system-ui, sans-serif
  --font-mono: 'JetBrains Mono', 'Fira Code', monospace  (amounts, IBAN, refs)

Scale:
  --text-xs:   11px / 1.4  — captions, compliance labels, timestamps
  --text-sm:   13px / 1.5  — secondary text, table cells, form labels
  --text-base: 15px / 1.6  — body, paragraphs
  --text-md:   16px / 1.5  — card body
  --text-lg:   18px / 1.4  — section headings
  --text-xl:   22px / 1.3  — card titles
  --text-2xl:  28px / 1.2  — balance amounts, hero numbers
  --text-3xl:  36px / 1.1  — large balance display

Weights:
  --weight-regular: 400
  --weight-medium:  500
  --weight-semibold: 600
  --weight-bold:    700

Financial amounts: ALWAYS monospace font at --text-xl+
IBAN / reference numbers: ALWAYS monospace, --text-sm
```

### Spacing

```
Base unit: 4px

--space-1:  4px
--space-2:  8px
--space-3:  12px
--space-4:  16px
--space-5:  20px
--space-6:  24px
--space-8:  32px
--space-10: 40px
--space-12: 48px
--space-16: 64px

Card padding: 24px (--space-6)
Section gap:  32px (--space-8)
List item height: 64px minimum for financial rows
```

### Border Radius

```
--radius-sm:   4px   (badges, chips, tags)
--radius-md:   8px   (inputs, buttons)
--radius-lg:   12px  (cards, panels)
--radius-xl:   16px  (modals, bottom sheets)
--radius-full: 9999px (pills, avatars, toggles)
```

### Elevation / Shadow

```
--shadow-card:   0 1px 3px rgba(0,0,0,0.4), 0 1px 2px rgba(0,0,0,0.24)
--shadow-modal:  0 4px 24px rgba(0,0,0,0.5), 0 1px 8px rgba(0,0,0,0.3)
--shadow-dropdown: 0 8px 32px rgba(0,0,0,0.5)
```

### Iconography

- Use **Lucide React** (MIT, tree-shakeable, consistent stroke weight)
- Icon size: 16px (inline), 20px (action), 24px (nav/hero)
- Stroke width: 1.5px (all sizes)
- Never filled icons for navigation — filled only for active/selected state
- Financial-specific icons: custom SVG set for wallet, FPS, SWIFT, SEPA, shield (compliance)

### Data Visualization

- Chart library: **Recharts** (React-native compatible) or **Tremor** (Tailwind-native)
- Balance chart: area chart, no grid lines, subtle fill gradient
- Transaction volume: bar chart, muted palette
- Never 3D charts
- Always include accessible text alternatives
- Color palette for charts must not rely on hue alone (add patterns/labels)

---

## UI Component Patterns

### Balance Widget (Primary)
```
Structure:
  [Currency label — text-sm secondary]
  [Amount — text-3xl bold monospace]
  [Available / Pending breakdown — text-sm secondary]
  [Quick actions: Send | Add | Exchange — icon + label buttons]

States:
  loaded | loading (skeleton) | error | hidden (privacy mode)
  
Privacy mode: replace amount with "••••" on tap/click toggle
```

### Transaction Row
```
Structure:
  [Icon/Logo 40px] [Counterparty name + reference — text-base bold / text-sm]
  [Amount ±£ — text-md bold monospace, green/red/grey]
  [Status chip] [Date — text-xs secondary]

Status chips:
  COMPLETED — green bg, green text
  PENDING   — warning bg, warning text
  FAILED    — error bg, error text
  BLOCKED   — error bg, strong border
  REVIEW    — warning bg, compliance icon

Row height: minimum 64px
Separator: --color-border-subtle
```

### Financial Card (Wallet Card)
```
Structure:
  [Card header: wallet type + currency flag]
  [Balance — text-2xl monospace]
  [IBAN (masked) — text-sm monospace]
  [Card actions: Deposit | Withdraw | Transfer]
  
Variants: Fiat (blue gradient subtle) | Crypto (violet subtle)
```

### AI Assistant Panel
```
Structure:
  [AI badge: "BANXE AI" with --color-ai-accent indicator]
  [Insight or suggestion text]
  [Confidence indicator: HIGH / MEDIUM / LOW]
  [Explanation toggle: "Why this insight?"]
  [Action button if applicable: "Review" / "Dismiss"]

Rules:
  NEVER show AI content without confidence label
  NEVER auto-act — always user-confirmed action
  Always show "AI-generated" badge
```

### Action Bar (Bottom sheet / Modal top)
```
Primary action: full-width --color-brand-primary button
Secondary action: ghost button
Destructive: --color-error button, requires confirmation dialog
Disabled state: --color-text-disabled, cursor not-allowed
```

### Navigation — Web (Sidebar)
```
Width: 240px collapsed-capable to 64px icon-only
Items: Dashboard | Wallets | Transactions | Send | AI Assistant | Settings
Active: left border accent --color-brand-primary, bg --color-bg-overlay
Notification badge: --color-warning dot
```

### Navigation — Mobile (Bottom Tabs)
```
Tabs: Dashboard | Wallets | Send | Transactions | More
Tab height: 64px + safe area
Active: icon filled + label, --color-brand-primary
```

---

## UX System

### User Types and Contexts

| User | Context | Key needs |
|------|---------|-----------|
| Individual account holder | Mobile first, high frequency | Fast balance check, send money, see status |
| Business account holder | Web primary, operations focus | Bulk transactions, reconciliation, compliance status |
| MLRO / Compliance officer | Web, audit focus | Flagged transactions, SAR status, reporting |
| Internal BANXE ops | Web, operational | Account management, override capabilities |

### Core User Journeys

**Journey 1: Check balance and recent activity** (30s, mobile dominant)
```
Open app → Dashboard loads (balance visible in <2s)
→ Tap transaction to see detail
→ Done
```

**Journey 2: Send money** (2-5 min, web or mobile)
```
Tap Send → Select destination (contact or new)
→ Enter amount → Amount validated (FPS/CHAPS routing shown)
→ SCA challenge if >£30 (PSR 2017)
→ Confirm → Processing state → Confirmed
→ Notification → Transaction appears in feed
```

**Journey 3: Review flagged transaction** (ops/compliance)
```
Alert received → Navigate to flagged transaction
→ See: reason flagged, AML score, entity info
→ Choose: Approve | Hold | Escalate to MLRO
→ Audit trail updated → Notification sent
```

**Journey 4: Onboarding / KYC** (compliance-sensitive)
```
Register → Email verify → Identity upload
→ Processing (2-5 min) → Approved / Manual Review
→ Wallet activated → Welcome dashboard
Progressive disclosure: only ask what is needed at each step
```

**Journey 5: AI Assistant query**
```
Open AI panel → Ask question (text)
→ AI responds with confidence framing
→ User reviews explanation → Takes action or dismisses
→ All AI interactions logged for audit
```

### Dashboard Logic

Web dashboard layout (1200px+):
```
Left sidebar | Main content: 2/3 + 1/3 right panel

Main: Balance widget (top) → Quick actions row → Recent transactions (list)
Right: AI insights panel → Notifications → Pending review items
```

Mobile dashboard layout:
```
[Header: Name + notification bell]
[Balance card: swipeable (multiple wallets)]
[Quick actions: 4 grid — Send | Add | Exchange | More]
[Recent transactions: 5 items visible, tap to see all]
[AI insight strip: 1 active insight]
```

### Transaction Browsing / Search / Filter

```
Controls: date range | status filter | amount range | type (in/out/all) | currency
Search: counterparty name, reference, amount
Sort: newest (default) | oldest | amount ↑↓

Results: paginated, 25 per page
Loading: skeleton rows (not spinner)
Empty: "No transactions match your filters" + clear filters link
Error: inline error with retry button
```

### Send / Transfer Flow (Web)

```
Step 1 — Recipient
  → Search contacts | New beneficiary | Paste IBAN
  → Recipient validation (sanctions check — non-blocking UX, runs in BG)
  
Step 2 — Amount
  → Currency + amount input (monospace, Decimal validation)
  → Available balance displayed live
  → Rail selection if multiple options (FPS / CHAPS)
  → Fee displayed before confirmation
  → SCA notice if >£30

Step 3 — Confirm
  → Full summary: To, Amount, Fee, Rail, Expected time
  → [Confirm Send] button — single clear primary action
  → [Back] [Cancel]

Step 4 — Processing
  → Animated processing state
  → Reference number displayed
  → Expected confirmation time

Step 5 — Result
  → Success: amount, to, ref, time
  → Failure: clear reason, recovery action (retry / contact support)
  → Pending: "We'll notify you when it clears"
```

### AI Assistant Interaction Model

```
UI: Slide-in panel (web) | Full screen with back (mobile)
Input: Text field + suggestions chips
Response: Text + structured data (amounts, dates) where applicable

Mandatory framing for every AI response:
  [BANXE AI badge]
  [Response content]
  [Confidence: HIGH / MEDIUM / UNCERTAIN]
  [Why this? — expandable explanation]
  [Feedback: 👍 👎]

AI capabilities:
  - Spend analysis ("How much did I spend on FX last month?")
  - Upcoming obligation alerts ("Your SEPA payment to X is due in 3 days")
  - Anomaly flagging ("This transaction is unusual for your pattern")
  - Compliance status ("Your EDD review is due")

AI limitations (shown in UI):
  - Cannot initiate transactions
  - Cannot modify account settings
  - All suggestions require user confirmation
  - Uncertainty always shown
```

### Trust and Clarity Rules

1. **Every balance must show: total / available / pending** — never just one number ambiguously
2. **Every transaction must show: status chip** — no ambiguity about cleared vs pending
3. **Every AI element must show: AI badge + confidence** — no unmarked AI content
4. **Every sensitive action must show: what happens if you confirm** — before confirm button
5. **Every error must show: what went wrong + what to do** — no dead-end errors

### Progressive Disclosure Rules

- Show only what user needs for current step
- Advanced options hidden behind "More options" toggle
- Compliance-sensitive info (EDD reason, SAR reference) visible only to authorized roles
- SCA challenge appears at payment confirmation, not before
- KYC document requirements shown one at a time, not all upfront

### Accessibility Rules

- WCAG 2.1 AA minimum
- All interactive elements: focusable, keyboard navigable
- All status chips: include icon + text (not color alone)
- All amounts: screen reader reads currency + amount (e.g. "£1,250.00 available")
- All charts: data table fallback
- Touch targets: minimum 44×44px (mobile)
- Focus ring: visible, --color-brand-light
- Skip to content: web

### Cognitive Load Rules for Sensitive Financial Actions

- Maximum 3 decisions per step in send/transfer flow
- Confirmation screen is summary only (no new information)
- No auto-proceed after 3 seconds of inactivity
- Amount always confirmed with currency symbol
- Large amounts (>£10,000): extra confirmation with typed amount
- Irreversible actions: "This cannot be undone" label + delay before confirm enabled

---

## Shared vs Platform-Specific

### Shared (Web + Mobile)
- Design tokens (colors, typography, spacing, radii)
- Business logic layer (Decimal calculations, status mapping)
- API contract (same endpoints)
- Content/copy (same labels, error messages)
- AI interaction model
- Accessibility principle

### Web-Specific
- Sidebar navigation
- Multi-column dashboard layout
- Keyboard shortcuts
- Table-based transaction list (sortable columns)
- Hover states

### Mobile-Specific
- Bottom tab navigation
- Swipeable wallet card
- Bottom sheet for send flow
- Haptic feedback on confirmation
- Biometric authentication (Face ID / Fingerprint)
- Push notifications
- Compact transaction row (reduced columns)
