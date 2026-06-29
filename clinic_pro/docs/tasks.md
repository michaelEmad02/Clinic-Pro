# ✅ tasks.md — Project Task Checklist

> Mark tasks as done by changing `[ ]` to `[x]`
> AI marks each task upon completion and stops at the end of each Phase for approval.

---

## Phase 1 — Project Setup & Core

### Part 1.1 — Flutter Project Init
- [x] Create Flutter project `clinic_pro`
- [x] Add all dependencies to `pubspec.yaml`
- [x] Configure fonts (Cairo, Inter) in pubspec
- [x] Setup folder structure (core/, features/)
- [x] Configure `analysis_options.yaml`

### Part 1.2 — Core Theme
- [x] `core/themes/app_colors.dart` — Light + Dark palettes
- [x] `core/themes/app_text_styles.dart` — Cairo + Inter styles
- [x] `core/themes/app_theme.dart` — ThemeData light + dark

### Part 1.3 — Core Constants & Utils
- [x] `core/constants/app_constants.dart` — spacing, radius
- [x] `core/constants/supabase_constants.dart` — table names + enums
- [x] `core/constants/route_constants.dart` — all route paths
- [x] `core/utils/queue_sorter.dart` — pure Dart queue sorting logic (no dependencies)

### Part 1.4 — Dependency Injection
- [x] `core/di/injection_container.dart` — getIt + injectable init
- [x] Register `MockCloudService` as `ICloudService`
- [x] Run `build_runner` — verify `injection_container.config.dart` generated

### Part 1.5 — Router
- [x] `core/router/app_router.dart` — all 26 routes defined
- [x] Role-based redirect logic
- [x] Deep link handler for `/join/:token`

### Part 1.6 — Shared Widgets
- [x] `core/widgets/app_list_item.dart`
- [x] `core/widgets/app_bottom_sheet.dart`
- [x] `core/widgets/status_badge.dart`
- [x] `core/widgets/empty_state.dart`
- [x] `core/widgets/shimmer_list.dart`
- [x] `core/widgets/dose_chip_selector.dart`
- [x] `core/widgets/summary_card.dart`
- [x] `core/widgets/realtime_indicator.dart`

### Part 1.7 — Mock Service & Data
- [x] `core/services/i_cloud_service.dart`
- [x] `core/services/mock_cloud_service.dart`
- [x] `core/mocks/mock_data.dart` — all static datasets

---

## Phase 2 — Auth & Onboarding UI

### Part 2.1 — Auth Screens
- [x] `features/auth/presentation/ui/splash_screen.dart` + widgets/
- [x] `features/auth/presentation/ui/login_screen.dart` + widgets/
- [x] `features/auth/presentation/ui/create_account_screen.dart` + widgets/
- [x] `features/auth/presentation/ui/accept_invitation_screen.dart` + widgets/

### Part 2.2 — Auth Cubit
- [x] `features/auth/presentation/manager/auth_cubit.dart`
- [x] `features/auth/presentation/manager/auth_state.dart`

### Part 2.3 — Onboarding Screens
- [x] `features/onboarding/presentation/ui/plan_screen.dart` + widgets/
- [x] `features/onboarding/presentation/ui/create_clinic_screen.dart` + widgets/
- [x] `features/onboarding/presentation/ui/invite_staff_screen.dart` + widgets/

### Part 2.4 — Onboarding Cubit
- [x] `features/onboarding/presentation/manager/onboarding_cubit.dart`
- [x] `features/onboarding/presentation/manager/onboarding_state.dart`

---

## Phase 3 — Dashboards UI
 
### Part 3.1 — Owner Dashboard
- [x] `features/dashboard/presentation/ui/owner_dashboard_screen.dart`
- [x] `features/dashboard/presentation/ui/widgets/dashboard_summary_row.dart`
- [x] `features/dashboard/presentation/ui/widgets/clinics_horizontal_scroll.dart`
- [x] `features/dashboard/presentation/ui/widgets/alerts_section.dart`
- [x] `features/dashboard/presentation/ui/widgets/revenue_bar_chart.dart`
- [x] `features/dashboard/presentation/ui/widgets/quick_actions_row.dart`
- [x] `features/dashboard/presentation/manager/owner_dashboard_cubit.dart`
- [x] `features/dashboard/presentation/manager/owner_dashboard_state.dart`
 
