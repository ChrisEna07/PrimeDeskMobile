import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/hash_helper.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('clientes').select('''
            *,
            motocicletas (id_motocicleta),
            usuarios (correo, estado)
          ''').order('nombre', ascending: true);

      if (mounted) {
        setState(() {
          _clientes = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar clientes: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _toggleStatus(dynamic c, bool currentStatus) async {
    try {
      if (c['id_usuario'] != null) {
        await _supabase.from('usuarios').update({'estado': !currentStatus}).eq(
            'id_usuario', c['id_usuario']);
        _fetchClientes();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Este cliente no tiene un usuario vinculado.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteClient(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Row(
          children: [
            Icon(LucideIcons.trash2, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Eliminar Cliente',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          '¿Está seguro de que desea eliminar este cliente? Se borrarán sus datos asociados.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('clientes').delete().eq('id_cliente', id);
        _fetchClientes();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    }
  }

  void _showClientDetails(dynamic c) {
    final List motos = c['motocicletas'] ?? [];
    final user = c['usuarios'];
    final bool isActive = user?['estado'] ?? true;
    final String mail = user?['correo'] ?? 'Sin correo';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Detalles del Cliente',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            IconButton(
                icon:
                    const Icon(LucideIcons.x, color: Colors.white54, size: 20),
                onPressed: () => Navigator.pop(ctx)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2124),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            const Color(0xFF2E65F3).withValues(alpha: 0.1),
                        child: Text(c['nombre']?[0] ?? 'C',
                            style: const TextStyle(
                                color: Color(0xFF2E65F3),
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${c['nombre'] ?? ''} ${c['apellido'] ?? ''}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(mail,
                                style: const TextStyle(color: Colors.white60)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _statusBadge(isActive),
                                _infoBadge('${motos.length} motos'),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('Información Personal'),
                Row(
                  children: [
                    Expanded(
                        child: _detailField(
                            'TIPO DOC', c['tipodocumento'] ?? '-')),
                    Expanded(
                        child:
                            _detailField('DOCUMENTO', c['documento'] ?? '-')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _detailField('TELÉFONO', c['telefono'] ?? '-')),
                    Expanded(
                        child: _detailField(
                            'FECHA NAC.', c['fechanacimiento'] ?? '-')),
                  ],
                ),
                const SizedBox(height: 16),
                _detailField('DIRECCIÓN',
                    '${c['direccion'] ?? '-'}, ${c['barrio'] ?? '-'}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFF2E65F3),
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white10),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (active ? Colors.greenAccent : Colors.redAccent)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(active ? 'Activo' : 'Inactivo',
          style: TextStyle(
              color: active ? Colors.greenAccent : Colors.redAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _detailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white30,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _showClientDialog({dynamic client}) async {
    final isEditing = client != null;
    final user = client?['usuarios'];

    final nombreCtrl = TextEditingController(text: client?['nombre'] ?? '');
    final apellidoCtrl = TextEditingController(text: client?['apellido'] ?? '');
    final correoCtrl = TextEditingController(text: user?['correo'] ?? '');
    final telefonoCtrl = TextEditingController(text: client?['telefono'] ?? '');
    final docNumCtrl = TextEditingController(text: client?['documento'] ?? '');
    final dirCtrl = TextEditingController(text: client?['direccion'] ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131518),
        title: Text(isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
                  _buildInput('Correo electrónico *', correoCtrl,
                      icon: LucideIcons.mail),
                Row(
                  children: [
                    Expanded(child: _buildInput('Nombre *', nombreCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput('Apellido *', apellidoCtrl)),
                  ],
                ),
                _buildInput('Documento', docNumCtrl,
                    icon: LucideIcons.creditCard),
                _buildInput('Teléfono', telefonoCtrl, icon: LucideIcons.phone),
                _buildInput('Dirección', dirCtrl, icon: LucideIcons.mapPin),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isEmpty) return;
              try {
                final Map<String, dynamic> payload = {
                  'nombre': nombreCtrl.text,
                  'apellido': apellidoCtrl.text,
                  'telefono': telefonoCtrl.text,
                  'documento': docNumCtrl.text,
                  'direccion': dirCtrl.text,
                };

                if (isEditing) {
                  await _supabase
                      .from('clientes')
                      .update(payload)
                      .eq('id_cliente', client['id_cliente']);
                } else {
                  final tempPassword = 'cliente_${DateTime.now().millisecondsSinceEpoch}';
                  final String hashedPass = HashHelper.hashPassword(tempPassword);
                  
                  // 1. Crear en Usuarios (Bcrypt)
                  final newUser = await _supabase
                      .from('usuarios')
                      .insert({
                        'correo': correoCtrl.text,
                        'contrasena': hashedPass,
                        'estado': true,
                        'id_rol': 3
                      })
                      .select('id_usuario')
                      .single();

                  payload['id_usuario'] = newUser['id_usuario'];
                  await _supabase.from('clientes').insert(payload);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _fetchClientes();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E65F3)),
            child: Text(isEditing ? 'Guardar Cambios' : 'Registrar'),
          )
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl,
      {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.white24, size: 18) : null,
          filled: true,
          fillColor: const Color(0xFF1E2124),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        _buildStatsHeader(),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E65F3)))
              : _clientes.isEmpty
                  ? const Center(
                      child: Text('No hay clientes.',
                          style: TextStyle(color: Colors.white24)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _clientes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _buildClientCard(_clientes[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Gestión de Clientes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          ElevatedButton.icon(
            onPressed: () => _showClientDialog(),
            icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
            label: const Text('Nuevo Cliente',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E65F3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    int activos =
        _clientes.where((c) => c['usuarios']?['estado'] == true).length;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1E2124),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _statTile('Total', _clientes.length.toString(), LucideIcons.users,
              const Color(0xFF2E65F3)),
          const VerticalDivider(color: Colors.white10),
          _statTile('Activos', activos.toString(), LucideIcons.shieldCheck,
              Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildClientCard(dynamic c) {
    final List motos = c['motocicletas'] ?? [];
    final user = c['usuarios'];
    final bool isActive = user?['estado'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F22),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF2E65F3).withValues(alpha: 0.1),
                child: Text(c['nombre']?[0] ?? 'C',
                    style: const TextStyle(color: Color(0xFF2E65F3))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c['nombre']} ${c['apellido']}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(user?['correo'] ?? 'Sin correo',
                        style: const TextStyle(
                            color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (val) => _toggleStatus(c, isActive),
                activeThumbColor: const Color(0xFF2E65F3),
                activeTrackColor:
                    const Color(0xFF2E65F3).withValues(alpha: 0.3),
              )
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoBadge('${motos.length} Motos'),
              Row(
                children: [
                  IconButton(
                      icon: const Icon(LucideIcons.eye,
                          color: Color(0xFF2E65F3), size: 18),
                      onPressed: () => _showClientDetails(c)),
                  IconButton(
                      icon: const Icon(LucideIcons.edit3,
                          color: Colors.greenAccent, size: 18),
                      onPressed: () => _showClientDialog(client: c)),
                  IconButton(
                      icon: const Icon(LucideIcons.trash2,
                          color: Colors.redAccent, size: 18),
                      onPressed: () => _deleteClient(c['id_cliente'])),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
