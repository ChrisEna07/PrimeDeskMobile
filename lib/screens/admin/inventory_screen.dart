import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_form_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _productos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('productos')
          .select('*, categorias_productos (nombre)') 
          .order('nombre', ascending: true);
      
      setState(() {
        _productos = response;
        _isLoading = false;
      });
    } catch (e) {
      // Si el join falla, cargar solo productos
      try {
        final simpleResponse = await _supabase.from('productos').select().order('nombre', ascending: true);
        setState(() {
          _productos = simpleResponse;
          _isLoading = false;
        });
      } catch (err) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar productos: $err'), backgroundColor: Colors.redAccent));
        }
      }
    }
  }

  Future<void> _deleteProducto(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('¿Eliminar Producto?', style: TextStyle(color: Colors.white)),
        content: const Text('Esta acción eliminará el producto permanentemente.', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('productos').delete().eq('id_producto', id);
        _fetchProductos();
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _productos.isEmpty 
          ? const Center(child: Text('No hay productos registrados.', style: TextStyle(color: Colors.white30)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _productos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) => _buildProductCard(_productos[i]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
          if (result == true) _fetchProductos();
        },
      ),
    );
  }

  Widget _buildProductCard(dynamic p) {
    final dynamic catData = p['categorias_productos'];
    final String catName = (catData is Map) ? (catData['nombre'] ?? 'General') : 'General';
    final bool isActive = p['estado'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFF6B00).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.package, color: Color(0xFFFF6B00), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['nombre'] ?? 'Producto', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(p['marca'] ?? 'Sin marca', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (val) async {
                  await _supabase.from('productos').update({'estado': val}).eq('id_producto', p['id_producto']);
                  _fetchProductos();
                },
                activeColor: const Color(0xFFFF6B00),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text('Cantidad: ${p['cantidad'] ?? 0} unidades', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                Text(catName, style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionIcon(LucideIcons.eye, Colors.blueAccent, () {}),
              _actionIcon(LucideIcons.edit3, Colors.blueAccent, () {}),
              _actionIcon(LucideIcons.trash2, Colors.redAccent, () => _deleteProducto(p['id_producto'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
