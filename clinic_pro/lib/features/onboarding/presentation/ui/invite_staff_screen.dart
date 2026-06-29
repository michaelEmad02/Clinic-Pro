import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../manager/onboarding_cubit.dart';
import '../manager/onboarding_state.dart';
import 'widgets/progress_indicator_bar.dart';
import 'widgets/invite_form_row.dart';
import 'widgets/invited_staff_list.dart';

/// شاشة دعوة الموظفين — الخطوة 3 من 3 في عملية الـ Onboarding
/// تتيح للمالك إضافة أعضاء الفريق عن طريق البريد الإلكتروني مع تحديد الصلاحية
class InviteStaffScreen extends StatefulWidget {
  const InviteStaffScreen({super.key});

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final _emailController = TextEditingController();
  StaffRoles _selectedRole = StaffRoles.doctor;

  /// قائمة الموظفين المدعوين (Mock Data)
  final List<InvitedStaffItem> _invitedStaff = [];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// إضافة موظف جديد إلى القائمة بعد التحقق من صحة البريد
  void _addInvitee() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      // عرض رسالة خطأ بسيطة
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال بريد إلكتروني صحيح'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // التحقق من عدم التكرار
    final alreadyExists = _invitedStaff.any((s) => s.email == email);
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذا البريد مضاف مسبقاً'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // // الحصول على اسم الصلاحية بالعربية
    // final roleLabel = StaffRole.values
    //     .firstWhere((r) => r == _selectedRole).label  ;

    setState(() {
      _invitedStaff.add(InvitedStaffItem(
        email: email,
        role: _selectedRole,
      ));
      _emailController.clear();
    });
  }

  /// حذف موظف من القائمة
  void _removeInvitee(int index) {
    setState(() {
      _invitedStaff.removeAt(index);
    });
  }

  /// إرسال الدعوات والمتابعة
  void _onSendInvitations() {
    if (_invitedStaff.isEmpty) {
      _onSkip();
      return;
    }

    final emails = _invitedStaff.map((s) => s.email).toList();
    context.read<OnboardingCubit>().inviteStaff(emails);
  }

  /// تخطي الدعوات والذهاب للوحة التحكم
  void _onSkip() {
    context.go(RouteConstants.ownerDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingStaffInvited) {
          context.go(RouteConstants.ownerDashboard);
        }
      },
      builder: (context, state) {
        final isLoading = state is OnboardingLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenEdgeH,
                  vertical: AppConstants.spaceXl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusCard),
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
                        // ── القسم العلوي: Header ──
                        _buildHeader(context),

                        // ── المحتوى الرئيسي ──
                        _buildContent(context),

                        // ── الأزرار السفلية ──
                        _buildFooter(context, isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء القسم العلوي: زر الرجوع + مؤشر الخطوات + العنوان + الوصف
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // صف زر الرجوع + مؤشر الخطوات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر الرجوع
              Material(
                color: AppColors.surfaceContainerLow,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => context.pop(),
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),

              // مؤشر الخطوات
              const Expanded(
                child: ProgressIndicatorBar(
                  step: 3,
                  totalSteps: 3,
                  title: '',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceMd),

          // العنوان
          Text(
            'دعوة الفريق',
            style: AppTextStyles.headlineLarge(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),

          // الوصف
          Text(
            'قم بدعوة زملائك في العيادة للانضمام إلى النظام بصلاحيات محددة.',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء المحتوى الرئيسي: نموذج الإدخال + قائمة المدعوين
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // نموذج إضافة موظف
          InviteFormRow(
            emailController: _emailController,
            selectedRole: _selectedRole,
            onRoleChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedRole = val;
                });
              }
            },
            onAdd: _addInvitee,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // قائمة المدعوين
          InvitedStaffList(
            items: _invitedStaff,
            onRemove: _removeInvitee,
          ),
        ],
      ),
    );
  }

  /// بناء الأزرار السفلية: إرسال الدعوات + تخطي
  Widget _buildFooter(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        0,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // زر إرسال الدعوات
          ElevatedButton(
            onPressed: isLoading ? null : _onSendInvitations,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
              elevation: 0,
              shadowColor: AppColors.primary.withOpacity(0.25),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, size: 20),
                      const SizedBox(width: AppConstants.spaceSm),
                      Text(
                        'إرسال الدعوات',
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: AppConstants.spaceSm),

          // زر تخطي
          TextButton(
            onPressed: isLoading ? null : _onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
            ),
            child: Text(
              'تخطي الآن',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
