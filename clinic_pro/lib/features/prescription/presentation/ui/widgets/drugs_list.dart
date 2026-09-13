// ────────────────────────────────────────────────────────
// قائمة الأدوية (Responsive Grid/List)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/empty_state.dart';
import 'drug_list_item.dart';

class DrugsList extends StatelessWidget {
  final List<Map<String, dynamic>> drugs;
  final String? searchQuery;
  final String? selectedCategory;
  final ValueChanged<Map<String, dynamic>> onDrugAction;

  const DrugsList({
    super.key,
    required this.drugs,
    this.searchQuery,
    this.selectedCategory,
    required this.onDrugAction,
  });

  @override
  Widget build(BuildContext context) {
    var filtered = List<Map<String, dynamic>>.from(drugs);

    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((d) => d['category'] == selectedCategory)
          .toList();
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered.where((d) {
        final tradeName = (d['trade_name'] as String? ?? '').toLowerCase();
        final genericName = (d['generic_name'] as String? ?? '').toLowerCase();
        final category = (d['category'] as String? ?? '').toLowerCase();
        return tradeName.contains(query) ||
            genericName.contains(query) ||
            category.contains(query);
      }).toList();
    }

    if (filtered.isEmpty) {
      return EmptyState(
        title: AppStrings.noData,
        subtitle: AppStrings.noData,
        icon: Icons.medication_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // أعمدة متجاوبة ديناميكياً: عمود 1 على الموبايل، عمودان على الشاشات المتوسطة، 3 إلى 5 أعمدة على الديسك توب
        final int columns = (width / 340).floor().clamp(1, 5);

        if (columns == 1) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final drug = filtered[index];
              return DrugListItem(
                drug: drug,
                onTap: () => onDrugAction(drug),
              );
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 96,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final drug = filtered[index];
              return DrugListItem(
                drug: drug,
                onTap: () => onDrugAction(drug),
              );
            },
          ),
        );
      },
    );
  }
}
