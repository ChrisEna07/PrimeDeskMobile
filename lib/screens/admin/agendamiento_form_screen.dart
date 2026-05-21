import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/dialog_helper.dart';

class AgendamientoFormScreen extends StatefulWidget {
  final DateTime initialDate;
  const AgendamientoFormScreen({super.key, required this.initialDate});

  @override
  State<AgendamientoFormScreen> createState() => _AgendamientoFormScreenState();
}

class _AgendamientoFormScreenState extends State<AgendamientoFormScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  
  // Datos para Dropdowns
  List<dynamic> _mecanicos = [];
  List<dynamic> _clientes = [];
  List<dynamic> _motos = [];
  List<dynamic> _servicios = [];
  
  // Selecciones
  String? _selectedMecanico;
  String? _selectedCliente;
  int? _selectedMoto;
  final List<int> _selectedServicios = [];
  final _notesController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchFormData();
  }

  Future<void> _fetchFormData() async {
    try {
      final authCtrl = context.read<AuthController>();
      final user = authCtrl.user;

      if (user != null && user.idRol == 3) {
        final results = await Future.wait([
          _supabase.from('usuarios').select().eq('id_rol', 2), // Mecánicos
          _supabase.from('servicios').select(),
        ]);

        setState(() {
          _mecanicos = results[0];
          _servicios = results[1];
          _selectedCliente = user.idAsociado?.toString();
        });

        if (user.idAsociado != null) {
          await _fetchMotos(user.idAsociado);
        }
      } else {
        final results = await Future.wait([
          _supabase.from('usuarios').select().eq('id_rol', 2), // Mecánicos
          _supabase.from('clientes').select('id_cliente, nombre, apellido'), // Clientes
          _supabase.from('servicios').select(),
        ]);

        setState(() {
          _mecanicos = results[0];
          _clientes = results[1];
          _servicios = results[2];
        });
      }
    } catch (e) {
      // Manejo de error silencioso
    }
  }

  Future<void> _fetchMotos(dynamic clienteId) async {
    try {
      final response = await _supabase.from('motocicletas').select().eq('id_cliente', clienteId);
      setState(() {
        _motos = response;
        _selectedMoto = null;
      });
    } catch (e) {}
  }

  Future<void> _saveAgendamiento() async {
    if (!_formKey.currentState!.validate() || _selectedMoto == null || _selectedMecanico == null) {
      await DialogHelper.showError(
        context,
        title: 'Campos Incompletos',
        message: 'Por favor completa todos los campos obligatorios.',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dia = DateFormat('yyyy-MM-dd').format(widget.initialDate);
      final hora = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

      // 1. Crear Agendamiento
      final response = await _supabase.from('agendamientos').insert({
        'id_motocicleta': _selectedMoto,
        'id_empleado': _selectedMecanico,
        'dia': dia,
        'horainicio': hora,
        'notas': _notesController.text,
      }).select().single();

      // 2. Crear Reparación automática (Lógica React Parity)
      await _supabase.from('reparaciones').insert({
        'id_motocicleta': _selectedMoto,
        'id_agendamiento': response['id_agendamiento'],
        'estado': 'Pendiente',
        'observaciones': 'Generada desde agendamiento: ${_notesController.text}',
      });

      if (mounted) {
        await DialogHelper.showSuccess(context, message: 'Cita agendada correctamente.');
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        await DialogHelper.showError(
          context,
          title: 'Error al Guardar',
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final isClient = user?.idRol == 3;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Nuevo Agendamiento', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Fecha y Hora Seleccionada'),
              _buildReadOnlyField(DateFormat('EEEE, d MMMM yyyy', 'es').format(widget.initialDate), LucideIcons.calendar),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _selectedTime);
                  if (time != null) setState(() => _selectedTime = time);
                },
                child: _buildReadOnlyField('Hora: ${_selectedTime.format(context)}', LucideIcons.clock),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Mecánico *'),
              _buildDropdown(
                hint: 'Seleccionar mecánico...',
                value: _selectedMecanico,
                items: _mecanicos.map((m) => DropdownMenuItem(value: m['id_usuario'].toString(), child: Text('${m['nombre']} ${m['apellido']}'))).toList(),
                onChanged: (val) => setState(() => _selectedMecanico = val as String?),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Cliente *'),
              isClient
                  ? _buildReadOnlyField(user?.nombreCompleto ?? 'Cliente', LucideIcons.user)
                  : _buildDropdown(
                      hint: 'Seleccionar cliente...',
                      value: _selectedCliente,
                      items: _clientes.map((c) => DropdownMenuItem(value: c['id_cliente'].toString(), child: Text('${c['nombre']} ${c['apellido']}'))).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCliente = val as String?);
                        if (val != null) _fetchMotos(val);
                      },
                    ),

              const SizedBox(height: 24),
              _buildSectionTitle('Motocicleta *'),
              _motos.isEmpty && !isClient && _selectedCliente == null
                  ? _buildDropdown(
                      hint: 'Primero selecciona un cliente',
                      value: null,
                      items: [],
                      onChanged: (_) {},
                    )
                  : _motos.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isClient 
                                      ? 'No tienes motocicletas registradas. Por favor solicita al administrador registrar tu vehículo.' 
                                      : 'Este cliente no tiene motocicletas registradas.',
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildDropdown(
                          hint: 'Seleccionar motocicleta...',
                          value: _selectedMoto?.toString(),
                          items: _motos.map((m) => DropdownMenuItem(value: m['id_motocicleta'].toString(), child: Text('${m['marca']} ${m['modelo']} (${m['placa']})'))).toList(),
                          onChanged: (val) => setState(() => _selectedMoto = int.tryParse(val as String)),
                        ),

              const SizedBox(height: 24),
              _buildSectionTitle('Servicios Sugeridos'),
              Wrap(
                spacing: 8,
                children: _servicios.map((s) {
                  final isSelected = _selectedServicios.contains(s['id_servicio']);
                  return FilterChip(
                    label: Text(s['nombre'], style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 12)),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) _selectedServicios.add(s['id_servicio']);
                        else _selectedServicios.remove(s['id_servicio']);
                      });
                    },
                    selectedColor: const Color(0xFFFF6B00),
                    backgroundColor: const Color(0xFF1E2124),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Notas'),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Observaciones adicionales...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF1E2124),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFF6B00).withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.2))),
                child: const Row(
                  children: [
                    Icon(LucideIcons.wrench, color: Color(0xFFFF6B00), size: 20),
                    SizedBox(width: 12),
                    Expanded(child: Text('Al crear este agendamiento se generará automáticamente una reparación.', style: TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isSaving || _motos.isEmpty) ? null : _saveAgendamiento,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Crear Agendamiento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
    );
  }

  Widget _buildReadOnlyField(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6B00), size: 20),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<DropdownMenuItem<String>> items, required Function(dynamic) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 14)),
          dropdownColor: const Color(0xFF1E2124),
          icon: const Icon(LucideIcons.chevronDown, color: Colors.white30),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
