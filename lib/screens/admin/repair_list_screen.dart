import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../responsive_layout.dart';
import 'repair_form_screen.dart';
import 'repair_detail_screen.dart';
import 'repair_pdf_screen.dart';

class RepairListScreen extends StatefulWidget {
  const RepairListScreen({super.key});

  @override
  State<RepairListScreen> createState() => _RepairListScreenState();
}

class _RepairListScreenState extends State<RepairListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _reparaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReparaciones();
  }

  Future<void> _fetchReparaciones() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('reparaciones')
          .select('''
            *,
            motocicletas (marca, modelo, placa)
          ''')
          .order('fecha', ascending: false);
      
      setState(() {
        _reparaciones = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _anularReparacion(dynamic r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('Anular Reparación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Está seguro de que desea anular esta reparación?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: const Color(0xFFFF6B00)),
            child: const Text('Anular'),
          ),
        ],
      )
    );

    if (confirm == true && mounted) {
      try {
        await _supabase.from('reparaciones').update({'estado': 'Cancelada'}).eq('id_reparacion', r['id_reparacion']);
        _fetchReparaciones(); // Refresh
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
                    Text('Gestión de Reparaciones', style: Theme.of(context).textTheme.displayLarge),
                    const Text('Administración de órdenes de servicio.', style: TextStyle(color: Colors.white30)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const RepairFormScreen()));
                  if (result == true) _fetchReparaciones();
                },
                icon: const Icon(LucideIcons.plus, color: Colors.white),
                label: const Text('Nueva Reparación', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E65F3), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E65F3))) 
              : _reparaciones.isEmpty 
                ? const Center(child: Text('No hay reparaciones registradas.', style: TextStyle(color: Colors.white30)))
                : ListView.separated(
                    itemCount: _reparaciones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => _buildRepairCard(_reparaciones[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairCard(dynamic r) {
    final moto = r['motocicletas'];
    final color = _getStatusColor(r['estado']);

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => RepairDetailScreen(repair: r)));
        if (result == true) _fetchReparaciones();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131518),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1))
        ),
        child: Column(
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(LucideIcons.wrench, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('R-${r['id_reparacion'].toString().padLeft(3, '0')} | ${moto?['marca'] ?? 'Reparación'} ${moto?['modelo'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Placa: ${moto?['placa'] ?? '...'} | Cliente: ${moto?['clientes']?['nombre'] ?? ''}', style: const TextStyle(color: Colors.white30, fontSize: 12)),
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
                  const Icon(LucideIcons.user, size: 12, color: Colors.white30),
                  const SizedBox(width: 4),
                  Text('ID Agend: ${r['id_agendamiento'] ?? 'N/A'}', style: const TextStyle(color: Colors.white30, fontSize: 11)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(r['estado']?.toString().toUpperCase() ?? 'PENDIENTE', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.eye, color: Color(0xFF2E65F3), size: 18),
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => RepairDetailScreen(repair: r)));
                      if (result == true) _fetchReparaciones();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.fileText, color: Colors.purpleAccent, size: 18),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RepairPdfScreen(repair: r)));
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, color: Colors.greenAccent, size: 18),
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => RepairFormScreen(repairData: r)));
                      if (result == true) _fetchReparaciones();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.xCircle, color: Colors.redAccent, size: 18),
                    onPressed: () => _anularReparacion(r),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
      ),
    );
  }

  Color _getStatusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'completada': return Colors.greenAccent;
      case 'entregada': return Colors.blueAccent;
      case 'cancelada': return Colors.redAccent;
      case 'en progreso': return Colors.blueAccent;
      case 'esperando repuestos': return Colors.orangeAccent;
      default: return const Color(0xFFFF6B00);
    }
  }
}
