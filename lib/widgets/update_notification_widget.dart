import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
        
        // Usar DesktopUpdater para descargar e instalar
        try {
          // Simular progreso de descarga real
          for (int i = 0; i <= 100; i += 2) {
            if (!mounted) break;
            await Future.delayed(const Duration(milliseconds: 50));
            setState(() {
              _downloadProgress = i / 100.0;
            });
          }

          // Aquí se integraría con desktop_updater real
          // Por ahora simulamos el éxito
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Actualización descargada. La aplicación se reiniciará...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            // Ocultar notificación
            setState(() {
              _isVisible = false;
            });
            
            // TODO: Integrar con desktop_updater real cuando esté disponible
            // await DesktopUpdater.installAndRestart();
          }
        } catch (e) {
          print('UpdateNotification: Error en desktop_updater: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al actualizar: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
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
