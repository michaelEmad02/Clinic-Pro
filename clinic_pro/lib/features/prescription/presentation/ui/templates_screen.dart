// ────────────────────────────────────────────────────────
// شاشة إدارة قوالب الروشتات — تصفح، فلترة، إضافة وتعديل (Responsive)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/templates_cubit.dart';
import '../manager/templates_state.dart';
import 'widgets/add_edit_template_sheet.dart';
import 'widgets/template_action_sheet.dart';
import 'widgets/template_preview_dialog.dart';
import 'widgets/drugs_search_bar.dart';
import 'widgets/templates_list.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TemplatesCubit>()..loadTemplates(),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          toolbarHeight: 64,
          backgroundColor: context.surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            AppStrings.prescriptionTemplates,
            style: AppTextStyles.headlineMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.primary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: context.borderColor, height: 1),
          ),
        ),
        body: BlocBuilder<TemplatesCubit, TemplatesState>(
          builder: (context, state) {
            if (state is TemplatesLoading) {
              return ResponsiveHelper.responsiveCenter(
                maxWidth: AppConstants.maxContentWidth,
                child: const Padding(
                  padding: EdgeInsets.all(AppConstants.spaceMd),
                  child: ShimmerList(itemCount: 6),
                ),
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
                    const SizedBox(height: AppConstants.spaceSm + 4),
                    ElevatedButton(
                      onPressed: () => context.read<TemplatesCubit>().loadTemplates(),
                      child: Text(AppStrings.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is TemplatesLoaded) {
              return RefreshIndicator(
                onRefresh: () => context.read<TemplatesCubit>().loadTemplates(),
                child: ResponsiveHelper.responsiveCenter(
                  maxWidth: AppConstants.maxContentWidth,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
                    children: [
                      DrugsSearchBar(
                        onChanged: (q) => context.read<TemplatesCubit>().search(q),
                      ),
                      const SizedBox(height: AppConstants.spaceSm + 4),
                      TemplatesList(
                        templates: state.templates,
                        searchQuery: state.searchQuery,
                        onPreview: (template) => _showPreviewDialog(context, template),
                        onAction: (template) => _showTemplateActions(context, template),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
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
              backgroundColor: context.primary,
              child: Icon(Icons.add, color: context.onPrimary),
            );
          },
        ),
      ),
    );
  }

  void _showAddTemplateSheet(BuildContext context) {
    final templatesCubit = context.read<TemplatesCubit>();
    AppBottomSheet.show(
      context: context,
      child: AddEditTemplateSheet(
        onSave: (name, drugs) {
          templatesCubit.addTemplate(name, drugs);
        },
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
      onEdit: () {
        _showEditTemplateSheet(context, template);
      },
    );
  }

  void _showEditTemplateSheet(BuildContext context, Map<String, dynamic> template) {
    final templatesCubit = context.read<TemplatesCubit>();
    AppBottomSheet.show(
      context: context,
      child: AddEditTemplateSheet(
        template: template,
        onSave: (name, drugs) {
          templatesCubit.editTemplate(template['id'], name, drugs);
        },
      ),
    );
  }
}
