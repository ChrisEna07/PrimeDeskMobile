// lib/models/user_management_models.dart

// Tabla Usuarios
class Usuario {
  final int? idUsuario;
  final int idRol;
  final String correo;
  final String contrasena;
  final bool estado;

  Usuario({
    this.idUsuario,
    required this.idRol,
    required this.correo,
    required this.contrasena,
    this.estado = true,
  });

  Map<String, dynamic> toMap() => {
    'id_rol': idRol,
    'correo': correo,
    'contrasena': contrasena,
    'estado': estado,
  };
}

// Tabla Empleados o Clientes (Comparten campos similares en tu script)
class DatosPersonales {
  final String nombre;
  final String apellido;
  final String tipoDocumento;
  final String documento;
  final String telefono;
  final String direccion;
  final String barrio;
  final DateTime fechaNacimiento;

  DatosPersonales({
    required this.nombre,
    required this.apellido,
    required this.tipoDocumento,
    required this.documento,
    required this.telefono,
    required this.direccion,
    required this.barrio,
    required this.fechaNacimiento,
  });

  Map<String, dynamic> toMap(int idUsuario, bool isEmpleado) {
    var map = {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'tipodocumento': tipoDocumento,
      'documento': documento,
      'telefono': telefono,
      'barrio': barrio,
      'direccion': direccion,
      'fechanacimiento': fechaNacimiento.toIso8601String(),
    };
    if (isEmpleado) map['fechaingreso'] = DateTime.now().toIso8601String();
    return map;
  }
}
