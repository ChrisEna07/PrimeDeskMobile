import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HorarioFormScreen extends StatefulWidget {
  const HorarioFormScreen({super.key});

  @override
  State<HorarioFormScreen> createState() => _HorarioFormScreenState();
}

class _HorarioFormScreenState extends State<HorarioFormScreen> {
  final _supabase = Supabase.instance.client;
  
  List<dynamic> _empleados = [];
  String? _selectedEmpleado;
  
  // Configuración por día
  final Map<String, Map<String, dynamic>> _configs = {
    'Lunes': {'active': false, 'entrada': const TimeOfDay(hour: 8, minute: 0), 'salida': const TimeOfDay(hour: 17, minute: 0)},
    'Martes': {'active': false, 'entrada': const TimeOfDay(hour: 8, minute: 0), 'salida': const TimeOfDay(hour: 17, minute: 0)},
    'Miércoles': {'active': false, 'entrada': const TimeOfDay(hour: 8, minute: 0), 'salida': const TimeOfDay(hour: 17, minute: 0)},
    'Jueves': {'active': false, 'entrada': const TimeOfDay(hour: 8, minute: 0), 'salida': const TimeOfDay(hour: 17, minute: 0)},
    'Viernes': {'active': false, 'entrada': const TimeOfDay(hour: 8, minute: 0), 'salida': const TimeOfDay(hour: 17, minute: 0)},
    'Sábado': {'active': false, 'entrada': const TimeOfDay(hour: 8, minute: 0), 'salida': const TimeOfDay(hour: 12, minute: 0)},
    'Domingo': {'active': false, 'entrada': const TimeOfDay(hour: 8, minute: 0), 'salida': const TimeOfDay(hour: 12, minute: 0)},
  };
  
  bool _isSaving = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _fetchEmpleados();
  }

  Future<void> _fetchEmpleados() async {
    try {
      // Filtramos en la tabla usuarios para obtener solo los de rol Mecánico (2)
      final response = await _supabase
          .from('empleados')
          .select('*, usuarios!inner(id_rol)')
          .eq('usuarios.id_rol', 2);
      
      setState(() => _empleados = response);
    } catch (e) {}
  }

  double _calculateTotalHours(TimeOfDay e, TimeOfDay s) {
    final start = e.hour + (e.minute / 60);
    final end = s.hour + (s.minute / 60);
    return (end - start).clamp(0, 24);
  }

  Future<void> _saveHorarios() async {
    final seleccionados = _configs.entries.where((e) => e.value['active']).toList();
    
    if (_selectedEmpleado == null || seleccionados.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    setState(() {
      _isSaving = true;
      _showError = false;
    });

    try {
      final List<Map<String, dynamic>> batch = seleccionados.map((e) {
        final config = e.value;
        final hEntrada = '${config['entrada'].hour.toString().padLeft(2, '0')}:${config['entrada'].minute.toString().padLeft(2, '0')}:00';
        final hSalida = '${config['salida'].hour.toString().padLeft(2, '0')}:${config['salida'].minute.toString().padLeft(2, '0')}:00';
        
        return {
          'id_empleado': _selectedEmpleado,
          'dia': e.key,
          'hora_entrada': hEntrada,
          'hora_salida': hSalida,
          'estado': true,
        };
      }).toList();

      await _supabase.from('horarios').insert(batch);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horarios configurados correctamente.')));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Nuevo Horario', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Mecánico *'),
            _buildDropdown(
              hint: 'Seleccionar mecánico',
              value: _selectedEmpleado,
              items: _empleados.map((e) => DropdownMenuItem(value: e['id_empleado'].toString(), child: Text('${e['nombre']} ${e['apellido']}'))).toList(),
              onChanged: (val) => setState(() => _selectedEmpleado = val as String?),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Horarios por Día de la Semana *'),
            const Text('Seleccione los días laborables y configure el horario específico para cada día', style: TextStyle(color: Colors.white24, fontSize: 13)),
            const SizedBox(height: 20),
            
            Column(
              children: _configs.keys.map((dia) => _buildDayConfigCard(dia)).toList(),
            ),

            if (_showError) ...[
              const SizedBox(height: 12),
              const Center(child: Text('Debe habilitar al menos un día de trabajo', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold))),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveHorarios,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Crear Horarios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)));
  }

  Widget _buildDayConfigCard(String dia) {
    final config = _configs[dia]!;
    final bool isSelected = config['active'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFFFF6B00).withOpacity(0.5) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => config['active'] = !isSelected),
            child: Row(
              children: [
                Icon(isSelected ? LucideIcons.checkSquare : LucideIcons.square, color: isSelected ? const Color(0xFFFF6B00) : Colors.white10),
                const SizedBox(width: 16),
                Text(dia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                const Spacer(),
                if (isSelected) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Activo', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTimePicker('Hora de Entrada', config['entrada'], (t) => setState(() => config['entrada'] = t))),
                const SizedBox(width: 16),
                Expanded(child: _buildTimePicker('Hora de Salida', config['salida'], (t) => setState(() => config['salida'] = t))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 12, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Text(
                  'Total: ${_calculateTotalHours(config['entrada'], config['salida']).toStringAsFixed(1)}h de trabajo', 
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<DropdownMenuItem<String>> items, required Function(dynamic) onChanged}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 14)), dropdownColor: const Color(0xFF1E2124), icon: const Icon(LucideIcons.chevronDown, color: Colors.white30), isExpanded: true, items: items, onChanged: onChanged, style: const TextStyle(color: Colors.white, fontSize: 15))));
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: time);
            if (t != null) onSelected(t);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFF0F1113), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Row(
              children: [
                Text(time.format(context), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const Spacer(),
                const Icon(LucideIcons.clock, color: Colors.white24, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
