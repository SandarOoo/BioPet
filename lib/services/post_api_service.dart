import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostApiService {

  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? "";

  // ============================================================
  // TOKEN
  // ============================================================

  static Future<String?> getToken() async {

    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getString('token');
  }


  // ============================================================
  // HEADERS
  // ============================================================

  static Future<Map<String, String>> _headers({
    bool isJson = true,
  }) async {

    final token =
    await getToken();

    return {

      if (isJson)
        "Content-Type":
        "application/json",

      "ngrok-skip-browser-warning":
      "true",

      if (token != null &&
          token.isNotEmpty)
        "Authorization":
        "Bearer $token",

    };

  }


  // ============================================================
  // CURRENT USER
  // ============================================================

  static String _currentUserId =
      "guest";

  static String _currentUserName =
      "Guest";


  static void setUser({
    required String id,
    required String name,
  }) {

    _currentUserId =
        id;

    _currentUserName =
        name;

    print(
      "POST SERVICE USER ID => "
          "$_currentUserId",
    );

    print(
      "POST SERVICE USER NAME => "
          "$_currentUserName",
    );

  }


  static String get currentUserId =>
      _currentUserId;


  static String get currentUserName =>
      _currentUserName;



  // ============================================================
  // FETCH POSTS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  fetchPosts(
      int page,
      ) async {

    try {

      final uri =
      Uri.parse(
        "$baseUrl/api/posts?page=$page&limit=10",
      );


      print(
        "GET POSTS URL => $uri",
      );


      final res =
      await http.get(
        uri,
        headers:
        await _headers(),
      );


      print(
        "GET POSTS STATUS => "
            "${res.statusCode}",
      );


      print(
        "GET POSTS BODY => "
            "${res.body}",
      );


      if (res.statusCode != 200) {

        throw Exception(
          "Fetch posts failed: "
              "${res.body}",
        );

      }


      final data =
      jsonDecode(
        res.body,
      );


      // ========================================================
      // BACKEND RESPONSE
      //
      // {
      //   "success": true,
      //   "posts": [...]
      // }
      // ========================================================

      if (data is Map &&
          data["success"] == true) {

        final posts =
        data["posts"];


        if (posts is List) {

          final result =
          posts
              .map(
                (post) =>
            Map<String, dynamic>.from(
              post,
            ),
          )
              .toList();


          print(
            "POST COUNT => "
                "${result.length}",
          );


          return result;

        }

      }


      // ========================================================
      // FALLBACK
      // If backend returns direct List
      // ========================================================

      if (data is List) {

        return data
            .map(
              (post) =>
          Map<String, dynamic>.from(
            post,
          ),
        )
            .toList();

      }


      return [];

    } catch (e) {

      print(
        "FETCH POSTS ERROR => $e",
      );

      rethrow;

    }

  }



  // ============================================================
  // CREATE POST + GEMINI AI
  // ============================================================

  static Future<Map<String, dynamic>>
  createPostWithImages({

    required String text,

    required List<File>
    imageFiles,

  }) async {

    try {

      final uri =
      Uri.parse(
        "$baseUrl/api/posts/create",
      );


      print(
        "CREATE POST URL => $uri",
      );


      final request =
      http.MultipartRequest(
        "POST",
        uri,
      );


      request.headers.addAll(
        await _headers(
          isJson: false,
        ),
      );


      // ========================================================
      // USER DATA
      // ========================================================

      request.fields["userId"] =
          _currentUserId;


      request.fields["name"] =
          _currentUserName;


      request.fields["text"] =
          text.trim();


      // ========================================================
      // IMAGES
      // ========================================================

      for (
      final file
      in imageFiles
      ) {

        request.files.add(

          await http.MultipartFile
              .fromPath(

            "images",

            file.path,

          ),

        );

      }


      print(
        "SENDING POST TO BACKEND...",
      );


      final streamed =
      await request.send();


      final response =
      await streamed
          .stream
          .bytesToString();


      print(
        "CREATE POST STATUS => "
            "${streamed.statusCode}",
      );


      print(
        "CREATE POST RESPONSE => "
            "$response",
      );


      final decoded =
      jsonDecode(
        response,
      );


      // ========================================================
      // SUCCESS
      // ========================================================

      if (
      streamed.statusCode ==
          201 &&
          decoded["success"] ==
              true
      ) {

        print(
          "POST CREATED SUCCESSFULLY",
        );


        print(
          "AI RESULT => "
              "${decoded["ai"]}",
        );


        return {

          "success":
          true,

          "post":
          decoded["post"],

          "ai":
          decoded["ai"],

          "message":
          decoded["message"],

        };

      }


      // ========================================================
      // AI BLOCKED POST
      // ========================================================

      throw Exception(

        decoded["message"] ??
            "Create post failed",

      );


    } catch (e) {

      print(
        "CREATE POST ERROR => $e",
      );

      rethrow;

    }

  }



  // ============================================================
  // LIKE POST
  // ============================================================

  static Future<Map<String, dynamic>>
  toggleLike(
      String postId,
      ) async {

    final uri =
    Uri.parse(
      "$baseUrl/api/posts/like",
    );


    final res =
    await http.post(

      uri,

      headers:
      await _headers(),

      body:
      jsonEncode({

        "postId":
        postId,

        "userId":
        _currentUserId,

      }),

    );


    print(
      "LIKE STATUS => "
          "${res.statusCode}",
    );


    print(
      "LIKE BODY => "
          "${res.body}",
    );


    final data =
    jsonDecode(
      res.body,
    );


    if (
    res.statusCode !=
        200
    ) {

      throw Exception(

        data["message"] ??
            data["error"] ??
            "Like failed",

      );

    }


    return data;

  }



  // ============================================================
  // ADD COMMENT
  // ============================================================

  static Future<Map<String, dynamic>>
  addComment({

    required String postId,

    required String text,

  }) async {

    final uri =
    Uri.parse(
      "$baseUrl/api/posts/comment",
    );


    final res =
    await http.post(

      uri,

      headers:
      await _headers(),

      body:
      jsonEncode({

        "postId":
        postId,

        "userId":
        _currentUserId,

        "text":
        text.trim(),

      }),

    );


    print(
      "COMMENT STATUS => "
          "${res.statusCode}",
    );


    print(
      "COMMENT BODY => "
          "${res.body}",
    );


    final data =
    jsonDecode(
      res.body,
    );


    if (
    res.statusCode !=
        200
    ) {

      throw Exception(

        data["message"] ??
            data["error"] ??
            "Comment failed",

      );

    }


    return data;

  }

}