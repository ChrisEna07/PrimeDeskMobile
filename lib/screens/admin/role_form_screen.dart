import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleFormScreen extends StatefulWidget {
  final dynamic role; // null para nuevo
  const RoleFormScreen({super.key, this.role});

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descController;
  
  List<dynamic> _allPermissions = [];
  List<int> _selectedPermissionIds = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.role?['nombre'] ?? '');
    _descController = TextEditingController(text: widget.role?['descripcion'] ?? '');
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Obtener todos los permisos disponibles
      final perms = await _supabase.from('permisos').select().order('nombre');
      _allPermissions = perms;

      // 2. Si es edición, obtener los permisos ya asignados
      if (widget.role != null) {
        final assigned = await _supabase
            .from('roles_permisos')
            .select('id_permiso')
            .eq('id_rol', widget.role['id_rol']);
        _selectedPermissionIds = (assigned as List).map((e) => e['id_permiso'] as int).toList();
      }
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      int roleId;
      final roleData = {
        'nombre': _nombreController.text,
        'descripcion': _descController.text,
        'estado': true,
      };

      if (widget.role != null) {
        roleId = widget.role['id_rol'];
        await _supabase.from('roles').update(roleData).eq('id_rol', roleId);
        // Limpiar permisos anteriores para re-insertar (estrategia simple de sync)
        await _supabase.from('roles_permisos').delete().eq('id_rol', roleId);
      } else {
        final res = await _supabase.from('roles').insert(roleData).select().single();
        roleId = res['id_rol'];
      }

      // Insertar nuevos permisos
      if (_selectedPermissionIds.isNotEmpty) {
        final List<Map<String, dynamic>> toInsert = _selectedPermissionIds.map((pid) => {
          'id_rol': roleId,
          'id_permiso': pid,
        }).toList();
        await _supabase.from('roles_permisos').insert(toInsert);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rol guardado correctamente.')));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: Text(widget.role != null ? 'Editar Rol' : 'Nuevo Rol', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_nombreController, 'Nombre del Rol', 'Ej: Administrador'),
                  const SizedBox(height: 24),
                  _buildTextField(_descController, 'Descripción', 'Descripción del rol', maxLines: 3),
                  const SizedBox(height: 32),
                  const Text('Permisos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2124),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05))
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _allPermissions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                      itemBuilder: (context, i) {
                        final p = _allPermissions[i];
                        final isSelected = _selectedPermissionIds.contains(p['id_permiso']);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) _selectedPermissionIds.add(p['id_permiso']);
                              else _selectedPermissionIds.remove(p['id_permiso']);
                            });
                          },
                          title: Text(p['nombre'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(p['descripcion'] ?? '', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                          activeColor: const Color(0xFF00B2FF),
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white10),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B2FF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(widget.role != null ? 'Actualizar Rol' : 'Crear Rol', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: const Color(0xFF1E2124),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }
}
