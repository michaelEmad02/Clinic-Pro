import 'package:equatable/equatable.dart';

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
    String? searchQuery,
    String? selectedCategory,
  }) {
    return TemplatesLoaded(
      templates: templates ?? this.templates,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [templates, searchQuery, selectedCategory];
}

class TemplatesError extends TemplatesState {
  final String message;

  const TemplatesError(this.message);

  @override
  List<Object?> get props => [message];
}
