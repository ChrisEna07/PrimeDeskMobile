import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final dynamic employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  int _calculateAge(String? birthDateStr) {
    if (birthDateStr == null) return 0;
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) age--;
      return age;
    } catch (e) { return 0; }
  }

  @override
  Widget build(BuildContext context) {
    final user = employee['usuarios'];
    final bool isActive = user != null ? (user['estado'] ?? true) : true;
    final int roleId = user != null ? (user['id_rol'] ?? 2) : 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Detalles del Empleado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.edit3, size: 20), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2124),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05))
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFFF6B00).withOpacity(0.1),
                    child: Text(employee['nombre'][0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${employee['nombre']} ${employee['apellido']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(user != null ? user['correo'] : 'Sin correo', style: const TextStyle(color: Colors.white30, fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildBadge(isActive ? 'Activo' : 'Inactivo', isActive ? Colors.greenAccent : Colors.redAccent),
                            const SizedBox(width: 8),
                            _buildBadge(roleId == 1 ? 'Administrador' : 'Mecánico', const Color(0xFFFF6B00).withOpacity(0.8)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildInfoSection('Información Personal', [
              _buildInfoRow('NOMBRE', employee['nombre'], 'APELLIDO', employee['apellido']),
              _buildInfoRow('FECHA DE NACIMIENTO', employee['fechanacimiento'] ?? 'N/A', 'EDAD', '${_calculateAge(employee['fechanacimiento'])} años'),
            ]),

            const SizedBox(height: 24),
            _buildInfoSection('Información de Contacto', [
              _buildInfoRow('CORREO ELECTRÓNICO', user != null ? user['correo'] : 'N/A', 'TELÉFONO', employee['telefono'] ?? 'N/A'),
              _buildInfoRow('DIRECCIÓN', employee['direccion'] ?? 'N/A', 'BARRIO', employee['barrio'] ?? 'N/A'),
            ]),

            const SizedBox(height: 24),
            _buildInfoSection('Información Laboral', [
              _buildInfoRow('ROL', roleId == 1 ? 'Administrador' : 'Mecánico', 'FECHA DE INGRESO', employee['fechaingreso'] ?? 'N/A'),
            ]),

            const SizedBox(height: 24),
            _buildInfoSection('Información de Identificación', [
              _buildInfoRow('TIPO DE DOCUMENTO', employee['tipodocumento'] ?? 'Cédula', 'NÚMERO DE DOCUMENTO', employee['documento'] ?? 'N/A'),
            ]),

            const SizedBox(height: 24),
            _buildInfoSection('Información del Sistema', [
              _buildInfoRow('ID DEL EMPLEADO', '#${employee['id_empleado']}', 'ESTADO DE CUENTA', isActive ? 'ACTIVO' : 'INACTIVO'),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF00B2FF), fontSize: 14, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white10, height: 24),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label1, String val1, String label2, String val2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(child: _buildInfoItem(label1, val1)),
          Expanded(child: _buildInfoItem(label2, val2)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
