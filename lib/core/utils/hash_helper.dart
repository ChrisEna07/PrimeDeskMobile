import 'package:bcrypt/bcrypt.dart';

class HashHelper {
  /// Hashea una cadena usando BCrypt (Algoritmo estándar de la industria)
  static String hashPassword(String password) {
    if (password.isEmpty) return '';
    // Bcrypt genera su propio salt y lo incluye en el hash resultante
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  /// Verifica si una contraseña coincide con un hash BCrypt
  static bool verify(String password, String hashed) {
    if (password.isEmpty || hashed.isEmpty) return false;
    return BCrypt.checkpw(password, hashed);
  }
}
