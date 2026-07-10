# GOLD SCHEME APP — Complete Project Context
> Use this file to resume work from any AI tool or any point in the project.
> Last updated: 5 July 2026

---

## 1. WHO I AM & WHAT WE'RE BUILDING

**Project:** Bindu Gold Scheme App
**Client:** Bictree Pvt. Ltd.
**Purpose:** Digitize paper-based gold chit/savings schemes for jewellery stores across India (Kerala-first).
**Platform:** Flutter → Android + iOS (single codebase)
**Backend:** Node.js + Express.js + MongoDB (already fully built, I only consume APIs)
**My role:** Flutter developer building the mobile app from scratch.

---

## 2. WHAT THE APP DOES

Customers join monthly gold savings plans at jewellery stores. They pay installments, accumulate gold (in grams), and redeem it as jewellery when the scheme matures. Think of it as a digital gold passbook + payment app.

### User Roles (same Flutter app, role-based UI)
| Role | Flutter Scope |
|------|--------------|
| Customer | OTP login, scheme browse, passbook, Razorpay payments, gold balance, redemption, KYC, FCM |
| Agent (field officer) | Due list, cash collection, GPS check-in, offline mode (Hive queue), bulk sync |
| Store Owner / Admin | Web panel only — NOT Flutter scope |
| Super Admin | Web panel only — NOT Flutter scope |

---

## 3. ARCHITECTURE DECISIONS (LOCKED IN)

### Pattern: Clean Architecture + Feature-First + MVVM

```
lib/
  core/               ← theme, router, constants, utils, providers
  features/
    global_widgets/     ← reusable widgets used across features
    auth/
      presentation/
        screens/      ← UI only (Widgets)
        viewmodels/   ← Riverpod Notifiers (ViewModel layer)
        widgets/      ← feature-specific widgets
    dashboard/        ← same structure per feature
    schemes/
    enrollments/
    payments/
    profile/
    kyc/
    redemption/
    notifications/
    agent/
    settings/
  shell/              ← bottom nav shell
```

### Dependency Rule
- Presentation → depends on → ViewModel (Riverpod)
- ViewModel → depends on → (Phase 2: Use Cases / Domain)
- Data layer → (Phase 2: repositories, Dio, DTOs)
- Core/Shared → depends on nothing

### State Management: Riverpod 2 (with code generation in Phase 2)
- `NotifierProvider` for UI state
- `AsyncNotifierProvider` for async data (Phase 2)
- `Provider` for simple values (theme, router)
- Why Riverpod over Bloc: simpler async state (AsyncValue), compile-time safety, no BuildContext needed in business logic, easy testing overrides

### Navigation: GoRouter v14
- `ShellRoute` for bottom navigation (5 tabs)
- Named routes via `RouteName` constants class
- Slide transition for drill-down screens
- Fade transition for splash/auth
- No transition for bottom nav tab switches
- Deep link ready for FCM notification navigation (Phase 2)

---

## 4. DESIGN SYSTEM

### Color Palette
```dart
Primary Gold:    #D4AF37   ← CTAs, highlights, gold amounts
Dark Navy:       #1A1A2E   ← Headers, primary text, dark backgrounds
Warm White:      #F8F5F0   ← Screen backgrounds (light mode)
Surface White:   #FFFFFF   ← Cards, bottom sheets
Success Green:   #27AE60   ← Paid, verified, success
Warning Orange:  #E67E22   ← Due-soon, pending, processing
Error Red:       #C0392B   ← Overdue, failed, rejected
Muted Gray:      #757575   ← Labels, secondary info
```

### Dark Mode
```
Background:  #0D0D1A
Surface:     #1A1A2E
Card:        #242438
Border:      #2E2E4A
```

### Typography: Google Noto Sans (Latin) + Noto Serif Malayalam
- Headings: Bold, 20–24sp
- Section titles: SemiBold, 16–18sp
- Body: Regular, 14–15sp
- Min label: 12sp
- Status badges: UPPERCASE + letter-spacing

