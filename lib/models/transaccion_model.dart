// Modelo para la tabla Compras (Insumos para la moto)
class Compra {
  final int? idCompra;
  final int idProveedor;
  final int idMotocicleta;
  final double total;
  final String? notas;

  Compra({
    this.idCompra,
    required this.idProveedor,
    required this.idMotocicleta,
    required this.total,
    this.notas,
  });

  Map<String, dynamic> toMap() => {
    'ID_Proveedor': idProveedor,
    'ID_Motocicleta': idMotocicleta,
    'Total': total,
    'Notas': notas,
  };
}

// Modelo para la tabla Ventas (Factura final)
class Venta {
  final int? idVenta;
  final int idReparacion;
  final int idEmpleado;
  final int idMotocicleta;
  final double total;
  final String? observaciones;

  Venta({
    this.idVenta,
    required this.idReparacion,
    required this.idEmpleado,
    required this.idMotocicleta,
    required this.total,
    this.observaciones,
  });

  Map<String, dynamic> toMap() => {
    'ID_Reparacion': idReparacion,
    'ID_Empleado': idEmpleado,
    'ID_Motocicleta': idMotocicleta,
    'Total': total,
    'Observaciones': observaciones,
  };
}
