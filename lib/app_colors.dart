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
  
  // Business card colors (specific colors requested)
  static const List<Color> businessCardColors = [
    Color(0xFF1E293B),
    Color(0xFF1F2937),
    Color(0xFF27272A),
    Color(0xFF262626),
  ];
  
  // Gradients using business card colors
  static const LinearGradient businessGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient personalGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient otherGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Utility methods
  static Color getRandomBusinessColor() {
    return businessCardColors[
        DateTime.now().millisecondsSinceEpoch % businessCardColors.length];
  }
  
  static Color getBusinessColorByIndex(int index) {
    return businessCardColors[index % businessCardColors.length];
  }
  
  static Color getRandomPersonalColor() {
    return businessCardColors[
        DateTime.now().millisecondsSinceEpoch % businessCardColors.length];
  }
  
  static Color getRandomOtherColor() {
    return businessCardColors[
        DateTime.now().millisecondsSinceEpoch % businessCardColors.length];
  }
  
  // Red colors for logout button (muted red tones)
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
}