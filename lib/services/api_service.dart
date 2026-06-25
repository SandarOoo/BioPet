import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ IMPORTANT: NO SPACE BEFORE URL
  static const String baseUrl =
      "https://itinerary-smite-expend.ngrok-free.dev";

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // ─────────────────────────────
  // TOKEN
  // ─────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ─────────────────────────────
  // USER DATA
  // ─────────────────────────────

  static Future<void> saveUser(String id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('userName', name);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
  }

  // ─────────────────────────────
  // REGISTER USER
  // ─────────────────────────────

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
      }),
    );

    return jsonDecode(res.body);
  }

  // ─────────────────────────────
  // SHOP OWNER REGISTER
  // ─────────────────────────────

  static Future<Map<String, dynamic>> registerShopOwner({
    required String ownerName,
    required String shopName,
    required String email,
    required String phone,
    required String shopAddress,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': ownerName,
        'email': email,
        'password': password,
        'phone': phone,
        'role': 'business_owner',
        'businessProfile': {
          'businessName': shopName,
          'address': shopAddress,
        }
      }),
    );

    return jsonDecode(res.body);
  }

  // ─────────────────────────────
  // VERIFY EMAIL (OTP)
  // ─────────────────────────────

  static Future<Map<String, dynamic>> verifyEmail(
      String email, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-email'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    return jsonDecode(res.body);
  }

  // ─────────────────────────────
  // RESEND OTP
  // ─────────────────────────────

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/resend-otp'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    return jsonDecode(res.body);
  }

  // ─────────────────────────────
  // LOGIN
  // ─────────────────────────────

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("LOGIN STATUS => ${res.statusCode}");
      print("LOGIN BODY => ${res.body}");

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        await saveToken(data['token']?.toString() ?? '');

        final user = data['user'];

        if (user != null) {
          await saveUser(
            user['_id']?.toString() ?? '',
            user['name']?.toString() ?? '',
          );
        } else {
          print("❌ user is NULL from backend");
        }
      }

      return data;
    } catch (e) {
      print("LOGIN ERROR => $e");
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
  // ─────────────────────────────
  // LOGOUT
  // ─────────────────────────────

  static Future<void> logout() async {
    await clearToken();
    await clearUser();
  }
}