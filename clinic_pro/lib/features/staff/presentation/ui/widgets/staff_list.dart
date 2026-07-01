// ────────────────────────────────────────────────────────
// شبكة الطاقم الطبي — Grid متجاوب (1/2/3 أعمدة)
// مستوحى من تصميم phase8_ui/staff_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/staff_state.dart';
import 'staff_list_item.dart';

class StaffList extends StatelessWidget {
  final List<StaffItem> staffList;
  final ValueChanged<StaffItem> onItemTap;
  final ValueChanged<StaffItem> onItemMore;

  const StaffList({
    super.key,
    required this.staffList,
    required this.onItemTap,
    required this.onItemMore,
  });

  @override
  Widget build(BuildContext context) {
    if (staffList.isEmpty) {
      return const EmptyState(
        title: 'لا يوجد موظفين',
        subtitle: 'لم يتم إضافة أي موظفين بعد.',
        icon: Icons.group_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = ResponsiveHelper.gridColumns(context);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
            ),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return StaffListItem(
                staff: staff,
                onTap: () => onItemTap(staff),
                onMore: () => onItemMore(staff),
              );
            },
          );
        },
      ),
    );
  }
}
