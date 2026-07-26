import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ملاحظ مخصص للـ Bloc والـ Cubit لمراقبة التغييرات والتحولات والأخطاء في بيئة التطوير
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      print('🟢 Bloc Created: ${bloc.runtimeType}');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      print('🔄 Bloc Changed (${bloc.runtimeType}): ${change.currentState} ➡️ ${change.nextState}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print('🔀 Bloc Transition (${bloc.runtimeType}): Event ${transition.event} ➡️ State ${transition.nextState}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      print('🔴 Bloc Error (${bloc.runtimeType}): $error');
      print(stackTrace);
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      print('🟥 Bloc Closed: ${bloc.runtimeType}');
    }
  }
}
