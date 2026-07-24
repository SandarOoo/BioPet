import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String _idKey = 'user_id';
  static const String _nameKey = 'user_name';

  // ✅ SAVE USER AFTER LOGIN
  static Future<void> saveUser(String id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idKey, id);
    await prefs.setString(_nameKey, name);
  }

  // ✅ GET USER ID
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_idKey) ?? '';
  }

  // ✅ GET USER NAME
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'Anonymous';
  }

  // ❌ LOGOUT (CLEAR DATA)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}