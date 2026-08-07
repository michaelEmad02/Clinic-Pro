// ────────────────────────────────────────────────────────
// شاشة قاعدة بيانات الأدوية — تصفح، فلترة، إضافة وتعديل (Responsive)
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
import '../manager/drugs_cubit.dart';
import '../manager/drugs_state.dart';
import 'widgets/add_edit_drug_sheet.dart';
import 'widgets/drug_action_sheet.dart';
import 'widgets/drugs_category_chips.dart';
import 'widgets/drugs_list.dart';
import 'widgets/drugs_search_bar.dart';

class DrugsScreen extends StatelessWidget {
  const DrugsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DrugsCubit>()..loadDrugs(),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          toolbarHeight: 64,
          backgroundColor: context.surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            AppStrings.drugBase,
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
        body: BlocBuilder<DrugsCubit, DrugsState>(
          builder: (context, state) {
            if (state is DrugsLoading) {
              return ResponsiveHelper.responsiveCenter(
                maxWidth: AppConstants.maxContentWidth,
                child: const Padding(
                  padding: EdgeInsets.all(AppConstants.spaceMd),
                  child: ShimmerList(itemCount: 6),
                ),
              );
            }

            if (state is DrugsError) {
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
                      onPressed: () => context.read<DrugsCubit>().loadDrugs(),
                      child: Text(AppStrings.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is DrugsLoaded) {
              return RefreshIndicator(
                onRefresh: () => context.read<DrugsCubit>().loadDrugs(),
                child: ResponsiveHelper.responsiveCenter(
                  maxWidth: AppConstants.maxContentWidth,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
                    children: [
                      DrugsSearchBar(
                        onChanged: (q) => context.read<DrugsCubit>().search(q),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      DrugsCategoryChips(
                        selectedCategory: state.selectedCategory,
                        categories: state.drugs
                            .map((d) => d['category'] as String?)
                            .where((c) => c != null && c.isNotEmpty)
                            .cast<String>()
                            .toSet()
                            .toList(),
                        onCategorySelected: (cat) =>
                            context.read<DrugsCubit>().selectCategory(cat),
                      ),
                      const SizedBox(height: AppConstants.spaceSm + 4),
                      DrugsList(
                        drugs: state.drugs,
                        searchQuery: state.searchQuery,
                        selectedCategory: state.selectedCategory,
                        onDrugAction: (drug) => _showDrugActions(context, drug),
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
              onPressed: () => _showAddDrugSheet(context),
              backgroundColor: context.primary,
              child: Icon(Icons.add, color: context.onPrimary),
            );
          },
        ),
      ),
    );
  }

  void _showAddDrugSheet(BuildContext context) {
    final drugsCubit = context.read<DrugsCubit>();
    AppBottomSheet.show(
      context: context,
      child: AddEditDrugSheet(
        onSave: ({
          required String tradeName,
          required String genericName,
          required String category,
        }) {
          drugsCubit.addDrug(
            tradeName: tradeName,
            genericName: genericName,
            category: category,
          );
        },
      ),
    );
  }

  void _showDrugActions(BuildContext context, Map<String, dynamic> drug) {
    final drugsCubit = context.read<DrugsCubit>();
    DrugActionSheet.show(
      context: context,
      drug: drug,
      onEdit: () {
        AppBottomSheet.show(
          context: context,
          child: AddEditDrugSheet(
            drug: drug,
            onSave: ({
              required String tradeName,
              required String genericName,
              required String category,
            }) {
              drugsCubit.updateDrug(
                id: drug['id'],
                tradeName: tradeName,
                genericName: genericName,
                category: category,
              );
            },
          ),
        );
      },
      onDelete: () {
        drugsCubit.deleteDrug(drug['id']);
      },
    );
  }
}
