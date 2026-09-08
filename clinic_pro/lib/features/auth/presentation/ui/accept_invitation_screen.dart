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
import '../../../../core/strings/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/accept_invitation_cubit.dart';
import '../manager/accept_invitation_state.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../manager/auth_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'widgets/auth_branding_panel.dart';
import 'widgets/invitation_details_card.dart';
import 'widgets/invitation_expired_view.dart';
import 'widgets/optional_staff_info_fields.dart';

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
class _AcceptInvitationBody extends StatefulWidget {
  const _AcceptInvitationBody();

  @override
  State<_AcceptInvitationBody> createState() => _AcceptInvitationBodyState();
}

class _AcceptInvitationBodyState extends State<_AcceptInvitationBody> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isObscure = ValueNotifier<bool>(true);
  bool _isNameInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialtyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _isObscure.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AcceptInvitationCubit, AcceptInvitationState>(
      listener: (context, state) {
        // عند نجاح القبول — تحديث AuthCubit والتوجيه للـ Dashboard
        if (state is AcceptInvitationSuccess) {
          _showSuccessAndNavigate(context, state);
        }

        // عرض رسالة خطأ
        if (state is AcceptInvitationError) {
          AppSnackbar.error(context, message: state.message);
        }

        // تعبئة الاسم الافتراضي عند اكتمال تحميل الدعوة لأول مرة
        if (state is AcceptInvitationLoaded && !_isNameInitialized) {
          if (state.invitation.name != null && state.invitation.name!.isNotEmpty) {
            _nameController.text = state.invitation.name!;
          }
          _isNameInitialized = true;
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
    return const Scaffold(
      body: Center(child: AppLoadingWidget()),
    );
  }

  /// عرض مؤشر التحميل أثناء تنفيذ القبول
  Widget _buildAcceptingView(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: const Center(child: AppLoadingWidget()),
    );
  }

  /// عرض تفاصيل الدعوة الصالحة مع فورم كلمة المرور وخيارات القبول
  Widget _buildLoadedView(
    BuildContext context,
    AcceptInvitationLoaded state,
  ) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final formContent = SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // كارت تفاصيل الدعوة (مع قفل الاسم إذا كان المستخدم مسجلاً مسبقاً)
                InvitationDetailsCard(
                  invitation: state.invitation,
                  nameController: state.invitation.isExistingUser ? null : _nameController,
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // حقول البيانات الإضافية (الهاتف، العنوان، والتخصص للأطباء)
                // تظهر فقط للمستخدم الجديد، وتُخفى تماماً في حال كان المستخدم مسجلاً مسبقاً في النظام
                if (!state.invitation.isExistingUser) ...[
                  OptionalStaffInfoFields(
                    phoneController: _phoneController,
                    addressController: _addressController,
                    specialtyController: _specialtyController,
                    isDoctor: state.invitation.role == StaffRoles.doctor,
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                ],

                // نموذج إدخال كلمة المرور مع إيميل معروض ومقفل (Disabled)
                _buildPasswordForm(context, state),
                const SizedBox(height: AppConstants.spaceLg),

                // فاصل أو
                Row(
                  children: [
                    Expanded(child: Divider(color: context.borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.orText,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: context.borderColor)),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // أزرار الدخول السريع عبر Google / Apple
                _buildGoogleButton(context, state),
                // const SizedBox(height: AppConstants.spaceSm),
                // _buildAppleButton(context),
                // const SizedBox(height: AppConstants.spaceLg),

                // // رابط العودة لتسجيل الدخول العادي
                // TextButton(
                //   onPressed: () => context.go(RouteConstants.login),
                //   child: Text(
                //     AppStrings.isArabic ? 'لديّ حساب بالفعل' : 'I already have an account',
                //     style: AppTextStyles.bodyMedium(context).copyWith(
                //       color: context.primary,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: isMobile
          ? formContent
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: AuthBrandingPanel(
                    title: AppStrings.isArabic ? 'دعوة انضمام للطاقم الطبي' : 'Medical Staff Invitation',
                    subtitle: AppStrings.isArabic
                        ? 'يسعدنا انضمامك لبرنامج إدارة العيادات ClinicPro'
                        : 'We are delighted to have you join ClinicPro management system',
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: formContent,
                ),
              ],
            ),
    );
  }

  /// نموذج إنشاء كلمة المرور والبريد المقفل
  Widget _buildPasswordForm(
    BuildContext context,
    AcceptInvitationLoaded state,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان البريد الإلكتروني المدعو (مقفل للعرض فقط منعاً للتحايل)
          Text(
            AppStrings.email,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: AppConstants.spaceMd,
            ),
            decoration: BoxDecoration(
              color: context.borderColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: context.textSecondary),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    state.invitation.email,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.check_circle_outline_rounded, size: 18, color: context.primary),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // حقل كلمة المرور
          Text(
            state.invitation.isExistingUser
                ? (AppStrings.isArabic ? 'كلمة مرور حسابك الحالي' : 'Current Account Password')
                : AppStrings.password,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<bool>(
            valueListenable: _isObscure,
            builder: (context, isObscure, _) {
              return TextFormField(
                controller: _passwordController,
                obscureText: isObscure,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => _isObscure.value = !isObscure,
                  ),
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.isArabic
                        ? 'الرجاء إدخال كلمة المرور'
                        : 'Please enter your password';
                  }
                  if (val.length < 6) {
                    return AppStrings.isArabic
                        ? 'كلمة المرور يجب ألا تقل عن 6 أحرف'
                        : 'Password must be at least 6 characters';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // زر قبول الدعوة الأساسي بكلمة المرور
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final password = _passwordController.text;
                // للمستخدم المسجل مسبقاً لا نرسل أي تعديلات على بياناته الشخصية
                final isExisting = state.invitation.isExistingUser;
                final customName = isExisting ? null : _nameController.text.trim();
                final phone = isExisting ? null : _phoneController.text.trim();
                final address = isExisting ? null : _addressController.text.trim();
                final specialty = isExisting ? null : _specialtyController.text.trim();
                context.read<AcceptInvitationCubit>().acceptWithPassword(
                      password: password,
                      updatedName: (customName != null && customName.isNotEmpty) ? customName : null,
                      updatedPhone: (phone != null && phone.isNotEmpty) ? phone : null,
                      updatedAddress: (address != null && address.isNotEmpty) ? address : null,
                      updatedSpecialty: (specialty != null && specialty.isNotEmpty) ? specialty : null,
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
            ),
            child: Text(
              state.invitation.isExistingUser
                  ? (AppStrings.isArabic ? 'قبول الدعوة والدخول للحساب' : 'Accept & Sign In')
                  : (AppStrings.isArabic ? 'قبول الدعوة وتعيين كلمة المرور' : 'Accept & Set Password'),
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// زر تسجيل الدخول بجوجل
  Widget _buildGoogleButton(
    BuildContext context,
    AcceptInvitationLoaded state,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        final isExisting = state.invitation.isExistingUser;
        final customName = isExisting ? null : _nameController.text.trim();
        final phone = isExisting ? null : _phoneController.text.trim();
        final address = isExisting ? null : _addressController.text.trim();
        final specialty = isExisting ? null : _specialtyController.text.trim();
        context.read<AcceptInvitationCubit>().acceptWithGoogle(
              updatedName: (customName != null && customName.isNotEmpty) ? customName : null,
              updatedPhone: (phone != null && phone.isNotEmpty) ? phone : null,
              updatedAddress: (address != null && address.isNotEmpty) ? address : null,
              updatedSpecialty: (specialty != null && specialty.isNotEmpty) ? specialty : null,
            );
      },
      icon: Image.network(
        'https://www.google.com/favicon.ico',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
      ),
      label: Text(AppStrings.continueWithGoogle),
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

  // /// زر تسجيل الدخول بـ Apple
  // Widget _buildAppleButton(BuildContext context) {
  //   return ElevatedButton.icon(
  //     onPressed: () {
  //       final customName = _nameController.text.trim();
  //       final phone = _phoneController.text.trim();
  //       final address = _addressController.text.trim();
  //       final specialty = _specialtyController.text.trim();
  //       context.read<AcceptInvitationCubit>().acceptWithApple(
  //             updatedName: customName.isNotEmpty ? customName : null,
  //             updatedPhone: phone.isNotEmpty ? phone : null,
  //             updatedAddress: address.isNotEmpty ? address : null,
  //             updatedSpecialty: specialty.isNotEmpty ? specialty : null,
  //           );
  //     },
  //     icon: const Icon(Icons.apple, size: 24),
  //     label: Text(AppStrings.continueWithApple),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.black,
  //       foregroundColor: Colors.white,
  //       padding: const EdgeInsets.symmetric(
  //         vertical: AppConstants.spaceMd,
  //       ),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(AppConstants.radiusButton),
  //       ),
  //     ),
  //   );
  // }

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
                    color: context.dangerBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: context.danger,
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
                  label: Text(AppStrings.backToLogin),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primary,
                    side: BorderSide(color: context.primary),
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

  /// عرض رسالة نجاح وتحديث حالة الجلسة والتوجيه للـ Dashboard
  void _showSuccessAndNavigate(
    BuildContext context,
    AcceptInvitationSuccess state,
  ) async {
    AppSnackbar.success(
      context,
      message: AppStrings.isArabic
          ? 'تم قبول الدعوة بنجاح! مرحباً بك في ${state.clinicName}'
          : 'Invitation accepted successfully! Welcome to ${state.clinicName}',
    );

    // تحديث حالة المصادقة والإعدادات لجلب العيادة والصلاحيات مباشرة
    try {
      await context.read<AuthCubit>().checkAuthStatus();
      if (context.mounted) {
        final authState = context.read<AuthCubit>().state;
        if (authState.user != null) {
          await context.read<SettingsCubit>().loadSettings(
                authState.user!.role,
                authState.user!.id,
                authState.user!.ownerId,
              );
        }
      }
    } catch (_) {}

    // التوجيه حسب الدور بعد اكتمال المزامنة
    if (!context.mounted) return;

    if (state.role == StaffRoles.doctor.name) {
      context.go(RouteConstants.doctorDashboard);
    } else if (state.role == StaffRoles.secretary.name) {
      context.go(RouteConstants.secretaryDashboard);
    } else {
      context.go(RouteConstants.login);
    }
  }
}
