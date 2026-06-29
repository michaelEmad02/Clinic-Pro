// ────────────────────────────────────────────────────────
// حالات شاشة العيادات — نموذج ClinicItem
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class ClinicItem extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String? logoUrl;
  final bool isActive;
  final int totalPatients;
  final int patientsChange;
  final int todayAppointments;
  final int todayRemaining;
  final int doctorsCount;
  final int doctorsOnLeave;
  final double rating;
  final int totalReviews;
  final double monthlyRevenue;

  const ClinicItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.logoUrl,
    this.isActive = true,
    this.totalPatients = 0,
    this.patientsChange = 0,
    this.todayAppointments = 0,
    this.todayRemaining = 0,
    this.doctorsCount = 0,
    this.doctorsOnLeave = 0,
    this.rating = 0,
    this.totalReviews = 0,
    this.monthlyRevenue = 0,
  });

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.first[0];
  }

  ClinicItem copyWith({
    String? name,
    String? phone,
    String? address,
    String? logoUrl,
    bool? isActive,
  }) {
    return ClinicItem(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      totalPatients: totalPatients,
      patientsChange: patientsChange,
      todayAppointments: todayAppointments,
      todayRemaining: todayRemaining,
      doctorsCount: doctorsCount,
      doctorsOnLeave: doctorsOnLeave,
      rating: rating,
      totalReviews: totalReviews,
      monthlyRevenue: monthlyRevenue,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}

abstract class ClinicsState extends Equatable {
  const ClinicsState();

  @override
  List<Object?> get props => [];
}

class ClinicsInitial extends ClinicsState {}

class ClinicsLoading extends ClinicsState {}

class ClinicsLoaded extends ClinicsState {
  final List<ClinicItem> clinics;

  const ClinicsLoaded({required this.clinics});

  @override
  List<Object?> get props => [clinics];
}

class ClinicsError extends ClinicsState {
  final String message;

  const ClinicsError(this.message);

  @override
  List<Object?> get props => [message];
}
