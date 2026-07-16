import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/supabase_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/i_cloud_service.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/localization/language_cubit.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/queue_pattern_cubit.dart';
import '../../manager/queue_pattern_state.dart';
import '../../manager/settings_cubit.dart';

class EditQueuePatternSheet extends StatelessWidget {
  final String doctorId;
  final String clinicId;

  const EditQueuePatternSheet({
    super.key,
    required this.doctorId,
    required this.clinicId,
  });

  static Future<void> show(BuildContext context) {
    final cubit = context.read<QueuePatternCubit>();
    final state = context.read<SettingsCubit>().state;
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: EditQueuePatternSheet(
          doctorId: state.userId,
          clinicId: state.clinicId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QueuePatternCubit, QueuePatternState>(
      listenWhen: (prev, curr) =>
          prev.isSaving && !curr.isSaving && curr.error == null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم حفظ النمط بنجاح', textAlign: TextAlign.right),
              behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context);
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spaceSm),
              _buildHeader(context, state),
              const SizedBox(height: AppConstants.spaceMd),
              _buildSlotCards(context, state),
              _buildPreviewSection(context, state),
              _buildSaveButton(context, state),
              const SizedBox(height: AppConstants.spaceSm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, QueuePatternState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: Column(
        children: [
          Text(AppStrings.queueSystem,
              style: AppTextStyles.headlineMedium(context)
                  .copyWith(color: context.primary)),
          const SizedBox(height: 4),
          Text('اسحب لإعادة ترتيب الأنواع',
              style: AppTextStyles.caption(context)
                  .copyWith(color: context.textSecondary)),
          if (state.isDirty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('(توجد تغييرات غير محفوظة)',
                  style: AppTextStyles.caption(context)
                      .copyWith(color: context.warningText)),
            ),
        ],
      ),
    );
  }

