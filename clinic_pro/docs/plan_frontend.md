# 🎨 plan_frontend.md — Frontend Plan & Design Reference

---

## 1. Design Principles

- **UI First:** entire UI is built with mock data before any Supabase integration
- **RTL First:** Arabic layout is the default — English is secondary
- **Clean & Medical:** whitespace-heavy, trustworthy, no decorative clutter
- **Responsive:** Mobile → Tablet → Desktop (future)
- **Accessible:** sufficient contrast, readable font sizes, touch targets ≥ 48px

---

## 2. Desigh Reference

** Use Stitch MCP to design the app
** The name of the project in Stitch is "ClinicPro"


---

## 3. Design System (Single Source of Truth)

All values below are **confirmed from Stitch**. Use these tokens everywhere — never hardcode hex values.

### 3.1 Colors

```dart
// core/themes/app_colors.dart

class AppColors {
  // ─── Brand ───
  static const primary         = Color(0xFF1A6B8A); // teal-blue — main brand
  static const primaryDark     = Color(0xFF00526D); // headings, links, AppBar title
  static const primaryLight    = Color(0xFFEAF4F8); // tint backgrounds, chip selected
  static const accent          = Color(0xFF2ECC9A); // success, active, confirmed
  static const accentLight     = Color(0xFF67F8C3); // lighter accent — some cards
  static const warning         = Color(0xFFF5A623); // alerts, pending status
  static const warningLight    = Color(0xFFFEF3C7); // warning banner background
  static const danger          = Color(0xFFE84C4C); // error, cancel, delete
  static const buttonTextLight = Color(0xFFBCE7FF); // text ON primary buttons

  // ─── Light Theme ───
  static const backgroundLight    = Color(0xFFF7F9FC); // screen background
  static const surfaceLight       = Color(0xFFFFFFFF); // cards, sheets, inputs
  static const surfaceAltLight    = Color(0xFFF2F4F7); // inactive buttons, alt rows
  static const borderLight        = Color(0xFFE2E8F0); // card borders, dividers
  static const textPrimaryLight   = Color(0xFF1A202C); // main text
  static const textSecondaryLight = Color(0xFF64748B); // secondary, captions
  static const textHintLight      = Color(0xFFA0AEC0); // placeholders

  // ─── Dark Theme ───
  static const backgroundDark    = Color(0xFF0F1923);
  static const surfaceDark       = Color(0xFF1A2535);
  static const surfaceAltDark    = Color(0xFF232F3E);
  static const borderDark        = Color(0xFF2D3748);
  static const textPrimaryDark   = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const textHintDark      = Color(0xFF4A5568);
}
```

### 3.2 Typography

```dart
// core/themes/app_text_styles.dart
// Fonts: Cairo (Arabic) + Inter (numbers & financial data)

class AppTextStyles {
  static const h1      = TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold);
  static const h2      = TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w600);
  static const h3      = TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600);
  static const bodyLg  = TextStyle(fontFamily: 'Cairo', fontSize: 15);
  static const body    = TextStyle(fontFamily: 'Cairo', fontSize: 14);
  static const caption = TextStyle(fontFamily: 'Cairo', fontSize: 12);
  static const label   = TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w500);
  static const mono    = TextStyle(fontFamily: 'Inter',  fontSize: 13, fontWeight: FontWeight.bold);
  // mono → prices, numbers, dates, IDs
}
```

### 3.3 Spacing & Radius

```dart
// core/constants/app_constants.dart

class AppSpacing {
  static const xs   = 4.0;
  static const sm   = 8.0;
  static const md   = 12.0;
  static const lg   = 16.0;
  static const xl   = 20.0;
  static const xxl  = 24.0;
  static const xxxl = 32.0;

  static const screenH = 20.0; // horizontal screen padding
  static const screenV = 16.0; // vertical screen padding
}

class AppRadius {
  static const card   = 16.0;
  static const button = 12.0;
  static const chip   = 20.0; // pill
  static const input  = 10.0;
  static const sheet  = 24.0; // bottom sheet top corners only
  static const avatar = 100.0;
}
```

