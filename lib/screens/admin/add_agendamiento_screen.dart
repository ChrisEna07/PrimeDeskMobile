import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/agendamiento_model.dart';
import '../../data/repositories/agendamiento_repository.dart';

class AddAgendamientoScreen extends StatefulWidget {
  const AddAgendamientoScreen({super.key});

  @override
  State<AddAgendamientoScreen> createState() => _AddAgendamientoScreenState();
}

class _AddAgendamientoScreenState extends State<AddAgendamientoScreen> {
  final _repo = AgendamientoRepository();
  final _supabase = Supabase.instance.client;

  int? _idMoto;
  int? _idEmpleado;
  DateTime _fechaSel = DateTime.now();
  final TimeOfDay _horaInicio = const TimeOfDay(hour: 8, minute: 0);
  final _notasCtrl = TextEditingController();

  // Función para formatear TimeOfDay a String HH:mm:ss para Postgres
  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

  void _guardarCita() async {
    if (_idMoto == null || _idEmpleado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Faltan datos")));
      return;
    }

    final nuevaCita = Agendamiento(
      idMotocicleta: _idMoto!,
      idEmpleado: _idEmpleado!,
      dia: _fechaSel,
      horaInicio: _formatTime(_horaInicio),
      horaFin: _formatTime(
        TimeOfDay(hour: _horaInicio.hour + 1, minute: _horaInicio.minute),
      ), // +1 hora por defecto
      notas: _notasCtrl.text,
    );

    try {
      await _repo.crearCita(nuevaCita);
      Navigator.pop(context);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Cita Taller")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "1. Seleccionar Vehículo (Placa)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildMotoDropdown(),
          const SizedBox(height: 20),
          const Text(
            "2. Asignar Mecánico",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildEmpleadoDropdown(),
          const SizedBox(height: 20),
          ListTile(
            title: Text(
              "Fecha: ${_fechaSel.day}/${_fechaSel.month}/${_fechaSel.year}",
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final pick = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (pick != null) setState(() => _fechaSel = pick);
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _notasCtrl,
            decoration: const InputDecoration(
              labelText: "Notas / Síntomas de la moto",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _guardarCita,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
            ),
            child: const Text(
              "AGENDAR SERVICIO",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdowns cargando datos reales de Supabase
  Widget _buildMotoDropdown() {
    return FutureBuilder(
      future: _supabase
          .from('motocicletas')
          .select('ID_Motocicleta, Placa, Modelo'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final list = snapshot.data as List;
        return DropdownButtonFormField<int>(
          items: list
              .map(
                (m) => DropdownMenuItem(
                  value: m['ID_Motocicleta'] as int,
                  child: Text("${m['Placa']} - ${m['Modelo']}"),
                ),
              )
              .toList(),
          onChanged: (val) => _idMoto = val,
        );
      },
    );
  }

  Widget _buildEmpleadoDropdown() {
    return FutureBuilder(
      future:
          _supabase.from('empleados').select('ID_Empleado, Nombre, Apellido'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final list = snapshot.data as List;
        return DropdownButtonFormField<int>(
          items: list
              .map(
                (e) => DropdownMenuItem(
                  value: e['ID_Empleado'] as int,
                  child: Text("${e['Nombre']} ${e['Apellido']}"),
                ),
              )
              .toList(),
          onChanged: (val) => _idEmpleado = val,
        );
      },
    );
  }
}
