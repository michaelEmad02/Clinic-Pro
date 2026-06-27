import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import 'widgets/progress_indicator_bar.dart';
import 'widgets/plan_card.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1024),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Indicator
                  const SizedBox(
                    width: 896,
                    child: ProgressIndicatorBar(
                      step: 1,
                      totalSteps: 3,
                      title: 'اختيار الخطة',
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Header
                  Text(
                    'اختر خطتك',
                    style: AppTextStyles.headlineLarge(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اكتشف الباقة التي تناسب حجم عيادتك وتطلعاتك.',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Pricing Cards Container
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: _buildStarterPlan(context)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildGrowthPlan(context)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildEnterprisePlan(context)),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildStarterPlan(context),
                            const SizedBox(height: 24),
                            _buildGrowthPlan(context),
                            const SizedBox(height: 24),
                            _buildEnterprisePlan(context),
                          ],
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Main Action Button
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to create clinic
                          context.go(RouteConstants.onboardingClinic);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primaryContainer.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: AppTextStyles.headlineMedium(context).copyWith(
                                  color: AppColors.onPrimary,
                                ),
                                children: const [
                                  TextSpan(text: 'ابدأ التجربة المجانية '),
                                  TextSpan(
                                    text: '14',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: ' يوم'),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_back), // Arrow pointing left in RTL
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarterPlan(BuildContext context) {
    return PlanCard(
      title: 'Starter',
      price: '\$29',
      priceSubtext: '/ شهرياً',
      features: const [
        PlanFeature(text: 'طبيب واحد'),
        PlanFeature(text: 'مريض', numericValue: '500'),
        PlanFeature(text: 'تقارير متقدمة', included: false),
      ],
      buttonText: 'اختيار الخطة',
      onSelect: () {
        context.go(RouteConstants.onboardingClinic);
      },
    );
  }

  Widget _buildGrowthPlan(BuildContext context) {
    return PlanCard(
      title: 'Growth',
      price: '\$79',
      priceSubtext: '/ شهرياً',
      isFeatured: true,
      badgeText: 'الأكثر طلباً',
      features: const [
        PlanFeature(text: 'أطباء', numericValue: '5'),
        PlanFeature(text: 'مرضى غير محدود'),
        PlanFeature(text: 'تقارير + رسائل SMS'),
      ],
      buttonText: 'اختيار الخطة',
      onSelect: () {
        context.go(RouteConstants.onboardingClinic);
      },
    );
  }

  Widget _buildEnterprisePlan(BuildContext context) {
    return PlanCard(
      title: 'Enterprise',
      price: 'مخصص',
      priceSubtext: '',
      features: const [
        PlanFeature(text: 'أطباء غير محدود'),
        PlanFeature(text: 'مرضى غير محدود'),
        PlanFeature(text: 'White label (هوية مخصصة)'),
      ],
      buttonText: 'تواصل معنا',
      onSelect: () {
        // Contact us action
      },
    );
  }
}
