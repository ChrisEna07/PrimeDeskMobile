import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/dialog_helper.dart';
import '../admin/agendamiento_list_screen.dart';
import '../admin/profile_screen.dart';

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
      const ProfileScreen(),
      const _ClientMotosScreen(),
      const AgendamentoListScreen(),
      const Center(child: Text('Historial de Servicios', style: TextStyle(color: Colors.white))),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await DialogHelper.showConfirm(
          context,
          title: 'Salir',
          message: '¿Seguro que quieres salir?',
          confirmText: 'Salir',
          cancelText: 'Cancelar',
        );
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
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
              final confirm = await DialogHelper.showConfirm(
                context,
                title: 'Cerrar Sesión',
                message: '¿Seguro que quieres cerrar sesión?',
                confirmText: 'Salir',
                cancelText: 'Cancelar',
              );
              if (confirm == true && context.mounted) {
                await context.read<AuthController>().logout();
                if (context.mounted) {
                  await DialogHelper.showSuccess(context, message: 'Cierre de sesión exitoso');
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ClientMotosScreen extends StatefulWidget {
  const _ClientMotosScreen();

  @override
  State<_ClientMotosScreen> createState() => _ClientMotosScreenState();
}

class _ClientMotosScreenState extends State<_ClientMotosScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _motos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMotos();
  }

  Future<void> _fetchMotos() async {
    try {
      final user = context.read<AuthController>().user;
      if (user?.idAsociado == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final response = await _supabase
          .from('motocicletas')
          .select()
          .eq('id_cliente', user!.idAsociado!);
      if (mounted) {
        setState(() {
          _motos = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading client motos: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Aquí aparecerán tus motos registradas.', style: TextStyle(color: Colors.white30)),
        const SizedBox(height: 16),
        if (_motos.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('No tienes motos registradas.', style: TextStyle(color: Colors.white24)),
            ),
          )
        else
          ..._motos.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2124),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.bike, color: Color(0xFFFF6B00), size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${m['marca']} ${m['modelo']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        Text('Placa: ${m['placa']}', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                        if (m['color'] != null) Text('Color: ${m['color']}', style: const TextStyle(color: Colors.white30, fontSize: 11)),
                      ],
                    )
                  ],
                ),
              )),
      ],
    );
  }
}