  Widget _buildSlotCards(BuildContext context, QueuePatternState state) {
    final cubit = context.read<QueuePatternCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 72,
            child: state.slots.isEmpty
                ? Center(
                    child: Text('لم يتم إضافة أنواع بعد، أضف أول نوع',
                        style: AppTextStyles.bodyMedium(context)
                            .copyWith(color: context.textHint)),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.slots.length,
                    itemBuilder: (context, index) {
                      final slotType = state.slots[index];
                      final label = index < state.slotLabels.length &&
                              state.slotLabels[index].isNotEmpty
                          ? state.slotLabels[index]
                          : mapSlotTypeToLabel(slotType);
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: _SlotCard(
                          label: label,
                          isUrgent: isSlotTypeUrgent(slotType),
                          slotType: slotType,
                          onRemove: () => cubit.removeSlot(index),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          TextButton.icon(
            onPressed: () => _showAddTypePicker(context, cubit),
            icon: Icon(Icons.add, size: 18, color: context.primary),
            label: Text('أضف نوع',
                style: AppTextStyles.headlineSmall(context)
                    .copyWith(color: context.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context, QueuePatternState state) {
    if (state.slots.isEmpty) return const SizedBox.shrink();
    final cycleLen = state.cycleLength;
    return Container(
      width: double.infinity,
      color: context.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenEdgeH, vertical: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('معاينة', style: AppTextStyles.headlineSmall(context)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceSm, vertical: 2),
                decoration: BoxDecoration(
                  color: state.isActive ? context.successBg : context.warningBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: state.isActive
                            ? context.successText
                            : context.warningText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(state.isActive ? 'مباشر' : 'غير نشط',
                        style: AppTextStyles.caption(context).copyWith(
                          color: state.isActive
                              ? context.successText
                              : context.warningText,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ...List.generate(state.slots.length, (i) {
            final slotType = state.slots[i];
            final label =
                i < state.slotLabels.length && state.slotLabels[i].isNotEmpty
                    ? state.slotLabels[i]
                    : mapSlotTypeToLabel(slotType);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
              child: _PreviewPatient(
                number: i + 1,
                type: label,
                isUrgent: isSlotTypeUrgent(slotType),
              ),
            );
          }),
          if (cycleLen > 0) _buildCycleDivider(context),
          if (cycleLen > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spaceSm),
              child: _PreviewPatient(
                number: cycleLen + 1,
                type: state.slotLabels.isNotEmpty &&
                        state.slotLabels.first.isNotEmpty
                    ? state.slotLabels.first
                    : mapSlotTypeToLabel(state.slots.first),
                isUrgent: isSlotTypeUrgent(state.slots.first),
                faded: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCycleDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(thickness: 0.5, color: AppColors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: Text('── 🔁 دورة جديدة ──',
              style: AppTextStyles.labelChip(context)
                  .copyWith(color: context.textHint)),
        ),
        const Expanded(
            child: Divider(thickness: 0.5, color: AppColors.outlineVariant)),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, QueuePatternState state) {
    final cubit = context.read<QueuePatternCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenEdgeH, vertical: AppConstants.spaceMd),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: state.isDirty && !state.isSaving
              ? () => cubit.savePattern()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: context.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            ),
            elevation: 0,
          ),
          child: state.isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.onPrimary))
              : Text('حفظ النمط', style: AppTextStyles.headlineSmall(context)),
        ),
      ),
    );
  }

  void _showAddTypePicker(BuildContext context, QueuePatternCubit cubit) async {
    final cloudService = sl<ICloudService>();

    List<_SlotTypeOption> types;
    try {
      final doctorTypes = await cloudService.select(
        table: 'doctor_appointment_types',
        eq: {'doctor_id': doctorId, 'clinic_id': clinicId},
      );

      final allAppTypes = await cloudService.select(table: 'appointment_types');

      types = [];
      for (final dt in doctorTypes) {
        final typeId = dt['appointment_type_id'] as String;
        final appType = allAppTypes.firstWhere(
          (t) => t['id'] == typeId,
          orElse: () => <String, dynamic>{},
        );
        final name = appType['name'] as String? ?? '';
        final slotType = _mapAppointmentTypeToSlot(name);
        types.add(_SlotTypeOption(
          label: name.isNotEmpty ? name : '',
          slotType: slotType,
          icon: mapSlotTypeToIcon(slotType),
          color: slotType == 'urgent' ? context.warningText : context.primary,
        ));
      }
    } catch (_) {
      types = [];
    }

    if (types.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة أنواع الزيارات أولاً من الإعدادات',
              textAlign: TextAlign.right),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => BlocBuilder<LanguageCubit, Locale>(
        builder: (ctx, locale) => Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: context.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            ),
            title: Text('اختيار نوع', style: AppTextStyles.headlineSmall(ctx)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: types.map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusButton),
                    ),
                    leading: Icon(type.icon, color: type.color),
                    title:
                        Text(type.label, style: AppTextStyles.bodyLarge(ctx)),
                    subtitle: Text(
                      mapSlotTypeToLabel(type.slotType),
                      style: AppTextStyles.caption(ctx)
                          .copyWith(color: context.textHint),
                    ),
                    trailing:
                        Icon(Icons.add_circle_outline, color: context.textHint),
                    onTap: () {
                      Navigator.pop(ctx);
                      cubit.addSlot(type.slotType, label: type.label);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _mapAppointmentTypeToSlot(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('طارئ') ||
        lower.contains('urgent') ||
        lower.contains('مستعجل')) {
      return QueueSlotType.urgent;
    }
    if (lower.contains('إعادة') ||
        lower.contains('revisit') ||
        lower.contains('مراجعة')) {
      return QueueSlotType.revisit;
    }
    if (lower.contains('استشارة') || lower.contains('consult')) {
      return QueueSlotType.consult;
    }
    if (lower.contains('متابعة') ||
        lower.contains('موعد') ||
        lower.contains('فحص')) {
      return QueueSlotType.normal;
    }
    return QueueSlotType.normal;
  }
}

// ────────────────────────────────────────────────────────
// بطاقة نوع واحد في النمط
// ────────────────────────────────────────────────────────
class _SlotCard extends StatelessWidget {
  final String label;
  final bool isUrgent;
  final String slotType;
  final VoidCallback onRemove;

  const _SlotCard(
      {required this.label,
      required this.isUrgent,
      required this.slotType,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent ? context.warningBg : context.primaryLightColor;
    final iconColor = isUrgent ? context.warningText : context.primaryFixedDim;
    final textColor = isUrgent ? context.warningText : context.textPrimary;
    final icon = mapSlotTypeToIcon(slotType);
    return Stack(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.labelChip(context)
                      .copyWith(color: textColor)),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.border),
              ),
              child: Icon(Icons.close, size: 12, color: context.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// معاينة مريض في النمط
// ────────────────────────────────────────────────────────
class _PreviewPatient extends StatelessWidget {
  final int number;
  final String type;
  final bool isUrgent;
  final bool faded;

  const _PreviewPatient(
      {required this.number,
      required this.type,
      this.isUrgent = false,
      this.faded = false});

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent ? context.warningBg : context.surface;
    final border =
        isUrgent ? context.warningText.withAlpha(25) : context.border;
    final numColor = isUrgent ? context.warningText : context.primary;
    // final chipBg = isUrgent ? context.surface.withAlpha(128) : context.surface;
    final chipText = isUrgent ? context.warningText : context.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: border),
      ),
      child: Opacity(
        opacity: faded ? 0.7 : 1,
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text('$number.',
                  style: AppTextStyles.dataNumeric(context)
                      .copyWith(color: numColor)),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Expanded(
              child: Text('مريض #$number',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: isUrgent ? context.warningText : context.textPrimary,
                    fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                  )),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd, vertical: 3),
              decoration: BoxDecoration(
                
                borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                border: isUrgent
                    ? Border.all(color: context.warningText.withAlpha(50))
                    : null,
              ),
              child: Text(type,
                  style: AppTextStyles.labelChip(context)
                      .copyWith(color: chipText)),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// نموذج خيار نوع الكشف في منتقي الإضافة
// ────────────────────────────────────────────────────────
class _SlotTypeOption {
  final String label;
  final String slotType;
  final IconData icon;
  final Color color;

  const _SlotTypeOption(
      {required this.label,
      required this.slotType,
      required this.icon,
      required this.color});
}

// ────────────────────────────────────────────────────────
// دوال مساعدة لتحويل QueueSlotType إلى بيانات العرض
// ────────────────────────────────────────────────────────
String mapSlotTypeToLabel(String slotType) {
  return AppStrings.mapSlotTypeToLabel(slotType);
}

IconData mapSlotTypeToIcon(String slotType) {
  switch (slotType) {
    case 'urgent':
      return Icons.bolt;
    case 'revisit':
      return Icons.refresh;
    case 'consult':
      return Icons.forum;
    case 'normal':
    default:
      return Icons.person;
  }
}

bool isSlotTypeUrgent(String slotType) => slotType == 'urgent';
