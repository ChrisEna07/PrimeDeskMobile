// lib/models/dashboard_stats.dart
import 'package:flutter/material.dart';

class StatModel {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isInteractive;

  StatModel({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    this.isInteractive = false,
  });
}
