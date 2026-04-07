import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/motocicleta_model.dart';
import '../../data/repositories/moto_repository.dart';

class AddMotoScreen extends StatefulWidget {
  const AddMotoScreen({super.key});

  @override
  State<AddMotoScreen> createState() => _AddMotoScreenState();
}

class _AddMotoScreenState extends State<AddMotoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motoRepo = MotoRepository();
  final _supabase = Supabase.instance.client;

  // Datos del Cliente Seleccionado
  int? _selectedClientId;
  String _selectedClientName = "Seleccione un cliente";

  // Controllers para los campos de la tabla Motocicletas
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _motorCtrl = TextEditingController();
  final _kmCtrl = TextEditingController(text: "0");

  // Función para buscar clientes en la tabla 'Clientes'
  void _showClientPicker() async {
    final List<Map<String, dynamic>> clients = await _supabase
        .from('clientes')
        .select('id_cliente, nombre, apellido, documento');

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Seleccionar Propietario",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final c = clients[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text("${c['nombre']} ${c['apellido']}"),
                    subtitle: Text("Doc: ${c['documento']}"),
                    onTap: () {
                      setState(() {
                        _selectedClientId = c['id_cliente'] as int;
                        _selectedClientName = "${c['nombre']} ${c['apellido']}";
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor seleccione un cliente")),
        );
        return;
      }

      final nuevaMoto = Motocicleta(
        idCliente: _selectedClientId!,
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        anio: int.parse(_anioCtrl.text),
        placa: _placaCtrl.text,
        color: _colorCtrl.text,
        motor: int.parse(_motorCtrl.text),
        kilometraje: int.parse(_kmCtrl.text),
      );

      try {
        await _motoRepo.registrarMoto(nuevaMoto);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Moto registrada exitosamente")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Motocicleta")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Selección de Cliente (FK_Moto_Cliente)
            const Text(
              "Propietario",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person_search, color: Colors.blue),
                title: Text(_selectedClientName),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _showClientPicker,
              ),
            ),
            const SizedBox(height: 16),

            // Datos de la Moto
            const Text(
              "Datos del Vehículo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    _placaCtrl,
                    "Placa (ej: ABC12D)",
                    Icons.tag,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildField(
                    _marcaCtrl,
                    "Marca",
                    Icons.branding_watermark,
                  ),
                ),
              ],
            ),
            _buildField(
              _modeloCtrl,
              "Modelo (ej: Pulsar NS 200)",
              Icons.motorcycle,
            ),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    _anioCtrl,
                    "Año",
                    Icons.calendar_today,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildField(
                    _motorCtrl,
                    "Cilindraje (cc)",
                    Icons.settings_input_component,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            _buildField(_colorCtrl, "Color", Icons.color_lens),
            _buildField(
              _kmCtrl,
              "Kilometraje Actual",
              Icons.speed,
              isNumber: true,
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue[900],
              ),
              child: const Text(
                "GUARDAR MOTOCICLETA",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "Requerido" : null,
      ),
    );
  }
}
