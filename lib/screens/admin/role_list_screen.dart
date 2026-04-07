import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'role_detail_screen.dart';
import 'role_form_screen.dart';

class RoleListScreen extends StatefulWidget {
  const RoleListScreen({super.key});

  @override
  State<RoleListScreen> createState() => _RoleListScreenState();
}

class _RoleListScreenState extends State<RoleListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('roles')
          .select()
          .order('nombre', ascending: true);
      setState(() => _roles = response);
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  Future<void> _toggleStatus(int id, bool currentStatus) async {
    try {
       // Si la tabla no tiene columna estado, esto fallará silenciosamente o podemos omitirlo
       // Según tu captura web, parece tener Estado.
      await _supabase.from('roles').update({'estado': !currentStatus}).eq('id_rol', id);
      _fetchRoles();
    } catch (e) {}
  }

  Future<void> _deleteRole(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('¿Eliminar Rol?', style: TextStyle(color: Colors.white)),
        content: const Text('Asegúrate de que ningún usuario esté vinculado a este rol.', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('roles').delete().eq('id_rol', id);
        _fetchRoles();
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _roles.isEmpty
          ? const Center(child: Text('No hay roles registrados.', style: TextStyle(color: Colors.white24)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _roles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildRoleCard(_roles[i]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const RoleFormScreen()));
          if (result == true) _fetchRoles();
        },
      ),
    );
  }

  Widget _buildRoleCard(dynamic r) {
    final bool isActive = r['estado'] ?? true;
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
                child: const Icon(LucideIcons.shield, color: Color(0xFFFF6B00), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['nombre'] ?? 'Sin Nombre', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(r['descripcion'] ?? 'Sin descripción', style: const TextStyle(color: Colors.white30, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (val) => _toggleStatus(r['id_rol'], isActive),
                activeColor: const Color(0xFFFF6B00),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionIcon(LucideIcons.eye, Colors.blueAccent, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RoleDetailScreen(role: r)));
              }),
              _actionIcon(LucideIcons.edit3, Colors.blueAccent, () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => RoleFormScreen(role: r)));
                if (result == true) _fetchRoles();
              }),
              _actionIcon(LucideIcons.trash2, Colors.redAccent, () => _deleteRole(r['id_rol'])),
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
