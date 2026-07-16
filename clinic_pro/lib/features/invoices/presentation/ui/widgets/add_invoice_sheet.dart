// ────────────────────────────────────────────────────────
// Bottom Sheet تسجيل فاتورة جديدة — مطابق لتصميم Stitch وبدون MockData مباشرة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../../core/di/injection_container.dart';
import '../../manager/invoices_cubit.dart';
import '../../manager/invoices_state.dart';

class AddInvoiceSheet {
  static Future<void> show(BuildContext context,
      {String? initialAppointmentId, InvoiceItem? invoice}) {
    // التقاط الـ Cubit الحالي من السياق أو إنشاء واحد جديد
    InvoicesCubit cubit;
    try {
      cubit = context.read<InvoicesCubit>();
    } catch (_) {
      cubit = sl<InvoicesCubit>()..loadInvoices();
    }

    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: _AddInvoiceForm(
          initialAppointmentId: initialAppointmentId,
          invoice: invoice,
        ),
      ),
    );
  }
}

class _AddInvoiceForm extends StatefulWidget {
  final String? initialAppointmentId;
  final InvoiceItem? invoice;
  const _AddInvoiceForm({this.initialAppointmentId, this.invoice});

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
  bool _isLoading = false;

  List<(String, String)> get _paymentMethods => [
        ('cash', AppStrings.isArabic ? 'نقد' : 'Cash'),
        ('card', AppStrings.isArabic ? 'بطاقة' : 'Card'),
        ('bank', AppStrings.isArabic ? 'تحويل' : 'Transfer'),
      ];

  @override
  void initState() {
    super.initState();
    _patientFocusNode.addListener(() {
      if (_patientFocusNode.hasFocus && _showPatientSearch) {
        _searchPatients(_patientSearchController.text);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cubit = context.read<InvoicesCubit>();

      if (widget.invoice != null) {
        setState(() => _isLoading = true);
        final inv = widget.invoice!;
        final patient = await cubit.getPatientDetails(inv.patientId);
        final appt = await cubit.getAppointmentDetails(inv.sourceId);

        if (patient != null) {
          await _selectPatient(patient);
          if (appt != null) {
            _selectAppointment(appt);
          }
          setState(() {
            _totalAmountController.text = inv.totalAmount.toStringAsFixed(0);
            _paidAmountController.text = inv.paidAmount.toStringAsFixed(0);
            _paymentMethod = inv.paymentMethod ?? 'cash';
          });
        }
        setState(() => _isLoading = false);
        return;
      }

      if (widget.initialAppointmentId != null) {
        setState(() => _isLoading = true);

        // جلب تفاصيل الموعد والمريض عبر الـ Cubit
        final appt =
            await cubit.getAppointmentDetails(widget.initialAppointmentId!);
        if (appt != null) {
          final patientId = appt['patient_id'] as String;
          final patient = await cubit.getPatientDetails(patientId);

          if (patient != null) {
            await _selectPatient(patient);
            _selectAppointment(appt);

            // التحقق من وجود فاتورة سابقة للموعد المحدد
            if (cubit.state is InvoicesLoaded) {
              final state = cubit.state as InvoicesLoaded;
              final existingInvoice = state.allInvoices.firstWhere(
                (inv) => inv.sourceId == widget.initialAppointmentId,
                orElse: () => const InvoiceItem(
                  id: '',
                  patientId: '',
                  patientName: '',
                  appointmentType: '',
                  sourceId: '',
                  totalAmount: 0,
                  paidAmount: 0,
                  createdAt: '',
                  createdBy: '',
                ),
              );

              if (existingInvoice.id.isNotEmpty) {
                final remaining =
                    existingInvoice.totalAmount - existingInvoice.paidAmount;
                if (remaining <= 0) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppStrings.isArabic
                              ? 'هذا الموعد مسجل له فاتورة مدفوعة بالكامل بالفعل.'
                              : 'This appointment already has a fully paid invoice.')),
                    );
                  }
                  return;
                }
                setState(() {
                  _totalAmountController.text = remaining.toStringAsFixed(0);
                  _expectedPrice = remaining;
                });
              }
            }
          }
        }
        setState(() => _isLoading = false);
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