### Part 3.2 — Doctor Dashboard
- [x] `features/dashboard/presentation/ui/doctor_dashboard_screen.dart`
- [x] `features/dashboard/presentation/ui/widgets/current_patient_card.dart`
- [x] `features/dashboard/presentation/ui/widgets/waiting_queue_list.dart`
- [x] `features/dashboard/presentation/ui/widgets/doctor_stats_row.dart`
- [x] `features/dashboard/presentation/manager/doctor_dashboard_cubit.dart`
- [x] `features/dashboard/presentation/manager/doctor_dashboard_state.dart`
 
### Part 3.3 — Secretary Dashboard
- [x] `features/dashboard/presentation/ui/secretary_dashboard_screen.dart`
- [x] `features/dashboard/presentation/ui/widgets/live_queue_section.dart`
- [x] `features/dashboard/presentation/ui/widgets/today_appointments_list.dart`
- [x] `features/dashboard/presentation/ui/widgets/daily_summary_row.dart`
- [x] `features/dashboard/presentation/manager/secretary_dashboard_cubit.dart`
- [x] `features/dashboard/presentation/manager/secretary_dashboard_state.dart`

---

## Phase 4 — Appointments UI

### Part 4.1 — Appointments Screen
- [x] `features/appointments/presentation/ui/appointments_screen.dart`
- [x] `features/appointments/presentation/ui/widgets/appointments_tab_bar.dart`
- [x] `features/appointments/presentation/ui/widgets/appointments_list.dart`
- [x] `features/appointments/presentation/ui/widgets/appointment_list_item.dart`
- [x] `features/appointments/presentation/ui/widgets/appointment_action_sheet.dart`
- [x] `features/appointments/presentation/ui/widgets/add_appointment_sheet.dart`
- [x] `features/appointments/presentation/manager/appointments_bloc.dart`
- [x] `features/appointments/presentation/manager/appointments_event.dart`
- [x] `features/appointments/presentation/manager/appointments_state.dart`

### Part 4.2 — Appointment Details Screen
- [x] `features/appointments/presentation/ui/appointment_details_screen.dart`
- [x] `features/appointments/presentation/ui/widgets/appointment_header_card.dart`
- [x] `features/appointments/presentation/ui/widgets/appointment_status_timeline.dart`
- [x] `features/appointments/presentation/ui/widgets/linked_prescription_card.dart`
- [x] `features/appointments/presentation/ui/widgets/linked_invoice_card.dart`

### Part 4.3 — Waiting Queue Screen
- [x] `features/appointments/presentation/ui/waiting_queue_screen.dart`
- [x] `features/appointments/presentation/ui/widgets/queue_list.dart`
- [x] `features/appointments/presentation/ui/widgets/queue_item.dart`
- [x] `features/appointments/presentation/ui/widgets/call_next_button.dart`
- [x] `features/appointments/presentation/manager/waiting_queue_cubit.dart`
- [x] `features/appointments/presentation/manager/waiting_queue_state.dart`

---

## Phase 5 — Patients UI

### Part 5.1 — Patients Screen
- [x] `features/patients/presentation/ui/patients_screen.dart`
- [x] `features/patients/presentation/ui/widgets/patients_search_bar.dart`
- [x] `features/patients/presentation/ui/widgets/patients_filter_chips.dart`
- [x] `features/patients/presentation/ui/widgets/patients_list.dart`
- [x] `features/patients/presentation/ui/widgets/patient_list_item.dart`
- [x] `features/patients/presentation/ui/widgets/patient_action_sheet.dart`
- [x] `features/patients/presentation/ui/widgets/add_edit_patient_sheet.dart`
- [x] `features/patients/presentation/manager/patients_cubit.dart`
- [x] `features/patients/presentation/manager/patients_state.dart`

### Part 5.2 — Patient Details Screen
- [x] `features/patients/presentation/ui/patient_details_screen.dart`
- [x] `features/patients/presentation/ui/widgets/patient_sliver_app_bar.dart`
- [x] `features/patients/presentation/ui/widgets/patient_allergy_banner.dart`
- [x] `features/patients/presentation/ui/widgets/patient_info_tab.dart`
- [x] `features/patients/presentation/ui/widgets/patient_visits_tab.dart`
- [x] `features/patients/presentation/ui/widgets/patient_prescriptions_tab.dart`
- [x] `features/patients/presentation/ui/widgets/visit_timeline_item.dart`

