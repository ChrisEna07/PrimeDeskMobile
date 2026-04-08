import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'repair_form_screen.dart';

class RepairDetailScreen extends StatelessWidget {
  final Map<String, dynamic> repair;
  const RepairDetailScreen({super.key, required this.repair});

  Future<void> _deleteRepair(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('Eliminar Reparación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que deseas eliminar esta reparación? Esta acción no se puede deshacer.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      )
    );

    if (confirm == true && context.mounted) {
      try {
        await Supabase.instance.client.from('reparaciones').delete().eq('id_reparacion', repair['id_reparacion']);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reparación eliminada.'), backgroundColor: Colors.green));
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moto = repair['motocicletas'];
    final fecha = repair['fecha'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(repair['fecha'])) : 'Desconocida';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: Text('Detalle Orden #${repair['id_reparacion']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit, color: Colors.blueAccent),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => RepairFormScreen(repairData: repair)));
              if (result == true && context.mounted) Navigator.pop(context, true);
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
            onPressed: () => _deleteRepair(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2124),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF2E65F3).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(LucideIcons.wrench, color: Color(0xFF2E65F3), size: 32),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revisión Técnica', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Fecha de Ingreso: $fecha', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2124),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Historial y Servicios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  _buildDetailRow('Estado Actual', repair['estado']?.toString().toUpperCase() ?? 'PENDIENTE', isChip: true),
                  _buildDetailRow('Servicios', repair['tiposervicio'] ?? 'Ninguno'),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 24),
                  const Text('Observaciones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF0F1113), borderRadius: BorderRadius.circular(8)),
                    child: Text(repair['observaciones'] ?? 'No hay observaciones guardadas.', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 24),
                  const Text('Motocicleta Informada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Placa / Info', moto != null ? '${moto['placa']} - ${moto['marca']} ${moto['modelo']}' : 'Información Perdida'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isChip = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          if (isChip) 
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
               decoration: BoxDecoration(color: const Color(0xFFFF6B00).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
               child: Text(value, style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 10, fontWeight: FontWeight.bold)),
             )
          else 
             Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
