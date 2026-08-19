// ────────────────────────────────────────────────────────
// شيت تعديل إعدادات نظام قائمة الانتظار (EditQueuePatternSheet)
// يتيح اختيار نظام الترتيب، ضبط النمط، والسحب والإفلات لإعادة الترتيب
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/supabase_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
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
    final settingsState = context.read<SettingsCubit>().state;
    final docId = context.read<AuthCubit>().state.user?.id ?? '';
    final clId = settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;
    cubit.init(docId, clId);
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: EditQueuePatternSheet(
          doctorId: docId,
          clinicId: clId,
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
          SnackBar(
            content: Text(
              AppStrings.isArabic
                  ? 'تم حفظ نظام قائمة الانتظار بنجاح'
                  : 'Queue system saved successfully',
              textAlign: TextAlign.right,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                _buildHeader(context, state),
                const SizedBox(height: 16),
                _buildSystemSelectorCards(context, state),
                if (state.queueSystem == DoctorQueueSystem.scheduled) ...[
                  const SizedBox(height: 16),
                  _buildScheduledInput(context, state),
                ],
                if (state.queueSystem == DoctorQueueSystem.pattern) ...[
                  const SizedBox(height: 20),
                  _buildPatternReorderableSlots(context, state),
                ],
                if (state.queueSystem == DoctorQueueSystem.pattern &&
                    state.slots.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildPreviewSection(context, state),
                ],
                const SizedBox(height: 20),
                _buildSaveButton(context, state),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, QueuePatternState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.isArabic ? 'نظام قائمة الانتظار' : 'Queue System',
                style: AppTextStyles.headlineMedium(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.isArabic
                    ? 'اختر طريقة ترتيب دخول المرضى للطبيب'
                    : 'Choose how patients are ordered for the doctor',
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          if (state.isDirty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.warningBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.isArabic ? 'تغييرات غير محفوظة' : 'Unsaved changes',
                style: AppTextStyles.caption(context).copyWith(
                  color: context.warningText,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// كروت تفاعلية مريحة لاختيار نظام الانتظار
  Widget _buildSystemSelectorCards(
      BuildContext context, QueuePatternState state) {
    final cubit = context.read<QueuePatternCubit>();
    final isAr = AppStrings.isArabic;

    final systems = [
      {
        'key': DoctorQueueSystem.arrival,
        'title': isAr ? 'أولوية الحضور' : 'Arrival Order',
        'desc': isAr ? 'من يصل العيادة أولاً يدخل أولاً' : 'First come, first served',
        'icon': Icons.directions_walk_rounded,
      },
      {
        'key': DoctorQueueSystem.booking,
        'title': isAr ? 'حسب وقت الحجز' : 'Booking Order',
        'desc': isAr ? 'الترتيب بناءً على وقت الحجز المسبق' : 'Ordered by scheduled time',
        'icon': Icons.calendar_month_rounded,
      },
      {
        'key': DoctorQueueSystem.pattern,
        'title': isAr ? 'نمط مخصص' : 'Custom Pattern',
        'desc': isAr
            ? 'تتابع تكراري لأنواع الكشف (كشف، مراجعة..)'
            : 'Rotational order by visit types',
        'icon': Icons.sync_alt_rounded,
      },
      {
        'key': DoctorQueueSystem.scheduled,
        'title': isAr ? 'مواعيد بمدة محددة' : 'Fixed Duration',
        'desc': isAr
            ? 'تحديد متوسط دقائق ثابت لكل مريض'
            : 'Fixed average duration per patient',
        'icon': Icons.timer_outlined,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.65,
        children: systems.map((sys) {
          final isSelected = state.queueSystem == sys['key'];
          return InkWell(
            onTap: () => cubit.setQueueSystem(sys['key'] as String),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryLightColor
                    : context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? context.primary : context.borderColor,
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.primary.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        sys['icon'] as IconData,
                        color: isSelected ? context.primary : context.textSecondary,
                        size: 22,
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: context.primary,
                          size: 18,
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sys['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: isSelected
                              ? context.primary
                              : context.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sys['desc'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// إدخال متوسط مدة الكشف بالدقائق (نظام scheduled)
  Widget _buildScheduledInput(BuildContext context, QueuePatternState state) {
    final cubit = context.read<QueuePatternCubit>();
    final isAr = AppStrings.isArabic;
    final currentMins = state.avgVisitMinutes ?? 15;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'متوسط زمن الكشف لكل مريض' : 'Average Visit Duration',
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [10, 15, 20, 30].map((mins) {
                  final selected = currentMins == mins;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(
                        isAr ? '$mins دقيقة' : '$mins min',
                        style: AppTextStyles.caption(context).copyWith(
                          color: selected ? Colors.white : context.textPrimary,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: selected,
                      selectedColor: context.primary,
                      backgroundColor: context.surfaceColor,
                      onSelected: (_) => cubit.setAvgVisitMinutes(mins),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// قائمة الخانات المتاحة لإعادة الترتيب بالسحب والإفلات (Reorderable ListView)
  Widget _buildPatternReorderableSlots(
      BuildContext context, QueuePatternState state) {
    final cubit = context.read<QueuePatternCubit>();
    final isAr = AppStrings.isArabic;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'ترتيب خانات النمط المخصص' : 'Custom Pattern Slots',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              Text(
                isAr ? 'اسحب لإعادة الترتيب' : 'Drag to reorder',
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (state.slots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Center(
                child: Text(
                  isAr
                      ? 'لم يتم إضافة أي أنواع كشف للنمط بعد'
                      : 'No visit types added to pattern yet',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 70,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.slots.length,
                onReorder: (oldIndex, newIndex) {
                  cubit.reorderSlots(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final slotType = state.slots[index];
                  final label = (index < state.slotLabels.length &&
                          state.slotLabels[index].isNotEmpty)
                      ? state.slotLabels[index]
                      : slotType;

                  final isUrgent = label.contains('طارئ') ||
                      label.toLowerCase().contains('urgent') ||
                      label.contains('مستعجل');

                  return Container(
                    key: ValueKey('$index-$slotType'),
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    child: _ReorderableSlotChip(
                      index: index + 1,
                      label: label,
                      isUrgent: isUrgent,
                      onRemove: () => cubit.removeSlot(index),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showAddTypePickerSheet(context, cubit),
              icon: Icon(Icons.add_circle_outline,
                  size: 20, color: context.primary),
              label: Text(
                isAr ? 'إضافة نوع كشف للنمط' : 'Add Visit Type to Pattern',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// المعاينة الحية المباشرة لكيفية تسلسل دخول المرضى
  Widget _buildPreviewSection(BuildContext context, QueuePatternState state) {
    final isAr = AppStrings.isArabic;
    final cycleLen = state.cycleLength;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'معاينة تسلسل طابور الكشف' : 'Queue Cycle Preview',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.primaryLightColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAr
                        ? 'تكرار كل $cycleLen مرضى'
                        : 'Repeats every $cycleLen patients',
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(state.slots.length, (i) {
              final slotType = state.slots[i];
              final label =
                  (i < state.slotLabels.length && state.slotLabels[i].isNotEmpty)
                      ? state.slotLabels[i]
                      : slotType;
              final isUrgent = label.contains('طارئ') ||
                  label.toLowerCase().contains('urgent') ||
                  label.contains('مستعجل');

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _PreviewPatientRow(
                  number: i + 1,
                  typeLabel: label,
                  isUrgent: isUrgent,
                ),
              );
            }),
            if (cycleLen > 0) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Divider(height: 1, thickness: 0.5),
              ),
              _PreviewPatientRow(
                number: cycleLen + 1,
                typeLabel: (state.slotLabels.isNotEmpty &&
                        state.slotLabels.first.isNotEmpty)
                    ? state.slotLabels.first
                    : state.slots.first,
                isUrgent: state.slots.first.contains('urgent') ||
                    state.slots.first.contains('طارئ'),
                faded: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, QueuePatternState state) {
    final cubit = context.read<QueuePatternCubit>();
    final isAr = AppStrings.isArabic;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: state.isDirty && !state.isSaving
              ? () => cubit.savePattern()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: state.isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isAr ? 'حفظ إعدادات الانتظار' : 'Save Queue Settings',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  /// منتقي اختيار أنواع الزيارات المتاحة كـ BottomSheet
  void _showAddTypePickerSheet(
      BuildContext context, QueuePatternCubit cubit) async {
    final isAr = AppStrings.isArabic;
    List<Map<String, String>> visitTypes = [];

    try {
      visitTypes = await cubit.fetchAvailableVisitTypes();
    } catch (_) {
      visitTypes = [];
    }

    if (visitTypes.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'يرجى إضافة أنواع زيارات من ميزة أنواع الكشف أولاً'
                : 'Please add visit types in Visit Types settings first',
            textAlign: TextAlign.right,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!context.mounted) return;

    AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'اختر نوع الكشف لإضافته للنمط' : 'Select Visit Type',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: visitTypes.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: context.borderColor),
                    itemBuilder: (ctx, idx) {
                      final item = visitTypes[idx];
                      final name = item['name'] ?? '';
                      final id = item['id'] ?? '';
                      final isUrgentType = name.contains('طارئ') ||
                          name.toLowerCase().contains('urgent') ||
                          name.contains('مستعجل');

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isUrgentType
                                ? context.warningBg
                                : context.primaryLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isUrgentType ? Icons.bolt : Icons.person_outlined,
                            color: isUrgentType
                                ? context.warningText
                                : context.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          name,
                          style: AppTextStyles.bodyMedium(ctx).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.add_circle_outline,
                          color: context.primary,
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          cubit.addSlot(id, label: name);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// مكون Chip قابل للإعادة الترتيب في النمط
// ────────────────────────────────────────────────────────
class _ReorderableSlotChip extends StatelessWidget {
  final int index;
  final String label;
  final bool isUrgent;
  final VoidCallback onRemove;

  const _ReorderableSlotChip({
    required this.index,
    required this.label,
    required this.isUrgent,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent ? context.warningBg : context.primaryLightColor;
    final borderColor = isUrgent ? context.warningText : context.primary;
    final textColor = isUrgent ? context.warningText : context.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.drag_indicator, size: 16, color: context.textSecondary),
          const SizedBox(width: 4),
          Text(
            '$index. $label',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// صف معاينة تسلسل مريض افتراضي
// ────────────────────────────────────────────────────────
class _PreviewPatientRow extends StatelessWidget {
  final int number;
  final String typeLabel;
  final bool isUrgent;
  final bool faded;

  const _PreviewPatientRow({
    required this.number,
    required this.typeLabel,
    this.isUrgent = false,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent ? context.warningBg : context.surfaceColor;
    final numColor = isUrgent ? context.warningText : context.primary;
    final chipText = isUrgent ? context.warningText : context.textSecondary;

    return Opacity(
      opacity: faded ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Text(
              '$number.',
              style: AppTextStyles.dataNumeric(context).copyWith(
                color: numColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${AppStrings.isArabic ? 'مريض #' : 'Patient #'}$number',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: isUrgent ? context.warningText : context.textPrimary,
                  fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isUrgent
                    ? context.warningBg
                    : context.primaryLightColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                typeLabel,
                style: AppTextStyles.caption(context).copyWith(
                  color: chipText,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
