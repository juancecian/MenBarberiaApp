import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('UpdateService: Inicializando servicio de actualizaciones');
      }
      if (kDebugMode || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        _isInitialized = false;
        return;
      }
      _isInitialized = true;
      if (kDebugMode) {
        print('UpdateService: Servicio inicializado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UpdateService: Error al inicializar: $e');
      }
    }
  }

  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '0.0.0';
    }
  }

  bool isAutoUpdateEnabled() => true;

  bool isNewerVersion(String availableVersion, String currentVersion) {
    final available = _parseVersion(availableVersion);
    final current = _parseVersion(currentVersion);
    for (int i = 0; i < 3; i++) {
      if (available[i] > current[i]) return true;
      if (available[i] < current[i]) return false;
    }
    return false;
  }

  List<int> _parseVersion(String version) {
    final parts = version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts;
  }
}
