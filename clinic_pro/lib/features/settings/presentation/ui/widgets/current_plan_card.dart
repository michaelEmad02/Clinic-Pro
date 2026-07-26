import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/i_cloud_service.dart';

class CurrentPlanCard extends StatelessWidget {
  final String planKey;
  final String planStatus;

  const CurrentPlanCard({
    super.key,
    required this.planKey,
    required this.planStatus,
  });

  String _planTitle() {
    switch (planKey) {
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
    switch (planKey) {
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

  Future<Map<String, dynamic>?> _fetchPlanDetails() async {
    try {
      final cloudService = sl<ICloudService>();
      
      // Determine standardized plan name used in DB
      String planName = 'basic';
      if (planKey == 'pro' || planKey == 'growth') {
        planName = 'pro';
      } else if (planKey == 'enterprise' || planKey == 'professional') {
        planName = 'enterprise';
      }

      // Fetch plan price from 'plans' table
      final planResults = await cloudService.select(
        table: 'plans',
        eq: {'name': planName},
      );
      if (planResults.isEmpty) return null;
      final planData = planResults.first;

      // Fetch plan features from 'plans_features' table
      final featuresResults = await cloudService.select(
        table: 'plans_features',
        eq: {'plan_id': planData['id']},
      );
      
      return {
        'plan': planData,
        'features': featuresResults.isNotEmpty ? featuresResults.first : null,
      };
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _planTitle();
    final description = _planDescription();

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchPlanDetails(),
      builder: (context, snapshot) {
        String price = '0';
        List<String> featuresList = [];

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          final plan = data['plan'] as Map<String, dynamic>?;
          final planFeatures = data['features'] as Map<String, dynamic>?;

          if (plan != null) {
            price = (plan['monthly_price'] ?? '0').toString().replaceAll('.0', '');
          }

          if (planFeatures != null) {
            // Read dynamically resolved limits from DB row values
            final maxClinics = planFeatures['max_clinics'];
            final maxStaff = planFeatures['max_staff'];
            final maxPatients = planFeatures['max_patients'];

            featuresList.add(AppStrings.supportClinics((maxClinics as num?)?.toInt() ?? 0));
            featuresList.add(AppStrings.supportStaff((maxStaff as num?)?.toInt() ?? 0));
            featuresList.add(AppStrings.supportPatients((maxPatients as num?)?.toInt() ?? 0));

            // Parse jsonb features object: e.g. {"print": [{"value": true}, {"title": "الطباعة"}]}
            final rawFeatures = planFeatures['features'];
            if (rawFeatures is Map<String, dynamic>) {
              rawFeatures.forEach((key, value) {
                if (value is List && value.length >= 2) {
                  final featureValueMap = value[0];
                  final featureTitleMap = value[1];
                  if (featureValueMap is Map && featureTitleMap is Map) {
                    final isActive = featureValueMap['value'] == true;
                    final featureTitle = featureTitleMap['title'] as String?;
                    if (isActive && featureTitle != null) {
                      featuresList.add(featureTitle);
                    }
                  }
                }
              });
            }
          }
        } else {
          // Fallback loading defaults
          price = planKey == 'pro' || planKey == 'growth'
              ? '11'
              : planKey == 'enterprise' || planKey == 'professional'
                  ? '17'
                  : '7';
                  
          final clinicsMax = planKey == 'pro' || planKey == 'growth'
              ? 3
              : planKey == 'enterprise' || planKey == 'professional'
                  ? 10
                  : 1;
          final staffMax = planKey == 'pro' || planKey == 'growth'
              ? 5
              : planKey == 'enterprise' || planKey == 'professional'
                  ? 20
                  : 2;
          final patientsMax = planKey == 'pro' || planKey == 'growth'
              ? 2000
              : planKey == 'enterprise' || planKey == 'professional'
                  ? 10000
                  : 500;
          featuresList = [
            AppStrings.supportClinics(clinicsMax),
            AppStrings.supportStaff(staffMax),
            AppStrings.supportPatients(patientsMax),
          ];
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
              Text(description,
                   style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary)),
              
              const SizedBox(height: AppConstants.spaceMd),
              Divider(height: 1, thickness: 0.5, color: context.border),
              const SizedBox(height: AppConstants.spaceMd),
              
              Text(AppStrings.planFeatures, style: AppTextStyles.headlineSmall(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.spaceSm),
              ...featuresList.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: context.accent),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(child: Text(feature, style: AppTextStyles.bodyMedium(context))),
                  ],
                ),
              )),
              
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(price, style: AppTextStyles.headlineLarge(context).copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  )),
                  const SizedBox(width: 4),
                  Text(AppStrings.perMonth, style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