### Gradients
- Gold gradient: `#D4AF37 → #B8962E` (CTAs, hero cards)
- Navy gradient: `#1A1A2E → #2D2D50` (dark headers)
- Hero gradient: `#1A1A2E → #16213E → #0F3460`

### Themes
- Both light and dark `ThemeData` configured via `AppTheme.light` and `AppTheme.dark`
- Theme persisted in `SharedPreferences` via `ThemeNotifier` (Riverpod)
- Custom `AppThemeExtension` for gold surface, shimmer colors, etc.

---

## 5. KEY TECHNICAL DECISIONS

| Concern | Decision | Reason |
|---------|----------|--------|
| State | Riverpod 2 | AsyncValue, testable, no context coupling |
| Nav | GoRouter 14 | Deep links, ShellRoute, type-safe |
| HTTP | Dio + interceptors | JWT auto-refresh, centralized error handling (Phase 2) |
| Tokens | flutter_secure_storage | Keychain/Keystore, NEVER SharedPreferences |
| Offline queue | Hive | Agent payment queue, schema matches POST /installments |
| Theme pref | SharedPreferences | Non-sensitive (just theme mode) |
| Currency | intl (Indian format) | ₹1,00,000 format via AppFormatters.currency() |
| Gold display | 3 decimal places | Per spec: 1.234 g |
| Images | cached_network_image | All remote images |
| KYC compress | flutter_image_compress | Max 2MB before upload |
| Payments | Razorpay SDK | Server creates order → SDK → server verifies |
| Crash reporting | Firebase Crashlytics | Phase 2 |
| Fonts | Google Fonts (Noto Sans) + local Noto Serif Malayalam | |

---

## 6. BACKEND API REFERENCE

**Base URL (dev):** `http://localhost:5000/api/v1`
**Auth:** `Authorization: Bearer <access_token>`
**Success:** `{ "success": true, "message": "...", "data": { ... } }`
**Error:** `{ "success": false, "message": "...", "error": "..." }`
**On 401:** auto-call `POST /auth/refresh` → retry → if fails → force logout

### Auth Endpoints
```
POST /auth/send-otp       Public  Send OTP to mobile
POST /auth/verify-otp     Public  Verify OTP → accessToken + refreshToken
POST /auth/refresh        Public  Refresh access token
POST /auth/logout         Auth    Invalidate refresh token
```

### User Endpoints
```
GET    /users/:id                  Get profile + KYC status
PATCH  /users/:id                  Update name, email, language
POST   /users/:id/kyc              Submit KYC docs (Aadhaar, PAN)
PATCH  /users/:id/kyc/verify       Approve/Reject KYC (Admin)
GET    /users/:id/enrollments      All enrollments
PATCH  /users/:id/device-token     Register FCM token
```

### Scheme Endpoints
```
GET /schemes        List active schemes (branch-filtered)
GET /schemes/:id    Scheme detail + bonus & late-fee policy
```

### Enrollment Endpoints
```
POST   /enrollments                    Enroll customer
GET    /enrollments/:id                Detail + gold weight summary
GET    /enrollments/:id/installments   Passbook (paginated)
GET    /enrollments/:id/statement      PDF statement (binary)
PATCH  /enrollments/:id/status         Pause/cancel/default
```

### Payment Endpoints
```
POST /payments/create-order    Create Razorpay order → order_id
POST /payments/verify          Verify HMAC signature, credit installment
POST /installments             Record offline/cash payment (Agent)
POST /installments/sync        Bulk sync offline payments (Agent)
```

### Gold Rate Endpoints
```
GET /gold-rates/today      Today's 24K/22K/18K rates
GET /gold-rates/history    Rate history with date range
```

### Redemption Endpoints
```
POST   /redemptions              Request gold redemption
GET    /redemptions/:id          Redemption detail + status
PATCH  /redemptions/:id/status   Update status (Admin)
```

### Notification Endpoints
```
GET   /notifications            List notifications
PATCH /notifications/:id/read   Mark as read
```

