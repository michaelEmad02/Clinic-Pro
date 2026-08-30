import 'package:clinic_pro/features/prescription/presentation/manager/prescription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import '../../../../../core/di/injection_container.dart';
import '../../manager/prescription_bloc.dart';
import '../../manager/prescription_event.dart';
import '../../manager/templates_cubit.dart';
import '../../manager/templates_state.dart';
import 'add_edit_template_sheet.dart';

// ────────────────────────────────────────────────────────
// قسم اختيار قوالب الروشتات الشائعة
// ────────────────────────────────────────────────────────

class TemplatesSelectorSection extends StatelessWidget {
  const TemplatesSelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TemplatesCubit>()..loadTemplates(),
      child: BlocBuilder<TemplatesCubit, TemplatesState>(
        builder: (context, state) {
          final templatesCubit = context.read<TemplatesCubit>();
          final List<Map<String, dynamic>> allTemplates =
              state is TemplatesLoaded ? state.templates : [];
          final String? searchQuery =
              state is TemplatesLoaded ? state.searchQuery : null;

          List<Map<String, dynamic>> filteredTemplates =
              List.from(allTemplates);

          filteredTemplates.sort((a, b) {
            final aUse = a['user_count'] as int? ?? 0;
            final bUse = b['user_count'] as int? ?? 0;
            return bUse.compareTo(aUse);
          });

          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            filteredTemplates = filteredTemplates.where((t) {
              final name = (t['name'] as String? ?? '').toLowerCase();
              return name.contains(query);
            }).toList();
          }

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: AppConstants.spaceSm,
            ),
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description_outlined, color: context.primary),
                        const SizedBox(width: AppConstants.spaceSm),
                        Text(
                          AppStrings.prescriptionTemplates,
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () =>
                          _showAddTemplateSheet(context, templatesCubit),
                      icon: Icon(Icons.add_circle_outline, color: context.primary),
                      tooltip: AppStrings.addTemplate,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSm + 4),
                TextField(
                  style: AppTextStyles.bodyMedium(context),
                  onChanged: (val) {
                    templatesCubit.search(val);
                  },
                  decoration: InputDecoration(
                    hintText: '${AppStrings.search} ${AppStrings.template}',
                    hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textHint,
                    ),
                    prefixIcon:
                        Icon(Icons.search, color: context.textHint, size: AppConstants.iconSizeXl),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm + 4),
                if (state is TemplatesLoading)
                  const Center(child: AppLoadingWidget())
                else if (state is TemplatesError)
                  Center(
                      child: Text(state.message,
                          style: TextStyle(color: context.danger)))
                else if (filteredTemplates.isNotEmpty)
                  BlocBuilder<PrescriptionBloc, PrescriptionState>(
                    builder: (context, presState) {
                      final appliedIds = presState.appliedTemplateIds;

                      return Wrap(
                        spacing: AppConstants.spaceSm,
                        runSpacing: AppConstants.spaceSm,
                        children: filteredTemplates.map((t) {
                          final String id = t['id'] ?? '';
                          final String name = t['name'] ?? '';
                          final isApplied = appliedIds.contains(id);

                          return FilterChip(
                            selected: isApplied,
                            avatar: Icon(
                              isApplied ? Icons.check_circle : Icons.bolt,
                              size: AppConstants.iconSizeSm,
                              color: isApplied ? context.primary : context.textSecondary,
                            ),
                            label: Text(
                              name,
                              style: AppTextStyles.labelChip(context).copyWith(
                                color: isApplied ? context.primary : context.textSecondary,
                                fontWeight: isApplied ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            selectedColor: context.primaryLightColor,
                            backgroundColor: context.surface,
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isApplied ? context.primary : context.border,
                                width: 1,
                              ),
                            ),
                            onSelected: (selected) {
                              if (!isApplied) {
                                context
                                    .read<PrescriptionBloc>()
                                    .add(ApplyTemplateEvent(id));

                                AppSnackbar.success(
                                  context,
                                  message: '${AppStrings.template} $name ✓',
                                );
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
                    child: Text(
                      AppStrings.noTemplates,
                      style: AppTextStyles.caption(context)
                          .copyWith(color: context.textSecondary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddTemplateSheet(
      BuildContext context, TemplatesCubit templatesCubit) {
    AppBottomSheet.show(
      context: context,
      child: AddEditTemplateSheet(
        onSave: (name, drugs) {
          templatesCubit.addTemplate(name, drugs);

          AppSnackbar.success(
            context,
            message: '${AppStrings.add} ${AppStrings.template}',
          );
        },
      ),
    );
  }
}
