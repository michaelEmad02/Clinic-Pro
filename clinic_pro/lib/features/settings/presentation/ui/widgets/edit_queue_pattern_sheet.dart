import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/supabase_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/queue_pattern_cubit.dart';
import '../../manager/queue_pattern_state.dart';

class EditQueuePatternSheet extends StatelessWidget {
  const EditQueuePatternSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<QueuePatternCubit>();
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: const EditQueuePatternSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QueuePatternCubit, QueuePatternState>(
      listenWhen: (prev, curr) => prev.isSaving && !curr.isSaving && curr.error == null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ النمط بنجاح', textAlign: TextAlign.right), behavior: SnackBarBehavior.floating),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
          Text('نمط قائمة الانتظار', style: AppTextStyles.headlineMedium(context).copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('اسحب لإعادة ترتيب الأنواع',
              style: AppTextStyles.caption(context).copyWith(color: AppColors.textSecondary)),
          if (state.isDirty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('(توجد تغييرات غير محفوظة)',
                  style: AppTextStyles.caption(context).copyWith(color: AppColors.warningText)),
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
                        style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textHint)),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: state.slots.length,
                    itemBuilder: (context, index) {
                      final slotType = state.slots[index];
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: _SlotCard(
                          label: mapSlotTypeToLabel(slotType),
                          isUrgent: isSlotTypeUrgent(slotType),
                          slotType: slotType,
                          onRemove: () => cubit.removeSlot(state.slots.length - 1 - index),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          TextButton.icon(
            onPressed: () => _showAddTypePicker(context, cubit),
            icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
            label: Text('أضف نوع', style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.primary)),
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
      color: AppColors.surfaceBright,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH, vertical: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('معاينة', style: AppTextStyles.headlineSmall(context)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSm, vertical: 2),
                decoration: BoxDecoration(
                  color: state.isActive ? AppColors.successBg : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: state.isActive ? AppColors.successText : AppColors.warningText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(state.isActive ? 'مباشر' : 'غير نشط',
                        style: AppTextStyles.caption(context).copyWith(
                          color: state.isActive ? AppColors.successText : AppColors.warningText,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ...List.generate(state.slots.length, (i) {
            final slotType = state.slots[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
              child: _PreviewPatient(
                number: i + 1,
                type: mapSlotTypeToLabel(slotType),
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
                type: mapSlotTypeToLabel(state.slots.first),
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
        const Expanded(child: Divider(thickness: 0.5, color: AppColors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: Text('── 🔁 دورة جديدة ──',
              style: AppTextStyles.labelChip(context).copyWith(color: AppColors.textHint)),
        ),
        const Expanded(child: Divider(thickness: 0.5, color: AppColors.outlineVariant)),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, QueuePatternState state) {
    final cubit = context.read<QueuePatternCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH, vertical: AppConstants.spaceMd),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: state.isDirty && !state.isSaving ? () => cubit.savePattern() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            ),
            elevation: 0,
          ),
          child: state.isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
              : Text('حفظ النمط', style: AppTextStyles.headlineSmall(context)),
        ),
      ),
    );
  }

  void _showAddTypePicker(BuildContext context, QueuePatternCubit cubit) {
    final types = [
      _SlotTypeOption(label: 'عادي', slotType: QueueSlotType.normal, icon: Icons.person, color: AppColors.primary),
      _SlotTypeOption(label: 'مستعجل', slotType: QueueSlotType.urgent, icon: Icons.bolt, color: AppColors.warningText),
      _SlotTypeOption(label: 'مراجعة', slotType: QueueSlotType.revisit, icon: Icons.refresh, color: AppColors.successText),
      _SlotTypeOption(label: 'استشارة', slotType: QueueSlotType.consult, icon: Icons.forum, color: AppColors.primaryContainer),
    ];

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
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
                    borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                  ),
                  leading: Icon(type.icon, color: type.color),
                  title: Text(type.label, style: AppTextStyles.bodyLarge(ctx)),
                  trailing: const Icon(Icons.add_circle_outline, color: AppColors.textHint),
                  onTap: () {
                    Navigator.pop(ctx);
                    cubit.addSlot(type.slotType);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
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

  const _SlotCard({required this.label, required this.isUrgent, required this.slotType, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent ? AppColors.warningBg : AppColors.primaryLight;
    final iconColor = isUrgent ? AppColors.warningText : AppColors.primary;
    final textColor = isUrgent ? AppColors.warningText : AppColors.primary;
    final icon = mapSlotTypeToIcon(slotType);
    return Stack(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 4),
              Text(label, style: AppTextStyles.labelChip(context).copyWith(color: textColor)),
            ],
          ),
        ),
        Positioned(
          left: -2, top: -2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.close, size: 10, color: AppColors.textSecondary),
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

  const _PreviewPatient({required this.number, required this.type, this.isUrgent = false, this.faded = false});

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent ? AppColors.warningBg : AppColors.surface;
    final border = isUrgent ? AppColors.warningText.withAlpha(25) : AppColors.border;
    final numColor = isUrgent ? AppColors.warningText : AppColors.primary;
    final chipBg = isUrgent ? AppColors.surface.withAlpha(128) : AppColors.primaryLight;
    final chipText = isUrgent ? AppColors.warningText : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceSm),
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
              child: Text('$number.', style: AppTextStyles.dataNumeric(context).copyWith(color: numColor)),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Expanded(
              child: Text('مريض #$number', style: AppTextStyles.bodyMedium(context).copyWith(
                color: isUrgent ? AppColors.warningText : AppColors.textPrimary,
                fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
              )),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 3),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                border: isUrgent ? Border.all(color: AppColors.warningText.withAlpha(50)) : null,
              ),
              child: Text(type, style: AppTextStyles.labelChip(context).copyWith(color: chipText)),
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

  const _SlotTypeOption({required this.label, required this.slotType, required this.icon, required this.color});
}

// ────────────────────────────────────────────────────────
// دوال مساعدة لتحويل QueueSlotType إلى بيانات العرض
// ────────────────────────────────────────────────────────
String mapSlotTypeToLabel(String slotType) {
  switch (slotType) {
    case 'urgent': return 'مستعجل';
    case 'revisit': return 'مراجعة';
    case 'consult': return 'استشارة';
    case 'normal': default: return 'عادي';
  }
}

IconData mapSlotTypeToIcon(String slotType) {
  switch (slotType) {
    case 'urgent': return Icons.bolt;
    case 'revisit': return Icons.refresh;
    case 'consult': return Icons.forum;
    case 'normal': default: return Icons.person;
  }
}

bool isSlotTypeUrgent(String slotType) => slotType == 'urgent';
