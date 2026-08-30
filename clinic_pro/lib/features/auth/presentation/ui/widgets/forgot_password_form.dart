// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على نموذج إدخال البريد لاستعادة كلمة المرور
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';

class ForgotPasswordForm extends StatefulWidget {
  final Function(String email) onSubmit;
  final bool isLoading;

  const ForgotPasswordForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      widget.onSubmit(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // حقل البريد الإلكتروني
          Text(
            AppStrings.email,
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
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
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
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.isArabic
                      ? 'الرجاء إدخال البريد الإلكتروني'
                      : 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return AppStrings.isArabic
                      ? 'الرجاء إدخال بريد إلكتروني صحيح'
                      : 'Please enter a valid email';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'dr@clinic.com',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.textHint,
                ),
                suffixIcon: Icon(
                  Icons.mail_outline,
                  color: context.textHint,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // زر إرسال الرابط
          ElevatedButton(
            onPressed: widget.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryContainer,
              foregroundColor: context.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppConstants.radiusButton),
                ),
              ),
              elevation: 4,
              shadowColor: context.primaryContainer.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.send_rounded, size: 18),
                const SizedBox(width: AppConstants.spaceSm),
                Flexible(
                  child: Text(
                    AppStrings.sendResetLink,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      color: context.onPrimaryContainer,
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
