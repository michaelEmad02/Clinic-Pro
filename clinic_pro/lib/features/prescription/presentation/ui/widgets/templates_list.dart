import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
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
      final matchesSearch = q.isEmpty || (t['name'] as String? ?? '').toLowerCase().contains(q);

      return matchesCategory && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: EmptyState(
          icon: Icons.assignment_outlined,
          title: AppStrings.noTemplates,
          subtitle: '${AppStrings.search} ${AppStrings.template}',
        ),
      );
    }

    final double width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossAxisCount == 1 ? 2.1 : 1.5,
      ),
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
