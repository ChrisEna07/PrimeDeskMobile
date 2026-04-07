class Producto {
  final int? id;
  final int idCategoria;
  final String nombre;
  final String marca;
  final int cantidad;
  final String? descripcion;
  final bool estado;

  Producto({
    this.id,
    required this.idCategoria,
    required this.nombre,
    required this.marca,
    required this.cantidad,
    this.descripcion,
    this.estado = true,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id_producto'],
      idCategoria: json['id_categoria'],
      nombre: json['nombre'],
      marca: json['marca'],
      cantidad: json['cantidad'] ?? 0,
      descripcion: json['descripcion'],
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_categoria': idCategoria,
      'nombre': nombre,
      'marca': marca,
      'cantidad': cantidad,
      'descripcion': descripcion,
      'estado': estado,
    };
  }
}
