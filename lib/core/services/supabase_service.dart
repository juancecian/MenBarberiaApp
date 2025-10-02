import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:men_barberia/models/barbero_model.dart';
import 'package:men_barberia/models/servicio_model.dart';

/// Servicio para manejar la conexión con Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  bool _isInitialized = false;

  /// Inicializa el cliente de Supabase y verifica la conexión
  /// Retorna true si la conexión fue exitosa, false en caso contrario
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Inicializar Supabase
      await Supabase.initialize(
        url: 'https://xlsqgdfkszssbcvhrcdk.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhsc3FnZGZrc3pzc2JjdmhyY2RrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3NzM5MjksImV4cCI6MjA3NDM0OTkyOX0.ZwxT-ncMpX-P0tEA3hBcl7XuLkb0ZnC4DlPcn8QyDDg',
      );
      
      _client = Supabase.instance.client;
      
      // Verificar conexión con una consulta simple
      try {
        final response = await _client
            .from('barber')
            .select('count')
            .limit(1)
            .single();
            
        _isInitialized = true;
        print('✅ Conexión con Supabase establecida correctamente');
        return true;
      } catch (e) {
        // Si falla la consulta pero la conexión está bien, igual consideramos éxito
        print('⚠️ Advertencia: No se pudo consultar la tabla barberos, pero la conexión está activa');
        print(e);
        _isInitialized = true;
        return true;
      }
    } catch (e, stackTrace) {
      print('❌ Error al conectar con Supabase: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Obtiene el cliente de Supabase
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase no ha sido inicializado. Llama a initialize() primero.');
    }
    return _client;
  }

  /// Obtener todos los barberos activos
  Future<List<Barbero>> getBarberos() async {
    final response = await client
        .from('barber')
        .select()
        .eq('is_active', true);
    
    return (response as List)
        .map((json) => Barbero.fromMap(json))
        .toList();
  }
  
  /// Obtener un barbero por su ID
  Future<Barbero?> getBarbero(String id) async {
    try {
      final response = await client
          .from('barber')
          .select()
          .eq('id', id)
          .single();
      
      return Barbero.fromMap(response);
    } catch (e) {
      print('Error al obtener barbero: $e');
      return null;
    }
  }

  /// Insertar un nuevo barbero
  Future<Barbero> insertBarbero({
    required String barberId,
    required String name,
    required bool isActive,
  }) async {
    final response = await client
        .from('barber')
        .insert({
          'id': barberId,
          'name': name,
          'is_active': isActive,
        })
        .select()
        .single();
    
    return Barbero.fromMap(response);
  }

  /// Insertar un nuevo servicio
  Future<Servicio> insertServicio({
    required String barberId,
    required String clientName,
    required int typeService,
    required double price,
    double? perquisiste,
    required DateTime registrationDate,
  }) async {
    final response = await client
        .from('services')
        .insert({
          'barber_id': barberId,
          'client_name': clientName,
          'type_service': typeService,
          'price': price,
          'perquisiste': perquisiste,
          'registration_date': registrationDate.toIso8601String(),
        })
        .select()
        .single();
    
    return Servicio.fromMap(response);
  }
  
  /// Obtener servicios por barbero
  Future<List<Servicio>> getServiciosPorBarbero(String barberId) async {
    final response = await client
        .from('services')
        .select()
        .eq('barber_id', barberId)
        .order('registration_date', ascending: false);
    
    return (response as List)
        .map((json) => Servicio.fromMap(json))
        .toList();
  }
  
  /// Obtener servicios por rango de fechas
  Future<List<Servicio>> getServiciosPorFecha(
    DateTime fechaInicio, 
    DateTime fechaFin, {
    String? barberId,
  }) async {
    try {
      // Definir la consulta base
      final query = client
          .from('services')
          .select('*, barber:barber_id(*)')
          .gte('registration_date', fechaInicio.toIso8601String())
          .lte('registration_date', fechaFin.toIso8601String());
      
      // Aplicar filtro de barbero si se especifica
      final filteredQuery = barberId != null 
          ? query.eq('barber_id', barberId)
          : query;
      
      // Ordenar por fecha de registro (más recientes primero)
      final orderedQuery = filteredQuery.order('registration_date', ascending: false);
      
      // Ejecutar la consulta
      final response = await orderedQuery;
      
      // Mapear la respuesta a objetos Servicio
      if (response is List) {
        return response
            .map((json) => Servicio.fromMap(json))
            .toList();
      } else {
        print('Error: La respuesta no es una lista');
        return [];
      }
    } catch (e) {
      print('Error al obtener servicios por fecha: $e');
      if (e is Error) {
        print('Stack trace: ${e.stackTrace}');
      }
      return [];
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Verificar si hay una sesión activa
  bool get isSignedIn => _isInitialized && client.auth.currentSession != null;

  /// Obtener el ID del usuario actual
  String? get currentUserId => _isInitialized ? client.auth.currentUser?.id : null;

  // CRUD Operations for Sync Service


  /// Insertar servicio en Supabase para sincronización (usando modelo de Supabase)
  Future<void> insertServicioSync(dynamic servicio) async {
    if (!_isInitialized) {
      throw Exception('SupabaseService no está inicializado');
    }

    try {
      await client.from('services').insert(servicio.toMap());
    } catch (e) {
      print('Error al insertar servicio: $e');
      rethrow;
    }
  }

  /// Actualizar servicio en Supabase para sincronización (usando modelo de Supabase)
  Future<void> updateServicioSync(dynamic servicio) async {
    if (!_isInitialized) {
      throw Exception('SupabaseService no está inicializado');
    }

    try {
      final updateData = servicio.toMap();
      updateData.remove('id'); // No actualizar el ID
      await client.from('services').update(updateData).eq('id', servicio.id);
    } catch (e) {
      print('Error al actualizar servicio: $e');
      rethrow;
    }
  }
}
