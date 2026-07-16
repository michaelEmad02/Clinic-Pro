import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// بطاقة رأس الروشتة: تعرض بيانات المريض والموعد
// ────────────────────────────────────────────────────────

class PrescriptionHeaderCard extends StatelessWidget {
  final String patientName;
  final String age;
  final String gender;
  final String bloodType;
  final String visitType;
  final String doctorName;
  final String visitDate;

  const PrescriptionHeaderCard({
    super.key,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.visitType,
    required this.doctorName,
    required this.visitDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // شريط جانبي ملون (primary accent)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: Container(
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // صورة رمزية للمريض
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: context.primaryLightColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: context.primary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style:
                                AppTextStyles.headlineMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                age,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: context.border,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                gender,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: context.border,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // شارة فصيلة الدم
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.dangerBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.water_drop,
                                      size: 12,
                                      color: context.danger,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      bloodType,
                                      style: AppTextStyles.dataNumeric(context)
                                          .copyWith(
                                        color: context.danger,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: context.border, height: 1),
                ),
                // بيانات وصفية: نوع الزيارة – الطبيب – التاريخ
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMetaItem(context, Icons.medical_services_outlined,
                        AppStrings.visitType, visitType),
                    _buildMetaItem(context, Icons.person_outline,
                        AppStrings.doctorLabel, doctorName),
                    _buildMetaItem(context, Icons.calendar_today,
                        AppStrings.date, visitDate),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textHint,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
