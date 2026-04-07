import 'package:flutter/material.dart';
import '../../models/reparacion_model.dart';
import '../../data/repositories/reparacion_repository.dart';

class AddAvanceScreen extends StatefulWidget {
  final int idReparacion; // Recibe la reparación activa
  final int idEmpleado; // El mecánico que está logueado

  const AddAvanceScreen({
    super.key,
    required this.idReparacion,
    required this.idEmpleado,
  });

  @override
  State<AddAvanceScreen> createState() => _AddAvanceScreenState();
}

class _AddAvanceScreenState extends State<AddAvanceScreen> {
  final _descCtrl = TextEditingController();
  final _repo = ReparacionRepository();
  bool _isLoading = false;

  void _guardarAvance() async {
    if (_descCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);

    final nuevoAvance = ReparacionAvance(
      idReparacion: widget.idReparacion,
      idEmpleado: widget.idEmpleado,
      descripcion: _descCtrl.text,
    );

    try {
      await _repo.registrarAvance(nuevoAvance);
      if (!mounted) return;
      Navigator.pop(context); // Regresa tras guardar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Avance guardado")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Avance Técnico")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reparación #${widget.idReparacion}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    "Describe el trabajo realizado (ej: Cambio de aceite y ajuste de cadena)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _guardarAvance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SUBIR AVANCE",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
