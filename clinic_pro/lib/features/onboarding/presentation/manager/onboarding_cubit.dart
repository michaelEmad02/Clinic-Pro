import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());

  Future<void> selectPlan(String planType) async {
    emit(OnboardingLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(OnboardingPlanSelected());
  }

  Future<void> createClinic({
    required String name,
    required String address,
    required String phone,
    required bool isDoctor,
  }) async {
    emit(OnboardingLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(OnboardingClinicCreated());
  }

  Future<void> inviteStaff(List<String> emails) async {
    emit(OnboardingLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(OnboardingStaffInvited());
  }
}