### 3.4 Component Specs (confirmed from Stitch)

**AppBar**
```
Height:     64px
Background: surface (#FFFFFF)
Shadow:     0 1px 1.5px rgba(0,0,0,0.05)
Title:      h2 Cairo:Bold, color primaryDark (#00526D)
Avatar:     36px circle, bg primary
```

**Cards**
```
Border-radius: 16px
Border:        1px solid border (#E2E8F0)
Shadow:        0 1px 3px rgba(0,0,0,0.08)
Background:    surface (#FFFFFF)
Padding:       16–21px
```

**Primary Button**
```
Background:    primary (#1A6B8A)
Border-radius: 12px
Shadow:        0 4px 8px rgba(26,107,138,0.25)
Text:          h3 Cairo:SemiBold, color buttonTextLight (#BCE7FF)
Padding:       12px vertical, 16px horizontal
```

**Secondary/Outlined Button**
```
Background:    primaryLight (#EAF4F8) or surface
Border:        1px solid rgba(0,82,109,0.2)
Border-radius: 12px
Text:          h3 Cairo:SemiBold, color primaryDark (#00526D)
```

**Input Fields**
```
Border-radius: 10px
Border:        1px solid border (#E2E8F0)
Shadow:        0 1px 2px rgba(0,0,0,0.05)
Padding:       13px vertical, 17px horizontal
Trailing icon: right-aligned (RTL)
Placeholder:   Inter:Bold 13sp, color textHint
```

**FAB**
```
Size:          56×56px
Background:    primary (#1A6B8A)
Border-radius: full circle
Shadow:        0 4px 8px rgba(26,107,138,0.25)
Position:      bottom-end, margin 16px
```

**Bottom Navigation**
```
Height:        64px
Active tab:    bg primary, rounded pill 16px, icon+label color buttonTextLight
Inactive tab:  icon+label color textSecondary (#64748B)
Label:         11sp Cairo:Medium
```

**Status Badges (pill shape)**
```
confirmed → bg #D1FAE5  text #065F46
pending   → bg #FEF3C7  text #92400E
cancelled → bg #FEE2E2  text #991B1B
upcoming  → bg #EAF4F8  text #1A6B8A
```

**Alert Banner**
```
Background: warningLight (#FEF3C7)
Border:     1px solid rgba(146,64,14,0.1)
Text color: #92400E
Action btn: surface bg, border rgba(146,64,14,0.2)
```

**Summary Cards (Bento — Dashboard)**
```
Width:         ~160px (horizontal scroll)
Left border accent: 4px on revenue card
Corner overlay: decorative circle, opacity 0.05
Icon container: 8px radius, colored bg
Value:         mono Inter:Bold
```

---

## 4. Shared Widgets

All in `core/widgets/` — used across all features.

| Widget | File | Description |
|--------|------|-------------|
| `AppListItem` | `app_list_item.dart` | 72px item — leading + title + subtitle + badges + (···) |
| `AppBottomSheet` | `app_bottom_sheet.dart` | handle bar + title + X + content + save button |
| `StatusBadge` | `status_badge.dart` | pill badge colored by status enum |
| `EmptyState` | `empty_state.dart` | icon + title + description + action button |
| `ShimmerList` | `shimmer_list.dart` | loading placeholder matching 72px list rows |
| `DoseChipSelector` | `dose_chip_selector.dart` | 3 chip rows: frequency / duration / timing |
| `SummaryCard` | `summary_card.dart` | icon + label + mono value |
| `RealtimeIndicator` | `realtime_indicator.dart` | 8px pulsing green dot |

