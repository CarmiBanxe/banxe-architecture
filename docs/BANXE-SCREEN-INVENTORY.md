# BANXE-SCREEN-INVENTORY.md — Screen Catalog
**Plane:** Architecture | **Updated:** 2026-04-08

---

## Web Screens

### W-01: Dashboard
**Purpose:** Primary landing screen. Balance overview, recent activity, AI insights.

**Primary user actions:** View balances | Browse recent transactions | Access quick actions | Review AI insight

**Required data:**
- Total balance (per currency wallet)
- Available vs pending breakdown
- Last 10 transactions
- Pending review count
- Active AI insight (if any)

**Required components:**
- BalanceWidget (primary)
- QuickActionsBar (Send | Add | Exchange | More)
- TransactionList (recent, 10 items)
- AIInsightPanel (1 active insight)
- PendingReviewBadge

**Mobile adaptation:** Single column, swipeable wallet cards, condensed AI strip

**Accessibility:** Balance reads as "£1,250.00 available, £50.00 pending"

**Trust/compliance:** Pending count badge for compliance review items

**States:**
| State | Behavior |
|-------|---------|
| loading | Skeleton: BalanceWidget + 5 TransactionRow skeletons |
| loaded | Full dashboard |
| error | Inline error in BalanceWidget + retry, rest of page usable |
| no_transactions | "No transactions yet" empty state with "Make your first payment" CTA |
| pending_review | Yellow badge on review items, compliance alert strip if >5 pending |

---

### W-02: Transactions
**Purpose:** Full transaction history with search, filter, and export.

**Primary user actions:** Browse | Search | Filter | Export (CSV) | View transaction detail

**Required data:**
- Transaction list (paginated, 25/page)
- Filter options: date range, status, type, currency, amount range
- Search: counterparty, reference, amount

**Required components:**
- TransactionFilterBar
- TransactionTable (sortable: date, amount, status)
- TransactionDetailDrawer (slide-in)
- ExportButton
- Pagination

**Mobile adaptation:** Card list instead of table, filter as bottom sheet

**Accessibility:** Table with proper th/td, ARIA labels on status chips

**Trust/compliance:** BLOCKED/REVIEW transactions show compliance chip with icon

**States:**
| State | Behavior |
|-------|---------|
| loading | Skeleton rows |
| loaded | Full transaction list |
| empty_default | "No transactions yet" |
| empty_filtered | "No transactions match your filters" + clear filters |
| error | Inline error + retry |
| exporting | Button loading state |

---

### W-03: Wallets
**Purpose:** Multi-currency wallet management. Fiat + crypto overview.

**Primary user actions:** View wallet details | Deposit | Withdraw | Get IBAN | Exchange

**Required data:**
- List of wallets (currency, balance, IBAN if applicable, status)
- Exchange rates (live)
- Pending deposits

**Required components:**
- WalletCard (per currency)
- WalletDetailPanel (expand on click)
- DepositModal
- WithdrawModal
- ExchangeWidget
- IBANDisplay (masked, copy button)

**Mobile adaptation:** Horizontal scroll wallet cards → detail screen

**Accessibility:** IBAN readable with spaces, copy action announces "IBAN copied"

**Trust/compliance:** Wallet status chip: ACTIVE | RESTRICTED | SUSPENDED

**States:**
| State | Behavior |
|-------|---------|
| loading | Wallet card skeletons |
| loaded | All wallets |
| wallet_restricted | Orange banner: reason + contact support |
| deposit_pending | Pending badge on wallet card |
| fx_unavailable | Exchange rate "Unavailable — try again" |

---

### W-04: Send / Transfer
**Purpose:** Initiate outbound payment. Step-by-step guided flow.

**Primary user actions:** Select recipient | Enter amount | Confirm | Track status

**Required data:**
- Saved beneficiaries list
- Current balances
- Exchange rates
- FPS/CHAPS/SEPA routing options
- Fee schedule

**Required components:**
- BeneficiarySearch + BeneficiaryForm (new)
- AmountInput (Decimal, currency selector)
- RailSelector (FPS | CHAPS | SEPA — based on amount + destination)
- FeeBreakdown
- ConfirmationSummary
- SCAChallenge (TOTP if >£30)
- ProcessingState + ResultScreen

**Mobile adaptation:** Full-screen step flow with progress bar

**Accessibility:** Each step announces "Step N of 5", amount confirms "£500 to John Smith"

**Trust/compliance:**
- Sanctions check runs in BG on beneficiary selection (non-blocking UX)
- If flagged: "We need to review this payment" — holds, not blocks
- SCA mandatory >£30 (PSR 2017 Reg.71)
- Large amount (>£10,000): typed confirmation "Please type the amount to confirm"

**States:**
| State | Behavior |
|-------|---------|
| step_recipient | Beneficiary selection |
| step_amount | Amount + rail selection |
| step_confirm | Summary + SCA if applicable |
| processing | Animated processing + reference number |
| success | Confirmed + view in transactions |
| failed | Clear reason + recovery options |
| pending | "Payment processing — you'll be notified" |
| blocked | "This payment requires review" — compliance hold |

