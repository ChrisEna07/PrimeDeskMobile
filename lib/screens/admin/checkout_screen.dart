import 'package:flutter/material.dart';
import '../../models/transaccion_model.dart';
import '../../data/repositories/facturacion_repository.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>
  datosReparacion; // Trae ID_Reparacion, ID_Moto, ID_Empleado

  const CheckoutScreen({super.key, required this.datosReparacion});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _totalCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _repo = FacturacionRepository();

  void _confirmarVenta() async {
    if (_totalCtrl.text.isEmpty) return;

    final nuevaVenta = Venta(
      idReparacion: widget.datosReparacion['ID_Reparacion'],
      idEmpleado: widget.datosReparacion['ID_Empleado'],
      idMotocicleta: widget.datosReparacion['ID_Motocicleta'],
      total: double.parse(_totalCtrl.text),
      observaciones: _obsCtrl.text,
    );

    try {
      await _repo.finalizarVenta(nuevaVenta);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Venta realizada y Reparación Cerrada"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finalizar Servicio")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              color: Colors.blueGrey[50],
              child: ListTile(
                title: Text(
                  "Reparación #${widget.datosReparacion['ID_Reparacion']}",
                ),
                subtitle: Text("Moto: ${widget.datosReparacion['Placa']}"),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _totalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total a Cobrar (COP)",
                prefixText: "\$ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _obsCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Observaciones de la factura",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _confirmarVenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
                child: const Text(
                  "GENERAR FACTURA Y CERRAR",
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