---

## Phase 6 — Prescription UI

### Part 6.1 — Prescription Screen
- [ ] `features/prescription/presentation/ui/prescription_screen.dart`
- [ ] `features/prescription/presentation/ui/widgets/prescription_header_card.dart`
- [ ] `features/prescription/presentation/ui/widgets/diagnosis_chips_section.dart`
- [ ] `features/prescription/presentation/ui/widgets/drugs_list_section.dart`
- [ ] `features/prescription/presentation/ui/widgets/drug_dose_card.dart`
- [ ] `features/prescription/presentation/ui/widgets/prescription_notes_field.dart`
- [ ] `features/prescription/presentation/ui/widgets/prescription_bottom_actions_bar.dart`
- [ ] `features/prescription/presentation/ui/widgets/add_drug_search_sheet.dart`
- [ ] `features/prescription/presentation/manager/prescription_bloc.dart`
- [ ] `features/prescription/presentation/manager/prescription_event.dart`
- [ ] `features/prescription/presentation/manager/prescription_state.dart`
- [x] `features/prescription/presentation/ui/prescription_screen.dart`
- [x] `features/prescription/presentation/ui/widgets/prescription_header_card.dart`
- [x] `features/prescription/presentation/ui/widgets/diagnosis_chips_section.dart`
- [x] `features/prescription/presentation/ui/widgets/drugs_list_section.dart`
- [x] `features/prescription/presentation/ui/widgets/drug_dose_card.dart`
- [x] `features/prescription/presentation/ui/widgets/prescription_notes_field.dart`
- [x] `features/prescription/presentation/ui/widgets/prescription_bottom_actions_bar.dart`
- [x] `features/prescription/presentation/ui/widgets/add_drug_search_sheet.dart`
- [x] `features/prescription/presentation/manager/prescription_bloc.dart`
- [x] `features/prescription/presentation/manager/prescription_event.dart`
- [x] `features/prescription/presentation/manager/prescription_state.dart`

### Part 6.2 — Templates Screen
- [ ] `features/prescription/presentation/ui/templates_screen.dart`
- [ ] `features/prescription/presentation/ui/widgets/templates_list.dart`
- [ ] `features/prescription/presentation/ui/widgets/template_list_item.dart`
- [ ] `features/prescription/presentation/ui/widgets/template_action_sheet.dart`
- [ ] `features/prescription/presentation/ui/widgets/template_preview_dialog.dart`
- [ ] `features/prescription/presentation/ui/widgets/add_edit_template_sheet.dart`
- [ ] `features/prescription/presentation/manager/templates_cubit.dart`
- [ ] `features/prescription/presentation/manager/templates_state.dart`
- [x] `features/prescription/presentation/ui/templates_screen.dart`
- [x] `features/prescription/presentation/ui/widgets/templates_list.dart`
- [x] `features/prescription/presentation/ui/widgets/template_list_item.dart`
- [x] `features/prescription/presentation/ui/widgets/template_action_sheet.dart`
- [x] `features/prescription/presentation/ui/widgets/template_preview_dialog.dart`
- [x] `features/prescription/presentation/ui/widgets/add_edit_template_sheet.dart`
- [x] `features/prescription/presentation/manager/templates_cubit.dart`
- [x] `features/prescription/presentation/manager/templates_state.dart`

