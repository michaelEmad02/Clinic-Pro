import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/empty_state.dart';
import 'drug_list_item.dart';

class DrugsList extends StatelessWidget {
  final List<Map<String, dynamic>> drugs;
  final String? searchQuery;
  final String? selectedCategory;
  final Function(Map<String, dynamic>) onDrugAction;

  const DrugsList({
    super.key,
    required this.drugs,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onDrugAction,
  });

  @override
  Widget build(BuildContext context) {
    // تصفية الأدوية برمجياً بناءً على البحث والتصنيف
    final filtered = drugs.where((d) {
      final matchesCategory = selectedCategory == null || d['category'] == selectedCategory;
      
      final q = searchQuery?.toLowerCase() ?? '';
      final matchesSearch = q.isEmpty ||
          (d['trade_name'] as String).toLowerCase().contains(q) ||
          (d['generic_name'] as String).toLowerCase().contains(q);

      return matchesCategory && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: EmptyState(
          icon: Icons.medication_outlined,
          title: AppStrings.noDrugs,
          subtitle: '${AppStrings.search} ${AppStrings.drug}',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final drug = filtered[index];
        return DrugListItem(
          drug: drug,
          onTap: () => onDrugAction(drug),
        );
      },
    );
  }
}
