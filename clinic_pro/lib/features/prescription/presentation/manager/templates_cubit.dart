// ────────────────────────────────────────────────────────
// Cubit قوالب الروشتات — إدارة القوالب وتطبيقها ومحاكاتها
// يتعامل مع ICloudService لجلب وإدارة البيانات
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/i_cloud_service.dart';
import 'templates_state.dart';

@injectable
class TemplatesCubit extends Cubit<TemplatesState> {
  final ICloudService _cloudService;

  TemplatesCubit(this._cloudService) : super(TemplatesInitial());

  /// تحميل جميع قوالب الروشتات من الخدمة السحابية
  Future<void> loadTemplates() async {
    emit(TemplatesLoading());

    try {
      final rawTemplates = await _cloudService.select(
        table: 'prescription_templates',
      );

      final List<Map<String, dynamic>> templates = [];
      for (final t in rawTemplates) {
        final items = await _cloudService.select(
          table: 'prescription_template_items',
          eq: {'template_id': t['id']},
        );
        
        final List<Map<String, dynamic>> itemsWithDrugs = [];
        for (final item in items) {
          final drugs = await _cloudService.select(
            table: 'drugs',
            eq: {'id': item['drug_id']},
          );
          final drug = drugs.isNotEmpty ? drugs.first : {'trade_name': 'دواء غير معروف', 'generic_name': ''};
          itemsWithDrugs.add({
            ...item,
            'trade_name': drug['trade_name'],
            'generic_name': drug['generic_name'],
          });
        }
        
        templates.add({...t, 'items': itemsWithDrugs});
      }

      emit(TemplatesLoaded(templates: templates));
    } catch (_) {
      emit(const TemplatesError('تعذّر تحميل القوالب'));
    }
  }

  /// تصفية القوالب بالبحث النصي (محلي على الـ state)
  void search(String query) {
    if (state is TemplatesLoaded) {
      final loaded = state as TemplatesLoaded;
      emit(loaded.copyWith(searchQuery: query.isEmpty ? null : query));
    }
  }

  /// تصفية القوالب بالتصنيف (محلي على الـ state)
  void filterByCategory(String? category) {
    if (state is TemplatesLoaded) {
      final loaded = state as TemplatesLoaded;
      emit(loaded.copyWith(selectedCategory: category));
    }
  }

  /// إضافة قالب روشتة جديد مع أدويته عبر الخدمة السحابية
  Future<void> addTemplate(String name, List<Map<String, dynamic>> drugs) async {
    if (state is! TemplatesLoaded) return;
    final loaded = state as TemplatesLoaded;

    try {
      // إدخال القالب الأساسي
      final newTemplate = await _cloudService.insert(
        table: 'prescription_templates',
        data: {
          'doctor_id': 'u-doc-1',
          'name': name,
          'user_count': 0,
        },
      );

      // إدخال أدوية القالب المرتبطة
      for (final drug in drugs) {
        await _cloudService.insert(
          table: 'prescription_template_items',
          data: {
            'template_id': newTemplate['id'],
            'drug_id': drug['drug_id'],
            'frequency': drug['frequency'],
            'duration': drug['duration'],
            'timing': drug['timing'],
            'is_prn': drug['is_prn'] ?? false,
          },
        );
      }

      emit(loaded.copyWith(templates: [...loaded.templates, newTemplate]));
    } catch (_) {
      emit(const TemplatesError('تعذّر إضافة القالب'));
    }
  }

  /// حذف قالب وجميع أدويته المرتبطة من الخدمة السحابية
  Future<void> deleteTemplate(String id) async {
    if (state is! TemplatesLoaded) return;
    final loaded = state as TemplatesLoaded;

    try {
      // حذف أدوية القالب أولاً
      await _cloudService.delete(
        table: 'prescription_template_items',
        matchColumn: 'template_id',
        matchValue: id,
      );

      // حذف القالب نفسه
      await _cloudService.delete(
        table: 'prescription_templates',
        matchColumn: 'id',
        matchValue: id,
      );

      final updatedList = loaded.templates.where((t) => t['id'] != id).toList();
      emit(loaded.copyWith(templates: updatedList));
    } catch (_) {
      emit(const TemplatesError('تعذّر حذف القالب'));
    }
  }

  /// تعديل قالب روشتة موجود وتحديث قائمة أدويته عبر الخدمة السحابية
  Future<void> editTemplate(String id, String name, List<Map<String, dynamic>> drugs) async {
    if (state is! TemplatesLoaded) return;
    final loaded = state as TemplatesLoaded;

    try {
      // تحديث بيانات القالب الأساسية
      await _cloudService.update(
        table: 'prescription_templates',
        data: {'name': name},
        matchColumn: 'id',
        matchValue: id,
      );

      // حذف الأدوية القديمة المرتبطة بهذا القالب
      await _cloudService.delete(
        table: 'prescription_template_items',
        matchColumn: 'template_id',
        matchValue: id,
      );

      // إدخال الأدوية الجديدة المرتبطة بالقالب المعدل
      for (final drug in drugs) {
        await _cloudService.insert(
          table: 'prescription_template_items',
          data: {
            'template_id': id,
            'drug_id': drug['drug_id'],
            'frequency': drug['frequency'],
            'duration': drug['duration'],
            'timing': drug['timing'],
            'is_prn': drug['is_prn'] ?? false,
          },
        );
      }

      // إعادة تحميل القوالب لضمان تطابق البيانات
      await loadTemplates();
    } catch (_) {
      emit(const TemplatesError('تعذّر تعديل القالب'));
    }
  }
}
