// ────────────────────────────────────────────────────────
// EditWorkingHoursSheet — واجهة تعديل ساعات عمل العيادة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/localization/language_cubit.dart';
import '../../manager/settings_cubit.dart';
import '../../manager/working_hours_cubit.dart';
import '../../manager/working_hours_state.dart';
import 'working_day_card.dart';

class EditWorkingHoursSheet extends StatelessWidget {
  final String clinicId;

  const EditWorkingHoursSheet({super.key, required this.clinicId});

  static Future<void> show(BuildContext context) {
    final clinicId = context.read<SettingsCubit>().state.clinicEntity?.id ?? '';
    final doctorId = context.read<AuthCubit>().state.user?.id ?? '';
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<WorkingHoursCubit>()..load(doctorId,clinicId),
        child: EditWorkingHoursSheet(clinicId: clinicId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageCubit>().state;
    return Directionality(
      textDirection:
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusSheet)),
        ),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: BlocConsumer<WorkingHoursCubit, WorkingHoursState>(
          listenWhen: (prev, curr) =>
              prev.isSaving && !curr.isSaving && curr.error == null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.workingHoursSaved,
                    textAlign: TextAlign.right),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppConstants.spaceMd),
                _buildDragIndicator(context),
                const SizedBox(height: AppConstants.spaceMd),
                _buildHeader(context),
                Divider(height: 1, color: context.border),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(state.error!,
                        style: TextStyle(color: context.danger)),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.screenEdgeH),
                    itemCount: state.schedule.length,
                    itemBuilder: (context, index) {
                      final day = state.schedule[index];
                      final cubit = context.read<WorkingHoursCubit>();
                      return WorkingDayCard(
                        day: day,
                        onToggle: (val) => cubit.toggleDayOpen(day.dayKey, val),
                        onPeriodUpdate: (pIndex, period) =>
                            cubit.updatePeriod(day.dayKey, pIndex, period),
                        onPeriodRemove: (pIndex) =>
                            cubit.removePeriod(day.dayKey, pIndex),
                      );
                    },
                  ),
                ),
                _buildSaveButton(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDragIndicator(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: context.border,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: context.primary, size: 24),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                AppStrings.workingHours,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.close, color: context.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, WorkingHoursState state) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.border, width: 1)),
      ),
      child: ElevatedButton.icon(
        onPressed: state.isSaving
            ? null
            : () {
                final doctorId = context.read<AuthCubit>().state.user?.id ?? '';
                context.read<WorkingHoursCubit>().save(doctorId, clinicId);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        icon: const Icon(Icons.save_outlined),
        label: state.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                AppStrings.save,
                style: AppTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.surfaceBright,
                ),
              ),
      ),
    );
  }
}
