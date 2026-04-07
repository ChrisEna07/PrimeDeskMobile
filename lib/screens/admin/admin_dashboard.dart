import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../responsive_layout.dart';
import '../../controllers/auth_controller.dart';

// Screens
import 'inventory_screen.dart';
import 'repair_list_screen.dart';
import 'client_list_screen.dart';
import 'moto_list_screen.dart';
import 'servicio_list_screen.dart';
import 'agendamiento_list_screen.dart';
import 'supplier_list_screen.dart';
import 'horario_list_screen.dart';
import 'compra_list_screen.dart';
import 'venta_list_screen.dart';
import 'category_list_screen.dart';
import 'employee_list_screen.dart';
import 'user_list_screen.dart';
import 'role_list_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  List<Widget>? _screens;

  // Módulos actualizados con React Parity (incluyendo Compras y Ventas)
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': LucideIcons.layoutDashboard, 'title': 'Dashboard'},
    {'icon': LucideIcons.user, 'title': 'Mi Perfil'},
    {'icon': LucideIcons.shield, 'title': 'Roles'},
    {'icon': LucideIcons.users2, 'title': 'Usuarios'},
    {'icon': LucideIcons.userCheck, 'title': 'Empleados'},
    {'icon': LucideIcons.users, 'title': 'Clientes'},
    {'icon': LucideIcons.bike, 'title': 'Motos'},
    {'icon': LucideIcons.wrench, 'title': 'Reparaciones'},
    {'icon': LucideIcons.settings2, 'title': 'Servicios'},
    {'icon': LucideIcons.clock, 'title': 'Horarios'},
    {'icon': LucideIcons.calendar, 'title': 'Agendamientos'},
    {'icon': LucideIcons.tags, 'title': 'Categorías'},
    {'icon': LucideIcons.package, 'title': 'Productos'},
    {'icon': LucideIcons.truck, 'title': 'Proveedores'},
    {'icon': LucideIcons.shoppingCart, 'title': 'Compras'},
    {'icon': LucideIcons.dollarSign, 'title': 'Ventas'},
    {'icon': LucideIcons.settings, 'title': 'Configuración'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screens ??= [
      _DashboardHome(onNavigate: (index) => setState(() => _selectedIndex = index)),
      const ProfileScreen(),
      const RoleListScreen(),
      const UserListScreen(),
      const EmployeeListScreen(),
      const ClientListScreen(),
      const MotoListScreen(),
      const RepairListScreen(),
      const ServicioListScreen(),
      const HorarioListScreen(),
      const AgendamentoListScreen(),
      const CategoryListScreen(),
      const InventoryScreen(),
      const SupplierListScreen(),
      const CompraListScreen(),
      const VentaListScreen(),
      const _PlaceholderScreen('Configuración', LucideIcons.settings),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_screens == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return ResponsiveLayout(
      mobile: Scaffold(
        drawer: _buildDrawer(user?.nombre ?? 'Admin'),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1113),
          title: Text(_menuItems[_selectedIndex]['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.bell, size: 20),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
            ),
            InkWell(
              onTap: () => setState(() => _selectedIndex = 1),
              child: CircleAvatar(
                radius: 14, 
                backgroundColor: const Color(0xFFFF6B00), 
                child: Text((user?.nombre ?? 'A').isNotEmpty ? (user?.nombre ?? 'A')[0].toUpperCase() : 'A', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: _screens!),
      ),
      desktop: Scaffold(
        body: Row(
          children: [
            Expanded(flex: 2, child: _buildSidebar(user?.nombre ?? 'Admin', user?.idRol == 1 ? 'Admin' : 'Empleado')),
            Expanded(flex: 8, child: IndexedStack(index: _selectedIndex, children: _screens!)),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(String initial) {
    return AppBar(
      backgroundColor: const Color(0xFF0F1113), elevation: 0,
      title: const Text('PrimeDesk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      actions: [
        IconButton(icon: const Icon(LucideIcons.bell, size: 20), onPressed: () {}),
        CircleAvatar(radius: 14, backgroundColor: const Color(0xFFFF6B00), child: Text(initial.isNotEmpty ? initial[0].toUpperCase() : 'A', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildSidebar(String name, String role) {
    return Container(
      color: const Color(0xFF1E2124),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildProfileBanner(name, role),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, i) {
                final m = _menuItems[i];
                final isSelected = _selectedIndex == i;
                return ListTile(
                  dense: true, onTap: () => setState(() => _selectedIndex = i),
                  leading: Icon(m['icon'], color: isSelected ? const Color(0xFFFF6B00) : Colors.white30, size: 18),
                  title: Text(m['title'], style: TextStyle(color: isSelected ? Colors.white : Colors.white30, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected, selectedTileColor: const Color(0xFFFF6B00).withOpacity(0.05),
                );
              },
            ),
          ),
          const Divider(color: Colors.white10),
          ListTile(
            dense: true, leading: const Icon(LucideIcons.logOut, color: Colors.redAccent, size: 18),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            onTap: () async {
              await context.read<AuthController>().logout();
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProfileBanner(String name, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF0F1113), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.1))),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: const Color(0xFFFF6B00).withOpacity(0.2), child: const Icon(LucideIcons.user, color: Color(0xFFFF6B00))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bienvenido', style: TextStyle(color: Colors.white30, fontSize: 10)),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis),
                  Text(role, style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(String name) {
    return Drawer(backgroundColor: const Color(0xFF1E2124), child: _buildSidebar(name, 'Administrador'));
  }
}


// Legacy Profile code removed - using ProfileScreen() from profile_screen.dart

// Pantall Genérica para listar datos
class _DataListScreen extends StatefulWidget {
  final String tableName;
  final String title;
  final IconData icon;
  const _DataListScreen({required this.tableName, required this.title, required this.icon});

  @override
  State<_DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<_DataListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _data = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _fetchData(); }

  Future<void> _fetchData() async {
    try {
      final response = await _supabase.from(widget.tableName).select();
      if (mounted) setState(() { _data = response; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(backgroundColor: const Color(0xFF0F1113), title: Text(widget.title)),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _data.isEmpty ? const Center(child: Text('No hay datos registrados.', style: TextStyle(color: Colors.white30))) : ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: _data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = _data[i];
          return Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(widget.icon, color: const Color(0xFFFF6B00), size: 20),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['nombre'] ?? item['correo'] ?? item['id_venta']?.toString() ?? 'Registro', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (item['descripcion'] != null || item['total'] != null) Text(item['descripcion'] ?? 'Total: \$${item['total']}', style: const TextStyle(color: Colors.white30, fontSize: 11)),
                ])),
                const Icon(LucideIcons.chevronRight, color: Colors.white10),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderScreen(this.title, this.icon);
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 64, color: Colors.white10), const SizedBox(height: 16), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white30)), const Text('Modulo en desarrollo.', style: TextStyle(color: Colors.white10))]));
  }
}

class _DashboardHome extends StatelessWidget {
  final Function(int) onNavigate;
  const _DashboardHome({required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(color: const Color(0xFF0F1113), child: ListView(padding: const EdgeInsets.all(20), children: [Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 12, children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Panel Principal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)), Text('Gestión integral Rafa Motos.', style: TextStyle(color: Colors.white30, fontSize: 11))]), ElevatedButton.icon(onPressed: () => onNavigate(7), icon: const Icon(LucideIcons.plus, color: Colors.white, size: 16), label: const Text('Nueva Reparación', style: TextStyle(color: Colors.white, fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)))]), const SizedBox(height: 24), _buildStats(screenWidth), const SizedBox(height: 32), const Text('Acciones Rápidas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Wrap(spacing: 12, runSpacing: 12, children: [_buildActionCard('Solicitar Cita', LucideIcons.calendarPlus, () => onNavigate(10), (screenWidth - 52) / 2), _buildActionCard('Moto Nueva', LucideIcons.bike, () => onNavigate(6), (screenWidth - 52) / 2), _buildActionCard('Ver Productos', LucideIcons.package, () => onNavigate(12), (screenWidth - 52) / 2)])]));
  }
  Widget _buildStats(double width) { int count = width > 1100 ? 4 : 2; final cardWidth = (width - 40 - (count - 1) * 16) / count; return Wrap(spacing: 16, runSpacing: 16, children: [_buildStatCard('En Reparación', '12', LucideIcons.wrench, const Color(0xFFFF6B00), cardWidth), _buildStatCard('Citas Hoy', '8', LucideIcons.calendar, const Color(0xFF00B2FF), cardWidth), _buildStatCard('Recaudado', '\$1.2M', LucideIcons.dollarSign, Colors.greenAccent, cardWidth), _buildStatCard('Pendientes', '3', LucideIcons.alertCircle, Colors.redAccent, cardWidth)]); }
  Widget _buildStatCard(String t, String v, IconData i, Color c, double w) { return Container(width: w, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i, color: c, size: 18), const SizedBox(height: 8), FittedBox(fit: BoxFit.scaleDown, child: Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Text(t, style: const TextStyle(color: Colors.white30, fontSize: 9), overflow: TextOverflow.ellipsis)])); }
  Widget _buildActionCard(String l, IconData i, VoidCallback t, double w) { return InkWell(onTap: t, child: Container(width: w, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(i, color: Colors.white60, size: 16), const SizedBox(width: 8), Expanded(child: Text(l, style: const TextStyle(fontSize: 11, color: Colors.white70), overflow: TextOverflow.ellipsis))]))); }
}
