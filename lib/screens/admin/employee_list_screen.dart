import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    try {
      // Cruzamos empleados con usuarios para obtener el correo y el rol
      final response = await _supabase
          .from('empleados')
          .select('*, usuarios (correo, id_rol, estado)')
          .order('nombre', ascending: true);
      setState(() => _employees = response);
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  Future<void> _toggleStatus(int userId, bool currentStatus) async {
    try {
      await _supabase.from('usuarios').update({'estado': !currentStatus}).eq('id_usuario', userId);
      _fetchEmployees();
    } catch (e) {}
  }

  Future<void> _deleteEmployee(int employeeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('¿Eliminar Empleado?', style: TextStyle(color: Colors.white)),
        content: const Text('Esta acción eliminará sus datos de acceso también.', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('empleados').delete().eq('id_empleado', employeeId);
        _fetchEmployees();
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _employees.isEmpty
          ? const Center(child: Text('No hay empleados registrados.', style: TextStyle(color: Colors.white24)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _employees.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildEmployeeCard(_employees[i]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeFormScreen()));
          if (result == true) _fetchEmployees();
        },
      ),
    );
  }

  Widget _buildEmployeeCard(dynamic e) {
    final user = e['usuarios'];
    final bool isActive = user != null ? (user['estado'] ?? true) : true;
    final int roleId = user != null ? (user['id_rol'] ?? 2) : 2;

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
                child: const Icon(LucideIcons.userCheck, color: Color(0xFFFF6B00), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e['nombre']} ${e['apellido']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(user != null ? user['correo'] : 'Sin correo', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Switch(
                    value: isActive,
                    onChanged: (val) => _toggleStatus(e['id_usuario'], isActive),
                    activeColor: const Color(0xFFFF6B00),
                  ),
                  Text(roleId == 1 ? 'ADMIN' : 'MECÁNICO', style: TextStyle(color: roleId == 1 ? Colors.redAccent : Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            children: [
              const Icon(LucideIcons.phone, size: 14, color: Colors.white30),
              const SizedBox(width: 8),
              Text(e['telefono'] ?? '-', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const Spacer(),
              _actionIcon(LucideIcons.eye, Colors.blueAccent, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeDetailScreen(employee: e)));
              }),
              _actionIcon(LucideIcons.edit3, Colors.blueAccent, () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeFormScreen(employee: e)));
                if (result == true) _fetchEmployees();
              }),
              _actionIcon(LucideIcons.trash2, Colors.redAccent, () => _deleteEmployee(e['id_empleado'])),
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
