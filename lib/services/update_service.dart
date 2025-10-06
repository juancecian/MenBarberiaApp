import 'dart:io';
import 'package:flutter/foundation.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // Configuración de la URL del archivo app-archive.json
  static const String _appArchiveUrl = 'https://raw.githubusercontent.com/juancecian/MenBarberiaApp/main/app-archive.json';
  
  bool _isInitialized = false;
  
  // Getters para el estado
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio de actualizaciones
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('UpdateService: Inicializando servicio de actualizaciones');
      }
      
      // Solo funciona en builds de release para desktop
      if (kDebugMode || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        if (kDebugMode) {
          print('UpdateService: Actualizaciones no disponibles en debug o plataformas móviles');
        }
        _isInitialized = false;
        return;
      }

      // En release, desktop_updater se inicializa automáticamente con los widgets
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

  /// Verifica si hay actualizaciones disponibles (simulado para debug)
  Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      if (kDebugMode) {
        print('UpdateService: Verificando actualizaciones...');
        await Future.delayed(const Duration(seconds: 2));
        
        // Simular que hay una actualización disponible en debug
        return {
          'version': '1.0.1',
          'releaseNotes': 'Corrección de errores y mejoras de rendimiento',
          'mandatory': false,
          'url': 'https://github.com/juancecian/MenBarberiaApp/releases/download/v1.0.1/men_barberia_v1.0.1.zip'
        };
      }

      // En release, el widget DesktopUpdater manejará automáticamente las actualizaciones
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('UpdateService: Error al verificar actualizaciones: $e');
      }
      return null;
    }
  }

  /// Verifica actualizaciones automáticamente al inicio
  Future<void> checkForUpdatesOnStartup() async {
    // Esperar un poco después del inicio para no interferir con la carga inicial
    await Future.delayed(const Duration(seconds: 5));
    
    final updateInfo = await checkForUpdates();
    if (updateInfo != null) {
      if (kDebugMode) {
        print('UpdateService: Actualización encontrada al inicio: ${updateInfo['version']}');
      }
      // En modo debug, la notificación se mostrará automáticamente
    }
  }

  /// Obtiene la versión actual de la aplicación
  String getCurrentVersion() {
    return '1.0.1'; // Actualizar con cada nueva versión
  }

  /// Verifica si las actualizaciones automáticas están habilitadas
  bool isAutoUpdateEnabled() {
    return true;
  }

  /// Habilita o deshabilita las actualizaciones automáticas
  Future<void> setAutoUpdateEnabled(bool enabled) async {
    if (kDebugMode) {
      print('UpdateService: Actualizaciones automáticas ${enabled ? 'habilitadas' : 'deshabilitadas'}');
    }
  }
}
