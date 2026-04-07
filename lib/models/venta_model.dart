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
      id: json['ID_Venta'],
      idReparacion: json['ID_Reparacion'],
      idEmpleado: json['ID_Empleado'],
      idMotocicleta: json['ID_Motocicleta'],
      fecha: DateTime.parse(json['Fecha']),
      total: (json['Total'] ?? 0).toDouble(),
      observaciones: json['Observaciones'],
      estado: json['Estado'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_Reparacion': idReparacion,
      'ID_Empleado': idEmpleado,
      'ID_Motocicleta': idMotocicleta,
      'Fecha': fecha.toIso8601String().split('T')[0],
      'Total': total,
      'Observaciones': observaciones,
      'Estado': estado,
    };
  }
}
