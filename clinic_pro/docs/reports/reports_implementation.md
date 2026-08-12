# Reports Feature — Implementation Spec

## Context

You are implementing the **Reports Screen** for **ClinicPro** — a multi-tenant
medical clinic management SaaS built with Flutter.

Read and follow these rules **before writing any code:**
- `rules.md` — coding standards, widget splitting, mock data rules
- `architecture.md` — Clean Architecture, layer boundaries, ICloudService pattern
- `features/financial/schema.md` — invoices, expenses tables
- `features/appointments_queue/schema.md` — appointments table
- `features/patients/schema.md` — patients table
- `features/prescriptions/schema.md` — prescriptions table


---

## Design System (use exactly — no deviations)
 استخدم نفس الالوان و قواعد و ثيمات التصميم الموجوده في باقي المشروع.
 انظر الي
 - lib/core/theme/app_theme.dart
 - lib/core/theme/app_colors.dart
 - lib/core/strings/app_strings.dart
 - lib/core/theme/app_text_styles.dart

 ** Responsive & Adaptive UI Rules
```dart
// ✅ Always use ResponsiveHelper for screen classification and responsive layouts
// ✅ Mobile (< 600px):
//    - Centered card containers (maxWidth: 440–480px)
//    - Single-column vertical lists with touch-friendly spacing
//    - Standard Modal BottomSheet for dialogs/forms
//    - BottomNavigationBar for main navigation

// ✅ Tablet & Desktop (>= 600px):
//    - ResponsiveCenter container (maxWidth: 720px for settings/forms, 1100–1200px for dashboards/lists)
//    - Multi-column grid layouts (Grid 2/3 Columns) for lists and Bento cards
//    - Navigation Rail (Sidebar) replacing BottomNavigationBar
//    - Centered Dialogs (maxDialogWidth: 560px) replacing Modal BottomSheet
//    - Auth Split-Screen: Branding panel on the right (flex: 5) + Form on the left (flex: 6)

// ❌ Never hardcode dimensions, padding, or fixed screen offsets
// ❌ Never use raw pixel values without AppConstants
// ❌ Always secure buttons and text in Rows/Grids with Flexible and TextOverflow.ellipsis to prevent Red Overflow

read :
- lib/core/utils/responsive_helper.dart
- lib/core/widgets/app_responsive_scaffold.dart
```
for more info , read "rules.md"
---

## Architecture Rules

```
✅ Screen file → thin, delegates to subwidgets
✅ Each chart/section → separate widget file in widgets/
✅ Mock data → in MockCloudService, NOT in widgets
✅ Numbers/amounts → Inter Bold always
✅ All widgets → const constructors where possible
✅ No setState → use ReportsCubit
✅ Widget > 200 lines → split further
✅ Comments in Arabic with English technical terms
```

---

## File Structure

```
lib/features/reports/
├── data/
│   ├── data_sources/
│   │   ├── i_reports_data_source.dart
│   │   ├── reports_remote_data_source.dart   // calls ICloudService
│   ├── models/
│   │   ├── revenue_summary_model.dart
│   │   ├── appointment_stats_model.dart
│   │   ├── doctor_performance_model.dart
│   │   ├── diagnosis_stats_model.dart
│   │   └── patient_stats_model.dart
│   └── repositories/
│       └── reports_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── revenue_summary_entity.dart
│   │   ├── appointment_stats_entity.dart
│   │   ├── doctor_performance_entity.dart
│   │   ├── diagnosis_stats_entity.dart
│   │   └── patient_stats_entity.dart
│   ├── repositories/
│   │   └── i_reports_repository.dart
│   └── usecases/
│       ├── get_revenue_summary_usecase.dart
│       ├── get_appointment_stats_usecase.dart
│       ├── get_doctor_performance_usecase.dart
│       ├── get_diagnosis_stats_usecase.dart
│       └── get_patient_stats_usecase.dart
└── presentation/
    ├── manager/
    │   ├── reports_cubit.dart
    │   └── reports_state.dart
    └── ui/
        ├── reports_screen.dart              // thin — assembles sections
        └── widgets/
            ├── reports_date_filter.dart     // date range chips
            ├── revenue_summary_section.dart
            ├── revenue_chart.dart           // bar chart
            ├── expenses_breakdown_section.dart
            ├── expenses_chart.dart          // pie/donut chart
            ├── appointment_stats_section.dart
            ├── peak_hours_chart.dart        // bar chart
            ├── patient_stats_section.dart
            ├── doctor_performance_section.dart
            ├── diagnosis_stats_section.dart
            └── report_summary_card.dart     // reusable stat card
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
    {'name': 'أخرى',                 'count': 19, 'percentage': 9.0},
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

```
□ reports_screen.dart is thin — no business logic inline
□ Each section is a separate widget file
□ All numbers use Inter Bold font
□ All amounts show "ج.م" suffix
□ Percentages show "%" with Inter Bold for the number
□ Mock data in MockReportsData class — not inline in widgets
□ ShimmerList shown while loading
□ Error state with retry button
□ Date filter defaults to "هذا الشهر"
□ Doctor performance section hidden if clinic has 1 doctor
□ Diagnosis section note: "free text grouping — not FK-based"
□ Export PDF button wired (can be TODO for Phase 2)
□ RTL layout throughout
□ Responsive: 2-column grid for summary cards on tablet
```
