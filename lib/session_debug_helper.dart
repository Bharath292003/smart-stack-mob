import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';
import 'package:flutter/foundation.dart';

/// Debug helper to completely clear all session data
class SessionDebugHelper {
  /// Force clear all possible session data
  static Future<void> forceLogout() async {
    try {
      // Clear using UserSession
      await UserSession.clearUserData();
      
      // Get SharedPreferences instance and clear everything
      final prefs = await SharedPreferences.getInstance();
      
      // Remove specific keys
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_phone');
      await prefs.remove('is_logged_in');
      
      // Clear all preferences as backup
      await prefs.clear();
      
      // For web platform: Clear browser localStorage and sessionStorage
      if (kIsWeb) {
        try {
          // Use universal_html for web-specific functionality
          // This will only work on web platform
          print('SessionDebugHelper: Web platform detected - browser storage would be cleared here');
        } catch (e) {
          print('SessionDebugHelper: Browser storage clear failed: $e');
        }
      }
      
      print('SessionDebugHelper: All session data cleared');
    } catch (e) {
      print('SessionDebugHelper: Error clearing session data: $e');
    }
  }
  
  /// Debug method to check current session state
  static Future<void> debugSessionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('=== SESSION DEBUG INFO ===');
      print('UserSession.isLoggedIn(): ${await UserSession.isLoggedIn()}');
      print('UserSession.getUserId(): ${await UserSession.getUserId()}');
      print('UserSession.getUserName(): ${await UserSession.getUserName()}');
      print('UserSession.getUserPhone(): ${await UserSession.getUserPhone()}');
      
      print('SharedPreferences keys: ${prefs.getKeys()}');
      print('is_logged_in: ${prefs.getBool('is_logged_in')}');
      print('user_id: ${prefs.getString('user_id')}');
      print('user_name: ${prefs.getString('user_name')}');
      print('user_phone: ${prefs.getString('user_phone')}');
      print('========================');
    } catch (e) {
      print('SessionDebugHelper: Error debugging session: $e');
    }
  }
}