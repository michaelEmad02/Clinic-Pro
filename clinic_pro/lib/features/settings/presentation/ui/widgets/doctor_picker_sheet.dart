import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
import '../../manager/settings_cubit.dart';
import '../../manager/settings_state.dart';

class DoctorPickerSheet extends StatelessWidget {
  const DoctorPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SettingsCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: const DoctorPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
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
                  color: context.surfaceContainerLow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
            child: Row(
              children: [
                Text(AppStrings.selectDoctor, style: AppTextStyles.headlineSmall(context)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.textSecondary),
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
                      AppStrings.noDoctorsAvailable,
                      style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary),
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
                          if (user != null) {
                            context.read<SettingsCubit>().changeActiveDoctor(
                                  user.id,
                                  state.clinicEntity?.id ?? '',
                                  docId,
                                );
                          }
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.spaceMd),
                          decoration: BoxDecoration(
                            color: isActive ? context.primaryLightColor : context.surface,
                            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                            border: Border.all(
                              color: isActive ? context.primary : context.border,
                              width: isActive ? 1.5 : 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isActive ? context.surface : context.primaryLightColor,
                                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl == null
                                    ? Text(
                                        name.isNotEmpty ? name[0] : '?',
                                        style: AppTextStyles.headlineSmall(context).copyWith(
                                          color: context.textSecondary,
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
                                        color: isActive ? context.textPrimary : context.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      specialty,
                                      style: AppTextStyles.bodyMedium(context).copyWith(
                                        color: isActive ? context.textSecondary : context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration:  BoxDecoration(
                                    color: context.successBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child:  Icon(Icons.check, color: context.successText, size: 16),
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
