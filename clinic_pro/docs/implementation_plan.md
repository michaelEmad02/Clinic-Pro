# ⚙️ implementation_plan.md — Development Plan

---

## Overview

- **Approach:** UI First — full UI with mock data before any Supabase integration
- **Phase control:** AI stops after each phase, shows summary, waits for approval
- **Task tracking:** see `tasks.md` for the live checklist

---

## Phases Overview

```
Phase 1 — Project Setup & Core
Phase 2 — Auth & Onboarding UI
Phase 3 — Dashboards UI
Phase 4 — Appointments UI
Phase 5 — Patients UI
Phase 6 — Prescription UI (most complex)
Phase 7 — Financial UI (Invoices + Expenses + Reports)
Phase 8 — Staff & Clinics UI
Phase 9 — Settings UI
Phase 10 — Supabase Integration
Phase 11 — Testing & Polish
```

---

## Phase 1 — Project Setup & Core

**Goal:** establish the full skeleton before any feature work.

### Part 1.1 — Flutter Project Init
- Create Flutter project with name `clinic_pro`
- Add all dependencies to `pubspec.yaml`
- Configure assets (fonts, images)
- Setup folder structure (`core/`, `features/`)

### Part 1.2 — Core Theme
- `app_colors.dart` — full Light + Dark color palette
- `app_text_styles.dart` — Cairo + Inter text styles
- `app_theme.dart` — ThemeData for light and dark

### Part 1.3 — Core Constants
- `app_constants.dart` — spacing, radius
- `supabase_constants.dart` — table names, status enums
- `route_constants.dart` — all route paths as constants

### Part 1.4 — Dependency Injection Setup
- `injection_container.dart` — getIt + injectable setup
- Register `MockCloudService` as `ICloudService` (active during UI phase)
- Register core services

### Part 1.5 — Router Setup
- `app_router.dart` — GoRouter with all 26 routes defined
- Role-based redirect logic
- Deep link for `/join/:token`

### Part 1.6 — Shared Widgets
- `app_list_item.dart`
- `app_bottom_sheet.dart`
- `status_badge.dart`
- `empty_state.dart`
- `shimmer_list.dart`
- `dose_chip_selector.dart`
- `summary_card.dart`
- `realtime_indicator.dart`

### Part 1.7 — Mock Service & Mock Data
- `i_cloud_service.dart` — abstract interface
- `mock_cloud_service.dart` — returns static raw data
- `mock_data.dart` — all static data sets (appointments, patients, drugs, etc.)

---

## Phase 2 — Auth & Onboarding UI

**Goal:** build all auth and onboarding screens with mock data.

### Part 2.1 — Auth Screens
- `splash_screen.dart` + subwidgets
- `login_screen.dart` + subwidgets
- `create_account_screen.dart` + subwidgets
- `accept_invitation_screen.dart` + subwidgets

### Part 2.2 — Auth Cubit
- `auth_cubit.dart` + `auth_state.dart`
- Mock: simulate login success/failure
- Role detection logic (mock returns Owner by default)

### Part 2.3 — Onboarding Screens
- `plan_screen.dart` + subwidgets
- `create_clinic_screen.dart` + subwidgets (includes "are you a doctor?" toggle)
- `invite_staff_screen.dart` + subwidgets

### Part 2.4 — Onboarding Cubit
- `onboarding_cubit.dart` + `onboarding_state.dart`
- Mock: simulate clinic creation, invitation sending

---

## Phase 3 — Dashboards UI

**Goal:** build all 3 role dashboards with mock data.

### Part 3.1 — Owner Dashboard
- `owner_dashboard_screen.dart` + subwidgets:
  - `dashboard_summary_row.dart`
  - `clinics_horizontal_scroll.dart`
  - `alerts_section.dart`
  - `revenue_bar_chart.dart`
  - `quick_actions_row.dart`
- `owner_dashboard_cubit.dart` + state

### Part 3.2 — Doctor Dashboard
- `doctor_dashboard_screen.dart` + subwidgets:
  - `current_patient_card.dart`
  - `waiting_queue_list.dart`
  - `doctor_stats_row.dart`
