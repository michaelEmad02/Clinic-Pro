// ────────────────────────────────────────────────────────
// شاشة العيادات — نظرة عامة على جميع الفروع
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'create_clinic_screen.dart';
import '../../domain/entities/clinic_entity.dart';
import '../manager/cubit/clinics_cubit.dart';
import '../manager/cubit/clinics_state.dart';
import 'widgets/clinics_list.dart';

class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var ownerId = context.read<AuthCubit>().state.user?.id ?? '';
    return BlocProvider(
      create: (_) => sl<ClinicsCubit>()..fetchClinics(ownerId),
      child: _ClinicsBody(ownerId: ownerId),
    );
  }
}

class _ClinicsBody extends StatelessWidget {
  const _ClinicsBody({required this.ownerId});
  final String ownerId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.myClinics,
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            Text(
              AppStrings.clinicOverview,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.border, height: 1),
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
                        context.read<ClinicsCubit>().fetchClinics(ownerId),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is ClinicsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ClinicsCubit>().fetchClinics(ownerId);
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ResponsiveHelper.responsiveCenter(
                maxWidth: 1100,
                child: ClinicsList(
                  clinics: state.clinics,
                  onItemTap: (c) =>
                      context.push('${RouteConstants.clinics}/${c.id}'),
                  onItemEdit: (c) => _openClinicForm(context, clinic: c),
                  onItemToggleActive: (c) => _toggleClinicActive(context, c),
                  onItemDelete: (c) => _deleteClinic(context, c),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openClinicForm(context),
        backgroundColor: context.primary,
        foregroundColor: context.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        ),
        child: Icon(
          Icons.add,
          color: context.surfaceBright,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // حذف عيادة مع تأكيد
  Future<void> _deleteClinic(BuildContext context, ClinicEntity clinic) async {
    final cubit = context.read<ClinicsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.confirmDelete),
        content: Text(AppStrings.confirmDeleteClinic(clinic.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete,
                style: TextStyle(color: context.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await cubit.deleteClinic(clinic);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.deletedSuccess}"${clinic.name}"')),
    );
  }

  // تبديل حالة التفعيل
  Future<void> _toggleClinicActive(
      BuildContext context, ClinicEntity clinic) async {
    final cubit = context.read<ClinicsCubit>();
    await cubit.toggleActive(clinic.id);
    if (!context.mounted) return;
    final action =
        clinic.isActive ? AppStrings.toggleClinic : AppStrings.enableClinic;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('${AppStrings.toggledSuccess}$action "${clinic.name}"')),
    );
  }

  // فتح نموذج إضافة / تعديل عيادة
  Future<void> _openClinicForm(
    BuildContext context, {
    ClinicEntity? clinic,
  }) async {
    final cubit = context.read<ClinicsCubit>();
    final result = await Navigator.push<Map<String, dynamic>>(
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
        name: result['name'] as String,
        phone1: result['phone'] as String,
        address: result['address'] as String,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.updatedSuccess)),
      );
    } else {
      var userId = context.read<AuthCubit>().state.user?.id ?? '';
      final isDoctor = result['isDoctor'] as bool? ?? false;
      // إنشاء entity جديد لإضافته
      cubit.addClinic(
        ClinicEntity(
          id: '', // سيتم توليده من الخادم
          ownerId: userId, // سيتم تحديده من الجلسة
          name: result['name'] as String,
          phone1: result['phone'] as String,
          phone2: '',
          address: result['address'] as String,
          logoUrl: '',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        isDoctor: isDoctor,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.addedSuccess)),
      );
    }
  }
}
