import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/hash_helper.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController(); // Nuevo
  final _docController = TextEditingController();
  final _telController = TextEditingController();
  final _barrioController = TextEditingController();
  final _direccionController = TextEditingController();
  
  String _tipoDoc = 'CC';
  int _idRol = 1;

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: Text(title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('ENTENDIDO', style: TextStyle(color: Color(0xFFFF6B00)))),
        ],
      ),
    );
  }

  Future<void> _createStaff() async {
    // Validar campos vacíos
    if (_emailController.text.isEmpty || _passController.text.isEmpty || 
        _nombreController.text.isEmpty || _docController.text.isEmpty || 
        _telController.text.isEmpty || _barrioController.text.isEmpty) {
      _showErrorDialog('CAMPOS INCOMPLETOS', 'Debes llenar Nombre, Apellido, Documento, Email, Password, Teléfono y Barrio.');
      return;
    }

    // Validar coincidencia de passwords
    if (_passController.text != _confirmPassController.text) {
      _showErrorDialog('ERROR DE CONTRASEÑA', 'Las contraseñas no coinciden. Por favor verifica.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final hashed = HashHelper.hashPassword(_passController.text.trim());
      
      final user = await _supabase.from('usuarios').insert({
        'correo': _emailController.text.trim(),
        'contrasena': hashed,
        'id_rol': _idRol,
        'estado': true,
        'correo_verificado': true,
      }).select('id_usuario').single();

      final idUsuario = user['id_usuario'];

      await _supabase.from('empleados').insert({
        'id_usuario': idUsuario,
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'documento': _docController.text.trim(),
        'telefono': _telController.text.trim(),
        'barrio': _barrioController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'tipodocumento': _tipoDoc,
        'fechanacimiento': '1990-01-01',
        'fechaingreso': DateTime.now().toIso8601String().split('T')[0],
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: const Color(0xFF1E2124),
            title: const Text('¡ÉXITO!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            content: const Text('El usuario y su perfil de empleado han sido creados correctamente.', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('GENIAL', style: TextStyle(color: Color(0xFFFF6B00)))),
            ],
          ),
        );
      }
      _clearFields();
    } catch (e) {
      if (mounted) _showErrorDialog('ERROR DE BASE DE DATOS', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _nombreController.clear(); _apellidoController.clear();
    _emailController.clear(); _passController.clear(); _confirmPassController.clear();
    _docController.clear(); _telController.clear();
    _barrioController.clear(); _direccionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(title: const Text('MODO DESARROLLADOR'), backgroundColor: Colors.red.withOpacity(0.1)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('NUEVO PERSONAL (ADMIN/MEC)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 20),
            _buildDevField('Nombre', _nombreController),
            _buildDevField('Apellido', _apellidoController),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildDevDropdown<String>(
                    label: 'Tipo',
                    value: _tipoDoc,
                    items: ['CC', 'CE', 'NIT', 'Pasaporte'],
                    onChanged: (v) => setState(() => _tipoDoc = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildDevField('Documento', _docController)),
              ],
            ),
            _buildDevField('Email', _emailController),
            _buildDevField('Password', _passController, isPassword: true),
            _buildDevField('Confirmar Password', _confirmPassController, isPassword: true),
            _buildDevField('Teléfono', _telController),
            _buildDevField('Barrio', _barrioController),
            _buildDevField('Dirección', _direccionController),
            const SizedBox(height: 10),
            _buildDevDropdown<int>(
              label: 'Rol de Usuario',
              value: _idRol,
              items: const [1, 2],
              itemLabel: (v) => v == 1 ? 'Administrador' : 'Mecánico',
              onChanged: (v) => setState(() => _idRol = v!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createStaff,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('CREAR PERSONAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.white10),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _purgeDatabase,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.8)),
                child: const Text('BORRAR TODA LA BASE DE DATOS', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purgeDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        title: const Text('¿PURGAR BASE DE DATOS?', style: TextStyle(color: Colors.red)),
        content: const Text('Esto borrará absolutamente todo. ¿Estás seguro?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCELAR')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('BORRAR TODO', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final tables = ['reparaciones_servicios', 'reparaciones_avances', 'reparaciones', 'agendamientos_servicios', 
                      'agendamientos', 'motocicletas', 'compras', 'ventas', 'clientes', 'empleados', 'usuarios'];

      for (var table in tables) {
        try { await _supabase.from(table).delete().neq('id_usuario', -1); } catch (e) { /* skip */ }
      }
      if (mounted) _showErrorDialog('ÉXITO', 'Base de datos purgada completamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDevField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white30, fontSize: 12),
          filled: true, fillColor: const Color(0xFF1E2124),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildDevDropdown<T>({required String label, required T value, required List<T> items, String Function(T)? itemLabel, required ValueChanged<T?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E2124),
            items: items.map((i) => DropdownMenuItem<T>(
              value: i,
              child: Text(itemLabel != null ? itemLabel(i) : i.toString(), style: const TextStyle(color: Colors.white, fontSize: 14)),
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
