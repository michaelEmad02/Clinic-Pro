// ────────────────────────────────────────────────────────
// Bottom Sheet تسجيل فاتورة جديدة — مطابق لتصميم Stitch وبدون MockData مباشرة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_bottom_sheet.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/presentation/manager/invoices_cubit.dart';
import 'package:clinic_pro/features/invoices/presentation/manager/invoices_state.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddInvoiceSheet {
  static Future<void> show(BuildContext context,
      {String? initialAppointmentId, InvoiceEntity? invoice}) {
    final clinicId = context.read<SettingsCubit>().state.clinicEntity?.id ?? '';
    InvoicesCubit cubit;
    try {
      cubit = context.read<InvoicesCubit>();
    } catch (_) {
      cubit = sl<InvoicesCubit>()..loadInvoices(clinicId);
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
  final InvoiceEntity? invoice;
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
  String? _selectedAppointmentId;
  String _paymentMethod = 'cash';

  List<PatientEntity> _searchResults = [];
  List<PatientEntity>? _cachedPatients;
  bool _showPatientSearch = true;
   double _expectedPrice = 0;
  double _alreadyPaidForAppointment = 0.0;
  bool _isLoading = false;
  String? _patientError;
  String? _totalAmountError;
  String? _paidAmountError;

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
        final patient = await cubit.getPatientById(inv.patientId);

        if (patient != null) {
          await _selectPatient(patient);
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

        final appt = await cubit.getAppointmentById(widget.initialAppointmentId!);

        if (appt != null) {
          final patient = await cubit.getPatientById(appt.patientId);

          if (patient != null) {
            await _selectPatient(patient);

            double paidSoFar = 0.0;
            final related = cubit.state.invoices.where((inv) => inv.sourceId == widget.initialAppointmentId);
            if (related.isNotEmpty) {
              paidSoFar = related.fold<double>(0.0, (sum, inv) => sum + inv.paidAmount);
            }

            _selectAppointment({
              'id': appt.id,
              'price': appt.price,
              'appointment_type_id': appt.typeId,
            }, paidSoFar: paidSoFar);
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
    if (_cachedPatients == null) {
      final clinicId = context.read<SettingsCubit>().state.clinicEntity?.id ?? '';
      _cachedPatients = await context.read<InvoicesCubit>().loadPatientsForClinic(clinicId);
    }

    final allPatients = _cachedPatients!;

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = allPatients;
      });
      return;
    }

    final results = allPatients.where((p) {
      final name = p.name.toLowerCase();
      final phone = (p.phone ?? '').toLowerCase();
      final q = query.trim().toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  Future<void> _selectPatient(PatientEntity patient) async {
    final patientId = patient.id;

    setState(() => _isLoading = true);
    final cubit = context.read<InvoicesCubit>();

    await cubit.loadPatientUnpaidAppointments(patientId);

    setState(() {
      _selectedPatientId = patientId;
      _selectedPatientName = patient.name;
      _selectedPatientPhone = patient.phone ?? '';
      _showPatientSearch = false;
      _patientSearchController.text = patient.name;
      _searchResults = [];
      _expectedPrice = 0;
      _alreadyPaidForAppointment = 0.0;
      _selectedAppointmentId = null;
      _totalAmountController.clear();
      _paidAmountController.clear();
      _isLoading = false;
    });
  }

  void _selectAppointment(Map<String, dynamic> appointment, {double paidSoFar = 0.0}) {
    final price = (appointment['price'] as num?)?.toDouble() ?? 0.0;
    final remaining = (price - paidSoFar) > 0 ? (price - paidSoFar) : 0.0;

    setState(() {
      _selectedAppointmentId = appointment['id'] as String;
      _alreadyPaidForAppointment = paidSoFar;
      _totalAmountController.text = price.toStringAsFixed(0);
      _paidAmountController.text = remaining.toStringAsFixed(0);
      _expectedPrice = price;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _patientError = null;
      _totalAmountError = null;
      _paidAmountError = null;
    });

    bool hasError = false;

    if (_selectedPatientId == null) {
      _patientError = AppStrings.isArabic
          ? 'يرجى اختيار المريض من القائمة'
          : 'Please select a patient';
      hasError = true;
    }

    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;

    if (_totalAmountController.text.trim().isEmpty) {
      _totalAmountError = AppStrings.isArabic
          ? 'يرجى إدخال المبلغ الإجمالي'
          : 'Please enter total amount';
      hasError = true;
    } else if (totalAmount <= 0) {
      _totalAmountError = AppStrings.isArabic
          ? 'المبلغ الإجمالي يجب أن يكون أكبر من 0'
          : 'Total amount must be greater than 0';
      hasError = true;
    }

    if (paidAmount < 0) {
      _paidAmountError = AppStrings.isArabic
          ? 'المبلغ المدفوع لا يمكن أن يكون بالسالب'
          : 'Paid amount cannot be negative';
      hasError = true;
    } else if (totalAmount > 0 && paidAmount > totalAmount) {
      _paidAmountError = AppStrings.isArabic
          ? 'المبلغ المدفوع لا يمكن أن يتخطى المبلغ الإجمالي'
          : 'Paid amount cannot exceed total amount';
      hasError = true;
    } else if (_alreadyPaidForAppointment > 0) {
      final remaining = (totalAmount - _alreadyPaidForAppointment) > 0 ? (totalAmount - _alreadyPaidForAppointment) : 0.0;
      if (paidAmount > remaining) {
        _paidAmountError = AppStrings.isArabic
            ? 'المبلغ المدفوع لا يمكن أن يتخطى المتبقي (${remaining.toStringAsFixed(0)})'
            : 'Paid amount cannot exceed remaining amount';
        hasError = true;
      }
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    final cubit = context.read<InvoicesCubit>();
    final user = context.read<AuthCubit>().state.user;
    final clinicId =
        context.read<SettingsCubit>().state.clinicEntity?.id ?? '';
    final createdBy = user?.id ?? '';

    if (widget.invoice != null) {
      final success = await cubit.updateInvoice(
        widget.invoice!.copyWith(
          totalAmount: totalAmount,
          paidAmount: paidAmount,
          paymentMethod: _paymentMethod,
        ),
      );
      setState(() => _isLoading = false);
      if (success && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.operationSuccessful)),
        );
      }
      return;
    }

    final success = await cubit.createInvoice(
      clinicId: clinicId,
      patientId: _selectedPatientId!,
      sourceId: _selectedAppointmentId ?? widget.initialAppointmentId ?? '',
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      paymentMethod: _paymentMethod,
      createdBy: createdBy,
    );

    setState(() => _isLoading = false);

    if (success && context.mounted) {
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
            Column(
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
                          errorText: _patientError,
                        ),
                        onTap: () {
                          if (_showPatientSearch) {
                            _searchPatients(_patientSearchController.text);
                          }
                        },
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
                                    p.initials,
                                    style: AppTextStyles.caption(context).copyWith(
                                        color: context.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  p.name,
                                  style: AppTextStyles.bodyMedium(context),
                                ),
                                subtitle: p.phone != null && p.phone!.isNotEmpty
                                    ? Text(
                                        p.phone!,
                                        style: AppTextStyles.caption(context),
                                      )
                                    : null,
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
                    BlocBuilder<InvoicesCubit, InvoicesState>(
                      builder: (context, state) {
                        final unpaid = state.patientUnpaidAppointments;
                        return Container(
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: context.border),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedAppointmentId,
                              hint: Text(
                                unpaid.isEmpty
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
                              items: unpaid.map((a) {
                                final label =
                                    '${a.appointmentTypeName ?? "كشف"} • ${a.date} • ${a.time}';
                                return DropdownMenuItem(
                                  value: a.id,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(label,
                                          style:
                                              AppTextStyles.bodyMedium(context)
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                      Text(
                                          '${AppStrings.isArabic ? "السعر المتوقع" : "Expected Price"}: ${a.expectedPrice.toStringAsFixed(0)}',
                                          style: AppTextStyles.caption(context)
                                              .copyWith(
                                                  color:
                                                      context.textSecondary)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: unpaid.isEmpty
                                  ? null
                                  : (v) {
                                      final appointment = unpaid
                                          .firstWhere((a) => a.id == v);
                                      _selectAppointment({
                                        'id': appointment.id,
                                        'price': appointment.expectedPrice,
                                      }, paidSoFar: appointment.paidSoFar);
                                    },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    BlocBuilder<InvoicesCubit, InvoicesState>(
                      builder: (context, state) {
                        final unpaid = state.patientUnpaidAppointments;
                        return Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 14, color: context.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              unpaid.isEmpty
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
                        );
                      },
                    ),
                    // 1. حقل المبلغ الإجمالي (كامل العرض)
                    Text(
                      AppStrings.total,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _totalAmountController,
                      enabled: _selectedAppointmentId == null,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      onChanged: (_) {
                        if (_totalAmountError != null) {
                          setState(() => _totalAmountError = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                        // suffixIcon: SizedBox(
                        //   width: 40,
                        //   child: Center(
                        //     child: Text(
                        //       AppStrings.egp,
                        //       style: AppTextStyles.caption(context).copyWith(
                        //         color: context.textSecondary,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: context.border.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: context.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceMd,
                          vertical: 13,
                        ),
                        errorText: _totalAmountError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_alreadyPaidForAppointment > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.isArabic ? 'المبلغ المدفوع سابقاً' : 'Previously Paid Amount',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: TextEditingController(text: _alreadyPaidForAppointment.toStringAsFixed(0)),
                        enabled: false,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          // suffixIcon: SizedBox(
                          //   width: 40,
                          //   child: Center(
                          //     child: Text(
                          //       AppStrings.egp,
                          //       style: AppTextStyles.caption(context).copyWith(
                          //         color: context.textSecondary,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          fillColor: context.surface.withOpacity(0.5),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: context.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: context.border),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: context.border.withOpacity(0.5)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceMd,
                            vertical: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.isArabic ? 'المبلغ المدفوع الآن' : 'Amount Paid Now',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _paidAmountController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) {
                          if (_paidAmountError != null) {
                            setState(() => _paidAmountError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                          // suffixIcon: SizedBox(
                          //   width: 40,
                          //   child: Center(
                          //     child: Text(
                          //       AppStrings.egp,
                          //       style: AppTextStyles.caption(context).copyWith(
                          //         color: context.textSecondary,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),
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
                          errorText: _paidAmountError,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.paid,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _paidAmountController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) {
                          if (_paidAmountError != null) {
                            setState(() => _paidAmountError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                          // suffixIcon: SizedBox(
                          //   width: 40,
                          //   child: Center(
                          //     child: Text(
                          //       AppStrings.egp,
                          //       style: AppTextStyles.caption(context).copyWith(
                          //         color: context.textSecondary,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),
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
                          errorText: _paidAmountError,
                        ),
                      ),
                    ],
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
                              '${AppStrings.isArabic ? "السعر المتوقع" : "Expected Price"}: $_expectedPrice',
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
                            labelStyle: AppTextStyles.caption(context).copyWith(
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
        ],
      ),
    );
  }
}
