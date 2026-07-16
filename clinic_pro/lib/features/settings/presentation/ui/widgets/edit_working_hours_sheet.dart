import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/i_cloud_service.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/localization/language_cubit.dart';
import '../../manager/settings_cubit.dart';

class WorkingHoursDay {
  final String dayKey;
  final String dayName;
  final String keyChar;
  bool isOpen;
  List<WorkingPeriod> periods;

  WorkingHoursDay({
    required this.dayKey,
    required this.dayName,
    required this.keyChar,
    this.isOpen = true,
    required this.periods,
  });
}

class WorkingPeriod {
  TimeOfDay start;
  TimeOfDay end;

  WorkingPeriod({required this.start, required this.end});
}

class _DayConfig {
  final String key;
  final String name;
  final String char;
  const _DayConfig(this.key, this.name, this.char);
}

class EditWorkingHoursSheet extends StatefulWidget {
  final String clinicId;

  const EditWorkingHoursSheet({super.key, required this.clinicId});

  static Future<void> show(BuildContext context) {
    final clinicId = context.read<SettingsCubit>().state.clinicId;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditWorkingHoursSheet(clinicId: clinicId),
    );
  }

  @override
  State<EditWorkingHoursSheet> createState() => _EditWorkingHoursSheetState();
}

class _EditWorkingHoursSheetState extends State<EditWorkingHoursSheet> {
  final ICloudService _cloudService = sl<ICloudService>();
  List<WorkingHoursDay> _schedule = [];
  bool _isLoading = true;

  static const _dayConfigs = [
    _DayConfig('saturday', 'السبت', 'S'),
    _DayConfig('sunday', 'الأحد', 'S'),
    _DayConfig('monday', 'الاثنين', 'M'),
    _DayConfig('tuesday', 'الثلاثاء', 'T'),
    _DayConfig('wednesday', 'الأربعاء', 'W'),
    _DayConfig('thursday', 'الخميس', 'T'),
    _DayConfig('friday', 'الجمعة', 'F'),
  ];

