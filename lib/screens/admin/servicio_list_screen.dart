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

  Future<void> _showServiceDialog({Servicio? servicioToEdit}) async {
    final nombreController = TextEditingController(text: servicioToEdit?.nombre ?? '');
    final descController = TextEditingController(text: servicioToEdit?.descripcion ?? '');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        title: Text(servicioToEdit == null ? 'Nuevo Servicio' : 'Editar Servicio', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nombre del Servicio *', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ej: Mantenimiento Preventivo',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E2124),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Descripción *', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describa detalladamente el servicio...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E2124),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
               if (nombreController.text.isEmpty) return;
               try {
                  if (servicioToEdit == null) {
                    await _supabase.from('servicios').insert({
                      'nombre': nombreController.text,
                      'descripcion': descController.text,
                      'estado': true
                    });
                  } else {
                     await _supabase.from('servicios').update({
                      'nombre': nombreController.text,
                      'descripcion': descController.text,
                    }).eq('id_servicio', servicioToEdit.id!);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
               } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
               }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E65F3), foregroundColor: Colors.white),
            child: Text(servicioToEdit == null ? 'Crear Servicio' : 'Guardar Cambios'),
          )
        ],
      )
    );

    if (result == true) {
      _fetchServicios();
    }
  }

  Future<void> _toggleEstado(Servicio s, bool val) async {
    try {
      await _supabase.from('servicios').update({'estado': val}).eq('id_servicio', s.id!);
      _fetchServicios();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteServicio(Servicio s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        title: const Text('Eliminar Servicio', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de eliminar el servicio "${s.nombre}"? Esta acción no se puede deshacer.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
               try {
                  await _supabase.from('servicios').delete().eq('id_servicio', s.id!);
                  if (ctx.mounted) Navigator.pop(ctx, true);
               } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
               }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          )
        ]
      )
    );
    if (confirm == true) _fetchServicios();
  }

  void _showDetails(Servicio s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        title: const Text('Detalles del Servicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre:', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12, fontWeight: FontWeight.bold)),
            Text(s.nombre, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 12),
            const Text('Descripción:', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12, fontWeight: FontWeight.bold)),
            Text(s.descripcion ?? 'Sin descripción', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            const Text('Estado Oficial:', style: TextStyle(color: Color(0xFF00B2FF), fontSize: 12, fontWeight: FontWeight.bold)),
            Text(s.estado ? 'ACTIVO' : 'INACTIVO', style: TextStyle(color: s.estado ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar', style: TextStyle(color: Colors.white))),
        ],
      )
    );
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
                  onPressed: () => _showServiceDialog(),
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text('Nuevo Servicio', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E65F3), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
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
      if (constraints.maxWidth <= 800) {
        return ListView.separated(
          itemCount: _servicios.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 16),
          itemBuilder: (ctx, i) => _buildServiceCard(_servicios[i]),
        );
      }

      final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
      
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 2.2,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Switch(
                value: s.estado, 
                onChanged: (val) => _toggleEstado(s, val),
                activeColor: const Color(0xFF00B2FF),
              ),
              Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.eye, color: Color(0xFF2E65F3), size: 18),
                    onPressed: () => _showDetails(s),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, color: Colors.greenAccent, size: 18),
                    onPressed: () => _showServiceDialog(servicioToEdit: s),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
                    onPressed: () => _deleteServicio(s),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ]
          )
        ],
      ),
    );
  }
}
