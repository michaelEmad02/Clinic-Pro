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

class ClinicPickerSheet extends StatelessWidget {
  const ClinicPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SettingsCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: const ClinicPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                color: context.surfaceBright,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH),
            child: Row(
              children: [
                Text(AppStrings.selectClinic,
                    style: AppTextStyles.headlineSmall(context)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close,
                      color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenEdgeH),
                child: Column(
                  children: [
                     ...state.availableClinics.map((clinic) {
                      final id = clinic.id;
                      final name = clinic.name;
                      final address = clinic.address;
                      final isActive = id == (state.clinicEntity?.id ?? '');
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppConstants.spaceSm),
                        child: _buildClinicCard(
                          context,
                          name: name,
                          address: address,
                          isActive: isActive,
                          onTap: () {
                            if (!isActive && user != null) {
                              context.read<SettingsCubit>().changeClinic(
                                    user.id,
                                    id,
                                    user.role,
                                  );
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
          SizedBox(
              height:
                  MediaQuery.of(context).padding.bottom + AppConstants.spaceMd),
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
          color: isActive ? context.primaryLightColor : context.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          border: Border.all(
            color: isActive ? context.primary : context.border,
            width: isActive ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? context.surface : context.surfaceBright,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isActive ? context.primaryFixedDim : context.border),
              ),
              child:
                  Icon(Icons.local_hospital, color: context.primary, size: 20),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        color: isActive
                            ? context.textPrimary
                            : context.textSecondary,
                      )),
                  Text(address,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                      )),
                ],
              ),
            ),
            if (isActive)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: context.successBg, shape: BoxShape.circle),
                child: Icon(Icons.check, color: context.successText, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
