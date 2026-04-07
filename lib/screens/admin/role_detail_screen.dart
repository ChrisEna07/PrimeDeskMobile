import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleDetailScreen extends StatefulWidget {
  final dynamic role;
  const RoleDetailScreen({super.key, required this.role});

  @override
  State<RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends State<RoleDetailScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _assignedPermissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
  }

  Future<void> _fetchPermissions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('roles_permisos')
          .select('permisos(nombre)')
          .eq('id_rol', widget.role['id_rol']);
      _assignedPermissions = response;
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.role['estado'] ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Detalles del Rol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Nombre del Rol', widget.role['nombre'] ?? 'Sin nombre', LucideIcons.shield),
            const SizedBox(height: 24),
            _buildInfoItem('Descripción', widget.role['descripcion'] ?? 'Sin descripción', LucideIcons.info),
            const SizedBox(height: 24),
            const Text('Estado', style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: isActive ? Colors.greenAccent.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(isActive ? 'Activo' : 'Inactivo', style: TextStyle(color: isActive ? Colors.greenAccent : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            const Text('Permisos Asignados', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _assignedPermissions.isEmpty
                ? const Text('No tiene permisos asignados.', style: TextStyle(color: Colors.white24, fontSize: 12))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _assignedPermissions.map((p) {
                      final name = p['permisos']['nombre'];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                        child: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF00B2FF)),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
      ],
    );
  }
}
