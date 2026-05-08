import 'package:shared_preferences/shared_preferences.dart';
const String baseUrl = "http://192.168.1.5:3000";
class AuthService {
  static const String _keyUserId = 'logged_in_user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyToken = 'jwt_token';

  Future<void> saveSession(int userId, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);

    if (token != null) {
      await prefs.setString(_keyToken, token);
    }
  }

  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    return prefs.getInt(_keyUserId);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }
}