import 'package:equatable/equatable.dart';

abstract class DrugsState extends Equatable {
  const DrugsState();

  @override
  List<Object?> get props => [];
}

class DrugsInitial extends DrugsState {}

class DrugsLoading extends DrugsState {}

class DrugsLoaded extends DrugsState {
  final List<Map<String, dynamic>> drugs;
  final String? searchQuery;
  final String? selectedCategory;

  const DrugsLoaded({
    required this.drugs,
    this.searchQuery,
    this.selectedCategory,
  });

  DrugsLoaded copyWith({
    List<Map<String, dynamic>>? drugs,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return DrugsLoaded(
      drugs: drugs ?? this.drugs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [drugs, searchQuery, selectedCategory];
}

class DrugsError extends DrugsState {
  final String message;

  const DrugsError(this.message);

  @override
  List<Object?> get props => [message];
}
