import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/constants/prescription_enums.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/drugs_cubit.dart';
import '../../manager/drugs_state.dart';
import 'template_drug_search_field.dart';
import 'template_drug_edit_card.dart';

class AddEditTemplateSheet extends StatefulWidget {
  final Map<String, dynamic>? template;
  final Function(String name, List<Map<String, dynamic>> drugs) onSave;

  const AddEditTemplateSheet({super.key, required this.onSave, this.template});

  @override
  State<AddEditTemplateSheet> createState() => _AddEditTemplateSheetState();
}

class _AddEditTemplateSheetState extends State<AddEditTemplateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  final List<Map<String, dynamic>> _addedDrugs = [];
  String _searchQuery = '';
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _showDropdown = _searchFocusNode.hasFocus;
      });
    });

    if (widget.template != null) {
      _nameController.text = widget.template!['name'] ?? '';

      final items =
          widget.template!['items'] as List<Map<String, dynamic>>? ?? [];
      for (final item in items) {
        _addedDrugs.add({
          'drug_id': item['drug_id'],
          'trade_name': item['trade_name'] ?? AppStrings.unknownDrug,
          'generic_name': item['generic_name'] ?? '',
          'frequency': item['frequency'],
          'duration': item['duration'],
          'timing': item['timing'] ?? 'after_meal',
          'is_prn': item['is_prn'] ?? false,
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DrugsCubit>()..loadDrugs(),
      child: BlocBuilder<DrugsCubit, DrugsState>(
        builder: (context, drugsState) {
          final allDrugs = drugsState is DrugsLoaded
              ? drugsState.drugs
              : <Map<String, dynamic>>[];

          final filteredDrugs = <Map<String, dynamic>>[];
          final query = _searchQuery.trim().toLowerCase();

          for (final drug in allDrugs) {
            final trade = (drug['trade_name'] as String? ?? '').toLowerCase();
            final generic =
                (drug['generic_name'] as String? ?? '').toLowerCase();
            final id = drug['id'] as String;

            final alreadyAdded = _addedDrugs.any((d) => d['drug_id'] == id);

            if (!alreadyAdded) {
              if (query.isEmpty ||
                  trade.contains(query) ||
                  generic.contains(query)) {
                filteredDrugs.add(drug);
              }
            }
          }

          return Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: context.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.template != null
                            ? AppStrings.editTemplate
                            : AppStrings.addTemplate,
                        style: AppTextStyles.headlineMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: context.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.templateName,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: AppTextStyles.bodyMedium(context),
                    decoration: InputDecoration(
                      hintText: AppStrings.templateName,
                      hintStyle: AppTextStyles.bodyMedium(context)
                          .copyWith(color: context.textHint),
                      filled: true,
                      fillColor: context.surface,
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? AppStrings.templateName
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.templateCategory,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _categoryController,
                    style: AppTextStyles.bodyMedium(context),
                    decoration: InputDecoration(
                      hintText: AppStrings.templateCategory,
                      hintStyle: AppTextStyles.bodyMedium(context)
                          .copyWith(color: context.textHint),
                      filled: true,
                      fillColor: context.surface,
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TemplateDrugSearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSearchChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    filteredDrugs: filteredDrugs,
                    showDropdown: _showDropdown,
                    onDrugSelected: (drug) {
                      setState(() {
                        _addedDrugs.add({
                          'drug_id': drug['id'],
                          'trade_name': drug['trade_name'],
                          'form': drug['form'] ?? AppStrings.dosage,
                          'generic_name': drug['generic_name'] ?? '',
                          'frequency': DrugFrequency.thrice.dbValue,
                          'duration': DrugDuration.threeDays.dbValue,
                          'timing': DrugTiming.afterMeal.dbValue,
                          'is_prn': false,
                        });
                        _searchQuery = '';
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                        _showDropdown = false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_addedDrugs.isNotEmpty) ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _addedDrugs.length,
                      itemBuilder: (context, index) {
                        return TemplateDrugEditCard(
                          drug: _addedDrugs[index],
                          index: index,
                          onChanged: () => setState(() {}),
                          onDelete: () {
                            setState(() {
                              _addedDrugs.removeAt(index);
                            });
                          },
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_addedDrugs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${AppStrings.add} ${AppStrings.drug}'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: context.danger,
                            ),
                          );
                          return;
                        }
                        widget.onSave(
                          _nameController.text,
                          _addedDrugs,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      AppStrings.save,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