### Part 6.3 — Drugs Screen
- [ ] `features/prescription/presentation/ui/drugs_screen.dart`
- [ ] `features/prescription/presentation/ui/widgets/drugs_search_bar.dart`
- [ ] `features/prescription/presentation/ui/widgets/drugs_category_chips.dart`
- [ ] `features/prescription/presentation/ui/widgets/drugs_list.dart`
- [ ] `features/prescription/presentation/ui/widgets/drug_list_item.dart`
- [ ] `features/prescription/presentation/ui/widgets/drug_action_sheet.dart`
- [ ] `features/prescription/presentation/ui/widgets/add_edit_drug_sheet.dart`
- [ ] `features/prescription/presentation/manager/drugs_cubit.dart`
- [ ] `features/prescription/presentation/manager/drugs_state.dart`
- [x] `features/prescription/presentation/ui/drugs_screen.dart`
- [x] `features/prescription/presentation/ui/widgets/drugs_search_bar.dart`
- [x] `features/prescription/presentation/ui/widgets/drugs_category_chips.dart`
- [x] `features/prescription/presentation/ui/widgets/drugs_list.dart`
- [x] `features/prescription/presentation/ui/widgets/drug_list_item.dart`
- [x] `features/prescription/presentation/ui/widgets/drug_action_sheet.dart`
- [x] `features/prescription/presentation/ui/widgets/add_edit_drug_sheet.dart`
- [x] `features/prescription/presentation/manager/drugs_cubit.dart`
- [x] `features/prescription/presentation/manager/drugs_state.dart`

---

## Phase 7 — Financial UI

### Part 7.1 — Invoices Screen
- [ ] `features/invoices/presentation/ui/invoices_screen.dart`
- [ ] `features/invoices/presentation/ui/widgets/invoices_summary_bar.dart`
- [ ] `features/invoices/presentation/ui/widgets/invoices_filter_chips.dart`
- [ ] `features/invoices/presentation/ui/widgets/invoices_list.dart`
- [ ] `features/invoices/presentation/ui/widgets/invoice_list_item.dart`
- [ ] `features/invoices/presentation/ui/widgets/invoice_action_sheet.dart`
- [ ] `features/invoices/presentation/ui/widgets/add_invoice_sheet.dart`
- [ ] `features/invoices/presentation/manager/invoices_cubit.dart`
- [ ] `features/invoices/presentation/manager/invoices_state.dart`

### Part 7.2 — Expenses Screen
- [ ] `features/expenses/presentation/ui/expenses_screen.dart`
- [ ] `features/expenses/presentation/ui/widgets/expenses_category_chips.dart`
- [ ] `features/expenses/presentation/ui/widgets/expenses_total_card.dart`
- [ ] `features/expenses/presentation/ui/widgets/expenses_list.dart`
- [ ] `features/expenses/presentation/ui/widgets/expense_list_item.dart`
- [ ] `features/expenses/presentation/ui/widgets/expense_action_sheet.dart`
- [ ] `features/expenses/presentation/ui/widgets/add_edit_expense_sheet.dart`
- [ ] `features/expenses/presentation/manager/expenses_cubit.dart`
- [ ] `features/expenses/presentation/manager/expenses_state.dart`

### Part 7.3 — Reports Screen
- [ ] `features/reports/presentation/ui/reports_screen.dart`
- [ ] `features/reports/presentation/ui/widgets/reports_date_range_chips.dart`
- [ ] `features/reports/presentation/ui/widgets/reports_summary_grid.dart`
- [ ] `features/reports/presentation/ui/widgets/revenue_vs_expenses_chart.dart`
- [ ] `features/reports/presentation/ui/widgets/patients_count_chart.dart`
- [ ] `features/reports/presentation/ui/widgets/top_services_list.dart`
- [ ] `features/reports/presentation/ui/widgets/doctor_performance_list.dart`
- [ ] `features/reports/presentation/manager/reports_cubit.dart`
- [ ] `features/reports/presentation/manager/reports_state.dart`

---

## Phase 8 — Staff & Clinics UI

### Part 8.1 — Staff Screen
- [x] `features/staff/presentation/ui/staff_screen.dart`
- [x] `features/staff/presentation/ui/widgets/staff_filter_chips.dart`
- [x] `features/staff/presentation/ui/widgets/staff_list.dart`
- [x] `features/staff/presentation/ui/widgets/staff_list_item.dart`
- [x] `features/staff/presentation/ui/widgets/staff_action_sheet.dart`
- [x] `features/staff/presentation/ui/widgets/pending_invitations_section.dart`
- [x] `features/staff/presentation/ui/widgets/invite_staff_sheet.dart`
- [x] `features/staff/presentation/manager/staff_cubit.dart`
- [x] `features/staff/presentation/manager/staff_state.dart`

