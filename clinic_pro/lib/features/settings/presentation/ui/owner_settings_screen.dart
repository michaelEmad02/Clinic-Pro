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
import 'widgets/settings_logout_section.dart';
import 'widgets/edit_profile_sheet.dart';

class OwnerSettingsScreen extends StatelessWidget {
  final bool showBottomNav;

  const OwnerSettingsScreen({super.key, this.showBottomNav = false});

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
                    subtitle: state.clinicName, // عيادة النور
                    avatarUrl: state.userAvatarUrl,
                    layout: AccountSectionLayout.centered,
                    roleBadge: 'صاحب عيادة',
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
                  const SettingsLogoutSection(),
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
            icon: Icons.groups_outlined,
            label: 'إدارة الطاقم',
            onTap: () => context.push(RouteConstants.staff),
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          NavSettingsItem(
            icon: Icons.person_add_outlined,
            label: 'دعوة عضو',
            onTap: () => context.push(RouteConstants.staff), // Leads to staff list/invitation view
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          NavSettingsItem(
            icon: Icons.payments,
            label: 'الاشتراك والخطة',
            onTap: () => context.push(RouteConstants.settingsSubscription),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return const SectionCard(
      title: 'أخرى',
      child: Column(
        children: [
          ToggleSettingsItem(
            icon: Icons.dark_mode_outlined,
            label: 'المظهر - الوضع الليلي',
            trailing: DarkModeSwitch(),
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
            label: 'الدخول كطبيب',
            onTap: () {
              // Action logic to switch role representation if simulated
            },
          ),
        ],
      ),
    );
  }
}
