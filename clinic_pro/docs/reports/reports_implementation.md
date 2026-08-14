# Reports Feature — Implementation Spec & Current Architecture

## Overview & System Architecture

The **Reports & Statistics Module** in **ClinicPro** is designed following strict **Clean Architecture** principles and multi-tenant scoping. It provides comprehensive financial, operational, and clinical analytics for clinic owners and individual doctors.

---

## 🏗️ Architecture & Component Hierarchy

### 1. Presentation & Navigation Layout
- **Main Category Hub (`ReportsScreen`)**:
  - Displays a grid/list of report categories:
    1. Financial Reports
    2. Appointment Reports
    3. Patient Reports
    4. Doctor Performance Reports (Exclusive to Clinic Owners)
    5. Prescription & Drug Reports
- **Doctor My Reports Hub (`DoctorMyReportsScreen`)**:
  - Accessible via Doctor Dashboard Quick Actions or Navigation.
  - Allows doctors to view their personal reports (Financial, Appointments, Patients, Drugs) pre-filtered by their `doctorId`.
- **Reusable Dedicated Report Screens**:
  - `FinancialReportsScreen`: Revenue, collected, expenses, and net profit.
  - `AppointmentReportsScreen`: Attendance, wait times, no-shows, peak hours/days.
  - `PatientReportsScreen`: Demographic breakdown, new vs returning ratio, visit frequency, avg spend/LTV, inactive list.
  - `DoctorReportsScreen`: Doctor performance comparison (revenue, visits, rating, trend) with clinic filter.
  - `DrugReportsScreen`: Top prescribed drugs and prescription statistics.

---

## 📁 File Structure

```
lib/features/reports/
├── data/
│   ├── datasources/
│   │   ├── i_reports_remote_data_source.dart
│   │   └── reports_remote_data_source_impl.dart
│   ├── models/
│   │   ├── revenue_summary_model.dart
│   │   ├── appointment_stats_model.dart
│   │   ├── doctor_performance_model.dart
│   │   ├── drug_stats_model.dart
│   │   └── patient_stats_model.dart
│   └── repositories/
│       └── reports_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── reports_entities.dart
│   ├── repositories/
│   │   └── i_reports_repository.dart
│   └── usecases/
│       ├── get_revenue_summary_usecase.dart
│       ├── get_appointment_stats_usecase.dart
│       ├── get_doctor_performance_usecase.dart
│       ├── get_drug_stats_usecase.dart
│       └── get_patient_stats_usecase.dart
└── presentation/
    ├── manager/
    │   ├── financial_reports_cubit.dart
    │   ├── appointment_reports_cubit.dart
    │   ├── patient_reports_cubit.dart
    │   ├── doctor_performance_cubit.dart
    │   ├── drug_reports_cubit.dart
    │   └── doctor_my_reports_cubit.dart
    └── ui/
        ├── reports_screen.dart
        ├── doctor_my_reports_screen.dart
        ├── financial_reports_screen.dart
        ├── appointment_reports_screen.dart
        ├── patient_reports_screen.dart
        ├── doctor_reports_screen.dart
        ├── drug_reports_screen.dart
        └── widgets/
            ├── reports_date_range_chips.dart
            ├── reports_summary_grid.dart
            ├── revenue_vs_expenses_chart.dart
            ├── expenses_chart.dart
            ├── appointment_stats_section.dart
            ├── patient_stats_section.dart
            ├── doctor_performance_list.dart
            └── drug_stats_section.dart
```

---

## ⚡ Multi-Cubit State Management

Unlike a single monolithic Cubit, each report module utilizes a dedicated **BLoC/Cubit** to ensure modularity, independent state reloading, and isolated error boundaries:

- `FinancialReportsCubit`: Handles `RevenueSummaryEntity` loading, date range switching, and clinic filtering.
- `AppointmentReportsCubit`: Manages `AppointmentStatsEntity` with attendance rates and peak metrics.
- `PatientReportsCubit`: Processes `PatientStatsEntity`, age/gender distributions, visit frequency, and inactive patient lists.
- `DoctorPerformanceCubit`: Handles owner-level performance comparison across clinic doctors.
- `DrugReportsCubit`: Manages `DrugStatsEntity` and top prescribed drugs.
- `DoctorMyReportsCubit`: Aggregates quick statistics for the Doctor My Reports dashboard.

---

## 🏥 Clinic & Doctor Filtering Rules