- `doctor_dashboard_cubit.dart` + state

### Part 3.3 — Secretary Dashboard
- `secretary_dashboard_screen.dart` + subwidgets:
  - `live_queue_section.dart`
  - `today_appointments_list.dart`
  - `quick_actions_row.dart`
  - `daily_summary_row.dart`
- `secretary_dashboard_cubit.dart` + state

---

## Phase 4 — Appointments UI

### Part 4.1 — Appointments Screen
- `appointments_screen.dart` + subwidgets:
  - `appointments_tab_bar.dart`
  - `appointments_list.dart`
  - `appointment_list_item.dart`
  - `appointment_action_sheet.dart`
  - `add_appointment_sheet.dart`
- `appointments_bloc.dart` + `appointments_event.dart` + `appointments_state.dart`

### Part 4.2 — Appointment Details Screen
- `appointment_details_screen.dart` + subwidgets:
  - `appointment_header_card.dart`
  - `appointment_status_timeline.dart`
  - `linked_prescription_card.dart`
  - `linked_invoice_card.dart`

### Part 4.3 — Waiting Queue Screen
- `waiting_queue_screen.dart` + subwidgets:
  - `queue_list.dart`
  - `queue_item.dart`
  - `call_next_button.dart`
- `waiting_queue_cubit.dart` + state

---

## Phase 5 — Patients UI

### Part 5.1 — Patients Screen
- `patients_screen.dart` + subwidgets:
  - `patients_search_bar.dart`
  - `patients_filter_chips.dart`
  - `patients_list.dart`
  - `patient_list_item.dart`
  - `patient_action_sheet.dart`
  - `add_edit_patient_sheet.dart`
- `patients_cubit.dart` + state

### Part 5.2 — Patient Details Screen
- `patient_details_screen.dart` + subwidgets:
  - `patient_sliver_app_bar.dart`
  - `patient_allergy_banner.dart`
  - `patient_info_tab.dart`
  - `patient_visits_tab.dart`
  - `patient_prescriptions_tab.dart`
  - `visit_timeline_item.dart`

---

## Phase 6 — Prescription UI (Most Complex)

### Part 6.1 — Prescription Screen
- `prescription_screen.dart` + subwidgets:
  - `prescription_header_card.dart`
  - `diagnosis_chips_section.dart`
  - `drugs_list_section.dart`
  - `drug_dose_card.dart` (contains DoseChipSelector)
  - `prescription_notes_field.dart`
  - `prescription_bottom_actions_bar.dart`
  - `add_drug_search_sheet.dart`
- `prescription_bloc.dart` + events + states

### Part 6.2 — Templates Screen
- `templates_screen.dart` + subwidgets:
  - `templates_list.dart`
  - `template_list_item.dart`
  - `template_action_sheet.dart`
  - `template_preview_dialog.dart`
  - `add_edit_template_sheet.dart`
- `templates_cubit.dart` + state

### Part 6.3 — Drugs Screen
- `drugs_screen.dart` + subwidgets:
  - `drugs_search_bar.dart`
  - `drugs_category_chips.dart`
  - `drugs_list.dart`
  - `drug_list_item.dart`
  - `drug_action_sheet.dart`
  - `add_edit_drug_sheet.dart`
- `drugs_cubit.dart` + state

---

## Phase 7 — Financial UI

### Part 7.1 — Invoices Screen
- `invoices_screen.dart` + subwidgets:
  - `invoices_summary_bar.dart`
  - `invoices_filter_chips.dart`
  - `invoices_list.dart`
  - `invoice_list_item.dart`
  - `invoice_action_sheet.dart`
  - `add_invoice_sheet.dart`
- `invoices_cubit.dart` + state

### Part 7.2 — Expenses Screen
- `expenses_screen.dart` + subwidgets:
  - `expenses_category_chips.dart`
  - `expenses_total_card.dart`
  - `expenses_list.dart`
  - `expense_list_item.dart`
  - `expense_action_sheet.dart`
  - `add_edit_expense_sheet.dart`
- `expenses_cubit.dart` + state

