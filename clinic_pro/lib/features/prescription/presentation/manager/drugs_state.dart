import 'package:equatable/equatable.dart';

class _Sentinel {
  const _Sentinel();
}

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
    Object? searchQuery = _null,
    Object? selectedCategory = _null,
  }) {
    return DrugsLoaded(
      drugs: drugs ?? this.drugs,
      searchQuery: identical(searchQuery, _null) ? this.searchQuery : searchQuery as String?,
      selectedCategory: identical(selectedCategory, _null) ? this.selectedCategory : selectedCategory as String?,
    );
  }

  static const _null = _Sentinel();

  @override
  List<Object?> get props => [drugs, searchQuery, selectedCategory];
}

class DrugsError extends DrugsState {
  final String message;

  const DrugsError(this.message);

  @override
  List<Object?> get props => [message];
}
