import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';
import 'widgets/shared_settings_widgets.dart';
import 'widgets/settings_account_section.dart';
import 'widgets/settings_logout_section.dart';
import 'widgets/edit_profile_sheet.dart';

class OwnerSettingsScreen extends StatelessWidget {
  final bool showBottomNav;

  const OwnerSettingsScreen({super.key, this.showBottomNav = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings,
            style: AppTextStyles.headlineMedium(context)
                .copyWith(color: context.primary)),
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
                    style: AppTextStyles.bodyLarge(context)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spaceMd),
                SettingsAccountSection(
                  name: state.userName,
                  subtitle: state.clinicName, // عيادة النور
                  avatarUrl: state.userAvatarUrl,
                  layout: AccountSectionLayout.centered,
                  roleBadge: AppStrings.ownerRoleLabel,
                  showSectionTitle: false,
                  onEdit: () => EditProfileSheet.show(context),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                _buildManagementSection(context),
                const SizedBox(height: AppConstants.spaceLg),
                _buildOtherSection(context),
                const SizedBox(height: AppConstants.spaceLg),
                _buildDangerZoneSection(context),
                const SizedBox(height: AppConstants.spaceLg),
                const SettingsLogoutSection(inline: true,),
                const SizedBox(height: AppConstants.spaceXl),
                const SettingsFooter(),
                const SizedBox(height: 16),
              ],
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
            icon: Icons.groups_outlined,
            label: AppStrings.manageStaff,
            onTap: () => context.push(RouteConstants.staff),
          ),
          Divider(height: 1, thickness: 0.5, color: context.border),
          NavSettingsItem(
            icon: Icons.person_add_outlined,
            label: AppStrings.inviteMember,
            onTap: () => context.push(
                RouteConstants.staff), // Leads to staff list/invitation view
          ),
          Divider(height: 1, thickness: 0.5, color: context.border),
          NavSettingsItem(
            icon: Icons.payments,
            label: AppStrings.subscriptionAndPlan,
            onTap: () => context.push(RouteConstants.settingsSubscription),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return SectionCard(
      title: AppStrings.other,
      child: Column(
        children: [
          ToggleSettingsItem(
            icon: Icons.dark_mode_outlined,
            label: AppStrings.appearanceDarkMode,
            trailing: const DarkModeSwitch(),
          ),
          Divider(height: 1, thickness: 0.5, color: context.border),
          ToggleSettingsItem(
            icon: Icons.language_outlined,
            label: AppStrings.language,
            trailing: const LanguageSwitch(),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection(BuildContext context) {
    return SectionCard(
      title: '',
      child: Column(
        children: [
          NavSettingsItem(
            icon: Icons.medical_services_outlined,
            label: AppStrings.enterAsDoctor,
            onTap: () {
              // Action logic to switch role representation if simulated
            },
          ),
        ],
      ),
    );
  }
}
