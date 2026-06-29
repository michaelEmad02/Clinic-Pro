import 'package:flutter/material.dart';
import '../../../../../core/widgets/empty_state.dart';
import 'template_list_item.dart';

class TemplatesList extends StatelessWidget {
  final List<Map<String, dynamic>> templates;
  final String? searchQuery;
  final String? selectedCategory;
  final Function(Map<String, dynamic>) onPreview;
  final Function(Map<String, dynamic>) onAction;

  const TemplatesList({
    super.key,
    required this.templates,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onPreview,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = templates.where((t) {
      final matchesCategory = selectedCategory == null || t['category'] == selectedCategory;
      
      final q = searchQuery?.toLowerCase() ?? '';
      final matchesSearch = q.isEmpty || (t['title'] as String).toLowerCase().contains(q);

      return matchesCategory && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: EmptyState(
          icon: Icons.assignment_outlined,
          title: 'لا توجد قوالب مطابقة',
          subtitle: 'حاول تغيير معايير البحث أو تصنيف الفلترة أو أضف قالباً جديداً.',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final template = filtered[index];
        return TemplateListItem(
          template: template,
          onTap: () => onPreview(template),
          onMoreTap: () => onAction(template),
        );
      },
    );
  }
}
