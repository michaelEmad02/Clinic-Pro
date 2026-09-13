// ────────────────────────────────────────────────────────
// قائمة قوالب الروشتات (Responsive Grid/List)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/empty_state.dart';
import 'template_list_item.dart';

class TemplatesList extends StatelessWidget {
  final List<Map<String, dynamic>> templates;
  final String? searchQuery;
  final ValueChanged<Map<String, dynamic>> onPreview;
  final ValueChanged<Map<String, dynamic>> onAction;

  const TemplatesList({
    super.key,
    required this.templates,
    this.searchQuery,
    required this.onPreview,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    var filtered = List<Map<String, dynamic>>.from(templates);

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered.where((t) {
        final name = (t['name'] as String? ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    }

    if (filtered.isEmpty) {
      return EmptyState(
        title: AppStrings.noTemplates,
        subtitle: AppStrings.noData,
        icon: Icons.description_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // أعمدة متجاوبة ديناميكياً: عمود 1 على الموبايل، عمودان على التابلت، 3 إلى 4 أعمدة على الديسك توب
        final int columns = (width / 340).floor().clamp(1, 4);

        if (columns == 1) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 140,
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
          ),
        );
      },
    );
  }
}
