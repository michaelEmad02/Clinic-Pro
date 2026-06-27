import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_list_item.dart';
import '../../manager/secretary_dashboard_state.dart';

class TodayAppointmentsList extends StatefulWidget {
  final List<AppointmentMock> appointments;
  final Function(String) onConfirmArrival;

  const TodayAppointmentsList({
    super.key,
    required this.appointments,
    required this.onConfirmArrival,
  });

  @override
  State<TodayAppointmentsList> createState() => _TodayAppointmentsListState();
}

class _TodayAppointmentsListState extends State<TodayAppointmentsList> {
  String _activeFilter = 'all'; // 'all', 'scheduled', 'confirmed', 'in_progress'

  @override
  Widget build(BuildContext context) {
    // Filter appointments
    final filteredApps = widget.appointments.where((app) {
      if (_activeFilter == 'all') return true;
      return app.status == _activeFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جدول مواعيد اليوم',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'عرض الجدول الكامل',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('الكل', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('مجدول', 'scheduled'),
              const SizedBox(width: 8),
              _buildFilterChip('مؤكد حضورهم', 'confirmed'),
              const SizedBox(width: 8),
              _buildFilterChip('قيد الكشف', 'in_progress'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (filteredApps.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'لا يوجد مواعيد تطابق الفلتر الحالي.',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredApps.length,
            itemBuilder: (context, index) {
              final app = filteredApps[index];
              final isScheduled = app.status == 'scheduled';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppListItem(
                  title: app.patientName,
                  subtitle: '${app.doctorName} • ${app.time}',
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isScheduled)
                        ElevatedButton(
                          onPressed: () => widget.onConfirmArrival(app.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successBg,
                            foregroundColor: AppColors.successText,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'تأكيد الحضور',
                            style: AppTextStyles.caption(context).copyWith(
                              color: AppColors.successText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        _buildStatusBadge(app.status),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                        onPressed: () {
                          // Action bottom sheet
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String filterKey) {
    final isSelected = _activeFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _activeFilter = filterKey;
          });
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.primaryLight;
    Color text = AppColors.primary;
    String label = 'مجهول';

    if (status == 'confirmed') {
      bg = AppColors.successBg;
      text = AppColors.successText;
      label = 'مؤكد';
    } else if (status == 'in_progress') {
      bg = const Color(0xFFE0F2FE);
      text = const Color(0xFF0369A1);
      label = 'عند الطبيب';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(context).copyWith(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
