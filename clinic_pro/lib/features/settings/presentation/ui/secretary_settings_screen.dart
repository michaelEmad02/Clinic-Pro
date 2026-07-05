import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';
import 'widgets/shared_settings_widgets.dart';
import 'widgets/settings_account_section.dart';
import 'widgets/settings_clinic_section.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/clinic_picker_sheet.dart';
import 'widgets/doctor_picker_sheet.dart';
import 'widgets/settings_logout_section.dart';

class SecretarySettingsScreen extends StatelessWidget {
  final bool showBottomNav;

  const SecretarySettingsScreen({super.key, this.showBottomNav = false});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الإعدادات',
            style: AppTextStyles.headlineMedium(context).copyWith(color: AppColors.primary),
          ),
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
              return Center(
                child: Text('خطأ: ${state.error}', style: AppTextStyles.bodyLarge(context)),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spaceMd),
                  SettingsAccountSection(
                    name: state.userName,
                    subtitle: 'سكرتيرة',
                    avatarUrl: state.userAvatarUrl,
                    layout: AccountSectionLayout.horizontal,
                    showSectionTitle: true,
                    onEdit: () => EditProfileSheet.show(context),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildManagementSection(context),
                  const SizedBox(height: AppConstants.spaceLg),
                  SettingsClinicSection(
                    clinicName: state.clinicName,
                    clinicAddress: state.clinicAddress,
                    onChangeClinic: () => ClinicPickerSheet.show(context),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildCurrentDoctorSection(context, state),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildOtherSection(context),
                  const SizedBox(height: AppConstants.spaceXl),
                  const SettingsFooter(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: showBottomNav ? const SettingsBottomNavBar() : null,
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return SectionCard(
      title: 'الإدارة',
      child: Column(
        children: [
          NavSettingsItem(
            icon: Icons.medication_liquid_sharp, // Represents pills/medication
            label: 'إدارة الأدوية',
            onTap: () => context.push(RouteConstants.drugs),
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          NavSettingsItem(
            icon: Icons.description_outlined,
            label: 'قوالب الروشتات',
            onTap: () => context.push(RouteConstants.prescriptionTemplates),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDoctorSection(BuildContext context, SettingsState state) {
    final hasDoctor = state.currentDoctorId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          child: Text(
            'الطبيب الحالي',
            style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: state.currentDoctorAvatar != null
                          ? NetworkImage(state.currentDoctorAvatar!)
                          : null,
                      child: state.currentDoctorAvatar == null
                          ? Text(
                              hasDoctor && state.currentDoctorName!.isNotEmpty
                                  ? state.currentDoctorName![0]
                                  : '?',
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
                            hasDoctor ? state.currentDoctorName! : 'لم يتم اختيار طبيب',
                            style: AppTextStyles.headlineSmall(context),
                          ),
                          if (hasDoctor)
                            Text(
                              state.currentDoctorSpecialty!,
                              style: AppTextStyles.caption(context).copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5, color: AppColors.border),
              InkWell(
                onTap: () => DoctorPickerSheet.show(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd, horizontal: AppConstants.spaceMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تغيير الطبيب',
                        style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.chevron_left, color: AppColors.primary, size: 20),
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

  Widget _buildOtherSection(BuildContext context) {
    return SectionCard(
      title: 'أخرى',
      child: Column(
        children: [
          ToggleSettingsItem(
            icon: Icons.dark_mode_outlined,
            label: 'المظهر',
            trailing: const DarkModeSwitch(),
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          const SettingsLogoutSection(inline: true),
        ],
      ),
    );
  }
}
