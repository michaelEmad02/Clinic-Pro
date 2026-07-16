// ────────────────────────────────────────────────────────
// شاشة كشف المريض وكتابة الروشتة الطبية
// الشاشة الرئيسية التي تجمع كل الأقسام الفرعية:
// بطاقة المريض، التشخيص، الأدوية، الملاحظات، وأزرار الحفظ
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/prescription_bloc.dart';
import '../manager/prescription_event.dart';
import '../manager/prescription_state.dart';
import 'widgets/prescription_header_card.dart';
import 'widgets/templates_selector_section.dart';
import 'widgets/drugs_list_section.dart';
import 'widgets/prescription_notes_field.dart';
import 'widgets/prescription_bottom_actions_bar.dart';
import 'widgets/add_drug_search_sheet.dart';

class PrescriptionScreen extends StatelessWidget {
  final String appointmentId;
  final bool isEditing;

  const PrescriptionScreen({
    super.key,
    required this.appointmentId,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PrescriptionBloc>()..add(LoadPrescriptionDataEvent(appointmentId)),
      child: PrescriptionView(isEditing),
    );
  }
}
