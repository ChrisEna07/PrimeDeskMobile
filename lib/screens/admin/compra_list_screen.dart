import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompraListScreen extends StatefulWidget {
  const CompraListScreen({super.key});

  @override
  State<CompraListScreen> createState() => _CompraListScreenState();
}

class _CompraListScreenState extends State<CompraListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _compras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompras();
  }

  Future<void> _fetchCompras() async {
    try {
      final response = await _supabase
          .from('compras')
          .select('''
            *,
            proveedores (nombreempresa)
          ''')
          .order('id_compra', ascending: false);
      setState(() {
        _compras = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar compras: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Compras', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _compras.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final c = _compras[i];
              final prov = c['proveedores'];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shoppingCart, color: Color(0xFFFF6B00)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prov?['nombreempresa'] ?? 'Proveedor Desconocido', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('ID: COMP-${c['id_compra']}', style: const TextStyle(color: Colors.white30, fontSize: 10)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${c['total']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        Text(c['estado'] ?? 'Recibido', style: const TextStyle(color: Colors.white30, fontSize: 10)),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
