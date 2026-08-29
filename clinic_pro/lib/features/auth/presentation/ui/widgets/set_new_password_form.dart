// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على نموذج إدخال وتأكيد كلمة المرور الجديدة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';

class SetNewPasswordForm extends StatefulWidget {
  final Function(String newPassword) onSubmit;
  final bool isLoading;

  const SetNewPasswordForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<SetNewPasswordForm> createState() => _SetNewPasswordFormState();
}

class _SetNewPasswordFormState extends State<SetNewPasswordForm> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> _isPasswordObscured = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isConfirmObscured = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _isPasswordObscured.dispose();
    _isConfirmObscured.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final password = _passwordController.text;
      widget.onSubmit(password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // حقل كلمة المرور الجديدة
          Text(
            AppStrings.newPassword,
            style: AppTextStyles.headlineSmall(context),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isPasswordObscured,
              builder: (context, obscured, child) {
                return TextFormField(
                  controller: _passwordController,
                  obscureText: obscured,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  enabled: !widget.isLoading,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور الجديدة';
                    }
                    if (value.length < 6) {
                      return 'يجب ألا تقل كلمة المرور عن 6 أحرف';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: () {
                        _isPasswordObscured.value = !obscured;
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                      vertical: 14,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // حقل تأكيد كلمة المرور الجديدة
          Text(
            AppStrings.confirmNewPassword,
            style: AppTextStyles.headlineSmall(context),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isConfirmObscured,
              builder: (context, obscured, child) {
                return TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: obscured,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  enabled: !widget.isLoading,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور';
                    }
                    if (value != _passwordController.text) {
                      return AppStrings.passwordsDoNotMatch;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: () {
                        _isConfirmObscured.value = !obscured;
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                      vertical: 14,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // زر التحديث
          ElevatedButton(
            onPressed: widget.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppConstants.radiusButton),
                ),
              ),
              elevation: 4,
              shadowColor: AppColors.primaryContainer.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                const SizedBox(width: AppConstants.spaceSm),
                Flexible(
                  child: Text(
                    AppStrings.updatePasswordBtn,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
