import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../admin/agendamiento_list_screen.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': LucideIcons.user, 'title': 'Mi Perfil'},
    {'icon': LucideIcons.bike, 'title': 'Mis Motos'},
    {'icon': LucideIcons.calendar, 'title': 'Agendar Cita'},
    {'icon': LucideIcons.history, 'title': 'Mis Servicios'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    
    final List<Widget> screens = [
      const Center(child: Text('Mi Perfil (En construcción)', style: TextStyle(color: Colors.white))),
      const _ClientMotosScreen(),
      AgendamentoListScreen(),
      const Center(child: Text('Historial de Servicios', style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      drawer: _buildDrawer(user?.nombre ?? 'Cliente'),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: Text(_menuItems[_selectedIndex]['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {}),
          const CircleAvatar(radius: 14, backgroundColor: Color(0xFFFF6B00), child: Icon(LucideIcons.user, size: 14, color: Colors.white)),
          const SizedBox(width: 12),
        ],
      ),
      body: screens[_selectedIndex],
    );
  }

  Widget _buildDrawer(String name) {
    return Drawer(
      backgroundColor: const Color(0xFF1E2124),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const CircleAvatar(radius: 40, backgroundColor: Color(0xFF0F1113), child: Icon(LucideIcons.user, size: 40, color: Color(0xFFFF6B00))),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          const Text('Panel de Cliente', style: TextStyle(color: Color(0xFFFF6B00), fontSize: 12)),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, i) {
                final m = _menuItems[i];
                final isSelected = _selectedIndex == i;
                return ListTile(
                  leading: Icon(m['icon'], color: isSelected ? const Color(0xFFFF6B00) : Colors.white30),
                  title: Text(m['title'], style: TextStyle(color: isSelected ? Colors.white : Colors.white30, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  onTap: () {
                    setState(() => _selectedIndex = i);
                    Navigator.pop(context); // Cerrar drawer
                  },
                );
              },
            ),
          ),

          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              await context.read<AuthController>().logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ClientMotosScreen extends StatelessWidget {
  const _ClientMotosScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Aquí aparecerán tus motos registradas.', style: TextStyle(color: Colors.white30)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: const Row(
            children: [
              Icon(LucideIcons.bike, color: Color(0xFFFF6B00), size: 32),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yamaha MT-03', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Placa: ABC-123', style: TextStyle(color: Colors.white30, fontSize: 12)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
