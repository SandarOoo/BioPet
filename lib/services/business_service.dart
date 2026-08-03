
import 'dart:convert';
import 'dart:typed_data';

import 'package:biopet/services/api_service.dart';
import 'package:biopet/services/order_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
'Content-Type':
'application/json',
'Authorization':
'Bearer $token',
'ngrok-skip-browser-warning':
'true',
},
body: jsonEncode({
'productId': productId,
'quantity': quantity,
'phone': phone,
'address': address,
'paymentMethod':
paymentMethod,
}),
);

debugPrint(
'CREATE ORDER STATUS => '
'${response.statusCode}',
);

debugPrint(
'CREATE ORDER RESPONSE => '
'${response.body}',
);

final data =
jsonDecode(response.body);

if (response.statusCode == 201 &&
data['success'] == true) {
return Map<String, dynamic>.from(
data,
);
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

Future<List<dynamic>>
getMyOrders() async {
return await orderService
    .getMyOrders();
}

// =====================================================
// GET SINGLE ORDER
// CUSTOMER
// =====================================================

Future<Map<String, dynamic>>
getOrderById(
String orderId,
) async {
return await orderService
    .getOrderDetail(
orderId,
);
}

// =====================================================
// GET BUSINESS OWNER ORDERS
// BUSINESS OWNER
// =====================================================

Future<List<dynamic>>
getBusinessOrders() async {
return await orderService
    .getBusinessOrders();
}

// =====================================================
// GET ALL SHOP PRODUCTS
// CUSTOMER SHOP
//
// GET /api/business/shop/products
// =====================================================

Future<List<Product>>
getShopProducts() async {
final url =
'${ApiService.baseUrl}'
'/api/business/shop/products';

debugPrint(
'======================================',
);

debugPrint(
'GET SHOP PRODUCTS',
);

debugPrint(
'URL => $url',
);

debugPrint(
'======================================',
);

try {
final response =
await http.get(
Uri.parse(url),
headers: {
'Content-Type':
'application/json',
'Accept':
'application/json',
'ngrok-skip-browser-warning':
'true',
},
);

debugPrint(
'SHOP PRODUCTS STATUS => '
'${response.statusCode}',
);

debugPrint(
'SHOP PRODUCTS RESPONSE => '
'${response.body}',
);

if (response.statusCode !=
200) {
throw Exception(
'Failed to load products.\n'
'Status: '
'${response.statusCode}\n'
'Response: '
'${response.body}',
);
}

final contentType =
response.headers[
'content-type'] ??
'';

if (!contentType.contains(
'application/json',
)) {
throw Exception(
'Server returned non-JSON response.\n'
'Status: '
'${response.statusCode}\n'
'Response: '
'${response.body}',
);
}

final data =
jsonDecode(response.body);

if (data['success'] !=
true) {
throw Exception(
data['message'] ??
'Failed to load products',
);
}

final List<dynamic>
products =
data['products'] ?? [];

return products
    .map(
(json) =>
Product.fromJson(
Map<String, dynamic>.from(
json,
),
),
)
    .toList();
} catch (e) {
debugPrint(
'GET SHOP PRODUCTS ERROR => '
'$e',
);

rethrow;
}
}

// =====================================================
// UPDATE ORDER STATUS
// =====================================================

Future<Map<String, dynamic>>
updateOrderStatus({
required String orderId,
required String status,
}) async {
final token =
await ApiService.getToken();

final response =
await http.put(
Uri.parse(
'${ApiService.baseUrl}'
'/api/orders/$orderId/status',
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

debugPrint(
'UPDATE ORDER STATUS: '
'${response.statusCode}',
);

debugPrint(
'UPDATE ORDER RESPONSE: '
'${response.body}',
);

final data =
jsonDecode(response.body);

if (response.statusCode == 200 &&
data['success'] == true) {
return Map<String, dynamic>.from(
data,
);
}

throw Exception(
data['message'] ??
'Failed to update order status',
);
}

// =====================================================
// GET BUSINESS OWNER PRODUCTS
//
// GET /api/business/products
// =====================================================

Future<List<Product>>
getProducts() async {
final token =
await ApiService.getToken();

final response =
await http.get(
Uri.parse(
'${ApiService.baseUrl}'
'/api/business/products',
),
headers: {
'Authorization':
'Bearer $token',
'Content-Type':
'application/json',
'Accept':
'application/json',
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

final data =
jsonDecode(response.body);

if (response.statusCode == 200 &&
data['success'] == true) {
final List<dynamic>
products =
data['products'] ?? [];

return products
    .map(
(item) =>
Product.fromJson(
Map<String, dynamic>.from(
item,
),
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
//
// POST /api/business/products
//
// Uses image bytes instead of XFile path.
// This prevents PathNotFoundException.
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
final token =
await ApiService.getToken();

if (token == null ||
token.isEmpty) {
throw Exception(
'Authentication token not found.',
);
}

if (imageBytes.isEmpty) {
throw Exception(
'Product image is empty.',
);
}

final url =
'${ApiService.baseUrl}'
'/api/business/products';

debugPrint(
'======================================',
);

debugPrint(
'ADD PRODUCT REQUEST',
);

debugPrint(
'URL => $url',
);

debugPrint(
'Product Name => $name',
);

debugPrint(
'Category => $category',
);

debugPrint(
'Price => $price',
);

debugPrint(
'Stock => $stock',
);

debugPrint(
'Image Name => $imageFileName',
);

debugPrint(
'Image Bytes => '
'${imageBytes.length}',
);

debugPrint(
'======================================',
);

final request =
http.MultipartRequest(
'POST',
Uri.parse(url),
);

// =====================================================
// HEADERS
// =====================================================

request.headers.addAll({
'Authorization':
'Bearer $token',
'Accept':
'application/json',
'ngrok-skip-browser-warning':
'true',
});

// =====================================================
// TEXT FIELDS
// =====================================================

request.fields.addAll({
'name': name,
'category': category,
'price': price.toString(),
'stock': stock.toString(),
'description': description,
});

// =====================================================
// PREPARE FILE NAME
// =====================================================

String filename =
imageFileName.trim();

if (filename.isEmpty) {
filename =
'product.jpg';
}

String lowerName =
filename.toLowerCase();

// =====================================================
// ENSURE VALID IMAGE EXTENSION
// =====================================================

if (!lowerName.endsWith(
'.jpg',
) &&
!lowerName.endsWith(
'.jpeg',
) &&
!lowerName.endsWith(
'.png',
) &&
!lowerName.endsWith(
'.webp',
)) {
filename =
'$filename.jpg';
}

lowerName =
filename.toLowerCase();

// =====================================================
// DETERMINE MIME TYPE
// =====================================================

MediaType contentType =
MediaType(
'image',
'jpeg',
);

if (lowerName.endsWith(
'.png',
)) {
contentType =
MediaType(
'image',
'png',
);
} else if (lowerName.endsWith(
'.webp',
)) {
contentType =
MediaType(
'image',
'webp',
);
}

// =====================================================
// ADD IMAGE FILE
// =====================================================

request.files.add(
http.MultipartFile.fromBytes(
'image',
imageBytes,
filename: filename,
contentType:
contentType,
),
);

debugPrint(
'UPLOAD FILE NAME => '
'$filename',
);

debugPrint(
'UPLOAD CONTENT TYPE => '
'$contentType',
);

// =====================================================
// SEND REQUEST
// =====================================================

final response =
await request.send();

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

// =====================================================
// SUCCESS
// =====================================================

if (response.statusCode == 200 ||
response.statusCode == 201) {
return true;
}

// =====================================================
// ERROR
// =====================================================

throw Exception(
'Status: '
'${response.statusCode}\n'
'Response: '
'$responseBody',
);
}

// =====================================================
// DELETE PRODUCT
//
// DELETE /api/business/products/:id
// =====================================================

Future<bool> deleteProduct(
String id,
) async {
final token =
await ApiService.getToken();

final response =
await http.delete(
Uri.parse(
'${ApiService.baseUrl}'
'/api/business/products/$id',
),
headers: {
'Authorization':
'Bearer $token',
'Accept':
'application/json',
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

if (response.statusCode >= 200 &&
response.statusCode < 300 &&
data['success'] == true) {
return true;
}

throw Exception(
data['message'] ??
'Failed to delete product',
);
}

// =====================================================
// UPDATE PRODUCT
//
// PUT /api/business/products/:id
//
// Supports optional new image.
// =====================================================

Future<bool> updateProduct({
required String id,
required String name,
required String category,
required String description,
required dynamic price,
required dynamic stock,
Uint8List? imageBytes,
String? imageFileName,
}) async {
try {
final token =
await ApiService.getToken();

if (token == null ||
token.isEmpty) {
throw Exception(
'Authentication token not found.',
);
}

final url =
'${ApiService.baseUrl}'
'/api/business/products/$id';

// =====================================================
// CREATE MULTIPART REQUEST
// =====================================================

final request =
http.MultipartRequest(
'PUT',
Uri.parse(url),
);

// =====================================================
// HEADERS
// =====================================================

request.headers.addAll({
'Authorization':
'Bearer $token',
'Accept':
'application/json',
'ngrok-skip-browser-warning':
'true',
});

// =====================================================
// TEXT FIELDS
// =====================================================

request.fields.addAll({
'name': name,
'category': category,
'description':
description,
'price':
price.toString(),
'stock':
stock.toString(),
});

// =====================================================
// OPTIONAL IMAGE
// =====================================================

if (imageBytes != null &&
imageBytes.isNotEmpty) {
String filename =
imageFileName
    ?.trim() ??
'product.jpg';

if (filename.isEmpty) {
filename =
'product.jpg';
}

String lowerName =
filename.toLowerCase();

if (!lowerName.endsWith(
'.jpg',
) &&
!lowerName.endsWith(
'.jpeg',
) &&
!lowerName.endsWith(
'.png',
) &&
!lowerName.endsWith(
'.webp',
)) {
filename =
'$filename.jpg';
}

lowerName =
filename.toLowerCase();

MediaType contentType =
MediaType(
'image',
'jpeg',
);

if (lowerName.endsWith(
'.png',
)) {
contentType =
MediaType(
'image',
'png',
);
} else if (lowerName.endsWith(
'.webp',
)) {
contentType =
MediaType(
'image',
'webp',
);
}

request.files.add(
http.MultipartFile
    .fromBytes(
'image',
imageBytes,
filename:
filename,
contentType:
contentType,
),
);
}

// =====================================================
// SEND REQUEST
// =====================================================

final response =
await request.send();

final responseBody =
await response.stream
    .bytesToString();

debugPrint(
'UPDATE PRODUCT STATUS => '
'${response.statusCode}',
);

debugPrint(
'UPDATE PRODUCT BODY => '
'$responseBody',
);

if (response.statusCode ==
200 ||
response.statusCode ==
201) {
return true;
}

throw Exception(
'Status: '
'${response.statusCode}\n'
'Response: '
'$responseBody',
);
} catch (e) {
debugPrint(
'UPDATE PRODUCT ERROR: $e',
);

rethrow;
}
}

// =====================================================
// ACCEPT AGREEMENT
// =====================================================

Future<bool> acceptAgreement(
String token,
) async {
final response =
await http.put(
Uri.parse(
'$baseUrl'
'/api/business/agreement',
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
final response =
await http.put(
Uri.parse(
'$baseUrl'
'/api/business/location',
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

return response.statusCode ==
200 &&
data['success'] == true;
}

// =====================================================
// SUBMIT BUSINESS
// =====================================================

Future<bool> submitBusiness(
String token,
) async {
final response =
await http.put(
Uri.parse(
'$baseUrl'
'/api/business/submit',
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

return response.statusCode ==
200 &&
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
'$baseUrl'
'/api/business/profile',
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

if (response.statusCode >=
200 &&
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
'UPDATE BUSINESS PROFILE ERROR: '
'$e',
);

rethrow;
}
}
}
