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
      id: json['ID_Agendamiento'],
      idMotocicleta: json['ID_Motocicleta'],
      idEmpleado: json['ID_Empleado'],
      dia: DateTime.parse(json['Dia']),
      horaInicio: json['HoraInicio'],
      horaFin: json['HoraFin'],
      notas: json['Notas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_Motocicleta': idMotocicleta,
      'ID_Empleado': idEmpleado,
      'Dia': dia.toIso8601String().split('T')[0], // YYYY-MM-DD
      'HoraInicio': horaInicio,
      'HoraFin': horaFin,
      'Notas': notas,
    };
  }
}
