import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_error_widget.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_state.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/all_prescriptions_cubit.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/all_prescriptions_state.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/all_prescriptions_card.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescriptions_filter_bar.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescriptions_search_bar.dart';

class AllPrescriptionsScreen extends StatefulWidget {
  const AllPrescriptionsScreen({super.key});

  @override
  State<AllPrescriptionsScreen> createState() => _AllPrescriptionsScreenState();
}

class _AllPrescriptionsScreenState extends State<AllPrescriptionsScreen> {
  late final AllPrescriptionsCubit _cubit;
  String _clinicId = '';
  String _doctorId = '';
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<AllPrescriptionsCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryLoadPrescriptions();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _tryLoadPrescriptions({String? forceClinicId, String? forceDoctorId}) {
    final settingsState = context.read<SettingsCubit>().state;
    final newClinicId = forceClinicId ??
        settingsState.clinicEntity?.id ??
        AppConstants.activeClinicId;
    final newDoctorId = forceDoctorId ??
        settingsState.doctorEntity?.id ??
        '';

    final hasChanges = newClinicId != _clinicId || newDoctorId != _doctorId;
    if (_hasLoaded && !hasChanges) return;
    if (newClinicId.isEmpty) return;

    _clinicId = newClinicId;
    _doctorId = newDoctorId;
    _hasLoaded = true;

    _cubit.loadPrescriptions(
      clinicId: _clinicId,
      doctorId: _doctorId.isNotEmpty ? _doctorId : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.clinicEntity?.id != current.clinicEntity?.id ||
            previous.doctorEntity?.id != current.doctorEntity?.id,
        listener: (context, settingsState) {
          if (settingsState.clinicEntity != null) {
            _tryLoadPrescriptions(
              forceClinicId: settingsState.clinicEntity!.id,
              forceDoctorId: settingsState.doctorEntity?.id,
            );
          }
        },
        child: Scaffold(
          backgroundColor: context.background,
          appBar: AppBar(
            backgroundColor: context.surface,
            elevation: 0,
            title: Text(
              AppStrings.allPrescriptions,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: AppStrings.refresh,
                onPressed: () => _cubit.refresh(),
              ),
            ],
          ),
          body: _AllPrescriptionsBody(cubit: _cubit),
        ),
      ),
    );
  }
}

class _AllPrescriptionsBody extends StatelessWidget {
  final AllPrescriptionsCubit cubit;

  const _AllPrescriptionsBody({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllPrescriptionsCubit, AllPrescriptionsState>(
      builder: (context, state) {
        if (state is AllPrescriptionsLoading ||
            state is AllPrescriptionsInitial) {
          return const Padding(
            padding: EdgeInsets.all(AppConstants.screenEdgeH),
            child: ShimmerList(itemCount: 6),
          );
        }

        if (state is AllPrescriptionsError) {
          return Center(
            child: AppErrorWidget(
              message: state.message,
              onRetry: () => cubit.refresh(),
            ),
          );
        }

        if (state is AllPrescriptionsLoaded) {
          final prescriptions = state.filteredPrescriptions;
          final totalCount = state.allPrescriptions.length;

          return RefreshIndicator(
            onRefresh: () => cubit.refresh(),
            color: context.primary,
            child: ResponsiveHelper.responsiveCenter(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.screenEdgeH),
                children: [
                  // ─── حقل البحث ───
                  PrescriptionsSearchBar(
                    initialValue: state.searchQuery,
                    onChanged: (q) => cubit.search(q),
                  ),
                  const SizedBox(height: 12),

                  // ─── فلاتر التاريخ ───
                  PrescriptionsFilterBar(
                    selectedFilter: state.selectedDateFilter,
                    onFilterSelected: (filter) => cubit.setDateFilter(filter),
                  ),
                  const SizedBox(height: 14),

                  // ─── شريط معلومات الإجمالي ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.prescriptionsTotalCount(prescriptions.length),
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state.searchQuery.isNotEmpty ||
                          state.selectedDateFilter != PrescriptionDateFilter.all)
                        Text(
                          '${AppStrings.filterAll}: $totalCount',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ─── قائمة الروشتات أو حالة الفراغ ───
                  if (prescriptions.isEmpty)
                    _buildEmptyState(context, state)
                  else
                    ...prescriptions.map(
                      (p) => AllPrescriptionsCard(prescription: p),
                    ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AllPrescriptionsLoaded state) {
    final bool isFiltered = state.searchQuery.isNotEmpty ||
        state.selectedDateFilter != PrescriptionDateFilter.all;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_liquid_outlined,
                size: 56,
                color: context.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? AppStrings.noPrescriptionsFound
                  : AppStrings.noPrescriptionsYet,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? AppStrings.searchPrescriptionsHint
                  : AppStrings.allPrescriptionsSubtitle,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
