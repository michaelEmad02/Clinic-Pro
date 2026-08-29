// ────────────────────────────────────────────────────────
// محاكاة خدمة التحقق من الاتصال للاختبارات (MockNetworkInfo)
// ────────────────────────────────────────────────────────

import 'dart:async';
import 'i_network_info.dart';

class MockNetworkInfo implements INetworkInfo {
  final bool _mockConnected;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  MockNetworkInfo({bool isConnected = true}) : _mockConnected = isConnected {
    _controller.add(isConnected);
  }

  @override
  Future<bool> get isConnected async => _mockConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