  Future<void> _searchPatients(String query) async {
    final results = await context.read<InvoicesCubit>().searchPatients(query);
    setState(() {
      _searchResults = results;
    });
  }

  Future<void> _selectPatient(Map<String, dynamic> patient) async {
    final patientId = patient['id'] as String;

    setState(() => _isLoading = true);
    final cubit = context.read<InvoicesCubit>();

    // جلب المعرفات للمواعيد المدفوعة بالكامل
    final Set<String> fullyPaidSourceIds = {};
    if (cubit.state is InvoicesLoaded) {
      for (final inv in (cubit.state as InvoicesLoaded).allInvoices) {
        if (inv.paidAmount >= inv.totalAmount) {
          fullyPaidSourceIds.add(inv.sourceId);
        }
      }
    }

    final allAppointments = await cubit.loadPatientAppointments(patientId);
    final appointments = allAppointments.where((a) {
      final isTarget = widget.initialAppointmentId != null &&
          a['id'] == widget.initialAppointmentId;
      return isTarget || !fullyPaidSourceIds.contains(a['id']);
    }).toList();

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
      _isLoading = false;
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

  Future<void> _submit() async {
    if (_selectedPatientId == null || _totalAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppStrings.isArabic
                ? 'يرجى ملء جميع الحقول المطلوبة'
                : 'Please fill all required fields')),
      );
      return;
    }

    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;

    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppStrings.isArabic
                ? 'المبلغ الإجمالي يجب أن يكون أكبر من 0'
                : 'Total amount must be greater than 0')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final cubit = context.read<InvoicesCubit>();

    if (widget.invoice != null) {
      await cubit.updateInvoice(
        invoiceId: widget.invoice!.id,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        paymentMethod: _paymentMethod,
      );
      setState(() => _isLoading = false);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.operationSuccessful)),
        );
      }
      return;
    }

    InvoiceItem existingInvoice = const InvoiceItem(
      id: '',
      patientId: '',
      patientName: '',
      appointmentType: '',
      sourceId: '',
      totalAmount: 0,
      paidAmount: 0,
      createdAt: '',
      createdBy: '',
    );

    if (cubit.state is InvoicesLoaded) {
      existingInvoice = (cubit.state as InvoicesLoaded).allInvoices.firstWhere(
            (inv) => inv.sourceId == widget.initialAppointmentId,
            orElse: () => existingInvoice,
          );
    }

    if (existingInvoice.id.isNotEmpty) {
      final prevPaid = existingInvoice.paidAmount;
      final newPaidTotal = prevPaid + paidAmount;

      await cubit.updatePaidAmount(
        invoiceId: existingInvoice.id,
        newPaidAmount: newPaidTotal,
        paymentMethod: _paymentMethod,
      );
    } else {
      await cubit.createInvoice(
        patientId: _selectedPatientId!,
        patientName: _selectedPatientName!,
        appointmentType: _selectedAppointmentType ?? AppStrings.normalCheckup,
        sourceId: _selectedAppointmentId ??
            'manual-${DateTime.now().millisecondsSinceEpoch}',
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        paymentMethod: _paymentMethod,
      );
    }

    setState(() => _isLoading = false);

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
                  AppStrings.addInvoice,
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
          const SizedBox(height: 16),
          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_showPatientSearch) ...[
                      Text(
                        AppStrings.patient,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _patientSearchController,
                        focusNode: _patientFocusNode,
                        decoration: InputDecoration(
                          hintText: AppStrings.searchByName,
                          prefixIcon: Icon(Icons.search,
                              size: 20, color: context.textHint),
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
                        ),
                        onChanged: _searchPatients,
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.border),
                          ),
                          child: Column(
                            children: _searchResults.map((p) {
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: context.primaryLightColor,
                                  child: Text(
                                    (p['name'] as String).substring(0, 1),
                                    style: TextStyle(
                                        color: context.primary, fontSize: 12),
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
                        AppStrings.patient,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.primaryLightColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: context.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: Text(
                                _selectedPatientName!.substring(0, 1),
                                style: TextStyle(
                                  color: context.primary,
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
                                      color: context.primary,
                                    ),
                                  ),
                                  Text(
                                    _selectedPatientPhone ?? '',
                                    style:
                                        AppTextStyles.caption(context).copyWith(
                                      color: context.textSecondary,
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
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: context.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.isArabic ? 'الموعد' : 'Appointment',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAppointmentId,
                          hint: Text(
                            _patientAppointments.isEmpty
                                ? AppStrings.isArabic
                                    ? 'لا توجد مواعيد غير مدفوعة'
                                    : 'No unpaid appointments'
                                : AppStrings.isArabic
                                    ? 'اختر الموعد'
                                    : 'Select Appointment',
                            style: AppTextStyles.bodyMedium(context)
                                .copyWith(color: context.textHint),
                          ),
                          isExpanded: true,
                          icon: Icon(Icons.expand_more,
                              color: context.textHint, size: 20),
                          items: _patientAppointments.map((a) {
                            final typeName =
                                a['appointment_types']['name'] as String;
                            final date = a['date'] as String;
                            final time = (a['time'] as String).substring(0, 5);
                            final doctorName = a['doctor_name'] as String? ??
                                AppStrings.generalPractitioner;
                            final dateTime = DateTime.tryParse(date);
                            String displayDate = date;
                            if (dateTime != null) {
                              final months = AppStrings.fullMonths;
                              displayDate =
                                  '${dateTime.day} ${months[dateTime.month - 1]}';
                            }
                            final label = '$typeName • $displayDate • $time';
                            return DropdownMenuItem(
                              value: a['id'] as String,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(label,
                                      style: AppTextStyles.bodyMedium(context)
                                          .copyWith(
                                              fontWeight: FontWeight.bold)),
                                  Text(doctorName,
                                      style: AppTextStyles.caption(context)
                                          .copyWith(
                                              color: context.textSecondary)),
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
                        Icon(Icons.info_outline,
                            size: 14, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _patientAppointments.isEmpty
                              ? AppStrings.isArabic
                                  ? 'لا توجد مواعيد غير مدفوعة لهذا المريض'
                                  : 'No unpaid appointments for this patient'
                              : AppStrings.isArabic
                                  ? 'يظهر فقط المواعيد غير المدفوعة بالكامل'
                                  : 'Only showing unpaid appointments',
                          style: AppTextStyles.caption(context)
                              .copyWith(color: context.textSecondary),
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
                                AppStrings.total,
                                style:
                                    AppTextStyles.bodyMedium(context).copyWith(
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
                                  suffixIcon: SizedBox(
                                    width: 40,
                                    child: Center(
                                      child: Text(
                                        AppStrings.egp,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  fillColor: context.surface,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusInput),
                                    borderSide:
                                        BorderSide(color: context.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusInput),
                                    borderSide: BorderSide(
                                        color: context.primary, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusInput),
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
                                AppStrings.paid,
                                style:
                                    AppTextStyles.bodyMedium(context).copyWith(
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
                                  suffixIcon: SizedBox(
                                    width: 40,
                                    child: Center(
                                      child: Text(
                                        AppStrings.egp,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  fillColor: context.surface,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: context.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: context.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: context.primary),
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
                          color: context.warningBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: context.warningText.withOpacity(0.1)),
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
                              child: Icon(Icons.lightbulb_outline,
                                  size: 18, color: context.warningText),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'السعر المتوقع: $_expectedPrice ${AppStrings.egp}',
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.warningText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.paymentMethod,
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
                                  m.$1 == 'cash'
                                      ? '💵'
                                      : m.$1 == 'card'
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
                            selectedColor: context.primary,
                            backgroundColor: context.surface,
                            labelStyle: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : context.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? context.primary
                                    : context.border,
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
                          backgroundColor: context.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: context.primary.withOpacity(0.3),
                        ),
                        child: Text(
                          AppStrings.isArabic ? 'حفظ الفاتورة' : 'Save Invoice',
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
