import 'package:flutter/foundation.dart';
import '../core/services/sync_service.dart';

/// Provider para manejar el estado de sincronización en la UI
class SyncProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();
  
  bool get isSyncing => _syncService.isSyncing;
  bool get isOnline => _syncService.isOnline;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;
  String? get syncError => _syncService.syncError;

  SyncProvider() {
    // Escuchar cambios en el servicio de sincronización
    _syncService.addListener(_onSyncServiceChanged);
  }

  void _onSyncServiceChanged() {
    notifyListeners();
  }

  /// Forzar sincronización manual
  Future<SyncResult> forcSync() async {
    return await _syncService.syncAll();
  }

  /// Sincronizar solo cambios locales
  Future<SyncResult> syncLocalChanges() async {
    return await _syncService.syncLocalChanges();
  }

  @override
  void dispose() {
    _syncService.removeListener(_onSyncServiceChanged);
    super.dispose();
  }
}
