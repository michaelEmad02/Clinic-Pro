import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/plan_entity.dart';

class CurrentPlanCard extends StatelessWidget {
  final PlanEntity plan;
  final String planStatus;
  final DateTime? endAt;

  const CurrentPlanCard({
    super.key,
    required this.plan,
    required this.planStatus,
    this.endAt,
  });

  String _planTitle() {
    switch (plan.name.toLowerCase()) {
      case 'pro':
      case 'growth':
        return AppStrings.isArabic ? 'الباقة الاحترافية (Pro)' : 'Pro Plan';
      case 'enterprise':
      case 'professional':
        return AppStrings.isArabic ? 'باقة المؤسسات (Enterprise)' : 'Enterprise Plan';
      case 'basic':
      default:
        return AppStrings.isArabic ? 'الباقة الأساسية (Basic)' : 'Basic Plan';
    }
  }

  String _planDescription() {
    if (plan.description != null && plan.description!.isNotEmpty) {
      return plan.description!;
    }
    switch (plan.name.toLowerCase()) {
      case 'pro':
      case 'growth':
        return AppStrings.isArabic ? 'الأكثر طلباً، مثالية للعيادات المتوسطة والنمو السريع.' : 'Most popular, ideal for medium clinics and rapid growth.';
      case 'enterprise':
      case 'professional':
        return AppStrings.isArabic ? 'مثالية للمراكز الطبية الكبيرة والمستشفيات المتكاملة.' : 'Ideal for large medical centers and integrated hospitals.';
      case 'basic':
      default:
        return AppStrings.isArabic ? 'مثالية للعيادات الناشئة والممارسين المستقلين.' : 'Ideal for emerging clinics and independent practitioners.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _planTitle();
    final description = _planDescription();
    final price = '${plan.monthlyPriceEgp.toInt()} ${AppStrings.egp}';

    final List<String> featuresList = [];

    if (plan.features != null) {
      final maxClinics = plan.features!.maxClinics;
      final maxStaff = plan.features!.maxStaff;
      final maxPatients = plan.features!.maxPatients;

      featuresList.add(AppStrings.supportClinics(maxClinics));
      featuresList.add(AppStrings.supportStaff(maxStaff));
      featuresList.add(AppStrings.supportPatients(maxPatients));

      if (plan.features!.customFeatures != null) {
        final Map<String, dynamic> customFeats = plan.features!.customFeatures!;
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';

        customFeats.forEach((key, val) {
          if (val is Map<String, dynamic>) {
            final String arbTitle = val['arb_title'] as String? ?? '';
            final String engTitle = val['eng_title'] as String? ?? '';
            final bool isIncluded = val['value'] as bool? ?? false;
            final String featTitle = isArabic
                ? (arbTitle.isNotEmpty ? arbTitle : engTitle)
                : (engTitle.isNotEmpty ? engTitle : arbTitle);

            if (isIncluded && featTitle.isNotEmpty) {
              featuresList.add(featTitle);
            }
          }
        });
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.border, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.headlineMedium(context)),
              const SizedBox(width: AppConstants.spaceSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 3),
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                  border: Border.all(color: context.primary.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: context.primary),
                    const SizedBox(width: 4),
                    Text(
                      planStatus == 'trial' || planStatus == 'trail'
                          ? AppStrings.trial
                          : planStatus == 'active'
                              ? AppStrings.active
                              : planStatus,
                      style: AppTextStyles.labelChip(context).copyWith(color: context.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            description,
            style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Divider(height: 1, thickness: 0.5, color: context.border),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            AppStrings.planFeatures,
            style: AppTextStyles.headlineSmall(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ...featuresList.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: context.accent),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(child: Text(feature, style: AppTextStyles.bodyMedium(context))),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (endAt != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 15,
                          color: context.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          planStatus == 'active'
                              ? AppStrings.subscriptionRenewsAt
                              : AppStrings.subscriptionExpiresAt,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d MMMM yyyy', AppStrings.isArabic ? 'ar' : 'en').format(endAt!),
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: AppTextStyles.headlineLarge(context).copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.perMonth,
                    style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
