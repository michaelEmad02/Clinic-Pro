// ────────────────────────────────────────────────────────
// WorkingDayCard — بطاقة إعداد ساعات العمل ليوم معين
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/working_hours_state.dart';

class WorkingDayCard extends StatelessWidget {
  final WorkingHoursDay day;
  final Function(bool) onToggle;
  final Function(int, WorkingPeriod) onPeriodUpdate;
  final Function(int) onPeriodRemove;

  const WorkingDayCard({
    super.key,
    required this.day,
    required this.onToggle,
    required this.onPeriodUpdate,
    required this.onPeriodRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: day.isOpen ? context.surface : context.background.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: day.isOpen ? context.primaryLightColor : context.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        day.keyChar,
                        style: TextStyle(
                          color: day.isOpen ? context.textPrimary : context.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Text(
                    day.dayName,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      color: day.isOpen ? context.textPrimary : context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Switch(
                value: day.isOpen,
                activeColor: context.primary,
                onChanged: onToggle,
              ),
            ],
          ),
          if (!day.isOpen) ...[
            const SizedBox(height: AppConstants.spaceSm),
              Text(
                AppStrings.dayClosed,
                style: AppTextStyles.caption(context).copyWith(color: context.textHint),
              ),
          ],
          if (day.isOpen) ...[
            const SizedBox(height: AppConstants.spaceMd),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: day.periods.length,
              itemBuilder: (context, pIndex) {
                final period = day.periods[pIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                  child: Column(
                    children: [
                      if (pIndex > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1, thickness: 0.5, color: context.border),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.fromLabel, style: AppTextStyles.caption(context).copyWith(color: context.textHint)),
                                const SizedBox(height: 4),
                                _TimeSelector(
                                  time: period.start,
                                  onChange: (newTime) => onPeriodUpdate(
                                    pIndex,
                                    WorkingPeriod(start: newTime, end: period.end),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.toLabel, style: AppTextStyles.caption(context).copyWith(color: context.textHint)),
                                const SizedBox(height: 4),
                                _TimeSelector(
                                  time: period.end,
                                  onChange: (newTime) => onPeriodUpdate(
                                    pIndex,
                                    WorkingPeriod(start: period.start, end: newTime),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (day.periods.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => onPeriodRemove(pIndex),
                              icon: Icon(Icons.delete, color: context.danger, size: 20),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final TimeOfDay time;
  final Function(TimeOfDay) onChange;

  const _TimeSelector({required this.time, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selected != null) {
          onChange(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 12),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time.format(context),
              style: AppTextStyles.bodyLarge(context).copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.schedule, size: 16, color: context.textHint),
          ],
        ),
      ),
    );
  }
}