### Part 7.3 — Reports Screen
- `reports_screen.dart` + subwidgets:
  - `reports_date_range_chips.dart`
  - `reports_summary_grid.dart`
  - `revenue_vs_expenses_chart.dart`
  - `patients_count_chart.dart`
  - `top_services_list.dart`
  - `doctor_performance_list.dart`
- `reports_cubit.dart` + state

---

## Phase 8 — Staff & Clinics UI

### Part 8.1 — Staff Screen
- `staff_screen.dart` + subwidgets:
  - `staff_filter_chips.dart`
  - `staff_list.dart`
  - `staff_list_item.dart`
  - `staff_action_sheet.dart`
  - `pending_invitations_section.dart`
  - `invite_staff_sheet.dart`
- `staff_cubit.dart` + state

### Part 8.2 — Clinics Screen
- `clinics_screen.dart` + subwidgets:
  - `clinics_list.dart`
  - `clinic_card.dart`
  - `clinic_action_sheet.dart`
  - `add_edit_clinic_sheet.dart`
- `clinics_cubit.dart` + state

### Part 8.3 — Clinic Details Screen
- `clinic_details_screen.dart` + subwidgets:
  - `clinic_details_header.dart`
  - `clinic_summary_cards.dart`
  - `clinic_working_hours_section.dart`
  - `clinic_visit_types_section.dart`
  - `clinic_staff_section.dart`

---

## Phase 9 — Settings UI

### Part 9.1 — Settings Screen
- `settings_screen.dart` + subwidgets:
  - `settings_account_section.dart`
  - `settings_clinic_section.dart`
  - `settings_owner_section.dart`
  - `settings_logout_section.dart`
  - `edit_profile_sheet.dart`
  - `clinic_picker_sheet.dart`
- `settings_cubit.dart` + state

### Part 9.2 — Subscription Screen
- `subscription_screen.dart` + subwidgets:
  - `current_plan_card.dart`
  - `trial_countdown_card.dart`
  - `usage_progress_section.dart`
  - `upgrade_cta_button.dart`
  - `billing_history_list.dart`

---

## Phase 10 — Supabase Integration

**Goal:** replace MockCloudService with real SupabaseService — no UI changes.

### Part 10.1 — Cloud Service Implementation
- `supabase_service.dart` — full ICloudService implementation
- Switch DI registration: `MockCloudService` → `SupabaseService`
- Test all queries against real database

### Part 10.2 — Auth Integration
- Real Google + Apple sign-in
- Magic Link flow
- Invitation accept flow (deep link handling)
- Session persistence

### Part 10.3 — Feature Integration (per feature)
- Owners, Users, Clinics, Staff
- Patients
- Drugs, Templates
- Appointments
- Prescriptions
- Invoices, Expenses
- Reports

### Part 10.4 — Realtime Integration
- Appointments channel
- Patients channel
- Prescriptions channel
- Handle disconnection gracefully

### Part 10.5 — Storage Integration
- Clinic logo upload
- User avatar upload
- Prescription doc upload

---

## Phase 11 — Testing & Polish

### Part 11.1 — Unit Tests
- All UseCases
- All Cubits/Blocs
- All Repository implementations (with mock data source)

### Part 11.2 — Widget Tests
- Shared widgets (AppListItem, StatusBadge, DoseChipSelector)
- Critical screens (PrescriptionScreen, AppointmentsScreen)

### Part 11.3 — Polish
- Animations and transitions
- Error states refinement
- Loading states refinement
- Offline banner
- Performance audit (const constructors, ListView.builder, buildWhen)

### Part 11.4 — Localization
- Extract all Arabic strings to `app_ar.arb`
- Add English translations to `app_en.arb`
- Test RTL/LTR switching

---

## AI Phase Control Protocol

```
At the end of each Phase:

✅ Phase [N] Complete
────────────────────────────────
Done:
  ✓ Part N.1 — [name]
  ✓ Part N.2 — [name]
  ...

Files created:
  • path/to/file1.dart
  • path/to/file2.dart
  ...
────────────────────────────────
Ready to proceed to Phase [N+1]: [Phase Name]?
(Reply: yes / adjustments needed)
```
