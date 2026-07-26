import 'dart:convert';
import 'package:biopet/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/business_order.dart';
import '../models/product.dart';

import 'order_service.dart';


class BusinessService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  // =========================================================
// CREATE ORDER
// =========================================================

  Future<Map<String, dynamic>> createOrder({
    required String productId,
    required int quantity,
    required String phone,
    required String address,
    String paymentMethod = "COD",
  }) async {
    final token =
    await ApiService.getToken();

    final response =
    await http.post(

      Uri.parse(
        '${ApiService.baseUrl}/api/orders',
      ),

      headers: {
        'Content-Type':
        'application/json',

        'Authorization':
        'Bearer $token',
      },

      body: jsonEncode({

        'productId':
        productId,

        'quantity':
        quantity,

        'phone':
        phone,

        'address':
        address,

        'paymentMethod':
        paymentMethod,
      }),
    );

    print(
      "CREATE ORDER STATUS => "
          "${response.statusCode}",
    );

    print(
      "CREATE ORDER RESPONSE => "
          "${response.body}",
    );

    final data =
    jsonDecode(response.body);

    if (
    response.statusCode == 201 &&
        data['success'] == true
    ) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Failed to create order',
    );
  }


// =========================================================
// GET MY ORDERS
// =========================================================

  Future<List<dynamic>> getMyOrders() async {
    final token =
    await ApiService.getToken();

    final response =
    await http.get(

      Uri.parse(
        '${ApiService.baseUrl}/api/orders/my',
      ),

      headers: {
        'Authorization':
        'Bearer $token',

        'Content-Type':
        'application/json',
      },
    );

    final data =
    jsonDecode(response.body);

    if (
    response.statusCode == 200 &&
        data['success'] == true
    ) {
      return data['orders'] ?? [];
    }

    throw Exception(
      data['message'] ??
          'Failed to load orders',
    );
  }


// =========================================================
// GET SINGLE ORDER
// =========================================================

  Future<Map<String, dynamic>>
  getOrderById(String orderId,) async {
    final token =
    await ApiService.getToken();

    final response =
    await http.get(

      Uri.parse(
        '${ApiService.baseUrl}/api/orders/$orderId',
      ),

      headers: {
        'Authorization':
        'Bearer $token',
      },
    );

    final data =
    jsonDecode(response.body);

    if (
    response.statusCode == 200 &&
        data['success'] == true
    ) {
      return data['order'];
    }

    throw Exception(
      data['message'] ??
          'Failed to load order',
    );
  }

  /// =========================================================
  // GET ALL PRODUCTS
  // CUSTOMER SHOP
  // GET /api/business/shop/products
  // =========================================================

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


      // ---------------------------------------------------
      // CHECK STATUS
      // ---------------------------------------------------

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load products.\n'
              'Status: ${response.statusCode}\n'
              'Response: ${response.body}',
        );
      }


      // ---------------------------------------------------
      // CHECK JSON
      // ---------------------------------------------------

      final contentType =
          response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        throw Exception(
          'Server returned non-JSON response.\n'
              'Status: ${response.statusCode}\n'
              'Response: ${response.body}',
        );
      }


      final data =
      jsonDecode(response.body);


      // ---------------------------------------------------
      // CHECK SUCCESS
      // ---------------------------------------------------

      if (data['success'] != true) {
        throw Exception(
          data['message'] ??
              'Failed to load products',
        );
      }


      // ---------------------------------------------------
      // GET PRODUCTS
      // ---------------------------------------------------

      final List<dynamic> products =
          data['products'] ?? [];


      return products
          .map(
            (json) =>
            Product.fromJson(
              json,
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


  // get_products

  Future<List<Product>> getProducts() async {
    final token = await ApiService.getToken();

    final response = await http.get(
      Uri.parse(
          "${ApiService.baseUrl}/api/business/products"
      ),
      headers: {
        "Authorization": "Bearer $token"
      },
    );


    final data = jsonDecode(response.body);


    if (response.statusCode == 200) {
      return (data["products"] as List)
          .map(
              (item) => Product.fromJson(item)
      )
          .toList();
    } else {
      throw Exception(
          data["message"] ?? "Failed to load products"
      );
    }
  }


  Future<bool> addProduct(Map<String, dynamic> body) async {
    final token = await ApiService.getToken();

    final url = '${ApiService.baseUrl}/api/business/createProducts';

    print("ADD PRODUCT URL: $url");
    print("ADD PRODUCT BODY: $body");

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    // Prevent jsonDecode HTML error
    if (response.headers['content-type']?.contains('application/json') !=
        true) {
      throw Exception(
        "Server returned non-JSON response.\n"
            "Status: ${response.statusCode}\n"
            "Response: ${response.body}",
      );
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data["success"] == true) {
      return true;
    }

    throw Exception(
      data["message"] ?? "Failed to add product",
    );
  }


  Future<List<BusinessOrder>> getBusinessOrders() async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("User token not found");
    }

    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/api/orders/business',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(
      "GET BUSINESS ORDERS STATUS: ${response.statusCode}",
    );

    print(
      "GET BUSINESS ORDERS RESPONSE: ${response.body}",
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List orders =
          data['orders'] ?? [];

      return orders
          .map(
            (order) =>
            BusinessOrder.fromJson(
              order,
            ),
      )
          .toList();
    }

    throw Exception(
      "Failed to load business orders: ${response.body}",
    );
  }


  // =====================================================
  // UPDATE ORDER STATUS
  // =====================================================

  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("User token not found");
    }

    final response = await http.put(
      Uri.parse(
        '${ApiService.baseUrl}/api/orders/$orderId/status',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    print(
      "UPDATE ORDER STATUS: ${response.statusCode}",
    );

    print(
      "UPDATE ORDER RESPONSE: ${response.body}",
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Failed to update order status',
    );
  }


  Future<bool> deleteProduct(String id) async {
    final token =
    await ApiService.getToken();


    final response =
    await http.delete(

      Uri.parse(
        "${ApiService.baseUrl}/api/business/products/$id",
      ),


      headers: {
        "Authorization": "Bearer $token"
      },


    );


    final data = jsonDecode(response.body);


    return data['success'] == true;
  }

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
      final token = await ApiService.getToken();

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

      print('UPDATE PRODUCT ERROR: ${response.body}');
      return false;
    } catch (e) {
      print('UPDATE PRODUCT ERROR: $e');
      return false;
    }
  }


  Future<bool> acceptAgreement(String token) async {
    final response = await http.put(
        Uri.parse("$baseUrl/api/business/agreement"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"accepted": true})
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      return true;
    }
    return false;
  }

  Future<bool> updateLocation(String token,
      double latitude,
      double longitude,) async {
    final response = await http.put(

      Uri.parse(
          "$baseUrl/api/business/location"
      ),

      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },

      body: jsonEncode({

        "latitude": latitude,
        "longitude": longitude
      }),

    );


    final data = jsonDecode(response.body);


    return response.statusCode == 200 &&
        data["success"] == true;
  }

  Future<bool> submitBusiness(String token) async {
    final response = await http.put(

      Uri.parse(
          "$baseUrl/api/business/submit"
      ),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },

    );


    final data = jsonDecode(response.body);


    return response.statusCode == 200 &&
        data["success"] == true;
  }
}