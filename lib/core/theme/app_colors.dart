import 'package:flutter/material.dart';

/// Centraliza a paleta da identidade visual para evitar valores mágicos
/// espalhados pelo código e facilitar ajustes de marca.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B1F3B);
  static const Color secondary = Color(0xFF2E6E85);
  static const Color accent = Color(0xFF66C6A2);
  static const Color neutralLight = Color(0xFFF4F5F7);
  static const Color neutral = Color(0xFF1F2430);
  static const Color neutralDark = Color(0xFF0E111A);
  static const Color warning = Color(0xFFFFB74D);
  static const Color danger = Color(0xFFE57373);
}
