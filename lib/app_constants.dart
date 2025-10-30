/// Application-wide constants and configuration
class AppConstants {
  /// Firebase Authentication Configuration
  /// Set this to true to enable Firebase phone authentication
  /// When false, the app will use the traditional API-based authentication
  static const bool isFirebaseAuthenticationNeeded = true;

  /// API Configuration
  static const String apiBaseUrl = 'http://34.93.230.130:5001';

  // Private constructor to prevent instantiation
  AppConstants._();
}
