import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('categorias_productos')
          .select()
          .order('nombre', ascending: true);
      setState(() => _categories = response);
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  Future<void> _toggleStatus(int id, bool currentStatus) async {
    try {
      await _supabase.from('categorias_productos').update({'estado': !currentStatus}).eq('id_categoria', id);
      _fetchCategories();
    } catch (e) {}
  }

  Future<void> _deleteCategory(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('¿Eliminar Categoría?', style: TextStyle(color: Colors.white)),
        content: const Text('Se eliminará permanentemente.', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('categorias_productos').delete().eq('id_categoria', id);
        _fetchCategories();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showCategoryDetails(dynamic c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        title: const Text('Detalles de la Categoría', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nombre', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(c['nombre'] ?? 'Sin Nombre', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: (c['estado'] == true ? Colors.greenAccent : Colors.redAccent).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Text(c['estado'] == true ? 'Activo' : 'Inactivo', style: TextStyle(color: c['estado'] == true ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text('Descripción', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(8)),
              child: Text(c['descripcion'] ?? 'Sin descripción...', style: const TextStyle(color: Colors.white70)),
            )
          ],
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.x, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
        ],
      )
    );
  }

  Future<void> _showCategoryDialog({dynamic categoryToEdit}) async {
    final nombreController = TextEditingController(text: categoryToEdit?['nombre'] ?? '');
    final descController = TextEditingController(text: categoryToEdit?['descripcion'] ?? '');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        title: Text(categoryToEdit == null ? 'Nueva Categoría' : 'Editar Categoría', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nombre *', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E2124),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Descripción *', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E2124),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
               if (nombreController.text.isEmpty) return;
               try {
                  if (categoryToEdit == null) {
                    await _supabase.from('categorias_productos').insert({
                      'nombre': nombreController.text,
                      'descripcion': descController.text,
                      'estado': true
                    });
                  } else {
                     await _supabase.from('categorias_productos').update({
                      'nombre': nombreController.text,
                      'descripcion': descController.text,
                    }).eq('id_categoria', categoryToEdit['id_categoria']);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
               } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
               }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E65F3), foregroundColor: Colors.white),
            child: Text(categoryToEdit == null ? 'Crear Categoría' : 'Actualizar'),
          )
        ],
      )
    );

    if (result == true) {
      _fetchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _categories.isEmpty
          ? const Center(child: Text('No hay categorías registradas.', style: TextStyle(color: Colors.white24)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildCategoryCard(_categories[i]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () => _showCategoryDialog(),
      ),
    );
  }

  Widget _buildCategoryCard(dynamic c) {
    final bool isActive = c['estado'] ?? true;
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
                child: const Icon(LucideIcons.tag, color: Color(0xFFFF6B00), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['nombre'] ?? 'Categoría', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(c['descripcion'] ?? 'Sin descripción', style: const TextStyle(color: Colors.white30, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (val) => _toggleStatus(c['id_categoria'], isActive),
                activeColor: const Color(0xFFFF6B00),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionIcon(LucideIcons.eye, const Color(0xFF2E65F3), () => _showCategoryDetails(c)),
              _actionIcon(LucideIcons.edit2, Colors.greenAccent, () => _showCategoryDialog(categoryToEdit: c)),
              _actionIcon(LucideIcons.trash2, Colors.redAccent, () => _deleteCategory(c['id_categoria'])),
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
