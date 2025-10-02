import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/barbero.dart';
import '../../models/servicio.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'men_barberia.db';
  static const int _databaseVersion = 2;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de barberos
    await db.execute('''
      CREATE TABLE barberos(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        telefono TEXT,
        activo INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de servicios
    await db.execute('''
      CREATE TABLE servicios(
        id TEXT PRIMARY KEY,
        barbero_id TEXT NOT NULL,
        cliente_nombre TEXT NOT NULL,
        cliente_telefono TEXT,
        tipo_servicio TEXT NOT NULL,
        precio_servicio REAL NOT NULL,
        propina REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL,
        tipo_pago INTEGER NOT NULL DEFAULT 1,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (barbero_id) REFERENCES barberos (id)
      )
    ''');

    // Insertar datos de prueba
    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar nuevos campos a la tabla servicios
      await db.execute('ALTER TABLE servicios ADD COLUMN cliente_telefono TEXT');
      await db.execute('ALTER TABLE servicios ADD COLUMN tipo_pago INTEGER NOT NULL DEFAULT 1');
    }
  }

  Future<void> _insertSampleData(Database db) async {
    // Barberos de prueba
    final barberos = [
      {
        'id': 'barbero1',
        'nombre': 'Carlos Mendoza',
        'telefono': '+58 424-555-0001',
        'activo': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'barbero2',
        'nombre': 'Miguel Rodriguez',
        'telefono': '+58 414-555-0002',
        'activo': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'barbero3',
        'nombre': 'Luis Torres',
        'telefono': '+58 426-555-0003',
        'activo': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (var barbero in barberos) {
      await db.insert('barberos', barbero);
    }

    // Servicios de prueba
    final servicios = [
      {
        'id': 'servicio1',
        'barbero_id': 'barbero1',
        'cliente_nombre': 'Juan Pérez',
        'cliente_telefono': '+58 424-123-4567',
        'tipo_servicio': 'Corte',
        'precio_servicio': 25.0,
        'propina': 5.0,
        'total': 30.0,
        'tipo_pago': 1, // Efectivo
        'fecha': DateTime.now().toIso8601String().split('T')[0],
        'hora': '09:30',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'servicio2',
        'barbero_id': 'barbero2',
        'cliente_nombre': 'Pedro García',
        'cliente_telefono': null,
        'tipo_servicio': 'Corte + Barba',
        'precio_servicio': 40.0,
        'propina': 8.0,
        'total': 48.0,
        'tipo_pago': 2, // Transferencia
        'fecha': DateTime.now().toIso8601String().split('T')[0],
        'hora': '11:15',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (var servicio in servicios) {
      await db.insert('servicios', servicio);
    }
  }

  // CRUD Barberos
  Future<List<Barbero>> getBarberos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'barberos',
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) => Barbero.fromMap(maps[i]));
  }

  Future<List<Barbero>> getBarberosActivos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'barberos',
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) => Barbero.fromMap(maps[i]));
  }

  Future<void> insertBarbero(Barbero barbero) async {
    final db = await database;
    await db.insert('barberos', barbero.toMap());
  }

  Future<void> updateBarbero(Barbero barbero) async {
    final db = await database;
    await db.update(
      'barberos',
      barbero.toMap(),
      where: 'id = ?',
      whereArgs: [barbero.id],
    );
  }

  Future<void> deleteBarbero(String id) async {
    final db = await database;
    await db.update(
      'barberos',
      {'activo': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Servicios
  Future<List<Servicio>> getServicios({String? fecha}) async {
    final db = await database;
    String where = '';
    List<dynamic> whereArgs = [];
    
    if (fecha != null) {
      where = 'fecha = ?';
      whereArgs = [fecha];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'servicios',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'fecha DESC, hora DESC',
    );

    return List.generate(maps.length, (i) => Servicio.fromMap(maps[i]));
  }

  Future<void> insertServicio(Servicio servicio) async {
    final db = await database;
    await db.insert('servicios', servicio.toMap());
  }

  Future<void> updateServicio(Servicio servicio) async {
    final db = await database;
    await db.update(
      'servicios',
      servicio.toMap(),
      where: 'id = ?',
      whereArgs: [servicio.id],
    );
  }

  Future<void> deleteServicio(String id) async {
    final db = await database;
    await db.delete(
      'servicios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métricas del dashboard
  Future<Map<String, dynamic>> getDashboardMetrics(String fecha) async {
    final db = await database;
    
    final serviciosHoy = await db.query(
      'servicios',
      where: 'fecha = ?',
      whereArgs: [fecha],
    );

    double ingresosTotales = 0;
    Map<String, int> barberoServicios = {};

    for (var servicio in serviciosHoy) {
      ingresosTotales += servicio['total'] as double;
      String barberoId = servicio['barbero_id'] as String;
      barberoServicios[barberoId] = (barberoServicios[barberoId] ?? 0) + 1;
    }

    String barberoMasActivo = '';
    int maxServicios = 0;
    for (var entry in barberoServicios.entries) {
      if (entry.value > maxServicios) {
        maxServicios = entry.value;
        barberoMasActivo = entry.key;
      }
    }

    // Obtener nombre del barbero más activo
    String nombreBarberoActivo = '';
    if (barberoMasActivo.isNotEmpty) {
      final barbero = await db.query(
        'barberos',
        where: 'id = ?',
        whereArgs: [barberoMasActivo],
      );
      if (barbero.isNotEmpty) {
        nombreBarberoActivo = barbero.first['nombre'] as String;
      }
    }

    return {
      'totalServicios': serviciosHoy.length,
      'ingresosTotales': ingresosTotales,
      'barberoMasActivo': nombreBarberoActivo,
    };
  }

  Future<List<String>> buscarClientes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'servicios',
      columns: ['DISTINCT cliente_nombre'],
      where: 'cliente_nombre LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'cliente_nombre ASC',
      limit: 10,
    );

    return maps.map((map) => map['cliente_nombre'] as String).toList();
  }
}