
import 'dart:convert';

import 'package:biopet/services/api_service.dart';
import 'package:biopet/services/order_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';

class BusinessService {
final String baseUrl = dotenv.env['BASE_URL'] ?? '';

final OrderService orderService = OrderService();

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
'productId': productId,
'quantity': quantity,
'phone': phone,
'address': address,
'paymentMethod': paymentMethod,
}),
);

debugPrint(
'CREATE ORDER STATUS => ${response.statusCode}',
);

debugPrint(
'CREATE ORDER RESPONSE => ${response.body}',
);

final data = jsonDecode(response.body);

if (response.statusCode == 201 &&
data['success'] == true) {
return Map<String, dynamic>.from(data);
}

throw Exception(
data['message'] ?? 'Failed to create order',
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

// =====================================================
// GET ALL SHOP PRODUCTS
// CUSTOMER SHOP
// GET /api/business/shop/products
// =====================================================

Future<List<Product>> getShopProducts() async {
final url =
'${ApiService.baseUrl}/api/business/shop/products';

debugPrint('======================================');
debugPrint('GET SHOP PRODUCTS');
debugPrint('URL => $url');
debugPrint('======================================');

try {
final response = await http.get(
Uri.parse(url),
headers: {
'Content-Type': 'application/json',
'Accept': 'application/json',
'ngrok-skip-browser-warning': 'true',
},
);

debugPrint(
'SHOP PRODUCTS STATUS => ${response.statusCode}',
);

debugPrint(
'SHOP PRODUCTS RESPONSE => ${response.body}',
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

if (!contentType.contains('application/json')) {
throw Exception(
'Server returned non-JSON response.\n'
'Status: ${response.statusCode}\n'
'Response: ${response.body}',
);
}

final data = jsonDecode(response.body);

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
debugPrint(
'GET SHOP PRODUCTS ERROR => $e',
);

rethrow;
}
}

// =====================================================
// UPDATE ORDER STATUS
// =====================================================

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

debugPrint(
'UPDATE ORDER STATUS: ${response.statusCode}',
);

debugPrint(
'UPDATE ORDER RESPONSE: ${response.body}',
);

final data = jsonDecode(response.body);

if (response.statusCode == 200 &&
data['success'] == true) {
return Map<String, dynamic>.from(data);
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
final token = await ApiService.getToken();

final response = await http.get(
Uri.parse(
'${ApiService.baseUrl}/api/business/products',
),
headers: {
'Authorization': 'Bearer $token',
'Content-Type': 'application/json',
},
);

debugPrint(
'GET BUSINESS PRODUCTS STATUS => '
'${response.statusCode}',
);

debugPrint(
'GET BUSINESS PRODUCTS RESPONSE => '
'${response.body}',
);

final data = jsonDecode(response.body);

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
// FIXED FOR ANDROID XFILE CACHE PATH ERROR
// =====================================================

// =====================================================
// ADD PRODUCT
// Upload image using Uint8List
// This avoids PathNotFoundException from temporary
// ImagePicker cache files.
// =====================================================

  Future<bool> addProduct({
    required String name,
    required String category,
    required double price,
    required int stock,
    required String description,
    required Uint8List imageBytes,
    required String imageFileName,
  }) async {
    try {
      // ===================================================
      // GET TOKEN
      // ===================================================

      final token = await ApiService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token not found.',
        );
      }

      // ===================================================
      // VALIDATE IMAGE BYTES
      // ===================================================

      if (imageBytes.isEmpty) {
        throw Exception(
          'Product image is empty.',
        );
      }

      // ===================================================
      // URL
      // ===================================================

      final url =
          '${ApiService.baseUrl}/api/business/products';

      debugPrint('======================================');
      debugPrint('ADD PRODUCT');
      debugPrint('URL => $url');
      debugPrint('PRODUCT NAME => $name');
      debugPrint('CATEGORY => $category');
      debugPrint('PRICE => $price');
      debugPrint('STOCK => $stock');
      debugPrint('IMAGE NAME => $imageFileName');
      debugPrint(
        'IMAGE BYTES => ${imageBytes.length}',
      );
      debugPrint('======================================');

      // ===================================================
      // CREATE MULTIPART REQUEST
      // ===================================================

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      // ===================================================
      // HEADERS
      // ===================================================

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

      // ===================================================
      // TEXT FIELDS
      // ===================================================

      request.fields.addAll({
        'name': name,
        'category': category,
        'price': price.toString(),
        'stock': stock.toString(),
        'description': description,
      });

      // ===================================================
      // IMAGE
      //
      // IMPORTANT:
      // fromBytes() does NOT use image.path
      //
      // So temporary cache file deletion will NOT cause:
      //
      // PathNotFoundException
      //
      // ===================================================

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName,
        ),
      );

      debugPrint(
        'Sending multipart request...',
      );

      // ===================================================
      // SEND REQUEST
      // ===================================================

      final response =
      await request.send();

      // ===================================================
      // READ RESPONSE
      // ===================================================

      final responseBody =
      await response.stream
          .bytesToString();

      debugPrint(
        'ADD PRODUCT STATUS => '
            '${response.statusCode}',
      );

      debugPrint(
        'ADD PRODUCT BODY => '
            '$responseBody',
      );

      // ===================================================
      // PARSE RESPONSE
      // ===================================================

      Map<String, dynamic>? data;

      try {
        final decoded =
        jsonDecode(responseBody);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        debugPrint(
          'Response is not valid JSON.',
        );
      }

      // ===================================================
      // SUCCESS
      // ===================================================

      if ((response.statusCode == 200 ||
          response.statusCode == 201) &&
          data?['success'] == true) {
        debugPrint(
          'PRODUCT ADDED SUCCESSFULLY',
        );

        return true;
      }

      // ===================================================
      // SOME BACKENDS MAY NOT RETURN success:true
      //
      // If your backend returns 200/201 but no success field,
      // you can still treat it as success.
      // ===================================================

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        debugPrint(
          'PRODUCT CREATED WITH STATUS '
              '${response.statusCode}',
        );

        return true;
      }

      // ===================================================
      // API ERROR
      // ===================================================

      final message =
          data?['message'] ??
              'Failed to add product.';

      throw Exception(
        '$message\n'
            'Status: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint(
        'ADD PRODUCT ERROR => $e',
      );

      rethrow;
    }
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
'Accept': 'application/json',
},
);

