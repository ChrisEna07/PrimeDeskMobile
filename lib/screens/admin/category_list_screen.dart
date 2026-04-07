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
      } catch (e) {}
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
        onPressed: () {
          // Navegar a formulario de nueva categoría
        },
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
              _actionIcon(LucideIcons.eye, Colors.blueAccent, () {}),
              _actionIcon(LucideIcons.edit3, Colors.blueAccent, () {}),
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