1. **Clinic Filter (`clinicId`)**:
   - Integrated across all report screens (`Financial`, `Appointment`, `Patient`, `Doctor Performance`, `Drug`).
   - Powered by `ClinicsCubit.fetchClinics(userId)` using `FetchClinicsUseCase`.
   - Automatically queries clinics where the user is an **Owner** or a **Staff Member (Doctor)**.
   - Automatically hides the dropdown if the user only belongs to a single clinic.

2. **Doctor Scoping (`doctorId`)**:
   - Passed to report screens when navigating from "Doctor My Reports".
   - Filters appointments, patients, and drug statistics by `doctorId`.
   - Filters financial invoices by matching invoice `sourceId` against doctor appointment IDs.

---

## 📊 Detailed Metrics & Data Points

### 1. Financial Reports (`FinancialReportsScreen`)
- **Total Revenue & Collected Amount**: Total invoiced revenue vs. actual cash collected.
- **Expenses & Net Profit**: Categorized expenses and net operating margin.
- **Revenue vs Expenses Chart**: Bar/Line chart comparing earnings vs operational costs over time.
- **Expenses Breakdown Chart**: Donut style distribution of clinic expenditures.

### 2. Appointment Reports (`AppointmentReportsScreen`)
- **Total, Completed & Cancelled Appointments**.
- **Attendance Rate & No-Show Rate**: Percentage of patients showing up vs no-shows.
- **Average Wait Time**: Time elapsed from arrival (`arrivedAt`) to consultation (`calledAt`).
- **Urgent Cases Percentage**: Ratio of emergency/urgent walk-ins.
- **Peak Hours & Peak Days Charts**: Busiest times of day and days of week for clinic capacity optimization.

### 3. Patient Reports (`PatientReportsScreen`)
- **Demographic Distribution**: Gender split (Male/Female) & Age groups (`0-18`, `19-35`, `36-50`, `51-65`, `65+`).
- **New vs. Returning Patients**: Comparison ratio between first-time patients (🆕) and returning patients (🔄).
- **Average Visits per Patient**: Frequency metric (`total visits / total patients`).
- **Average Revenue per Patient (LTV)**: Monetary value generated per patient (`total revenue / total patients`).
- **Inactive & At-Risk Patient List**: Patients with no visits for over 60 days for retention campaigns.

### 4. Doctor Performance Reports (`DoctorReportsScreen`) - *Owner Only*
- **Doctor Comparison List**:
  - Completed appointments and visit volume per doctor.
  - Revenue generated by each doctor.
  - Performance rating and trend indicator (`up`, `stable`, `down`).

### 5. Drug & Prescription Reports (`DrugReportsScreen`)
- **Top Prescribed Medications**: Most frequently prescribed drugs with usage counts and percentages.
- **Prescription Usage Stats**: Breakdown of prescribed medication categories.

---

## 🛠️ Package & Chart Specification

```
fl_chart: ^0.68.0

Applied Usage:
  BarChart  → Revenue vs Expenses, Peak Hours, Peak Days
  PieChart  → Expenses Breakdown (Donut Style), Gender & Patient Ratios
```

---

## ✅ Implementation Checklist

- [x] Main hub (`ReportsScreen`) displays category cards for modular navigation.
- [x] "Doctor My Reports" hub (`DoctorMyReportsScreen`) reuses existing report screens with `doctorId` scoping.
- [x] Doctor Performance Reports screen is restricted to Owner roles.
- [x] Multi-Cubit state management implemented per report type for clean state isolation.
- [x] Clinic Filter (`clinicId`) supported across all reports with Clean Architecture `ClinicsCubit`.
- [x] Invoices correctly linked to doctor appointments via `sourceId`.
- [x] Advanced Patient Metrics added (New vs Returning Chart, Avg Visits/Patient, Avg Revenue/Patient).
- [x] Full RTL support, localized Arabic/English strings, and Inter Bold typography for monetary values.�شة الرئيسية للأقسام
        ├── financial_reports_screen.dart    // الشاشة المالية
        ├── appointment_reports_screen.dart  // شاشة المواعيد
        ├── patient_reports_screen.dart      // شاشة المرضى
        ├── doctor_reports_screen.dart       // شاشة أداء الأطباء (Owner)
        ├── drug_reports_screen.dart         // شاشة الأدوية (New)
        └── widgets/
            ├── reports_date_filter.dart
            ├── revenue_summary_section.dart
            ├── revenue_chart.dart
            ├── expenses_breakdown_section.dart
            ├── expenses_chart.dart
            ├── appointment_stats_section.dart
            ├── peak_hours_chart.dart
            ├── patient_stats_section.dart
            ├── doctor_performance_section.dart
            ├── drug_stats_section.dart      // جديد
            └── report_summary_card.dart
