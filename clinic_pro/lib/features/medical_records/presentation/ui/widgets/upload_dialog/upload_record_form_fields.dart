// ────────────────────────────────────────────────────────
// حقول البيانات الإضافية للفحص (UploadRecordFormFields)
// تشمل اسم الفحص مع مقترحات سريعة، تاريـخ إجراء الفحص، والملاحظات
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';

class UploadRecordFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController notesController;
  final DateTime selectedDate;
  final List<String> suggestions;
  final VoidCallback onSelectDate;
  final ValueChanged<String> onSelectSuggestion;

  const UploadRecordFormFields({
    super.key,
    required this.titleController,
    required this.notesController,
    required this.selectedDate,
    required this.suggestions,
    required this.onSelectDate,
    required this.onSelectSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اسم الفحص / التحليل
        Text(
          AppStrings.recordTitleLabel,
          style: AppTextStyles.caption(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: AppStrings.recordTitleHint,
            prefixIcon: const Icon(Icons.title_rounded, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return AppStrings.recordTitleRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 8),

        // رقاقات المقترحات السريعة
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: suggestions.map((s) {
            return ActionChip(
              label: Text(s, style: const TextStyle(fontSize: 11)),
              onPressed: () => onSelectSuggestion(s),
              backgroundColor: context.surfaceContainerLow,
              side: BorderSide(color: context.borderColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusChip),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // تاريخ الفحص
        Text(
          AppStrings.recordDateLabel,
          style: AppTextStyles.caption(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onSelectDate,
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: context.borderColor),
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              color: context.surfaceColor,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 20, color: context.primary),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  style: AppTextStyles.bodyMedium(context),
                ),
                const Spacer(),
                Text(
                  AppStrings.changeDate,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // ملاحظات الطبيب
        Text(
          AppStrings.doctorNotesOptional,
          style: AppTextStyles.caption(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: AppStrings.doctorNotesHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
