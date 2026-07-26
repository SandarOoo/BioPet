import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostApiService {
  static final baseUrl = dotenv.env['BASE_URL'] ?? "";

  // ─────────────────────────────
  // TOKEN
  // ─────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers({bool isJson = true}) async {
    final token = await getToken();

    return {
      if (isJson) "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ─────────────────────────────
  // CURRENT USER
  // ─────────────────────────────
  static String _currentUserId = "guest";
  static String _currentUserName = "Guest";

  static void setUser({
    required String id,
    required String name,
  }) {
    _currentUserId = id;
    _currentUserName = name;
  }

  static String get currentUserId => _currentUserId;
  static String get currentUserName => _currentUserName;

  // ─────────────────────────────
  // FETCH POSTS
  // ─────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchPosts(int page) async {
    final uri = Uri.parse("$baseUrl/api/posts?page=$page&limit=10");

    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode != 200) {
      throw Exception("Fetch posts failed: ${res.body}");
    }

    final data = jsonDecode(res.body);

    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }

  // ─────────────────────────────
  // CREATE POST (WITH AI)
  // ─────────────────────────────
  static Future<Map<String, dynamic>> createPostWithImages({
    required String text,
    required List<File> imageFiles,
  }) async {
    final uri = Uri.parse("$baseUrl/api/posts/create");

    final request = http.MultipartRequest("POST", uri);
    request.headers.addAll(await _headers(isJson: false));

    request.fields["userId"] = _currentUserId;
    request.fields["name"] = _currentUserName;
    request.fields["text"] = text;

    for (final file in imageFiles) {
      request.files.add(
        await http.MultipartFile.fromPath("images", file.path),
      );
    }

    final streamed = await request.send();
    final response = await streamed.stream.bytesToString();

    final decoded = jsonDecode(response);

    if (streamed.statusCode == 201) {
      return {
        "post": decoded["post"],
        "ai": decoded["ai"]
      };
    }

    throw Exception(decoded["message"] ?? "Create post failed");
  }

  // ─────────────────────────────
  // LIKE POST
  // ─────────────────────────────
  static Future<Map<String, dynamic>> toggleLike(String postId) async {
    final uri = Uri.parse("$baseUrl/api/posts/like");

    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        "postId": postId,
        "userId": _currentUserId,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["error"] ?? "Like failed");
    }

    return data;
  }

  // ─────────────────────────────
  // COMMENT
  // ─────────────────────────────
  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String text,
  }) async {
    final uri = Uri.parse("$baseUrl/api/posts/comment");

    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        "postId": postId,
        "userId": _currentUserId,
        "text": text,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["error"] ?? "Comment failed");
    }

    return data;
  }
}