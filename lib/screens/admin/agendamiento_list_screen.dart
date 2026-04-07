import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../responsive_layout.dart';
import 'agendamiento_form_screen.dart';

class AgendamentoListScreen extends StatefulWidget {
  const AgendamentoListScreen({super.key});

  @override
  State<AgendamentoListScreen> createState() => _AgendamentoListScreenState();
}

class _AgendamentoListScreenState extends State<AgendamentoListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _agendamientos = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAgendamientos();
  }

  Future<void> _fetchAgendamientos() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('agendamientos')
          .select('''
            *,
            motocicletas (marca, modelo, placa),
            empleados (nombre, apellido)
          ''')
          .order('dia', ascending: true);
      
      setState(() {
        _agendamientos = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // Regla de 1 Hora de React: "Solo se puede eliminar con al menos una hora de anticipación"
  bool _canDelete(String dia, String hora) {
    try {
      final aptDateTime = DateTime.parse('$dia $hora');
      return aptDateTime.difference(DateTime.now()).inHours >= 1;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparente para usar el fondo del Dashboard
      body: Column(
        children: [
          _buildQuickCalendar(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _agendamientos.isEmpty 
                ? const Center(child: Text('No hay citas programadas.', style: TextStyle(color: Colors.white30)))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _agendamientos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => _buildAgendamientoCard(_agendamientos[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgendamientoFormScreen(initialDate: _selectedDate)),
          );
          if (result == true) _fetchAgendamientos();
        },
      ),
    );
  }

  Widget _buildQuickCalendar() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2124),
        border: Border(bottom: BorderSide(color: Colors.white10))
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, i) {
          final date = DateTime.now().add(Duration(days: i));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF6B00) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? const Color(0xFFFF6B00) : Colors.white10)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E', 'es').format(date).toUpperCase(), style: TextStyle(color: isSelected ? Colors.white : Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('${date.day}', style: TextStyle(color: isSelected ? Colors.white : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgendamientoCard(dynamic a) {
    final moto = a['motocicletas'];
    final emp = a['empleados'];
    final String hora = a['horainicio'] ?? '00:00';
    final String dia = a['dia'] ?? '';
    final bool canDel = _canDelete(dia, hora);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFF6B00).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.clock, color: Color(0xFFFF6B00), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hora, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(dia, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Programado', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(LucideIcons.bike, 'Moto', '${moto?['marca'] ?? 'Desconocida'} ${moto?['modelo'] ?? ''}'),
                const SizedBox(height: 8),
                _infoRow(LucideIcons.userCheck, 'Mecánico', '${emp?['nombre'] ?? 'Sin'} ${emp?['apellido'] ?? 'asignar'}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {}, 
                      icon: const Icon(LucideIcons.edit2, size: 14), 
                      label: const Text('Editar', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: canDel ? () {} : null, 
                      icon: const Icon(LucideIcons.trash2, size: 14), 
                      label: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: canDel ? Colors.redAccent : Colors.white10),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white30),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(color: Colors.white30, fontSize: 12)),
        const SizedBox(width: 4),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
