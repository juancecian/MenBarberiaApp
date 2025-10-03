import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../database/database_service.dart';
import 'supabase_service.dart';
import '../../models/barbero.dart';
import '../../models/servicio.dart';
import '../../models/cliente.dart';
import '../../models/barbero_model.dart' as SupabaseBarbero;
import '../../models/servicio_model.dart' as SupabaseServicio;

/// Servicio de sincronización offline/online
/// Maneja la sincronización bidireccional entre SQLite local y Supabase
class SyncService with ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService();
  
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;
  bool _isOnline = false;
  DateTime? _lastSyncTime;
  String? _syncError;
  
  // Getters para el estado de sincronización
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;

  /// Inicializa el servicio de sincronización
  Future<void> initialize() async {
    await _checkConnectivity();
    await _startPeriodicSync();
  }

  /// Verifica la conectividad a internet
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      _isOnline = false;
    }
    notifyListeners();
  }

  /// Inicia la sincronización periódica cada 5 minutos
  Future<void> _startPeriodicSync() async {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAll(),
    );
  }

  /// Sincronización completa (solo servicios)
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sincronización ya en progreso',
      );
    }

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      await _checkConnectivity();
      
      if (!_isOnline) {
        return SyncResult(
          success: false,
          message: 'Sin conexión a internet',
        );
      }

      // Sincronizar clientes y servicios
      final clientesResult = await _syncClientes();
      if (!clientesResult.success) {
        return clientesResult;
      }

      final serviciosResult = await _syncServicios();
      if (!serviciosResult.success) {
        return serviciosResult;
      }

      _lastSyncTime = DateTime.now();
      
      return SyncResult(
        success: true,
        message: 'Clientes y servicios sincronizados exitosamente',
        syncedClientes: clientesResult.syncedClientes,
        syncedServicios: serviciosResult.syncedServicios,
      );

    } catch (e) {
      _syncError = e.toString();
      return SyncResult(
        success: false,
        message: 'Error durante la sincronización: $e',
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sincroniza clientes entre local y remoto
  Future<SyncResult> _syncClientes() async {
    try {
      // 1. Obtener clientes remotos
      final remoteClientesData = await _supabaseService.getClientes();
      final remoteClientes = remoteClientesData
          .map((data) => Cliente.fromMap(data))
          .toList();
      
      // 2. Obtener clientes locales
      final localClientes = await _databaseService.getClientes();
      
      int syncedCount = 0;
      
      // 3. Sincronizar desde remoto a local
      for (final remoteCliente in remoteClientes) {
        final localCliente = localClientes.firstWhere(
          (c) => c.id == remoteCliente.id,
          orElse: () => Cliente(
            id: '',
            nombre: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (localCliente.id.isEmpty) {
          // Cliente no existe localmente, insertarlo
          await _databaseService.insertCliente(remoteCliente);
          syncedCount++;
        } else if (remoteCliente.updatedAt.isAfter(localCliente.updatedAt)) {
          // Cliente remoto es más reciente, actualizarlo
          await _databaseService.updateCliente(remoteCliente);
          syncedCount++;
        }
      }
      
      // 4. Sincronizar desde local a remoto (clientes nuevos)
      for (final localCliente in localClientes) {
        final remoteCliente = remoteClientes.firstWhere(
          (c) => c.id == localCliente.id,
          orElse: () => Cliente(
            id: '',
            nombre: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (remoteCliente.id.isEmpty) {
          // Cliente no existe remotamente, insertarlo
          await _supabaseService.insertClienteSync(localCliente.toMap());
          syncedCount++;
        } else if (localCliente.updatedAt.isAfter(remoteCliente.updatedAt)) {
          // Cliente local es más reciente, actualizarlo en remoto
          await _supabaseService.updateClienteSync(localCliente.toMap());
          syncedCount++;
        }
      }
      
      return SyncResult(
        success: true,
        message: 'Clientes sincronizados',
        syncedClientes: syncedCount,
      );
      
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando clientes: $e',
      );
    }
  }

  /// Sincroniza servicios entre local y remoto
  Future<SyncResult> _syncServicios() async {
    try {
      // 1. Obtener servicios remotos (últimos 30 días) y convertirlos
      final fechaInicio = DateTime.now().subtract(const Duration(days: 30));
      final fechaFin = DateTime.now();
      
      final remoteServiciosSupabase = await _supabaseService.getServiciosPorFecha(
        fechaInicio,
        fechaFin,
      );
      final remoteServicios = remoteServiciosSupabase
          .map((s) => _convertSupabaseServicioToLocal(s))
          .toList();
      
      // 2. Obtener servicios locales
      final localServicios = await _databaseService.getServicios();
      
      int syncedCount = 0;
      
      // 3. Sincronizar desde remoto a local
      for (final remoteServicio in remoteServicios) {
        final localServicio = localServicios.firstWhere(
          (s) => s.id == remoteServicio.id,
          orElse: () => Servicio(
            id: '',
            barberoId: '',
            clienteNombre: '',
            clienteTelefono: null,
            tipoServicio: 0,
            precioServicio: 0,
            propina: 0,
            tipoPago: 1,
            registrationDate: DateTime.now(),
          ),
        );
        
        if (localServicio.id.isEmpty) {
          // Servicio no existe localmente, insertarlo
          await _databaseService.insertServicio(remoteServicio);
          syncedCount++;
        } else if (remoteServicio.createdAt.isAfter(localServicio.createdAt)) {
          // Servicio remoto es más reciente, actualizarlo
          await _databaseService.updateServicio(remoteServicio);
          syncedCount++;
        }
      }
      
      // 4. Sincronizar desde local a remoto (servicios nuevos)
      for (final localServicio in localServicios) {
        final remoteServicio = remoteServicios.firstWhere(
          (s) => s.id == localServicio.id,
          orElse: () => Servicio(
            id: '',
            barberoId: '',
            clienteNombre: '',
            clienteTelefono: null,
            tipoServicio: 0,
            precioServicio: 0,
            propina: 0,
            tipoPago: 1,
            registrationDate: DateTime.now(),
          ),
        );
        
        if (remoteServicio.id.isEmpty) {
          // Servicio no existe remotamente, insertarlo
          final supabaseServicio = _convertLocalServicioToSupabase(localServicio);
          await _supabaseService.insertServicioSync(supabaseServicio);
          syncedCount++;
        }
      }
      
      return SyncResult(
        success: true,
        message: 'Servicios sincronizados',
        syncedServicios: syncedCount,
      );
      
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando servicios: $e',
      );
    }
  }

  /// Sincronización rápida solo para subir datos locales pendientes
  Future<SyncResult> syncLocalChanges() async {
    if (!_isOnline) {
      return SyncResult(
        success: false,
        message: 'Sin conexión a internet',
      );
    }

    try {
      // Aquí podríamos implementar una tabla de cambios pendientes
      // Por ahora, hacemos una sincronización completa ligera
      return await syncAll();
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando cambios locales: $e',
      );
    }
  }

  /// Detiene el servicio de sincronización
  void dispose() {
    _periodicSyncTimer?.cancel();
    super.dispose();
  }

  // Métodos de conversión entre modelos (solo para servicios)

  /// Convierte un Servicio de Supabase a modelo local
  Servicio _convertSupabaseServicioToLocal(SupabaseServicio.Servicio supabaseServicio) {
    return Servicio(
      id: supabaseServicio.id,
      barberoId: supabaseServicio.barberId,
      clienteNombre: supabaseServicio.clientName,
      clienteTelefono: supabaseServicio.clientPhone,
      tipoServicio: supabaseServicio.typeService, // Ya es int
      precioServicio: supabaseServicio.price,
      propina: supabaseServicio.perquisiste ?? 0.0,
      tipoPago: supabaseServicio.paymentType,
      registrationDate: supabaseServicio.registrationDate,
    );
  }

  /// Convierte un Servicio local a modelo de Supabase
  SupabaseServicio.Servicio _convertLocalServicioToSupabase(Servicio localServicio) {
    return SupabaseServicio.Servicio(
      id: localServicio.id,
      barberId: localServicio.barberoId,
      clientName: localServicio.clienteNombre,
      clientPhone: localServicio.clienteTelefono,
      typeService: localServicio.tipoServicio, // Ya es int
      price: localServicio.precioServicio,
      perquisiste: localServicio.propina,
      paymentType: localServicio.tipoPago,
      registrationDate: localServicio.registrationDate,
    );
  }

}

/// Resultado de una operación de sincronización
class SyncResult {
  final bool success;
  final String message;
  final int syncedBarberos;
  final int syncedClientes;
  final int syncedServicios;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedBarberos = 0,
    this.syncedClientes = 0,
    this.syncedServicios = 0,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, '
           'barberos: $syncedBarberos, clientes: $syncedClientes, servicios: $syncedServicios)';
  }
}
