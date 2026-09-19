// ────────────────────────────────────────────────────────
// AppVoiceInputCubit — مدير الصوت الموحد لكافة شاشات التطبيق
// ────────────────────────────────────────────────────────

import 'dart:async';

import 'package:clinic_pro/core/services/ai/ai_error_handler.dart';
import 'package:clinic_pro/core/services/i_speech_recognition_service.dart';
import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/widgets/voice_input/app_voice_input_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppVoiceInputCubit extends Cubit<AppVoiceInputState> {
  final ISpeechRecognitionService _speechService;
  final IVoiceExtractionService _extractionService;

  String _accumulatedText = '';
  String _currentSessionWords = '';
  String _lastWords = '';

  AppVoiceInputCubit(
    this._speechService,
    this._extractionService,
  ) : super(const AppVoiceInputInitial());

  /// بدء الاستماع لصوت المستخدم مع خيار الاحتفاظ بالكلمات السابقة
  Future<void> startListening({
    required ExtractionTarget target,
    Map<String, dynamic>? extraContext,
    bool keepExisting = false,
  }) async {
    if (!keepExisting) {
      _accumulatedText = '';
      _currentSessionWords = '';
      _lastWords = '';
      emit(const AppVoiceInputListening(recognizedWords: ''));
    } else {
      emit(AppVoiceInputListening(recognizedWords: _lastWords));
    }

    try {
      final initialized = await _speechService.initialize();
      if (!initialized) {
        emit(AppVoiceInputFailure(message: AppStrings.micPermissionDenied));
        return;
      }

      await _speechService.startListening(
        onResult: (words, isFinal) {
          final trimmed = words.trim();
          if (trimmed.isNotEmpty) {
            _currentSessionWords = trimmed;
            final fullText = _accumulatedText.isEmpty
                ? _currentSessionWords
                : '$_accumulatedText $_currentSessionWords';
            _lastWords = fullText.trim();
            if (isClosed) return;
            emit(AppVoiceInputListening(recognizedWords: _lastWords));
          }

          if (isFinal && _currentSessionWords.isNotEmpty) {
            // حفظ الجملة المكتملة في النص التراكمي حتى لا تضيع إذا بدأت جلسة جديدة
            _accumulatedText = _lastWords;
            _currentSessionWords = '';
          }
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(AppVoiceInputFailure(message: e.toString()));
    }
  }

  /// إيقاف التسجيل ومعالجة النص المسجل
  Future<void> stopAndProcess({
    required ExtractionTarget target,
    Map<String, dynamic>? extraContext,
  }) async {
    await _speechService.stopListening();
    final finalText = _lastWords.trim();
    if (finalText.isNotEmpty) {
      await _processText(finalText, target, extraContext);
    } else {
      emit(AppVoiceInputFailure(message: AppStrings.noSpeechDetected));
    }
  }

  /// إلغاء الاستماع
  Future<void> cancelListening() async {
    await _speechService.cancelListening();
    _accumulatedText = '';
    _currentSessionWords = '';
    _lastWords = '';
    emit(const AppVoiceInputInitial());
  }

  Future<void> _processText(
    String text,
    ExtractionTarget target,
    Map<String, dynamic>? extraContext,
  ) async {
    if (text.trim().isEmpty) {
      emit(AppVoiceInputFailure(message: AppStrings.noSpeechDetected));
      return;
    }

    emit(AppVoiceInputProcessing(finalWords: text));

    try {
      final data = await _extractionService.extractData(
        text: text,
        target: target,
        extraContext: extraContext,
      );

      emit(AppVoiceInputSuccess(data: data));
    } catch (e) {
      emit(AppVoiceInputFailure(message: AiErrorHandler.sanitize(e)));
    }
  }

  @override
  Future<void> close() {
    _speechService.cancelListening();
    return super.close();
  }
}
