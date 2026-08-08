// ────────────────────────────────────────────────────────
// تبويب الروشتات في تفاصيل المريض — يستعرض روشتات المريض بـ Cubit منفصل
// بتصميم متجاوب Responsive UI بعمودين للشاشات الواسعة وقائمة رأسية للجوال
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/empty_state.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/features/patients/presentation/manager/patient_prescriptions_cubit.dart';
import 'package:clinic_pro/features/patients/presentation/manager/patient_prescriptions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_prescription_card.dart';

class PatientPrescriptionsTab extends StatelessWidget {
  final String patientId;

  const PatientPrescriptionsTab({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PatientPrescriptionsCubit>()..loadPrescriptions(patientId),
      child: BlocBuilder<PatientPrescriptionsCubit, PatientPrescriptionsState>(
        builder: (context, state) {
          if (state is PatientPrescriptionsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 3),
            );
          }

          if (state is PatientPrescriptionsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is PatientPrescriptionsLoaded) {
            if (state.prescriptions.isEmpty) {
              return EmptyState(
                title: AppStrings.isArabic ? 'لا توجد روشتات' : 'No Prescriptions',
                subtitle: AppStrings.isArabic
                    ? 'لم تُصدر أي روشتة لهذا المريض بعد.'
                    : 'No prescriptions have been issued for this patient.',
                icon: Icons.medication_outlined,
              );
            }

            final isMobile = ResponsiveHelper.isMobile(context);

            if (isMobile) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.prescriptions.length,
                itemBuilder: (context, index) {
                  return PatientPrescriptionCard(
                    prescription: state.prescriptions[index],
                  );
                },
              );
            }

            // تقسيم الروشتات في عمودين متوازيين للشاشات الواسعة مع دعم التمدد الديناميكي للارتفاع
            final leftColumnPrescriptions = <dynamic>[];
            final rightColumnPrescriptions = <dynamic>[];

            for (int i = 0; i < state.prescriptions.length; i++) {
              if (i % 2 == 0) {
                leftColumnPrescriptions.add(state.prescriptions[i]);
              } else {
                rightColumnPrescriptions.add(state.prescriptions[i]);
              }
            }

            return ResponsiveHelper.responsiveCenter(
              maxWidth: 1100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: leftColumnPrescriptions
                            .map((p) => PatientPrescriptionCard(prescription: p))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: rightColumnPrescriptions
                            .map((p) => PatientPrescriptionCard(prescription: p))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
