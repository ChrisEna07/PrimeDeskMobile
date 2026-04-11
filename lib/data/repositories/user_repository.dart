import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/hash_helper.dart';

class UserRepository {
  final _supabase = Supabase.instance.client;

  Future<void> registrarUsuarioCompleto({
    required String email,
    required String password,
    required int idRol,
    required Map<String, dynamic> datosPersonales,
  }) async {
    try {
      // 1. Hashear la contraseña para coincidir con el sistema Web (React)
      final String hashedPass = HashHelper.hashPassword(password);

      // 2. Insertar en la tabla 'Usuarios'
      final userResponse = await _supabase
          .from('usuarios')
          .insert({
            'id_rol': idRol,
            'correo': email,
            'contrasena': hashedPass,
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
