import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'moto_form_screen.dart';

class MotoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> moto;
  const MotoDetailScreen({super.key, required this.moto});

  Future<void> _deleteMoto(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('Eliminar Motocicleta', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que deseas eliminar esta motocicleta? Esta acción no se puede deshacer.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      )
    );

    if (confirm == true && context.mounted) {
      try {
        await Supabase.instance.client.from('motocicletas').delete().eq('id_motocicleta', moto['id_motocicleta']);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Motocicleta eliminada.'), backgroundColor: Colors.green));
          Navigator.pop(context, true); // Retorna true para refrescar la lista
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
    final cliente = moto['clientes'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Detalle de Motocicleta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit, color: Colors.blueAccent),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MotoFormScreen(motoData: moto)));
              if (result == true && context.mounted) Navigator.pop(context, true); // Cascada update back to list
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
            onPressed: () => _deleteMoto(context),
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
                    child: const Icon(LucideIcons.bike, color: Color(0xFF2E65F3), size: 32),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${moto['marca']} ${moto['modelo']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Placa: ${moto['placa']}', style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const Text('Especificaciones Técnicas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  _buildDetailRow('Año de Fabricación', moto['anio']?.toString() ?? 'N/A'),
                  _buildDetailRow('Color Registrado', moto['color']?.toString() ?? 'N/A'),
                  _buildDetailRow('Cilindraje (cc)', moto['motor']?.toString() ?? 'N/A'),
                  _buildDetailRow('Kilometraje (km)', moto['kilometraje']?.toString() ?? '0'),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 24),
                  const Text('Propietario Vinculado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Nombre Completo', cliente != null ? '${cliente['nombre']} ${cliente['apellido']}' : 'Desvinculado'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
