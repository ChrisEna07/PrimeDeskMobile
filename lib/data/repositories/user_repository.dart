import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    final String baseUrl = dotenv.env['API_URL'] ?? 'https://api.rmmedellin.site';
    final Uri url = Uri.parse('$baseUrl/api/auth/register');

    final body = {
      'correo': email,
      'contrasena': password,
      'id_rol': idRol,
      'nombre': datosPersonales['nombre'],
      'apellido': datosPersonales['apellido'],
      'documento': datosPersonales['documento'],
      'telefono': datosPersonales['telefono'],
      // Campos adicionales si el backend los acepta
      'tipo_documento': datosPersonales['tipodocumento'],
      'barrio': datosPersonales['barrio'],
      'direccion': datosPersonales['direccion'],
      'fecha_nacimiento': datosPersonales['fechanacimiento'],
    };

    print('DEBUG: Registrar usuario body: ${jsonEncode(body)}');

    final http.Response response;
    try {
      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print('DEBUG: Registrar usuario response: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('DEBUG: Registrar usuario error de conexion: $e');
      throw Exception("Error de conexión con el servidor: $e");
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        String msg = errorData['message'] ?? errorData['error'] ?? 'Error desconocido al registrar usuario';
        if (errorData['errors'] != null && errorData['errors'] is List && (errorData['errors'] as List).isNotEmpty) {
          final firstError = errorData['errors'][0];
          msg = firstError['mensaje'] ?? msg;
        }
        throw Exception(msg);
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception("Error de validación del servidor");
      }
    }
  }
}
