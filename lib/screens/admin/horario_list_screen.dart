import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'horario_form_screen.dart';

class HorarioListScreen extends StatefulWidget {
  const HorarioListScreen({super.key});

  @override
  State<HorarioListScreen> createState() => _HorarioListScreenState();
}

class _HorarioListScreenState extends State<HorarioListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _horarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHorarios();
  }

  Future<void> _fetchHorarios() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('horarios')
          .select('*, empleados (nombre, apellido)')
          .order('dia', ascending: true);
      setState(() => _horarios = response);
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _horarios.isEmpty
          ? const Center(child: Text('No hay horarios configurados.', style: TextStyle(color: Colors.white24)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _horarios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildHorarioCard(_horarios[i]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HorarioFormScreen()),
          );
          if (result == true) _fetchHorarios();
        },
      ),
    );
  }

  Widget _buildHorarioCard(dynamic h) {
    final emp = h['empleados'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFF6B00).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(LucideIcons.clock, color: Color(0xFFFF6B00), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp != null ? '${emp['nombre']} ${emp['apellido']}' : 'Mecánico ID: ${h['id_empleado']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(h['dia'] ?? 'Día', style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontWeight: FontWeight.bold)),
                Text('${h['hora_entrada']} - ${h['hora_salida']}', style: const TextStyle(color: Colors.white30, fontSize: 11)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Colors.white10),
        ],
      ),
    );
  }
}
