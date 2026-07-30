import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';

class OrderService {
  // =====================================================
  // CREATE ORDER
  // CUSTOMER
  // =====================================================

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String name,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    final token = await ApiService.getToken();

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
        'items': items,
        'shippingAddress': {
          'name': name,
          'phone': phone,
          'address': address,
        },
        'paymentMethod': paymentMethod,
      }),
    );

    print(
      'CREATE ORDER STATUS: '
          '${response.statusCode}',
    );

    print(
      'CREATE ORDER RESPONSE: '
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
  // GET BUSINESS OWNER ORDERS
  // BUSINESS OWNER
  // =====================================================

  Future<List<dynamic>> getBusinessOrders() async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not found. Please login again.',
      );
    }

    final url =
        '${ApiService.baseUrl}/api/orders/business';

    print('======================================');
    print('GET BUSINESS ORDERS');
    print('URL => $url');
    print('TOKEN EXISTS => true');
    print('======================================');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    print(
      'GET BUSINESS ORDERS STATUS => '
          '${response.statusCode}',
    );

    print(
      'GET BUSINESS ORDERS RESPONSE => '
          '${response.body}',
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

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return List<dynamic>.from(
        data['orders'] ?? [],
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to load business orders',
    );
  }

  // =====================================================
  // GET MY ORDERS
  // CUSTOMER
  // =====================================================


  // =====================================================
// UPDATE BUSINESS ORDER STATUS
// =====================================================

  // =====================================================
// UPDATE ORDER STATUS
// =====================================================

  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final token =
    await ApiService.getToken();

    final response = await http.put(
      Uri.parse(
        '${ApiService.baseUrl}/api/orders/$orderId/status',
      ),
      headers: {
        'Authorization':
        'Bearer $token',

        'Content-Type':
        'application/json',

        'ngrok-skip-browser-warning':
        'true',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    print(
      'UPDATE ORDER STATUS: '
          '${response.statusCode}',
    );

    print(
      'UPDATE ORDER RESPONSE: '
          '${response.body}',
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Failed to update order status',
    );
  }

  Future<List<dynamic>> getMyOrders() async {
    final token = await ApiService.getToken();

    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/api/orders/my',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return List<dynamic>.from(
        data['orders'] ?? [],
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to load orders',
    );
  }

  // =====================================================
  // GET ORDER DETAIL
  // =====================================================

  Future<Map<String, dynamic>> getOrderDetail(
      String orderId,
      ) async {
    final token = await ApiService.getToken();

    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/api/orders/$orderId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return Map<String, dynamic>.from(
        data['order'],
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to load order',
    );
  }

  // =====================================================
  // CANCEL ORDER
  // CUSTOMER
  // =====================================================

  Future<bool> cancelOrder(
      String orderId,
      ) async {
    final token = await ApiService.getToken();

    final response = await http.put(
      Uri.parse(
        '${ApiService.baseUrl}/api/orders/$orderId/cancel',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    final data = jsonDecode(response.body);

    return response.statusCode == 200 &&
        data['success'] == true;
  }
}