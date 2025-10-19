import 'package:shared_preferences/shared_preferences.dart';

/// UserSession class to manage user data and session state
/// This class provides easy access to user_id and other user information
/// stored in SharedPreferences for API operations
class UserSession {
  static UserSession? _instance;
  static SharedPreferences? _prefs;

  UserSession._internal();

  static Future<UserSession> getInstance() async {
    if (_instance == null) {
      _instance = UserSession._internal();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// Get the current user's ID (critical for API operations)
  static Future<String?> getUserId() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString('user_id');
  }

  /// Get the current user's name
  static Future<String?> getUserName() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString('user_name');
  }

  /// Get the current user's phone number
  static Future<String?> getUserPhone() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString('user_phone');
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool('is_logged_in') ?? false;
  }

  /// Store user data after successful login
  static Future<void> saveUserData({
    required String userId,
    required String phone,
    String? userName,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('user_id', userId);
    await _prefs!.setString('user_phone', phone);
    await _prefs!.setBool('is_logged_in', true);
    
    if (userName != null && userName.isNotEmpty) {
      await _prefs!.setString('user_name', userName);
    }
  }

  /// Clear all user data (for logout)
  static Future<void> clearUserData() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove('user_id');
    await _prefs!.remove('user_name');
    await _prefs!.remove('user_phone');
    await _prefs!.setBool('is_logged_in', false);
  }

  /// Get user data as a map for easy access
  static Future<Map<String, String?>> getUserData() async {
    return {
      'user_id': await getUserId(),
      'user_name': await getUserName(),
      'user_phone': await getUserPhone(),
    };
  }
}