// ────────────────────────────────────────────────────────
// شاشة العيادات — نظرة عامة على جميع الفروع
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../onboarding/presentation/ui/create_clinic_screen.dart';
import '../manager/clinics_cubit.dart';
import '../manager/clinics_state.dart';
import 'widgets/clinics_list.dart';

class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicsCubit()..loadClinics(),
      child: const _ClinicsBody(),
    );
  }
}

class _ClinicsBody extends StatelessWidget {
  const _ClinicsBody();

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
              'عياداتي',
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'نظرة عامة على أداء جميع الفروع',
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
      body: BlocBuilder<ClinicsCubit, ClinicsState>(
        builder: (context, state) {
          if (state is ClinicsLoading) {
            return const Padding(
              padding: EdgeInsets.all(AppConstants.spaceMd),
              child: ShimmerList(itemCount: 3),
            );
          }
          if (state is ClinicsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: AppConstants.spaceMd),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ClinicsCubit>().loadClinics(),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is ClinicsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ClinicsCubit>().loadClinics();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ClinicsList(
                clinics: state.clinics,
                onItemTap: (c) =>
                    context.push('${RouteConstants.clinics}/${c.id}'),
                onItemEdit: (c) => _openClinicForm(context, clinic: c),
                onItemToggleActive: (c) =>
                    _toggleClinicActive(context, c),
                onItemDelete: (c) =>
                    _deleteClinic(context, c),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openClinicForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Future<void> _deleteClinic(BuildContext context, ClinicItem clinic) async {
    final cubit = context.read<ClinicsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text('هل أنت متأكد من حذف "${clinic.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete, style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await cubit.deleteClinic(clinic.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.deletedSuccess}"${clinic.name}"')),
    );
  }

  Future<void> _toggleClinicActive(BuildContext context, ClinicItem clinic) async {
    final cubit = context.read<ClinicsCubit>();
    await cubit.toggleActive(clinic.id);
    if (!context.mounted) return;
    final action = clinic.isActive ? 'تعطيل' : 'تفعيل';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم $action "${clinic.name}"')),
    );
  }

  Future<void> _openClinicForm(
    BuildContext context, {
    ClinicItem? clinic,
  }) async {
    final cubit = context.read<ClinicsCubit>();
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateClinicScreen(
          clinic: clinic,
          isOnboarding: false,
        ),
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;
    if (clinic != null) {
      cubit.updateClinic(clinic.copyWith(
        name: result['name']!,
        phone: result['phone']!,
        address: result['address']!,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.updatedSuccess)),
      );
    } else {
      cubit.addClinic(
        name: result['name']!,
        phone: result['phone']!,
        address: result['address']!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.addedSuccess)),
      );
    }
  }
}
