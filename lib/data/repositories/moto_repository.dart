import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/motocicleta_model.dart'; // Subimos dos niveles para llegar a models

class MotoRepository {
  final _supabase = Supabase.instance.client;

  // Insertar en la tabla 'motocicletas' de tu SQL
  Future<void> registrarMoto(Motocicleta moto) async {
    try {
      await _supabase.from('motocicletas').insert(moto.toMap());
    } catch (e) {
      throw Exception("Error en DB: $e");
    }
  }

  // Obtener motos de un cliente
  Future<List<Map<String, dynamic>>> obtenerMotosPorCliente(
    int idCliente,
  ) async {
    return await _supabase
        .from('motocicletas')
        .select()
        .eq('id_cliente', idCliente);
  }
}
