import 'package:equatable/equatable.dart';

class _Sentinel {
  const _Sentinel();
}

abstract class TemplatesState extends Equatable {
  const TemplatesState();

  @override
  List<Object?> get props => [];
}

class TemplatesInitial extends TemplatesState {}

class TemplatesLoading extends TemplatesState {}

class TemplatesLoaded extends TemplatesState {
  final List<Map<String, dynamic>> templates;
  final String? searchQuery;
  final String? selectedCategory;

  const TemplatesLoaded({
    required this.templates,
    this.searchQuery,
    this.selectedCategory,
  });

  TemplatesLoaded copyWith({
    List<Map<String, dynamic>>? templates,
    Object? searchQuery = _null,
    Object? selectedCategory = _null,
  }) {
    return TemplatesLoaded(
      templates: templates ?? this.templates,
      searchQuery: identical(searchQuery, _null) ? this.searchQuery : searchQuery as String?,
      selectedCategory: identical(selectedCategory, _null) ? this.selectedCategory : selectedCategory as String?,
    );
  }

  static const _null = _Sentinel();

  @override
  List<Object?> get props => [templates, searchQuery, selectedCategory];
}

class TemplatesError extends TemplatesState {
  final String message;

  const TemplatesError(this.message);

  @override
  List<Object?> get props => [message];
}
