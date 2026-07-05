import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
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
        return 'الباقة الاحترافية (Pro)';
      case 'enterprise':
      case 'professional':
        return 'باقة المؤسسات (Enterprise)';
      case 'basic':
      default:
        return 'الباقة الأساسية (Basic)';
    }
  }

  String _planDescription() {
    switch (planKey) {
      case 'pro':
      case 'growth':
        return 'الأكثر طلباً، مثالية للعيادات المتوسطة والنمو السريع.';
      case 'enterprise':
      case 'professional':
        return 'مثالية للمراكز الطبية الكبيرة والمستشفيات المتكاملة.';
      case 'basic':
      default:
        return 'مثالية للعيادات الناشئة والممارسين المستقلين.';
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

            featuresList.add('دعم حتى $maxClinics عيادات نشطة');
            featuresList.add('دعم حتى $maxStaff مستخدمين من طاقم العمل');
            featuresList.add('دعم حتى $maxPatients مريض مسجل');

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
                  
          featuresList = planKey == 'pro' || planKey == 'growth'
              ? ['دعم حتى 3 عيادات نشطة', 'دعم حتى 5 مستخدمين', 'دعم حتى 2000 مريض']
              : planKey == 'enterprise' || planKey == 'professional'
                  ? ['دعم حتى 10 عيادات نشطة', 'دعم حتى 20 مستخدم', 'دعم حتى 10000 مريض']
                  : ['دعم عيادة واحدة فقط', 'دعم مستخدمين اثنين', 'أقصى عدد مرضى: 500 مريض'];
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border, width: 0.5),
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
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          planStatus == 'trial' || planStatus == 'trail'
                              ? 'تجربة مجانية'
                              : planStatus == 'active'
                                  ? 'نشط'
                                  : planStatus,
                          style: AppTextStyles.labelChip(context).copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(description,
                  style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
              
              const SizedBox(height: AppConstants.spaceMd),
              const Divider(height: 1, thickness: 0.5, color: AppColors.border),
              const SizedBox(height: AppConstants.spaceMd),
              
              Text('ميزات الخطة:', style: AppTextStyles.headlineSmall(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.spaceSm),
              ...featuresList.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.accent),
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
                  Text('دولار / شهرياً', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
