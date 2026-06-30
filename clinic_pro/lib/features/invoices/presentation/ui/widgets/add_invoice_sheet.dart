import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/invoices_cubit.dart';

class AddInvoiceSheet {
  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      child: const _AddInvoiceForm(),
    );
  }
}

class _AddInvoiceForm extends StatefulWidget {
  const _AddInvoiceForm();

  @override
  State<_AddInvoiceForm> createState() => _AddInvoiceFormState();
}

class _AddInvoiceFormState extends State<_AddInvoiceForm> {
  final _patientSearchController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _patientFocusNode = FocusNode();

  String? _selectedPatientId;
  String? _selectedPatientName;
  String? _selectedPatientPhone;
  String? _selectedAppointmentType;
  String? _selectedAppointmentId;
  String _paymentMethod = 'cash';

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _patientAppointments = [];
  bool _showPatientSearch = true;
  double _expectedPrice = 0;

  static const _paymentMethods = [
    ('cash', 'نقد'),
    ('card', 'بطاقة'),
    ('bank', 'تحويل'),
  ];

  @override
  void initState() {
    super.initState();
    _patientFocusNode.addListener(() {
      if (_patientFocusNode.hasFocus && _showPatientSearch) {
        _searchPatients(_patientSearchController.text);
      }
    });
  }

  @override
  void dispose() {
    _patientSearchController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _patientFocusNode.dispose();
    super.dispose();
  }

