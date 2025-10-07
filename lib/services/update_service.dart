import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  /// Verifica si hay actualizaciones disponibles
  Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      if (kDebugMode) {
        print('UpdateService: Verificando actualizaciones...');
        await Future.delayed(const Duration(seconds: 2));
        
        // Simular que hay una actualización disponible en debug
        return {
          'version': '1.0.3',
          'releaseNotes': 'Corrección de errores y mejoras de rendimiento',
          'mandatory': false,
          'url': 'https://github.com/juancecian/MenBarberiaApp/releases/download/v1.0.3/men_barberia_v1.0.3_windows.zip'
        };
      }

      // En release, consultar GitHub real
      print('UpdateService: Consultando GitHub para actualizaciones...');
      final response = await http.get(Uri.parse(_appArchiveUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final archiveData = jsonDecode(response.body);
        final currentVersion = await getCurrentVersion();
        final currentPlatform = _getCurrentPlatform();
        
        print('UpdateService: Versión actual: $currentVersion');
        print('UpdateService: Plataforma: $currentPlatform');
        
        // Buscar actualización para la plataforma actual
        for (var item in archiveData['items']) {
          if (item['platform'] == currentPlatform) {
            final availableVersion = item['version'];
            print('UpdateService: Versión disponible: $availableVersion');
            
            if (_isNewerVersion(availableVersion, currentVersion)) {
              print('UpdateService: ¡Actualización encontrada!');
              return {
                'version': availableVersion,
                'releaseNotes': _formatReleaseNotes(item['changes']),
                'mandatory': item['mandatory'] ?? false,
                'url': item['url'],
                'date': item['date'],
              };
            }
          }
        }
        
        print('UpdateService: No hay actualizaciones disponibles');
        return null;
      } else {
        print('UpdateService: Error al obtener actualizaciones: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('UpdateService: Error al verificar actualizaciones: $e');
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
  Future<String> getCurrentVersion() async {
    try {
      // En modo debug, intentar leer desde pubspec.yaml primero
      if (kDebugMode) {
        try {
          final pubspecFile = File('pubspec.yaml');
          if (pubspecFile.existsSync()) {
            final content = pubspecFile.readAsStringSync();
            final versionMatch = RegExp(r'version:\s*([0-9]+\.[0-9]+\.[0-9]+)').firstMatch(content);
            if (versionMatch != null) {
              print('UpdateService: Versión leída desde pubspec.yaml: ${versionMatch.group(1)}');
              return versionMatch.group(1)!;
            }
          }
        } catch (e2) {
          print('UpdateService: Error al leer pubspec.yaml: $e2');
        }
      }
      
      // Usar package_info_plus para obtener la versión real del ejecutable
      // Esto funciona tanto en debug como en release
      final packageInfo = await PackageInfo.fromPlatform();
      print('UpdateService: Versión leída desde PackageInfo: ${packageInfo.version}');
      return packageInfo.version;
    } catch (e) {
      print('UpdateService: Error al obtener versión: $e');
      // Fallback final
      return '1.0.1';
    }
  }

  /// Obtiene la versión desde el build compilado
  Future<String> _getVersionFromBuild() async {
    // En un build de release, Flutter incluye la versión en los metadatos
    // del ejecutable. Usamos package_info_plus para obtenerla correctamente.
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      if (kDebugMode) {
        print('UpdateService: Error al obtener versión del build: $e');
      }
      return '1.0.1';
    }
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

  /// Obtiene la plataforma actual
  String _getCurrentPlatform() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Compara versiones (formato semver)
  bool _isNewerVersion(String availableVersion, String currentVersion) {
    final available = _parseVersion(availableVersion);
    final current = _parseVersion(currentVersion);
    
    for (int i = 0; i < 3; i++) {
      if (available[i] > current[i]) return true;
      if (available[i] < current[i]) return false;
    }
    
    return false; // Misma versión
  }

  /// Parsea una versión en formato semver
  List<int> _parseVersion(String version) {
    final parts = version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts;
  }

  /// Formatea las notas de release
  String _formatReleaseNotes(List<dynamic> changes) {
    return changes.map((change) => 
      '• ${change['message'] ?? 'Cambio sin descripción'}'
    ).join('\n');
  }
}
