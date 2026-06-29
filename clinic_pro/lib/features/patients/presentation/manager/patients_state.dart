// ────────────────────────────────────────────────────────
// حالات شاشة المرضى — نماذج PatientItem و PatientVisit و PatientPrescriptionRecord
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// فلاتر قائمة المرضى — مطابقة لـ Stitch
enum PatientsFilter { all, today, thisWeek, chronic }

/// نموذج مريض للعرض (UI Phase — Mock)
class PatientItem extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String gender;
  final String? birthDate;
  final String? bloodType;
  final String? email;
  final String? address;
  final String? emergencyContact;
  final String allergies;
  final String chronicConditions;
  final bool isChronic;
  final String lastVisitLabel;
  final String? lastVisitDate;
  final String statusTag;

  const PatientItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    this.birthDate,
    this.bloodType,
    this.email,
    this.address,
    this.emergencyContact,
    required this.allergies,
    required this.chronicConditions,
    this.isChronic = false,
    required this.lastVisitLabel,
    this.lastVisitDate,
    this.statusTag = 'follow_up',
  });

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0];
    return '${parts.first[0]}${parts.last[0]}';
  }

  bool get hasAllergies =>
      allergies.isNotEmpty && allergies != 'لا يوجد';

  PatientItem copyWith({
    String? name,
    String? phone,
    String? gender,
    String? birthDate,
    String? bloodType,
    String? email,
    String? address,
    String? emergencyContact,
    String? allergies,
    String? chronicConditions,
    bool? isChronic,
  }) {
    return PatientItem(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      isChronic: isChronic ?? this.isChronic,
      lastVisitLabel: lastVisitLabel,
      lastVisitDate: lastVisitDate,
      statusTag: statusTag,
    );
  }

  @override
  List<Object?> get props => [id, name, phone];
}

class PatientVisitItem extends Equatable {
  final String id;
  final String title;
  final String displayDate;
  final String description;
  final String doctorName;

  const PatientVisitItem({
    required this.id,
    required this.title,
    required this.displayDate,
    required this.description,
    required this.doctorName,
  });

  @override
  List<Object?> get props => [id];
}

class PatientPrescriptionRecordItem extends Equatable {
  final String id;
  final String title;
  final String displayDate;
  final String doctorName;

  const PatientPrescriptionRecordItem({
    required this.id,
    required this.title,
    required this.displayDate,
    required this.doctorName,
  });

  @override
  List<Object?> get props => [id];
}

abstract class PatientsState extends Equatable {
  const PatientsState();

  @override
  List<Object?> get props => [];
}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final List<PatientItem> allPatients;
  final String searchQuery;
  final PatientsFilter activeFilter;

  const PatientsLoaded({
    required this.allPatients,
    this.searchQuery = '',
    this.activeFilter = PatientsFilter.all,
  });

  List<PatientItem> get filteredPatients {
    var list = allPatients;

    if (searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.contains(searchQuery) || p.phone.contains(searchQuery))
          .toList();
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    switch (activeFilter) {
      case PatientsFilter.all:
        break;
      case PatientsFilter.today:
        list = list.where((p) => p.lastVisitDate == today).toList();
      case PatientsFilter.thisWeek:
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        list = list.where((p) {
          if (p.lastVisitDate == null) return false;
          final d = DateTime.tryParse(p.lastVisitDate!);
          return d != null && d.isAfter(weekAgo);
        }).toList();
      case PatientsFilter.chronic:
        list = list.where((p) => p.isChronic).toList();
    }

    return list;
  }

  PatientsLoaded copyWith({
    List<PatientItem>? allPatients,
    String? searchQuery,
    PatientsFilter? activeFilter,
  }) {
    return PatientsLoaded(
      allPatients: allPatients ?? this.allPatients,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [allPatients, searchQuery, activeFilter];
}

class PatientsError extends PatientsState {
  final String message;

  const PatientsError(this.message);

  @override
  List<Object?> get props => [message];
}
