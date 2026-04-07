import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/agendamiento_model.dart';

class AgendamientoRepository {
  final _supabase = Supabase.instance.client;

  Future<void> crearCita(Agendamiento cita) async {
    try {
      await _supabase.from('agendamientos').insert(cita.toMap());
    } catch (e) {
      throw Exception("Error al agendar: $e");
    }
  }

  // Para ver la agenda del día
  Future<List<Map<String, dynamic>>> obtenerAgendaPorDia(DateTime fecha) async {
    final fechaStr = fecha.toIso8601String().split('T')[0];
    return await _supabase
        .from('agendamientos')
        .select('''
          *,
          motocicletas(Placa, Marca, Modelo),
          empleados(Nombre, Apellido)
        ''')
        .eq('Dia', fechaStr);
  }
}
