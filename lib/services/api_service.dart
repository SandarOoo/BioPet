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

  static Future<void> saveUser(
      String id,
      String name,
      ) async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'userId',
      id,
    );

    await prefs.setString(
      'userName',
      name,
    );

    print("SAVED USER ID => $id");
    print("SAVED USER NAME => $name");
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getUserName() async {

    final prefs =
    await SharedPreferences.getInstance();

    final name =
    prefs.getString('userName');

    print("GET SAVED USER NAME => $name");

    return name;
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
    try {
      final res = await http
          .post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'role': 'user',
        }),
      )
          .timeout(const Duration(seconds: 15));

      print('REGISTER STATUS => ${res.statusCode}');
      print('REGISTER RESPONSE => ${res.body}');

      final data = jsonDecode(res.body);

      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('REGISTER ERROR => $e');

      return {
        'success': false,
        'message': e.toString(),
      };
    }
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
    try {
      final res = await http
          .post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'name': ownerName.trim(),
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
          'role': 'business_owner',
          'businessProfile': {
            'businessName': shopName.trim(),
            'address': shopAddress.trim(),
          },
        }),
      )
          .timeout(const Duration(seconds: 15));

      print('SHOP OWNER REGISTER STATUS => ${res.statusCode}');
      print('SHOP OWNER REGISTER RESPONSE => ${res.body}');

      final data = jsonDecode(res.body);

      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('SHOP OWNER REGISTER ERROR => $e');

      return {
        'success': false,
        'message': e.toString(),
      };
    }
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
      String email,
      String password,
      ) async {
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

        // =========================
        // SAVE TOKEN
        // =========================

        final token = data['token']?.toString() ?? '';

        await saveToken(token);

        // =========================
        // GET USER
        // =========================

        final user = data['user'];

        print("USER => $user");
        print("FULL USER JSON => ${jsonEncode(user)}");

        if (user != null) {

          final id =
              user['_id'] ??
                  user['id'] ??
                  '';

          final name =
              user['name'] ??
                  '';

          print("EXTRACTED ID => $id");
          print("EXTRACTED NAME => $name");

          // =========================
          // SAVE USER DATA
          // =========================

          if (id.toString().isNotEmpty) {
            await saveUser(
              id.toString(),
              name.toString(),
            );

            print("USER SAVED SUCCESSFULLY");
          }
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

// =====================================================
// CREATE PRODUCT
// BUSINESS OWNER
// =====================================================

  static Future<Map<String, dynamic>>
  createProduct({
    required String name,
    required String category,
    required double price,
    required int stock,
    String description = '',
    String image = '',
  }) async {

    final token =
    await getToken();

    final response =
    await http.post(

      Uri.parse(
        '$baseUrl/api/business/createProducts',
      ),

      headers: {
        'Content-Type':
        'application/json',

        'ngrok-skip-browser-warning':
        'true',

        if (token != null)
          'Authorization':
          'Bearer $token',
      },

      body:
      jsonEncode({

        'name':
        name,

        'category':
        category,

        'price':
        price,

        'stock':
        stock,

        'description':
        description,

        'image':
        image,

      }),

    );


    print(
      'CREATE PRODUCT STATUS => '
          '${response.statusCode}',
    );

    print(
      'CREATE PRODUCT BODY => '
          '${response.body}',
    );


    final data =
    jsonDecode(
      response.body,
    );


    if (
    response.statusCode ==
        201
    ) {

      return data;

    }


    throw Exception(
      data['message'] ??
          'Failed to create product',
    );
  }


// =====================================================
// MY PRODUCTS
// BUSINESS OWNER
// =====================================================

  static Future<List<dynamic>>
  getMyProducts() async {

    final token =
    await getToken();


    final response =
    await http.get(

      Uri.parse(
        '$baseUrl/api/business/products',
      ),

      headers: {

        'Content-Type':
        'application/json',

        'ngrok-skip-browser-warning':
        'true',

        if (token != null)
          'Authorization':
          'Bearer $token',

      },

    );


    print(
      'MY PRODUCTS STATUS => '
          '${response.statusCode}',
    );


    print(
      'MY PRODUCTS BODY => '
          '${response.body}',
    );


    if (
    response.statusCode ==
        200
    ) {

      final data =
      jsonDecode(
        response.body,
      );

      return data['products'] ??
          [];

    }


    throw Exception(
      'Failed to load my products',
    );
  }


// =====================================================
// UPDATE PRODUCT
// BUSINESS OWNER
// =====================================================

  static Future<Map<String, dynamic>>
  updateProduct({

    required String id,

    required String name,

    required String category,

    required double price,

    required int stock,

    String description = '',

    String image = '',

  }) async {

    final token =
    await getToken();


    final response =
    await http.put(

      Uri.parse(
        '$baseUrl/api/business/products/$id',
      ),

      headers: {

        'Content-Type':
        'application/json',

        'ngrok-skip-browser-warning':
        'true',

        if (token != null)
          'Authorization':
          'Bearer $token',

      },

      body:
      jsonEncode({

        'name':
        name,

        'category':
        category,

        'price':
        price,

        'stock':
        stock,

        'description':
        description,

        'image':
        image,

      }),

    );


    final data =
    jsonDecode(
      response.body,
    );


    if (
    response.statusCode ==
        200
    ) {

      return data;

    }


    throw Exception(
      data['message'] ??
          'Failed to update product',
    );
  }


// =====================================================
// DELETE PRODUCT
// BUSINESS OWNER
// =====================================================

  static Future<bool>
  deleteProduct(
      String id,
      ) async {

    final token =
    await getToken();


    final response =
    await http.delete(

      Uri.parse(
        '$baseUrl/api/business/products/$id',
      ),

      headers: {

        'Content-Type':
        'application/json',

        'ngrok-skip-browser-warning':
        'true',

        if (token != null)
          'Authorization':
          'Bearer $token',

      },

    );


    print(
      'DELETE PRODUCT STATUS => '
          '${response.statusCode}',
    );


    if (
    response.statusCode ==
        200
    ) {

      return true;

    }


    return false;
  }

  // ─────────────────────────────
// SELLER ORDERS
// ─────────────────────────────

  static Future<List<dynamic>> getSellerOrders() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/seller'),
      headers: headers,
    );

    print("GET ORDERS STATUS => ${response.statusCode}");
    print("GET ORDERS BODY => ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['orders'] ?? [];
    }

    throw Exception(
      'Failed to load orders: ${response.body}',
    );
  }


