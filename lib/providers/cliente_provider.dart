import 'package:flutter/foundation.dart';
import '../models/cliente.dart';
import '../core/database/database_service.dart';

class ClienteProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Cliente> _clientes = [];
  List<Cliente> _clientesSugeridos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Cliente> get clientes => _clientes;
  List<Cliente> get clientesSugeridos => _clientesSugeridos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga todos los clientes desde la base de datos
  Future<void> loadClientes() async {
    _setLoading(true);
    _clearError();
    
    try {
      _clientes = await _databaseService.getClientes();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar clientes: $e');
      debugPrint('Error loading clientes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca clientes por nombre para autocompletado
  Future<void> buscarClientes(String query) async {
    if (query.trim().isEmpty) {
      _clientesSugeridos = [];
      notifyListeners();
      return;
    }

    try {
      _clientesSugeridos = await _databaseService.buscarClientesPorNombre(query.trim());
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching clientes: $e');
      _clientesSugeridos = [];
      notifyListeners();
    }
  }

  /// Obtiene un cliente por nombre exacto
  Future<Cliente?> getClientePorNombre(String nombre) async {
    try {
      return await _databaseService.getClientePorNombre(nombre);
    } catch (e) {
      debugPrint('Error getting cliente by name: $e');
      return null;
    }
  }

  /// Crea o actualiza un cliente (upsert)
  /// Retorna el cliente creado o actualizado
  Future<Cliente?> upsertCliente(String nombre, String? telefono, DateTime fechaAsistencia) async {
    if (nombre.trim().isEmpty) {
      _setError('El nombre del cliente es requerido');
      return null;
    }

    _clearError();
    
    try {
      final cliente = await _databaseService.upsertCliente(
        nombre.trim(), 
        telefono?.trim().isEmpty == true ? null : telefono?.trim(),
        fechaAsistencia,
      );
      
      // Actualizar la lista local
      await loadClientes();
      
      return cliente;
    } catch (e) {
      _setError('Error al guardar cliente: $e');
      debugPrint('Error upserting cliente: $e');
      return null;
    }
  }

  /// Agrega un nuevo cliente
  Future<bool> addCliente(Cliente cliente) async {
    _clearError();
    
    try {
      await _databaseService.insertCliente(cliente);
      await loadClientes();
      return true;
    } catch (e) {
      _setError('Error al agregar cliente: $e');
      debugPrint('Error adding cliente: $e');
      return false;
    }
  }

  /// Actualiza un cliente existente
  Future<bool> updateCliente(Cliente cliente) async {
    _clearError();
    
    try {
      await _databaseService.updateCliente(cliente);
      await loadClientes();
      return true;
    } catch (e) {
      _setError('Error al actualizar cliente: $e');
      debugPrint('Error updating cliente: $e');
      return false;
    }
  }

  /// Elimina un cliente
  Future<bool> deleteCliente(String id) async {
    _clearError();
    
    try {
      await _databaseService.deleteCliente(id);
      await loadClientes();
      return true;
    } catch (e) {
      _setError('Error al eliminar cliente: $e');
      debugPrint('Error deleting cliente: $e');
      return false;
    }
  }

  /// Limpia las sugerencias de búsqueda
  void clearSugerencias() {
    _clientesSugeridos = [];
    notifyListeners();
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
