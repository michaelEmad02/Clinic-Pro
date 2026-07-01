// ────────────────────────────────────────────────────────
// شاشة المرضى الرئيسية — مطابقة لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../manager/patients_cubit.dart';
import '../manager/patients_state.dart';
import 'widgets/add_edit_patient_sheet.dart';
import 'widgets/patient_action_sheet.dart';
import 'widgets/patients_filter_chips.dart';
import 'widgets/patients_list.dart';
import 'widgets/patients_search_bar.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PatientsCubit>()..loadPatients(),
      child: const _PatientsBody(),
    );
  }
}

class _PatientsBody extends StatelessWidget {
  const _PatientsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المرضى',
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'إدارة سجلات المرضى والبيانات الشخصية',
              style: AppTextStyles.caption(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: BlocBuilder<PatientsCubit, PatientsState>(
        builder: (context, state) {
          if (state is PatientsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 6),
            );
          }
          if (state is PatientsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<PatientsCubit>().loadPatients(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state is PatientsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PatientsCubit>().loadPatients();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  PatientsSearchBar(
                    onChanged: (q) =>
                        context.read<PatientsCubit>().search(q),
                  ),
                  const SizedBox(height: 12),
                  PatientsFilterChips(
                    activeFilter: state.activeFilter,
                    onChanged: (f) =>
                        context.read<PatientsCubit>().changeFilter(f),
                  ),
                  const SizedBox(height: 16),
                  PatientsList(
                    patients: state.filteredPatients,
                    onItemTap: (p) =>
                        context.push('${RouteConstants.patients}/${p.id}'),
                    onItemMore: (p) => _showActions(context, p),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEditPatientSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showActions(BuildContext context, PatientItem patient) {
    PatientActionSheet.show(
      context: context,
      patient: patient,
      onViewDetails: () =>
          context.push('${RouteConstants.patients}/${patient.id}'),
      onEdit: () => AddEditPatientSheet.show(context, patient: patient),
      onBookAppointment: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سيتم فتح حجز موعد من شاشة المواعيد')),
        );
      },
      onDeletePatient: () {
        _confirmDelete(context, patient);
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, PatientItem patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المريض'),
        content: Text('هل أنت متأكد من حذف "${patient.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<PatientsCubit>().deletePatient(patient.id);
    }
  }
}
