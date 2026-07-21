import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
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
import 'widgets/settings_logout_section.dart';
import 'widgets/edit_profile_sheet.dart';

class OwnerSettingsScreen extends StatelessWidget {
  final bool showBottomNav;

  const OwnerSettingsScreen({super.key, this.showBottomNav = false});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
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
          final clinics = state.availableClinics;
          return RefreshIndicator(
            onRefresh: () async {
              final role = user?.role ?? StaffRoles.owner;
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
                      subtitle: null, // عيادة النور
                      avatarUrl: user?.imageUrl,
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
                    if (clinics.isNotEmpty)
                      _buildDangerZoneSection(context, clinics),
                    const SizedBox(height: AppConstants.spaceLg),
                    const SettingsLogoutSection(inline: true),
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
            icon: Icons.groups_outlined,
            label: AppStrings.manageStaff,
            onTap: () => context.push(RouteConstants.staff),
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

  Widget _buildDangerZoneSection(
      BuildContext context, List<ClinicEntity> clinics) {
    return SectionCard(
      title: '',
      child: Column(
        children: [
          NavSettingsItem(
            icon: Icons.medical_services_outlined,
            label: AppStrings.enterAsDoctor,
            onTap: () {
              if (clinics.length > 1) {
                // عند وجود أكثر من عيادة: إظهار اختيار العيادة أولاً
                _showClinicPickerForSwitch(context, clinics);
              } else {
                // عيادة واحدة أو أقل: الدخول مباشرة كطبيب
                context.read<AuthCubit>().switchToDoctor();
                context.go(RouteConstants.doctorDashboard);
              }
            },
          ),
        ],
      ),
    );
  }

  /// إظهار Bottom Sheet لاختيار العيادة عند التبديل كطبيب
  void _showClinicPickerForSwitch(BuildContext context, List<dynamic> clinics) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SettingsCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: _ClinicSwitchPickerContent(
          onClinicSelected: (clinicId) {
            // تحديث العيادة النشطة ثم التبديل كطبيب
            AppConstants.activeClinicId = clinicId;
            context.read<AuthCubit>().switchToDoctor();
            context.go(RouteConstants.doctorDashboard);
          },
        ),
      ),
    );
  }
}

/// محتوى Bottom Sheet اختيار العيادة للتبديل كطبيب
class _ClinicSwitchPickerContent extends StatelessWidget {
  final void Function(String clinicId) onClinicSelected;

  const _ClinicSwitchPickerContent({required this.onClinicSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spaceSm),
              // مقبض السحب
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
              // العنوان
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenEdgeH),
                child: Row(
                  children: [
                    Text(AppStrings.selectClinicToEnter,
                        style: AppTextStyles.headlineSmall(context)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close,
                          color: context.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              // قائمة العيادات
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenEdgeH),
                child: Column(
                  children: state.availableClinics.map((clinic) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppConstants.spaceSm),
                      child: _buildClinicCard(
                        context,
                        name: clinic.name,
                        address: clinic.address,
                        onTap: () {
                          Navigator.pop(context);
                          onClinicSelected(clinic.id);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    AppConstants.spaceMd,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClinicCard(
    BuildContext context, {
    required String name,
    required String address,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusButton),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          border: Border.all(color: context.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceBright,
                shape: BoxShape.circle,
                border: Border.all(color: context.border),
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
                      style: AppTextStyles.headlineSmall(context)
                          .copyWith(color: context.textPrimary)),
                  Text(address,
                      style: AppTextStyles.bodyMedium(context)
                          .copyWith(color: context.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: context.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
