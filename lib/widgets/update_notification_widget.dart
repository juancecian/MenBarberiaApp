import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/update_service.dart';
import 'package:auto_updater/auto_updater.dart';

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

  String _getPlatformSuffix() {
    if (Platform.isWindows) return 'men_barberia_v1.0.6_windows.zip';
    if (Platform.isMacOS) return 'men_barberia_v1.0.6_macos.dmg';
    if (Platform.isLinux) return 'men_barberia_v1.0.6_linux.tar.gz';
    throw UnsupportedError('Plataforma no soportada');
  }

  Future<void> _checkForUpdates() async {
    try {
      final release = await _fetchGitHubRelease();
      final installedVersion = await _updateService.getCurrentVersion();
      if (release != null && _updateService.isNewerVersion(release['version'], installedVersion)) {
        setState(() {
          _availableUpdate = release;
          _isVisible = true;
        });
      }
    } catch (e) {
      debugPrint('Error al verificar actualizaciones: $e');
    }
  }

  Future<Map<String, dynamic>?> _fetchGitHubRelease() async {
    const owner = 'juancecian';
    const repo = 'MenBarberiaApp';
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest');
    final response = await http.get(url);
    if (response.statusCode != 200) return null;
    final data = json.decode(response.body);
    final tag = data['tag_name'] ?? '';
    final version = tag.toString().replaceFirst('v', '');
    final assets = List<Map<String, dynamic>>.from(data['assets']);
    final platformSuffix = _getPlatformSuffix();
    final asset = assets.firstWhere(
      (a) => (a['name'] as String).contains(platformSuffix),
      orElse: () => {},
    );
    debugPrint('asset: $asset');
    
    if (asset.isEmpty) return null;
    return {
      'version': version,
      'releaseNotes': data['body'] ?? '',
      'url': asset['browser_download_url'],
      'platform': Platform.operatingSystem,
    };
  }

  Future<void> _downloadUpdate() async {
    if (_availableUpdate == null) return;
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });
    try {
      // if (kDebugMode) {
      //   debugPrint('Simulando actualización...');
      //   for (int i = 0; i <= 100; i += 5) {
      //     if (!mounted) return;
      //     await Future.delayed(const Duration(milliseconds: 100));
      //     setState(() => _downloadProgress = i / 100);
      //   }
      //   _showMessage('Simulación de actualización completada (modo debug)', Colors.green);
      //   setState(() => _isVisible = false);
      //   return;
      // }
      final url = _availableUpdate!['url'] as String;
      debugPrint('⏬ Configurando feed de actualizaciones: $url');
      await autoUpdater.setFeedURL(url);
      await autoUpdater.checkForUpdates();
      _showMessage('Actualización lista para instalar. Si el instalador lo permite, la app se reiniciará tras la actualización.', Colors.green);
      setState(() => _isVisible = false);
    } catch (e) {
      debugPrint('❌ Error durante la actualización: $e');
      _showMessage('Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showMessage(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
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
              colors: [Colors.blue.shade50, Colors.blue.shade100],
            ),
            border: Border.all(color: Colors.blue.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.system_update, color: Colors.blue.shade700),
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
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Versión ${_availableUpdate!['version']} disponible',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              if ((_availableUpdate!['releaseNotes'] ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Novedades:',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800)),
                const SizedBox(height: 4),
                Text(
                  _availableUpdate!['releaseNotes'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              if (_isDownloading)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descargando actualización...',
                        style: TextStyle(
                            fontSize: 13, color: Colors.blue.shade700)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text('${(_downloadProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _dismissNotification,
                      child: Text('Más tarde',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _downloadUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text('Actualizar ahora'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
