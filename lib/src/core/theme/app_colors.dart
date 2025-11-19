import 'package:flutter/material.dart';

/// Centraliza a paleta da identidade visual para evitar valores mágicos
/// espalhados pelo código e facilitar ajustes de marca.
class AppColors {
  AppColors._();

  /// Paleta inspirada em tons botânicos para reforçar a identidade da
  /// SmartMushroom e garantir contraste em ambos os temas.
  static const Color primary = Color(0xFF2F3B2F); // verde musgo escuro
  static const Color secondary = Color(0xFF4E7053); // verde médio
  static const Color accent = Color(0xFF8EE7A8); // verde claro/estado ideal

  static const Color neutralLight = Color(0xFFF4EEE5); // fundo claro quente
  static const Color neutral = Color(0xFF1C2420); // cinza-esverdeado
  static const Color neutralDark = Color(0xFF0D1410); // quase preto

  static const Color warning = Color(0xFFF6C453);
  static const Color danger = Color(0xFFE16A6A);
}
