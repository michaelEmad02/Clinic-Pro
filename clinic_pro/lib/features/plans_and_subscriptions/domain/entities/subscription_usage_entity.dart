// ────────────────────────────────────────────────────────
// كيان إحصائيات استخدام خطة الاشتراك (SubscriptionUsageEntity)
// يحتوي على أعداد العيادات والموظفين والمرضى الحالية للمالك والعيادة النشطة
// ────────────────────────────────────────────────────────

class SubscriptionUsageEntity {
  final int clinicsCount;
  final int staffCount;
  final int patientsCount;

  const SubscriptionUsageEntity({
    required this.clinicsCount,
    required this.staffCount,
    required this.patientsCount,
  });
}
