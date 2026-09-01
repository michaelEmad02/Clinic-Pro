import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_bottom_sheet.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:clinic_pro/features/expenses/presentation/manager/expenses_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditExpenseSheet {
  static Future<void> show(
    BuildContext context, {
    ExpensesEntity? expense,
    required List<ExpenseCategoryEntity> categories,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: context.read<ExpensesCubit>(),
        child: _AddEditExpenseForm(
          expense: expense,
          categories: categories,
        ),
      ),
    );
  }
}

class _AddEditExpenseForm extends StatefulWidget {
  final ExpensesEntity? expense;
  final List<ExpenseCategoryEntity> categories;

  const _AddEditExpenseForm({
    this.expense,
    required this.categories,
  });

  @override
  State<_AddEditExpenseForm> createState() => _AddEditExpenseFormState();
}

class _AddEditExpenseFormState extends State<_AddEditExpenseForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late String _categoryId;
  late String _categoryName;
  late String _targetType; // 'clinic' | 'doctor'
  String? _selectedDoctorId;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.expense != null ? widget.expense!.amount.toString() : '',
    );
    _notesController = TextEditingController(text: widget.expense?.notes ?? '');

    final hasCategories = widget.categories.isNotEmpty;
    _categoryId = widget.expense?.categoryId ??
        (hasCategories ? widget.categories.first.id : '');
    _categoryName = widget.expense?.categoryName ??
        (hasCategories ? widget.categories.first.name : '');

    final expDocId = widget.expense?.doctorId;
    if (expDocId != null && expDocId.isNotEmpty) {
      _targetType = 'doctor';
      _selectedDoctorId = expDocId;
    } else {
      _targetType = 'clinic';
      _selectedDoctorId = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getAvailableDoctors() {
    final settingsState = context.read<SettingsCubit>().state;
    final List<Map<String, String>> doctorsList = [];

    if (settingsState.secretaryDoctors.isNotEmpty) {
      for (final doc in settingsState.secretaryDoctors) {
        final id = doc['doctor_id'] as String? ?? doc['id'] as String? ?? '';
        final name = doc['name'] as String? ?? '';
        if (id.isNotEmpty) {
          doctorsList.add({'id': id, 'name': name.isNotEmpty ? name : (AppStrings.isArabic ? 'طبيب' : 'Doctor')});
        }
      }
    }

    if (doctorsList.isEmpty && settingsState.staffList.isNotEmpty) {
      for (final staff in settingsState.staffList) {
        if (staff.role == StaffRoles.doctor && staff.userId.isNotEmpty) {
          doctorsList.add({'id': staff.userId, 'name': staff.name});
        }
      }
    }

    if (doctorsList.isEmpty && settingsState.doctorEntity != null) {
      final doc = settingsState.doctorEntity!;
      final id = doc.userId.isNotEmpty ? doc.userId : doc.id;
      if (id.isNotEmpty) {
        doctorsList.add({'id': id, 'name': doc.name});
      }
    }

    if (doctorsList.isEmpty && (settingsState.currentDoctorId?.isNotEmpty ?? false)) {
      doctorsList.add({
        'id': settingsState.currentDoctorId!,
        'name': settingsState.currentDoctorName ?? (AppStrings.isArabic ? 'طبيب العيادة' : 'Clinic Doctor'),
      });
    }

    return doctorsList;
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppSnackbar.info(context, message: AppStrings.enterExpenseTitle);
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      AppSnackbar.info(context, message: AppStrings.amountMustBeGreaterThanZero);
      return;
    }

    if (_categoryId.isEmpty) {
      AppSnackbar.info(context, message: AppStrings.chooseCategory);
      return;
    }

    final cubit = context.read<ExpensesCubit>();
    final authUser = context.read<AuthCubit>().state.user;
    final clinicId = context.read<SettingsCubit>().state.clinicEntity?.id ??
        AppConstants.activeClinicId;
    final currentUserId = authUser?.id ?? '';
    final isDoctor = authUser?.role == StaffRoles.doctor;

    String? assignedDoctorId;
    if (isDoctor) {
      assignedDoctorId = currentUserId;
    } else {
      if (_targetType == 'doctor') {
        if (_selectedDoctorId == null || _selectedDoctorId!.isEmpty) {
          AppSnackbar.info(context, message: AppStrings.isArabic ? 'يرجى اختيار الطبيب' : 'Please select a doctor');
          return;
        }
        assignedDoctorId = _selectedDoctorId;
      } else {
        assignedDoctorId = null;
      }
    }

    bool success = false;

    if (isEditing) {
      final updated = widget.expense!.copyWith(
        title: title,
        amount: amount,
        categoryId: _categoryId,
        categoryName: _categoryName,
        notes: _notesController.text.trim(),
        doctorId: assignedDoctorId,
      );
      success = await cubit.updateExpense(updated);
    } else {
      success = await cubit.addExpense(
        clinicId: clinicId,
        title: title,
        amount: amount,
        categoryId: _categoryId,
        categoryName: _categoryName,
        notes: _notesController.text.trim(),
        doctorId: assignedDoctorId,
        createdBy: currentUserId,
      );
    }

    if (mounted && success) {
      Navigator.pop(context);
      AppSnackbar.success(context, message: AppStrings.operationSuccessful);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthCubit>().state.user;
    final isDoctor = authUser?.role == StaffRoles.doctor;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  isEditing ? AppStrings.editExpense : AppStrings.addExpense,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: Icon(Icons.close, color: context.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          const SizedBox(height: 4),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabel(AppStrings.expenseName),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    decoration: _inputDecoration(AppStrings.expenseName),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(AppStrings.expenseCategory),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categoryId.isEmpty ? null : _categoryId,
                        isExpanded: true,
                        icon: Icon(Icons.expand_more,
                            color: context.textSecondary, size: 20),
                        hint: Text(
                          widget.categories.isEmpty
                              ? AppStrings.noCategories
                              : AppStrings.chooseCategory,
                          style: AppTextStyles.bodyMedium(context),
                        ),
                        items: widget.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          final cat =
                              widget.categories.firstWhere((c) => c.id == v);
                          setState(() {
                            _categoryId = v;
                            _categoryName = cat.name;
                          });
                        },
                      ),
                    ),
                  ),
                  if (!isDoctor) ...[
                    const SizedBox(height: 16),
                    _buildLabel(AppStrings.isArabic ? 'الجهة المتحملة للمصروف' : 'Responsible Party'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _targetType = 'clinic';
                                _selectedDoctorId = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _targetType == 'clinic'
                                    ? context.primary.withOpacity(0.1)
                                    : context.surfaceColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _targetType == 'clinic'
                                      ? context.primary
                                      : context.borderColor,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_hospital_outlined,
                                    size: 18,
                                    color: _targetType == 'clinic'
                                        ? context.primary
                                        : context.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.isArabic ? 'العيادة (عام)' : 'Clinic (General)',
                                    style: AppTextStyles.bodyMedium(context).copyWith(
                                      fontWeight: _targetType == 'clinic'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _targetType == 'clinic'
                                          ? context.primary
                                          : context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              final docs = _getAvailableDoctors();
                              setState(() {
                                _targetType = 'doctor';
                                if (_selectedDoctorId == null && docs.isNotEmpty) {
                                  _selectedDoctorId = docs.first['id'];
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _targetType == 'doctor'
                                    ? context.primary.withOpacity(0.1)
                                    : context.surfaceColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _targetType == 'doctor'
                                      ? context.primary
                                      : context.borderColor,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 18,
                                    color: _targetType == 'doctor'
                                        ? context.primary
                                        : context.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.isArabic ? 'طبيب معين' : 'Specific Doctor',
                                    style: AppTextStyles.bodyMedium(context).copyWith(
                                      fontWeight: _targetType == 'doctor'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _targetType == 'doctor'
                                          ? context.primary
                                          : context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_targetType == 'doctor') ...[
                      const SizedBox(height: 12),
                      _buildLabel(AppStrings.isArabic ? 'اختر الطبيب' : 'Select Doctor'),
                      const SizedBox(height: 6),
                      Builder(builder: (context) {
                        final docs = _getAvailableDoctors();
                        final currentVal = docs.any((d) => d['id'] == _selectedDoctorId)
                            ? _selectedDoctorId
                            : (docs.isNotEmpty ? docs.first['id'] : null);
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: context.borderColor),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: currentVal,
                              isExpanded: true,
                              icon: Icon(Icons.expand_more,
                                  color: context.textSecondary, size: 20),
                              hint: Text(
                                docs.isEmpty
                                    ? (AppStrings.isArabic ? 'لا يوجد أطباء متاحيين' : 'No doctors available')
                                    : (AppStrings.isArabic ? 'اختر الطبيب' : 'Select Doctor'),
                                style: AppTextStyles.bodyMedium(context),
                              ),
                              items: docs.map((doc) {
                                return DropdownMenuItem<String>(
                                  value: doc['id'],
                                  child: Text(doc['name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _selectedDoctorId = v;
                                });
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                  const SizedBox(height: 16),
                  _buildLabel(AppStrings.amount),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: context.textHint,
                      ),
                      fillColor: context.surfaceColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  const SizedBox(height: 16),
                  _buildLabel(AppStrings.notes),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                        AppStrings.addAdditionalDetailsHint),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save_outlined, size: 20),
                      label: Text(
                        AppStrings.save,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: context.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium(context).copyWith(
        fontWeight: FontWeight.bold,
        color: context.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          AppTextStyles.bodyMedium(context).copyWith(color: context.textHint),
      fillColor: context.surfaceColor,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: 13,
      ),
    );
  }
}
