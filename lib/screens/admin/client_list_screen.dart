import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../responsive_layout.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {
    setState(() => _isLoading = true);
    try {
      // Query con conteo de motos (lógica de React: "MotosCount")
      final response = await _supabase
          .from('clientes')
          .select('''
            *,
            motocicletas (id_motocicleta)
          ''')
          .order('nombre', ascending: true);

      setState(() {
        _clientes = response;
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
        _buildStatsHeader(),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : _clientes.isEmpty 
              ? const Center(child: Text('No hay clientes registrados.', style: TextStyle(color: Colors.white30)))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _clientes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _buildClientCard(_clientes[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1E2124),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', _clientes.length.toString(), LucideIcons.users, Colors.blueAccent),
          _statItem('Activos', _clientes.length.toString(), LucideIcons.checkCircle, Colors.greenAccent), // Simplificado
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10)),
      ],
    );
  }

  Widget _buildClientCard(dynamic c) {
    final List motos = c['motocicletas'] ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFF6B00).withOpacity(0.1),
            child: Text(c['nombre']?[0] ?? 'U', style: const TextStyle(color: Color(0xFFFF6B00))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${c['nombre'] ?? ''} ${c['apellido'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(c['correo'] ?? 'Sin correo', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.phone, size: 10, color: Colors.white30),
                    const SizedBox(width: 4),
                    Text(c['telefono'] ?? '-', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.bike, size: 10, color: Colors.white30),
                    const SizedBox(width: 4),
                    Text('${motos.length} motos', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, color: Colors.white10),
            onPressed: () {
              // Ver detalles del cliente
            },
          )
        ],
      ),
    );
  }
}
