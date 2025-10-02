import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/servicio.dart';
import '../core/database/database_service.dart';
import '../core/services/sync_service.dart';

enum DateFilterType {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  all
}

class ServicioProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final SyncService _syncService = SyncService();
  List<Servicio> _servicios = [];
  List<Servicio> _allServicios = []; // Lista completa sin filtrar
  Map<String, dynamic> _dashboardMetrics = {};
  bool _isLoading = false;
  String? _error;
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];
  DateFilterType _currentFilter = DateFilterType.today;

  List<Servicio> get servicios => _servicios;
  List<Servicio> get allServicios => _allServicios;
  Map<String, dynamic> get dashboardMetrics => _dashboardMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDate => _selectedDate;
  DateFilterType get currentFilter => _currentFilter;

  Future<void> loadServicios({String? fecha}) async {
    _isLoading = true;
    _error = null;
    
    // Defer notification to avoid setState during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      // Cargar todos los servicios sin filtro de fecha
      _allServicios = await _databaseService.getServicios();
      
      // Si se especifica una fecha, mantener compatibilidad con el comportamiento anterior
      if (fecha != null) {
        _selectedDate = fecha;
        _servicios = await _databaseService.getServicios(fecha: fecha);
        // Cargar métricas de forma asíncrona sin bloquear
        loadDashboardMetrics(fecha);
      } else {
        // Aplicar el filtro actual
        _applyCurrentFilter();
      }
    } catch (e) {
      _error = 'Error al cargar servicios: $e';
    } finally {
      _isLoading = false;
      // Safe to notify here as we're in async context
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> loadDashboardMetrics(String fecha) async {
    try {
      _dashboardMetrics = await _databaseService.getDashboardMetrics(fecha);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error al cargar métricas: $e';
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> addServicio(Servicio servicio) async {
    _error = null;
    try {
      // 1. Guardar siempre en la base de datos local primero (offline-first)
      await _databaseService.insertServicio(servicio);
      
      // 2. Recargar datos locales inmediatamente
      await loadServicios(fecha: _selectedDate);
      
      // 3. Intentar sincronizar en segundo plano (no bloquear la UI)
      _syncService.syncLocalChanges().then((result) {
        if (!result.success) {
          print('Sincronización en segundo plano falló: ${result.message}');
          // El dato ya está guardado localmente, no es crítico
        }
      }).catchError((e) {
        print('Error en sincronización en segundo plano: $e');
        // El dato ya está guardado localmente, no es crítico
      });
      
      return true;
    } catch (e) {
      _error = 'Error al agregar servicio: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateServicio(Servicio servicio) async {
    _error = null;
    try {
      await _databaseService.updateServicio(servicio);
      await loadServicios(fecha: _selectedDate);
      return true;
    } catch (e) {
      _error = 'Error al actualizar servicio: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteServicio(String id) async {
    _error = null;
    try {
      await _databaseService.deleteServicio(id);
      await loadServicios(fecha: _selectedDate);
      return true;
    } catch (e) {
      _error = 'Error al eliminar servicio: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<String>> searchClients(String query) async {
    try {
      return await _databaseService.buscarClientes(query);
    } catch (e) {
      return [];
    }
  }

  void setSelectedDate(String date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      loadServicios(fecha: date);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos para filtrado por fecha de registro
  void setDateFilter(DateFilterType filterType) {
    _currentFilter = filterType;
    _applyCurrentFilter();
    notifyListeners();
  }

  void _applyCurrentFilter() {
    final now = DateTime.now();
    
    switch (_currentFilter) {
      case DateFilterType.today:
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        _servicios = _allServicios.where((servicio) {
          return servicio.registrationDate.isAfter(today.subtract(const Duration(milliseconds: 1))) &&
                 servicio.registrationDate.isBefore(tomorrow);
        }).toList();
        _selectedDate = today.toIso8601String().split('T')[0];
        break;
        
      case DateFilterType.yesterday:
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final today = DateTime(now.year, now.month, now.day);
        _servicios = _allServicios.where((servicio) {
          return servicio.registrationDate.isAfter(yesterday.subtract(const Duration(milliseconds: 1))) &&
                 servicio.registrationDate.isBefore(today);
        }).toList();
        _selectedDate = yesterday.toIso8601String().split('T')[0];
        break;
        
      case DateFilterType.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final endOfWeek = startOfWeekDay.add(const Duration(days: 7));
        _servicios = _allServicios.where((servicio) {
          return servicio.registrationDate.isAfter(startOfWeekDay.subtract(const Duration(milliseconds: 1))) &&
                 servicio.registrationDate.isBefore(endOfWeek);
        }).toList();
        break;
        
      case DateFilterType.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        _servicios = _allServicios.where((servicio) {
          return servicio.registrationDate.isAfter(startOfMonth.subtract(const Duration(milliseconds: 1))) &&
                 servicio.registrationDate.isBefore(endOfMonth);
        }).toList();
        break;
        
      case DateFilterType.all:
        _servicios = List.from(_allServicios);
        break;
    }
    
    // Ordenar por fecha de registro (más recientes primero)
    _servicios.sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
    
    // Actualizar métricas si es necesario
    if (_currentFilter == DateFilterType.today) {
      loadDashboardMetrics(_selectedDate);
    }
  }

  String getFilterDisplayName() {
    switch (_currentFilter) {
      case DateFilterType.today:
        return 'Hoy';
      case DateFilterType.yesterday:
        return 'Ayer';
      case DateFilterType.thisWeek:
        return 'Esta Semana';
      case DateFilterType.thisMonth:
        return 'Este Mes';
      case DateFilterType.all:
        return 'Todos los Servicios';
    }
  }
}