### DoseChipSelector detail
```
Row 1 — Frequency:  [1×][2×][3×][4×][PRN]
  → PRN = is_prn:true, disables rows 1 & 2

Row 2 — Duration:   [3d][5d][7d][10d][14d][30d]
  → hidden when is_prn = true

Row 3 — Timing:     [قبل الأكل][بعد الأكل][مع الأكل][أي وقت]
```

### AppBottomSheet layout
```
── handle bar (32×4px, centered, grey) ──
[Title h3]                        [✕ close]
─────────────────────────────────────────
[content / form fields]
[Primary full-width Save Button]

max-height: 85% screen
tablet:     max-width 480px, centered
```

---

## 5. Bottom Navigation (per role)

```dart
// Owner
tabs:  [الرئيسية, العيادات, التقارير, الإعدادات]
icons: [home, building, chart-bar, settings]

// Doctor
tabs:  [الرئيسية, المواعيد, المرضى, الإعدادات]
icons: [home, calendar, users, settings]

// Secretary
tabs:  [الرئيسية, المواعيد, الفواتير, الإعدادات]
icons: [home, calendar, receipt, settings]
```

---

## 6. Responsive Breakpoints

```dart
// core/utils/responsive_helper.dart
class ResponsiveHelper {
  static bool isMobile(BuildContext ctx)  => MediaQuery.sizeOf(ctx).width < 600;
  static bool isTablet(BuildContext ctx)  => MediaQuery.sizeOf(ctx).width >= 600
                                          && MediaQuery.sizeOf(ctx).width < 900;
  static bool isDesktop(BuildContext ctx) => MediaQuery.sizeOf(ctx).width >= 900;
}
```

| Breakpoint | Layout | Navigation |
|-----------|--------|-----------|
| Mobile < 600 | 1 column | Bottom Navigation |
| Tablet 600–900 | 2 columns for grids | Bottom or Side Nav |
| Desktop > 900 | Sidebar 240px + content | Side Navigation (future) |

---

## 7. Screen-Level Rules

### Every List Screen must have
```
✅ AppBar: title + optional filter icon
✅ SearchBar (if applicable)
✅ Filter Chips row (if applicable)
✅ ListView.builder with AppListItem
✅ (···) on each item → Action Bottom Sheet
✅ FAB → Add/Edit Bottom Sheet
✅ EmptyState when list is empty
✅ ShimmerList while loading
✅ Error state with retry button
```

### Every Details Screen must have
```
✅ AppBar: back button + optional edit action
✅ Scrollable body
✅ Sections clearly separated
✅ No inline editing — always via Bottom Sheet
```

### Prescription Screen (special)
```
✅ Opened ONLY from "Confirm Examination" in appointments
✅ Bottom Actions Bar fixed at bottom: [حفظ][طباعة]
✅ Drug cards scrollable in body
✅ is_prn = true → disables frequency + duration chips
✅ Multi-select diagnosis templates
✅ Add drug manually → search Bottom Sheet (node 1:1832)
✅ Use node 1:3115 for new prescription design reference
```

### Invoice Creation (special flow)
```
✅ Accessible via:
   a) Invoices FAB
   b) Appointments (···) → "تسجيل فاتورة"
✅ Bottom Sheet:
   - Patient autocomplete
   - Appointment selector (filtered to patient)
   - Amount field — appointment.price shown as hint "السعر المتوقع"
   - Payment method (optional)
```

### Subscription Screen (special)
```
✅ Fetch plans from plans + plan_features tables
✅ Toggle: Monthly / Yearly (show yearly savings)
✅ Trial countdown: days remaining, prominent
✅ Usage progress bars: clinics / staff / patients (current / max)
✅ plan_features.feature jsonb → render feature list
✅ Upgrade CTA prominent when status = trial or expired
```

