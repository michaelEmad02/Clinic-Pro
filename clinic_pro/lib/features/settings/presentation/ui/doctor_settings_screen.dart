import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/queue_pattern_cubit.dart';
import '../manager/queue_pattern_state.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';
import 'widgets/settings_account_section.dart';
import 'widgets/settings_clinic_section.dart';
import 'widgets/settings_logout_section.dart';
import 'widgets/shared_settings_widgets.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/clinic_picker_sheet.dart';
import 'widgets/edit_queue_pattern_sheet.dart';

class DoctorSettingsScreen extends StatelessWidget {
  final bool showBottomNav;

  const DoctorSettingsScreen({super.key, this.showBottomNav = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QueuePatternCubit()..loadPattern(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text('الإعدادات',
                style: AppTextStyles.headlineMedium(context)
                    .copyWith(color: AppColors.primary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textSecondary),
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
                    child: Text('خطأ: ${state.error}',
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
                      subtitle: state.userRole,
                      onEdit: () => EditProfileSheet.show(context),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    SettingsClinicSection(
                      clinicName: state.clinicName,
                      onChangeClinic: () => ClinicPickerSheet.show(context),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    _buildQueuePatternSection(context),
                    const SizedBox(height: AppConstants.spaceLg),
                    _buildOtherSection(context),
                    const SizedBox(height: AppConstants.spaceLg),
                    const SettingsLogoutSection(),
                    const SizedBox(height: AppConstants.spaceLg),
                    buildSettingsFooter(context, showSystemStatus: true),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar:
              showBottomNav ? buildBottomNavBar(context) : null,
        ),
      ),
    );
  }

  Widget _buildQueuePatternSection(BuildContext context) {
    return SectionCard(
      title: 'نظام قائمة الانتظار',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('النمط الحالي:',
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppConstants.spaceSm),
          const _QueuePatternChips(),
          const SizedBox(height: AppConstants.spaceMd),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => EditQueuePatternSheet.show(context),
              label: Text('تعديل',
                  style: AppTextStyles.bodyLarge(context)
                      .copyWith(color: AppColors.primary)),
              icon: const Icon(Icons.chevron_left,
                  color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return SectionCard(
      title: 'أخرى',
      child: Column(
        children: [
          buildNavItem(
            context,
            icon: Icons.description_outlined,
            label: 'قوالب الروشتات',
            onTap: () => context.push(RouteConstants.prescriptionTemplates),
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          buildNavItem(
            context,
            icon: Icons.description_outlined,
            label: 'ادارة الادوية',
            onTap: () => context.push(RouteConstants.drugs),
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          buildNavItem(
            context,
            icon: Icons.notifications_active_outlined,
            label: 'التنبيهات',
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          buildToggleItem(
            context,
            icon: Icons.dark_mode,
            label: 'المظهر الداكن',
            trailing: const DarkModeSwitch(),
          ),
        ],
      ),
    );
  }
}

class _QueuePatternChips extends StatelessWidget {
  const _QueuePatternChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueuePatternCubit, QueuePatternState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppConstants.spaceSm,
              runSpacing: AppConstants.spaceSm,
              children: state.slots.map((slot) {
                final label = _mapSlotTypeToLabel(slot);
                return QueueChip(label, isUrgent: slot == 'urgent');
              }).toList(),
            ),
            if (state.slots.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spaceSm),
              Row(
                children: [
                  const Icon(Icons.sync,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppConstants.spaceXs),
                  Text('يتكرر كل ',
                      style: AppTextStyles.bodyMedium(context)
                          .copyWith(color: AppColors.textSecondary)),
                  Text('${state.cycleLength}',
                      style: AppTextStyles.dataNumeric(context)),
                  Text(' مرضى',
                      style: AppTextStyles.bodyMedium(context)
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  static String _mapSlotTypeToLabel(String slotType) {
    switch (slotType) {
      case 'urgent':
        return 'مستعجل';
      case 'revisit':
        return 'مراجعة';
      case 'consult':
        return 'استشارة';
      default:
        return 'عادي';
    }
  }
}
