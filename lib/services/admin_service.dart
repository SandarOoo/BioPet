import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';

class AdminService {
  final String baseUrl = ApiService.baseUrl;

  Future<List<dynamic>> getPendingBusinesses() async {
    final token = await ApiService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/admin/businesses/pending"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["businesses"];
    }

    throw Exception(jsonDecode(response.body)["message"]);
  }

  Future<bool> approveBusiness(String userId) async {
    final token = await ApiService.getToken();

    final response = await http.put(
      Uri.parse(
        "$baseUrl/api/admin/businesses/$userId/approve",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> rejectBusiness(
      String userId,
      String reason,
      ) async {
    final token = await ApiService.getToken();

    final response = await http.put(
      Uri.parse(
        "$baseUrl/api/admin/businesses/$userId/reject",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        "reason": reason,
      }),
    );

    return response.statusCode == 200;
  }
}