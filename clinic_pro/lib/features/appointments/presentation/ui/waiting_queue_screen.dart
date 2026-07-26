// ────────────────────────────────────────────────────────
// شاشة طابور الانتظار — للطبيب والسكرتيرة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import '../../../auth/presentation/manager/auth_state.dart';
import '../../../settings/presentation/manager/settings_cubit.dart';
import '../../../settings/presentation/manager/settings_state.dart';
import '../manager/waiting_queue_cubit.dart';
import '../manager/waiting_queue_state.dart';
import 'widgets/call_next_button.dart';
import 'widgets/queue_list.dart';

class WaitingQueueScreen extends StatefulWidget {
  const WaitingQueueScreen({super.key});

  @override
  State<WaitingQueueScreen> createState() => _WaitingQueueScreenState();
}

class _WaitingQueueScreenState extends State<WaitingQueueScreen> {
  late final WaitingQueueCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<WaitingQueueCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryLoadQueue();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _tryLoadQueue() {
    final authState = context.read<AuthCubit>().state;
    final settingsState = context.read<SettingsCubit>().state;
    String doctorId = '';
    String doctorName = '';
    final clinicId =
        settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;

    if (authState is AuthAuthenticated) {
      final currentUser = authState.user;
      if (currentUser.role == StaffRoles.doctor) {
        doctorId = currentUser.id;
        doctorName = currentUser.name;
      } else {
        doctorId = settingsState.currentDoctorId ?? '';
        doctorName = settingsState.currentDoctorName ?? '';
      }
    }

    if (doctorId.isNotEmpty && clinicId.isNotEmpty) {
      _cubit.loadQueue(
        doctorId: doctorId,
        clinicId: clinicId,
        doctorName: doctorName.isNotEmpty
            ? doctorName
            : AppStrings.treatingDoctor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
      ],
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.currentDoctorId != current.currentDoctorId ||
            previous.clinicEntity?.id != current.clinicEntity?.id,
        listener: (context, state) {
          _tryLoadQueue();
        },
        child: _WaitingQueueBody(onRefresh: _tryLoadQueue),
      ),
    );
  }
}

class _WaitingQueueBody extends StatelessWidget {
  final VoidCallback onRefresh;
  const _WaitingQueueBody({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: BlocBuilder<WaitingQueueCubit, WaitingQueueState>(
          builder: (context, state) {
            final subtitle =
                state is WaitingQueueLoaded ? state.doctorName : '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.waitingQueueTitle,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primary,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                    ),
                  ),
              ],
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: BlocBuilder<WaitingQueueCubit, WaitingQueueState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType || previous != current,
        builder: (context, state) {
          if (state is WaitingQueueLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 4),
            );
          }
          if (state is WaitingQueueError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRefresh,
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is WaitingQueueLoaded) {
            final hasNext = state.queue.any((p) => p.status == 'confirmed');

            return RefreshIndicator(
              onRefresh: () async {
                onRefresh();
                await Future.delayed(const Duration(milliseconds: 200));
              },
              child: ResponsiveHelper.responsiveCenter(
                maxWidth: 900,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    CallNextButton(
                      enabled: hasNext,
                      onPressed: () {
                        context.read<WaitingQueueCubit>().callNext();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppStrings.patientCalled)),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    QueueList(
                      queue: state.queue,
                      onCallPatient: (id) {
                        context.read<WaitingQueueCubit>().callPatient(id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppStrings.patientCalledDetails)),
                        );
                      },
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
