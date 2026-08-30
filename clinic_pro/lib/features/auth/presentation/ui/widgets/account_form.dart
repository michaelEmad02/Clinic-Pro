import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/app_snackbar.dart';

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
  final _referralCodeController = TextEditingController();
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreedToTerms) {
        AppSnackbar.info(context, message: AppStrings.agreeToTerms);
        return;
      }
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
          context.go(RouteConstants.onboardingReferral);
        } else if (state is AuthError) {
          AppSnackbar.error(context, message: state.message);
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
                controller: _nameController,
                style: AppTextStyles.bodyMedium(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterFullName;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: AppStrings.isArabic ? 'د. أحمد العلي' : 'Dr. John Doe',
                  hintStyle: TextStyle(color: context.textHint),
                  suffixIcon:
                      Icon(Icons.person_outline, color: context.textHint),
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
                  suffixIcon:
                      Icon(Icons.email_outlined, color: context.textHint),
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
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.surfaceContainerLow,
                      border: Border(
                          right: BorderSide(
                              color: context.borderColor)),
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

            // Referral Code Field (Optional)
            Text(
              '${AppStrings.yourReferralCode} ${AppStrings.optional}',
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            // const SizedBox(height: 8),
            // Container(
            //   height: 46,
            //   decoration: BoxDecoration(
            //     color: context.surfaceColor,
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(color: context.borderColor),
            //   ),
            //   child: TextFormField(
            //     controller: _referralCodeController,
            //     textCapitalization: TextCapitalization.characters,
            //     style: AppTextStyles.bodyMedium(context).copyWith(
            //       color: context.textPrimary,
            //       fontWeight: FontWeight.w600,
            //     ),
            //     decoration: InputDecoration(
            //       hintText: 'DOC-XXXXX',
            //       hintStyle: AppTextStyles.bodyMedium(context).copyWith(
            //         color: context.textHint,
            //       ),
            //       prefixIcon: Icon(Icons.card_giftcard_outlined, color: context.primary, size: 20),
            //       border: InputBorder.none,
            //       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     ),
            //   ),
            // ),
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
                  borderRadius: BorderRadius.circular(AppConstants.radiusButton),
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