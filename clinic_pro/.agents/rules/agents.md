---
trigger: always_on
---

# AGENTS.md — ClinicPro Project Context

## What is this project?
**ClinicPro** — a multi-tenant SaaS Flutter app for managing medical clinics. for more info read file : docs/product.md
Roles: Owner / Doctor / Secretary.
Backend: Supabase (Auth + DB + Realtime + Storage).

---

## Critical Rules (read before anything)

- **Plan first, implement second.** Present a plan and wait for approval before writing any code.
- **UI First approach.** All screens are built with mock data before Supabase integration.
- **Never use `setState`** except for animations or forced lifecycle edge cases.
- **Never put all screen code in one file.** Split into subwidgets in separate files.
- **Never hardcode colors or text styles.** Always use `AppColors` and `AppTextStyles`.
- **Never call Supabase from UI or Cubit.** Flow: UI → UseCase → Repository → DataSource → ICloudService.
- **Mock data goes in `MockCloudService`**, not in widgets or screens.
- **Treat it as real data—meaning you must fully simulate the data usage—because the design is indifferent to the data's source. This is an advantage of clean arch , solid principles . for example : in patients list screen , if user click on add patient , and save , should add the new user to the list , update the list , and update the total number of patients . and if user search for a patient , should return the search results . and so on . so the mock data should implement the same interface of the real data source , so we can switch between mock and real data source without affecting the UI or business logic .
- **Widget file > 200 lines → split it.**
- **Comment every non-obvious block in Arabic** (English technical terms allowed).
- **After each Phase, stop and wait for approval** before moving to the next.

---

## Architecture — Clean Architecture + Supabase

```
Presentation (Cubit/Bloc + UI + SubWidgets)
     ↓
Domain (Entities + UseCases + Repo Interfaces)
     ↓
Data (Models + DataSources + Repo Implementations)
     ↓
ICloudService → SupabaseService (real) | MockCloudService (UI phase)
```

**State management:** Cubit (simple) / Bloc (complex events)
**DI:** getIt + injectable
**Routing:** GoRouter
**Principles:** SOLID, single responsibility, dependency inversion , dependancy injection

---

## Tech Stack

| | |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Supabase |
| State | Bloc / Cubit |
| DI | getIt + injectable |
| Router | GoRouter |
| Icons | flutter_tabler_icons |
| Fonts | Cairo (Arabic) + Inter (numbers) |
| Themes | Light + Dark (system-aware) |

---

## Folder Structure

```
lib/
├── core/
│   ├── themes/        app_colors.dart, app_text_styles.dart, app_theme.dart
│   ├── constants/     app_constants.dart, supabase_constants.dart, route_constants.dart
│   ├── di/            injection_container.dart
│   ├── router/        app_router.dart
│   ├── services/      i_cloud_service.dart, supabase_service.dart, mock_cloud_service.dart
│   ├── error/         failures.dart, exceptions.dart
│   └── widgets/       app_list_item, app_bottom_sheet, status_badge, empty_state,
│                      shimmer_list, dose_chip_selector, summary_card, realtime_indicator
└── features/
    └── [feature]/
        ├── data/       data_sources/, models/, repositories/
        ├── domain/     entities/, repositories/, usecases/
        └── presentation/
            ├── manager/   cubit/bloc + state
            └── ui/        screen.dart + widgets/
```

---

## Documentation Map (Reference Files )— Feature-Based (READ ONLY WHAT YOU NEED)

Each feature folder contains 3 focused files. **Only read the feature folder
relevant to your current task** — do not load all features into context at once.

```
docs/
├── rules.md                   ← always read this before writing code
├── architecture.md            ← read when creating new modules/files
├── product.md                 ← read when scope is unclear
├── implementation_plan.md     ← read when starting a new Phase
├── tasks.md                   ← read to check current task / mark done
│
└── features/
    ├── auth/
    │   ├── schema.md          ← Owners, users tables
    │   ├── business_logic.md  ← login flow, session detection
    │   └── ui.md               ← Splash, Login, Create Account, Accept Invitation
    │
    ├── clinics_staff/
    │   ├── schema.md          ← clinics, clinic_staff, invitations (not yet in DB)
    │   ├── business_logic.md  ← invitation flow, permissions
    │   └── ui.md               ← Clinics, Staff, Settings (3 role variants)
    │
    ├── patients/
    │   ├── schema.md          ← patients table
    │   ├── business_logic.md  ← owner-scoping, validations
    │   └── ui.md               ← Patients, Patient Details
    │
    ├── appointments_queue/
    │   ├── schema.md          ← appointment_types, appointments, doctor_queue_rules
    │   ├── business_logic.md  ← status flow, QueueSorter algorithm
    │   └── ui.md               ← Appointments, Appointment Details, Waiting Queue
    │
    ├── prescriptions/
    │   ├── schema.md          ← drugs, templates, prescriptions, prescription_items
    │   ├── business_logic.md  ← diagnosis-as-text rule, save flow
    │   └── ui.md               ← Prescription, Templates, Drugs screens
    │
    ├── financial/
    │   ├── schema.md          ← invoices, expenses, expense_categories
    │   ├── business_logic.md  ← manual invoice creation, status derivation
    │   └── ui.md               ← Invoices, Expenses, Reports
    │
    └── subscriptions/
        ├── schema.md          ← plans, plans_features, subscriptions
        ├── business_logic.md  ← limit enforcement, trial logic
        └── ui.md               ← Plan Selection, Subscription screen
```

---

## Current Phase

> **Check `docs/tasks.md` for the current task and phase.**
> Mark tasks `[✓]` as they are completed.

**Queue system (important):**
- No separate queue table — queue is derived from `appointments`
- Queue = appointments WHERE `arrived_at IS NOT NULL` AND `date = today`
- Sorting logic lives in `core/utils/queue_sorter.dart` (pure Dart)
- `is_urgent = true` → always first | pattern from `doctor_queue_rules`
- Realtime on `appointments` table triggers queue re-sort in Flutter


**Development order:**
Phase 1 Core → Phase 2 Auth → Phase 3 Onboarding → Phase 4 Dashboards →
Phase 5 Appointments → Phase 6 Patients → Phase 7 Prescription →
Phase 8 Financial → Phase 9 Staff & Clinics → Phase 10 Settings →
Phase 11 Supabase Integration → Phase 12 Testing

---

## Key Design Tokens

```dart
// Colors
primary:      Color(0xFF1A6B8A)
primaryDark:  Color(0xFF00526D)
primaryLight: Color(0xFFEAF4F8)
accent:       Color(0xFF2ECC9A)
warning:      Color(0xFFF5A623)
danger:       Color(0xFFE84C4C)
background:   Color(0xFFF7F9FC)
surface:      Color(0xFFFFFFFF)
border:       Color(0xFFE2E8F0)
textPrimary:  Color(0xFF1A202C)

// Radius
card: 16 | button: 12 | chip: 20 | input: 10 | sheet: 24

// Fonts
Arabic text → Cairo | Numbers/amounts → Inter Bold
```

---

## Stitch Design File

**Use Stitch MCP to design the app
** The name of the project in Stitch is "ClinicPro"


---