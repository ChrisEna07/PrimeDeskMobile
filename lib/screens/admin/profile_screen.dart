import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/hash_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  Map<String, dynamic>? _employeeData;
  Map<String, dynamic>? _userData;
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSavingPassword = false;

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _documentoController;
  late TextEditingController _telefonoController;
  late TextEditingController _barrioController;
  late TextEditingController _direccionController;
  
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String _tipoDocumento = 'Cédula de Ciudadanía';
  DateTime? _fechaNacimiento;
  
  final List<String> _docOptions = ['Cédula de Ciudadanía', 'Cédula de Extranjería', 'Pasaporte'];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    _documentoController = TextEditingController();
    _telefonoController = TextEditingController();
    _barrioController = TextEditingController();
    _direccionController = TextEditingController();
    
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null || authUser.email == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final userResponse = await _supabase
          .from('usuarios')
          .select('*, roles(*)')
          .eq('correo', authUser.email!)
          .maybeSingle();

      if (userResponse != null) {
        _userData = userResponse;

        final tableName = (userResponse['id_rol'] == 1 || userResponse['id_rol'] == 2) ? 'empleados' : 'clientes';

        final profileResponse = await _supabase
            .from(tableName)
            .select()
            .eq('id_usuario', userResponse['id_usuario'])
            .maybeSingle();

        if (profileResponse != null) {
          _employeeData = profileResponse;
          _nombreController.text = _employeeData!['nombre'] ?? '';
          _apellidoController.text = _employeeData!['apellido'] ?? '';
          _documentoController.text = _employeeData!['documento'] ?? '';
          _telefonoController.text = _employeeData!['telefono'] ?? '';
          _barrioController.text = _employeeData!['barrio'] ?? '';
          _direccionController.text = _employeeData!['direccion'] ?? '';
          
          String docFromDb = _employeeData!['tipodocumento'] ?? 'Cédula de Ciudadanía';
          if (docFromDb == 'CC') docFromDb = 'Cédula de Ciudadanía';
          if (docFromDb == 'CE') docFromDb = 'Cédula de Extranjería';
          if (docFromDb == 'PA' || docFromDb == 'PAS') docFromDb = 'Pasaporte';
          _tipoDocumento = _docOptions.contains(docFromDb) ? docFromDb : _docOptions.first;

          if (_employeeData!['fechanacimiento'] != null) {
            _fechaNacimiento = DateTime.tryParse(_employeeData!['fechanacimiento'].toString());
          }
        } else {
           debugPrint("El usuario existe pero no se encontró en la tabla $tableName.");
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando perfil: $e')));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_employeeData == null || _userData == null) return;

    setState(() => _isSaving = true);
    try {
      String dbTipoDoc = _tipoDocumento;
      if (_tipoDocumento == 'Cédula de Ciudadanía') dbTipoDoc = 'CC';
      else if (_tipoDocumento == 'Cédula de Extranjería') dbTipoDoc = 'CE';
      else if (_tipoDocumento == 'Pasaporte') dbTipoDoc = 'PA';

      final data = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'tipodocumento': dbTipoDoc,
        'documento': _documentoController.text,
        'telefono': _telefonoController.text,
        'barrio': _barrioController.text,
        'direccion': _direccionController.text,
        'fechanacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
      };

      final tableName = (_userData!['id_rol'] == 1 || _userData!['id_rol'] == 2) ? 'empleados' : 'clientes';
      String idColumn = (_userData!['id_rol'] == 1 || _userData!['id_rol'] == 2) ? 'id_empleado' : 'id_cliente';
      
      await _supabase.from(tableName).update(data).eq(idColumn, _employeeData![idColumn]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado correctamente.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isSaving = false);
  }

  Future<void> _updatePassword() async {
    if (!_securityFormKey.currentState!.validate()) return;
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las nuevas contraseñas no coinciden.'), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isSavingPassword = true);
    try {
      // Intentar actualizar en Supabase Auth
      await _supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      // Y sincronizar en 'usuarios'
      if (_userData != null) {
        final hashedPass = HashHelper.hashPassword(_newPasswordController.text);
        await _supabase.from('usuarios').update({'contrasena': hashedPass}).eq('id_usuario', _userData!['id_usuario']);
      }

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada correctamente.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar contraseña. Verifica tu clave actual.'), backgroundColor: Colors.red));
    }
    setState(() => _isSavingPassword = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF2E65F3))); // Match web blue button color
    if (_employeeData == null || _userData == null) return const Center(child: Text('No se encontraron datos del perfil.', style: TextStyle(color: Colors.white24)));

    final roleName = _userData!['roles']?['nombre'] ?? 'Sin rol';
    final isActive = _userData!['estado'] ?? true;
    final fullName = '${_employeeData!['nombre']} ${_employeeData!['apellido']}';

    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header similar to web
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF2E65F3).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.user, color: Color(0xFF2E65F3), size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mi Perfil', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Administra tu información personal y configuración de cuenta.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),

              ],
            ),
            const SizedBox(height: 32),

            // Content Layout
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildLeftPanel(fullName, roleName, _userData!['correo'], isActive)),
                  const SizedBox(width: 24),
                  Expanded(flex: 7, child: _buildRightPanel()),
                ],
              )
            else
              Column(
                children: [
                  _buildLeftPanel(fullName, roleName, _userData!['correo'], isActive),
                  const SizedBox(height: 24),
                  _buildRightPanel(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel(String fullName, String role, String email, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF131518), // Darker panel background from web
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF0F1113),
            backgroundImage: _employeeData!['foto'] != null ? NetworkImage(_employeeData!['foto']) : null,
            child: _employeeData!['foto'] == null ? Text(fullName[0], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)) : null,
          ),
          const SizedBox(height: 24),
          Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
            child: Text(role.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 24),
          _buildProfileInfoRow(LucideIcons.mail, email),
          const SizedBox(height: 16),
          _buildProfileInfoRow(LucideIcons.shield, "Rol: $role"),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.circle, color: isActive ? Colors.greenAccent : Colors.redAccent, size: 12),
              const SizedBox(width: 12),
              const Text("Estado: ", style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(isActive ? "Activo" : "Inactivo", style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        // Personal Data Card
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF131518),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Actualiza tu información básica de contacto.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField(_nombreController, 'Nombres *')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_apellidoController, 'Apellidos *')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDropdown('Tipo Documento', _docOptions)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_documentoController, 'Número Documento *', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_telefonoController, 'Teléfono *', keyboardType: TextInputType.phone)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_barrioController, 'Barrio *')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_direccionController, 'Dirección *'),
                const SizedBox(height: 16),
                _buildDatePicker('Fecha de Nacimiento *', _fechaNacimiento, (d) => setState(() => _fechaNacimiento = d)),
                
                const SizedBox(height: 24),
                const Text('Foto de Perfil', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Desde archivo local', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Ningún archivo seleccionado', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E65F3), // Web blue color
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Security Card
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF131518),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Form(
            key: _securityFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.lock, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    const Text('Seguridad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Modifica la contraseña de acceso a tu cuenta.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 32),
                
                _buildTextField(_currentPasswordController, 'Contraseña Actual *', obscureText: true),
                const SizedBox(height: 16),
                _buildTextField(_newPasswordController, 'Nueva Contraseña *', obscureText: true),
                const SizedBox(height: 16),
                _buildTextField(_confirmPasswordController, 'Confirmar Nueva Contraseña *', obscureText: true),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSavingPassword ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2124), // Web dark grey button
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: _isSavingPassword ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Actualizar Contraseña', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F1113),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2E65F3))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) => label.contains('*') && (value == null || value.isEmpty) ? 'Campo requerido' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    String safeValue = options.contains(_tipoDocumento) ? _tipoDocumento : options[0];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1113), 
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.05))
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: safeValue,
              dropdownColor: const Color(0xFF1E2124),
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, color: Colors.white54, size: 16),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14, color: Colors.white)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _tipoDocumento = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now());
            if (d != null) onPick(d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1113), 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.05))
            ),
            child: Row(
              children: [
                Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                const Spacer(),
                const Icon(LucideIcons.calendar, size: 16, color: Colors.white30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