### Implementation notes from Stitch
```
- RTL fully applied in all Stitch frames
- Currency: "12,500 دولار" — Inter Bold number, Cairo suffix
- Dates: "١٥ أكتوبر ٢٠٢٣" — Arabic numerals
- Bottom sheets → showModalBottomSheet
- Horizontal scroll sections → ListView.horizontal
- Bar chart → fl_chart package
- Icons → flutter_tabler_icons (not Stitch SVG exports)
```

---

## 8. Navigation Flow

```
Splash
  ├── Login
  │     ├── Create Account → Onboarding (Plan → Clinic → Invite)
  │     └── Accept Invitation
  │
  ├── Owner Dashboard
  │     ├── Clinics → Clinic Details
  │     ├── Reports
  │     └── Settings → Subscription
  │
  ├── Doctor Dashboard
  │     ├── Appointments → Appointment Details
  │     │                → Prescription (confirm exam only)
  │     ├── Patients → Patient Details
  │     └── Settings
  │
  └── Secretary Dashboard
        ├── Appointments → Appointment Details
        │                → Invoice (via ··· action)
        ├── Invoices
        ├── Waiting Queue
        └── Settings
```

---

## 9. GoRouter Structure

```dart
// core/router/app_router.dart

final router = GoRouter(
  initialLocation: '/splash',
  redirect: _handleRedirect,
  routes: [
    GoRoute(path: '/splash',      builder: (_,__) => const SplashScreen()),
    GoRoute(path: '/login',       builder: (_,__) => const LoginScreen()),
    GoRoute(path: '/register',    builder: (_,__) => const CreateAccountScreen()),
    GoRoute(path: '/join/:token', builder: (_,s)  =>
      AcceptInvitationScreen(token: s.pathParameters['token']!)),

    // Onboarding
    ShellRoute(routes: [
      GoRoute(path: '/onboarding/plan',   builder: (_,__) => const PlanScreen()),
      GoRoute(path: '/onboarding/clinic', builder: (_,__) => const CreateClinicScreen()),
      GoRoute(path: '/onboarding/invite', builder: (_,__) => const InviteStaffScreen()),
    ]),

    // Dashboards
    GoRoute(path: '/owner/dashboard',     builder: (_,__) => const OwnerDashboardScreen()),
    GoRoute(path: '/doctor/dashboard',    builder: (_,__) => const DoctorDashboardScreen()),
    GoRoute(path: '/secretary/dashboard', builder: (_,__) => const SecretaryDashboardScreen()),

    // Prescription
    GoRoute(
      path: '/prescription/:appointment_id',
      builder: (_,s) => PrescriptionScreen(
        appointmentId: s.pathParameters['appointment_id']!),
    ),

    // Owner-only
    GoRoute(path: '/clinics',     builder: (_,__) => const ClinicsScreen()),
    GoRoute(path: '/clinics/:id', builder: (_,s)  =>
      ClinicDetailsScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/reports',     builder: (_,__) => const ReportsScreen()),
    GoRoute(path: '/staff',       builder: (_,__) => const StaffScreen()),

    // Shared
    GoRoute(path: '/appointments',     builder: (_,__) => const AppointmentsScreen()),
    GoRoute(path: '/appointments/:id', builder: (_,s)  =>
      AppointmentDetailsScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/queue',            builder: (_,__) => const WaitingQueueScreen()),
    GoRoute(path: '/patients',         builder: (_,__) => const PatientsScreen()),
    GoRoute(path: '/patients/:id',     builder: (_,s)  =>
      PatientDetailsScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/templates',        builder: (_,__) => const TemplatesScreen()),
    GoRoute(path: '/drugs',            builder: (_,__) => const DrugsScreen()),
    GoRoute(path: '/invoices',         builder: (_,__) => const InvoicesScreen()),
    GoRoute(path: '/expenses',         builder: (_,__) => const ExpensesScreen()),
    GoRoute(path: '/settings',         builder: (_,__) => const SettingsScreen()),
    GoRoute(path: '/settings/subscription',
      builder: (_,__) => const SubscriptionScreen()),
  ],
);
```
