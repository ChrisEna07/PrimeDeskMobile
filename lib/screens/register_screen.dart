import 'package:flutter/material.dart';
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

  final List<String> _docOptions = [
    'CC', // Cédula de Ciudadanía
    'CE', // Cédula de Extranjería
    'TI', // Tarjeta de Identidad
    'PP', // Pasaporte
  ];

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
    if (_activeStep == 1) {
      if (_nombreController.text.isEmpty || _apellidoController.text.isEmpty) {
        _showError('Nombre y Apellido son obligatorios');
        return;
      }
      if (!RegExp(r'^\d{7,10}$').hasMatch(_documentoController.text)) {
        _showError('Documento debe tener entre 7 y 10 números');
        return;
      }
      if (!RegExp(r'^\d{10}$').hasMatch(_telefonoController.text)) {
        _showError('Teléfono debe tener exactamente 10 números');
        return;
      }
    } else if (_activeStep == 2) {
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailController.text)) {
        _showError('Correo electrónico inválido');
        return;
      }
      if (_barrioController.text.isEmpty || _direccionController.text.isEmpty) {
        _showError('Barrio y Dirección son obligatorios');
        return;
      }
      if (_fechaNacimiento == null) {
        _showError('Fecha de Nacimiento es obligatoria');
        return;
      }
    }

    setState(() => _activeStep++);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _handleRegister() async {
    // Validaciones finales de Paso 3
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};' r'":' r'\\|,.<>\/?]).{8,}$');
    
    if (!passwordRegex.hasMatch(password)) {
      _showError('La contraseña debe tener al menos 8 caracteres, una mayúscula, un número y un carácter especial');
      return;
    }
    if (password != confirm) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = UserRepository();
      
      await repo.registrarUsuarioCompleto(
        email: _emailController.text.trim(),
        password: password.trim(),
        idRol: 3, // Cliente
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso. Revisa tu correo.')),
        );
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
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 20),
        const Text(
          'Crear una cuenta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              '¿Ya tienes una cuenta? ',
              style: TextStyle(color: Colors.white60),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text(
                'Inicia sesión',
                style: TextStyle(
                  color: Color(0xFFFF6B00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFF6B00) : const Color(0xFF1E2124),
            border: Border.all(
              color: isActive ? const Color(0xFFFF6B00) : Colors.white10,
            ),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.white70 : Colors.white24,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(int step) {
    bool isActive = _activeStep > step;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isActive ? const Color(0xFFFF6B00) : Colors.white10,
    );
  }

  Widget _buildActiveStepForm() {
    switch (_activeStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInput('Nombre *', _nombreController, icon: LucideIcons.user)),
            const SizedBox(width: 16),
            Expanded(child: _buildInput('Apellido *', _apellidoController, icon: LucideIcons.user)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDropdown('Tipo Documento', _tipoDocumento, _docOptions, (val) {
          setState(() => _tipoDocumento = val!);
        }),
        const SizedBox(height: 20),
        _buildInput('Número de documento *', _documentoController, icon: LucideIcons.creditCard, keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildInput('Teléfono *', _telefonoController, icon: LucideIcons.phone, keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _buildInput('Correo electrónico *', _emailController, icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildInput('Barrio *', _barrioController, icon: LucideIcons.mapPin)),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePicker(
                'Fec. Nacimiento *',
                _fechaNacimiento,
                (d) => setState(() => _fechaNacimiento = d),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInput('Dirección *', _direccionController, icon: LucideIcons.home),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _buildInput(
          'Contraseña *',
          _passwordController,
          icon: LucideIcons.lock,
          isPassword: true,
          obscureText: !_showPassword,
          onToggle: () => setState(() => _showPassword = !_showPassword),
        ),
        const SizedBox(height: 20),
        _buildInput(
          'Confirmar contraseña *',
          _confirmPasswordController,
          icon: LucideIcons.shieldCheck,
          isPassword: true,
          obscureText: !_showConfirmPassword,
          onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2124),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.sparkles, color: Color(0xFFFF6B00), size: 18),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Por qué registrarte?',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Accede a historial de servicios, recordatorios de mantenimiento y promociones exclusivas.',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_activeStep > 1)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _activeStep--),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white10),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Anterior', style: TextStyle(color: Colors.white)),
            ),
          ),
        if (_activeStep > 1) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : (_activeStep < 3 ? _nextStep : _handleRegister),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _activeStep < 3 ? 'Continuar' : 'Completar Registro',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Icon(_activeStep < 3 ? LucideIcons.arrowRight : LucideIcons.checkCircle, size: 16, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {IconData? icon, bool isPassword = false, bool obscureText = false, VoidCallback? onToggle, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: Colors.white24, size: 18) : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscureText ? LucideIcons.eyeOff : LucideIcons.eye, color: Colors.white24, size: 18),
                    onPressed: onToggle,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF1E2124),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2124),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF1E2124),
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, color: Colors.white24, size: 18),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(color: Colors.white, fontSize: 14)))).toList(),
              onChanged: onChanged,
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
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final d = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime(2000),
              firstDate: DateTime(1920),
              lastDate: now,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(primary: Color(0xFFFF6B00), onPrimary: Colors.white, surface: Color(0xFF1E2124), onSurface: Colors.white),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.calendar, color: Colors.white24, size: 18),
                const SizedBox(width: 12),
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'DD/MM/AAAA',
                  style: TextStyle(color: date != null ? Colors.white : Colors.white24, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
