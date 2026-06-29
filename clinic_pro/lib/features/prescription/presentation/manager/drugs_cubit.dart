// ────────────────────────────────────────────────────────
// Cubit إدارة الأدوية — تحميل الأدوية وتعديلها وإضافتها
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'drugs_state.dart';

class DrugsCubit extends Cubit<DrugsState> {
  DrugsCubit() : super(DrugsInitial());

  Future<void> loadDrugs() async {
    emit(DrugsLoading());
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      emit(DrugsLoaded(drugs: List.from(MockData.drugs)));
    } catch (_) {
      emit(const DrugsError('تعذّر تحميل الأدوية'));
    }
  }

  void search(String query) {
    if (state is DrugsLoaded) {
      final loaded = state as DrugsLoaded;
      emit(loaded.copyWith(searchQuery: query.isEmpty ? null : query));
    }
  }

  void selectCategory(String? category) {
    if (state is DrugsLoaded) {
      final loaded = state as DrugsLoaded;
      emit(loaded.copyWith(selectedCategory: category));
    }
  }

  Future<void> addDrug({
    required String tradeName,
    required String genericName,
    required String category,
    required String form,
    required int stockCount,
  }) async {
    if (state is! DrugsLoaded) return;
    final loaded = state as DrugsLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final newDrug = {
      'id': 'd-new-${DateTime.now().millisecondsSinceEpoch}',
      'trade_name': tradeName,
      'generic_name': genericName,
      'category': category,
      'form': form,
      'stock_count': stockCount,
      'stock_status': stockCount > 20 ? 'متوفر' : 'مخزون منخفض',
    };

    MockData.drugs.add(newDrug);
    emit(loaded.copyWith(drugs: [...loaded.drugs, newDrug]));
  }

  Future<void> updateDrug({
    required String id,
    required String tradeName,
    required String genericName,
    required String category,
    required String form,
    required int stockCount,
  }) async {
    if (state is! DrugsLoaded) return;
    final loaded = state as DrugsLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list = loaded.drugs.map((d) {
      if (d['id'] == id) {
        return {
          'id': id,
          'trade_name': tradeName,
          'generic_name': genericName,
          'category': category,
          'form': form,
          'stock_count': stockCount,
          'stock_status': stockCount > 20 ? 'متوفر' : 'مخزون منخفض',
        };
      }
      return d;
    }).toList();

    // تحديث قاعدة البيانات للمحاكاة
    for (int i = 0; i < MockData.drugs.length; i++) {
      if (MockData.drugs[i]['id'] == id) {
        MockData.drugs[i] = {
          'id': id,
          'trade_name': tradeName,
          'generic_name': genericName,
          'category': category,
          'form': form,
          'stock_count': stockCount,
          'stock_status': stockCount > 20 ? 'متوفر' : 'مخزون منخفض',
        };
      }
    }

    emit(loaded.copyWith(drugs: list));
  }

  Future<void> deleteDrug(String id) async {
    if (state is! DrugsLoaded) return;
    final loaded = state as DrugsLoaded;
    await Future.delayed(const Duration(milliseconds: 200));

    MockData.drugs.removeWhere((d) => d['id'] == id);
    final updatedList = loaded.drugs.where((d) => d['id'] != id).toList();
    emit(loaded.copyWith(drugs: updatedList));
  }
}
