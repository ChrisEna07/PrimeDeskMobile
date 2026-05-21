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
    try {
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
        'tipodocumento': datosPersonales['tipodocumento'],
        'barrio': datosPersonales['barrio'],
        'direccion': datosPersonales['direccion'],
        'fechanacimiento': datosPersonales['fechanacimiento'],
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? errorData['message'] ?? 'Error desconocido al registrar usuario');
      }
    } catch (e) {
      throw Exception("Error de conexión con el servidor: $e");
    }
  }
}