---

### W-05: AI Assistant
**Purpose:** Interactive AI for financial queries, insights, anomaly alerts.

**Primary user actions:** Ask question | Review insight | Expand explanation | Dismiss | Provide feedback

**Required data:**
- Chat history (session)
- Recent transactions (context)
- Active flags/alerts

**Required components:**
- AIChatInterface (input + response stream)
- AIBadge (mandatory, --color-ai-accent)
- ConfidenceIndicator (HIGH | MEDIUM | UNCERTAIN)
- ExplanationToggle ("Why this?")
- FeedbackButtons (👍 👎)
- InsightsList (active alerts, past queries)

**Mobile adaptation:** Full screen, keyboard-aware layout

**Accessibility:** All AI responses labeled "AI-generated content follows"

**Trust/compliance:**
- Every response has AI badge + confidence
- "AI cannot initiate payments or change settings" — static notice
- All interactions logged for FCA audit trail

**States:**
| State | Behavior |
|-------|---------|
| idle | Welcome message + suggestion chips |
| thinking | Typing animation |
| responded | Response with confidence + explanation |
| uncertain | "I'm not certain. Please verify with your account details." |
| error | "Temporarily unavailable — try again" |

---

### W-06: Profile / Settings
**Purpose:** Account management, notification preferences, security settings.

**Primary user actions:** Update profile | Change notification settings | View KYC status | Manage 2FA | Download statements

**Required data:**
- User profile (name, email, entity type)
- KYC status + EDD status
- 2FA configuration
- Notification preferences
- API access (business accounts)

**Required components:**
- ProfileCard
- KYCStatusPanel
- NotificationPreferencesForm
- SecuritySettings (2FA toggle, active sessions)
- StatementDownload
- DangerZone (account closure — hidden behind expansion)

**States:** Standard form states: viewing | editing | saving | saved | error

---

## Mobile Screens

### M-01: Mobile Dashboard
**Differences from W-01:**
- No sidebar navigation → bottom tabs
- Wallet cards: horizontal swipe (one card visible + partial next)
- Quick actions: 4-icon grid (Send | Add | Exchange | More)
- AI insight: compact strip at bottom of cards
- Transaction list: 5 items, "See all" link to M-02

---

### M-02: Mobile Transactions
**Differences from W-02:**
- Card layout instead of table
- Filter via bottom sheet (full-screen)
- Detail: full-screen slide from right
- Export: share sheet (native mobile)

---

### M-03: Mobile Wallet
**Differences from W-03:**
- Full-screen per wallet (tap to enter)
- IBAN: tap to copy, long-press for share
- Deposit / Withdraw: full-screen flow
- Exchange: bottom sheet widget

---

### M-04: Mobile Send Flow
**Differences from W-04:**
- Step-by-step full-screen flow
- Beneficiary: searchable list with avatar
- Amount: large numpad (calculator style)
- Biometric or PIN for SCA (not TOTP on mobile)
- Bottom sheet confirmation (not modal)

---

### M-05: Mobile AI Assistant
**Differences from W-05:**
- Full screen from bottom tab or deep link
- Voice input button (optional, Phase 2)
- Suggestion chips pre-loaded
- Pull to refresh insight list

---

### M-06: Mobile Profile
**Differences from W-06:**
- Grouped settings list (iOS / Material style)
- KYC status card at top
- Biometric toggle prominent
- Notification settings: per channel (push, email, SMS)

---

## Shared States (All Screens)

| State | Component | Behavior |
|-------|-----------|---------|
| network_offline | GlobalBanner | "You're offline — some features unavailable" |
| session_expiring | SessionWarningModal | "Your session expires in 2 minutes" + Extend |
| compliance_hold | ComplianceHoldBanner | "Your account is under review" — read-only mode |
| maintenance | MaintenanceScreen | "Scheduled maintenance — back by {time}" |
| loading | SkeletonScreens | Never spinner-only — always skeleton layout |
| error_boundary | ErrorBoundary | "Something went wrong" + reload + support link |

---

## Reusable Modules

| Module | Used in |
|--------|---------|
| TransactionRow | Dashboard, Transactions, Wallet detail |
| BalanceWidget | Dashboard, Wallet |
| StatusChip | Transactions, Send result, Compliance flags |
| AIInsightCard | Dashboard, AI Assistant |
| ConfirmationDialog | Send, Settings changes, Account closure |
| SCAChallenge | Send flow (>£30), Settings security change |
| AmountInput | Send, Exchange, Deposit, Withdrawal |
| BeneficiarySearch | Send flow |
| IBANDisplay | Wallet detail, Profile |
| EmptyState | All lists (with contextual icon + CTA) |
| SkeletonRow | All loading states |
| ComplianceFlag | Transactions (BLOCKED, REVIEW status) |
