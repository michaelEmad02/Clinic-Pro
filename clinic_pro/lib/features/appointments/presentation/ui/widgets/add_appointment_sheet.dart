// ────────────────────────────────────────────────────────
// Bottom Sheet إضافة موعد جديد — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
import '../../../../auth/presentation/manager/auth_state.dart';
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
    } else {
      final authState = context.read<AuthCubit>().state;
      String? currentUserId;
      String? currentUserRole;
      if (authState is AuthAuthenticated) {
        currentUserId = authState.user.id;
        currentUserRole = authState.user.role.name;
      }

      if (currentUserRole == 'doctor') {
        _doctorId = currentUserId;
      } else {
        final clinicStaffIds = MockData.clinicStaff
            .where((cs) => cs['clinic_id'] == AppConstants.activeClinicId && cs['role'] == 'doctor')
            .map((cs) => cs['user_id'] as String)
            .toSet();
        final clinicDoctors = MockData.users
            .where((u) => clinicStaffIds.contains(u['id']))
            .toList();
        if (clinicDoctors.isNotEmpty) {
          _doctorId = clinicDoctors.first['id'] as String;
        }
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
        SnackBar(
            content: Text(AppStrings.isArabic
                ? 'يرجى ملء جميع الحقول المطلوبة'
                : 'Please fill all required fields')),
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
          content: Text(_isEditing
              ? AppStrings.updatedSuccess
              : AppStrings.addedSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicStaffIds = MockData.clinicStaff
        .where((cs) => cs['clinic_id'] == AppConstants.activeClinicId && cs['role'] == 'doctor')
        .map((cs) => cs['user_id'] as String)
        .toSet();
    final doctors = MockData.users
        .where((u) => clinicStaffIds.contains(u['id']))
        .toList();

    final selectedType = _typeId != null
        ? MockData.appointmentTypes.firstWhere((t) => t['id'] == _typeId)
        : null;
    final typePrice = selectedType != null
        ? (selectedType['price'] as num).toStringAsFixed(0)
        : null;

    final selectedDoctorName = _doctorId != null
        ? (doctors.firstWhere((d) => d['id'] == _doctorId, orElse: () => {'name': ''})['name'] as String)
        : '';

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
                  _isEditing
                      ? '${AppStrings.edit} ${AppStrings.appointment}'
                      : AppStrings.newAppointment,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: context.textSecondary,
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
                doctorId: _doctorId,
                onChanged: (id) => setState(() => _patientId = id),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // الدكتور المعالج (عرض فقط)
          Text(
            AppStrings.doctorLabel,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: context.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  selectedDoctorName.isNotEmpty ? selectedDoctorName : (AppStrings.isArabic ? 'غير محدد' : 'Not specified'),
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
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
                      AppStrings.date,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: context.primary.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: context.border),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                        backgroundColor: context.primaryLightColor,
                      ),
                      icon: Icon(Icons.calendar_month_outlined,
                          size: 18, color: context.primary),
                      label: Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: context.primary,
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
                      AppStrings.timing,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickTime,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: context.primary.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                        backgroundColor: context.primaryLightColor,
                      ),
                      icon: Icon(Icons.schedule_outlined,
                          size: 18, color: context.primary),
                      label: Text(
                        _time.format(context),
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: context.primary,
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
                AppStrings.visitType,
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (typePrice != null) ...[
                const Spacer(),
                Text(
                  '$typePrice ${AppStrings.sar}',
                  style: AppTextStyles.dataNumeric(context).copyWith(
                    color: context.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              fillColor: context.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                borderSide: BorderSide(color: context.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                borderSide: BorderSide(color: context.primary, width: 1.5),
              ),
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
              labelText: '${AppStrings.notes} ${AppStrings.optional}',
              alignLabelWithHint: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                borderSide: BorderSide(color: context.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                borderSide: BorderSide(color: context.primary, width: 1.5),
              ),
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
                  : (context.isDarkMode
                      ? const Color(0xFF2A2A2A)
                      : AppColors.surfaceContainerLow),
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(
                color: _isUrgent
                    ? AppColors.danger.withOpacity(0.3)
                    : context.borderColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.emergencyBanner,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isUrgent
                              ? AppColors.dangerText
                              : context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.emergencyPriorityDescription,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
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
              _isEditing
                  ? AppStrings.saveChanges
                  : '${AppStrings.save} ${AppStrings.appointment}',
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
