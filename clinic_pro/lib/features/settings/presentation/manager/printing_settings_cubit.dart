// ────────────────────────────────────────────────────────
// PrintingSettingsCubit — Cubit إدارة وتحميل وحفظ إعدادات طباعة المالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:clinic_pro/features/settings/domain/usecases/get_owner_printing_settings_usecase.dart';
import 'package:clinic_pro/features/settings/domain/usecases/save_owner_printing_settings_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'printing_settings_state.dart';

@injectable
class PrintingSettingsCubit extends Cubit<PrintingSettingsState> {
  final GetOwnerPrintingSettingsUseCase _getOwnerPrintingSettingsUseCase;
  final SaveOwnerPrintingSettingsUseCase _saveOwnerPrintingSettingsUseCase;

  PrintingSettingsCubit(
    this._getOwnerPrintingSettingsUseCase,
    this._saveOwnerPrintingSettingsUseCase,
  ) : super(const PrintingSettingsState());

  /// تحميل إعدادات الطباعة الحالية للمالك
  Future<void> loadPrintingSettings(String ownerId) async {
    emit(state.copyWith(status: PrintingSettingsStatus.loading));

    final result = await _getOwnerPrintingSettingsUseCase(ownerId, true);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PrintingSettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: PrintingSettingsStatus.success,
        settings: settings,
      )),
    );
  }

  /// تحديث وتفعيل الخيارات في الواجهة المباشرة
  void updateDraft(PrintingSettingsEntity updated) {
    emit(state.copyWith(
      status: PrintingSettingsStatus.success,
      settings: updated,
    ));
  }

  /// حفظ إعدادات الطباعة النهائية بـ Supabase
  Future<bool> savePrintingSettings(String ownerId) async {
    emit(state.copyWith(status: PrintingSettingsStatus.saving));

    final result = await _saveOwnerPrintingSettingsUseCase(
      ownerId: ownerId,
      settings: state.settings,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: PrintingSettingsStatus.error,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(status: PrintingSettingsStatus.saved));
        return true;
      },
    );
  }
}
