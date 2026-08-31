import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// حقول التشخيص النهائي والملاحظات الإضافية وموعد الزيارة القادمة (أيام)
// ────────────────────────────────────────────────────────

class PrescriptionNotesField extends StatelessWidget {
  final String finalDiagnosis;
  final String notes;
  final int? nextVisitDays;
  final ValueChanged<String> onFinalDiagnosisChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<int?> onNextVisitDaysChanged;

  const PrescriptionNotesField({
    super.key,
    required this.finalDiagnosis,
    required this.notes,
    this.nextVisitDays,
    required this.onFinalDiagnosisChanged,
    required this.onNotesChanged,
    required this.onNextVisitDaysChanged,
  });

  String _formatComputedDate(int days) {
    final target = DateTime.now().add(Duration(days: days));
    return DateFormat('yyyy-MM-dd').format(target);
  }

  Future<void> _pickCustomDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime initial = now.add(Duration(days: nextVisitDays ?? 7));

    final picked = await showDatePicker(
      context: context,
      locale: Localizations.localeOf(context),
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      final diff =
          picked.difference(DateTime(now.year, now.month, now.day)).inDays;
      onNextVisitDaysChanged(diff > 0 ? diff : 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── قسم موعد الزيارة القادمة (الاستشارة) ───
          Row(
            children: [
              Icon(Icons.event_repeat_rounded,
                  size: 18, color: context.primary),
              const SizedBox(width: 6),
              Text(
                isArabic
                    ? 'موعد الزيارة القادمة (الاستشارة)'
                    : 'Next Visit / Follow-up',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (nextVisitDays != null && nextVisitDays! > 0) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => onNextVisitDaysChanged(null),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.dangerBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 14, color: context.danger),
                        const SizedBox(width: 2),
                        Text(
                          isArabic ? 'إلغاء الموعد' : 'Clear',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // رقائق الاختيار السريع لعدد الأيام
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChoiceChip(
                  context,
                  label: isArabic ? '3 أيام' : '3 Days',
                  isSelected: nextVisitDays == 3,
                  onTap: () =>
                      onNextVisitDaysChanged(nextVisitDays == 3 ? null : 3),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  context,
                  label: isArabic ? 'بعد أسبوع (7 أيام)' : '7 Days',
                  isSelected: nextVisitDays == 7,
                  onTap: () =>
                      onNextVisitDaysChanged(nextVisitDays == 7 ? null : 7),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  context,
                  label: isArabic ? 'بعد أسبوعين (14 يوماً)' : '14 Days',
                  isSelected: nextVisitDays == 14,
                  onTap: () =>
                      onNextVisitDaysChanged(nextVisitDays == 14 ? null : 14),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  context,
                  label: isArabic ? 'بعد 21 يوماً' : '21 Days',
                  isSelected: nextVisitDays == 21,
                  onTap: () =>
                      onNextVisitDaysChanged(nextVisitDays == 21 ? null : 21),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  context,
                  label: isArabic ? 'بعد شهر (30 يوماً)' : '30 Days',
                  isSelected: nextVisitDays == 30,
                  onTap: () =>
                      onNextVisitDaysChanged(nextVisitDays == 30 ? null : 30),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  context,
                  label: isArabic ? 'تاريخ من التقويم 📅' : 'From Calendar 📅',
                  isSelected: nextVisitDays != null &&
                      nextVisitDays != 3 &&
                      nextVisitDays != 7 &&
                      nextVisitDays != 14 &&
                      nextVisitDays != 21 &&
                      nextVisitDays != 30,
                  onTap: () => _pickCustomDate(context),
                ),
              ],
            ),
          ),

          if (nextVisitDays != null && nextVisitDays! > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                border: Border.all(color: context.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16, color: context.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'موعد الإعادة: بعد $nextVisitDays ${nextVisitDays == 1 ? "يوم" : "أيام"} (الموافق ${_formatComputedDate(nextVisitDays!)})'
                          : 'Follow-up: After $nextVisitDays days (${_formatComputedDate(nextVisitDays!)})',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            AppStrings.diagnosis,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: finalDiagnosis,
            onChanged: onFinalDiagnosisChanged,
            maxLines: 2,
            style: AppTextStyles.bodyMedium(context),
            decoration: InputDecoration(
              hintText: AppStrings.diagnosisHint,
              hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textHint,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.borderColor),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            AppStrings.notes,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: notes,
            onChanged: onNotesChanged,
            maxLines: 2,
            style: AppTextStyles.bodyMedium(context),
            decoration: InputDecoration(
              hintText: AppStrings.notes,
              hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textHint,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.primary : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(context).copyWith(
            color: isSelected ? context.onPrimary : context.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
