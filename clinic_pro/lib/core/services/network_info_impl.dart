// ────────────────────────────────────────────────────────
// تنفيذ خدمة التحقق من الاتصال بالإنترنت (NetworkInfoImpl)
// باستخدام internet_connection_checker_plus بفحص فوري وموثوق
// ────────────────────────────────────────────────────────

import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'i_network_info.dart';

@LazySingleton(as: INetworkInfo)
class NetworkInfoImpl implements INetworkInfo {
  final InternetConnection _internetConnection;

  NetworkInfoImpl()
      : _internetConnection = InternetConnection.createInstance(
          checkInterval: const Duration(seconds: 4),
        );

  @override
  Future<bool> get isConnected async {
    return await _internetConnection.hasInternetAccess;
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _internetConnection.onStatusChange.map(
      (status) => status == InternetStatus.connected,
    );
  }
}
