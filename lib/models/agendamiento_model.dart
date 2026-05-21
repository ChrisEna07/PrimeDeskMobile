class Agendamiento {
  final int? id;
  final int idMotocicleta;
  final int idEmpleado;
  final DateTime dia;
  final String horaInicio;
  final String horaFin;
  final String? notas;

  Agendamiento({
    this.id,
    required this.idMotocicleta,
    required this.idEmpleado,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    this.notas,
  });

  factory Agendamiento.fromJson(Map<String, dynamic> json) {
    return Agendamiento(
      id: json['id_agendamiento'],
      idMotocicleta: json['id_motocicleta'],
      idEmpleado: json['id_empleado'],
      dia: DateTime.parse(json['dia']),
      horaInicio: json['horainicio'],
      horaFin: json['horafin'],
      notas: json['notas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_motocicleta': idMotocicleta,
      'id_empleado': idEmpleado,
      'dia': dia.toIso8601String().split('T')[0],
      'horainicio': horaInicio,
      'horafin': horaFin,
      'notas': notas,
    };
  }
}