### Agent Endpoints
```
GET  /agents/:id/due-list     Today's due collection list
POST /agents/:id/checkin      GPS check-in
GET  /agents/:id/stats        Performance stats
GET  /agents/:id/collections  Historical collections
```

---

## 7. PHASE PLAN

### Phase 1 — UI Only (Deadline: 10 July 2026)
**Goal:** All screens from Figma, no real API calls. Mock data in ViewModels.
**Deliverable:** Working APK with full navigation and UI.

**Today's work (5 July):**
- [x] Project folder structure created (feature-first clean architecture)
- [x] `pubspec.yaml` with all dependencies
- [x] `AppColors` — complete light/dark palette
- [x] `AppSpacing` — spacing constants
- [x] `AppTypography` — full text style system (Noto Sans + Malayalam)
- [x] `AppTheme` — complete light + dark `ThemeData` + `AppThemeExtension`
- [x] `ThemeNotifier` — persisted theme toggle (Riverpod)
- [x] `RouteName` — all named route constants
- [x] `AppRouter` — full GoRouter config with ShellRoute, transitions, deep links
- [x] `AppFormatters` — currency (₹1,00,000), gold weight (1.234g), dates, phone
- [x] `AppButton` — primary/secondary/outline/ghost/danger variants + loading state
- [ ] Remaining shared widgets (in progress, see Section 8)
- [ ] All feature screens

### Phase 2 — API Integration + Production (After 10 July)
- Dio HTTP client + JWT interceptor + 401 silent refresh
- flutter_secure_storage for tokens
- Real API calls replacing mock data in ViewModels
- Razorpay payment integration
- FCM push notifications + deep links
- Hive offline queue for agent
- GPS check-in
- KYC image upload (compress → S3)
- Firebase Crashlytics
- Unit tests (70% coverage on business logic)
- Integration tests (Login → Pay flow, Agent offline sync)
- Signed APK + AAB for Play Store
- IPA for App Store

---

## 8. SHARED WIDGETS TO BUILD (lib/shared/widgets/)

| Widget | File | Status | Purpose |
|--------|------|--------|---------|
| AppButton | app_button.dart | ✅ Done | Primary/secondary/outline/ghost/danger |
| AppIconButton | app_button.dart | ✅ Done | Icon-only action button |
| AppTextField | app_text_field.dart | ⬜ Todo | Custom text input with gold focus border |
| StatusBadge | status_badge.dart | ⬜ Todo | PAID/OVERDUE/PENDING/VERIFIED chips |
| GoldRateCard | gold_rate_card.dart | ⬜ Todo | 24K/22K/18K rate display card |
| GoldBalanceHero | gold_balance_hero.dart | ⬜ Todo | Hero card with CountUp animation |
| ShimmerLoading | shimmer_loading.dart | ⬜ Todo | Skeleton placeholder widgets |
| CustomAppBar | custom_app_bar.dart | ⬜ Todo | Consistent app bar across screens |
| EmptyStateWidget | empty_state_widget.dart | ⬜ Todo | Empty list/error illustrations |
| AppBottomNav | app_bottom_nav.dart | ⬜ Todo | Bottom navigation bar |
| InstallmentCard | installment_card.dart | ⬜ Todo | Passbook installment row |
| EnrollmentCard | enrollment_card.dart | ⬜ Todo | Enrollment summary card |
| SchemeCard | scheme_card.dart | ⬜ Todo | Scheme listing card |
| ProgressRing | progress_ring.dart | ⬜ Todo | Circular progress for enrollment |
| SectionHeader | section_header.dart | ⬜ Todo | Section title + "See all" link |
| AppDivider | app_divider.dart | ⬜ Todo | Styled divider |
| InfoRow | info_row.dart | ⬜ Todo | Label + value row for detail screens |
| GoldAmountDisplay | gold_amount_display.dart | ⬜ Todo | Gold grams with icon |
| ConfirmDialog | confirm_dialog.dart | ⬜ Todo | Reusable confirmation dialog |
| SuccessSheet | success_sheet.dart | ⬜ Todo | Bottom sheet for success states |

---

