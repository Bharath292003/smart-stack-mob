import 'package:flutter/material.dart';

class AppColors {
  // Background color for the entire application
  static const Color background = Color(0xFFFFFFFF); // #FFFFFF
  
  // Card colors - to be used alternately, not mixed in single card
  static const Color cardColor1 = Color(0xFF1E2025); // #1E2025 - Dark
  static const Color cardColor2 = Color(0xFFE7B595); // #E7B595 - Light Orange
  static const Color cardColor3 = Color(0xFFCBD5DE); // #CBD5DE - Light Blue
  
  // Text colors based on card backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF); // White text for dark cards
  static const Color textOnLight = Color(0xFF1E2025); // Dark text for light cards
  
  // Button and interactive element colors
  static const Color primaryButton = Color(0xFF1E2025);
  static const Color primaryButtonText = Color(0xFFFFFFFF);
  
  // Input field colors
  static const Color inputBorder = Color(0xFFCBD5DE);
  static const Color inputFocused = Color(0xFF1E2025);
  static const Color inputLabel = Color(0xFF1E2025);
  static const Color inputText = Color(0xFF1E2025);
  
  // Error colors
  static const Color error = Color(0xFFE74C3C);
  
  // Helper method to get card color by index
  static Color getCardColor(int index) {
    switch (index % 3) {
      case 0:
        return cardColor1;
      case 1:
        return cardColor2;
      case 2:
        return cardColor3;
      default:
        return cardColor1;
    }
  }
  
  // Helper method to get text color based on card color
  static Color getTextColorForCard(Color cardColor) {
    if (cardColor == cardColor1) {
      return textOnDark; // White text for dark card
    } else {
      return textOnLight; // Dark text for light cards
    }
  }
}