import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/settings_cubit.dart';
import '../../manager/settings_state.dart';

class ClinicPickerSheet extends StatelessWidget {
  const ClinicPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: const ClinicPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.spaceSm),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
            child: Row(
              children: [
                Text('اختر العيادة', style: AppTextStyles.headlineSmall(context)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
                child: Column(
                  children: [
                    ...state.availableClinics.map((clinic) {
                      final id = clinic['id'] as String;
                      final name = clinic['name'] as String;
                      final address = clinic['address'] as String;
                      final isActive = id == state.clinicId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                        child: _buildClinicCard(
                          context,
                          name: name,
                          address: address,
                          isActive: isActive,
                          onTap: () {
                            if (!isActive) {
                              context.read<SettingsCubit>().changeClinic(id);
                            }
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppConstants.spaceMd),
        ],
      ),
    );
  }

  Widget _buildClinicCard(
    BuildContext context, {
    required String name,
    required String address,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusButton),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppColors.surface : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: isActive ? AppColors.primaryFixedDim : AppColors.border),
              ),
              child: const Icon(Icons.local_hospital, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.headlineSmall(context).copyWith(
                    color: isActive ? AppColors.primary : AppColors.onSurface,
                  )),
                  Text(address, style: AppTextStyles.bodyMedium(context).copyWith(
                    color: isActive ? AppColors.onSurfaceVariant : AppColors.textSecondary,
                  )),
                ],
              ),
            ),
            if (isActive)
              Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: AppColors.successText, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
