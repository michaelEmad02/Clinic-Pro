import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/drug_entity.dart';
import '../../domain/usecases/drugs_usecases.dart';
import 'drugs_state.dart';

@injectable
class DrugsCubit extends Cubit<DrugsState> {
  final GetDrugsUseCase _getDrugsUseCase;
  final AddDrugUseCase _addDrugUseCase;
  final UpdateDrugUseCase _updateDrugUseCase;
  final DeleteDrugUseCase _deleteDrugUseCase;

  DrugsCubit(
    this._getDrugsUseCase,
    this._addDrugUseCase,
    this._updateDrugUseCase,
    this._deleteDrugUseCase,
  ) : super(DrugsInitial());

  /// تحميل جميع الأدوية من الخدمة السحابية
  Future<void> loadDrugs() async {
    emit(DrugsLoading());

    final result = await _getDrugsUseCase();

    result.fold(
      (failure) => emit(DrugsError(failure.message)),
      (drugsList) {
        final List<Map<String, dynamic>> drugsRaw = drugsList.map((d) {
          return {
            'id': d.id,
            'trade_name': d.tradeName,
            'generic_name': d.genericName,
            'category': d.category,
          };
        }).toList();

        emit(DrugsLoaded(drugs: drugsRaw));
      },
    );
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

    final drug = DrugEntity(
      id: '',
      tradeName: tradeName,
      genericName: genericName,
      category: category,
    );

    final result = await _addDrugUseCase(drug);

    result.fold(
      (failure) => emit(DrugsError(failure.message)),
      (newDrug) {
        final newDrugRaw = {
          'id': newDrug.id,
          'trade_name': newDrug.tradeName,
          'generic_name': newDrug.genericName,
          'category': newDrug.category,
        };
        emit(loaded.copyWith(drugs: [...loaded.drugs, newDrugRaw]));
      },
    );
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

    final drug = DrugEntity(
      id: id,
      tradeName: tradeName,
      genericName: genericName,
      category: category,
    );

    final result = await _updateDrugUseCase(drug);

    result.fold(
      (failure) => emit(DrugsError(failure.message)),
      (_) {
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
      },
    );
  }

  /// حذف دواء من الخدمة السحابية
  Future<void> deleteDrug(String id) async {
    if (state is! DrugsLoaded) return;
    final loaded = state as DrugsLoaded;

    final result = await _deleteDrugUseCase(id);

    result.fold(
      (failure) => emit(DrugsError(failure.message)),
      (_) {
        final updatedList = loaded.drugs.where((d) => d['id'] != id).toList();
        emit(loaded.copyWith(drugs: updatedList));
      },
    );
  }
}
