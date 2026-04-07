import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../responsive_layout.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _proveedores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProveedores();
  }

  Future<void> _fetchProveedores() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('proveedores')
          .select()
          .order('nombreempresa', ascending: true);
      
      setState(() {
        _proveedores = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar proveedores: $e')));
      }
    }
  }

  Future<void> _toggleStatus(int id, bool currentStatus) async {
    try {
      await _supabase.from('proveedores').update({'estado': !currentStatus}).eq('id_proveedor', id);
      _fetchProveedores();
    } catch (e) {}
  }

  Future<void> _deleteSupplier(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('¿Eliminar Proveedor?', style: TextStyle(color: Colors.white)),
        content: const Text('Esta acción no se puede deshacer.', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('proveedores').delete().eq('id_proveedor', id);
        _fetchProveedores();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: ResponsiveLayout.isMobile(context) 
        ? AppBar(
            backgroundColor: const Color(0xFF0F1113),
            title: const Text('Proveedores', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        : null,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!ResponsiveLayout.isMobile(context))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proveedores Aliados', style: Theme.of(context).textTheme.displayLarge),
                      const Text('Gestión de contactos y especialidades de proveedores de repuestos.', style: TextStyle(color: Colors.white30)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.truck, color: Colors.white),
                    label: const Text('Nuevo Proveedor', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            
            // Grid of Suppliers
            Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildSupplierGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierGrid() {
    if (_proveedores.isEmpty) {
      return const Center(child: Text('No hay proveedores registrados.', style: TextStyle(color: Colors.white30)));
    }
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.8,
      ),
      itemCount: _proveedores.length,
      itemBuilder: (context, i) => _buildSupplierCard(_proveedores[i]),
    );
  }

  Widget _buildSupplierCard(dynamic s) {
    final bool isActive = s['estado'] ?? true;
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFF6B00).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(LucideIcons.truck, color: Color(0xFFFF6B00), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['nombreempresa'] ?? 'Proveedor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(s['nit'] ?? 'NIT no registrado', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (val) => _toggleStatus(s['id_proveedor'], isActive),
                activeColor: const Color(0xFFFF6B00),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            children: [
              const Icon(LucideIcons.phone, size: 14, color: Colors.white30),
              const SizedBox(width: 8),
              Text(s['telefono'] ?? '-', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const Spacer(),
              const Icon(LucideIcons.mail, size: 14, color: Colors.white30),
              const SizedBox(width: 4),
              const Text('Email', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
