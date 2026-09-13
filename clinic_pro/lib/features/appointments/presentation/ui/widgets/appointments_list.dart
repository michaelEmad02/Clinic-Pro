// ────────────────────────────────────────────────────────
// قائمة المواعيد مع فلاتر الحالة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', AppStrings.all),
      ('scheduled', AppStrings.scheduled),
      ('confirmed', AppStrings.confirmed),
      ('in_progress', AppStrings.inProgress),
      ('done', AppStrings.completed),
      ('cancelled', AppStrings.cancelled),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // فلاتر الحالة
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: Row(
            children: filters.map((f) {
              final isSelected = statusFilter == f.$1;
              return Padding(
                padding: const EdgeInsets.only(left: AppConstants.spaceSm),
                child: ChoiceChip(
                  label: Text(f.$2),
                  selected: isSelected,
                  onSelected: (_) => onFilterChanged(f.$1),
                  selectedColor: context.primary,
                  backgroundColor: context.surfaceColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  labelStyle: AppTextStyles.bodyMedium(context).copyWith(
                    color: isSelected ? context.onPrimary : context.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusChip),
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
        const SizedBox(height: AppConstants.spaceSm + 4),
        // القائمة أو الحالة الفارغة (تخطيط متجاوب بين الهواتف والأجهزة اللوحية والمكتبية)
        if (appointments.isEmpty)
          EmptyState(
            title: AppStrings.noData,
            subtitle: AppStrings.noAppointmentsMatchFilter,
            icon: Icons.event_busy_outlined,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // حساب عدد الأعمدة ديناميكياً ليملأ كامل عرض الشاشة مع مقاس بطاقة مريح (~340 بكسل)
              // على الشاشات الكبيرة (1920px مثلاً): سيتم عرض 4 إلى 5 بطاقات في الصف الواحد
              final int columns = (width / 340).floor().clamp(1, 6);

              if (columns == 1) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceSm + 4),
                  itemBuilder: (context, index) {
                    final item = appointments[index];
                    return AppointmentListItem(
                      appointment: item,
                      onTap: () => onItemTap(item),
                      onMore: () => onItemMore(item),
                    );
                  },
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppConstants.spaceSm + 4,
                  crossAxisSpacing: AppConstants.spaceSm + 4,
                  mainAxisExtent: 178,
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
              );
            },
          ),
      ],
    );
  }
}
