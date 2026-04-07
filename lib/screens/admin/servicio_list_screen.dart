import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/servicio_model.dart';
import '../../responsive_layout.dart';

class ServicioListScreen extends StatefulWidget {
  const ServicioListScreen({super.key});

  @override
  State<ServicioListScreen> createState() => _ServicioListScreenState();
}

class _ServicioListScreenState extends State<ServicioListScreen> {
  final _supabase = Supabase.instance.client;
  List<Servicio> _servicios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServicios();
  }

  Future<void> _fetchServicios() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('servicios')
          .select()
          .order('nombre', ascending: true);
      
      setState(() {
        _servicios = (response as List).map((s) => Servicio.fromJson(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar servicios: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catálogo de Servicios', style: Theme.of(context).textTheme.displayLarge),
                      const Text('Mano de obra, mantenimientos y servicios técnicos.', style: TextStyle(color: Colors.white30)),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text('Nuevo Servicio', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _buildServiceGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    if (_servicios.isEmpty) {
      return const Center(child: Text('No hay servicios disponibles.', style: TextStyle(color: Colors.white30)));
    }
    
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
      
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 3,
        ),
        itemCount: _servicios.length,
        itemBuilder: (context, i) => _buildServiceCard(_servicios[i]),
      );
    });
  }

  Widget _buildServiceCard(Servicio s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF00B2FF).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(LucideIcons.settings, color: Color(0xFF00B2FF), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(s.descripcion ?? 'Sin descripción', style: const TextStyle(color: Colors.white30, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Switch(
            value: s.estado, 
            onChanged: (val) {},
            activeColor: const Color(0xFFFF6B00),
          ),
        ],
      ),
    );
  }
}
