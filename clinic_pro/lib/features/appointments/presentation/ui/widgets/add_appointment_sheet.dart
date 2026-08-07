import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';

import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
import '../../../../auth/presentation/manager/auth_state.dart';
import '../../../../settings/presentation/manager/settings_cubit.dart';
import '../../../../settings/presentation/manager/visit_types_cubit.dart';
import '../../../../settings/presentation/manager/visit_types_state.dart';
import '../../../../patients/presentation/manager/patients_cubit.dart';
import '../../manager/appointments_bloc.dart';
import '../../manager/appointments_event.dart';
import '../../manager/appointments_state.dart';
import '../../../domain/entities/appointment_entity.dart';
import 'patient_picker_field.dart';

class AddAppointmentSheet {
  /// يفتح sheet إضافة موعد جديد أو تعديل موعد موجود
  static Future<void> show(
    BuildContext context, {
    AppointmentEntity? appointment,
    String? initialPatientId,
    AppointmentsBloc? appointmentsBloc,
  }) {
    AppointmentsBloc bloc;
    if (appointmentsBloc != null) {
      bloc = appointmentsBloc;
    } else {
      try {
        bloc = context.read<AppointmentsBloc>();
      } catch (_) {
        bloc = sl<AppointmentsBloc>();
      }
    }
    final activeClinicId =
        context.read<SettingsCubit>().state.clinicEntity?.id ??
            AppConstants.activeClinicId;
    return AppBottomSheet.show(
      context: context,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppointmentsBloc>.value(value: bloc),
          BlocProvider(create: (_) => sl<VisitTypesCubit>()),
          BlocProvider(
              create: (_) =>
                  sl<PatientsCubit>()..loadPatients(clinicId: activeClinicId)),
        ],
        child: _AddAppointmentForm(
          appointment: appointment,
          initialPatientId: initialPatientId,
        ),
      ),
    );
  }
}

class _AddAppointmentForm extends StatefulWidget {
  final AppointmentEntity? appointment;
  final String? initialPatientId;

