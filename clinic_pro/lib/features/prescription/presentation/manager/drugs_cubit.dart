// ────────────────────────────────────────────────────────
// Cubit إدارة الأدوية — تحميل الأدوية وتعديلها وإضافتها
// يتعامل مع ICloudService لجلب وإدارة البيانات
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/services/i_cloud_service.dart';
import 'drugs_state.dart';

@injectable
class DrugsCubit extends Cubit<DrugsState> {
  final ICloudService _cloudService;

  DrugsCubit(this._cloudService) : super(DrugsInitial());

  /// تحميل جميع الأدوية من الخدمة السحابية
  Future<void> loadDrugs() async {
    emit(DrugsLoading());

    try {
      final drugs = await _cloudService.select(table: 'drugs');
      emit(DrugsLoaded(drugs: drugs));
    } catch (_) {
      emit(DrugsError(AppStrings.loadDrugsFailed));
    }
  }

  /// تصفية الأدوية بالبحث النصي (محلي على الـ state)
  void search(String query) {
    if (state is DrugsLoaded) {
      final loaded = state as DrugsLoaded;
      emit(loaded.copyWith(searchQuery: query.isEmpty ? null : query));
    }
  }

  /// تصفية الأدوية حسب الفئة (محلي على الـ state)
  void selectCategory(String? category) {
    if (state is DrugsLoaded) {
      final loaded = state as DrugsLoaded;
      emit(loaded.copyWith(selectedCategory: category));
    }
  }

  /// إضافة دواء جديد عبر الخدمة السحابية
  Future<void> addDrug({
    required String tradeName,
    required String genericName,
    required String category,
  }) async {
    if (state is! DrugsLoaded) return;
    final loaded = state as DrugsLoaded;

    try {
      final newDrug = await _cloudService.insert(
        table: 'drugs',
        data: {
          'trade_name': tradeName,
          'generic_name': genericName,
          'category': category,
        },
      );

      emit(loaded.copyWith(drugs: [...loaded.drugs, newDrug]));
    } catch (_) {
      emit(DrugsError(AppStrings.loadDrugsFailed));
    }
  }

  /// تعديل بيانات دواء موجود عبر الخدمة السحابية
  Future<void> updateDrug({
    required String id,
    required String tradeName,
    required String genericName,
    required String category,
  }) async {
    if (state is! DrugsLoaded) return;
    final loaded = state as DrugsLoaded;

    try {
      await _cloudService.update(
        table: 'drugs',
        data: {
          'trade_name': tradeName,
          'generic_name': genericName,
          'category': category,
        },
        matchColumn: 'id',
        matchValue: id,
      );

      // تحديث القائمة المحلية بعد نجاح التحديث
      final updatedList = loaded.drugs.map((d) {
        if (d['id'] == id) {
          return {
            ...d,
            'trade_name': tradeName,
            'generic_name': genericName,
            'category': category,
          };
        }
        return d;
      }).toList();

      emit(loaded.copyWith(drugs: updatedList));
    } catch (_) {
      emit(DrugsError(AppStrings.loadDrugsFailed));
    }
  }

  /// حذف دواء من الخدمة السحابية
  Future<void> deleteDrug(String id) async {
    if (state is! DrugsLoaded) return;
    final loaded = state as DrugsLoaded;

    try {
      await _cloudService.delete(
        table: 'drugs',
        matchColumn: 'id',
        matchValue: id,
      );

      final updatedList = loaded.drugs.where((d) => d['id'] != id).toList();
      emit(loaded.copyWith(drugs: updatedList));
    } catch (_) {
      emit(DrugsError(AppStrings.loadDrugsFailed));
    }
  }
}
