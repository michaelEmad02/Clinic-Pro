import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../manager/drugs_cubit.dart';
import '../../manager/drugs_state.dart';

// ────────────────────────────────────────────────────────
// شاشة البحث عن الأدوية وإضافتها للروشتة (BottomSheet)
// تستخدم DrugsCubit بدلاً من الـ MockData و setState
// ────────────────────────────────────────────────────────

class AddDrugSearchSheet extends StatelessWidget {
  final Function(Map<String, dynamic> drug) onDrugSelected;

  const AddDrugSearchSheet({super.key, required this.onDrugSelected});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DrugsCubit>()..loadDrugs(),
      child: BlocBuilder<DrugsCubit, DrugsState>(
        builder: (context, state) {
          if (state is DrugsLoading) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is DrugsError) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            );
          }

          final drugs = state is DrugsLoaded ? state.drugs : [];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // مقبض السحب
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إضافة دواء للوصفة',
                      style: AppTextStyles.headlineMedium(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // حقل البحث
                TextField(
                  onChanged: (val) {
                    context.read<DrugsCubit>().search(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'ابحث عن دواء باسمه العلمي أو التجاري...',
                    hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // قائمة الأدوية المصفاة
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: drugs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('لا توجد أدوية مطابقة للبحث')),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: drugs.length,
                          itemBuilder: (context, index) {
                            final drug = drugs[index];
                            return ListTile(
                              leading: const Icon(Icons.medication, color: AppColors.primary),
                              title: Text(
                                drug['trade_name'] ?? '',
                                style: AppTextStyles.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                drug['generic_name'] ?? '',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  onDrugSelected(drug);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('إضافة'),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
