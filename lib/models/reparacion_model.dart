// Modelo para la tabla Reparaciones
class Reparacion {
  final int? idReparacion;
  final int idMotocicleta;
  final int idAgendamiento;
  final String? observaciones;
  final String estado;

  Reparacion({
    this.idReparacion,
    required this.idMotocicleta,
    required this.idAgendamiento,
    this.observaciones,
    this.estado = 'Pendiente',
  });

  Map<String, dynamic> toMap() => {
    'id_motocicleta': idMotocicleta,
    'id_agendamiento': idAgendamiento,
    'observaciones': observaciones,
    'estado': estado,
  };
}

// Modelo para la tabla Reparaciones_Avances
class ReparacionAvance {
  final int? idAvance;
  final int idReparacion;
  final int idEmpleado;
  final String descripcion;
  final DateTime? fecha;

  ReparacionAvance({
    this.idAvance,
    required this.idReparacion,
    required this.idEmpleado,
    required this.descripcion,
    this.fecha,
  });

  Map<String, dynamic> toMap() => {
    'id_reparacion': idReparacion,
    'id_empleado': idEmpleado,
    'descripcion': descripcion,
  };
}
