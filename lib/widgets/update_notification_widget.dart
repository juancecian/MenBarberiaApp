import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:desktop_updater/desktop_updater.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/update_service.dart';

class UpdateNotificationWidget extends StatefulWidget {
  const UpdateNotificationWidget({Key? key}) : super(key: key);

  @override
  State<UpdateNotificationWidget> createState() => _UpdateNotificationWidgetState();
}

class _UpdateNotificationWidgetState extends State<UpdateNotificationWidget> {
  final UpdateService _updateService = UpdateService();
  Map<String, dynamic>? _availableUpdate;
  bool _isVisible = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final updateInfo = await _updateService.checkForUpdates();
    if (updateInfo != null && mounted) {
      setState(() {
        _availableUpdate = updateInfo;
        _isVisible = true;
      });
    }
  }

  Future<void> _downloadUpdate() async {
    if (_availableUpdate == null) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      if (kDebugMode) {
        // En modo debug, simular descarga
        print('UpdateNotification: Simulando descarga en modo debug');
        for (int i = 0; i <= 100; i += 5) {
          if (!mounted) break;
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {
            _downloadProgress = i / 100.0;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Actualización simulada completada (modo debug)'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        // En modo release, usar desktop_updater real
        print('UpdateNotification: Iniciando descarga real');
        final url = _availableUpdate!['url'] as String;
        
        // Descargar el archivo de actualización
        final downloadedFile = await _downloadUpdateFile(url);
        
        if (downloadedFile != null && mounted) {
          print('UpdateNotification: Archivo descargado: ${downloadedFile.path}');
          
          // Usar DesktopUpdater para instalar y reiniciar
          try {
            // Configurar DesktopUpdater
            await DesktopUpdater.setAppcastURL(_availableUpdate!['url']);
            await DesktopUpdater.setFeedURL(_availableUpdate!['url']);
            
            // Instalar la actualización
            final success = await DesktopUpdater.installUpdate(downloadedFile.path);
            
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualización instalada. La aplicación se reiniciará...'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
              
              // Ocultar notificación
              setState(() {
                _isVisible = false;
              });
              
              // Esperar un momento y reiniciar
              await Future.delayed(const Duration(seconds: 2));
              await DesktopUpdater.restartApp();
            } else {
              throw Exception('No se pudo instalar la actualización');
            }
          } catch (e) {
            print('UpdateNotification: Error con DesktopUpdater: $e');
            // Fallback: intentar instalación manual
            await _performManualUpdate(downloadedFile);
          }
        } else {
          throw Exception('No se pudo descargar el archivo de actualización');
        }
      }
    } catch (e) {
      print('UpdateNotification: Error durante la descarga: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  /// Descarga el archivo de actualización
  Future<File?> _downloadUpdateFile(String url) async {
    try {
      print('UpdateNotification: Descargando desde: $url');
      
      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(Uri.parse(url).path);
      final filePath = path.join(tempDir.path, fileName);
      final file = File(filePath);
      
      // Realizar la descarga con progreso
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        var downloadedBytes = 0;
        
        final sink = file.openWrite();
        
        await for (final chunk in response.stream) {
          sink.add(chunk);
          downloadedBytes += chunk.length;
          
          if (contentLength > 0 && mounted) {
            setState(() {
              _downloadProgress = downloadedBytes / contentLength;
            });
          }
        }
        
        await sink.close();
        print('UpdateNotification: Descarga completada: ${file.path}');
        return file;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('UpdateNotification: Error al descargar archivo: $e');
      return null;
    }
  }

  /// Realiza una actualización manual como fallback
  Future<void> _performManualUpdate(File updateFile) async {
    try {
      print('UpdateNotification: Intentando actualización manual');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actualización descargada. Por favor, instala manualmente y reinicia la aplicación.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        
        // Mostrar diálogo con instrucciones
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Actualización Descargada'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('La actualización se ha descargado correctamente.'),
                const SizedBox(height: 8),
                const Text('Ubicación del archivo:'),
                const SizedBox(height: 4),
                SelectableText(
                  updateFile.path,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text('Por favor, cierra la aplicación e instala la actualización manualmente.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isVisible = false;
                  });
                },
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isVisible = false;
                  });
                  // Cerrar la aplicación
                  exit(0);
                },
                child: const Text('Cerrar Aplicación'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('UpdateNotification: Error en actualización manual: $e');
    }
  }

  void _dismissNotification() {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _availableUpdate == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
            ),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.system_update,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nueva actualización disponible',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _dismissNotification,
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Versión ${_availableUpdate!['version']} está disponible',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              if (_availableUpdate!['releaseNotes']?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  'Novedades:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _availableUpdate!['releaseNotes']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              if (_isDownloading) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descargando actualización...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _dismissNotification,
                      child: Text(
                        'Más tarde',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _downloadUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Actualizar ahora'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar en la configuración
class UpdateSettingsWidget extends StatefulWidget {
  const UpdateSettingsWidget({Key? key}) : super(key: key);

  @override
  State<UpdateSettingsWidget> createState() => _UpdateSettingsWidgetState();
}

class _UpdateSettingsWidgetState extends State<UpdateSettingsWidget> {
  final UpdateService _updateService = UpdateService();
  bool _autoUpdateEnabled = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _autoUpdateEnabled = _updateService.isAutoUpdateEnabled();
  }

  Future<void> _checkForUpdatesManually() async {
    setState(() {
      _isChecking = true;
    });

    final updateInfo = await _updateService.checkForUpdates();
    
    if (mounted) {
      setState(() {
        _isChecking = false;
      });

      if (updateInfo != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nueva actualización disponible: ${updateInfo['version']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay actualizaciones disponibles'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actualizaciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Verificar actualizaciones automáticamente'),
              subtitle: const Text('Buscar nuevas versiones al iniciar la aplicación'),
              value: _autoUpdateEnabled,
              onChanged: (value) {
                setState(() {
                  _autoUpdateEnabled = value;
                });
                _updateService.setAutoUpdateEnabled(value);
              },
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _updateService.getCurrentVersion(),
              builder: (context, snapshot) {
                return ListTile(
                  title: const Text('Verificar actualizaciones ahora'),
                  subtitle: Text('Versión actual: ${snapshot.data ?? "Cargando..."}'),
                  trailing: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onTap: _isChecking ? null : _checkForUpdatesManually,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
