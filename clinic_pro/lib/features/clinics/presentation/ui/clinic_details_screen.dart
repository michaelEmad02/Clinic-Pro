// ────────────────────────────────────────────────────────
// شاشة تفاصيل العيادة — تخطيط عمودين (رئيسي + جانبي) مع Bento Grid
// مستوحى من تصميم phase8_ui/clinic_details_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/clinics_cubit.dart';
import '../manager/clinics_state.dart';
import 'widgets/clinic_details_header.dart';
import 'widgets/clinic_staff_section.dart';
import 'widgets/clinic_summary_cards.dart';
import 'widgets/clinic_visit_types_section.dart';
import 'widgets/clinic_working_hours_section.dart';
import 'widgets/clinic_map_placeholder.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/themes/app_colors.dart';

class ClinicDetailsScreen extends StatelessWidget {
  final String id;

  const ClinicDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicsCubit()..loadClinics(),
      child: _ClinicDetailsBody(id: id),
    );
  }
}

class _ClinicDetailsBody extends StatelessWidget {
  final String id;

  const _ClinicDetailsBody({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'تفاصيل العيادة',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              onPressed: () {},
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: BlocBuilder<ClinicsCubit, ClinicsState>(
        builder: (context, state) {
          if (state is ClinicsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ClinicsLoaded) {
            final clinic =
                state.clinics.where((c) => c.id == id).toList();
            if (clinic.isEmpty) {
              return const Center(child: Text('العيادة غير موجودة'));
            }
            return _DetailsContent(clinic: clinic.first);
          }
          return const Center(child: Text('تعذر تحميل البيانات'));
        },
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final ClinicItem clinic;

  const _DetailsContent({required this.clinic});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: isDesktop ? 1000 : double.infinity,
          child: Column(
            children: [
              ClinicDetailsHeader(clinic: clinic),
              const SizedBox(height: 16),
              ClinicSummaryCards(clinic: clinic),
              const SizedBox(height: 16),
              // تخطيط عمودين في سطح المكتب، عمود واحد في الجوال
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _MainColumn(clinicId: clinic.id),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _SidebarColumn(clinicId: clinic.id),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _MainColumn(clinicId: clinic.id),
                    const SizedBox(height: 16),
                    _SidebarColumn(clinicId: clinic.id),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainColumn extends StatelessWidget {
  final String clinicId;

  const _MainColumn({required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClinicVisitTypesSection(clinicId: clinicId),
        const SizedBox(height: 16),
        ClinicStaffSection(clinicId: clinicId),
      ],
    );
  }
}

class _SidebarColumn extends StatelessWidget {
  final String clinicId;

  const _SidebarColumn({required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClinicWorkingHoursSection(clinicId: clinicId),
        const SizedBox(height: 16),
        const ClinicMapPlaceholder(),
      ],
    );
  }
}
