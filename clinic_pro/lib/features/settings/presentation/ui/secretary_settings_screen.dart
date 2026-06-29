import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';
import 'widgets/shared_settings_widgets.dart';
import 'widgets/settings_account_section.dart';
import 'widgets/settings_clinic_section.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/clinic_picker_sheet.dart';

class SecretarySettingsScreen extends StatelessWidget {
  final bool showBottomNav;

  const SecretarySettingsScreen({super.key, this.showBottomNav = false});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الإعدادات', style: AppTextStyles.headlineMedium(context).copyWith(color: AppColors.primary)),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text('خطأ: ${state.error}', style: AppTextStyles.bodyLarge(context)));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spaceMd),
                  SettingsAccountSection(
                    name: state.userName,
                    subtitle: state.userRole,
                    onEdit: () => EditProfileSheet.show(context),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  SettingsClinicSection(
                    clinicName: state.clinicName,
                    clinicAddress: state.clinicAddress,
                    onChangeClinic: () => ClinicPickerSheet.show(context),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildOtherSection(context),
                  const SizedBox(height: AppConstants.spaceXl),
                  buildSettingsFooter(context),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: showBottomNav ? buildBottomNavBar(context) : null,
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          child: Text('أخرى', style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            children: [
              buildToggleItem(context,
                icon: Icons.dark_mode,
                label: 'المظهر',
                trailing: const DarkModeSwitch(),
              ),
              const Divider(height: 1, thickness: 0.5, color: AppColors.surfaceContainerLow, indent: AppConstants.spaceMd, endIndent: AppConstants.spaceMd),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: AppColors.danger),
                      const SizedBox(width: AppConstants.spaceMd),
                      Text('تسجيل الخروج', style: AppTextStyles.bodyLarge(context).copyWith(color: AppColors.dangerText)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
