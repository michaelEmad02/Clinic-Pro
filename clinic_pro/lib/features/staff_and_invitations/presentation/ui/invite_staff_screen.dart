import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/invitation_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import '../../../onboarding/presentation/manager/onboarding_cubit.dart';
import '../../../onboarding/presentation/manager/onboarding_state.dart';
import '../../../clinics/presentation/ui/widgets/progress_indicator_bar.dart';
import '../../../clinics/presentation/manager/cubit/clinics_cubit.dart';
import '../../../clinics/presentation/manager/cubit/clinics_state.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
import '../manager/invite_staff_cubit.dart';
import '../manager/invite_staff_state.dart';
import 'widgets/invite_form_row.dart';
import 'widgets/invited_staff_list.dart';

class InviteStaffScreen extends StatefulWidget {
  final bool isOnboarding;

  const InviteStaffScreen({
    super.key,
    this.isOnboarding = true,
  });

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ClinicsCubit>()..fetchClinics(ownerId),
        ),
        BlocProvider(
          create: (_) => sl<InviteStaffCubit>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<OnboardingCubit, OnboardingState>(
            listener: (context, onboardingState) {
              if (onboardingState is OnboardingStaffInvited &&
                  widget.isOnboarding) {
                context.go(RouteConstants.ownerDashboard);
              }
            },
            child: BlocListener<ClinicsCubit, ClinicsState>(
              listener: (context, clinicsState) {
                if (clinicsState is ClinicsLoaded &&
                    clinicsState.clinics.isNotEmpty) {
                  context.read<InviteStaffCubit>().loadInitialData(
                        ownerId,
                        clinicsState.clinics.first.id,
                      );
                }
              },
              child: BlocConsumer<InviteStaffCubit, InviteStaffState>(
                listener: (context, state) {
                  if (state is InviteStaffLoaded) {
                    if (state.submitErrorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.submitErrorMessage!),
                          backgroundColor: context.danger,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.read<InviteStaffCubit>().clearSubmitError();
                    }
                    if (state.isSuccess) {
                      if (widget.isOnboarding) {
                        // context.read<OnboardingCubit>().inviteStaff(
                        //       state.invitedStaff.map((e) => e.email).toList(),
                        //     );
                        context.go(RouteConstants.ownerDashboard);
                      } else {
                        context.pop();
                      }
                    }
                  }
                },
                builder: (context, state) {
                  final isLoading = state is InviteStaffLoading ||
                      (state is InviteStaffLoaded && state.isSubmitting);

                  return Scaffold(
                    backgroundColor: context.background,
                    body: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.screenEdgeH,
                            vertical: AppConstants.spaceXl,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.surface,
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusCard),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildHeader(context),
                                  if (state is InviteStaffLoading)
                                    const Padding(
                                      padding: EdgeInsets.all(AppConstants.spaceLg),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  else if (state is InviteStaffError)
                                    Padding(
                                      padding: const EdgeInsets.all(
                                          AppConstants.spaceLg),
                                      child: Column(
                                        children: [
                                          Text(
                                            state.message,
                                            style: AppTextStyles.bodyMedium(context)
                                                .copyWith(
                                              color: context.danger,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              final clinicsState = context
                                                  .read<ClinicsCubit>()
                                                  .state;
                                              if (clinicsState is ClinicsLoaded &&
                                                  clinicsState.clinics.isNotEmpty) {
                                                context
                                                    .read<InviteStaffCubit>()
                                                    .loadInitialData(
                                                      ownerId,
                                                      clinicsState.clinics.first.id,
                                                    );
                                              } else {
                                                context
                                                    .read<ClinicsCubit>()
                                                    .fetchClinics(ownerId);
                                              }
                                            },
                                            child: Text(AppStrings.retry),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (state is InviteStaffLoaded)
                                    _buildContent(context, state, ownerId),
                                  _buildFooter(context, state, isLoading, ownerId),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: context.surfaceContainerLow,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => _onSkip(context),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: context.textHint,
                    ),
                  ),
                ),
              ),
              if (widget.isOnboarding)
                const Expanded(
                  child: ProgressIndicatorBar(
                    step: 3,
                    totalSteps: 3,
                    title: '',
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            AppStrings.inviteTeam,
            style: AppTextStyles.headlineLarge(context).copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            AppStrings.inviteTeamDescription,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, InviteStaffLoaded state, String ownerId) {
    final inviteStaffCubit = context.read<InviteStaffCubit>();
    final clinicsState = context.watch<ClinicsCubit>().state;
    final clinicsList = clinicsState is ClinicsLoaded
        ? clinicsState.clinics
        : const <ClinicEntity>[];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InviteFormRow(
            nameController: _nameController,
            emailController: _emailController,
            selectedRole: state.selectedRole,
            onRoleChanged: (val) {
              if (val != null) {
                inviteStaffCubit.onRoleChanged(val);
              }
            },
            clinics: clinicsList,
            selectedClinicId: state.selectedClinicId,
            onClinicChanged: (val) {
              if (val != null) {
                inviteStaffCubit.onClinicChanged(val, ownerId);
              }
            },
            doctors: state.doctors,
            selectedDoctorId: state.selectedDoctorId,
            onDoctorChanged: (val) {
              inviteStaffCubit.onDoctorChanged(val);
            },
            onAdd: () {
              final name = _nameController.text.trim();
              final email = _emailController.text.trim();
              if (name.isEmpty) {
                _showError(context, AppStrings.enterEmployeeName);
                return;
              }
              if (email.isEmpty || !email.contains('@')) {
                _showError(context, AppStrings.enterValidEmail);
                return;
              }
              _addCurrentInvitee(context, state, ownerId);
            },
          ),
          const SizedBox(height: AppConstants.spaceLg),
          InvitedStaffList(
            items: state.invitedStaff,
            onRemove: (idx) => inviteStaffCubit.removeInvitee(idx),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, InviteStaffState state,
      bool isLoading, String ownerId) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        0,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isLoading || state is! InviteStaffLoaded
                ? null
                : () {
                    _addCurrentInvitee(context, state, ownerId);
                    context.read<InviteStaffCubit>().sendInvitations(ownerId);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: context.surfaceBright,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send, size: 20),
                      const SizedBox(width: AppConstants.spaceSm),
                      Flexible(
                        child: Text(
                          AppStrings.sendInvitations,
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: context.surfaceBright,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
          if (widget.isOnboarding) ...[
            const SizedBox(height: AppConstants.spaceSm),
            TextButton(
              onPressed: isLoading ? null : () => _onSkip(context),
              style: TextButton.styleFrom(
                foregroundColor: context.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                AppStrings.skip,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onSkip(BuildContext context) {
    if (widget.isOnboarding) {
      context.go(RouteConstants.ownerDashboard);
    } else {
      context.pop();
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: context.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// دالة مساعدة لتجميع بيانات الواجهة وإنشاء كائن الدعوة وإضافته للقائمة
  void _addCurrentInvitee(BuildContext context, InviteStaffLoaded state, String ownerId) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty || !email.contains('@')) return;

    // نقرأ حالة ClinicsCubit من الـ context التابع لـ Builder في شجرة الوجت
    final clinicsState = BlocProvider.of<ClinicsCubit>(context).state;
    final clinicsList = clinicsState is ClinicsLoaded ? clinicsState.clinics : const <ClinicEntity>[];
    if (state.selectedClinicId == null || clinicsList.isEmpty) return;

    final selectedClinic = clinicsList.firstWhere((c) => c.id == state.selectedClinicId);
    
    String? doctorName;
    if (state.selectedRole == StaffRoles.secretary && state.selectedDoctorId != null) {
      final doc = state.doctors.firstWhere((d) => d.id == state.selectedDoctorId);
      doctorName = doc.name;
    }

    final now = DateTime.now();
    final invitation = InvitationEntity(
      id: '',
      clinicId: state.selectedClinicId!,
      clinicName: selectedClinic.name,
      ownerId: ownerId,
      doctorId: state.selectedRole == StaffRoles.secretary ? state.selectedDoctorId : null,
      doctorName: doctorName,
      email: email,
      name: name,
      role: state.selectedRole,
      token: 'token-${now.millisecondsSinceEpoch}',
      status: InvitationStatus.pending,
      expiredAt: now.add(const Duration(days: 7)),
      createdAt: now,
    );

    context.read<InviteStaffCubit>().addInvitee(invitation);
    _nameController.clear();
    _emailController.clear();
  }
}
