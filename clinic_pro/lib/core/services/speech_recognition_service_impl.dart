// ────────────────────────────────────────────────────────
// SpeechRecognitionServiceImpl — تنفيذ خدمة التعرف على الصوت
// باستخدام مكتبة speech_to_text الرسمية لدعم التسجيل وتحويل الصوت لنص
// ────────────────────────────────────────────────────────

import 'dart:async';

import 'package:clinic_pro/core/services/i_speech_recognition_service.dart';
import 'package:injectable/injectable.dart';
import 'package:speech_to_text/speech_to_text.dart';

@LazySingleton(as: ISpeechRecognitionService)
class SpeechRecognitionServiceImpl implements ISpeechRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  @override
  bool get isListening => _speechToText.isListening;

  @override
  bool get isAvailable => _isInitialized && _speechToText.isAvailable;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (errorNotification) {
          // تسجيل الأخطاء إن لزم
        },
        onStatus: (status) {
          // متابعة حالة التسجيل
        },
      );
      return _isInitialized;
    } catch (_) {
      _isInitialized = false;
      return false;
    }
  }

  @override
  Future<void> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    String? localeId,
  }) async {
    final available = await initialize();
    if (!available) {
      throw Exception('Speech recognition not available or permission denied');
    }

    // تحديد اللغة الافتراضية للعربية إن لم تُحدد
    final targetLocale = localeId ?? 'ar_SA';

    final options = SpeechListenOptions(
      listenMode: ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
      localeId: targetLocale,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 15),
    );

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: options,
    );
  }

  @override
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  @override
  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }
}