## 9. ALL SCREENS TO BUILD

### Customer Screens
| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Splash | `/` | ⬜ Todo | Animated gold logo, 2-3s, auto-navigate |
| Login | `/login` | ⬜ Todo | Full gold gradient header, +91 input |
| OTP Verify | `/otp` | ⬜ Todo | 6-box OTP, auto-submit, 30s countdown |
| Dashboard | `/app/dashboard` | ⬜ Todo | Hero card, gold rate ticker, enrollments, quick actions |
| Gold Rates | `/app/gold-rates` | ⬜ Todo | Purity tabs, sparkline chart, last updated |
| Schemes List | `/app/schemes` | ⬜ Todo | Card grid, filter by purity/duration |
| Scheme Detail | `/app/schemes/:id` | ⬜ Todo | Full detail + gold calculator |
| My Enrollments | `/app/enrollments` | ⬜ Todo | Active + completed tabs |
| Passbook | `/app/enrollments/:id/passbook` | ⬜ Todo | Timeline list, month grouping, PDF download |
| Payment | `/app/pay/:enrollmentId` | ⬜ Todo | Amount chips, gold preview, Razorpay CTA |
| Payment Success | `/app/pay/success` | ⬜ Todo | Lottie animation, receipt, gold credited |
| Profile | `/app/profile` | ⬜ Todo | Name, phone, KYC badge, edit, settings |
| Edit Profile | `/app/profile/edit` | ⬜ Todo | Name, email, language picker |
| KYC Submit | `/app/profile/kyc` | ⬜ Todo | Aadhaar + PAN upload, camera/gallery |
| KYC Status | `/app/profile/kyc/status` | ⬜ Todo | Status timeline: pending/verified/rejected |
| Redemption | `/app/redemption/:enrollmentId` | ⬜ Todo | Wizard: enrollment → mode → address → confirm |
| Redemption Status | `/app/redemption/:id/status` | ⬜ Todo | Status tracker: requested→dispatched→completed |
| Notifications | `/app/notifications` | ⬜ Todo | Date-grouped, unread dot, swipe-to-dismiss |
| Settings | `/app/settings` | ⬜ Todo | Theme toggle, language, version, logout |

### Agent Screens
| Screen | Route | Status |
|--------|-------|--------|
| Agent Dashboard | `/app/agent/dashboard` | ⬜ Todo |
| Due List | `/app/agent/due-list` | ⬜ Todo |
| Collect Payment | `/app/agent/collect/:customerId` | ⬜ Todo |
| Agent Stats | `/app/agent/stats` | ⬜ Todo |

---

## 10. FILES CREATED SO FAR

```
gold_scheme/
├── pubspec.yaml                                     ✅
└── lib/
    ├── core/
    │   ├── theme/
    │   │   ├── app_colors.dart                      ✅
    │   │   ├── app_spacing.dart                     ✅
    │   │   ├── app_typography.dart                  ✅
    │   │   └── app_theme.dart                       ✅
    │   ├── router/
    │   │   ├── route_names.dart                     ✅
    │   │   └── app_router.dart                      ✅
    │   ├── utils/
    │   │   └── formatters.dart                      ✅
    │   └── providers/
    │       └── theme_provider.dart                  ✅
    └── shared/
        └── widgets/
            └── app_button.dart                      ✅
```

**All other files and folders exist as empty directories, ready to be filled.**

---

## 11. FIGMA DESIGN

**File:** BINDU GOLD SCHEME APP UI
**Link:** https://www.figma.com/design/J8FpCIYlahGIkwrqbY5D48/BINDU-GOLD-SCHEME-APP-UI?node-id=122-2&t=WoEUMYoN5Qb34hDs-0
**Status:** Access required — request from client before building each screen.

---

## 12. IMPORTANT RULES & CONSTRAINTS

### Security (non-negotiable)
- NEVER store tokens in SharedPreferences — use flutter_secure_storage only
- NEVER generate Razorpay orders in Flutter — always call POST /payments/create-order
- NEVER trust Razorpay client callback alone — always call POST /payments/verify
- SSL certificate pinning for production builds (Phase 2)

