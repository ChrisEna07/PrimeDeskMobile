import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VentaListScreen extends StatefulWidget {
  const VentaListScreen({super.key});

  @override
  State<VentaListScreen> createState() => _VentaListScreenState();
}

class _VentaListScreenState extends State<VentaListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _ventas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVentas();
  }

  Future<void> _fetchVentas() async {
    try {
      final response = await _supabase
          .from('ventas')
          .select('''
            *,
            clientes (nombre, apellido),
            reparaciones (id_reparacion)
          ''')
          .order('id_venta', ascending: false);
      
      setState(() {
        _ventas = response;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback: consulta simple si los joins no existen
      try {
        final fallback = await _supabase
            .from('ventas')
            .select()
            .order('id_venta', ascending: false);
        setState(() {
          _ventas = fallback;
          _isLoading = false;
        });
      } catch (err) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar ventas: $err'), backgroundColor: Colors.redAccent));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Historial de Ventas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _ventas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final v = _ventas[i];
              final cli = v['clientes'];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2124),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.dollarSign, color: Colors.greenAccent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cli != null ? '${cli['nombre']} ${cli['apellido']}' : 'Consumidor Final', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('ID: VEN-${v['id_venta']}', style: const TextStyle(color: Colors.white30, fontSize: 10)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${v['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('FACTURADO', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
    );
  }
}
