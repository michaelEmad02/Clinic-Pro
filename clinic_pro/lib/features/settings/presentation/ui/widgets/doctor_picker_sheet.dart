// ────────────────────────────────────────────────────────
// شريحة اختيار الطبيب النشط للسكرتيرة (DoctorPickerSheet)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/settings_cubit.dart';
import '../../manager/settings_state.dart';

class DoctorPickerSheet extends StatelessWidget {
  const DoctorPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: const DoctorPickerSheet(),
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
              width: 40,
              height: 4,
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
                Text('اختر الطبيب الحالي', style: AppTextStyles.headlineSmall(context)),
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
              if (state.secretaryDoctors.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  child: Center(
                    child: Text(
                      'لا يوجد أطباء مسجلين في جدولك لهذه العيادة.',
                      style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
                child: Column(
                  children: state.secretaryDoctors.map((doc) {
                    final docId = doc['doctor_id'] as String;
                    final name = doc['name'] as String;
                    final specialty = doc['specialty'] as String;
                    final avatarUrl = doc['avatar_url'] as String?;
                    final isActive = docId == state.currentDoctorId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                      child: InkWell(
                        onTap: () {
                          context.read<SettingsCubit>().changeActiveDoctor(docId);
                          Navigator.pop(context);
                        },
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
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isActive ? AppColors.surface : AppColors.primaryLight,
                                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl == null
                                    ? Text(
                                        name.isNotEmpty ? name[0] : '?',
                                        style: AppTextStyles.headlineSmall(context).copyWith(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppConstants.spaceMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTextStyles.headlineSmall(context).copyWith(
                                        color: isActive ? AppColors.primary : AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      specialty,
                                      style: AppTextStyles.bodyMedium(context).copyWith(
                                        color: isActive ? AppColors.onSurfaceVariant : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.successBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, color: AppColors.successText, size: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppConstants.spaceMd),
        ],
      ),
    );
  }
}
