import 'package:supabase_flutter/supabase_flutter.dart';

class BaseRepository {
  final _client = Supabase.instance.client;

  // Método genérico para insertar en cualquier tabla (Clientes, Motos, etc.)
  Future<void> insertar(String tabla, Map<String, dynamic> datos) async {
    await _client.from(tabla).insert(datos);
  }

  // Método para listar datos (útil para dropdowns de Empleados o Roles)
  Future<List<Map<String, dynamic>>> consultar(String tabla) async {
    return await _client.from(tabla).select();
  }
}
