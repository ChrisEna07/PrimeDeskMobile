import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/reparacion_model.dart';

class ReparacionRepository {
  final _supabase = Supabase.instance.client;

  // Iniciar una reparación (Basado en un agendamiento previo)
  Future<int> iniciarReparacion(Reparacion rep) async {
    final response = await _supabase
        .from('reparaciones')
        .insert(rep.toMap())
        .select()
        .single();
    return response['id_reparacion'];
  }

  // Registrar un avance (Lo que hace el mecánico día a día)
  Future<void> registrarAvance(ReparacionAvance avance) async {
    try {
      await _supabase.from('reparaciones_avances').insert(avance.toMap());
    } catch (e) {
      throw Exception("Error al registrar avance: $e");
    }
  }

  // Obtener historial de avances de una moto específica
  Future<List<Map<String, dynamic>>> obtenerHistorialAvances(
    int idReparacion,
  ) async {
    return await _supabase
        .from('reparaciones_avances')
        .select('*, empleados(nombre, apellido)')
        .eq('id_reparacion', idReparacion)
        .order('id_avance', ascending: false);
  }
}
