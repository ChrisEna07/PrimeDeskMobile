class Venta {
  final int? id;
  final int idReparacion;
  final int idEmpleado;
  final int idMotocicleta;
  final DateTime fecha;
  final double total;
  final String? observaciones;
  final bool estado;

  Venta({
    this.id,
    required this.idReparacion,
    required this.idEmpleado,
    required this.idMotocicleta,
    required this.fecha,
    required this.total,
    this.observaciones,
    this.estado = true,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id_venta'],
      idReparacion: json['id_reparacion'],
      idEmpleado: json['id_empleado'],
      idMotocicleta: json['id_motocicleta'],
      fecha: DateTime.parse(json['fecha']),
      total: (json['total'] ?? 0).toDouble(),
      observaciones: json['observaciones'],
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_reparacion': idReparacion,
      'id_empleado': idEmpleado,
      'id_motocicleta': idMotocicleta,
      'fecha': fecha.toIso8601String().split('T')[0],
      'total': total,
      'observaciones': observaciones,
      'estado': estado,
    };
  }
}
