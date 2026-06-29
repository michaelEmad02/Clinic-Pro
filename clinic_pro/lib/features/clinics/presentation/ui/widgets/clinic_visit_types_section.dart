// ────────────────────────────────────────────────────────
// قسم أنواع الكشوفات والخدمات — مع الوصف والسعر وسهم التوجيه
// مستوحى من تصميم phase8_ui/clinic_details_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

String _formatPrice(double value) {
  return value.toInt().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class ClinicVisitTypesSection extends StatelessWidget {
  final String clinicId;

  const ClinicVisitTypesSection({
    super.key,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    final types = MockData.appointmentTypes
        .where((t) => t['clinic_id'] == clinicId)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القسم
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'أنواع الزيارات والأسعار',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'إضافة خدمة',
                  style: AppTextStyles.labelChip(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (types.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'لا توجد خدمات مسجلة',
                style: TextStyle(color: AppColors.textHint),
              ),
            )
          else
            ...types.map((type) {
              final name = type['name'] as String;
              final price = (type['price'] as num).toDouble();
              final description = type['description'] as String? ?? '';

              return InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  description,
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Text(
                            _formatPrice(price),
                            style: AppTextStyles.dataNumeric(context).copyWith(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'ر.س',
                            style: AppTextStyles.caption(context).copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_left,
                            size: 18,
                            color: AppColors.outline,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
