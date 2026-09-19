// ────────────────────────────────────────────────────────
// AppVoiceInputState — حالات مدير الصوت الموحد للتطبيق
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

abstract class AppVoiceInputState extends Equatable {
  const AppVoiceInputState();

  @override
  List<Object?> get props => [];
}

class AppVoiceInputInitial extends AppVoiceInputState {
  const AppVoiceInputInitial();
}

class AppVoiceInputListening extends AppVoiceInputState {
  final String recognizedWords;

  const AppVoiceInputListening({required this.recognizedWords});

  @override
  List<Object?> get props => [recognizedWords];
}

class AppVoiceInputProcessing extends AppVoiceInputState {
  final String finalWords;

  const AppVoiceInputProcessing({required this.finalWords});

  @override
  List<Object?> get props => [finalWords];
}

class AppVoiceInputSuccess extends AppVoiceInputState {
  final Map<String, dynamic> data;

  const AppVoiceInputSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class AppVoiceInputFailure extends AppVoiceInputState {
  final String message;

  const AppVoiceInputFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
