class Servicio {
  final String id;
  final String barberId;
  final String clientName;
  final String? clientPhone; // Nuevo campo
  final int typeService;
  final double price;
  final double? perquisiste;
  final int paymentType; // Nuevo campo: 1 = Efectivo, 2 = Transferencia
  final DateTime registrationDate;

  Servicio({
    required this.id,
    required this.barberId,
    required this.clientName,
    this.clientPhone,
    required this.typeService,
    required this.price,
    this.perquisiste,
    required this.paymentType,
    required this.registrationDate,
  });

  factory Servicio.fromMap(Map<String, dynamic> map) {
    return Servicio(
      id: map['id'].toString(),
      barberId: map['barber_id'].toString(),
      clientName: map['client_name'] ?? '',
      clientPhone: map['client_phone'] as String?,
      typeService: _parseToInt(map['type_service']),
      price: _parseToDouble(map['price']),
      perquisiste: map['perquisiste'] != null 
          ? _parseToDouble(map['perquisiste']) 
          : null,
      paymentType: _parseToInt(map['payment_type'] ?? 1), // Default a efectivo
      registrationDate: DateTime.parse(map['registration_date']),
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barber_id': barberId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'type_service': typeService,
      'price': price,
      'perquisiste': perquisiste,
      'payment_type': paymentType,
      'registration_date': registrationDate.toIso8601String(),
    };
  }

  // Método para copiar un servicio con algunos campos actualizados
  Servicio copyWith({
    String? id,
    String? barberId,
    String? clientName,
    String? clientPhone,
    int? typeService,
    double? price,
    double? perquisiste,
    int? paymentType,
    DateTime? registrationDate,
  }) {
    return Servicio(
      id: id ?? this.id,
      barberId: barberId ?? this.barberId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      typeService: typeService ?? this.typeService,
      price: price ?? this.price,
      perquisiste: perquisiste ?? this.perquisiste,
      paymentType: paymentType ?? this.paymentType,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }

  // Métodos helper para UI
  String get paymentTypeText {
    switch (paymentType) {
      case 1:
        return 'Efectivo';
      case 2:
        return 'Transferencia';
      default:
        return 'Efectivo';
    }
  }
}
