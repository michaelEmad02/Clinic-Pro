// ────────────────────────────────────────────────────────
// شاشة الفواتير — عرض الفواتير وإدارتها
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/core/widgets/app_error_widget.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/presentation/manager/invoices_cubit.dart';
import 'package:clinic_pro/features/invoices/presentation/manager/invoices_state.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/add_invoice_sheet.dart';
import 'widgets/invoice_action_sheet.dart';
import 'widgets/invoices_date_range_chips.dart';
import 'widgets/invoices_list.dart';
import 'widgets/invoices_summary_bar.dart';
import 'widgets/invoices_tab_selector.dart';
import 'widgets/unbilled_appointments_list.dart';
import 'widgets/unbilled_patient_filter_chips.dart';

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import '../../../../core/widgets/read_only_guard.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.read<SettingsCubit>().state;
    final clinicId = settingsState.clinicEntity?.id ?? '';
    final authUser = context.read<AuthCubit>().state.user;
    final isDoctor = authUser?.role == StaffRoles.doctor;
    final activeDoctorId = isDoctor
        ? authUser?.id
        : (settingsState.currentDoctorId ??
            (AppConstants.activeDoctorId.isNotEmpty
                ? AppConstants.activeDoctorId
                : null));

    return BlocProvider(
      create: (_) => sl<InvoicesCubit>()..loadInvoices(clinicId, doctorId: activeDoctorId),
      child: const _InvoicesBody(),
    );
  }
}

class _InvoicesBody extends StatelessWidget {
  const _InvoicesBody();

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final clinicId = settingsState.clinicEntity?.id ?? '';
    final authUser = context.watch<AuthCubit>().state.user;
    final isDoctor = authUser?.role == StaffRoles.doctor;
    final activeDoctorId = isDoctor
        ? authUser?.id
        : (settingsState.currentDoctorId ??
            (AppConstants.activeDoctorId.isNotEmpty
                ? AppConstants.activeDoctorId
                : null));

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.invoices,
          style: AppTextStyles.headlineLarge(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: BlocBuilder<InvoicesCubit, InvoicesState>(
        builder: (context, state) {
          if (state.status == InvoicesStatus.loading &&
              state.invoices.isEmpty &&
              state.unbilledAppointments.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 5),
            );
          }
          if (state.status == InvoicesStatus.failure &&
              state.invoices.isEmpty &&
              state.unbilledAppointments.isEmpty) {
            return AppErrorWidget.buildErrorView(
              context: context,
              error: state.errorMessage,
              onRetry: () =>
                  context.read<InvoicesCubit>().loadInvoices(clinicId, doctorId: activeDoctorId),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<InvoicesCubit>().loadInvoices(clinicId, doctorId: activeDoctorId);
            },
            child: ResponsiveHelper.responsiveCenter(
              maxWidth: 1100,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  InvoicesSummaryBar(state: state),
                  const SizedBox(height: 12),
                  InvoicesTabSelector(
                    activeTab: state.activeTab,
                    invoicesCount: state.filteredInvoices.length,
                    unbilledCount: state.filteredUnbilledAppointments.length,
                    onTabChanged: (tab) {
                      context.read<InvoicesCubit>().changeTab(tab);
                    },
                  ),
                  const SizedBox(height: 12),
                  InvoicesDateRangeChips(
                    activeDateRange: state.activeDateRange,
                    activeStatusFilter: state.activeStatusFilter,
                    showStatusFilter: state.activeTab == 'invoices',
                    onDateRangeChanged: (range) async {
                      if (range == InvoicesDateRange.custom) {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && context.mounted) {
                          context.read<InvoicesCubit>().filterInvoices(
                                dateRange: range,
                                customStart: picked.start,
                                customEnd: picked.end,
                              );
                        }
                      } else {
                        context.read<InvoicesCubit>().filterInvoices(dateRange: range);
                      }
                    },
                    onStatusFilterChanged: (status) {
                      context.read<InvoicesCubit>().filterInvoices(statusFilter: status);
                    },
                  ),
                  if (state.activeTab == 'unbilled' &&
                      state.availableUnbilledPatients.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    UnbilledPatientFilterChips(
                      availablePatients: state.availableUnbilledPatients,
                      selectedPatientId: state.selectedUnbilledPatientId,
                      onPatientSelected: (patientId) {
                        context
                            .read<InvoicesCubit>()
                            .filterUnbilledByPatient(patientId);
                      },
                    ),
                  ],
                  const SizedBox(height: 0),
                  AnimatedCrossFade(
                    firstChild: InvoicesList(
                      invoices: state.filteredInvoices,
                      onItemTap: (inv) => _showActions(context, inv),
                      onItemMore: (inv) => _showActions(context, inv),
                    ),
                    secondChild: UnbilledAppointmentsList(
                      appointments: state.filteredUnbilledAppointments,
                    ),
                    crossFadeState: state.activeTab == 'invoices'
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 350),
                    sizeCurve: Curves.easeInOutCubic,
                    firstCurve: Curves.easeOutCubic,
                    secondCurve: Curves.easeOutCubic,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ReadOnlyGuard.protect(
          context,
          onAllowed: () => AddInvoiceSheet.show(context),
        ),
        backgroundColor: context.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _showActions(BuildContext context, InvoiceEntity invoice) {
    InvoiceActionSheet.show(
      context: context,
      invoice: invoice,
    );
  }
}