debugPrint(
'DELETE PRODUCT STATUS => '
'${response.statusCode}',
);

debugPrint(
'DELETE PRODUCT BODY => '
'${response.body}',
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
'Content-Type':
'application/json',
'Authorization':
'Bearer $token',
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

debugPrint(
'UPDATE PRODUCT STATUS => '
'${response.statusCode}',
);

debugPrint(
'UPDATE PRODUCT BODY => '
'${response.body}',
);

if (response.statusCode == 200) {
return true;
}

return false;
} catch (e) {
debugPrint(
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
'Content-Type':
'application/json',
'Authorization':
'Bearer $token',
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
'Content-Type':
'application/json',
'Authorization':
'Bearer $token',
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
'Authorization':
'Bearer $token',
'Content-Type':
'application/json',
},
);

final data =
jsonDecode(response.body);

return response.statusCode == 200 &&
data['success'] == true;
}

// =====================================================
// UPDATE BUSINESS PROFILE
// =====================================================

Future<Map<String, dynamic>>
updateBusinessProfile({
required String businessName,
required String businessType,
required String address,
required String description,
required String phone,
}) async {
try {
final baseUrl =
ApiService.baseUrl;

final token =
await ApiService.getToken();

if (token == null ||
token.isEmpty) {
throw Exception(
'Authentication token not found.',
);
}

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

debugPrint(
'UPDATE PROFILE STATUS: '
'${response.statusCode}',
);

debugPrint(
'UPDATE PROFILE RESPONSE: '
'${response.body}',
);

final data =
jsonDecode(response.body);

if (response.statusCode >= 200 &&
response.statusCode < 300 &&
data['success'] == true) {
return Map<String, dynamic>.from(
data,
);
}

throw Exception(
data['message'] ??
'Failed to update business profile.',
);
} catch (e) {
debugPrint(
'UPDATE BUSINESS PROFILE ERROR: $e',
);

rethrow;
}
}
}
