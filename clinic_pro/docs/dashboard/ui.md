# ui.md — Dashboard (Composite Screen)

> This is a **composite feature** — it has no dedicated DB tables.
> Each dashboard variant aggregates data from multiple features.
> No `schema.md` or `business_logic.md` exists here — refer to the source
> features listed below for all data rules.

---

## Source Features Used (per dashboard variant)

| Section | Data From | Tables Touched |
|---------|-----------|-----------------|
| Summary cards (patients/appointments/revenue) | `patients/`, `appointments_queue/`, `financial/` | `patients`, `appointments`, `invoices` |
| Clinic list (Owner only) | `clinics_staff/` | `clinics` |
| Current patient / queue preview | `appointments_queue/` | `appointments`, `doctor_queue_rules` |
| Daily revenue (Secretary) | `financial/` | `invoices` |
| Alerts (subscription expiry) | `subscriptions/` | `subscriptions` |

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|
| Owner Dashboard | `/owner/dashboard` | Owner |
| Doctor Dashboard | `/doctor/dashboard` | Doctor |
| Secretary Dashboard | `/secretary/dashboard` | Secretary |

---

## Owner Dashboard

```
Header: user name + current clinic name
Summary cards (horizontal): 
  patients count   ← from patients/ (owner-scoped query)
  appointments today ← from appointments_queue/
  revenue this month ← from financial/ (invoices.paid_amount sum)

Clinic cards (horizontal scroll): per-clinic mini stats
  ← from clinics_staff/ + aggregated patients/appointments/financial counts

Alerts section:
  "اشتراكك ينتهي خلال X أيام" ← from subscriptions/ (end_at check)

Revenue bar chart (7 days) ← from financial/
Quick actions: إضافة عيادة (clinics_staff/) | إضافة موظف (clinics_staff/)
```

---

## Doctor Dashboard

```
Header: "صباح الخير، دكتور [اسم]" + date

Current Patient card (prominent):
  ← from appointments_queue/ — next entry in QueueSorter.sort() result
  Button: "تأكيد الكشف" → navigates to prescriptions/ui.md Prescription screen

Queue preview list (Realtime):
  ← from appointments_queue/ — same QueueSorter logic as Waiting Queue screen
  (shows top 3-5 entries only — full list lives at /queue)

Stats row: today's patient count, avg consultation time, attendance rate
  ← computed from appointments_queue/ data
```

---

## Secretary Dashboard

```
Live queue section (prominent) ← from appointments_queue/ (same as above)
Today's appointments list ← from appointments_queue/
Quick actions: تأكيد حضور | إضافة موعد | تحصيل دفعة
  ← appointments_queue/ (confirm arrival) + financial/ (collect payment)

Daily financial summary: revenue today, pending invoices count
  ← from financial/
```

---

## State Management Note

```
Each dashboard variant has its OWN Cubit that aggregates calls to
multiple UseCases from different feature domains:

lib/features/dashboard/
├── presentation/
│   ├── manager/
│   │   ├── owner_dashboard_cubit.dart       ← calls UseCases from:
│   │   │                                        clinics_staff, patients,
│   │   │                                        appointments_queue, financial,
│   │   │                                        subscriptions
│   │   ├── doctor_dashboard_cubit.dart      ← calls UseCases from:
│   │   │                                        appointments_queue
│   │   └── secretary_dashboard_cubit.dart   ← calls UseCases from:
│   │                                            appointments_queue, financial
│   └── ui/
│       ├── owner_dashboard_screen.dart
│       ├── doctor_dashboard_screen.dart
│       └── secretary_dashboard_screen.dart

# No data/ or domain/ folders — dashboard has no own entities/repositories.
# Each dashboard Cubit is a pure aggregator over existing feature UseCases.
```

---

## Realtime Note

```
Doctor and Secretary dashboards both subscribe to the same Realtime
channel as the Waiting Queue screen (appointments_queue/business_logic.md).
Avoid duplicate subscriptions if user navigates between Dashboard and
Queue screens — consider a shared subscription manager at the app level.
```

---

## Design Tokens
See `architecture.md` → Design System section.
