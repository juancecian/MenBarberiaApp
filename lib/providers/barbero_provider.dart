import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/barbero.dart';
import '../core/database/database_service.dart';
import '../core/services/supabase_service.dart';

class BarberoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService();
  List<Barbero> _barberos = [];
  List<Barbero> _barberosActivos = []; 
  bool _isLoading = false;
  String? _error;

  List<Barbero> get barberos => _barberos;
  List<Barbero> get barberosActivos => _barberosActivos;
  bool get isLoading => _isLoading;
  Future<void> loadBarberos() async {
    _isLoading = true;
    _error = null;
    
    try {
      // 1. Intentar cargar desde Supabase primero
      try {
        final supabaseBarberos = await _supabaseService.getBarberos();
        
        // Convertir modelos de Supabase a locales
        _barberos = supabaseBarberos.map((sb) => Barbero(
          id: sb.id,
          nombre: sb.name,
          telefono: null, // No disponible en Supabase
          activo: sb.isActive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )).toList();
        
        // Actualizar caché local
        await _updateLocalCache(_barberos);
        
      } catch (e) {
        // Si falla Supabase, cargar desde caché local
        print('Error cargando desde Supabase, usando caché local: $e');
        _barberos = await _databaseService.getBarberos();
      }
      
      _barberosActivos = _barberos.where((b) => b.activo).toList();
      
      // Safe to notify here as we're in async context
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error al cargar barberos: $e';
      // Safe to notify here as we're in async context
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } finally {
      _isLoading = false;
      // Safe to notify here as we're in async context
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Actualiza el caché local con los barberos de Supabase
  Future<void> _updateLocalCache(List<Barbero> barberos) async {
    try {
      // Limpiar caché existente y agregar nuevos
      final localBarberos = await _databaseService.getBarberos();
      
      for (final barbero in barberos) {
        final exists = localBarberos.any((b) => b.id == barbero.id);
        if (exists) {
          await _databaseService.updateBarbero(barbero);
        } else {
          await _databaseService.insertBarbero(barbero);
        }
      }
    } catch (e) {
      print('Error actualizando caché local de barberos: $e');
    }
  }

  Future<bool> addBarbero(Barbero barbero) async {
    _error = null;
    try {
      // 1. Guardar directamente en Supabase (barberos son datos maestros)
      await _supabaseService.insertBarbero(
        barberId: barbero.id,
        name: barbero.nombre,
        isActive: barbero.activo,
      );
      
      // 2. Recargar barberos desde Supabase
      await loadBarberos();
      
      return true;
    } catch (e) {
      _error = 'Error al agregar barbero: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBarbero(Barbero barbero) async {
    _error = null;
    try {
      await _databaseService.updateBarbero(barbero);
      await loadBarberos();
      return true;
    } catch (e) {
      _error = 'Error al actualizar barbero: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBarbero(String id) async {
    _error = null;
    try {
      await _databaseService.deleteBarbero(id);
      await loadBarberos();
      return true;
    } catch (e) {
      _error = 'Error al eliminar barbero: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}