### Part 8.2 — Clinics Screen
- [x] `features/clinics/presentation/ui/clinics_screen.dart`
- [x] `features/clinics/presentation/ui/widgets/clinics_list.dart`
- [x] `features/clinics/presentation/ui/widgets/clinic_card.dart`
- [x] `features/clinics/presentation/ui/widgets/clinic_action_sheet.dart`
- [x] `features/clinics/presentation/ui/widgets/add_edit_clinic_sheet.dart`
- [x] `features/clinics/presentation/manager/clinics_cubit.dart`
- [x] `features/clinics/presentation/manager/clinics_state.dart`

### Part 8.3 — Clinic Details Screen
- [x] `features/clinics/presentation/ui/clinic_details_screen.dart`
- [x] `features/clinics/presentation/ui/widgets/clinic_details_header.dart`
- [x] `features/clinics/presentation/ui/widgets/clinic_summary_cards.dart`
- [x] `features/clinics/presentation/ui/widgets/clinic_working_hours_section.dart`
- [x] `features/clinics/presentation/ui/widgets/clinic_visit_types_section.dart`
- [x] `features/clinics/presentation/ui/widgets/clinic_staff_section.dart`

---

## Phase 9 — Settings UI

### Part 9.1 — Settings Screen
- [x] `features/settings/presentation/ui/settings_screen.dart`
- [x] `features/settings/presentation/ui/widgets/settings_account_section.dart`
- [x] `features/settings/presentation/ui/widgets/settings_clinic_section.dart`
- [x] `features/settings/presentation/ui/widgets/settings_owner_section.dart`
- [x] `features/settings/presentation/ui/widgets/settings_logout_section.dart`
- [x] `features/settings/presentation/ui/widgets/edit_profile_sheet.dart`
- [x] `features/settings/presentation/ui/widgets/clinic_picker_sheet.dart`
- [x] `features/settings/presentation/manager/settings_cubit.dart`
- [x] `features/settings/presentation/manager/settings_state.dart`

### Part 9.2 — Subscription Screen
- [x] `features/settings/presentation/ui/subscription_screen.dart`
- [x] `features/settings/presentation/ui/widgets/current_plan_card.dart`
- [x] `features/settings/presentation/ui/widgets/trial_countdown_card.dart`
- [x] `features/settings/presentation/ui/widgets/usage_progress_section.dart`
- [x] `features/settings/presentation/ui/widgets/upgrade_cta_button.dart`
- [x] `features/settings/presentation/ui/widgets/billing_history_list.dart`

---

## Phase 10 — Supabase Integration

### Part 10.1 — Cloud Service
- [ ] `core/services/supabase_service.dart` — full implementation
- [ ] Switch DI: `MockCloudService` → `SupabaseService`
- [ ] Test all queries against real Supabase project

### Part 10.2 — Auth Integration
- [ ] Google Sign-In
- [ ] Apple Sign-In
- [ ] Magic Link
- [ ] Invitation deep link
- [ ] Session persistence

### Part 10.3 — Feature Data Integration

#### Auth Feature
- [ ] Auth — Domain Layer: entities + repository interface + usecases
- [ ] Auth — Data Layer: models + data source (SupabaseService calls) + repository impl

#### Owners Feature
- [ ] Owners — Domain Layer: entity + repository interface + usecases (getOwner, createOwner)
- [ ] Owners — Data Layer: model + data source + repository impl

#### Clinics Feature
- [ ] Clinics — Domain Layer: entity + repository interface + usecases (getClinics, createClinic, updateClinic)
- [ ] Clinics — Data Layer: model + data source + repository impl

#### Staff & Invitations Feature
- [ ] Staff — Domain Layer: entity + repository interface + usecases (getStaff, inviteStaff, updateRole, suspendStaff)
- [ ] Staff — Data Layer: model + data source + repository impl
- [ ] Invitations — Domain Layer: entity + repository interface + usecases (sendInvitation, acceptInvitation)
- [ ] Invitations — Data Layer: model + data source + repository impl

#### Patients Feature
- [ ] Patients — Domain Layer: entity + repository interface + usecases (getPatients, getPatient, addPatient, updatePatient)
- [ ] Patients — Data Layer: model + data source + repository impl

