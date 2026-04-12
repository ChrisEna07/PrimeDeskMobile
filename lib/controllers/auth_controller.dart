import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/hash_helper.dart';
import '../models/usuario_model.dart';

class AuthController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Usuario? user;
  bool isLoading = false;
  bool showPassword = false;

  void togglePassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    
    try {
      // 1. Intentar login en Supabase Auth con la contraseña PLANA
      // Se usa la contraseña tal cual ya que Supabase Auth la verificará contra su hash BCrypt interno
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (authResponse.user != null) {
        // 2. Si Auth funciona, buscamos su ROL en tu tabla pública 'usuarios'
        final userResponse = await _supabase
            .from('usuarios') 
            .select()
            .eq('correo', email)
            .maybeSingle(); 
        
        if (userResponse != null) {
          int idRol = userResponse['id_rol'];
          int idUsuario = userResponse['id_usuario'];
          
          Map<String, dynamic>? profileResponse;
          
          // ID_Rol = 1 es Administrador, 2 es Empleado, etc.
          if (idRol == 1 || idRol == 2) {
            profileResponse = await _supabase
                .from('empleados')
                .select()
                .eq('id_usuario', idUsuario)
                .maybeSingle();
          } else {
            profileResponse = await _supabase
                .from('clientes')
                .select()
                .eq('id_usuario', idUsuario)
                .maybeSingle();
          }

          if (profileResponse != null) {
            user = Usuario.fromMap(userResponse, profileResponse);
            
            isLoading = false;
            notifyListeners();
            return true;
          } else {
            debugPrint("No se encontró perfil en empleados/clientes para el ID: $idUsuario");
            throw "No se encontró un perfil asociado a esta cuenta.";
          }
        } else {
          debugPrint("Usuario autenticado pero no existe registro en la tabla pública 'usuarios'.");
          throw "Su cuenta de acceso existe pero no tiene un perfil configurado en el sistema.";
        }
      }
      
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      String errorMsg = e.toString();
      if (e is AuthException) errorMsg = e.message;
      debugPrint("Error de Supabase Auth: $errorMsg"); 
      throw errorMsg;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    user = null;
    notifyListeners();
  }
}
