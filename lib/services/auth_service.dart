import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUserId = 'logged_in_user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  /// Save session after successful login
  Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Get current logged-in user ID
  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    return prefs.getInt(_keyUserId);
  }

  /// Check if a user is currently logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Clear session (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}