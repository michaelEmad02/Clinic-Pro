// ────────────────────────────────────────────────────────
// شاشة العيادات — نظرة عامة على جميع الفروع
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
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
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 3),
            );
          }
          if (state is ClinicsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ClinicsCubit>().loadClinics(),
                    child: const Text('إعادة المحاولة'),
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
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _deleteClinic(BuildContext context, ClinicItem clinic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${clinic.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ClinicsCubit>().deleteClinic(clinic.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف "${clinic.name}"')),
              );
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _toggleClinicActive(BuildContext context, ClinicItem clinic) {
    final cubit = context.read<ClinicsCubit>();
    cubit.toggleActive(clinic.id);
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
        const SnackBar(content: Text('تم تحديث بيانات العيادة')),
      );
    } else {
      cubit.addClinic(
        name: result['name']!,
        phone: result['phone']!,
        address: result['address']!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة العيادة')),
      );
    }
  }
}
