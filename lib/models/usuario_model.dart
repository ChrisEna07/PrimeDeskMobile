class Usuario {
  final int idUsuario;
  final int idRol;
  final String correo;
  final bool estado;
  
  // Datos del Empleado o Cliente asociado
  final String nombre;
  final String apellido;
  final String? documento;
  final String? telefono;
  final String? direccion;
  final String? barrio;
  final String? foto;

  Usuario({
    required this.idUsuario,
    required this.idRol,
    required this.correo,
    required this.estado,
    required this.nombre,
    required this.apellido,
    this.documento,
    this.telefono,
    this.direccion,
    this.barrio,
    this.foto,
  });

  factory Usuario.fromMap(Map<String, dynamic> map, Map<String, dynamic> profileMap) {
    // Manejar nombres de campos que pueden variar entre tablas 'clientes' y 'empleados'
    return Usuario(
      idUsuario: map['id_usuario'],
      idRol: map['id_rol'],
      correo: map['correo'],
      estado: map['estado'] ?? true,
      nombre: profileMap['nombre'] ?? profileMap['nombre_empleado'] ?? profileMap['nombre_cliente'] ?? '',
      apellido: profileMap['apellido'] ?? profileMap['apellido_empleado'] ?? profileMap['apellido_cliente'] ?? '',
      documento: profileMap['documento'] ?? profileMap['doc_empleado'] ?? profileMap['documento_cliente'],
      telefono: profileMap['telefono'] ?? profileMap['tel_empleado'] ?? profileMap['telefono_cliente'],
      direccion: profileMap['direccion'] ?? profileMap['dir_empleado'],
      barrio: profileMap['barrio'] ?? profileMap['barrio_empleado'],
      foto: profileMap['foto'] ?? profileMap['foto_empleado'] ?? profileMap['foto_cliente'],
    );
  }

  bool get isAdmin => idRol == 1; 
  String get nombreCompleto => '$nombre $apellido';
}
