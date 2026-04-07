import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_detail_screen.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      // Cruzamos usuarios con roles, empleados y clientes para tener nombres completos
      final response = await _supabase
          .from('usuarios')
          .select('*, roles(nombre), empleados(nombre, apellido), clientes(nombre, apellido)')
          .order('id_usuario', ascending: true);
      setState(() => _users = response);
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  Future<void> _toggleStatus(int id, bool currentStatus) async {
    try {
      await _supabase.from('usuarios').update({'estado': !currentStatus}).eq('id_usuario', id);
      _fetchUsers();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _users.isEmpty
          ? const Center(child: Text('No hay usuarios registrados.', style: TextStyle(color: Colors.white24)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildUserCard(_users[i]),
            ),
    );
  }

  Widget _buildUserCard(dynamic u) {
    final role = u['roles'];
    final bool isActive = u['estado'] ?? true;
    
    // Intentar obtener nombre de empleados o clientes
    String fullName = '-';
    if (u['empleados'] != null && u['empleados'].isNotEmpty) {
      final emp = u['empleados'][0];
      fullName = '${emp['nombre']} ${emp['apellido']}';
    } else if (u['clientes'] != null && u['clientes'].isNotEmpty) {
      final cli = u['clientes'][0];
      fullName = '${cli['nombre']} ${cli['apellido']}';
    }

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
                child: const Icon(LucideIcons.users2, color: Color(0xFFFF6B00), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u['correo'] ?? 'Sin correo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(fullName, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (val) => _toggleStatus(u['id_usuario'], isActive),
                activeColor: const Color(0xFFFF6B00),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRoleBadge(role != null ? role['nombre'] : 'Sin Rol'),
              Row(
                children: [
                  _actionIcon(LucideIcons.eye, Colors.blueAccent, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailScreen(user: u)));
                  }),
                  _actionIcon(LucideIcons.edit3, Colors.blueAccent, () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => UserFormScreen(user: u)));
                    if (result == true) _fetchUsers();
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String label) {
    Color color = Colors.blueAccent;
    if (label.toLowerCase().contains('admin')) color = Colors.redAccent;
    if (label.toLowerCase().contains('cliente')) color = Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
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
