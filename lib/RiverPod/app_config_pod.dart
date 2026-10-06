import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../Network/api_manager.dart';
import '../Screens/UpdateAndMaintenance/maintenance_screen.dart';
import '../Screens/UpdateAndMaintenance/update_screen.dart';
import '../Utils/app_alerController.dart';

class AppConfigState {
  final bool isLoading;
  final bool isMaintenance;
  final bool isUpdateAvailable;
  final String? error;

  AppConfigState({
    this.isLoading = false,
    this.isMaintenance = false,
    this.isUpdateAvailable = false,
    this.error,
  });

  AppConfigState copyWith({
    bool? isLoading,
    bool? isMaintenance,
    bool? isUpdateAvailable,
    String? error,
  }) {
    return AppConfigState(
      isLoading: isLoading ?? this.isLoading,
      isMaintenance: isMaintenance ?? this.isMaintenance,
      isUpdateAvailable: isUpdateAvailable ?? this.isUpdateAvailable,
      error: error ?? this.error,
    );
  }
}

class AppConfigNotifier extends StateNotifier<AppConfigState> {
  AppConfigNotifier() : super(AppConfigState());

  Future<void> checkAppStatus(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    await ApiMethods().getAppVersion(
      successBlock: (data) async {
        final serverVersion = data['appVersion'] as String;
        final isMaintenance = data['maintenance'] as bool;

        if (isMaintenance) {
          state = state.copyWith(isLoading: false, isMaintenance: true);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
            (route) => false,
          );
          return;
        }

        // Get current app version
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        bool updateAvailable = _isUpdateAvailable(currentVersion, serverVersion);

        if (updateAvailable) {
          state = state.copyWith(isLoading: false, isUpdateAvailable: true);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UpdateScreen()),
            (route) => false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
      failureBlock: (exception, data) {
        state = state.copyWith(isLoading: false, error: exception.toString());
        AppAlertController().showAlert(
          message: exception.toString(),
          inContext: context,
        );
      },
    );
  }

  bool _isUpdateAvailable(String currentVersion, String serverVersion) {
    List<String> current = currentVersion.split('.');
    List<String> server = serverVersion.split('.');

    for (int i = 0; i < server.length; i++) {
      int s = int.parse(server[i]);
      int c = i < current.length ? int.parse(current[i]) : 0;
      if (s > c) return true;
      if (c > s) return false;
    }
    return false;
  }
}

final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfigState>((ref) {
  return AppConfigNotifier();
});
