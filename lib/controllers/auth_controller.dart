import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/hash_helper.dart';
import '../models/usuario_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Usuario? user;
  bool isLoading = false;
  bool showPassword = false;

  AuthController() {
    _loadSession();
  }

  void togglePassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('user_email');
    if (email != null) {
      try {
        await _fetchAndSetUser(email);
      } catch (e) {
        debugPrint("Error al restaurar sesión: $e");
      }
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    
    try {
      // 1. Buscamos el usuario en la tabla 'usuarios' (como hace el backend)
      final userResponse = await _supabase
          .from('usuarios') 
          .select('*, roles(nombre)')
          .eq('correo', email)
          .maybeSingle(); 
      
      if (userResponse == null) {
        throw "Credenciales incorrectas."; // Mensaje genérico por seguridad
      }

      // 2. Verificar estado (Como el backend)
      if (userResponse['estado'] == false || userResponse['estado'] == 0) {
        throw "Su cuenta está inactiva. Por favor, contacte con la administración.";
      }

      // 3. Verificar correo verificado (NUEVO: alineado con backend)
      if (userResponse['correo_verificado'] == false || userResponse['correo_verificado'] == 0) {
        throw "Su correo no ha sido verificado. Por favor, revise su bandeja de entrada.";
      }

      // 4. Verificar la contraseña usando BCrypt
      final String storedHash = userResponse['contrasena'] ?? '';
      final bool isPasswordCorrect = HashHelper.verify(password, storedHash);

      if (!isPasswordCorrect) {
        throw "Credenciales incorrectas.";
      }

      // 5. Cargar perfil completo (Joining logic manual)
      int idUsuario = userResponse['id_usuario'];
      int idRol = userResponse['id_rol'];
      
      Map<String, dynamic>? profileResponse;
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
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw "No se encontró el perfil de empleado/cliente vinculado.";
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("Error Login: $e"); 
      rethrow;
    }
  }

  Future<void> _fetchAndSetUser(String email) async {
    final userResponse = await _supabase.from('usuarios').select().eq('correo', email).maybeSingle();
    if (userResponse != null) {
      int idUsuario = userResponse['id_usuario'];
      int idRol = userResponse['id_rol'];
      Map<String, dynamic>? profileResponse;

      if (idRol == 1 || idRol == 2) {
        profileResponse = await _supabase.from('empleados').select().eq('id_usuario', idUsuario).maybeSingle();
      } else {
        profileResponse = await _supabase.from('clientes').select().eq('id_usuario', idUsuario).maybeSingle();
      }

      if (profileResponse != null) {
        user = Usuario.fromMap(userResponse, profileResponse);
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    user = null;
    notifyListeners();
  }

  Future<void> verifyEmail(String token) async {
    final baseUrl = dotenv.env['API_URL'] ?? 'https://api.rmmedellin.site';
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
    if (response.statusCode != 200) {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? errorData['message'] ?? 'Error al verificar correo');
    }
  }

  Future<void> forgotPassword(String email) async {
    final baseUrl = dotenv.env['API_URL'] ?? 'https://api.rmmedellin.site';
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': email}),
    );
    if (response.statusCode != 200) {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? errorData['message'] ?? 'Error al solicitar recuperación de contraseña');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final baseUrl = dotenv.env['API_URL'] ?? 'https://api.rmmedellin.site';
    // Asumiendo que el endpoint es reset-password
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'nueva_contrasena': newPassword}),
    );
    if (response.statusCode != 200) {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? errorData['message'] ?? 'Error al restablecer contraseña');
    }
  }
}
