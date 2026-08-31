// ────────────────────────────────────────────────────────
// حالات شاشة كل الروشتات (AllPrescriptionsState)
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../domain/entities/prescription_entity.dart';

enum PrescriptionDateFilter {
  all,
  today,
  thisWeek,
  thisMonth,
}

abstract class AllPrescriptionsState extends Equatable {
  const AllPrescriptionsState();

  @override
  List<Object?> get props => [];
}

class AllPrescriptionsInitial extends AllPrescriptionsState {
  const AllPrescriptionsInitial();
}

class AllPrescriptionsLoading extends AllPrescriptionsState {
  const AllPrescriptionsLoading();
}

class AllPrescriptionsLoaded extends AllPrescriptionsState {
  final List<PrescriptionEntity> allPrescriptions;
  final List<PrescriptionEntity> filteredPrescriptions;
  final String searchQuery;
  final PrescriptionDateFilter selectedDateFilter;

  const AllPrescriptionsLoaded({
    required this.allPrescriptions,
    required this.filteredPrescriptions,
    this.searchQuery = '',
    this.selectedDateFilter = PrescriptionDateFilter.all,
  });

  AllPrescriptionsLoaded copyWith({
    List<PrescriptionEntity>? allPrescriptions,
    List<PrescriptionEntity>? filteredPrescriptions,
    String? searchQuery,
    PrescriptionDateFilter? selectedDateFilter,
  }) {
    return AllPrescriptionsLoaded(
      allPrescriptions: allPrescriptions ?? this.allPrescriptions,
      filteredPrescriptions:
          filteredPrescriptions ?? this.filteredPrescriptions,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
    );
  }

  @override
  List<Object?> get props => [
        allPrescriptions,
        filteredPrescriptions,
        searchQuery,
        selectedDateFilter,
      ];
}

class AllPrescriptionsError extends AllPrescriptionsState {
  final String message;

  const AllPrescriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}
