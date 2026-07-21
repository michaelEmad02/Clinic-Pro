// ────────────────────────────────────────────────────────
// شبكة الطاقم الطبي — Grid متجاوب (1/2/3 أعمدة)
// مستوحى من تصميم phase8_ui/staff_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/widgets/empty_state.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'staff_list_item.dart';

class StaffList extends StatelessWidget {
  final List<StaffEntity> staffList;
  final ValueChanged<StaffEntity> onItemTap;
  final ValueChanged<StaffEntity> onItemMore;
  final Map<String, String>? clinicNames;

  const StaffList({
    super.key,
    required this.staffList,
    required this.onItemTap,
    required this.onItemMore,
    this.clinicNames,
  });

  @override
  Widget build(BuildContext context) {
    if (staffList.isEmpty) {
      return EmptyState(
        title: AppStrings.noStaff,
        subtitle: AppStrings.isArabic ? 'لم يتم إضافة أي موظفين بعد.' : 'No staff members have been added yet.',
        icon: Icons.group_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = ResponsiveHelper.isMobile(context);
          final crossAxisCount = ResponsiveHelper.gridColumns(context);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.55 : 1.85,
            ),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return StaffListItem(
                staff: staff,
                onTap: () => onItemTap(staff),
                onMore: () => onItemMore(staff),
                clinicName: clinicNames?[staff.clinicId],
              );
            },
          );
        },
      ),
    );
  }
}
