// ────────────────────────────────────────────────────────
// FinancialReceivablesScreen — الشاشة الرئيسية لتقرير المستحقات المالية
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_error_widget.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/empty_state.dart';
import 'package:clinic_pro/features/reports/presentation/manager/financial_receivables_cubit.dart';
import 'package:clinic_pro/features/reports/presentation/manager/financial_receivables_state.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import 'package:clinic_pro/features/reports/presentation/ui/widgets/debtor_patient_card.dart';
import 'package:clinic_pro/features/reports/presentation/ui/widgets/financial_receivables_kpi_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';

import 'package:clinic_pro/features/clinics/presentation/manager/cubit/clinics_cubit.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/clinics_state.dart';
import 'package:clinic_pro/features/staff_and_invitations/presentation/manager/staff_cubit.dart';
import 'package:clinic_pro/features/staff_and_invitations/presentation/manager/staff_state.dart';
import 'package:clinic_pro/features/reports/presentation/ui/widgets/reports_date_range_chips.dart';

class FinancialReceivablesScreen extends StatelessWidget {
  const FinancialReceivablesScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FinancialReceivablesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthCubit>().state.user;
    final isOwner = authUser?.role == StaffRoles.owner;
    final isDoctor = authUser?.role == StaffRoles.doctor;
    final ownerId = isOwner ? authUser?.id : null;
    final doctorId = isDoctor ? authUser?.id : null;
    final userId = authUser?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<FinancialReceivablesCubit>()
            ..loadReport(
              ownerId: ownerId,
              resetClinic: true,
              clinicId: null,
              resetDoctor: true,
              doctorId: doctorId,
            ),
        ),
        BlocProvider(
          create: (_) => sl<ClinicsCubit>()..fetchClinics(userId),
        ),
        BlocProvider(
          create: (_) => sl<StaffCubit>()..fetchAllStaff(userId),
        ),
      ],
      child: const _FinancialReceivablesView(),
    );
  }
}

class _FinancialReceivablesView extends StatefulWidget {
  const _FinancialReceivablesView();

  @override
  State<_FinancialReceivablesView> createState() => _FinancialReceivablesViewState();
}

