// ────────────────────────────────────────────────────────
// شاشة قاعدة بيانات الأدوية — تصفح، فلترة، إضافة وتعديل
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
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
      create: (context) => DrugsCubit()..loadDrugs(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: 64,
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'قاعدة الأدوية',
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
        body: BlocBuilder<DrugsCubit, DrugsState>(
          builder: (context, state) {
            if (state is DrugsLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: ShimmerList(),
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
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<DrugsCubit>().loadDrugs(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is DrugsLoaded) {
              return RefreshIndicator(
                onRefresh: () => context.read<DrugsCubit>().loadDrugs(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 8),
                    DrugsSearchBar(
                      onChanged: (q) => context.read<DrugsCubit>().search(q),
                    ),
                    const SizedBox(height: 8),
                    DrugsCategoryChips(
                      selectedCategory: state.selectedCategory,
                      onCategorySelected: (cat) => context.read<DrugsCubit>().selectCategory(cat),
                    ),
                    const SizedBox(height: 12),
                    DrugsList(
                      drugs: state.drugs,
                      searchQuery: state.searchQuery,
                      selectedCategory: state.selectedCategory,
                      onDrugAction: (drug) => _showDrugActions(context, drug),
                    ),
                    const SizedBox(height: 80), // مسافة إضافية للـ FAB
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
              onPressed: () => _showAddDrugSheet(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  void _showAddDrugSheet(BuildContext context) {
    final drugsCubit = context.read<DrugsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddEditDrugSheet(
            onSave: ({
              required String tradeName,
              required String genericName,
              required String category,
              required String form,
              required int stockCount,
            }) {
              drugsCubit.addDrug(
                tradeName: tradeName,
                genericName: genericName,
                category: category,
                form: form,
                stockCount: stockCount,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDrugActions(BuildContext context, Map<String, dynamic> drug) {
    final drugsCubit = context.read<DrugsCubit>();
    DrugActionSheet.show(
      context: context,
      drug: drug,
      onEdit: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddEditDrugSheet(
                drug: drug,
                onSave: ({
                  required String tradeName,
                  required String genericName,
                  required String category,
                  required String form,
                  required int stockCount,
                }) {
                  drugsCubit.updateDrug(
                    id: drug['id'],
                    tradeName: tradeName,
                    genericName: genericName,
                    category: category,
                    form: form,
                    stockCount: stockCount,
                  );
                },
              ),
            ),
          ),
        );
      },
      onDelete: () {
        drugsCubit.deleteDrug(drug['id']);
      },
    );
  }
}