  const _AddAppointmentForm({
    this.appointment,
    this.initialPatientId,
  });

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
    _patientId = widget.initialPatientId;
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
      final parts = (appt.time ?? '00:00:00').split(':');
      if (parts.length >= 2) {
        _time = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    } else {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final currentUser = authState.user;
        if (currentUser.role == StaffRoles.doctor) {
          _doctorId = currentUser.id;
        } else {
          final settingsState = context.read<SettingsCubit>().state;
          _doctorId = settingsState.currentDoctorId;
          if (_doctorId == null || _doctorId!.isEmpty) {
            _doctorId = AppConstants.activeDoctorId.isNotEmpty
                ? AppConstants.activeDoctorId
                : null;
          }
        }
      }
      // تعيين وقت بداية مبدئي ذكي بناءً على آخر موعد محجوز
      _recalculateTimeForSelectedType(_typeId);
    }

    final activeClinicId =
        context.read<SettingsCubit>().state.clinicEntity?.id ??
            AppConstants.activeClinicId;
    if (_doctorId != null && activeClinicId.isNotEmpty) {
      context.read<VisitTypesCubit>().loadData(
            doctorId: _doctorId!,
            clinicId: activeClinicId,
          );
    }
  }

  void _recalculateTimeForSelectedType(String? newTypeId) {
    if (_isEditing) return;

    final appState = context.read<AppointmentsBloc>().state;
    if (appState is AppointmentsLoaded && appState.allAppointments.isNotEmpty) {
      final targetDateStr = _date.toIso8601String().substring(0, 10);
      final sameDayAppts = appState.allAppointments
          .where((a) => a.date == targetDateStr)
          .toList();

      if (sameDayAppts.isNotEmpty) {
        sameDayAppts.sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));
        final lastAppt = sameDayAppts.last;

        final parts = (lastAppt.time ?? '00:00').split(':');
        if (parts.length >= 2) {
          final lastHour = int.tryParse(parts[0]) ?? 0;
          final lastMin = int.tryParse(parts[1]) ?? 0;
          final lastTimeInMinutes = lastHour * 60 + lastMin;

          final visitCubitState = context.read<VisitTypesCubit>().state;
          int duration = 15;
          if (newTypeId != null &&
              visitCubitState.addedEntries.any((t) => t.id == newTypeId)) {
            duration = visitCubitState.addedEntries
                .firstWhere((t) => t.id == newTypeId)
                .durationInMinutes;
          }

          final nextTimeInMinutes = lastTimeInMinutes + duration;
          final nextHour = (nextTimeInMinutes ~/ 60) % 24;
          final nextMin = nextTimeInMinutes % 60;
          setState(() {
            _time = TimeOfDay(hour: nextHour, minute: nextMin);
          });
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
      locale: Localizations.localeOf(context),
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
        SnackBar(content: Text(AppStrings.fillRequiredFields)),
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
      final authState = context.read<AuthCubit>().state;
      String currentUser = '';
      if (authState is AuthAuthenticated) {
        currentUser = authState.user.id;
      }
      // وضع الإضافة — إنشاء موعد جديد
      bloc.add(AddAppointmentEvent(
        patientId: _patientId!,
        doctorId: _doctorId!,
        currentUser: currentUser,
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
    final authState = context.read<AuthCubit>().state;
    final settingsState = context.read<SettingsCubit>().state;

    String selectedDoctorName = '';
    if (_doctorId != null) {
      if (authState is AuthAuthenticated &&
          authState.user.role == StaffRoles.doctor &&
          authState.user.id == _doctorId) {
        selectedDoctorName = authState.user.name;
      } else if (settingsState.currentDoctorId == _doctorId &&
          settingsState.currentDoctorName != null) {
        selectedDoctorName = settingsState.currentDoctorName!;
      } else {
        selectedDoctorName = AppStrings.treatingDoctor;
      }
    }

    return BlocConsumer<VisitTypesCubit, VisitTypesState>(
      listener: (context, visitTypesState) {
        if (!visitTypesState.isLoading &&
            visitTypesState.addedEntries.isNotEmpty &&
            _typeId == null &&
            widget.appointment == null) {
          setState(() {
            _typeId = visitTypesState.addedEntries.first
                .id; // t.id represents doctor_appointment_types.id
          });
        }
      },
      builder: (context, visitTypesState) {
        final appointmentTypes = visitTypesState.addedEntries;
        final isLoadingTypes = visitTypesState.isLoading;

        final selectedType =
            (_typeId != null && appointmentTypes.any((t) => t.id == _typeId))
                ? appointmentTypes.firstWhere((t) => t.id == _typeId)
                : null;
        final typePrice = (selectedType != null && selectedType.id.isNotEmpty)
            ? selectedType.price.toStringAsFixed(0)
            : null;

        return ResponsiveHelper.responsiveCenter(
          maxWidth: 600,
          child: Padding(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusInput),
                    border: Border.all(color: context.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline,
                          color: context.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        selectedDoctorName.isNotEmpty
                            ? selectedDoctorName
                            : AppStrings.notSpecified,
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
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusButton),
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
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusButton),
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
                isLoadingTypes
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          fillColor: context.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusInput),
                            borderSide: BorderSide(color: context.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusInput),
                            borderSide:
                                BorderSide(color: context.primary, width: 1.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusInput),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceMd,
                            vertical: 13,
                          ),
                        ),
                        value: _typeId,
                        items: appointmentTypes
                            .map((t) => DropdownMenuItem(
                                  value: t
                                      .id, // matches doctor_appointment_types.id
                                  child: Text(t.name ?? ''),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _typeId = v);
                          _recalculateTimeForSelectedType(v);
                        },
                      ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.notes} ${AppStrings.optional}',
                    alignLabelWithHint: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                      borderSide:
                          BorderSide(color: context.primary, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
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
                        ? context.dangerBg
                        : (context.isDarkMode
                            ? context.surfaceColor
                            : context.surfaceContainerLow),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusCard),
                    border: Border.all(
                      color: _isUrgent
                          ? context.danger.withOpacity(0.3)
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
                                    ? context.dangerText
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
                        activeColor: context.danger,
                        onChanged: (v) => setState(() => _isUrgent = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: context.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shadowColor: context.primary.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusButton),
                    ),
                  ),
                  child: Text(
                    _isEditing
                        ? AppStrings.saveChanges
                        : '${AppStrings.save} ${AppStrings.appointment}',
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      color: context.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
