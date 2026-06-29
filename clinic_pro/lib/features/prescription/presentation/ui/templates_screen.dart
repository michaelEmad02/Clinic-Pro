// ────────────────────────────────────────────────────────
// شاشة إدارة قوالب الروشتات — تصفح، فلترة، إضافة وتعديل
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../manager/templates_cubit.dart';
import '../manager/templates_state.dart';
import 'widgets/add_edit_template_sheet.dart';
import 'widgets/template_action_sheet.dart';
import 'widgets/template_preview_dialog.dart';
import 'widgets/drugs_category_chips.dart';
import 'widgets/drugs_search_bar.dart';
import 'widgets/templates_list.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TemplatesCubit()..loadTemplates(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: 64,
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'قوالب الروشتات',
            style: AppTextStyles.headlineMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.border, height: 1),
          ),
        ),
        body: BlocBuilder<TemplatesCubit, TemplatesState>(
          builder: (context, state) {
            if (state is TemplatesLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: ShimmerList(),
              );
            }

            if (state is TemplatesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<TemplatesCubit>().loadTemplates(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is TemplatesLoaded) {
              return RefreshIndicator(
                onRefresh: () => context.read<TemplatesCubit>().loadTemplates(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 8),
                    DrugsSearchBar(
                      onChanged: (q) => context.read<TemplatesCubit>().search(q),
                    ),
                    const SizedBox(height: 8),
                    DrugsCategoryChips(
                      selectedCategory: state.selectedCategory,
                      onCategorySelected: (cat) => context.read<TemplatesCubit>().filterByCategory(cat),
                    ),
                    const SizedBox(height: 12),
                    TemplatesList(
                      templates: state.templates,
                      searchQuery: state.searchQuery,
                      selectedCategory: state.selectedCategory,
                      onPreview: (template) => _showPreviewDialog(context, template),
                      onAction: (template) => _showTemplateActions(context, template),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () => _showAddTemplateSheet(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  void _showAddTemplateSheet(BuildContext context) {
    final templatesCubit = context.read<TemplatesCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddEditTemplateSheet(
            onSave: (title, category, drugs) {
              templatesCubit.addTemplate(title, category, drugs);
            },
          ),
        ),
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, Map<String, dynamic> template) {
    showDialog(
      context: context,
      builder: (_) => TemplatePreviewDialog(template: template),
    );
  }

  void _showTemplateActions(BuildContext context, Map<String, dynamic> template) {
    final templatesCubit = context.read<TemplatesCubit>();
    TemplateActionSheet.show(
      context: context,
      template: template,
      onDelete: () {
        templatesCubit.deleteTemplate(template['id']);
      },
    );
  }
}
