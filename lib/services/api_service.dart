import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static final baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

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
      final res = await http
          .post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 10));

      print("LOGIN STATUS => ${res.statusCode}");
      print("LOGIN BODY => ${res.body}");

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        await saveToken(data['token']?.toString() ?? '');

        final user = data['user'];

        print("USER => $user");
        print("FULL USER JSON => ${jsonEncode(user)}");

        final id = user?['_id'] ?? user?['id'] ?? '';
        final name = user?['name'] ?? '';

        print("EXTRACTED ID => $id");
        print("EXTRACTED NAME => $name");

        if (id.toString().isNotEmpty) {
          await saveUser(
            id.toString(),
            name.toString(),
          );
        } else {
          print("❌ USER ID IS EMPTY - NOT SAVED");
        }
      }

      return data;
    } catch (e) {
      print("LOGIN ERROR => $e");
      return {"success": false, "message": e.toString()};
    }
  }
  // save classification
  static Future<void> saveClassification(
      String userId,
      Map<String, dynamic> data,
      ) async {
    await http.post(
      Uri.parse('$baseUrl/history/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'data': data,
      }),
    );
  }

  static Future<Map<String,dynamic>?> getCurrentUser() async {

    final token = await getToken();

    if(token == null) return null;


    final response = await http.get(

        Uri.parse(
            "$baseUrl/api/auth/me"
        ),

        headers:{
          "Authorization":"Bearer $token"
        }

    );


    if(response.statusCode == 200){

      return jsonDecode(response.body);

    }


    return null;

  }

  // ─────────────────────────────
  // HISTORY
  // ─────────────────────────────

  static Future<List<dynamic>> getHistory(String userId) async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/api/classify/history'),
      headers: headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }
    throw Exception('Failed to load history');
  }

  static Future<void> deleteHistory(String id) async {
    final headers = await _authHeaders();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/classify/$id'),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete history');
    }
  }

  static Future<Map<String, dynamic>> createClassification({
    required String userId,
    required String imagePath,
    required List<Map<String, dynamic>> breeds,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/api/classify'),
      headers: headers,
      body: jsonEncode({
        'userId': userId,
        'imagePath': imagePath,
        'breeds': breeds,
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to create classification');
  }

  static Future<void> logout() async {
    await clearToken();
    await clearUser();
  }
}