  void _searchPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = List.from(MockData.patients);
      } else {
        final q = query.trim();
        _searchResults = MockData.patients
            .where((p) =>
                (p['name'] as String).contains(q) ||
                (p['phone'] as String).contains(q))
            .toList();
      }
    });
  }

  void _selectPatient(Map<String, dynamic> patient) {
    final patientId = patient['id'] as String;

    final invoicedSourceIds = MockData.invoices
        .map((inv) => inv['source_id'] as String)
        .toSet();

    final appointments = MockData.appointments.where((a) =>
        a['patient_id'] == patientId &&
        a['status'] == 'done' &&
        !invoicedSourceIds.contains(a['id'])).toList();

    setState(() {
      _selectedPatientId = patientId;
      _selectedPatientName = patient['name'] as String;
      _selectedPatientPhone = patient['phone'] as String;
      _showPatientSearch = false;
      _patientSearchController.text = patient['name'] as String;
      _searchResults = [];
      _patientAppointments = appointments;
      _expectedPrice = 0;
      _selectedAppointmentType = null;
      _selectedAppointmentId = null;
      _totalAmountController.clear();
      _paidAmountController.clear();
    });
  }

  void _selectAppointment(Map<String, dynamic> appointment) {
    final typeName = appointment['appointment_types']['name'] as String;
    final price = (appointment['appointment_types']['price'] as num).toDouble();

    setState(() {
      _selectedAppointmentType = typeName;
      _selectedAppointmentId = appointment['id'] as String;
      _totalAmountController.text = price.toStringAsFixed(0);
      _expectedPrice = price;
    });
  }

  String _getDoctorName(String doctorId) {
    for (final user in MockData.users) {
      if (user['id'] == doctorId) return user['name'] as String? ?? 'طبيب';
    }
    return 'طبيب';
  }

  Future<void> _submit() async {
    if (_selectedPatientId == null ||
        _totalAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;

    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المبلغ الإجمالي يجب أن يكون أكبر من 0')),
      );
      return;
    }

    await context.read<InvoicesCubit>().createInvoice(
          patientId: _selectedPatientId!,
          patientName: _selectedPatientName!,
          appointmentType: _selectedAppointmentType ?? 'كشف عادي',
          sourceId: _selectedAppointmentId ?? 'manual-${DateTime.now().millisecondsSinceEpoch}',
          totalAmount: totalAmount,
          paidAmount: paidAmount,
          paymentMethod: _paymentMethod,
        );

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الفاتورة بنجاح')),
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
                  'تسجيل فاتورة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showPatientSearch) ...[
                    Text(
                      'المريض',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _patientSearchController,
                      focusNode: _patientFocusNode,
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم المريض أو رقمه',
                        prefixIcon:
                            const Icon(Icons.search, size: 20, color: AppColors.textHint),
                        fillColor: AppColors.surfaceBright,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceMd,
                          vertical: 13,
                        ),
                      ),
                      onChanged: _searchPatients,
                    ),
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: _searchResults.map((p) {
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  (p['name'] as String).substring(0, 1),
                                  style: const TextStyle(
                                      color: AppColors.primary, fontSize: 12),
                                ),
                              ),
                              title: Text(
                                p['name'] as String,
                                style: AppTextStyles.bodyMedium(context),
                              ),
                              subtitle: Text(
                                p['phone'] as String,
                                style: AppTextStyles.caption(context),
                              ),
                              onTap: () => _selectPatient(p),
                            );
                          }).toList(),
                        ),
                      ),
                  ] else ...[
                    Text(
                      'المريض',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: Text(
                              _selectedPatientName!.substring(0, 1),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPatientName!,
                                  style: AppTextStyles.bodyMedium(context)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  _selectedPatientPhone ?? '',
                                  style: AppTextStyles.caption(context)
                                      .copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPatientId = null;
                                _selectedPatientName = null;
                                _selectedPatientPhone = null;
                                _showPatientSearch = true;
                                _patientSearchController.clear();
                                _expectedPrice = 0;
                              });
                            },
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'الموعد',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedAppointmentId,
                        hint: Text(
                          _patientAppointments.isEmpty
                              ? 'لا توجد مواعيد منتهية'
                              : 'اختر الموعد',
                          style: AppTextStyles.bodyMedium(context)
                              .copyWith(color: AppColors.textHint),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.textHint, size: 20),
                        items: _patientAppointments.map((a) {
                          final typeName = a['appointment_types']['name'] as String;
                          final date = a['date'] as String;
                          final time = (a['time'] as String).substring(0, 5);
                          final doctorId = a['doctor_id'] as String;
                          final doctorName = _getDoctorName(doctorId);
                          final dateTime = DateTime.tryParse(date);
                          String displayDate = date;
                          if (dateTime != null) {
                            const months = [
                              'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                              'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
                            ];
                            displayDate = '${dateTime.day} ${months[dateTime.month - 1]}';
                          }
                          final label = '$typeName • $displayDate • $time';
                          return DropdownMenuItem(
                            value: a['id'] as String,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label,
                                    style: AppTextStyles.bodyMedium(context)
                                        .copyWith(fontWeight: FontWeight.bold)),
                                Text(doctorName,
                                    style: AppTextStyles.caption(context)
                                        .copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _patientAppointments.isEmpty
                            ? null
                            : (v) {
                                final appointment = _patientAppointments
                                    .firstWhere((a) => a['id'] == v);
                                _selectAppointment(appointment);
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _patientAppointments.isEmpty
                            ? 'لا توجد مواعيد منتهية لهذا المريض'
                            : 'يظهر فقط المواعيد المنتهية',
                        style: AppTextStyles.caption(context)
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المبلغ الإجمالي',
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _totalAmountController,
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                ),
                                suffixIcon: const SizedBox(
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'ج.م',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                fillColor: AppColors.surfaceContainerLow,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spaceMd,
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المبلغ المدفوع',
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _paidAmountController,
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                ),
                                suffixIcon: const SizedBox(
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'ج.م',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                fillColor: AppColors.surfaceContainerLow,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spaceMd,
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_expectedPrice > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.warningText.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.lightbulb_outline,
                                size: 18, color: AppColors.warningText),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'السعر المتوقع: $_expectedPrice ج.م',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warningText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'طريقة الدفع',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _paymentMethods.map((m) {
                      final isSelected = _paymentMethod == m.$1;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                m.$2 == 'نقد'
                                    ? '💵'
                                    : m.$2 == 'بطاقة'
                                        ? '💳'
                                        : '🔄',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(m.$2),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _paymentMethod = m.$1),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      child: Text(
                        'حفظ الفاتورة',
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
}