import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserDetailScreen extends StatelessWidget {
  final dynamic user;
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final role = user['roles'];
    final bool isActive = user['estado'] ?? true;
    
    String fullName = 'Usuario sin vincular';
    if (user['empleados'] != null && user['empleados'].isNotEmpty) {
      final emp = user['empleados'][0];
      fullName = '${emp['nombre']} ${emp['apellido']}';
    } else if (user['clientes'] != null && user['clientes'].isNotEmpty) {
      final cli = user['clientes'][0];
      fullName = '${cli['nombre']} ${cli['apellido']}';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Detalles de la Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Center Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2124),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05))
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00B2FF), width: 2)),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF0F1113),
                      child: Text(fullName[0], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.mail, size: 14, color: Colors.white30),
                      const SizedBox(width: 8),
                      Text(user['correo'] ?? 'Sin correo', style: const TextStyle(color: Colors.white30, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildRoleBadge(role != null ? role['nombre'] : 'Sin Rol'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSimpleCard('ID USUARIO', '#${user['id_usuario']}', isActive)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusCard(isActive)),
              ],
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00B2FF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00B2FF).withOpacity(0.1))
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.info, color: Color(0xFF00B2FF), size: 20),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Este es un perfil de acceso al sistema. Los datos adicionales se gestionan en los módulos de personal.',
                      style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String label) {
    Color color = Colors.blueAccent;
    if (label.toLowerCase().contains('admin')) color = Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSimpleCard(String label, String value, bool active) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isActive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTADO', style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.circle, color: isActive ? Colors.greenAccent : Colors.redAccent, size: 10),
              const SizedBox(width: 8),
              Text(isActive ? 'Activo' : 'Inactivo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