```

---

## Reports Screen — Layout

```
AppBar:
  title: "التقارير والإحصائيات"
  action: زر "تصدير PDF" (icon: ti-file-export, color: primary)
  roles: Owner only

Body (SingleChildScrollView):
  ① Date Filter Row
  ② Revenue Summary Section
  ③ Expenses Breakdown Section
  ④ Appointments Stats Section
  ⑤ Patient Stats Section
  ⑥ Doctor Performance Section   (only if clinic has > 1 doctor)
  ⑦ Diagnosis Stats Section
```

---

## ① Date Filter

```dart
// widget: reports_date_filter.dart

// Options (filter chips — single select):
[اليوم] [هذا الأسبوع] [هذا الشهر] [3 أشهر] [هذا العام] [مخصص]

// "مخصص" → opens DateRangePicker dialog

// Selected chip style:
  bg: primaryLight (#EAF4F8)
  border: 1.5px solid primary (#1A6B8A)
  text: primary (#1A6B8A)
  font: Cairo Medium 12sp

// Unselected chip style:
  bg: surface (#FFFFFF)
  border: 0.5px solid border (#E2E8F0)
  text: textSecondary (#64748B)

// Default: "هذا الشهر"
// On change: triggers ReportsCubit.loadReports(dateRange)
```

---

## ② Revenue Summary Section

### Data Required
```dart
class RevenueSummaryEntity {
  final double totalRevenue;       // SUM(invoices.paid_amount)
  final double totalExpenses;      // SUM(expenses.amount)
  final double netProfit;          // totalRevenue - totalExpenses
  final double pendingAmount;      // SUM(total_amount - paid_amount) WHERE paid < total
  final double previousRevenue;    // same period last cycle (for % change)
  final List<MonthlyRevenue> chart;  // [{date, revenue, expenses}] for bar chart
}

class DailyRevenue {
  final DateTime date;
  final double revenue;
  final double expenses;
}
```

### UI Layout
```
Section Header: "الملخص المالي"

── Summary Cards Row (horizontal scroll, 160px wide each) ──

Card ①: الإيرادات
  icon: ti-trending-up (accent color)
  value: "١٢,٥٠٠" (Inter Bold 22sp, textPrimary)
  unit: "ج.م" (Cairo 12sp, textSecondary)
  change: "↑ 12% عن الشهر السابق" (12sp, accent if positive, danger if negative)

Card ②: المصروفات
  icon: ti-trending-down (danger color)
  value: "٤,٢٠٠"
  unit: "ج.م"
  change: "↑ 5% عن الشهر السابق"

Card ③: صافي الربح
  icon: ti-cash (primary color)
  value: "٨,٣٠٠"
  unit: "ج.م"
  change: "↑ 12% عن الشهر السابق" (12sp, accent if positive, danger if negative)
  bg: primaryLight if positive, danger light if negative

Card ④: مبالغ معلقة
  icon: ti-clock (warning color)
  value: "١,٨٠٠"
  unit: "ج.م"
  sub: "من 7 فواتير"

── Revenue vs Expenses Bar Chart ──

Title: "الإيرادات مقابل المصروفات"
Type: Grouped Bar Chart (fl_chart package)

X-axis: dates (days/weeks/months depending on filter)
Y-axis: amounts in ج.م (Inter Bold)

Bars:
  Revenue bar: primary (#1A6B8A)
  Expenses bar: danger light (#FFCDD2)

Legend:
  ■ الإيرادات (primary)
  ■ المصروفات (danger light)

Chart height: 200px
Chart bg: surface, radius 16px, padding 16px
```

---

## ③ Expenses Breakdown Section

### Data Required
```dart
class ExpensesCategoryEntity {
  final String categoryName;   // from expense_categories.name
  final double amount;
  final double percentage;     // amount / total * 100
}
```

### UI Layout
```
Section Header: "تفاصيل المصروفات"

── Donut Chart ──
  Center: إجمالي المصروفات
          "٤,٢٠٠ ج.م" (Inter Bold)
  Segments: each expense_category with a color
  Height: 180px

Colors per category (consistent):
  إيجار:              #1A6B8A (primary)
  كهرباء:             #F5A623 (warning)
  رواتب:              #2ECC9A (accent)
  مستلزمات:           #9B59B6
  صيانه:              #E84C4C (danger)
  اجهزة طبية:         #3498DB
  انترنت:             #1ABC9C
  تسويق و اعلانات:    #F39C12
  خدمات:              #95A5A6
  ضرائب و رسوم:       #E74C3C
  طاقه اخري (غاز):    #D35400
  مياه:               #2980B9
  أخري:               #BDC3C7

── Category List ──
Each row:
  [color dot 10px] اسم الفئة    percentage%    amount ج.م
  font: Cairo 13sp | amount: Inter Bold 13sp
  with thin progress bar underneath (color matches dot)
```

---

## ④ Appointments Stats Section

### Data Required
```dart
class AppointmentStatsEntity {
  final int totalAppointments;
  final int completedAppointments;   // status = 'done'
  final int cancelledAppointments;   // status = 'cancelled'
  final double attendanceRate;       // done / (done + cancelled) * 100
  final List<PeakHour> peakHours;    // [{hour, count}]
  final List<PeakDay> peakDays;      // [{dayName, count}]
  final Map<String, int> byType;     // {type_name: count}
}

class PeakHour {
  final int hour;       // 0-23
  final int count;
}

class PeakDay {
  final String dayName; // "السبت", "الأحد"...
  final int count;
}
```

### UI Layout
```
Section Header: "إحصائيات المواعيد"

── Stats Row ──
  [إجمالي: 248]  [مكتمل: 201 ✓]  [ملغي: 47 ✗]

── Attendance Rate ──
  "معدل الحضور"
  Large percentage: "81%" (Inter Bold 32sp, accent if ≥70%, warning if 50-70%, danger if <50%)
  Progress bar: full width, colored per rate

── Peak Hours Bar Chart ──
  Title: "أوقات الذروة"
  X-axis: ساعات اليوم (8ص, 9ص, 10ص...)
  Y-axis: عدد المواعيد
  Highlight bar: darkest = busiest hour
  Height: 150px

── Busiest Days ──
  Title: "أكثر الأيام ازدحاماً"
  Horizontal bars: each day with count and bar
  Days: السبت, الأحد, الاثنين, الثلاثاء, الأربعاء, الخميس

── Visit Types Breakdown ──
  Title: "أنواع الزيارات"
  Each type: [name] [count] [percentage bar]
```

---

## ⑤ Patient Stats Section

### Data Required
```dart
class PatientStatsEntity {
  final int totalPatients;
  final int newPatients;          // registered in selected period
  final int returningPatients;    // visited > 1 time
  final double returnRate;        // returning / total * 100
  final Map<String, int> byGender;       // {'male': X, 'female': Y}
  final Map<String, int> byAgeGroup;     // {'0-18': X, '19-35': Y, ...}
  final List<PatientActivity> inactive;  // لم يزوروا منذ > 3 أشهر
}

class PatientActivity {
  final String patientName;
  final DateTime lastVisit;
  final int daysSinceLastVisit;
}
```

### UI Layout
```
Section Header: "إحصائيات المرضى"

── Summary Row ──
  [إجمالي المرضى: 412]  [جدد: 28]  [معدل العودة: 67%]

── Gender Distribution ──
  Title: "توزيع المرضى"
  Simple two-bar visual:
    ذكور  ████████  62%
    إناث  ██████    38%
  Colors: primary for male, accent for female (or vice versa)

── Age Groups ──
  Title: "الفئات العمرية"
  Horizontal bars:
    0-18    ██       8%
    19-35   ████████ 35%
    36-50   ██████   28%
    51-65   ████     18%
    65+     ██       11%

── Inactive Patients ──
  Title: "مرضى لم يزوروا منذ 3 أشهر"
  subtitle: "قد يحتاجون تذكيراً" (caption, warning color)
  List (max 5):
    [Avatar] اسم المريض    آخر زيارة: X أشهر
  "عرض الكل" link if more than 5
```

---

## ⑥ Doctor Performance Section

```
Visible only when: clinic has more than 1 active doctor

Section Header: "أداء الأطباء"
```

### Data Required
```dart
class DoctorPerformanceEntity {
  final String doctorId;
  final String doctorName;
  final String? specialty;
  final List<ClinicEntity> clinics;
  final int appointmentsCount;
  final double revenue;
  final double attendanceRate;
}
```

### UI Layout
```
For each doctor — Card:
┌──────────────────────────────────────────────┐
│    [Avatar]  د. أحمد محمد      │
│           طب عام                             │
│                                              │
│  المواعيد      الإيرادات      الحضور         │
│  124           ٨,٢٠٠ ج.م      88%            │
│  (Inter Bold)  (Inter Bold)   (accent color) │
│                                              │
│  [progress bar — relative to top performer] │
└──────────────────────────────────────────────┘

Top performer card: border 1.5px primary + "الأفضل أداءً" badge
```
---

## ⑦ prescription templetes Stats Section  (prescription templetes)

### Data Required
```dart
class templetesStatsEntity {
  final String name;   // prescription_templetes table
  final int count;
  final double percentage;
}
```

### UI Layout
```
Section Header: "أكثر التشخيصات شيوعاً"
subtitle: "بناءً على الروشتات المحررة" (caption)

⚠️ Note: diagnosis is free text — grouping is by exact text match.
Similar diagnoses (e.g. "التهاب حلق" vs "التهاب في الحلق") counted separately.
This is a known limitation of the current schema.

List (top 10):
  Rank | diagnosis text | count | percentage bar

  1  التهاب حلق حاد          48  ████████████  22%
  2  ضغط الدم المرتفع        31  ████████      14%
  3  سكري النوع الثاني       28  ███████       13%
  ...

Bar color: primary, thinning for lower ranks
Font: Cairo 13sp for text, Inter Bold for numbers
```

---

## Supabase Queries Reference

```dart
// Revenue Summary
// SUM paid_amount WHERE clinic_id + date range
supabase.from('invoices')
  .select('paid_amount, total_amount, created_at')
  .eq('clinic_id', clinicId)
  .gte('created_at', startDate)
  .lte('created_at', endDate)

// Expenses by category
supabase.from('expenses')
  .select('amount, created_at, expense_categories(name)')
  .eq('clinic_id', clinicId)
  .gte('created_at', startDate)
  .lte('created_at', endDate)

// Appointment stats
supabase.from('appointments')
  .select('status, time, date, doctor_appointment_types(appointment_types(name))')
  .eq('clinic_id', clinicId)
  .gte('date', startDate)
  .lte('date', endDate)

// Patient stats
supabase.from('patients')
  .select('id, gender, date_of_birth, created_at')
  .eq('owner_id', ownerId)
  .gte('created_at', startDate)
  .lte('created_at', endDate)

// Doctor performance
supabase.from('appointments')
  .select('doctor_id, status, users!doctor_id(name, specialty)')
  .eq('clinic_id', clinicId)
  .gte('date', startDate)
  .lte('date', endDate)


```
## Screen Specs

### ① Financial Reports Screen
- **الملخص المالي** (RevenueSummaryEntity): بطاقات الإيرادات، المصروفات، صافي الربح، المبالغ المعلقة.
- **رسم بياني** (Revenue vs Expenses Bar Chart).
- **تفاصيل المصروفات** (Expenses Breakdown Donut Chart & Category List).

### ② Appointment Reports Screen
- **إحصائيات المواعيد** (AppointmentStatsEntity): إجمالي، مكتمل، ملغي، ومعدل الحضور.
- **رسم بياني لأوقات الذروة** (Peak Hours Bar Chart) والأيام الأكثر ازدحاماً.
- **تفاصيل أنواع الزيارات**.

### ③ Patient Reports Screen
- **إحصائيات المرضى** (PatientStatsEntity): إجمالي المرضى، المرضى الجدد، معدل العودة.
- **توزيع الجنس والفئات العمرية**.
- **قائمة المرضى غير النشطين** الذين لم يزوروا العيادة منذ 3 أشهر.

### ④ Doctor Performance Reports Screen (Owner Only)
- **مقارنة أداء الأطباء** (DoctorPerformanceEntity): يعرض كروت الأطباء متضمنة المواعيد، الإيرادات، ونسب الحضور.

### ⑤ Drug Reports Screen (NEW)
- **إحصائيات الأدوية العامة** (DrugStatsEntity):
  - **التصنيف الدوائي** (Drug Categories Donut Chart): يعرض نسبة توزيع الأدوية حسب الفئة (Antibiotic, Antipyretic, Chronic, etc.).
  - **الأدوية الأكثر وصفاً بالعيادة** (Top Prescribed Drugs): قائمة بأكثر 10 أدوية تم استخدامها في الروشتات مع عدد الوصفات ونسبتها المئوية.

---

## Doctor Reports Screen Spec (شاشة تقارير الطبيب في الـ Bottom Nav)

تظهر هذه الشاشة للطبيب عند الضغط على تبويب "تقاريري" في شريط التنقل السفلي، وتعرض الإحصائيات الآتية الخاصة به فقط:

### ① المواعيد الخاصة بالطبيب (Doctor Appointments Stats):
- إجمالي المواعيد، المواعيد المكتملة (done)، والملغاة (cancelled).
- معدل حضور المرضى الخاص به (Attendance Rate).
- رسم بياني لأوقات الذروة (Peak Hours) والأيام الأكثر ازدحاماً لمرضاه.
- توزيع المواعيد حسب نوع الزيارة (كشف، استشارة، إعادة كشف).

### ② الإيرادات الخاصة بالطبيب (Doctor Revenue Stats):
- إجمالي الإيرادات المحصلة من كشوفات هذا الطبيب.
- رسم بياني لتطور الإيرادات شهراً بشهر.
- المبالغ المعلقة الخاصة بمرضاه.

### ③ المرضى الخاصين بالطبيب (Doctor Patients Stats):
- إجمالي عدد المرضى الفريدين الذين عاينهم الطبيب.
- نسبة عودة المرضى للطبيب (Return Rate).
- توزيع المرضى حسب الجنس (ذكور/إناث) والفئات العمرية.

### ④ الأدوية الأكثر وصفاً بواسطة الطبيب (Doctor Top Prescribed Drugs):
- رسم بياني دائري (Donut Chart) لتوزيع فئات الأدوية الموصوفة من قبل الطبيب (Antibiotic, Antipyretic, etc.).
- قائمة بأكثر 10 أدوية يصفها الطبيب في روشتاته مرتبة تنازلياً.

### ⑤ قوالب الروشتات الأكثر استخداماً (Doctor Top Prescription Templates):
- إحصائية القوالب الخاصة بالطبيب مرتبة تنازلياً حسب عدد مرات استخدامها (`user_count`).
---

## Mock Data Structure

```dart
// core/mocks/mock_data.dart — add reports mock data

class MockReportsData {

  static final revenueSummary = {
    'total_revenue':    12500.0,
    'total_expenses':   4200.0,
    'net_profit':       8300.0,
    'pending_amount':   1800.0,
    'previous_revenue': 11200.0,
    'chart': [
      {'date': '2025-01-01', 'revenue': 1800.0, 'expenses': 600.0},
      {'date': '2025-01-02', 'revenue': 2100.0, 'expenses': 800.0},
      {'date': '2025-01-03', 'revenue': 1500.0, 'expenses': 400.0},
      {'date': '2025-01-04', 'revenue': 2800.0, 'expenses': 1200.0},
      {'date': '2025-01-05', 'revenue': 1900.0, 'expenses': 700.0},
      {'date': '2025-01-06', 'revenue': 1400.0, 'expenses': 300.0},
      {'date': '2025-01-07', 'revenue': 1000.0, 'expenses': 200.0},
    ],
  };

  static final expensesBreakdown = [
    {'category': 'رواتب',     'amount': 2000.0, 'percentage': 47.6},
    {'category': 'إيجار',     'amount': 1200.0, 'percentage': 28.6},
    {'category': 'كهرباء',    'amount': 340.0,  'percentage': 8.1},
    {'category': 'مستلزمات',  'amount': 280.0,  'percentage': 6.7},
    {'category': 'صيانه',     'amount': 180.0,  'percentage': 4.3},
    {'category': 'أخري',      'amount': 200.0,  'percentage': 4.8},
  ];

  static final appointmentStats = {
    'total':          248,
    'completed':      201,
    'cancelled':      47,
    'attendance_rate': 81.0,
    'peak_hours': [
      {'hour': 9,  'count': 42},
      {'hour': 10, 'count': 58},
      {'hour': 11, 'count': 51},
      {'hour': 12, 'count': 38},
      {'hour': 16, 'count': 45},
      {'hour': 17, 'count': 39},
    ],
    'peak_days': [
      {'day': 'السبت',    'count': 52},
      {'day': 'الاثنين',  'count': 48},
      {'day': 'الثلاثاء', 'count': 44},
      {'day': 'الأربعاء', 'count': 41},
      {'day': 'الأحد',    'count': 38},
      {'day': 'الخميس',   'count': 25},
    ],
    'by_type': [
      {'name': 'كشف عادي',    'count': 180},
      {'name': 'إعادة كشف',  'count': 45},
      {'name': 'استشارة',     'count': 23},
    ],
  };

  static final patientStats = {
    'total':            412,
    'new':              28,
    'returning':        276,
    'return_rate':      67.0,
    'by_gender': {'male': 255, 'female': 157},
    'by_age': {
      '0-18':  33,
      '19-35': 144,
      '36-50': 115,
      '51-65': 74,
      '65+':   46,
    },
    'inactive': [
      {'name': 'محمد أحمد',  'last_visit': '2024-09-15', 'days': 108},
      {'name': 'سارة علي',   'last_visit': '2024-09-20', 'days': 103},
      {'name': 'خالد حسن',   'last_visit': '2024-09-28', 'days': 95},
      {'name': 'نورا محمود', 'last_visit': '2024-10-01', 'days': 92},
      {'name': 'أحمد سامي',  'last_visit': '2024-10-05', 'days': 88},
    ],
  };
    static final drugStats = {
    'by_category': [
      {'category': 'مضاد حيوي', 'count': 120, 'percentage': 40.0},
      {'category': 'خافض حرارة', 'count': 90, 'percentage': 30.0},
      {'category': 'أمراض صدر', 'count': 45, 'percentage': 15.0},
      {'category': 'أدوية مزمنة', 'count': 30, 'percentage': 10.0},
      {'category': 'أخرى', 'count': 15, 'percentage': 5.0},
    ],
    'top_drugs': [
      {'name': 'Amoxicillin 500mg', 'count': 64, 'percentage': 21.3},
      {'name': 'Paracetamol 500mg', 'count': 58, 'percentage': 19.3},
      {'name': 'Ibuprofen 400mg', 'count': 42, 'percentage': 14.0},
      {'name': 'Panadol Joint', 'count': 35, 'percentage': 11.6},
      ...
    ]
  };
  
  static final doctorPerformance = [
    {
      'doctor_id':        'doc-1',
      'name':             'د. أحمد محمد',
      'specialty':        'طب عام',
      'appointments':     124,
      'revenue':          8200.0,
      'attendance_rate':  88.0,
    },
    {
      'doctor_id':        'doc-2',
      'name':             'د. سارة علي',
      'specialty':        'طب أطفال',
      'appointments':     89,
      'revenue':          5400.0,
      'attendance_rate':  82.0,
    },
  ];

  static final diagnosisStats = [
    {'name': 'التهاب حلق حاد',       'count': 48, 'percentage': 22.0},
    {'name': 'ضغط الدم المرتفع',     'count': 31, 'percentage': 14.0},
    {'name': 'سكري النوع الثاني',    'count': 28, 'percentage': 13.0},
    {'name': 'التهاب الجيوب الأنفية','count': 21, 'percentage': 10.0},
    {'name': 'آلام الظهر المزمنة',   'count': 19, 'percentage': 9.0},
    {'name': 'أنيميا',               'count': 15, 'percentage': 7.0},
    {'name': 'إجهاد عام',            'count': 14, 'percentage': 6.0},
    {'name': 'التهاب المعدة',        'count': 12, 'percentage': 5.0},
    {'name': 'حساسية موسمية',        'count': 11, 'percentage': 5.0},
    {'diagnosis': 'أخرى',                 'count': 19, 'percentage': 9.0},
  ];
}
```

---

## ReportsCubit

```dart
// presentation/manager/reports_cubit.dart

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({
    required this.getRevenueSummaryUseCase,
    required this.getAppointmentStatsUseCase,
    required this.getDoctorPerformanceUseCase,
    required this.getDiagnosisStatsUseCase,
    required this.getPatientStatsUseCase,
  }) : super(ReportsInitial());

  // تحميل كل التقارير دفعة واحدة
  Future<void> loadReports({required DateRange dateRange}) async {
    emit(ReportsLoading());

    // استدعاء UseCases بالتوازي
    final results = await Future.wait([
      getRevenueSummaryUseCase(dateRange),
      getAppointmentStatsUseCase(dateRange),
      getDoctorPerformanceUseCase(dateRange),
      getDiagnosisStatsUseCase(dateRange),
      getPatientStatsUseCase(dateRange),
    ]);

    // تجميع النتائج
    // لو أي منهم فشل → emit ReportsError
    // لو كلهم نجحوا → emit ReportsLoaded
  }
}
```

---

## Package to Use for Charts

```
fl_chart: ^0.68.0

Usage:
  BarChart  → Revenue vs Expenses, Peak Hours, Peak Days
  PieChart  → Expenses Breakdown (donut style)
  LineChart → (optional future) Patient growth over time
```

---

## Checklist Before Submitting

- [ ] الشاشة الرئيسية تعرض كروت الأقسام (مالي، مواعيد، مرضى، أداء أطباء، أدوية).
- [ ] عند الضغط على كرت يتم الانتقال للشاشة التفصيلية للقسم المحدد.
- [ ] شاشة أداء الأطباء تظهر فقط للمستخدم المالك (Owner).
- [ ] لوحة تحكم الطبيب تحتوي على إحصائياته الفردية وتصنيفاته الدوائية وقوالبه الأكثر استخداماً (`user_count`).
- [ ] جميع الرسوم البيانية تستخدم حزمة `fl_chart`.
- [ ] تدعم واجهات التقارير بالكامل الاتجاه من اليمين لليسار (RTL) والأرقام بخط Inter Bold.

---

## 7. تنفيذ قسم تقارير العيادات ومقارنة الفروع (Clinic Reports) 🏥 *(خاص بالمالك)*

تم تخصيص هذا القسم لمالك النظام (isOwner = true) لعرض إحصائيات ومقارنات تفاعلية بين الفروع المملوكة له فقط (owner_id).

### 🛠️ المكونات الفنية وطبقات النظام (Clean Architecture):

1. **Domain Layer**:
   - ClinicReportEntity: يحتوي على الكيانات الكلية للمالك (	otalActiveClinics, 	otalExpectedRevenue, 	otalCollectedAmount, 	otalExpenses, 	otalNetProfit, 	otalAppointmentsToday, 	otalDoctors, clinics).
   - ClinicComparisonItem: يحتوي على إحصائيات كل فرع مستقلة (expectedRevenue من ppointments, collectedAmount من invoices, monthlyExpenses من expenses, 
etProfit, profitMargin, evenuePerDoctor, monthlyPerformance, monthlyExpectedPerformance).
   - GetClinicReportUseCase: تنفيذ استدعاء التقرير بحسب ownerId.
   - IReportsRepository: إضافة getClinicReport(String ownerId).

2. **Data Layer**:
   - IReportsRemoteDataSource.fetchClinicReport(String ownerId):
     - يتم الاستعلام عن العيادات المفلترة بشرط owner_id = ownerId.
     - يتم حساب **الإيراد المتوقع** للشهر الحالي والأشهر الـ 5 الماضية من جدول ppointments (مجموع price).
     - يتم حساب **المحصل الفعلي** للشهر الحالي والأشهر الـ 5 الماضية من جدول invoices (مجموع paid_amount).
     - يتم حساب المصروفات ونسبة هامش الربح ومعدل إيراد الطبيب (collectedAmount / numberOfDoctors).
   - ReportsRepositoryImpl: معالجة الأخطاء وإعادة Either<Failure, ClinicReportEntity>.

3. **Presentation Layer**:
   - ClinicReportsCubit: إدارة حالات تحميل التقرير (ClinicReportsLoading, ClinicReportsLoaded, ClinicReportsError).
   - ClinicReportsScreen: الشاشة الرئيسية التي تجمع مكونات التقرير.
   - **الودجتس المخصصة**:
     - ClinicSummaryCards: عرض بطاقات KPI الرئيسية (الإيراد المتوقع من الحجوزات، المحصل الفعلي من الفواتير، المصروفات، صافي الربح، العيادات النشطة، الأطباء).
     - ClinicComparisonBarChart: رسم بياني عمودي شريطي مزدوج يقارن بين **الإيراد المتوقع** و**المحصل الفعلي** لكل فرع.
     - ClinicTrendLineChart: رسم خطي تفاعلي لآخر 5 أشهر مع منحنيين لكل فرع (**خط متصل للمحصل الفعلي** و**خط منقط برتقالي للمتوقع**).
     - ClinicLeaderboardTable: جدول تفاعلي يرتب العيادات بحسب المحصل الفعلي مع إظهار عمود مستقل لـ إيراد/طبيب وهامش الربح.
