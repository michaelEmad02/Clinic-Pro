import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/prescription_enums.dart';

class TemplateDrugEditCard extends StatelessWidget {
  final Map<String, dynamic> drug;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const TemplateDrugEditCard({
    super.key,
    required this.drug,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final frequencies = DrugFrequency.values.where((e) => e != DrugFrequency.on_demand).toList();
    final durations = DrugDuration.values.toList();
    final timings = DrugTiming.values.toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrnRow(context),
                if (!(drug['is_prn'] as bool? ?? false)) ...[
                  const SizedBox(height: 8),
                  _buildRowTitle(context, 'التكرار'),
                  const SizedBox(height: 8),
                  _buildChipsRow(
                    context: context,
                    entries: frequencies,
                    isSelected: (e) => drug['frequency'] == e.dbValue,
                    onTap: (e) {
                      drug['frequency'] = e.dbValue;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildRowTitle(context, 'المدة'),
                  const SizedBox(height: 8),
                  _buildChipsRow(
                    context: context,
                    entries: durations,
                    isSelected: (e) => drug['duration'] == e.dbValue,
                    onTap: (e) {
                      drug['duration'] = e.dbValue;
                      onChanged();
                    },
                  ),
                ],
                const SizedBox(height: 16),
                _buildRowTitle(context, 'التوقيت'),
                const SizedBox(height: 8),
                _buildChipsRow(
                  context: context,
                  entries: timings,
                  isSelected: (e) => drug['timing'] == e.dbValue,
                  onTap: (e) {
                    drug['timing'] = e.dbValue;
                    onChanged();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                drug['trade_name'] ?? '',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  drug['form'] ?? '',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildPrnRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRowTitle(context, 'عند اللزوم (PRN)'),
        Switch(
          value: drug['is_prn'] as bool? ?? false,
          activeColor: AppColors.primary,
          onChanged: (val) {
            drug['is_prn'] = val;
            if (val) {
              drug['frequency'] = null;
              drug['duration'] = null;
            } else {
              drug['frequency'] = DrugFrequency.twice.dbValue;
              drug['duration'] = DrugDuration.sevenDays.dbValue;
            }
            onChanged();
          },
        ),
      ],
    );
  }

  Widget _buildRowTitle(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.caption(context).copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChipsRow<T>({
    required BuildContext context,
    required List<T> entries,
    required bool Function(T) isSelected,
    required void Function(T) onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((entry) {
        final selected = isSelected(entry);
        String label;
        if (entry is DrugFrequency) {
          label = entry.label;
        } else if (entry is DrugDuration) {
          label = entry.label;
        } else if (entry is DrugTiming) {
          label = entry.label;
        } else {
          label = entry.toString();
        }
        return GestureDetector(
          onTap: () => onTap(entry),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryLight : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
