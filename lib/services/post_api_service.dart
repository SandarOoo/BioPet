import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostApiService {
  static const String baseUrl = "http://10.0.2.2:3000";

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
  // CURRENT USER (TEMP)
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
  // FETCH POSTS (FIXED)
  // ─────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchPosts(int page) async {
    final uri = Uri.parse("$baseUrl/api/posts?page=$page&limit=10");

    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }

      throw Exception("Invalid response format");
    }

    throw Exception("Failed to fetch posts: ${res.statusCode}");
  }

  // ─────────────────────────────
  // CREATE POST WITH IMAGES (FIXED)
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

    if (streamed.statusCode == 201) {
      return jsonDecode(response);
    }

    throw Exception("Create post failed: ${streamed.statusCode} $response");
  }

  // ─────────────────────────────
  // LIKE POST (FIXED)
  // ─────────────────────────────
  static Future<void> toggleLike(String postId) async {
    final uri = Uri.parse("$baseUrl/api/posts/like");

    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        "postId": postId,
        "userId": _currentUserId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Like failed: ${res.body}");
    }
  }

  // ─────────────────────────────
  // COMMENT POST (FIXED)
  // ─────────────────────────────
  static Future<void> addComment({
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

    if (res.statusCode != 200) {
      throw Exception("Comment failed: ${res.body}");
    }
  }
}