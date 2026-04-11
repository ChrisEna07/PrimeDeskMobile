import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashHelper {
  /// Hashea una cadena usando SHA-256 (Mismo método que suele usarse en React/CryptoJS)
  static String hashPassword(String password) {
    if (password.isEmpty) return '';
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
