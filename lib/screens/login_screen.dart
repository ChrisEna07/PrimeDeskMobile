import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'admin/admin_dashboard.dart';
import 'cliente/client_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthController>();
      final success = await auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          final user = auth.user;
          if (user?.idRol == 3) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (c) => const ClientDashboard()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (c) => const AdminDashboard()));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Acceso Denegado: Su rol no permite entrar al panel o no tiene perfil asignado.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop || isTablet)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F1113), Color(0xFF1E2124)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.bike, size: 100, color: Color(0xFFFF6B00)),
                        const SizedBox(height: 20),
                        Text('PrimeDesk.',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48)),
                        const Text('Gestión inteligente de talleres de motos.',
                            style: TextStyle(fontSize: 18, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFF0F1113),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isDesktop && !isTablet) ...[
                        const Icon(LucideIcons.bike, size: 60, color: Color(0xFFFF6B00)),
                        const SizedBox(height: 20),
                        const Text('PrimeDesk', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 50),
                      ],
                      const Text('Bienvenido de nuevo!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                      const Text('Ingresa a tu cuenta para continuar.', style: TextStyle(color: Colors.white60)),
                      const SizedBox(height: 48),
                      
                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Correo Electrónico',
                        icon: LucideIcons.mail,
                      ),
                      const SizedBox(height: 20),
                      
                      // Contraseña
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        icon: LucideIcons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 40),
                      
                      // Botón
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('INGRESAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white30, size: 20),
            filled: true,
            fillColor: const Color(0xFF1E2124),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5)),
          ),
        ),
      ],
    );
  }
}
