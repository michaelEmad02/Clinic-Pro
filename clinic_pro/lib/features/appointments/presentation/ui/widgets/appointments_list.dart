// ────────────────────────────────────────────────────────
// قائمة المواعيد مع فلاتر الحالة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../domain/entities/appointment_entity.dart';
import 'appointment_list_item.dart';

class AppointmentsList extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  final String statusFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<AppointmentEntity> onItemTap;
  final ValueChanged<AppointmentEntity> onItemMore;

  const AppointmentsList({
    super.key,
    required this.appointments,
    required this.statusFilter,
    required this.onFilterChanged,
    required this.onItemTap,
    required this.onItemMore,
  });

  static final _filters = [
    ('all', AppStrings.all),
    ('scheduled', AppStrings.scheduled),
    ('confirmed', AppStrings.confirmed),
    ('in_progress', AppStrings.inProgress),
    ('done', AppStrings.completed),
    ('cancelled', AppStrings.cancelled),
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
                  selectedColor: context.primary,
                  backgroundColor: context.surfaceColor,
                  labelStyle: AppTextStyles.caption(context).copyWith(
                    color: isSelected ? context.onPrimary : context.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? context.primary : context.borderColor,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // القائمة أو الحالة الفارغة (تخطيط متجاوب بين الهواتف والأجهزة اللوحية والمكتبية)
        if (appointments.isEmpty)
          EmptyState(
            title: AppStrings.noData,
            subtitle: AppStrings.noAppointmentsMatchFilter,
            icon: Icons.event_busy_outlined,
          )
        else if (!ResponsiveHelper.isMobile(context))
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.gridColumns(context),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 140,
            ),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final item = appointments[index];
              return AppointmentListItem(
                appointment: item,
                onTap: () => onItemTap(item),
                onMore: () => onItemMore(item),
              );
            },
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
