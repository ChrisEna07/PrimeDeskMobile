// Modelo para la tabla Reparaciones
class Reparacion {
  final int? idReparacion;
  final int idMotocicleta;
  final int idAgendamiento;
  final DateTime? fecha;
  final String? observaciones;
  final String tipoServicio; // 'Directo' por defecto en SQL
  final String estado; // 'Activo' por defecto en SQL

  Reparacion({
    this.idReparacion,
    required this.idMotocicleta,
    required this.idAgendamiento,
    this.fecha,
    this.observaciones,
    this.tipoServicio = 'Directo',
    this.estado = 'Activo',
  });

  Map<String, dynamic> toMap() => {
    'ID_Motocicleta': idMotocicleta,
    'ID_Agendamiento': idAgendamiento,
    'Observaciones': observaciones,
    'TipoServicio': tipoServicio,
    'Estado': estado,
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
    'ID_Reparacion': idReparacion,
    'ID_Empleado': idEmpleado,
    'Descripcion': descripcion,
  };
}
