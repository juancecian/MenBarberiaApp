class Cliente {
  final String id;
  final String nombre;
  final String? telefono;
  final DateTime? ultimaAsistencia;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cliente({
    required this.id,
    required this.nombre,
    this.telefono,
    this.ultimaAsistencia,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'ultima_asistencia': ultimaAsistencia?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      telefono: map['telefono'] as String?,
      ultimaAsistencia: map['ultima_asistencia'] != null 
          ? DateTime.parse(map['ultima_asistencia'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Cliente copyWith({
    String? id,
    String? nombre,
    String? telefono,
    DateTime? ultimaAsistencia,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      ultimaAsistencia: ultimaAsistencia ?? this.ultimaAsistencia,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cliente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Cliente(id: $id, nombre: $nombre, telefono: $telefono)';
  }
}
