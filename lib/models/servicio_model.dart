class Servicio {
  final int? id;
  final String nombre;
  final String? descripcion;
  final bool estado;

  Servicio({
    this.id,
    required this.nombre,
    this.descripcion,
    this.estado = true,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id_servicio'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
    };
  }
}
