import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulacro de notificaciones (en productivo se cargaría de una tabla de logs o notificaciones)
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Nuevo Registro',
        'desc': 'Se ha registrado un nuevo empleado: Carlos Pérez.',
        'time': 'Hace 5 min',
        'icon': LucideIcons.userPlus,
        'color': const Color(0xFF00B2FF)
      },
      {
        'title': 'Solicitud de Cita',
        'desc': 'Nueva solicitud de agendamiento para Yamaha MT-03.',
        'time': 'Hace 1 hora',
        'icon': LucideIcons.calendar,
        'color': const Color(0xFFFF6B00)
      },
      {
        'title': 'Cambio en Inventario',
        'desc': 'El stock de Aceite Motul 10W40 está por debajo del límite.',
        'time': 'Hace 3 horas',
        'icon': LucideIcons.alertTriangle,
        'color': Colors.redAccent
      },
      {
        'title': 'Venta Realizada',
        'desc': 'Venta #1024 completada con éxito por \$450,000.',
        'time': 'Ayer',
        'icon': LucideIcons.dollarSign,
        'color': Colors.greenAccent
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: notifications.isEmpty
        ? _buildEmptyState()
        : ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _buildNotificationCard(notifications[i]),
          ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: n['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(n['icon'], color: n['color'], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(n['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(n['time'], style: const TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n['desc'], style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bellOff, size: 64, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text('No tienes notificaciones pendientes.', style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }
}
