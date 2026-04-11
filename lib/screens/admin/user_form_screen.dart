import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/hash_helper.dart';

class UserFormScreen extends StatefulWidget {
  final dynamic user;
  const UserFormScreen({super.key, required this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _passController;
  late TextEditingController _verifyPassController;
  
  bool _isSaving = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user['correo'] ?? '');
    _passController = TextEditingController();
    _verifyPassController = TextEditingController();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passController.text.isNotEmpty && _passController.text != _verifyPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updates = {
        'correo': _emailController.text,
      };
      
      if (_passController.text.isNotEmpty) {
        updates['contrasena'] = HashHelper.hashPassword(_passController.text);
      }

      await _supabase.from('usuarios').update(updates).eq('id_usuario', widget.user['id_usuario']);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario actualizado correctamente.')));
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
        title: const Text('Editar Usuario', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_emailController, 'Correo electrónico *', LucideIcons.mail, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              _buildTextField(
                _passController, 
                'Nueva contraseña (opcional)', 
                LucideIcons.lock,
                obscureText: _obscurePass,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? LucideIcons.eyeOff : LucideIcons.eye, size: 18, color: Colors.white30),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_verifyPassController, 'Verificar contraseña *', LucideIcons.shieldCheck, obscureText: _obscurePass),
              
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
                      onPressed: _isSaving ? null : _update,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B2FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Actualizar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, Widget? suffixIcon, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF00B2FF).withOpacity(0.5)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF1E2124),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (val) {
             if (label.contains('*') && (val == null || val.isEmpty)) return 'Requerido';
             return null;
          },
        ),
      ],
    );
  }
}