  String _dayName(String dayKey) {
    final index = AppStrings.dayKeys.indexOf(dayKey);
    return index >= 0 ? AppStrings.dayNames[index] : dayKey;
  }

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  Future<void> _loadWorkingHours() async {
    try {
      final results = await _cloudService.select(
        table: 'clinic_working_hours',
        eq: {'clinic_id': widget.clinicId},
      );

      final Map<String, dynamic>? data =
          results.isNotEmpty ? results.first : null;

      final schedule = _dayConfigs.map((cfg) {
        final raw = data?[cfg.key] as String?;
        if (raw == null || raw == AppStrings.closed) {
          return WorkingHoursDay(
            dayKey: cfg.key,
            dayName: _dayName(cfg.key),
            keyChar: cfg.char,
            isOpen: false,
            periods: [],
          );
        }
        return WorkingHoursDay(
          dayKey: cfg.key,
          dayName: _dayName(cfg.key),
          keyChar: cfg.char,
          isOpen: true,
          periods: _parsePeriods(raw),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _schedule = schedule;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<WorkingPeriod> _parsePeriods(String raw) {
    final parts = raw.split(' - ');
    if (parts.length == 2) {
      final start = _parseTime(parts[0]);
      final end = _parseTime(parts[1]);
      if (start != null && end != null) {
        return [WorkingPeriod(start: start, end: end)];
      }
    }
    return [];
  }

  TimeOfDay? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatPeriods(List<WorkingPeriod> periods) {
    if (periods.isEmpty) return AppStrings.closed;
    final start = _formatTime(periods.first.start);
    final end = _formatTime(periods.first.end);
    return '$start - $end';
  }

  Future<void> _saveWorkingHours() async {
    try {
      final data = <String, dynamic>{
        'clinic_id': widget.clinicId,
      };
      for (final day in _schedule) {
        data[day.dayKey] = _formatPeriods(day.periods);
      }

      final existing = await _cloudService.select(
        table: 'clinic_working_hours',
        eq: {'clinic_id': widget.clinicId},
      );

      if (existing.isNotEmpty) {
        await _cloudService.update(
          table: 'clinic_working_hours',
          data: data,
          matchColumn: 'clinic_id',
          matchValue: widget.clinicId,
        );
      } else {
        await _cloudService.insert(
          table: 'clinic_working_hours',
          data: data,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ مواعيد العمل بنجاح ✓'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحفظ: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
        child: _isLoading
            ? const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppConstants.spaceMd),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.screenEdgeH),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month,
                                color: context.primary, size: 24),
                            const SizedBox(width: AppConstants.spaceSm),
                            Text(
                              AppStrings.workingHours,
                              style: AppTextStyles.headlineSmall(context)
                                  .copyWith(
                                      color: context.primary,
                                      fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: context.border),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.screenEdgeH),
                      itemCount: _schedule.length,
                      itemBuilder: (context, index) {
                        final day = _schedule[index];
                        return _buildDayCard(day);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceLg),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: context.border, width: 1)),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _saveWorkingHours,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spaceMd),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(AppStrings.save,
                          style: AppTextStyles.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.surfaceBright)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDayCard(WorkingHoursDay day) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color:
            day.isOpen ? context.surface : context.background.withOpacity(0.6),
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
                      color: day.isOpen
                          ? context.primaryLightColor
                          : context.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        day.keyChar,
                        style: TextStyle(
                          color: day.isOpen
                              ? context.textPrimary
                              : context.textSecondary,
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
                      color: day.isOpen
                          ? context.textPrimary
                          : context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Switch(
                value: day.isOpen,
                activeColor: context.primary,
                onChanged: (val) {
                  setState(() {
                    day.isOpen = val;
                    if (val && day.periods.isEmpty) {
                      day.periods.add(
                        WorkingPeriod(
                          start: const TimeOfDay(hour: 9, minute: 0),
                          end: const TimeOfDay(hour: 17, minute: 0),
                        ),
                      );
                    } else if (!val) {
                      day.periods.clear();
                    }
                  });
                },
              ),
            ],
          ),
          if (!day.isOpen) ...[
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'يوم مغلق - لا يوجد مواعيد',
              style: AppTextStyles.caption(context)
                  .copyWith(color: context.textHint),
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
                          child: Divider(
                              height: 1, thickness: 0.5, color: context.border),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('من',
                                    style: AppTextStyles.caption(context)
                                        .copyWith(color: context.textHint)),
                                const SizedBox(height: 4),
                                _buildTimeSelector(period.start, (newTime) {
                                  setState(() => period.start = newTime);
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('إلى',
                                    style: AppTextStyles.caption(context)
                                        .copyWith(color: context.textHint)),
                                const SizedBox(height: 4),
                                _buildTimeSelector(period.end, (newTime) {
                                  setState(() => period.end = newTime);
                                }),
                              ],
                            ),
                          ),
                          if (day.periods.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  day.periods.removeAt(pIndex);
                                });
                              },
                              icon: Icon(Icons.delete,
                                  color: context.danger, size: 20),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            // TextButton.icon(
            //   onPressed: () {
            //     setState(() {
            //       day.periods.add(
            //         WorkingPeriod(
            //           start: const TimeOfDay(hour: 17, minute: 0),
            //           end: const TimeOfDay(hour: 20, minute: 0),
            //         ),
            //       );
            //     });
            //   },
            //   icon:  Icon(Icons.add_circle_outline,
            //       size: 18, color: context.primary),
            //   label: Text(
            //     day.periods.isEmpty
            //         ? 'إضافة فترة'
            //         : day.periods.length == 1
            //             ? 'إضافة فترة ثانية'
            //             : 'إضافة فترة ثالثة',
            //     style: AppTextStyles.bodyMedium(context).copyWith(
            //         color: context.primary, fontWeight: FontWeight.bold),
            //   ),
            //  ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector(TimeOfDay time, Function(TimeOfDay) onChange) {
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
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd, vertical: 12),
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
