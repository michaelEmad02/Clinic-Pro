import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';

class MagicLinkForm extends StatefulWidget {
  final Function(String) onSubmit;

  const MagicLinkForm({super.key, required this.onSubmit});

  @override
  State<MagicLinkForm> createState() => _MagicLinkFormState();
}

class _MagicLinkFormState extends State<MagicLinkForm> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      widget.onSubmit(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          child: TextField(
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
            decoration: InputDecoration(
              hintText: 'dr@clinic.com',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textHint,
              ),
              suffixIcon: const Icon(
                Icons.mail_outline,
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: AppColors.primaryContainer.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome), // magic button icon
              const SizedBox(width: 8),
              Text(
                AppStrings.sendMagicLink,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
