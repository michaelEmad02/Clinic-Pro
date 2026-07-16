import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../manager/prescription_bloc.dart';
import '../../manager/prescription_event.dart';
import '../../manager/templates_cubit.dart';
import '../../manager/templates_state.dart';
import 'add_edit_template_sheet.dart';

// ────────────────────────────────────────────────────────
// قسم اختيار قوالب الروشتات الشائعة
// يستخدم TemplatesCubit لجلب البيانات بدلاً من MockData
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

          // ترتيب القوالب حسب الأكثر استخداماً
          filteredTemplates.sort((a, b) {
            final aUse =
                a['user_count'] as int? ?? 0; // DB schema uses user_count
            final bUse = b['user_count'] as int? ?? 0;
            return bUse.compareTo(aUse);
          });

          // تصفية القوالب بناءً على البحث
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            filteredTemplates = filteredTemplates.where((t) {
              final name = (t['name'] as String? ?? '').toLowerCase();
              return name.contains(query);
            }).toList();
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان القسم وزر الإضافة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description_outlined,
                            color: context.primary),
                        const SizedBox(width: 8),
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
                      icon: Icon(Icons.add_circle_outline,
                          color: context.primary),
                      tooltip: AppStrings.addTemplate,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // حقل البحث
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
                        Icon(Icons.search, color: context.textHint, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: context.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: context.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),

                if (state is TemplatesLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state is TemplatesError)
                  Center(
                      child: Text(state.message,
                          style: TextStyle(color: context.danger)))
                else if (filteredTemplates.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filteredTemplates.map((t) {
                      final String name = t['name'] ?? '';
                      // final int useCount = t['user_count'] ?? 0;

                      return ActionChip(
                        avatar:
                            Icon(Icons.bolt, size: 14, color: context.primary),
                        label: Text(
                          name,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: context.primaryLightColor,
                        side:
                            BorderSide(color: context.primary.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onPressed: () {
                          // تطبيق القالب وإضافة أدويته للروشتة
                          context
                              .read<PrescriptionBloc>()
                              .add(ApplyTemplateEvent(t['id']));

                          // TODO: call API to increase user_count in DB if needed.

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${AppStrings.template} $name ✓'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddEditTemplateSheet(
            onSave: (name, drugs) {
              templatesCubit.addTemplate(name, drugs);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppStrings.add} ${AppStrings.template}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
