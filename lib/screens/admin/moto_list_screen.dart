import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'moto_form_screen.dart';
import 'moto_detail_screen.dart';

class MotoListScreen extends StatefulWidget {
  const MotoListScreen({super.key});

  @override
  State<MotoListScreen> createState() => _MotoListScreenState();
}

class _MotoListScreenState extends State<MotoListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _motos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMotos();
  }

  Future<void> _fetchMotos() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('motocicletas')
          .select('*, clientes (nombre, apellido)')
          .order('marca', ascending: true);

      setState(() {
        _motos = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteMoto(dynamic m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('Eliminar Motocicleta', style: TextStyle(color: Colors.white)),
        content: Text('¿Está seguro de que desea eliminar la motocicleta ${m['placa']}? Esta acción no se puede deshacer.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      )
    );

    if (confirm == true && mounted) {
      try {
        await _supabase.from('motocicletas').delete().eq('id_motocicleta', m['id_motocicleta']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Motocicleta eliminada.'), backgroundColor: Colors.green));
          _fetchMotos();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Listado de Motocicletas', style: Theme.of(context).textTheme.displayLarge),
                      const Text('Gestión y registro de vehículos de clientes.', style: TextStyle(color: Colors.white30)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const MotoFormScreen()));
                    if (result == true) _fetchMotos();
                  },
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text('Nueva Motocicleta', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E65F3), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)), // Web blue
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E65F3))) 
                : _motos.isEmpty 
                  ? const Center(child: Text('No hay motocicletas registradas.', style: TextStyle(color: Colors.white30)))
                  : ListView.separated(
                      itemCount: _motos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) => _buildMotoCard(_motos[i]),
                    ),
            ),
          ],
        ),
      );
  }

  Widget _buildMotoCard(dynamic m) {
    final cliente = m['clientes'];
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MotoDetailScreen(moto: m)));
        if (result == true) _fetchMotos();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131518),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05))
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF00B2FF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.bike, color: Color(0xFF00B2FF), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${m['marca']} ${m['modelo']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Placa: ${m['placa']}', style: const TextStyle(color: Color(0xFF00B2FF), fontSize: 12, fontWeight: FontWeight.bold)),
                      if (cliente != null) Text('Propietario: ${cliente['nombre']} ${cliente['apellido']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Switch(
                        value: m['estado'] ?? true, 
                        onChanged: (val) {}, 
                        activeColor: const Color(0xFF00B2FF),
                     ),
                  ]
                ),
                Wrap(
                  spacing: 8,
                  children: [
                     IconButton(
                      icon: const Icon(LucideIcons.eye, color: Color(0xFF2E65F3), size: 18),
                      onPressed: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MotoDetailScreen(moto: m)));
                        if (result == true) _fetchMotos();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.edit2, color: Colors.greenAccent, size: 18),
                      onPressed: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MotoFormScreen(motoData: m)));
                        if (result == true) _fetchMotos();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
                      onPressed: () => _deleteMoto(m),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