// ─────────────────────────────
// UPDATE ORDER STATUS
// ─────────────────────────────

  static Future<Map<String, dynamic>> updateOrderStatus(
      String orderId,
      String status,
      ) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/orders/$orderId/status',
      ),
      headers: headers,
      body: jsonEncode({
        'status': status,
      }),
    );

    print("UPDATE ORDER STATUS => ${response.statusCode}");
    print("UPDATE ORDER BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update order: ${response.body}',
    );
  }
  // save classification
  static Future<void> saveClassification(
      String userId,
      Map<String, dynamic> data,
      ) async {
    final headers = await _authHeaders();

    final url = '$baseUrl/api/classify';

    print('==============================');
    print('💾 SAVE CLASSIFICATION');
    print('🌐 URL => $url');
    print('👤 USER ID => $userId');

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        'userId': userId,
        'data': data,
      }),
    );

    print('📡 STATUS => ${res.statusCode}');
    print('📦 RESPONSE => ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to save classification. '
            'Status: ${res.statusCode}. '
            'Response: ${res.body}',
      );
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();

      print("GET CURRENT USER TOKEN => $token");

      if (token == null || token.isEmpty) {
        print("❌ TOKEN IS NULL OR EMPTY");
        return null;
      }

      final url = "$baseUrl/api/auth/me";

      print("GET CURRENT USER URL => $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
        },
      );

      print(
        "GET CURRENT USER STATUS => ${response.statusCode}",
      );

      print(
        "GET CURRENT USER BODY => ${response.body}",
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;

    } catch (e) {
      print("GET CURRENT USER ERROR => $e");
      return null;
    }
  }

  // ─────────────────────────────
  // HISTORY
  // ─────────────────────────────

  static Future<List<dynamic>> getHistory(String userId) async {
    final headers = await _authHeaders();

    final url = Uri.parse(
      '$baseUrl/api/classify/history',
    );

    print('==============================');
    print('📥 GET HISTORY');
    print('🌐 URL => $url');
    print('👤 USER ID => $userId');
    print('🔑 HEADERS => $headers');

    final res = await http.get(
      url,
      headers: headers,
    );

    print('📡 STATUS => ${res.statusCode}');
    print('📦 RESPONSE => ${res.body}');
    print('==============================');

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      print('✅ HISTORY API SUCCESS');
      print('📊 DATA => ${decoded['data']}');

      return decoded['data'] ?? [];
    }

    throw Exception(
      'Failed to load history. '
          'Status: ${res.statusCode}. '
          'Response: ${res.body}',
    );
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