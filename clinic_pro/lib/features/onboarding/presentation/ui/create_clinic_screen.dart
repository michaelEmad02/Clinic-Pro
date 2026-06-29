import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../clinics/presentation/manager/clinics_state.dart';
import 'widgets/progress_indicator_bar.dart';
import 'widgets/clinic_form.dart';

class CreateClinicScreen extends StatelessWidget {
  final ClinicItem? clinic;
  final bool isOnboarding;

  const CreateClinicScreen({
    super.key,
    this.clinic,
    this.isOnboarding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isOnboarding
          ? null
          : AppBar(
              toolbarHeight: 56,
              backgroundColor: AppColors.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
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
                          isOnboarding
                              ? 'بيانات العيادة'
                              : (clinic != null
                                  ? 'تعديل بيانات العيادة'
                                  : 'إضافة عيادة جديدة'),
                          style: AppTextStyles.headlineLarge(context).copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        if (isOnboarding) ...[
                          const SizedBox(height: 8),
                          const ProgressIndicatorBar(
                            step: 2,
                            totalSteps: 3,
                            title: '',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Form
                    ClinicForm(
                      clinic: clinic,
                      isOnboarding: isOnboarding,
                      onSubmit: ({
                        required String name,
                        required String phone,
                        required String address,
                        String? logoUrl,
                      }) {
                        if (isOnboarding) {
                          context.go(RouteConstants.ownerDashboard);
                        } else {
                          Navigator.pop(context, {
                            'name': name,
                            'phone': phone,
                            'address': address,
                          });
                        }
                      },
                      onBack: () {
                        if (isOnboarding) {
                          context.go(RouteConstants.onboardingPlan);
                        } else {
                          Navigator.pop(context);
                        }
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
