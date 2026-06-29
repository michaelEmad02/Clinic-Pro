import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/settings_cubit.dart';

class SettingsLogoutSection extends StatelessWidget {
  const SettingsLogoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.read<SettingsCubit>().logout(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.dangerBg, width: 2),
          backgroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          ),
        ),
        icon: const Icon(Icons.logout, color: AppColors.danger, size: 20),
        label: Text(
          'تسجيل الخروج',
          style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.danger),
        ),
      ),
    );
  }
}
