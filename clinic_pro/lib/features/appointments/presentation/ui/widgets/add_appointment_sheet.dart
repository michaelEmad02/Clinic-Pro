// ────────────────────────────────────────────────────────
// Bottom Sheet إضافة موعد جديد — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/appointments_bloc.dart';
import '../../manager/appointments_event.dart';
import '../../manager/appointments_state.dart';
import 'patient_picker_field.dart';

class AddAppointmentSheet {
  /// يفتح sheet إضافة موعد جديد أو تعديل موعد موجود
  static Future<void> show(BuildContext context,
      {AppointmentItem? appointment}) {
    // نلتقط الـ Bloc الحالي من الشاشة الأم لنشاركه مع الـ Sheet
    final bloc = context.read<AppointmentsBloc>();
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: bloc,
        child: _AddAppointmentForm(appointment: appointment),
      ),
    );
  }
}

class _AddAppointmentForm extends StatefulWidget {
  final AppointmentItem? appointment;

  const _AddAppointmentForm({this.appointment});

  @override
  State<_AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends State<_AddAppointmentForm> {
  String? _patientId;
  String? _doctorId;
  String? _typeId;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _isUrgent = false;
  final _notesController = TextEditingController();

  /// هل نحن في وضع التعديل أم الإضافة؟
  bool get _isEditing => widget.appointment != null;

  @override
  void initState() {
    super.initState();
    // ملء الحقول بقيم الموعد الحالي عند التعديل
    final appt = widget.appointment;
    if (appt != null) {
      _patientId = appt.patientId;
      _doctorId = appt.doctorId;
      _typeId = appt.typeId;
      _date = DateTime.parse(appt.date);
      _isUrgent = appt.isUrgent;
      _notesController.text = appt.notes ?? '';

      // تحويل الوقت الخام '16:30:00' إلى TimeOfDay
      final parts = appt.rawTime.split(':');
      if (parts.length >= 2) {
        _time = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('ar'),
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    if (_patientId == null || _doctorId == null || _typeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    final timeStr =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}:00';

    final bloc = context.read<AppointmentsBloc>();

    if (_isEditing) {
      // وضع التعديل — تحديث الموعد القائم
      bloc.add(UpdateAppointmentEvent(
        appointmentId: widget.appointment!.id,
        doctorId: _doctorId!,
        typeId: _typeId!,
        date: _date.toIso8601String().substring(0, 10),
        time: timeStr,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isUrgent: _isUrgent,
      ));
    } else {
      // وضع الإضافة — إنشاء موعد جديد
      bloc.add(AddAppointmentEvent(
        patientId: _patientId!,
        doctorId: _doctorId!,
        typeId: _typeId!,
        date: _date.toIso8601String().substring(0, 10),
        time: timeStr,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isUrgent: _isUrgent,
      ));
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              _isEditing ? 'تم تعديل الموعد بنجاح' : 'تم إضافة الموعد بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctors = MockData.users
        .where((u) => u['role'] == 'doctor' || u['role'] == 'owner')
        .toList();

    final selectedType = _typeId != null
        ? MockData.appointmentTypes.firstWhere((t) => t['id'] == _typeId)
        : null;
    final typePrice = selectedType != null
        ? (selectedType['price'] as num).toStringAsFixed(0)
        : null;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الـ sheet: عنوان + زر إغلاق
          Row(
            children: [
              Expanded(
                child: Text(
                  _isEditing ? 'تعديل الموعد' : 'إضافة موعد جديد',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // في وضع التعديل لا يمكن تغيير المريض
          IgnorePointer(
            ignoring: _isEditing,
            child: Opacity(
              opacity: _isEditing ? 0.5 : 1.0,
              child: PatientPickerField(
                selectedPatientId: _patientId,
                onChanged: (id) => setState(() => _patientId = id),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // الدكتور المعالج
          Text(
            'الدكتور المعالج',
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'اختر الدكتور...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
                vertical: 13,
              ),
            ),
            value: _doctorId,
            items: doctors
                .map((d) => DropdownMenuItem(
                      value: d['id'] as String,
                      child: Text(d['name'] as String),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _doctorId = v),
          ),
          const SizedBox(height: 16),
          // التاريخ والوقت
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'التاريخ',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                        backgroundColor: AppColors.primaryLight,
                      ),
                      icon: const Icon(Icons.calendar_month_outlined,
                          size: 18, color: AppColors.primary),
                      label: Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الوقت',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickTime,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                        backgroundColor: AppColors.primaryLight,
                      ),
                      icon: const Icon(Icons.schedule_outlined,
                          size: 18, color: AppColors.primary),
                      label: Text(
                        _time.format(context),
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // نوع الزيارة مع السعر
          Row(
            children: [
              Text(
                'نوع الزيارة',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (typePrice != null) ...[
                const Spacer(),
                Text(
                  '$typePrice ر.س',
                  style: AppTextStyles.dataNumeric(context).copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
                vertical: 13,
              ),
            ),
            value: _typeId,
            items: MockData.appointmentTypes
                .map((t) => DropdownMenuItem(
                      value: t['id'] as String,
                      child: Text(t['name'] as String),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _typeId = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'ملاحظات (اختياري)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          // مفتاح حالة طارئة
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              color: _isUrgent
                  ? AppColors.dangerBg
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(
                color: _isUrgent
                    ? AppColors.danger.withOpacity(0.3)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حالة طارئة 🚨',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isUrgent
                              ? AppColors.dangerText
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سيحصل على الأولوية في الانتظار',
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isUrgent,
                  activeColor: AppColors.danger,
                  onChanged: (v) => setState(() => _isUrgent = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
            ),
            child: Text(
              _isEditing ? 'حفظ التعديلات' : 'حفظ الموعد',
              style: AppTextStyles.headlineSmall(context).copyWith(
                color: AppColors.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
