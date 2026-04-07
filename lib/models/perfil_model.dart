import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { admin, mecanico, cliente }

class ProfileModel {
  final String id;
  final int rolId;
  final String nombre;
  final String apellido;
  final String? documento;
  final String? telefono;
  final String? direccion;
  final String? fotoUrl;
  final bool estado;

  ProfileModel({
    required this.id,
    required this.rolId,
    required this.nombre,
    required this.apellido,
    this.documento,
    this.telefono,
    this.direccion,
    this.fotoUrl,
    this.estado = true,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      rolId: json['id_rol'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      documento: json['documento'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      fotoUrl: json['foto_url'],
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_rol': rolId,
      'nombre': nombre,
      'apellido': apellido,
      'documento': documento,
      'telefono': telefono,
      'direccion': direccion,
      'foto_url': fotoUrl,
      'estado': estado,
    };
  }

  String get fullname => '$nombre $apellido';
  UserRole get role {
    switch (rolId) {
      case 1: return UserRole.admin;
      case 2: return UserRole.mecanico;
      case 3: return UserRole.cliente;
      default: return UserRole.cliente;
    }
  }
}
