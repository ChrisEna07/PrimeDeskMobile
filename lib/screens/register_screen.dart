import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/auth_controller.dart';
import '../data/repositories/user_repository.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = UserRepository();
      
      // Registrar 
      await repo.registrarUsuarioCompleto(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        idRol: 3, // Rol de Cliente (según dashboard)
        datosPersonales: {
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'telefono': _phoneController.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso. Ahora puedes iniciar sesión.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1113), Color(0xFF1E2124)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.userPlus, size: 60, color: Color(0xFFFF6B00)),
                  const SizedBox(height: 16),
                  const Text('Crear Cuenta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Únete a la familia RafaMotos.', style: TextStyle(color: Colors.white60)),
                  const SizedBox(height: 40),
                  
                  _buildTextField(controller: _nombreController, label: 'Nombre', icon: LucideIcons.user),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _apellidoController, label: 'Apellido', icon: LucideIcons.user),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _emailController, label: 'Correo Electrónico', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _phoneController, label: 'Teléfono', icon: LucideIcons.phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController, 
                    label: 'Contraseña', 
                    icon: LucideIcons.lock, 
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController, 
                    label: 'Confirmar Contraseña', 
                    icon: LucideIcons.shieldCheck, 
                    isPassword: true,
                    obscureText: _obscurePassword,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('REGISTRARSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('¿Ya tienes cuenta? Inicia Sesión', style: TextStyle(color: Colors.white60)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white30, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white30, size: 20),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(obscureText ? LucideIcons.eyeOff : LucideIcons.eye, color: Colors.white30, size: 18),
          onPressed: onToggle,
        ) : null,
        filled: true,
        fillColor: const Color(0xFF1E2124).withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
    );
  }
}
