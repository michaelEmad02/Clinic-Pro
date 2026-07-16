import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/expenses_cubit.dart';
import '../../manager/expenses_state.dart';

class AddEditExpenseSheet {
  static Future<void> show(
    BuildContext context, {
    ExpenseItem? expense,
    required List<ExpenseCategory> categories,
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
  final ExpenseItem? expense;
  final List<ExpenseCategory> categories;

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
  late String _categoryLabel;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController =
        TextEditingController(text: widget.expense?.amount.toString() ?? '');
    _notesController = TextEditingController(text: widget.expense?.notes ?? '');
    _categoryId = widget.expense?.categoryId ?? widget.categories.first.id;
    _categoryLabel =
        widget.expense?.categoryLabel ?? widget.categories.first.name;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عنوان المصروف')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المبلغ يجب أن يكون أكبر من 0')),
      );
      return;
    }

    final cubit = context.read<ExpensesCubit>();

    if (isEditing) {
      await cubit.updateExpense(
        expenseId: widget.expense!.id,
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _categoryId,
        categoryLabel: _categoryLabel,
        notes: _notesController.text.trim(),
      );
    } else {
      await cubit.addExpense(
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _categoryId,
        categoryLabel: _categoryLabel,
        notes: _notesController.text.trim(),
      );
    }

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.operationSuccessful),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      border: Border.all(color: context.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categoryId,
                        isExpanded: true,
                        icon: Icon(Icons.expand_more,
                            color: context.textSecondary, size: 20),
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
                            _categoryLabel = cat.name;
                          });
                        },
                      ),
                    ),
                  ),
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
                          color: context.textHint),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 56, minHeight: 0),
                      fillColor: context.surface,
                      filled: true,
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
                        horizontal: 12,
                        vertical: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(AppStrings.date),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formattedDate(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        Icon(Icons.calendar_today,
                            size: 20, color: context.textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(AppStrings.notes),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: _inputDecoration('أضف تفاصيل إضافية هنا...'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save, size: 20),
                      label: Text(
                        isEditing ? AppStrings.save : AppStrings.save,
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
      fillColor: context.surface,
      filled: true,
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
        horizontal: AppConstants.spaceMd,
        vertical: 13,
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    final months = AppStrings.fullMonths;
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
