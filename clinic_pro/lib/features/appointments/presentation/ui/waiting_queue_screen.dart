// ────────────────────────────────────────────────────────
// شاشة طابور الانتظار — للطبيب والسكرتيرة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/waiting_queue_cubit.dart';
import '../manager/waiting_queue_state.dart';
import 'widgets/call_next_button.dart';
import 'widgets/queue_list.dart';

class WaitingQueueScreen extends StatelessWidget {
  const WaitingQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WaitingQueueCubit>()..loadQueue(),
      child: const _WaitingQueueBody(),
    );
  }
}

class _WaitingQueueBody extends StatelessWidget {
  const _WaitingQueueBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: BlocBuilder<WaitingQueueCubit, WaitingQueueState>(
          builder: (context, state) {
            final subtitle = state is WaitingQueueLoaded ? state.doctorName : '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.waitingQueueTitle,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
                    onPressed: () =>
                        context.read<WaitingQueueCubit>().loadQueue(),
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
                context.read<WaitingQueueCubit>().loadQueue();
                await Future.delayed(const Duration(milliseconds: 200));
              },
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
                        SnackBar(content: Text(AppStrings.patientCalledDetails)),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
