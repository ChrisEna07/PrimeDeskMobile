import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/hash_helper.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _documentoController;
  late TextEditingController _telefonoController;
  late TextEditingController _barrioController;
  late TextEditingController _direccionController;
  late TextEditingController _passwordController;

  String _tipoDocumento = 'CC';
  DateTime? _fechaNacimiento;
  DateTime? _fechaIngreso;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.employee?['nombre']);
    _apellidoController = TextEditingController(text: widget.employee?['apellido']);
    _documentoController = TextEditingController(text: widget.employee?['documento']);
    _telefonoController = TextEditingController(text: widget.employee?['telefono']);
    _barrioController = TextEditingController(text: widget.employee?['barrio']);
    _direccionController = TextEditingController(text: widget.employee?['direccion']);
    _passwordController = TextEditingController();

    if (widget.employee != null) {
      _tipoDocumento = widget.employee?['tipodocumento'] ?? 'CC';
      _fechaNacimiento = widget.employee?['fechanacimiento'] != null ? DateTime.parse(widget.employee!['fechanacimiento']) : null;
      _fechaIngreso = widget.employee?['fechaingreso'] != null ? DateTime.parse(widget.employee!['fechaingreso']) : null;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _barrioController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (widget.employee == null) {
        if (_passwordController.text.isEmpty) throw "Contraseña obligatoria.";
        final hashedPass = HashHelper.hashPassword(_passwordController.text);
        final email = 'emp_${DateTime.now().millisecondsSinceEpoch}@primedesk.com';

        final newUser = await _supabase.from('usuarios').insert({'correo': email, 'contrasena': hashedPass, 'estado': true, 'id_rol': 2}).select('id_usuario').single();
        final idUsuario = newUser['id_usuario'];

        await _supabase.from('empleados').insert({
          'id_usuario': idUsuario, 'nombre': _nombreController.text.trim(), 'apellido': _apellidoController.text.trim(),
          'tipodocumento': _tipoDocumento, 'documento': _documentoController.text.trim(), 'telefono': _telefonoController.text.trim(),
          'barrio': _barrioController.text.trim(), 'direccion': _direccionController.text.trim(),
          'fechanacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
          'fechaingreso': _fechaIngreso?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String(),
        });
      } else {
        final idUsuario = widget.employee!['id_usuario'];
        if (_passwordController.text.isNotEmpty) {
          await _supabase.from('usuarios').update({'contrasena': HashHelper.hashPassword(_passwordController.text)}).eq('id_usuario', idUsuario);
        }
        await _supabase.from('empleados').update({
          'nombre': _nombreController.text.trim(), 'apellido': _apellidoController.text.trim(), 'tipodocumento': _tipoDocumento,
          'documento': _documentoController.text.trim(), 'telefono': _telefonoController.text.trim(),
          'barrio': _barrioController.text.trim(), 'direccion': _direccionController.text.trim(),
          'fechanacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
          'fechaingreso': _fechaIngreso?.toIso8601String().split('T')[0],
        }).eq('id_empleado', widget.employee!['id_empleado']);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(title: Text(widget.employee == null ? 'Nuevo Empleado' : 'Editar Empleado'), backgroundColor: Colors.transparent, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _buildField('Nombre *', _nombreController, icon: LucideIcons.user, formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))], validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 16),
              _buildField('Apellido *', _apellidoController, icon: LucideIcons.user, formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))], validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildField('Documento *', _documentoController, icon: LucideIcons.creditCard, keyboardType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => (v!.length < 7 || v.length > 10) ? '7-10 números' : null),
              const SizedBox(height: 16),
              _buildField('Teléfono *', _telefonoController, icon: LucideIcons.phone, keyboardType: TextInputType.phone, formatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => v!.length != 10 ? '10 números' : null),
              const SizedBox(height: 16),
              _buildField('Barrio', _barrioController, icon: LucideIcons.mapPin),
              const SizedBox(height: 16),
              _buildField('Dirección', _direccionController, icon: LucideIcons.home),
              const SizedBox(height: 16),
              _buildDatePicker('Fecha Nacimiento', _fechaNacimiento, (d) => setState(() => _fechaNacimiento = d)),
              const SizedBox(height: 16),
              _buildDatePicker('Fecha Ingreso', _fechaIngreso, (d) => setState(() => _fechaIngreso = d)),
              const SizedBox(height: 16),
              _buildField(widget.employee == null ? 'Contraseña *' : 'Nueva Contraseña (Opcional)', _passwordController, icon: LucideIcons.lock, obscure: true),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _isLoading ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('GUARDAR'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {IconData? icon, bool obscure = false, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? formatters, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, obscureText: obscure, keyboardType: keyboardType, inputFormatters: formatters, validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(prefixIcon: icon != null ? Icon(icon, color: Colors.white24, size: 18) : null, filled: true, fillColor: const Color(0xFF1E2124), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<String>(value: _tipoDocumento, dropdownColor: const Color(0xFF1E2124), isExpanded: true, underline: const SizedBox(), items: ['CC', 'CE', 'TI', 'PP'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(), onChanged: (v) => setState(() => _tipoDocumento = v!)),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final d = await showDatePicker(context: context, initialDate: date ?? now, firstDate: DateTime(1900), lastDate: now);
            if (d != null) onPick(d);
          },
          child: Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [const Icon(LucideIcons.calendar, color: Colors.white24, size: 18), const SizedBox(width: 12), Text(date == null ? 'Seleccionar' : date.toIso8601String().split('T')[0], style: const TextStyle(color: Colors.white))]),
          ),
        ),
      ],
    );
  }
}
