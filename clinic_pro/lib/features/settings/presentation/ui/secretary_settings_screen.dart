import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';
import '../../../../core/utils/responsive_helper.dart';
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
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.settings,
          style: AppTextStyles.headlineMedium(context)
              .copyWith(color: context.primary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: context.textSecondary),
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
              child: Text('${AppStrings.error}: ${state.error}',
                  style: AppTextStyles.bodyLarge(context)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final role = user?.role ?? StaffRoles.secretary;
              await context
                  .read<SettingsCubit>()
                  .loadSettings(role, user?.id ?? '');
            },
            child: ResponsiveHelper.responsiveCenter(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenEdgeH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.spaceMd),
                    SettingsAccountSection(
                      name: user?.name ?? '',
                      email: user?.email ?? '',
                      subtitle: AppStrings.secretaryRoleLabel,
                      avatarUrl: user?.imageUrl,
                      layout: AccountSectionLayout.horizontal,
                      showSectionTitle: true,
                      onEdit: () => EditProfileSheet.show(context),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    _buildManagementSection(context),
                    const SizedBox(height: AppConstants.spaceLg),
                    SettingsClinicSection(
                      clinicName: state.clinicEntity?.name ?? '',
                      clinicAddress: state.clinicEntity?.address ?? '',
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
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: showBottomNav ? const SettingsBottomNavBar() : null,
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return SectionCard(
      title: AppStrings.management,
      child: Column(
        children: [
          NavSettingsItem(
            icon: Icons.medication_liquid_sharp,
            label: AppStrings.manageDrugs,
            onTap: () => context.push(RouteConstants.drugs),
          ),
          Divider(height: 1, thickness: 0.5, color: context.border),
          NavSettingsItem(
            icon: Icons.description_outlined,
            label: AppStrings.prescriptionTemplates,
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
            AppStrings.currentDoctor,
            style: AppTextStyles.headlineSmall(context)
                .copyWith(color: context.textSecondary),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: context.border, width: 0.5),
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
                      backgroundColor: context.primaryLightColor,
                      backgroundImage: state.currentDoctorAvatar != null
                          ? NetworkImage(state.currentDoctorAvatar!)
                          : null,
                      child: state.currentDoctorAvatar == null
                          ? Text(
                              hasDoctor && state.currentDoctorName!.isNotEmpty
                                  ? state.currentDoctorName![0]
                                  : '?',
                              style:
                                  AppTextStyles.headlineSmall(context).copyWith(
                                color: context.primary,
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
                            hasDoctor
                                ? state.currentDoctorName!
                                : AppStrings.noDoctorSelected,
                            style: AppTextStyles.headlineSmall(context),
                          ),
                          if (hasDoctor)
                            Text(
                              state.currentDoctorSpecialty!,
                              style: AppTextStyles.caption(context)
                                  .copyWith(color: context.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: context.border),
              InkWell(
                onTap: () => DoctorPickerSheet.show(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spaceMd,
                      horizontal: AppConstants.spaceMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.changeDoctor,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.chevron_left,
                          color: context.primary, size: 20),
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
      title: AppStrings.other,
      child: Column(
        children: [
          ToggleSettingsItem(
            icon: Icons.dark_mode_outlined,
            label: AppStrings.appearance,
            trailing: const DarkModeSwitch(),
          ),
          Divider(height: 1, thickness: 0.5, color: context.border),
          ToggleSettingsItem(
            icon: Icons.language_outlined,
            label: AppStrings.language,
            trailing: const LanguageSwitch(),
          ),
          Divider(height: 1, thickness: 0.5, color: context.border),
          const SettingsLogoutSection(inline: true),
        ],
      ),
    );
  }
}
