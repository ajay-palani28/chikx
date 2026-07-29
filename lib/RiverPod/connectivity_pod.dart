import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum ConnectivityStatus { isConnected, isDisconnected, notDetermined }

class ConnectivityStatusNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityStatusNotifier() : super(ConnectivityStatus.notDetermined) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateState(results);
    });
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _updateState(results);
    } catch (e) {
      state = ConnectivityStatus.isDisconnected;
    }
  }

  void _updateState(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      state = ConnectivityStatus.isDisconnected;
    } else {
      state = ConnectivityStatus.isConnected;
    }
  }
}

final connectivityStatusProvider = StateNotifierProvider<ConnectivityStatusNotifier, ConnectivityStatus>((ref) {
  return ConnectivityStatusNotifier();
});
