class Barbero {
  final String id;
  final String name;
  final bool isActive;

  Barbero({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory Barbero.fromMap(Map<String, dynamic> map) {
    return Barbero(
      id: map['id'].toString(),
      name: map['name'] ?? 'Sin nombre',
      isActive: map['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
    };
  }

  Barbero copyWith({
    String? id,
    String? name,
    bool? isActive,
  }) {
    return Barbero(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
