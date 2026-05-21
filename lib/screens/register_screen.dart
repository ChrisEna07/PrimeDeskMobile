import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../data/repositories/user_repository.dart';
import '../core/utils/hash_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _activeStep = 1;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Controllers Step 1
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  String _tipoDocumento = 'CC';
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();

  // Controllers Step 2
  final _emailController = TextEditingController();
  final _barrioController = TextEditingController();
  final _direccionController = TextEditingController();
  DateTime? _fechaNacimiento;

  // Controllers Step 3
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> _docOptions = ['CC', 'CE', 'TI', 'PP'];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _barrioController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_activeStep == 2 && _fechaNacimiento == null) {
        _showError('Selecciona tu fecha de nacimiento');
        return;
      }
      setState(() => _activeStep++);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = UserRepository();
      await repo.registrarUsuarioCompleto(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        idRol: 3, 
        datosPersonales: {
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'tipodocumento': _tipoDocumento,
          'documento': _documentoController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'barrio': _barrioController.text.trim(),
          'direccion': _direccionController.text.trim(),
          'fechanacimiento': _fechaNacimiento?.toIso8601String().split('T')[0],
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso.')));
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildStepIndicator(),
                const SizedBox(height: 40),
                _buildActiveStepForm(),
                const SizedBox(height: 40),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        ),
        const Text('Crear una cuenta', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle(1, 'Personal'),
        _stepLine(1),
        _stepCircle(2, 'Contacto'),
        _stepLine(2),
        _stepCircle(3, 'Acceso'),
      ],
    );
  }

  Widget _stepCircle(int step, String label) {
    bool isActive = _activeStep >= step;
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? const Color(0xFFFF6B00) : const Color(0xFF1E2124)),
          child: Center(child: Text(step.toString(), style: TextStyle(color: isActive ? Colors.white : Colors.white30))),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.white70 : Colors.white24)),
      ],
    );
  }

  Widget _stepLine(int step) {
    return Container(width: 40, height: 2, margin: const EdgeInsets.only(bottom: 14), color: _activeStep > step ? const Color(0xFFFF6B00) : Colors.white10);
  }

  Widget _buildActiveStepForm() {
    if (_activeStep == 1) return _buildStep1();
    if (_activeStep == 2) return _buildStep2();
    return _buildStep3();
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInput('Nombre *', _nombreController, icon: LucideIcons.user, 
              formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))], 
              validator: (v) => v!.isEmpty ? 'Requerido' : null)),
            const SizedBox(width: 16),
            Expanded(child: _buildInput('Apellido *', _apellidoController, icon: LucideIcons.user, 
              formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))], 
              validator: (v) => v!.isEmpty ? 'Requerido' : null)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDropdown('Tipo Documento', _tipoDocumento, _docOptions, (val) => setState(() => _tipoDocumento = val!)),
        const SizedBox(height: 20),
        _buildInput('Documento *', _documentoController, icon: LucideIcons.creditCard, keyboardType: TextInputType.number, 
          formatters: [FilteringTextInputFormatter.digitsOnly], 
          validator: (v) => (v!.length < 7 || v.length > 10) ? '7-10 dígitos' : null),
        const SizedBox(height: 20),
        _buildInput('Teléfono *', _telefonoController, icon: LucideIcons.phone, keyboardType: TextInputType.phone, 
          formatters: [FilteringTextInputFormatter.digitsOnly], 
          validator: (v) => v!.length != 10 ? '10 dígitos' : null),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _buildInput('Correo electrónico *', _emailController, icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress, 
          validator: (v) => !RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.com$').hasMatch(v!) ? 'correo@ejemplo.com' : null),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInput('Barrio *', _barrioController, icon: LucideIcons.mapPin, validator: (v) => v!.isEmpty ? 'Requerido' : null)),
            const SizedBox(width: 16),
            Expanded(child: _buildDatePicker('Fec. Nacimiento *', _fechaNacimiento, (d) => setState(() => _fechaNacimiento = d))),
          ],
        ),
        const SizedBox(height: 20),
        _buildInput('Dirección *', _direccionController, icon: LucideIcons.home, validator: (v) => v!.isEmpty ? 'Requerido' : null),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _buildInput('Contraseña *', _passwordController, icon: LucideIcons.lock, isPassword: true, obscureText: !_showPassword, 
          onToggle: () => setState(() => _showPassword = !_showPassword), 
          validator: (v) => !RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~%^()_+\-=\[\]{}|;:",./<>?]).{8,}$').hasMatch(v!) 
              ? 'Mín. 8 caracteres, 1 Mayús, 1 Núm y 1 Especial' 
              : null),
        const SizedBox(height: 20),
        _buildInput('Confirmar contraseña *', _confirmPasswordController, icon: LucideIcons.shieldCheck, isPassword: true, obscureText: !_showConfirmPassword, 
          onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword), 
          validator: (v) => v != _passwordController.text ? 'No coinciden' : null),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_activeStep > 1) Expanded(child: OutlinedButton(onPressed: () => setState(() => _activeStep--), child: const Text('Anterior', style: TextStyle(color: Colors.white)))),
        if (_activeStep > 1) const SizedBox(width: 16),
        Expanded(child: ElevatedButton(onPressed: _isLoading ? null : (_activeStep < 3 ? _nextStep : _handleRegister), 
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)), 
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_activeStep < 3 ? 'Continuar' : 'Registrar', style: const TextStyle(color: Colors.white)))),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {IconData? icon, bool isPassword = false, bool obscureText = false, VoidCallback? onToggle, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? formatters, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, obscureText: obscureText, keyboardType: keyboardType, inputFormatters: formatters, validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: Colors.white24, size: 18) : null,
            suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? LucideIcons.eyeOff : LucideIcons.eye, color: Colors.white24, size: 18), onPressed: onToggle) : null,
            filled: true, fillColor: const Color(0xFF1E2124), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(value: value, items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(color: Colors.white)))).toList(), onChanged: onChanged),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: date ?? DateTime(2000), firstDate: DateTime(1920), lastDate: DateTime.now());
            if (d != null) onPick(d);
          },
          child: Container(
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
            child: Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : 'DD/MM/AAAA', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