class _FinancialReceivablesViewState extends State<_FinancialReceivablesView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.isArabic ? 'تقرير المستحقات المالية' : 'Financial Receivables Report',
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.isArabic ? 'تحديث البيانات' : 'Refresh Data',
            onPressed: () {
              context.read<FinancialReceivablesCubit>().loadReport(forceRefresh: true);
            },
          ),
        ],
      ),
      body: BlocBuilder<FinancialReceivablesCubit, FinancialReceivablesState>(
        builder: (context, state) {
          if (state.status == FinancialReceivablesStatus.loading) {
            return const Center(child: AppLoadingWidget());
          }

          if (state.status == FinancialReceivablesStatus.error) {
            return AppErrorWidget(
              message: state.errorMessage ?? AppStrings.unknownPatient,
              onRetry: () => context.read<FinancialReceivablesCubit>().loadReport(forceRefresh: true),
            );
          }

          final report = state.report;
          if (report == null) {
            return const Center(child: AppLoadingWidget());
          }

          return ResponsiveHelper.responsiveCenter(
            maxWidth: 1100,
            child: RefreshIndicator(
              onRefresh: () => context.read<FinancialReceivablesCubit>().loadReport(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // شريط فلاتر التاريخ والعيادة والطبيب ونوع المستحق
                    _FilterHeader(state: state),
                    const SizedBox(height: 16),
                    // كروت الإحصائيات العليا وتحليل أعمار الديون
                    FinancialReceivablesKpiBar(report: report),
                    const SizedBox(height: 20),
                    // شريط اختيار التبويب الحالية (كشف حساب المرضى / السجل التفصيلي)
                    _ReceivablesTabSelector(
                      activeTab: state.activeTab,
                      onTabChanged: (index) {
                        context.read<FinancialReceivablesCubit>().changeTab(index);
                      },
                    ),
                    const SizedBox(height: 16),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: state.activeTab == 0
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Column(
                        children: [
                          // مربع بحث المرضى المديونين
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: AppStrings.isArabic
                                    ? 'بحث باسم المريض أو رقم الهاتف...'
                                    : 'Search debtor by name or phone...',
                                prefixIcon: Icon(Icons.search, size: 20, color: context.textHint),
                                fillColor: context.surface,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: context.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: context.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: context.primary),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (val) {
                                context.read<FinancialReceivablesCubit>().setSearchQuery(val);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // قائمة المرضى المديونين المصفاة
                          _DebtorsList(debtors: state.filteredDebtors),
                        ],
                      ),
                      secondChild: _DetailedOutstandingsLog(debtors: state.filteredDebtors),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReceivablesTabSelector extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;

  const _ReceivablesTabSelector({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AppStrings.isArabic ? 'كشف حساب المرضى المديونين' : 'Debtors Ledger',
      AppStrings.isArabic ? 'السجل التفصيلي للمستحقات' : 'Detailed Outstandings Log',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = activeTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => onTabChanged(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? context.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.primary.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : context.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  final FinancialReceivablesState state;

  const _FilterHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthCubit>().state.user;
    final isDoctor = authUser?.role == StaffRoles.doctor;

    final typeFilters = [
      (0, AppStrings.isArabic ? 'الكل' : 'All'),
      (1, AppStrings.isArabic ? 'فواتير معلقة' : 'Pending Invoices'),
      (2, AppStrings.isArabic ? 'زيارات غير مفوترة' : 'Unbilled Visits'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اختيار العيادة واختيار الطبيب
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // فلتر العيادات
              Expanded(
                child: BlocBuilder<ClinicsCubit, ClinicsState>(
                  builder: (context, clinicsState) {
                    final clinics = (clinicsState is ClinicsLoaded) ? clinicsState.clinics : [];
                    final clinicIds = clinics.map((c) => c.id).toSet();
                    final effectiveClinicValue = (state.selectedClinicId != null && clinicIds.contains(state.selectedClinicId))
                        ? state.selectedClinicId
                        : null;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: effectiveClinicValue,
                          isExpanded: true,
                          hint: Text(
                            AppStrings.isArabic ? 'جميع العيادات' : 'All Clinics',
                            style: AppTextStyles.caption(context),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                AppStrings.isArabic ? 'جميع العيادات' : 'All Clinics',
                                style: AppTextStyles.caption(context),
                              ),
                            ),
                            ...clinics.map(
                              (c) => DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  style: AppTextStyles.caption(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            context.read<FinancialReceivablesCubit>().loadReport(
                                  resetClinic: true,
                                  clinicId: val,
                                  resetDoctor: true,
                                  doctorId: isDoctor ? authUser?.id : null,
                                );
                            context.read<StaffCubit>().changeClinicFilter(val);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!isDoctor) ...[
                const SizedBox(width: 8),
                // فلتر الأطباء (يعتمد ديناميكياً على العيادة المحددة ومع تجميع الأطباء بدون تكرار)
                Expanded(
                  child: BlocBuilder<StaffCubit, StaffState>(
                    builder: (context, staffState) {
                      List<dynamic> doctors = [];
                      if (staffState is StaffLoaded) {
                        if (state.selectedClinicId == null || state.selectedClinicId!.isEmpty) {
                          // حالة جميع العيادات: إظهار كافة الأطباء بدون تكرار
                          final Map<String, dynamic> doctorMap = {};
                          for (final s in staffState.allStaff) {
                            if (s.role == StaffRoles.doctor) {
                              final key = s.userId.isNotEmpty ? s.userId : s.id;
                              if (!doctorMap.containsKey(key)) {
                                doctorMap[key] = s;
                              }
                            }
                          }
                          doctors = doctorMap.values.toList();
                        } else {
                          // حالة عيادة محددة: إظهار الأطباء التابعين لهذه العيادة فقط
                          doctors = staffState.allStaff
                              .where((s) => s.role == StaffRoles.doctor && s.clinicId == state.selectedClinicId)
                              .toList();
                        }
                      }

                      // حماية من خروج قيمة الطبيب المحدد خارج عناصر القائمة المتاحة (منع AssertionError)
                      final doctorValues = doctors
                          .map<String?>((d) => (d.userId != null && (d.userId as String).isNotEmpty) ? d.userId as String : d.id as String)
                          .toSet();
                      final effectiveDoctorValue = (state.selectedDoctorId != null && doctorValues.contains(state.selectedDoctorId))
                          ? state.selectedDoctorId
                          : null;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: context.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: effectiveDoctorValue,
                            isExpanded: true,
                            hint: Text(
                              AppStrings.isArabic ? 'جميع الأطباء' : 'All Doctors',
                              style: AppTextStyles.caption(context),
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  AppStrings.isArabic ? 'جميع الأطباء' : 'All Doctors',
                                  style: AppTextStyles.caption(context),
                                ),
                              ),
                              ...doctors.map(
                                (d) {
                                  final docId = (d.userId != null && (d.userId as String).isNotEmpty) ? d.userId as String : d.id as String;
                                  return DropdownMenuItem<String?>(
                                    value: docId,
                                    child: Text(
                                      d.name,
                                      style: AppTextStyles.caption(context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ],
                            onChanged: (val) {
                              context.read<FinancialReceivablesCubit>().loadReport(
                                    resetDoctor: true,
                                    doctorId: val,
                                  );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        // فلتر نطاق التاريخ الشامل مع الخيار المخصص (Custom Range)
        ReportsDateRangeChips(
          activeRange: state.activeDateRange,
          customDateRange: state.customDateRange,
          onChanged: (range) {
            context.read<FinancialReceivablesCubit>().loadReport(range: range);
          },
          onCustomRangeSelected: (customRange) {
            context.read<FinancialReceivablesCubit>().loadReport(
                  range: ReportsDateRange.custom,
                  customDateRange: customRange,
                );
          },
        ),
        const SizedBox(height: 8),
        // فلتر نوع المستحق
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: typeFilters.map((tf) {
              final isSelected = state.typeFilter == tf.$1;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(tf.$2),
                  selected: isSelected,
                  onSelected: (_) {
                    context.read<FinancialReceivablesCubit>().setTypeFilter(tf.$1);
                  },
                  selectedColor: context.accent.withOpacity(0.2),
                  backgroundColor: context.surface,
                  labelStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    color: isSelected ? context.accent : context.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? context.accent : context.border,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DebtorsList extends StatelessWidget {
  final List<dynamic> debtors;

  const _DebtorsList({required this.debtors});

  @override
  Widget build(BuildContext context) {
    if (debtors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: EmptyState(
          title: AppStrings.isArabic ? 'لا توجد ديون معلقة' : 'No Outstanding Dues',
          subtitle: AppStrings.isArabic
              ? 'جميع المرضى قاموا بسداد كافة الفواتير والزيارات'
              : 'All patients have fully settled their invoices and visits',
          icon: Icons.check_circle_outline,
        ),
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: debtors.length,
        itemBuilder: (context, index) {
          return DebtorPatientCard(debtor: debtors[index]);
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 520,
        mainAxisExtent: 110,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: debtors.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemBuilder: (context, index) {
        return DebtorPatientCard(debtor: debtors[index]);
      },
    );
  }
}

class _DetailedOutstandingsLog extends StatelessWidget {
  final List<dynamic> debtors;

  const _DetailedOutstandingsLog({required this.debtors});

  @override
  Widget build(BuildContext context) {
    if (debtors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: EmptyState(
          title: AppStrings.isArabic ? 'لا توجد مستحقات تفصيلية' : 'No Detailed Outstandings',
          subtitle: AppStrings.isArabic
              ? 'لا توجد بيانات مستحقات تفصيلية حالياً'
              : 'No detailed outstandings available at the moment',
          icon: Icons.receipt_long_outlined,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: debtors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = debtors[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.patientName,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${d.totalDue.toStringAsFixed(0)} ${AppStrings.egp}',
                    style: AppTextStyles.dataNumeric(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${AppStrings.isArabic ? "فواتير غير مسددة" : "Pending Invoices"}: ${d.issuedPendingAmount.toStringAsFixed(0)} ${AppStrings.egp} | ${AppStrings.isArabic ? "زيارات معلقة" : "Unbilled Visits"}: ${d.unbilledAmount.toStringAsFixed(0)} ${AppStrings.egp}',
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
