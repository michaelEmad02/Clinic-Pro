// ────────────────────────────────────────────────────────
// VisitTypeListSection — عرض قائمة أنواع الزيارات المضافة للطبيب
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/doctor_appointment_type_entity.dart';

class VisitTypeListSection extends StatelessWidget {
  final List<DoctorAppointmentTypeEntity> entries;
  final Function(int) onRemove;

  const VisitTypeListSection({
    super.key,
    required this.entries,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
          child: Text(
            AppStrings.addedTypes,
            style: AppTextStyles.labelChip(context).copyWith(color: context.textSecondary),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.25),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                  vertical: AppConstants.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                  border: Border.all(color: context.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.name ?? '', style: AppTextStyles.bodyLarge(context)),
                          Text(
                            '${entry.price.toStringAsFixed(0)} ${AppStrings.sar}',
                            style: AppTextStyles.dataNumeric(context).copyWith(color: context.primary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(index),
                      icon: Icon(Icons.remove_circle_outline, color: context.danger, size: 20),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        Divider(height: 1, thickness: 0.5, color: context.border),
        const SizedBox(height: AppConstants.spaceMd),
      ],
    );
  }
}
