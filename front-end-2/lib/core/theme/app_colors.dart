import 'package:flutter/material.dart';

/// Paleta oficial do aplicativo — Azul / Branco / Cinza.
///
/// Centralizar as cores aqui garante consistência visual e facilita
/// ajustes globais de identidade sem tocar nas telas.
class AppColors {
  AppColors._();

  // Azuis (cor dominante)
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primarySoft = Color(0xFFE3F0FC);

  // Neutros claros
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  // Cinzas / textos
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color gray = Color(0xFF607D8B);
  static const Color grayLight = Color(0xFF90A4AE);

  // Semânticas
  static const Color success = Color(0xFF2E7D32);
  static const Color successSoft = Color(0xFFE6F4EA);
  static const Color error = Color(0xFFC62828);
  static const Color errorSoft = Color(0xFFFDEAEA);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningSoft = Color(0xFFFFF6E0);

  // Tema escuro
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF131C30);
  static const Color darkBorder = Color(0xFF243147);
  static const Color darkTextPrimary = Color(0xFFE8EDF5);
  static const Color darkTextSecondary = Color(0xFF9AA8BF);
}
