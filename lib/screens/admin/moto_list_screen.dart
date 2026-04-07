import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : _motos.isEmpty 
              ? const Center(child: Text('No hay motocicletas registradas.', style: TextStyle(color: Colors.white30)))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _motos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _buildMotoCard(_motos[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildMotoCard(dynamic m) {
    final cliente = m['clientes'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFF6B00).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(LucideIcons.bike, color: Color(0xFFFF6B00), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m['marca']} ${m['modelo']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Placa: ${m['placa']}', style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontWeight: FontWeight.bold)),
                if (cliente != null) Text('Propietario: ${cliente['nombre']} ${cliente['apellido']}', style: const TextStyle(color: Colors.white30, fontSize: 11)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Colors.white10),
        ],
      ),
    );
  }
}