### Gold Calculation Rule
```
gold_grams = installment_amount ÷ gold_rate_at_payment_date
Display: 3 decimal places (e.g. 1.234 g)
Currency: Indian format ₹1,00,000
```

### JWT Token Handling (Phase 2)
- accessToken expires in 15 minutes
- refreshToken expires in 30 days
- On 401: lock → call POST /auth/refresh → retry queued requests → if refresh fails → force logout
- Must use queue-based approach (not naive retry) to prevent race conditions when multiple parallel requests hit 401

### Offline Agent Queue (Phase 2)
- Store in Hive with schema exactly matching POST /installments payload
- Max 200 records before forcing sync
- Auto-sync when connectivity restored (connectivity_plus)
- WorkManager for background sync on Android

### Multi-language
- 4 languages: ml (Malayalam), en, ta (Tamil), hi (Hindi)
- ARB files in lib/l10n/
- Noto Serif Malayalam font for ml locale
- Use intl package for date/number formatting per locale
- Language preference stored per user on server (PATCH /users/:id)

### Performance targets
- < 16ms frame render time
- Pagination on all lists: ?page=1&limit=20
- 30-minute TTL cache for gold rates and scheme list
- KYC images compressed to max 2MB before upload
- const widgets wherever possible

---

## 13. PACKAGES & VERSIONS

```yaml
# State management
flutter_riverpod: ^2.5.1
riverpod_annotation: ^2.3.5
hooks_riverpod: ^2.5.1
flutter_hooks: ^0.20.5

# Navigation
go_router: ^14.2.0

# UI
google_fonts: ^6.2.1
flutter_svg: ^2.0.10+1
cached_network_image: ^3.3.1
shimmer: ^3.0.0
lottie: ^3.1.2
flutter_animate: ^4.5.0
pinput: ^5.0.0
percent_indicator: ^4.2.3

# Formatting
intl: ^0.19.0

# Storage
flutter_secure_storage: ^9.2.2
hive_flutter: ^1.1.0
shared_preferences: ^2.3.0

# Network
dio: ^5.4.3+1
connectivity_plus: ^6.0.3

# Payments
razorpay_flutter: ^1.3.6

# Firebase
firebase_core: ^3.3.0
firebase_messaging: ^15.0.4
firebase_crashlytics: ^4.0.4

# Device & media
image_picker: ^1.1.2
flutter_image_compress: ^2.3.0
geolocator: ^13.0.1
permission_handler: ^11.3.1
flutter_pdfview: ^1.3.2

# Utils
freezed_annotation: ^2.4.1
json_annotation: ^4.9.0

# Dev
build_runner: ^2.4.11
riverpod_generator: ^2.4.3
freezed: ^2.5.2
json_serializable: ^6.8.0
```

---

## 14. RECOMMENDED NEXT STEPS (IN ORDER)

1. Create Flutter project: `flutter create gold_scheme --org com.bictree`
2. Copy all files from this session into the project
3. Run `flutter pub get`
4. Download Noto Serif Malayalam font files into `assets/fonts/`
5. Create placeholder files in `assets/images/`, `assets/icons/`, `assets/animations/`
6. Build remaining shared widgets (see Section 8 list)
7. Build `MainShell` (bottom nav shell)
8. Build `SplashScreen`
9. Build `LoginScreen` + `OtpScreen`
10. Build `DashboardScreen` with mock data
11. Continue with all remaining screens (see Section 9)

---

## 15. ASKING AN AI TO CONTINUE THIS WORK

When resuming with any AI assistant, say:

> "I'm building a Flutter app called Gold Scheme (Bindu Gold Scheme App) for Bictree Pvt. Ltd. I have a project context document. The architecture is Clean Architecture + Feature-First + MVVM using Riverpod 2 and GoRouter. Phase 1 is UI-only with mock data, deadline 10 July 2026. Here is the full context: [paste this file]. Today I need to build: [specific widget/screen]."

Always share this file at the start of every new session.
