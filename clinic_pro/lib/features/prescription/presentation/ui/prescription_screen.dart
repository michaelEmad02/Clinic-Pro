// ────────────────────────────────────────────────────────
// شاشة كشف المريض وكتابة الروشتة الطبية
// الشاشة الرئيسية التي تجمع كل الأقسام الفرعية:
// بطاقة المريض، التشخيص، الأدوية، الملاحظات، وأزرار الحفظ
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/prescription_bloc.dart';
import '../manager/prescription_event.dart';

import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/presentation/manager/appointments_bloc.dart';

class PrescriptionScreen extends StatelessWidget {
  final AppointmentEntity appointment;
  final bool isEditing;

  const PrescriptionScreen({
    super.key,
    required this.appointment,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<PrescriptionBloc>()..add(LoadPrescriptionDataEvent(appointment)),
        ),
        BlocProvider(
          create: (context) => sl<AppointmentsBloc>(),
        ),
      ],
      child: PrescriptionView(isEditing, appointment: appointment),
    );
  }
}
