// ────────────────────────────────────────────────────────
// AiSettingsState — حالات إدارة وتخصيص إعدادات الذكاء الاصطناعي
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/ai/ai_provider_config.dart';
import 'package:clinic_pro/features/settings/domain/entities/ai_settings_entity.dart';
import 'package:equatable/equatable.dart';

enum AiSettingsStatus { initial, loading, loaded, saving, saved, error }

enum AiTestStatus { initial, testing, success, error }

enum AiModelsFetchStatus { initial, fetching, success, error }

class AiSettingsState extends Equatable {
  final AiSettingsStatus status;
  final AiTestStatus testStatus;
  final AiModelsFetchStatus modelsFetchStatus;
  final AiSettingsEntity settings;
  final AiProviderType selectedProvider;
  final String extractionMode; // 'regex' or 'ai'
  final String selectedModel;
  final String? customBaseUrl;
  final List<String> availableModels;
  final String? errorMessage;
  final String? testErrorMessage;

  const AiSettingsState({
    this.status = AiSettingsStatus.initial,
    this.testStatus = AiTestStatus.initial,
    this.modelsFetchStatus = AiModelsFetchStatus.initial,
    this.settings = const AiSettingsEntity(),
    this.selectedProvider = AiProviderType.openai,
    this.extractionMode = 'regex',
    this.selectedModel = 'gpt-4o-mini',
    this.customBaseUrl,
    this.availableModels = const [],
    this.errorMessage,
    this.testErrorMessage,
  });

  bool get isAiMode => extractionMode == 'ai';

  AiSettingsState copyWith({
    AiSettingsStatus? status,
    AiTestStatus? testStatus,
    AiModelsFetchStatus? modelsFetchStatus,
    AiSettingsEntity? settings,
    AiProviderType? selectedProvider,
    String? extractionMode,
    String? selectedModel,
    String? customBaseUrl,
    List<String>? availableModels,
    String? errorMessage,
    String? testErrorMessage,
  }) {
    return AiSettingsState(
      status: status ?? this.status,
      testStatus: testStatus ?? this.testStatus,
      modelsFetchStatus: modelsFetchStatus ?? this.modelsFetchStatus,
      settings: settings ?? this.settings,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      extractionMode: extractionMode ?? this.extractionMode,
      selectedModel: selectedModel ?? this.selectedModel,
      customBaseUrl: customBaseUrl ?? this.customBaseUrl,
      availableModels: availableModels ?? this.availableModels,
      errorMessage: errorMessage,
      testErrorMessage: testErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        testStatus,
        modelsFetchStatus,
        settings,
        selectedProvider,
        extractionMode,
        selectedModel,
        customBaseUrl,
        availableModels,
        errorMessage,
        testErrorMessage,
      ];
}
