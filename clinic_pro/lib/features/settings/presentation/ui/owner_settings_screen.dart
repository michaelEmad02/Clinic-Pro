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
import 'subscription_screen.dart';

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
                    subtitle: state.userRole,
                    onEdit: () => EditProfileSheet.show(context),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildManagementSection(context),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildOtherSection(context),
                  const SizedBox(height: AppConstants.spaceLg),
                  const SettingsLogoutSection(),
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

  Widget _buildManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          child: Text('الإدارة', style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        _buildSettingsItem(
          context: context,
          icon: Icons.local_hospital_outlined,
          label: 'إدارة العيادات',
          onTap: () => context.push(RouteConstants.clinics),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        _buildSettingsItem(
          context: context,
          icon: Icons.group_outlined,
          label: 'إدارة الطاقم الطبي',
          onTap: () => context.push(RouteConstants.staff),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        _buildSettingsItem(
          context: context,
          icon: Icons.payments,
          label: 'الاشتراك والخطة',
          onTap: () {
            final cubit = context.read<SettingsCubit>();
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => BlocProvider.value(value: cubit, child: const SubscriptionScreen()),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryContainer, size: 20),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(child: Text(label, style: AppTextStyles.bodyLarge(context))),
              const Icon(Icons.chevron_left, color: AppColors.textHint, size: 18),
            ],
          ),
        ),
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
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Row(
            children: [
              Icon(Icons.dark_mode, size: 20, color: AppColors.primaryContainer),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(child: Text('المظهر - الوضع الليلي', style: AppTextStyles.bodyLarge(context))),
              const DarkModeSwitch(),
            ],
          ),
        ),
      ],
    );
  }
}
