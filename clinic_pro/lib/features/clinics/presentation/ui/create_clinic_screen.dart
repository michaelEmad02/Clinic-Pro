import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/entities/clinic_entity.dart';
import 'widgets/progress_indicator_bar.dart';
import 'widgets/clinic_form.dart';

class CreateClinicScreen extends StatelessWidget {
  final ClinicEntity? clinic;
  final bool isOnboarding;

  const CreateClinicScreen({
    super.key,
    this.clinic,
    this.isOnboarding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: isOnboarding
          ? null
          : AppBar(
              toolbarHeight: 56,
              backgroundColor: context.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon:  Icon(Icons.close, color: context.textSecondary),
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
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.surface,
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
                              ? AppStrings.clinicData
                              : (clinic != null
                                  ? AppStrings.editClinicData
                                  : AppStrings.addNewClinic),
                          style: AppTextStyles.headlineLarge(context).copyWith(
                            color: context.primary,
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
