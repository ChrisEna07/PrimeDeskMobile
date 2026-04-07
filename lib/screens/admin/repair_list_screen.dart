import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../responsive_layout.dart';

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

  @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _reparaciones.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _buildRepairCard(_reparaciones[i]),
                ),
          ),
        ],
      );
    }

  Widget _buildRepairCard(dynamic r) {
    final moto = r['motocicletas'];
    final color = _getStatusColor(r['estado']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
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
                    Text('${moto?['marca'] ?? 'Reparación'} ${moto?['modelo'] ?? r['id_reparacion']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Placa: ${moto?['placa'] ?? '...'}', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(LucideIcons.moreVertical, color: Colors.white24), onPressed: () {})
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.user, size: 12, color: Colors.white30),
                  const SizedBox(width: 4),
                  Text('ID Agend: ${r['id_agendamiento'] ?? 'N/A'}', style: const TextStyle(color: Colors.white30, fontSize: 11)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(r['estado']?.toString().toUpperCase() ?? 'PENDIENTE', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
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