#### Drugs Feature
- [ ] Drugs — Domain Layer: entity + repository interface + usecases (searchDrugs, addDrug, updateDrug)
- [ ] Drugs — Data Layer: model + data source + repository impl

#### Prescription Templates Feature
- [ ] Templates — Domain Layer: entity + repository interface + usecases (getTemplates, addTemplate, updateTemplate, deleteTemplate, incrementUseCount)
- [ ] Templates — Data Layer: model + data source + repository impl

#### Appointments Feature
- [ ] AppointmentTypes — Domain Layer: entity + repository interface + usecases (getTypes, addType, updateType, deleteType)
- [ ] AppointmentTypes — Data Layer: model + data source + repository impl
- [ ] Appointments — Domain Layer: entity + repository interface + usecases (getAppointments, addAppointment, updateStatus, cancelAppointment, confirmArrival, callPatient, toggleUrgent)
- [ ] Appointments — Data Layer: model + data source + repository impl
- [ ] Appointments — Realtime subscription wired to AppointmentsBloc (triggers queue re-sort)

#### Queue Feature
- [ ] DoctorQueueRules — Domain Layer: entity + repository interface + usecases (getQueueRule, saveQueueRule)
- [ ] DoctorQueueRules — Data Layer: model + data source + repository impl
- [ ] QueueSorter — core/utils/queue_sorter.dart (pure Dart — no DB, no DI)
- [ ] WaitingQueueCubit — wires appointments Realtime → QueueSorter → emits sorted list

#### Prescriptions Feature
- [ ] Prescriptions — Domain Layer: entity + repository interface + usecases (savePrescription, getPrescriptions, getPatientPrescriptions)
- [ ] Prescriptions — Data Layer: model + data source + repository impl (transaction: prescription + items)
- [ ] PrescriptionDocs — Data Layer: upload to Supabase Storage + save doc_url

#### Invoices Feature
- [ ] Invoices — Domain Layer: entity + repository interface + usecases (getInvoices, createInvoice, updatePaidAmount)
- [ ] Invoices — Data Layer: model + data source + repository impl

#### Expenses Feature
- [ ] ExpenseCategories — Domain Layer: entity + repository interface + usecase (getCategories)
- [ ] ExpenseCategories — Data Layer: model + data source + repository impl
- [ ] Expenses — Domain Layer: entity + repository interface + usecases (getExpenses, addExpense, updateExpense, deleteExpense)
- [ ] Expenses — Data Layer: model + data source + repository impl

#### Plans & Subscriptions Feature
- [ ] Plans — Domain Layer: entity + repository interface + usecases (getPlans, getPlanFeatures)
- [ ] Plans — Data Layer: model + data source + repository impl
- [ ] Subscriptions — Domain Layer: entity + repository interface + usecases (getSubscription, createSubscription, cancelSubscription)
- [ ] Subscriptions — Data Layer: model + data source + repository impl

#### Reports Feature
- [ ] Reports — Domain Layer: entity + repository interface + usecases (getRevenueSummary, getExpensesSummary, getDoctorPerformance, getTopServices)
- [ ] Reports — Data Layer: data source + repository impl (Supabase aggregate queries)

### Part 10.4 — Realtime
- [ ] Appointments channel
- [ ] Patients channel
- [ ] Prescriptions channel
- [ ] Disconnection handling

### Part 10.5 — Storage
- [ ] Clinic logo upload/display
- [ ] User avatar upload/display
- [ ] Prescription doc upload/display

---

## Phase 11 — Testing & Polish

### Part 11.1 — Unit Tests
- [ ] All UseCases
- [ ] All Cubits/Blocs
- [ ] Repository implementations

### Part 11.2 — Widget Tests
- [ ] AppListItem
- [ ] StatusBadge
- [ ] DoseChipSelector
- [ ] PrescriptionScreen
- [ ] AppointmentsScreen

### Part 11.3 — Polish
- [ ] Screen transitions and animations
- [ ] Error states for all screens
- [ ] Offline banner widget
- [ ] Performance audit (const, ListView.builder, buildWhen)

### Part 11.4 — Localization
- [ ] Extract all strings to `app_ar.arb`
- [ ] Create `app_en.arb`
- [ ] Test RTL/LTR switching
