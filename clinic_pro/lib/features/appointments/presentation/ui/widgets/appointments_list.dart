// ────────────────────────────────────────────────────────
// قائمة المواعيد مع فلاتر الحالة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/appointments_state.dart';
import 'appointment_list_item.dart';

class AppointmentsList extends StatelessWidget {
  final List<AppointmentItem> appointments;
  final String statusFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<AppointmentItem> onItemTap;
  final ValueChanged<AppointmentItem> onItemMore;

  const AppointmentsList({
    super.key,
    required this.appointments,
    required this.statusFilter,
    required this.onFilterChanged,
    required this.onItemTap,
    required this.onItemMore,
  });

  static const _filters = [
    ('all', 'الكل'),
    ('scheduled', 'مجدول'),
    ('confirmed', 'مؤكد'),
    ('in_progress', 'قيد الكشف'),
    ('done', 'منتهي'),
    ('cancelled', 'ملغي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // فلاتر الحالة
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _filters.map((f) {
              final isSelected = statusFilter == f.$1;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(f.$2),
                  selected: isSelected,
                  onSelected: (_) => onFilterChanged(f.$1),
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
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // القائمة أو الحالة الفارغة
        if (appointments.isEmpty)
          const EmptyState(
            title: 'لا توجد مواعيد',
            subtitle: 'لا يوجد مواعيد تطابق الفلتر الحالي.',
            icon: Icons.event_busy_outlined,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final item = appointments[index];
              return AppointmentListItem(
                appointment: item,
                onTap: () => onItemTap(item),
                onMore: () => onItemMore(item),
              );
            },
          ),
      ],
    );
  }
}
