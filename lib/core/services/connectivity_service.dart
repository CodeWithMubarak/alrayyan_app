import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// خدمة مراقبة الاتصال بالإنترنت
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.any((result) => result != ConnectivityResult.none);
    });
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final isConnectedProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});
