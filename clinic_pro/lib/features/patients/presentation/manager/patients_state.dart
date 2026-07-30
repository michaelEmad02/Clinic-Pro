// ────────────────────────────────────────────────────────
// حالات شاشة المرضى — تستخدم PatientEntity من طبقة الدومين
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../domain/entities/patient_entity.dart';

/// فلاتر قائمة المرضى — مطابقة لـ Stitch
enum PatientsFilter { all, today, thisWeek, chronic }

/// نموذج سجل روشتة مريض (مؤقت حتى بناء طبقة الدومين الخاصة بـ Prescription Feature)
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

// ───────────── حالات شاشة قائمة المرضى ─────────────

abstract class PatientsState extends Equatable {
  const PatientsState();

  @override
  List<Object?> get props => [];
}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final List<PatientEntity> allPatients;
  final String searchQuery;
  final PatientsFilter activeFilter;

  const PatientsLoaded({
    required this.allPatients,
    this.searchQuery = '',
    this.activeFilter = PatientsFilter.all,
  });

  /// قائمة المرضى بعد تطبيق البحث والفلاتر
  List<PatientEntity> get filteredPatients {
    var list = allPatients;

    // تطبيق البحث بالاسم أو الهاتف
    if (searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.contains(searchQuery) ||
              (p.phone != null && p.phone!.contains(searchQuery)))
          .toList();
    }

    // تطبيق الفلتر النشط
    switch (activeFilter) {
      case PatientsFilter.all:
        break;
      case PatientsFilter.today:
        break;
      case PatientsFilter.thisWeek:
        break;
      case PatientsFilter.chronic:
        list = list.where((p) => p.isChronic).toList();
    }

    return list;
  }

  PatientsLoaded copyWith({
    List<PatientEntity>? allPatients,
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
