import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/clinic_summary_entity.dart';

class ClinicsHorizontalScroll extends StatelessWidget {
  final List<ClinicSummaryEntity> clinics;

  const ClinicsHorizontalScroll({
    super.key,
    required this.clinics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عياداتك النشطة',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push(RouteConstants.clinics),
                child: Text(
                  'عرض الكل',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return GestureDetector(
                onTap: () => context.push('${RouteConstants.clinics}/${clinic.id}'),
                child: Container(
                width: 240,
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            clinic.name,
                            style: AppTextStyles.headlineSmall(context).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: clinic.isActive ? AppColors.successBg : AppColors.dangerBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            clinic.isActive ? 'نشطة' : 'متوقفة',
                            style: AppTextStyles.caption(context).copyWith(
                              fontSize: 10,
                              color: clinic.isActive ? AppColors.successText : AppColors.dangerText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            clinic.location,
                            style: AppTextStyles.caption(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medication_outlined, size: 14, color: AppColors.primaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              'أطباء: ${clinic.doctorsCount}',
                              style: AppTextStyles.caption(context).copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 14, color: AppColors.primaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              'مرضى: ${clinic.patientsCount}',
                              style: AppTextStyles.caption(context).copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              );
            },
          ),
        ),
      ],
    );
  }
}
