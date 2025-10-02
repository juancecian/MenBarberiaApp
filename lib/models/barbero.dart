class Barbero {
  final String id;
  final String nombre;
  final String? telefono;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Barbero({
    required this.id,
    required this.nombre,
    this.telefono,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'activo': activo ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Barbero.fromMap(Map<String, dynamic> map) {
    return Barbero(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      telefono: map['telefono'] as String?,
      activo: (map['activo'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Barbero copyWith({
    String? id,
    String? nombre,
    String? telefono,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Barbero(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}