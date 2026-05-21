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
        title: const Row(
          children: [
            Icon(LucideIcons.trash2, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Eliminar Proveedor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ]
        ),
        content: const Text('¿Confirmar eliminación?', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('proveedores').delete().eq('id_proveedor', id);
        _fetchProveedores();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSupplierDetails(dynamic s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        title: const Text('Detalles del Proveedor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Información General', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text('Nombre', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12)),
                      Text(s['nombreempresa'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('NIT', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12)),
                      Text(s['documento'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('Especialidad', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12)),
                      Text(s['especialidad'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 16),
                      const Text('Estado', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: (s['estado'] == true ? Colors.greenAccent : Colors.redAccent).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text(s['estado'] == true ? 'Activo' : 'Inactivo', style: TextStyle(color: s['estado'] == true ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contacto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text('Persona', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12)),
                      Text(s['personacontacto'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('Teléfono', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12)),
                      Text(s['telefono'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('Email', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12)),
                      Text(s['email'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('Dirección', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12)),
                      Text(s['direccion'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                )
              ],
            ),
          )
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.x, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
        ],
      )
    );
  }

  Future<void> _showSupplierDialog({dynamic supplier}) async {
    final nombreCtrl = TextEditingController(text: supplier?['nombreempresa'] ?? '');
    final nitCtrl = TextEditingController(text: supplier?['documento'] ?? '');
    final contactoCtrl = TextEditingController(text: supplier?['personacontacto'] ?? '');
    final especialidadCtrl = TextEditingController(text: supplier?['especialidad'] ?? '');
    final telCtrl = TextEditingController(text: supplier?['telefono'] ?? '');
    final emailCtrl = TextEditingController(text: supplier?['email'] ?? '');
    final dirCtrl = TextEditingController(text: supplier?['direccion'] ?? '');
    final ciudadCtrl = TextEditingController(text: supplier?['ciudad'] ?? '');
    final paisCtrl = TextEditingController(text: supplier?['pais'] ?? '');
    final webCtrl = TextEditingController(text: supplier?['sitioweb'] ?? '');
    final notasCtrl = TextEditingController(text: supplier?['notas'] ?? '');

    Widget buildInput(String label, TextEditingController ctrl, {int lines = 1}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              maxLines: lines,
              decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E2124), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
            ),
          ],
        ),
      );
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        title: Text(supplier == null ? 'Nuevo Proveedor' : 'Editar Proveedor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: buildInput('Nombre *', nombreCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: buildInput('NIT (Opcional)', nitCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildInput('Contacto *', contactoCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: buildInput('Especialidad (Opcional)', especialidadCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildInput('Teléfono *', telCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: buildInput('Email *', emailCtrl)),
                  ],
                ),
                buildInput('Dirección *', dirCtrl),
                Row(
                  children: [
                    Expanded(child: buildInput('Ciudad *', ciudadCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: buildInput('País *', paisCtrl)),
                  ],
                ),
                buildInput('Sitio Web (Opcional)', webCtrl),
                buildInput('Notas', notasCtrl, lines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isEmpty) return;
              try {
                final payload = {
                  'nombreempresa': nombreCtrl.text,
                  'documento': nitCtrl.text,
                  'personacontacto': contactoCtrl.text,
                  'especialidad': especialidadCtrl.text,
                  'telefono': telCtrl.text,
                  'email': emailCtrl.text,
                  'direccion': dirCtrl.text,
                  'ciudad': ciudadCtrl.text,
                  'pais': paisCtrl.text,
                  'sitioweb': webCtrl.text,
                  'notas': notasCtrl.text,
                  'estado': supplier?['estado'] ?? true,
                };
                if (supplier == null) {
                  await _supabase.from('proveedores').insert(payload);
                } else {
                  await _supabase.from('proveedores').update(payload).eq('id_proveedor', supplier['id_proveedor']);
                }
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E65F3)),
            child: Text(supplier == null ? 'Registrar' : 'Actualizar', style: const TextStyle(color: Colors.white)),
          )
        ],
      )
    );
    if (result == true) _fetchProveedores();
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
                    onPressed: () => _showSupplierDialog(),
                    icon: const Icon(LucideIcons.plus, color: Colors.white),
                    label: const Text('Nuevo Proveedor', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E65F3), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildSupplierGrid()),
          ],
        ),
      ),
      floatingActionButton: ResponsiveLayout.isMobile(context) 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFF2E65F3),
            child: const Icon(LucideIcons.plus, color: Colors.white),
            onPressed: () => _showSupplierDialog(),
          )
        : null,
    );
  }

  Widget _buildSupplierGrid() {
    if (_proveedores.isEmpty) {
      return const Center(child: Text('No hay proveedores registrados.', style: TextStyle(color: Colors.white30)));
    }
    
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth <= 800) {
        return ListView.separated(
          itemCount: _proveedores.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 16),
          itemBuilder: (ctx, i) => _buildSupplierCard(_proveedores[i]),
        );
      }
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2, // increased height allocation dynamically
        ),
        itemCount: _proveedores.length,
        itemBuilder: (context, i) => _buildSupplierCard(_proveedores[i]),
      );
    });
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF2E65F3).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(LucideIcons.truck, color: Color(0xFF2E65F3), size: 22),
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
                    value: isActive,
                    onChanged: (val) => _toggleStatus(s['id_proveedor'], isActive),
                    activeColor: const Color(0xFF2E65F3),
                  ),
                ]
              ),
              Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.eye, color: Color(0xFF2E65F3), size: 18),
                    onPressed: () => _showSupplierDetails(s),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, color: Colors.greenAccent, size: 18),
                    onPressed: () => _showSupplierDialog(supplier: s),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
                    onPressed: () => _deleteSupplier(s['id_proveedor']),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
