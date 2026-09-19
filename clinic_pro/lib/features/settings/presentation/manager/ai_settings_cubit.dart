// ────────────────────────────────────────────────────────
// AiSettingsCubit — مدير حالة وتفاعلات إعدادات الذكاء الاصطناعي
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/ai/ai_edge_function_service.dart';
import 'package:clinic_pro/core/services/ai/ai_error_handler.dart';
import 'package:clinic_pro/core/services/ai/ai_provider_config.dart';
import 'package:clinic_pro/features/settings/domain/entities/ai_settings_entity.dart';
import 'package:clinic_pro/features/settings/domain/usecases/get_ai_settings_usecase.dart';
import 'package:clinic_pro/features/settings/domain/usecases/save_ai_settings_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'ai_settings_state.dart';

@injectable
class AiSettingsCubit extends Cubit<AiSettingsState> {
  final GetAiSettingsUseCase _getAiSettingsUseCase;
  final SaveAiSettingsUseCase _saveAiSettingsUseCase;
  final AiEdgeFunctionService _edgeFunctionService;

  AiSettingsCubit(
    this._getAiSettingsUseCase,
    this._saveAiSettingsUseCase,
    this._edgeFunctionService,
  ) : super(const AiSettingsState());

  /// تحميل إعدادات الذكاء الاصطناعي الحالية للمالك
  Future<void> loadSettings(String ownerId) async {
    emit(state.copyWith(status: AiSettingsStatus.loading));

    final result = await _getAiSettingsUseCase(ownerId, true);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AiSettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) {
        final provider = AiProviderConfig.parseType(settings.provider);
        final defaultModels = AiProviderConfig.defaultModels(provider);
        final initialModel = settings.model ??
            (defaultModels.isNotEmpty ? defaultModels.first.id : '');

        emit(state.copyWith(
          status: AiSettingsStatus.loaded,
          settings: settings,
          extractionMode: settings.extractionMode,
          selectedProvider: provider,
          selectedModel: initialModel,
          customBaseUrl: settings.customBaseUrl,
        ));
      },
    );
  }

  /// تغيير وضع الاستخراج (regex أو ai)
  void setExtractionMode(String mode) {
    emit(state.copyWith(extractionMode: mode));
  }

  /// تغيير مزود الذكاء الاصطناعي
  void selectProvider(AiProviderType provider) {
    final defaultModels = AiProviderConfig.defaultModels(provider);
    final initialModel =
        defaultModels.isNotEmpty ? defaultModels.first.id : '';

    emit(state.copyWith(
      selectedProvider: provider,
      selectedModel: initialModel,
      availableModels: const [],
      testStatus: AiTestStatus.initial,
      modelsFetchStatus: AiModelsFetchStatus.initial,
    ));
  }

  /// اختيار الموديل
  void selectModel(String model) {
    emit(state.copyWith(selectedModel: model));
  }

  /// تعديل الـ Base URL المخصص
  void setCustomBaseUrl(String url) {
    emit(state.copyWith(customBaseUrl: url));
  }

  /// اختبار الاتصال بالمزود
  Future<void> testConnection({
    String? apiKey,
    String? ownerId,
  }) async {
    final effectiveKey = apiKey?.trim() ?? '';
    final hasStoredKey = state.settings.hasApiKey;

    if (effectiveKey.isEmpty && !hasStoredKey) {
      emit(state.copyWith(
        testStatus: AiTestStatus.error,
        testErrorMessage: 'يرجى إدخال مفتاح الـ API للاختبار',
      ));
      return;
    }

    emit(state.copyWith(testStatus: AiTestStatus.testing));

    try {
      final success = await _edgeFunctionService.testConnection(
        provider: state.selectedProvider.name,
        apiKey: effectiveKey.isNotEmpty ? effectiveKey : null,
        model: state.selectedModel,
        customBaseUrl: state.customBaseUrl,
        ownerId: ownerId,
      );

      if (success) {
        emit(state.copyWith(testStatus: AiTestStatus.success));
      } else {
        emit(state.copyWith(
          testStatus: AiTestStatus.error,
          testErrorMessage: 'فشل الاتصال بالمزود، تحقق من صحة المفتاح والموديل',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        testStatus: AiTestStatus.error,
        testErrorMessage: AiErrorHandler.sanitize(e),
      ));
    }
  }

  /// جلب الموديلات المتاحة من API المزود
  Future<void> fetchAvailableModels({
    String? apiKey,
    String? ownerId,
  }) async {
    final effectiveKey = apiKey?.trim() ?? '';
    final hasStoredKey = state.settings.hasApiKey;

    if (effectiveKey.isEmpty && !hasStoredKey) {
      emit(state.copyWith(
        modelsFetchStatus: AiModelsFetchStatus.error,
        errorMessage: 'يرجى إدخال مفتاح الـ API أولاً لجلب الموديلات',
      ));
      return;
    }

    emit(state.copyWith(modelsFetchStatus: AiModelsFetchStatus.fetching));

    try {
      final models = await _edgeFunctionService.fetchModels(
        provider: state.selectedProvider.name,
        apiKey: effectiveKey.isNotEmpty ? effectiveKey : null,
        customBaseUrl: state.customBaseUrl,
        ownerId: ownerId,
      );

      emit(state.copyWith(
        modelsFetchStatus: AiModelsFetchStatus.success,
        availableModels: models,
      ));
    } catch (e) {
      emit(state.copyWith(
        modelsFetchStatus: AiModelsFetchStatus.error,
        errorMessage: AiErrorHandler.sanitize(e),
      ));
    }
  }

  /// حفظ الإعدادات النهائية في السيرفر وتشفير الـ API Key
  Future<bool> saveSettings({
    required String ownerId,
    String? apiKey,
  }) async {
    emit(state.copyWith(status: AiSettingsStatus.saving));

    try {
      // 1. الحفظ عبر Edge Function لتشفير المفتاح في السيرفر
      await _edgeFunctionService.saveSettings(
        ownerId: ownerId,
        provider: state.selectedProvider.name,
        apiKey: apiKey,
        model: state.selectedModel,
        extractionMode: state.extractionMode,
        customBaseUrl: state.customBaseUrl,
      );

      // 2. تحديث الـ Entity والكاش
      final hasKey = (apiKey != null && apiKey.trim().isNotEmpty) ||
          state.settings.hasApiKey;

      final updatedEntity = AiSettingsEntity(
        extractionMode: state.extractionMode,
        provider: state.selectedProvider.name,
        hasApiKey: hasKey,
        model: state.selectedModel,
        customBaseUrl: state.customBaseUrl,
      );

      await _saveAiSettingsUseCase(
        ownerId: ownerId,
        settings: updatedEntity,
      );

      emit(state.copyWith(
        status: AiSettingsStatus.saved,
        settings: updatedEntity,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AiSettingsStatus.error,
        errorMessage: AiErrorHandler.sanitize(e),
      ));
      return false;
    }
  }
}
