import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import 'widgets/progress_indicator_bar.dart';
import 'widgets/clinic_form.dart';

class CreateClinicScreen extends StatelessWidget {
  const CreateClinicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Column(
                      children: [
                        Text(
                          'بيانات العيادة',
                          style: AppTextStyles.headlineLarge(context).copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const ProgressIndicatorBar(
                          step: 2,
                          totalSteps: 3,
                          title: '',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Form
                    ClinicForm(
                      onSubmit: () {
                        // After creating clinic, typically go to owner dashboard
                        context.go(RouteConstants.ownerDashboard);
                      },
                      onBack: () {
                        context.go(RouteConstants.onboardingPlan);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
