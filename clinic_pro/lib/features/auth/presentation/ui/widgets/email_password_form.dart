// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على نموذج تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';

class EmailPasswordForm extends StatefulWidget {
  final Function(String email, String password) onSubmit;

  const EmailPasswordForm({super.key, required this.onSubmit});

  @override
  State<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // استخدام ValueNotifier للتحكم في إظهار/إخفاء كلمة المرور لتجنب استخدام setState
  final ValueNotifier<bool> _isObscured = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isObscured.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      widget.onSubmit(email, password);
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
          const SizedBox(height: 8),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // حقل كلمة المرور
          Text(
            AppStrings.password,
            style: AppTextStyles.headlineSmall(context),
          ),
          const SizedBox(height: 8),
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
              valueListenable: _isObscured,
              builder: (context, obscured, child) {
                return TextFormField(
                  controller: _passwordController,
                  obscureText: obscured,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.isArabic
                          ? 'الرجاء إدخال كلمة المرور'
                          : 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return AppStrings.isArabic
                          ? 'يجب ألا تقل كلمة المرور عن 6 أحرف'
                          : 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.textHint,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: context.textHint,
                      ),
                      onPressed: () {
                        _isObscured.value = !obscured;
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),

          // رابط نسيت كلمة المرور؟
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                context.push(RouteConstants.forgotPassword);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceXs,
                  vertical: AppConstants.spaceXs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: context.primary,
              ),
              child: Text(
                AppStrings.forgotPassword,
                style: AppTextStyles.caption(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          // زر تسجيل الدخول
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryContainer,
              foregroundColor: context.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusButton)),
              ),
              elevation: 4,
              shadowColor: context.primaryContainer.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppStrings.login,
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
