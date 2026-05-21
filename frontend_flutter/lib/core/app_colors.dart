import 'package:flutter/material.dart';

class AppColors {
  // Palette de base (70% blanc/clair, 30% Bleu Nil)
  static const Color background = Color(0xFFF6F8FB);
  static const Color white = Color(0xFFFFFFFF);
  
  // Bleu Nil (Couleur principale et ses variantes)
  static const Color primary = Color(0xFF1A4B6E); // Bleu Nil original
  static const Color primaryLight = Color(0xFFE2EFF9); // Teinte très claire pour sélections
  static const Color primaryMedium = Color(0xFF5D8AA8);
  static const Color primaryDark = Color(0xFF0F2E45);

  // Couleurs de texte
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Couleurs d'accent et catégories
  static const Color study = Color(0xFF8B5CF6); // Violet
  static const Color work = Color(0xFF3B82F6); // Bleu royal
  static const Color personal = Color(0xFFEC4899); // Rose
  static const Color health = Color(0xFF10B981); // Émeraude
  static const Color sport = Color(0xFFF59E0B); // Orange
  static const Color meetings = Color(0xFF06B6D4); // Cyan
  static const Color other = Color(0xFF6B7280); // Gris

  // Couleurs des priorités
  static const Color priorityHigh = Color(0xFFEF4444); // Rouge
  static const Color priorityMedium = Color(0xFFF59E0B); // Orange/Jaune
  static const Color priorityLow = Color(0xFF10B981); // Vert

  // Ombres douces (Soft shadows)
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: const Color(0xFF1A4B6E).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
