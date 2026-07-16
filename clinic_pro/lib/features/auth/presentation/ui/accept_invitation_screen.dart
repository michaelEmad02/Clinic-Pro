import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/constants/staff_roles.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';

class AcceptInvitationScreen extends StatefulWidget {
  final String token;
  const AcceptInvitationScreen({super.key, required this.token});

  @override
  State<AcceptInvitationScreen> createState() => _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState extends State<AcceptInvitationScreen> {
  void _onAcceptPressed() {
    // محاكاة قبول الدعوة وتسجيل الدخول
    context.read<AuthCubit>().login('invitee@clinicpro.com', 'password');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final role = state.user.role;
          if (role == StaffRoles.owner) {
            context.go(RouteConstants.ownerDashboard);
          } else if (role == StaffRoles.doctor) {
            context.go(RouteConstants.doctorDashboard);
          } else if (role == StaffRoles.secretary) {
            context.go(RouteConstants.secretaryDashboard);
          } else {
            context.go(RouteConstants.login);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    Text(
                      AppStrings.joinInvitation,
                      style: AppTextStyles.headlineLarge(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    Text(
                      AppStrings.invitationDescription,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceXl),
                    ElevatedButton(
                      onPressed: isLoading ? null : _onAcceptPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppStrings.acceptAndLogin,
                              style: AppTextStyles.headlineSmall(context).copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
