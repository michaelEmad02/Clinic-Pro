// ────────────────────────────────────────────────────────
// Cubit قوالب الروشتات — إدارة القوالب وتطبيقها ومحاكاتها
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'templates_state.dart';

class TemplatesCubit extends Cubit<TemplatesState> {
  TemplatesCubit() : super(TemplatesInitial());

  Future<void> loadTemplates() async {
    emit(TemplatesLoading());
    await Future.delayed(const Duration(milliseconds: 450));

    try {
      emit(TemplatesLoaded(templates: List.from(MockData.prescriptionTemplates)));
    } catch (_) {
      emit(const TemplatesError('تعذّر تحميل القوالب'));
    }
  }

  void search(String query) {
    if (state is TemplatesLoaded) {
      final loaded = state as TemplatesLoaded;
      emit(loaded.copyWith(searchQuery: query.isEmpty ? null : query));
    }
  }

  void filterByCategory(String? category) {
    if (state is TemplatesLoaded) {
      final loaded = state as TemplatesLoaded;
      emit(loaded.copyWith(selectedCategory: category));
    }
  }

  Future<void> addTemplate(String title, String category, List<Map<String, dynamic>> drugs) async {
    if (state is! TemplatesLoaded) return;
    final loaded = state as TemplatesLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final newId = 'pt-new-${DateTime.now().millisecondsSinceEpoch}';
    final newTemplate = {
      'id': newId,
      'doctor_id': 'u-doc-1',
      'title': title,
      'use_count': 0,
      'category': category,
    };

    MockData.prescriptionTemplates.add(newTemplate);

    // إضافة الأدوية المرتبطة بالقالب
    for (final drug in drugs) {
      MockData.prescriptionTemplateItems.add({
        'id': 'pti-new-${DateTime.now().millisecondsSinceEpoch}',
        'template_id': newId,
        'drug_id': drug['drug_id'],
        'dose_frequency': drug['dose_frequency'] ?? 'مرة واحدة يومياً',
        'dose_duration': drug['dose_duration'] ?? '٧ أيام',
        'dose_timing': drug['dose_timing'] ?? 'بعد الأكل',
      });
    }

    emit(loaded.copyWith(templates: [...loaded.templates, newTemplate]));
  }

  Future<void> deleteTemplate(String id) async {
    if (state is! TemplatesLoaded) return;
    final loaded = state as TemplatesLoaded;
    await Future.delayed(const Duration(milliseconds: 200));

    MockData.prescriptionTemplates.removeWhere((t) => t['id'] == id);
    MockData.prescriptionTemplateItems.removeWhere((item) => item['template_id'] == id);

    final updatedList = loaded.templates.where((t) => t['id'] != id).toList();
    emit(loaded.copyWith(templates: updatedList));
  }
}
