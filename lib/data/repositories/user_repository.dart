import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final _supabase = Supabase.instance.client;

  Future<void> registrarUsuarioCompleto({
    required String email,
    required String password,
    required int idRol,
    required Map<String, dynamic> datosPersonales,
  }) async {
    try {
      // 1. Insertar en la tabla 'Usuarios'
      // Tu script: ID_Usuario (SERIAL), ID_Rol, Correo, Contrasena, Estado
      final userResponse = await _supabase
          .from('usuarios')
          .insert({
            'id_rol': idRol,
            'correo': email,
            'contrasena':
                password, // Nota: En producción usa auth.signUp de Supabase
            'estado': true,
          })
          .select()
          .single();

      final int newUserId = userResponse['id_usuario'];

      // 2. Decidir en qué tabla insertar según el Rol
      // Según tu lógica: Roles 1,2,3 son Staff, Rol 4 es Cliente
      if (idRol == 4) {
        await _supabase.from('clientes').insert({
          'id_usuario': newUserId,
          ...datosPersonales, // Trae Nombre, Apellido, Telefono, etc.
        });
      } else {
        await _supabase.from('empleados').insert({
          'id_usuario': newUserId,
          'fecha_ingreso': DateTime.now().toIso8601String(),
          ...datosPersonales,
        });
      }
    } catch (e) {
      throw Exception("Error al guardar en la base de datos: $e");
    }
  }
}
