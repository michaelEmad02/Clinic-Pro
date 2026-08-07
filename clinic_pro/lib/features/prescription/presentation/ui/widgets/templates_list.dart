// ────────────────────────────────────────────────────────
// قائمة قوالب الروشتات (Responsive Grid/List)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/utils/responsive_helper.dart';
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

    if (!ResponsiveHelper.isMobile(context)) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisSpacing: AppConstants.spaceSm + 4,
          crossAxisSpacing: AppConstants.spaceSm + 4,
          childAspectRatio: 2.2,
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
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
