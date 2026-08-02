import 'dart:convert';

import 'package:biopet/services/api_service.dart';
import 'package:biopet/services/order_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class BusinessService {
  final String baseUrl =
      dotenv.env['BASE_URL'] ?? '';

  final OrderService orderService =
  OrderService();

  // =====================================================
  // CREATE ORDER
  // CUSTOMER
  // =====================================================

  Future<Map<String, dynamic>> createOrder({
    required String productId,
    required int quantity,
    required String phone,
    required String address,
    String paymentMethod = 'COD',
  }) async {
    final token =
    await ApiService.getToken();

    final response = await http.post(
      Uri.parse(
        '${ApiService.baseUrl}/api/orders',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
        'phone': phone,
        'address': address,
        'paymentMethod': paymentMethod,
      }),
    );

    print(
      'CREATE ORDER STATUS => '
          '${response.statusCode}',
    );

    print(
      'CREATE ORDER RESPONSE => '
          '${response.body}',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 &&
        data['success'] == true) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data['message'] ??
          'Failed to create order',
    );
  }

  // =====================================================
  // GET MY ORDERS
  // CUSTOMER
  // =====================================================

  Future<List<dynamic>> getMyOrders() async {
    return await orderService.getMyOrders();
  }

  // =====================================================
  // GET SINGLE ORDER
  // CUSTOMER
  // =====================================================

  Future<Map<String, dynamic>> getOrderById(
      String orderId,
      ) async {
    return await orderService.getOrderDetail(
      orderId,
    );
  }

  // =====================================================
  // GET BUSINESS OWNER ORDERS
  // BUSINESS OWNER
  // =====================================================


  Future<List<dynamic>> getBusinessOrders() async {
    return await orderService.getBusinessOrders();
  }
  // GET ALL PRODUCTS
  // CUSTOMER SHOP
  // GET /api/business/shop/products
  // =====================================================

  Future<List<Product>> getShopProducts() async {
    final url =
        '${ApiService.baseUrl}/api/business/shop/products';

    print('======================================');
    print('GET SHOP PRODUCTS');
    print('URL => $url');
    print('======================================');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      print(
        'SHOP PRODUCTS STATUS => '
            '${response.statusCode}',
      );

      print(
        'SHOP PRODUCTS RESPONSE => '
            '${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load products.\n'
              'Status: ${response.statusCode}\n'
              'Response: ${response.body}',
        );
      }

      final contentType =
          response.headers['content-type'] ?? '';

      if (!contentType.contains(
        'application/json',
      )) {
        throw Exception(
          'Server returned non-JSON response.\n'
              'Status: ${response.statusCode}\n'
              'Response: ${response.body}',
        );
      }

      final data =
      jsonDecode(response.body);

      if (data['success'] != true) {
        throw Exception(
          data['message'] ??
              'Failed to load products',
        );
      }

      final List<dynamic> products =
          data['products'] ?? [];

      return products
          .map(
            (json) => Product.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();
    } catch (e) {
      print(
        'GET SHOP PRODUCTS ERROR => $e',
      );

      rethrow;
    }
  }


  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final token = await ApiService.getToken();

    final response = await http.put(
      Uri.parse(
        '${ApiService.baseUrl}/api/orders/$orderId/status',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    print(
      'UPDATE ORDER STATUS: ${response.statusCode}',
    );

    print(
      'UPDATE ORDER RESPONSE: ${response.body}',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Failed to update order status',
    );
  }

  // =====================================================
  // GET BUSINESS OWNER PRODUCTS
  // GET /api/business/products
  // =====================================================

  Future<List<Product>> getProducts() async {
    final token =
    await ApiService.getToken();

    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/api/business/products',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(
      'GET BUSINESS PRODUCTS STATUS => '
          '${response.statusCode}',
    );

    print(
      'GET BUSINESS PRODUCTS RESPONSE => '
          '${response.body}',
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      final List<dynamic> products =
          data['products'] ?? [];

      return products
          .map(
            (item) => Product.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    throw Exception(
      data['message'] ??
          'Failed to load products',
    );
  }

  // =====================================================
  // ADD PRODUCT
  // =====================================================

  Future<bool> addProduct(
      Map<String, dynamic> body,
      ) async {
    final token =
    await ApiService.getToken();

    final url =
        '${ApiService.baseUrl}/api/business/createProducts';

    print(
      'ADD PRODUCT URL: $url',
    );

    print(
      'ADD PRODUCT BODY: $body',
    );

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    print(
      'STATUS CODE: ${response.statusCode}',
    );

    print(
      'RESPONSE BODY: ${response.body}',
    );

    if (response.headers['content-type']
        ?.contains('application/json') !=
        true) {
      throw Exception(
        'Server returned non-JSON response.\n'
            'Status: ${response.statusCode}\n'
            'Response: ${response.body}',
      );
    }

    final data =
    jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      return true;
    }

    throw Exception(
      data['message'] ??
          'Failed to add product',
    );
  }

  // =====================================================
  // DELETE PRODUCT
  // =====================================================

  Future<bool> deleteProduct(
      String id,
      ) async {
    final token =
    await ApiService.getToken();

    final response = await http.delete(
      Uri.parse(
        '${ApiService.baseUrl}/api/business/products/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data =
    jsonDecode(response.body);

    return data['success'] == true;
  }

  // =====================================================
  // UPDATE PRODUCT
  // =====================================================

  Future<bool> updateProduct({
    required String id,
    required String name,
    required String category,
    required String description,
    required dynamic price,
    required dynamic stock,
    String? image,
  }) async {
    try {
      final token =
      await ApiService.getToken();

      final response = await http.put(
        Uri.parse(
          '${ApiService.baseUrl}/api/business/products/$id',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'category': category,
          'description': description,
          'price': price,
          'stock': stock,
          'image': image,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }

      print(
        'UPDATE PRODUCT ERROR: '
            '${response.body}',
      );

      return false;
    } catch (e) {
      print(
        'UPDATE PRODUCT ERROR: $e',
      );

      return false;
    }
  }

  // =====================================================
  // ACCEPT AGREEMENT
  // =====================================================

  Future<bool> acceptAgreement(
      String token,
      ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/business/agreement',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'accepted': true,
      }),
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return true;
    }

    return false;
  }

  // =====================================================
  // UPDATE BUSINESS LOCATION
  // =====================================================

  Future<bool> updateLocation(
      String token,
      double latitude,
      double longitude,
      ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/business/location',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    final data =
    jsonDecode(response.body);

    return response.statusCode == 200 &&
        data['success'] == true;
  }

  // =====================================================
  // SUBMIT BUSINESS
  // =====================================================

  Future<bool> submitBusiness(
      String token,
      ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/business/submit',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data =
    jsonDecode(response.body);

    return response.statusCode == 200 &&
        data['success'] == true;
  }



  // ============================================================
  // UPDATE BUSINESS PROFILE
  // ============================================================

  Future<Map<String, dynamic>> updateBusinessProfile({
    required String businessName,
    required String businessType,
    required String address,
    required String description,
    required String phone,
  }) async {
    try {
      // ------------------------------------------
      // GET BASE URL
      // ------------------------------------------

      final baseUrl =
          ApiService.baseUrl;

      // ------------------------------------------
      // GET TOKEN
      // ------------------------------------------

      final token =
      await ApiService.getToken();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          "Authentication token not found.",
        );
      }

      // ------------------------------------------
      // REQUEST
      // ------------------------------------------

      final response =
      await http.put(
        Uri.parse(
          '$baseUrl/api/business/profile',
        ),

        headers: {
          'Content-Type':
          'application/json',

          'Authorization':
          'Bearer $token',
        },

        body: jsonEncode({
          'businessName':
          businessName.trim(),

          'businessType':
          businessType.trim(),

          'address':
          address.trim(),

          'description':
          description.trim(),

          'phone':
          phone.trim(),
        }),
      );

      // ------------------------------------------
      // DEBUG
      // ------------------------------------------

      print(
        'UPDATE PROFILE STATUS: '
            '${response.statusCode}',
      );

      print(
        'UPDATE PROFILE RESPONSE: '
            '${response.body}',
      );

      // ------------------------------------------
      // PARSE RESPONSE
      // ------------------------------------------

      final data =
      jsonDecode(response.body);

      // ------------------------------------------
      // SUCCESS
      // ------------------------------------------

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(
          data,
        );
      }

      // ------------------------------------------
      // API ERROR
      // ------------------------------------------

      throw Exception(
        data['message'] ??
            'Failed to update business profile.',
      );

    } catch (e) {
      print(
        'UPDATE BUSINESS PROFILE ERROR: $e',
      );

      rethrow;
    }
  }
}
