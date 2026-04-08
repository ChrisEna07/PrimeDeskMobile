import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class EmployeeFormScreen extends StatefulWidget {
  final dynamic employee; // null para nuevo, con datos para editar
  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _documentoController;
  late TextEditingController _telefonoController;
  late TextEditingController _barrioController;
  late TextEditingController _direccionController;
  late TextEditingController
      _passwordController; // Nuevo controller para contraseña

  String _tipoDocumento = 'Cédula de Ciudadanía';
  DateTime? _fechaNacimiento;
  DateTime? _fechaIngreso;
  bool _isSaving = false;
  bool _obscurePassword = true;

  final List<String> _docOptions = [
    'Cédula de Ciudadanía',
    'Cédula de Extranjería',
    'Pasaporte'
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nombreController =
        TextEditingController(text: e?['nombre']?.toString() ?? '');
    _apellidoController =
        TextEditingController(text: e?['apellido']?.toString() ?? '');
    _documentoController =
        TextEditingController(text: e?['documento']?.toString() ?? '');
    _telefonoController =
        TextEditingController(text: e?['telefono']?.toString() ?? '');
    _barrioController =
        TextEditingController(text: e?['barrio']?.toString() ?? '');
    _direccionController =
        TextEditingController(text: e?['direccion']?.toString() ?? '');
    _passwordController = TextEditingController(); // Inicialización

    if (e != null) {
      final docFromDb = e['tipodocumento']?.toString() ?? 'CC';
      if (docFromDb == 'CC') {
        _tipoDocumento = 'Cédula de Ciudadanía';
      } else if (docFromDb == 'CE') {
        _tipoDocumento = 'Cédula de Extranjería';
      } else if (docFromDb == 'PA' || docFromDb == 'PAS') {
        _tipoDocumento = 'Pasaporte';
      } else {
        _tipoDocumento = docFromDb;
      }

      if (e['fechanacimiento'] != null) {
        _fechaNacimiento = DateTime.tryParse(e['fechanacimiento'].toString());
      }
      if (e['fechaingreso'] != null) {
        _fechaIngreso = DateTime.tryParse(e['fechaingreso'].toString());
      }
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

    // Validar fechas obligatorias
    if (_fechaNacimiento == null || _fechaIngreso == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor seleccione las fechas requeridas.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      String dbTipoDoc = _tipoDocumento;
      if (_tipoDocumento == 'Cédula de Ciudadanía') {
        dbTipoDoc = 'CC';
      } else if (_tipoDocumento == 'Cédula de Extranjería') {
        dbTipoDoc = 'CE';
      } else if (_tipoDocumento == 'Pasaporte') {
        dbTipoDoc = 'PA';
      }

      // Formateo de fecha estricto para PostgreSQL (YYYY-MM-DD)
      final data = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'tipodocumento': dbTipoDoc,
        'documento': _documentoController.text,
        'telefono': _telefonoController.text,
        'barrio': _barrioController.text,
        'direccion': _direccionController.text,
        'fechanacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
        'fechaingreso': _fechaIngreso?.toIso8601String().split('T')[0],
      };

      if (widget.employee != null) {
        // ACTUALIZAR EMPLEADO
        await _supabase
            .from('empleados')
            .update(data)
            .eq('id_empleado', widget.employee['id_empleado']);
      } else {
        // REGISTRAR NUEVO (Usuario + Empleado)
        if (_passwordController.text.isEmpty) {
          throw 'La contraseña es requerida para nuevos empleados.';
        }

        final newUser = await _supabase
            .from('usuarios')
            .insert({
              'correo':
                  'empleado_${DateTime.now().millisecondsSinceEpoch}@primedesk.com',
              'contrasena':
                  _passwordController.text, // Campo corregido (NOT NULL)
              'estado': true,
              'id_rol': 2
            })
            .select('id_usuario')
            .single();

        data['id_usuario'] = newUser['id_usuario'];
        await _supabase.from('empleados').insert(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Operación exitosa.')));
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        elevation: 0,
        title: Text(
            widget.employee != null ? 'Editar Empleado' : 'Nuevo Empleado',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN: ACCESO ---
              if (widget.employee == null) ...[
                const Row(
                  children: [
                    Icon(LucideIcons.shieldCheck,
                        color: Color(0xFF00B2FF), size: 20),
                    SizedBox(width: 12),
                    Text('Credenciales de Acceso',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Contraseña inicial *',
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword)),
                const SizedBox(height: 24),
                const Divider(color: Colors.white10),
                const SizedBox(height: 24),
              ],

              // --- SECCIÓN: DATOS PERSONALES ---
              const Row(
                children: [
                  Icon(LucideIcons.user, color: Color(0xFF00B2FF), size: 20),
                  SizedBox(width: 12),
                  Text('Información Personal',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_nombreController, 'Nombre *')),
                  const SizedBox(width: 16),
                  Expanded(
                      child:
                          _buildTextField(_apellidoController, 'Apellido *')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildDropdown('Tipo de Documento', _docOptions)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          _documentoController, 'Núm. Documento *',
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_telefonoController, 'Teléfono *',
                          keyboardType: TextInputType.phone)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDatePicker(
                          'Fec. Nacimiento *',
                          _fechaNacimiento,
                          (d) => setState(() => _fechaNacimiento = d))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildDatePicker(
                          'Fecha de Ingreso *',
                          _fechaIngreso,
                          (d) => setState(() => _fechaIngreso = d))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(_barrioController, 'Barrio *')),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_direccionController, 'Dirección *'),

              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white10),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B2FF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              widget.employee == null
                                  ? 'Registrar'
                                  : 'Actualizar',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
      bool isPassword = false,
      bool obscureText = false,
      VoidCallback? onToggleVisibility}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E2124),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                        color: Colors.white30,
                        size: 18),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    String safeValue =
        options.contains(_tipoDocumento) ? _tipoDocumento : options[0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: const Color(0xFF1E2124),
              borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeValue,
              dropdownColor: const Color(0xFF1E2124),
              isExpanded: true,
              items: options
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o, style: const TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _tipoDocumento = val);
              },
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? date, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF00B2FF),
                        onPrimary: Colors.white,
                        surface: Color(0xFF1E2124)),
                    dialogTheme: const DialogThemeData(
                      backgroundColor: Color(0xFF0F1113),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (d != null) onPick(d);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFF1E2124),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Text(
                    date != null
                        ? DateFormat('dd/MM/yyyy').format(date)
                        : 'Seleccionar',
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const Spacer(),
                const Icon(LucideIcons.calendar,
                    size: 16, color: Colors.white30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
