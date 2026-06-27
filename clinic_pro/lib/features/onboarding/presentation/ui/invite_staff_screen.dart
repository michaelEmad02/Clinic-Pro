import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../manager/onboarding_cubit.dart';
import '../manager/onboarding_state.dart';

class InviteStaffScreen extends StatefulWidget {
  const InviteStaffScreen({super.key});

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final List<TextEditingController> _emailControllers = [TextEditingController()];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addEmailField() {
    setState(() {
      _emailControllers.add(TextEditingController());
    });
  }

  void _removeEmailField(int index) {
    if (_emailControllers.length > 1) {
      setState(() {
        _emailControllers[index].dispose();
        _emailControllers.removeAt(index);
      });
    }
  }

  void _onInvitePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final emails = _emailControllers
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      
      if (emails.isNotEmpty) {
        context.read<OnboardingCubit>().inviteStaff(emails);
      } else {
        _onSkipPressed();
      }
    }
  }

  void _onSkipPressed() {
    // تجاوز والدخول إلى اللوحة
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
          appBar: AppBar(
            title: const Text('دعوة الطاقم'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.pop();
              },
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : _onSkipPressed,
                child: Text(
                  'تخطي',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppConstants.spaceLg),
                      children: [
                        Text(
                          'أضف فريق عملك',
                          style: AppTextStyles.headlineMedium(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spaceXs),
                        Text(
                          'أدخل عناوين البريد الإلكتروني للأطباء والموظفين لدعوتهم للانضمام للعيادة. سيتم إرسال رابط دعوة لهم.',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spaceXl),

                        ...List.generate(_emailControllers.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailControllers[index],
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'البريد الإلكتروني',
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                                      ),
                                    ),
                                    validator: (value) {
                                      // التحقق فقط إذا لم يكن الحقل الأخير وهو فارغ
                                      if (index < _emailControllers.length - 1 || _emailControllers.length == 1) {
                                        if (value != null && value.isNotEmpty && !value.contains('@')) {
                                          return 'الرجاء إدخال بريد إلكتروني صحيح';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (_emailControllers.length > 1) ...[
                                  const SizedBox(width: AppConstants.spaceSm),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
                                    onPressed: () => _removeEmailField(index),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: AppConstants.spaceSm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _addEmailField,
                            icon: const Icon(Icons.add, color: AppColors.primary),
                            label: Text(
                              'إضافة شخص آخر',
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // زر المتابعة
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spaceLg),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onInvitePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
                        minimumSize: const Size(double.infinity, 0),
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
                              'إرسال الدعوات والبدء',
                              style: AppTextStyles.headlineSmall(context).copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
