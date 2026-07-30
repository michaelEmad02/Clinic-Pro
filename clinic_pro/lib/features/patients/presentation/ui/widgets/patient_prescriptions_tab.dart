// ────────────────────────────────────────────────────────
// تبويب الروشتات في تفاصيل المريض — مطابق لتصميم Stitch
// ملاحظة: هذا التبويب سيُحدث لاحقاً عند بناء طبقة الدومين
// الخاصة بـ Prescription Feature — حالياً يعرض حالة فارغة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/empty_state.dart';

class PatientPrescriptionsTab extends StatelessWidget {
  final String patientId;

  const PatientPrescriptionsTab({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    // سيتم ربط هذا التبويب بـ Prescription Feature UseCase لاحقاً
    return EmptyState(
      title: AppStrings.isArabic ? 'لا توجد روشتات' : 'No Prescriptions',
      subtitle: AppStrings.isArabic
          ? 'لم تُصدر أي روشتة لهذا المريض بعد.'
          : 'No prescriptions have been issued for this patient.',
      icon: Icons.medication_outlined,
    );
  }
}
