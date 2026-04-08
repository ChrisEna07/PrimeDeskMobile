import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MotoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? motoData;
  const MotoFormScreen({super.key, this.motoData});

  @override
  State<MotoFormScreen> createState() => _MotoFormScreenState();
}

class _MotoFormScreenState extends State<MotoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  bool _isSaving = false;
  List<dynamic> _clientes = [];
  int? _selectedClienteId;

  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _anioController;
  late TextEditingController _placaController;
  late TextEditingController _colorController;
  late TextEditingController _motorController;
  late TextEditingController _kilometrajeController;

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.motoData?['marca']?.toString() ?? '');
    _modeloController = TextEditingController(text: widget.motoData?['modelo']?.toString() ?? '');
    _anioController = TextEditingController(text: widget.motoData?['anio']?.toString() ?? '');
    _placaController = TextEditingController(text: widget.motoData?['placa']?.toString() ?? '');
    _colorController = TextEditingController(text: widget.motoData?['color']?.toString() ?? '');
    _motorController = TextEditingController(text: widget.motoData?['motor']?.toString() ?? '');
    _kilometrajeController = TextEditingController(text: widget.motoData?['kilometraje']?.toString() ?? '0');
    _selectedClienteId = widget.motoData?['id_cliente'];
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {
    try {
      final response = await _supabase.from('clientes').select('id_cliente, nombre, apellido');
      if (mounted) setState(() => _clientes = response);
    } catch (e) {
      debugPrint("Error loading clientes: $e");
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedClienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, completa todos los campos requeridos y selecciona un propietario.'), backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _isSaving = true);
    
    try {
      final data = {
        'id_cliente': _selectedClienteId,
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'anio': int.parse(_anioController.text),
        'placa': _placaController.text,
        'color': _colorController.text,
        'motor': _motorController.text,
        'kilometraje': int.parse(_kilometrajeController.text),
      };

      if (widget.motoData == null) {
        await _supabase.from('motocicletas').insert(data);
      } else {
        await _supabase.from('motocicletas').update(data).eq('id_motocicleta', widget.motoData!['id_motocicleta']);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: Text(widget.motoData == null ? 'Nueva Motocicleta' : 'Editar Motocicleta', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2124),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField(_marcaController, 'Marca *', 'Ej: Honda')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_modeloController, 'Modelo *', 'Ej: Hornet CB600')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_anioController, 'Año *', '2026', isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_placaController, 'Placa *', 'ABC123')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_colorController, 'Color *', 'Ej: Rojo')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_motorController, 'Cilindraje (cc) *', 'Ej: 600', isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_kilometrajeController, 'Kilometraje *', '0', isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Propietario *', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(color: const Color(0xFF0F1113), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedClienteId,
                                hint: const Text('Seleccionar cliente', style: TextStyle(color: Colors.white30, fontSize: 14)),
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1E2124),
                                items: _clientes.map((c) => DropdownMenuItem<int>(
                                  value: c['id_cliente'],
                                  child: Text('${c['nombre']} ${c['apellido']}', style: const TextStyle(color: Colors.white)),
                                )).toList(),
                                onChanged: (val) => setState(() => _selectedClienteId = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E65F3), // Web match button
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(widget.motoData == null ? 'Registrar Motocicleta' : 'Actualizar Motocicleta', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF0F1113),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xFF2E65F3))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }
}
