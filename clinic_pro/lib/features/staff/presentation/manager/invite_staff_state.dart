import 'package:equatable/equatable.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/entities/staff_entity.dart';

abstract class InviteStaffState extends Equatable {
  const InviteStaffState();

  @override
  List<Object?> get props => [];
}

class InviteStaffInitial extends InviteStaffState {}

class InviteStaffLoading extends InviteStaffState {}

class InviteStaffError extends InviteStaffState {
  final String message;

  const InviteStaffError(this.message);

  @override
  List<Object?> get props => [message];
}

class InviteStaffLoaded extends InviteStaffState {
  final List<StaffEntity> doctors;
  final String? selectedClinicId;
  final String? selectedDoctorId;
  final StaffRoles selectedRole;
  final List<InvitationEntity> invitedStaff;
  final bool isSubmitting;
  final bool isSuccess;
  final String? submitErrorMessage;

  const InviteStaffLoaded({
    required this.doctors,
    this.selectedClinicId,
    this.selectedDoctorId,
    this.selectedRole = StaffRoles.doctor,
    this.invitedStaff = const [],
    this.isSubmitting = false,
    this.isSuccess = false,
    this.submitErrorMessage,
  });

  InviteStaffLoaded copyWith({
    List<StaffEntity>? doctors,
    String? selectedClinicId,
    String? selectedDoctorId,
    StaffRoles? selectedRole,
    List<InvitationEntity>? invitedStaff,
    bool? isSubmitting,
    bool? isSuccess,
    String? submitErrorMessage,
  }) {
    return InviteStaffLoaded(
      doctors: doctors ?? this.doctors,
      selectedClinicId: selectedClinicId ?? this.selectedClinicId,
      selectedDoctorId: selectedDoctorId ?? this.selectedDoctorId,
      selectedRole: selectedRole ?? this.selectedRole,
      invitedStaff: invitedStaff ?? this.invitedStaff,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      submitErrorMessage: submitErrorMessage, // can be cleared
    );
  }

  @override
  List<Object?> get props => [
        doctors,
        selectedClinicId,
        selectedDoctorId,
        selectedRole,
        invitedStaff,
        isSubmitting,
        isSuccess,
        submitErrorMessage,
      ];
}
