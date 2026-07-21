import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({
    super.key,
  });

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  @override
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.agreeToTerms),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      // Navigate to plan selection on success
      context.read<AuthCubit>().register(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phone: _mobileController.text,
          country: "",
          address: "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistrationSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: Text(AppStrings.accountVerification, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              content: Text(
                AppStrings.verificationEmailSent,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.go(RouteConstants.onboardingPlan);
                  },
                  child: Text(AppStrings.continueLabel, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name Field
            Text(
              AppStrings.fullName,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
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
                controller: _nameController,
                style: AppTextStyles.bodyMedium(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterFullName;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'د. أحمد العلي',
                  hintStyle: TextStyle(color: context.textHint),
                  suffixIcon: Icon(Icons.person_outline, color: context.textHint),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            Text(
              AppStrings.email,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
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
                  fontSize: 14,
                  color: context.textPrimary,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterEmail;
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return AppStrings.enterValidEmail;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'example@clinic.com',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: context.textHint,
                  ),
                  suffixIcon: Icon(Icons.email_outlined, color: context.textHint),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            Text(
              AppStrings.password,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
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
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: context.textPrimary,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterPassword;
                  }
                  if (value.length < 6) {
                    return AppStrings.passwordLengthError;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: context.textHint,
                  ),
                  // زر إظهار/إخفاء كلمة المرور
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: context.textHint,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mobile Number Field
            Text(
              AppStrings.phoneNumber,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  // Prefix
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? AppColors.darkBackground
                          : AppColors.surfaceContainerLow,
                      border: Border(
                          right: BorderSide(
                              color: context.borderColor)), // because of LTR
                    ),
                    child: Text(
                      '+20',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  // Input
                  Expanded(
                    child: TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.enterPhone;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '5X XXX XXXX',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.textHint,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Terms Checkbox
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (val) {
                    setState(() {
                      _agreedToTerms = val ?? false;
                    });
                  },
                  activeColor: context.primaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                Expanded(
                  child: Text(
                    AppStrings.agreeToTerms,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryContainer,
                foregroundColor: context.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: context.primaryContainer.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      AppStrings.createAccount,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        color: context.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
