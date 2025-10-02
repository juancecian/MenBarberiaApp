class Servicio {
  final String id;
  final String barberoId;
  final String clienteNombre;
  final String? clienteTelefono; // Nuevo campo opcional
  final int tipoServicio; // Cambio a int para coincidir con Supabase
  final double precioServicio;
  final double propina;
  final double total; // Calculado: precioServicio + propina
  final int tipoPago; // Nuevo campo: 1 = Efectivo, 2 = Transferencia
  final DateTime registrationDate; // Cambio para coincidir con Supabase
  
  // Campos calculados para UI
  String get fecha => registrationDate.toIso8601String().split('T')[0];
  String get hora => '${registrationDate.hour.toString().padLeft(2, '0')}:${registrationDate.minute.toString().padLeft(2, '0')}';
  DateTime get createdAt => registrationDate; // Alias para compatibilidad

  Servicio({
    required this.id,
    required this.barberoId,
    required this.clienteNombre,
    this.clienteTelefono,
    required this.tipoServicio,
    required this.precioServicio,
    required this.propina,
    required this.tipoPago,
    required this.registrationDate,
  }) : total = precioServicio + propina;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barbero_id': barberoId,
      'cliente_nombre': clienteNombre,
      'cliente_telefono': clienteTelefono,
      'tipo_servicio': tipoServicio,
      'precio_servicio': precioServicio,
      'propina': propina,
      'total': total,
      'tipo_pago': tipoPago,
      'fecha': fecha,
      'hora': hora,
      'created_at': registrationDate.toIso8601String(),
    };
  }

  factory Servicio.fromMap(Map<String, dynamic> map) {
    return Servicio(
      id: map['id'] as String,
      barberoId: map['barbero_id'] as String,
      clienteNombre: map['cliente_nombre'] as String,
      clienteTelefono: map['cliente_telefono'] as String?,
      tipoServicio: _parseToInt(map['tipo_servicio']),
      precioServicio: _parseToDouble(map['precio_servicio']),
      propina: _parseToDouble(map['propina']),
      tipoPago: _parseToInt(map['tipo_pago'] ?? 1), // Default a efectivo
      registrationDate: DateTime.parse(map['created_at'] as String),
    );
  }

  // Métodos helper para conversión segura
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Servicio copyWith({
    String? id,
    String? barberoId,
    String? clienteNombre,
    String? clienteTelefono,
    int? tipoServicio,
    double? precioServicio,
    double? propina,
    int? tipoPago,
    DateTime? registrationDate,
  }) {
    return Servicio(
      id: id ?? this.id,
      barberoId: barberoId ?? this.barberoId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteTelefono: clienteTelefono ?? this.clienteTelefono,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      precioServicio: precioServicio ?? this.precioServicio,
      propina: propina ?? this.propina,
      tipoPago: tipoPago ?? this.tipoPago,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }

  // Métodos helper para UI
  String get tipoPagoTexto {
    switch (tipoPago) {
      case 1:
        return 'Efectivo';
      case 2:
        return 'Transferencia';
      default:
        return 'Efectivo';
    }
  }
}