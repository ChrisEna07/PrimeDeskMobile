import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class EmployeeFormScreen extends StatefulWidget {
  final dynamic employee; // null para nuevo, con datos para editar
  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _documentoController;
  late TextEditingController _telefonoController;
  late TextEditingController _barrioController;
  late TextEditingController _direccionController;

  String _tipoDocumento = 'Cédula de Ciudadanía';
  DateTime? _fechaNacimiento;
  DateTime? _fechaIngreso;
  bool _isSaving = false;

  final List<String> _docOptions = ['Cédula de Ciudadanía', 'Cédula de Extranjería', 'Pasaporte'];

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nombreController = TextEditingController(text: e?['nombre'] ?? '');
    _apellidoController = TextEditingController(text: e?['apellido'] ?? '');
    _documentoController = TextEditingController(text: e?['documento'] ?? '');
    _telefonoController = TextEditingController(text: e?['telefono'] ?? '');
    _barrioController = TextEditingController(text: e?['barrio'] ?? '');
    _direccionController = TextEditingController(text: e?['direccion'] ?? '');
    
    if (e != null) {
      final docFromDb = e['tipodocumento'] ?? 'CC';
      // Mapeo inverso de siglas a nombres completos
      if (docFromDb == 'CC') _tipoDocumento = 'Cédula de Ciudadanía';
      else if (docFromDb == 'CE') _tipoDocumento = 'Cédula de Extranjería';
      else if (docFromDb == 'PA' || docFromDb == 'PAS') _tipoDocumento = 'Pasaporte';
      else _tipoDocumento = docFromDb;

      if (e['fechanacimiento'] != null) _fechaNacimiento = DateTime.tryParse(e['fechanacimiento']);
      if (e['fechaingreso'] != null) _fechaIngreso = DateTime.tryParse(e['fechaingreso']);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // Mapear de vuelta a siglas para la DB
      String dbTipoDoc = _tipoDocumento;
      if (_tipoDocumento == 'Cédula de Ciudadanía') dbTipoDoc = 'CC';
      else if (_tipoDocumento == 'Cédula de Extranjería') dbTipoDoc = 'CE';
      else if (_tipoDocumento == 'Pasaporte') dbTipoDoc = 'PA';

      final data = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'tipodocumento': dbTipoDoc,
        'documento': _documentoController.text,
        'telefono': _telefonoController.text,
        'barrio': _barrioController.text,
        'direccion': _direccionController.text,
        'fechanacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
        'fechaingreso': _fechaIngreso?.toIso8601String().split('T')[0],
      };

      if (widget.employee != null) {
        await _supabase.from('empleados').update(data).eq('id_empleado', widget.employee['id_empleado']);
      } else {
        // Lógica para nuevo empleado (requiere crear usuario primero)
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos actualizados con éxito.')));
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
        title: Text(widget.employee != null ? 'Editar Empleado' : 'Nuevo Empleado', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                   Icon(LucideIcons.user, color: Color(0xFF00B2FF), size: 20),
                   SizedBox(width: 12),
                   Text('Información Personal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildTextField(_nombreController, 'Nombre *')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_apellidoController, 'Apellido *')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Tipo de Documento', _docOptions)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_documentoController, 'Núm. Documento *', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_telefonoController, 'Teléfono *', keyboardType: TextInputType.phone)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDatePicker('Fec. Nacimiento *', _fechaNacimiento, (d) => setState(() => _fechaNacimiento = d))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Fecha de Ingreso *', _fechaIngreso, (d) => setState(() => _fechaIngreso = d))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_barrioController, 'Barrio *')),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_direccionController, 'Dirección *'),

              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white10),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B2FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Actualizar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E2124),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    // Asegurar que el valor actual exista en las opciones para evitar el error de assertion
    String safeValue = options.contains(_tipoDocumento) ? _tipoDocumento : options[0];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeValue,
              dropdownColor: const Color(0xFF1E2124),
              isExpanded: true,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _tipoDocumento = val);
              },
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now());
            if (d != null) onPick(d);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Seleccionar', style: const TextStyle(color: Colors.white, fontSize: 14)),
                const Spacer(),
                const Icon(LucideIcons.calendar, size: 16, color: Colors.white30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
