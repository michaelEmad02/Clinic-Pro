// ────────────────────────────────────────────────────────
// شاشة قبول الدعوة (AcceptInvitationScreen)
// تعرض تفاصيل الدعوة وتتيح القبول عبر Google أو Apple
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/accept_invitation_cubit.dart';
import '../manager/accept_invitation_state.dart';
import 'widgets/invitation_details_card.dart';
import 'widgets/invitation_expired_view.dart';

class AcceptInvitationScreen extends StatelessWidget {
  final String token;

  const AcceptInvitationScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // إنشاء Cubit جديد لكل شاشة دعوة وتحميل البيانات تلقائياً
      create: (_) => sl<AcceptInvitationCubit>()..loadInvitation(token),
      child: const _AcceptInvitationBody(),
    );
  }
}

/// محتوى الشاشة — يستمع لتغييرات الحالة
class _AcceptInvitationBody extends StatelessWidget {
  const _AcceptInvitationBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AcceptInvitationCubit, AcceptInvitationState>(
      listener: (context, state) {
        // عند نجاح القبول — التوجيه للـ Dashboard حسب الدور
        if (state is AcceptInvitationSuccess) {
          _showSuccessAndNavigate(context, state);
        }

        // عرض رسالة خطأ
        if (state is AcceptInvitationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        // حالة التحميل
        if (state is AcceptInvitationLoading) {
          return _buildLoadingView(context);
        }

        // الدعوة منتهية الصلاحية
        if (state is AcceptInvitationExpired) {
          return InvitationExpiredView.expired(message: state.message);
        }

        // الدعوة مقبولة مسبقاً
        if (state is AcceptInvitationAlreadyAccepted) {
          return InvitationExpiredView.alreadyAccepted(message: state.message);
        }

        // جاري تنفيذ القبول
        if (state is AcceptInvitationAccepting) {
          return _buildAcceptingView(context);
        }

        // الدعوة صالحة — عرض التفاصيل وأزرار القبول
        if (state is AcceptInvitationLoaded) {
          return _buildLoadedView(context, state);
        }

        // حالة الخطأ — عرض زر إعادة المحاولة
        if (state is AcceptInvitationError) {
          return _buildErrorView(context, state);
        }

        // الحالة الابتدائية
        return _buildLoadingView(context);
      },
    );
  }

  /// عرض مؤشر التحميل أثناء جلب بيانات الدعوة
  Widget _buildLoadingView(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppConstants.spaceMd),
            Text('جاري تحميل بيانات الدعوة...'),
          ],
        ),
      ),
    );
  }

  /// عرض مؤشر التحميل أثناء تنفيذ القبول
  Widget _buildAcceptingView(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              'جاري قبول الدعوة والانضمام...',
              style: AppTextStyles.bodyLarge(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض تفاصيل الدعوة الصالحة مع أزرار القبول
  Widget _buildLoadedView(
    BuildContext context,
    AcceptInvitationLoaded state,
  ) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // كارت تفاصيل الدعوة
                  InvitationDetailsCard(invitation: state.invitation),
                  const SizedBox(height: AppConstants.spaceXl),

                  // عنوان "سجّل الدخول للقبول"
                  Text(
                    'سجّل الدخول لقبول الدعوة',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),

                  // زر تسجيل الدخول بجوجل
                  _buildGoogleButton(context),
                  const SizedBox(height: AppConstants.spaceSm),

                  // زر تسجيل الدخول بـ Apple
                  _buildAppleButton(context),
                  const SizedBox(height: AppConstants.spaceLg),

                  // رابط العودة لتسجيل الدخول العادي
                  TextButton(
                    onPressed: () => context.go(RouteConstants.login),
                    child: Text(
                      'لديّ حساب بالفعل',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: AppColors.primary,
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

  /// زر تسجيل الدخول بجوجل
  Widget _buildGoogleButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () =>
          context.read<AcceptInvitationCubit>().acceptWithGoogle(),
      icon: Image.network(
        'https://www.google.com/favicon.ico',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.g_mobiledata, size: 24),
      ),
      label: const Text('المتابعة بحساب Google'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          side: BorderSide(color: context.borderColor),
        ),
      ),
    );
  }

  /// زر تسجيل الدخول بـ Apple
  Widget _buildAppleButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () =>
          context.read<AcceptInvitationCubit>().acceptWithApple(),
      icon: const Icon(Icons.apple, size: 24),
      label: const Text('المتابعة بحساب Apple'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        ),
      ),
    );
  }

  /// عرض حالة الخطأ مع زر إعادة المحاولة
  Widget _buildErrorView(
    BuildContext context,
    AcceptInvitationError state,
  ) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                Text(
                  state.message,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: context.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spaceXl),
                OutlinedButton.icon(
                  onPressed: () => context.go(RouteConstants.login),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('العودة لتسجيل الدخول'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spaceMd,
                      horizontal: AppConstants.spaceLg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusButton,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// عرض رسالة نجاح والتوجيه للـ Dashboard
  void _showSuccessAndNavigate(
    BuildContext context,
    AcceptInvitationSuccess state,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم قبول الدعوة بنجاح! مرحباً بك في ${state.clinicName}',
        ),
        backgroundColor: AppColors.accent,
        duration: const Duration(seconds: 2),
      ),
    );

    // التوجيه حسب الدور بعد تأخير قصير
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;

      if (state.role == StaffRoles.doctor.name) {
        context.go(RouteConstants.doctorDashboard);
      } else if (state.role == StaffRoles.secretary.name) {
        context.go(RouteConstants.secretaryDashboard);
      } else {
        context.go(RouteConstants.login);
      }
    });
  }
}
