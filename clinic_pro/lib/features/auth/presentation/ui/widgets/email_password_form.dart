// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على نموذج تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
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
              borderRadius: BorderRadius.circular(10),
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
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                if (!value.contains('@')) {
                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'dr@clinic.com',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHint,
                ),
                suffixIcon: Icon(
                  Icons.mail_outline,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              borderRadius: BorderRadius.circular(10),
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
                      return 'الرجاء إدخال كلمة المرور';
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
                        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textHint,
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
          const SizedBox(height: 24),

          // زر تسجيل الدخول
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              elevation: 4,
              shadowColor: AppColors.primaryContainer.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login),
                const SizedBox(width: 8),
                Text(
                  AppStrings.login,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: AppColors.onPrimaryContainer,
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
