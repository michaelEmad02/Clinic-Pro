// ────────────────────────────────────────────────────────
// SliverAppBar لتفاصيل المريض — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/patients_state.dart';

class PatientSliverAppBar extends StatelessWidget {
  final PatientItem patient;

  const PatientSliverAppBar({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: context.surface,
      foregroundColor: context.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [context.primaryLightColor, context.surface],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: context.primary,
                  child: Text(
                    patient.initials,
                    style: AppTextStyles.headlineMedium(context).copyWith(
                      color: context.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  patient.name,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (patient.bloodType != null)
                  Text(
                    patient.bloodType!,
                    style: AppTextStyles.dataNumeric(context).copyWith(
                      color: context.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
