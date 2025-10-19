import 'package:flutter/material.dart';

/// App-wide color constants based on the design reference
class AppColors {
  // Primary dark colors from design reference
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color secondaryDark = Color(0xFF1E293B);
  static const Color tertiaryDark = Color(0xFF262626);
  static const Color quaternaryDark = Color(0xFF27272A);
  static const Color quinquenaryDark = Color(0xFF1F2937);
  
  // Slate color palette
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  
  // Business card colors (dark theme)
  static const List<Color> businessCardColors = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
    Color(0xFF262626),
    Color(0xFF374151),
    Color(0xFF4B5563),
  ];
  
  // Personal card colors (vibrant theme)
  static const List<Color> personalCardColors = [
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Violet
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFF84CC16), // Lime
    Color(0xFFEC4899), // Pink
  ];
  
  // Other card colors (purple theme)
  static const List<Color> otherCardColors = [
    Color(0xFF8B5CF6), // Violet
    Color(0xFF7C3AED), // Purple
    Color(0xFF6366F1), // Indigo
    Color(0xFF3B82F6), // Blue
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
  ];
  
  // Gradient combinations
  static const LinearGradient businessGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient personalGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient otherGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Utility methods
  static Color getRandomBusinessColor() {
    return businessCardColors[
        DateTime.now().millisecondsSinceEpoch % businessCardColors.length];
  }
  
  static Color getRandomPersonalColor() {
    return personalCardColors[
        DateTime.now().millisecondsSinceEpoch % personalCardColors.length];
  }
  
  static Color getRandomOtherColor() {
    return otherCardColors[
        DateTime.now().millisecondsSinceEpoch % otherCardColors.length];
  }
}