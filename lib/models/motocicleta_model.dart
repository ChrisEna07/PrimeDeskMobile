class Motocicleta {
  final int? id;
  final int idCliente;
  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final String color;
  final int motor;
  final int kilometraje;
  final bool estado;

  Motocicleta({
    this.id,
    required this.idCliente,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    required this.color,
    required this.motor,
    this.kilometraje = 0,
    this.estado = true,
  });

  factory Motocicleta.fromJson(Map<String, dynamic> json) {
    return Motocicleta(
      id: json['id_motocicleta'],
      idCliente: json['id_cliente'],
      marca: json['marca'],
      modelo: json['modelo'],
      anio: json['anio'],
      placa: json['placa'],
      color: json['color'],
      motor: json['motor'],
      kilometraje: json['kilometraje'] ?? 0,
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_cliente': idCliente,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'placa': placa,
      'color': color,
      'motor': motor,
      'kilometraje': kilometraje,
      'estado': estado,
    };
  }
}
